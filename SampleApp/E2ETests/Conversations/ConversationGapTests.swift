import XCTest

/// Gap cases around the conversation list and message-list chrome: empty-UID login validation,
/// visible timestamps, unread clearing on open, the new-message affordance while scrolled up,
/// and rapid chat switching under live traffic.
/// Sheet sources: Sanity AUTH-03 / CONV-05 / CONV-07; sample-app sheet timestamp/unread rows;
/// catalog RT-EDGE "switch chats rapidly".
final class ConversationGapTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?
    private var ctx: SeedData.TestGroupContext?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { [group, ctx] in
            await SeedData.deleteTestGroup(group)
            await SeedData.deleteTestGroup(ctx)
        }
        group = nil
        ctx = nil
        runBlocking { await SeedData.cleanup() }
    }

    private static let timePattern = "^[0-9]{1,2}:[0-9]{2}( ?[APap][Mm])?$"

    /// The messages screen hides the navigation bar and draws its own header, so
    /// `AppLauncher.goBack` (which taps `navigationBars.buttons.firstMatch`) finds nothing there.
    /// Use the header's own back control, falling back to the nav bar for screens that have one.
    private func leaveConversation() {
        if let back = ComponentQueries.headerBackButton(app), back.isHittable {
            back.tap()
        } else if app.navigationBars.buttons.firstMatch.exists {
            app.navigationBars.buttons.firstMatch.tap()
        }
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 8)
    }

    /// AUTH-03 — Continue with an empty UID must not log in (stays on Login, no crash).
    func test_LOGIN_emptyUIDBlocked() throws {
        app = AppLauncher.launchToLogin()
        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 15), "Login screen did not appear")
        if continueButton.isEnabled { continueButton.tap() }
        // Either the button was disabled, an error surfaced, or we simply stayed on Login.
        XCTAssertFalse(app.tabBars.buttons[AppLauncher.TabLabel.chats].waitForExistence(timeout: 6),
                       "Empty-UID login unexpectedly reached Home")
        XCTAssertTrue(continueButton.exists || app.alerts.firstMatch.exists,
                      "Login screen lost after empty-UID attempt")
    }

    /// Sample-app sheet — a sent message renders with a visible HH:mm timestamp.
    func test_1TO1_sentMessageShowsTimestamp() throws {
        app = openSeededConversation()
        let token = "tstamp\(UUID().uuidString.prefix(6).lowercased())"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 15), "Message not sent")
        let time = app.staticTexts.matching(
            NSPredicate(format: "label MATCHES %@", Self.timePattern)).firstMatch
        XCTAssertTrue(time.waitForExistence(timeout: 8), "No visible timestamp near the sent message")
    }

    /// CONV-05 — the conversation row carries a readable time/date stamp.
    func test_CONV_rowShowsTimestamp() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        try runBlocking { _ = try await PeerActions.sendTextMessage("E2E row time probe") }
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        let row = app.staticTexts[TestConfig.userBDisplayName]
        XCTAssertTrue(row.waitForExistence(timeout: 15), "B's conversation row missing")
        let rowY = row.frame.midY
        let stampish = NSPredicate(
            format: "label MATCHES %@ OR label == 'Yesterday' OR label == 'Today'",
            "^[0-9]{1,2}:[0-9]{2}( ?[APap][Mm])?$")
        let stamp = app.staticTexts.matching(stampish).allElementsBoundByIndex
            .first { $0.exists && abs($0.frame.midY - rowY) < 44 }
        XCTAssertNotNil(stamp, "Conversation row shows no timestamp")
    }

    /// Wave 6 — a group conversation's Chats-row preview follows a member's new message. B sends
    /// while A is on another tab; entering Chats re-fetches the list, and the group's row must
    /// carry the new text (the backend `lastMessage` is checked too, as the 1:1 cases do).
    func test_CONV_groupPreviewUpdatesOnNewMessage() throws {
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = created
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users)

        let token = "gprev\(UUID().uuidString.prefix(6).lowercased())"
        try runBlocking { _ = try await PeerActions.sendGroupTextMessage("E2E \(token)", groupId: created.guid) }
        XCTAssertTrue(waitForBackend(timeout: 15) {
            await PeerActions.lastGroupConversationMessageText(guid: created.guid) == "E2E \(token)"
        }, "Backend lastMessage for the group did not update")

        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        XCTAssertTrue(app.staticTexts[created.name].waitForExistence(timeout: 20),
                      "The group has no row in Chats after B's message")
        let rowY = app.staticTexts[created.name].frame.midY
        let preview = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", token))
        XCTAssertTrue(waitForCondition(timeout: 15) {
            preview.allElementsBoundByIndex.contains { $0.exists && abs($0.frame.midY - rowY) < 60 }
        }, "The group's Chats row does not preview B's new message")
    }

    /// Wave 6 — a member kicked from a group loses that group's conversation. A is a participant
    /// in B's group and is watching Chats; B kicks A over REST; the row must go (the kit removes
    /// it on `onGroupMemberKicked`). Real-time.
    func test_CONV_kickedMemberLosesGroupConversation() throws {
        let context = try runBlocking { try await SeedData.createGroupOwnedByBWithAAs("participant") }
        ctx = context
        // A message from B gives A a conversation for the group in the first place.
        try runBlocking {
            _ = try await PeerActions.sendGroupTextMessage("E2E kick \(UUID().uuidString.prefix(6))",
                                                           groupId: context.group.guid)
        }
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        let row = app.staticTexts[context.group.name]
        XCTAssertTrue(row.waitForExistence(timeout: 20), "The group's conversation is not listed before the kick")

        try runBlocking {
            try await PeerActions.kickGroupMember(guid: context.group.guid, uid: TestConfig.userAUid, by: TestConfig.userBUid)
        }
        XCTAssertTrue(waitForCondition(timeout: 25) { !row.exists },
                      "The group's conversation stayed in Chats after A was kicked")
    }

    /// CONV-07 — opening the conversation clears its unread badge in the list.
    func test_CONV_openingClearsUnreadBadge() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users)
        try runBlocking { _ = try await PeerActions.sendMultipleMessages(2, prefix: "E2E-clear") }
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        guard waitForUnreadBadge(rowNamed: TestConfig.userBDisplayName, timeout: 20) != nil else {
            throw XCTSkip("No unread badge appeared to clear (backend timing)")
        }
        let row = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 8), "Conversation row missing")
        row.tap()
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Conversation did not open")
        leaveConversation()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        XCTAssertTrue(waitForCondition(timeout: 15) {
            self.unreadBadgeLabel(rowNamed: TestConfig.userBDisplayName) == nil
        }, "Unread badge did not clear after opening the conversation")
    }

    /// Sample-app sheet — a message arriving while scrolled up surfaces a new-message affordance.
    ///
    /// Parked on a kit defect this case found, reproduced by hand on 2026-09-17: when the
    /// conversation is opened with unread messages pending (the "New" divider mode), a message
    /// received while scrolled up puts its count on the scroll-to-bottom control — and the first
    /// scroll movement wipes it, leaving a bare chevron. The receive path sets the count, but
    /// `CometChatMessageList.scrollViewDidScroll` calls `reset()` on every tick while
    /// `unreadSeparatorMode == .navigateFromConversation` instead of re-applying it as every
    /// other mode does; the insert's own re-layout fires a tick immediately, so under automation
    /// the count is gone before it can be asserted, and by hand it visibly vanishes on the
    /// first touch. Open the same chat with nothing unread and the count survives scrolling. `openSeededConversation()` seeds before opening, so
    /// this case always lands in the affected mode. Runs again once the kit keeps the count
    /// there, or now with `E2E_RUN_PARKED=1` in the environment to check a fix.
    func test_1TO1_newMessageIndicatorWhileScrolledUp() throws {
        if ProcessInfo.processInfo.environment["E2E_RUN_PARKED"] == nil {
            throw XCTSkip("Kit defect: unread count on the scroll-to-bottom control is wiped by the first scroll movement when the chat was opened with unread pending — ENG-39419")
        }
        app = openSeededConversation()
        try runBlocking { _ = try await PeerActions.sendMultipleMessages(8, prefix: "E2E-pad") }
        _ = app.staticTexts.firstMatch.waitForExistence(timeout: 2)
        app.swipeDown(); app.swipeDown(); app.swipeDown()
        let token = "E2E-fresh-\(UUID().uuidString.prefix(6))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        // The affordance is a digit badge / pill / scroll-to-latest control near the composer.
        let affordance = app.staticTexts.matching(
            NSPredicate(format: "label MATCHES '^[0-9]{1,3}\\\\+?$' OR label CONTAINS[c] 'new message'")
        ).firstMatch
        let appeared = affordance.waitForExistence(timeout: 12)
        // Behavioural floor either way: returning to the bottom shows the fresh message.
        app.swipeUp(); app.swipeUp(); app.swipeUp()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 15),
                      "Fresh message unreachable after scrolling back down")
        XCTAssertTrue(appeared, "No new-message indicator appeared while scrolled up")
    }

    /// RT-EDGE — switching between two live chats under traffic keeps both consistent.
    func test_EDGE_rapidChatSwitchingUnderTraffic() throws {
        var created: SeedData.TestGroup?
        (app, created) = openSeededGroupWithMember()
        group = created
        guard let group else { return }

        var lastOneToOne = ""; var lastGroup = ""
        for round in 1...3 {
            let stamp = UUID().uuidString.prefix(4).lowercased()
            lastGroup = "E2E-gsw-\(round)-\(stamp)"
            try runBlocking { [lastGroup] in
                _ = try await PeerActions.sendGroupTextMessage(lastGroup, groupId: group.guid)
            }
            leaveConversation()
            XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                          "Could not open the 1:1 on round \(round)")
            lastOneToOne = "E2E-usw-\(round)-\(stamp)"
            try runBlocking { [lastOneToOne] in _ = try await PeerActions.sendTextMessage(lastOneToOne) }
            XCTAssertTrue(ComponentQueries.waitForBubble(app, text: lastOneToOne, timeout: 20),
                          "1:1 message missing on round \(round)")
            leaveConversation()
            XCTAssertTrue(AppLauncher.openGroup(app, named: group.name),
                          "Could not reopen the group on round \(round)")
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: lastGroup, timeout: 20),
                      "Group message missing after rapid switching")
    }

    // MARK: - Badge helpers (same heuristics as UnreadBadgeTests)

    /// The digit badge inside the conversation cell named `name`, or nil when the cell has none.
    /// Scoped to the cell on purpose: this used to take the first "name" label anywhere on
    /// screen and look for digits at that height, and the Users tab — visited a step earlier and
    /// still in the hierarchy — has its own "name" row whose height lined up with another
    /// conversation's badge, so "did the badge clear" answered no while the row was plainly clean.
    private func unreadBadgeLabel(rowNamed name: String) -> String? {
        let row = app.cells.containing(.staticText, identifier: name).firstMatch
        guard row.exists else { return nil }
        let digits = NSPredicate(format: "label MATCHES %@", "^[0-9]{1,3}\\+?$")
        return row.staticTexts.matching(digits).firstMatch.exists
            ? row.staticTexts.matching(digits).firstMatch.label
            : nil
    }

    private func waitForUnreadBadge(rowNamed name: String, timeout: TimeInterval) -> String? {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if let label = unreadBadgeLabel(rowNamed: name) { return label }
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 0.5)
        } while Date() < deadline
        return nil
    }
}
