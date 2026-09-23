import XCTest

/// Pin and save a message (UI Kit 5.1.22). The options only exist when the app has the Pin
/// Message / Save Message extensions enabled (`CometChat.isPinMessageEnabled()` /
/// `isSaveMessageEnabled()`); on an app without them every case skips with that reason rather
/// than failing, the same way PollsTests handles the Polls extension.
final class PinAndSaveMessageTests: XCTestCase {

    private var app: XCUIApplication!

    private enum Copy {
        static let pin = "Pin message"
        static let unpin = "Unpin message"
        static let save = "Save message"
        static let pinnedMessages = "Pinned Messages"
        static let pinnedEmpty = "No pinned messages yet"
        static let savedEmpty = "No saved messages yet"
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    /// Send a message and open its options; skip when the extension's option is not offered.
    private func openOptionsOnNewMessage(requiring option: String) throws -> String {
        app = openSeededConversation()
        let token = "ps\(UUID().uuidString.prefix(6).lowercased())"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 15), "Message did not send")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        guard ComponentQueries.messageOptionExists(app, label: option, timeout: 6) else {
            throw XCTSkip("'\(option)' is not offered: its extension is not enabled for this App ID")
        }
        return token
    }

    private func openPinnedMessagesScreen() {
        let more = app.buttons["More"].firstMatch
        XCTAssertTrue(more.waitForExistence(timeout: 8), "Header menu button missing")
        more.tap()
        let entry = app.buttons[Copy.pinnedMessages].exists ? app.buttons[Copy.pinnedMessages] : app.staticTexts[Copy.pinnedMessages]
        XCTAssertTrue(entry.firstMatch.waitForExistence(timeout: 8), "Pinned Messages entry missing from the header menu")
        entry.firstMatch.tap()
    }

    func test_1TO1_PIN_pinOptionIsOffered() throws {
        _ = try openOptionsOnNewMessage(requiring: Copy.pin)
    }

    func test_1TO1_PIN_pinnedMessageAppearsInPinnedList() throws {
        let token = try openOptionsOnNewMessage(requiring: Copy.pin)
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: Copy.pin), "Could not tap Pin message")
        openPinnedMessagesScreen()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", token)).firstMatch
                        .waitForExistence(timeout: 12)
                        || ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 2),
                      "Pinned message not listed on the Pinned Messages screen")
    }

    func test_1TO1_PIN_pinnedMessageOffersUnpin() throws {
        let token = try openOptionsOnNewMessage(requiring: Copy.pin)
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: Copy.pin), "Could not tap Pin message")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.messageOptionExists(app, label: Copy.unpin),
                      "A pinned message does not offer Unpin")
    }

    func test_1TO1_SAVE_saveOptionIsOffered() throws {
        _ = try openOptionsOnNewMessage(requiring: Copy.save)
    }

    // MARK: - Wave 6: pinned jump / unpin, and the Saved Messages screen

    private enum Wave6Copy {
        static let unsave = "Unsave message"
        static let savedMessages = "Saved Messages"
        static let unpinConfirm = "Unpin"
        static let unsaveConfirm = "Unsave"
        static let pinLimit = "You can only pin"
    }

    /// Pin the freshly sent message from its options; skip when the app's pin limit is hit
    /// (a configuration fact of the shared app, not a defect).
    private func pinCurrentMessage() throws {
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: Copy.pin), "Could not tap Pin message")
        let limit = app.staticTexts.containing(NSPredicate(format: "label BEGINSWITH %@", Wave6Copy.pinLimit)).firstMatch
        if limit.waitForExistence(timeout: 2) {
            throw XCTSkip("The conversation is at its pin limit; unpin something first")
        }
    }

    private func leaveToHome() {
        for _ in 0..<3 {
            if app.tabBars.firstMatch.exists { return }
            if let back = ComponentQueries.headerBackButton(app), back.isHittable {
                back.tap()
            } else if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
            }
            _ = app.tabBars.firstMatch.waitForExistence(timeout: 6)
        }
    }

    private func pinnedRow(for token: String) -> XCUIElement {
        let asCell = app.cells.containing(NSPredicate(format: "label CONTAINS %@", token)).firstMatch
        if asCell.exists { return asCell }
        return app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", token)).firstMatch
    }

    /// Tapping a row on Pinned Messages returns to the conversation scrolled to that message —
    /// here the pinned message is pushed off-screen by 14 newer ones seeded while the chat is
    /// closed, so it is only visible again if the jump actually happened. The fillers are sent
    /// AS A (from "another device"): B's would be unread, and `startFromUnreadMessages` would
    /// then open the list at the unread divider — right next to the pinned message.
    func test_1TO1_PIN_tappingPinnedRowJumpsToTheMessage() throws {
        let token = try openOptionsOnNewMessage(requiring: Copy.pin)
        try pinCurrentMessage()
        leaveToHome()
        let fill = "E2E-pinfill-\(UUID().uuidString.prefix(4).lowercased())"
        try runBlocking {
            for i in 1...14 { _ = try await PeerActions.sendTextMessageAsA("\(fill) #\(i)") }
        }

        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not reopen the conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Conversation did not reopen")
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: "\(fill) #14", timeout: 20),
                      "The newest seeded message is not at the bottom")
        XCTAssertFalse(ComponentQueries.bubble(app, text: token).exists,
                       "Precondition: the pinned message is still on screen, so a jump proves nothing")

        openPinnedMessagesScreen()
        let row = pinnedRow(for: token)
        XCTAssertTrue(row.waitForExistence(timeout: 12), "Pinned message not listed")
        row.tap()

        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10),
                      "Tapping the pinned row did not return to the conversation")
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 15),
                      "The list did not scroll to the pinned message")
    }

    /// Unpinning from the message options removes the message from the Pinned Messages screen.
    func test_1TO1_PIN_unpinRemovesFromPinnedList() throws {
        let token = try openOptionsOnNewMessage(requiring: Copy.pin)
        try pinCurrentMessage()
        openPinnedMessagesScreen()
        XCTAssertTrue(pinnedRow(for: token).waitForExistence(timeout: 12), "Pinned message not listed before unpin")
        if let back = ComponentQueries.headerBackButton(app), back.isHittable { back.tap() }
        else { app.navigationBars.buttons.firstMatch.tap() }
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Did not return to the conversation")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: Copy.unpin), "Unpin message not offered")
        let confirm = app.alerts.buttons[Wave6Copy.unpinConfirm].firstMatch
        if confirm.waitForExistence(timeout: 4) { confirm.tap() }

        openPinnedMessagesScreen()
        XCTAssertTrue(app.staticTexts[Copy.pinnedMessages].waitForExistence(timeout: 8)
                        || app.navigationBars[Copy.pinnedMessages].exists,
                      "Pinned Messages screen did not open")
        XCTAssertFalse(pinnedRow(for: token).waitForExistence(timeout: 5),
                       "The unpinned message is still listed on Pinned Messages")
    }

    /// Saved messages are user-level, so the sample app opens them from the Chats screen's avatar
    /// menu. That menu is a `showsMenuAsPrimaryAction` pull-down, which a plain XCUITest tap does
    /// not open (the app exposes a `uiTestLogout` bar button for exactly this reason); a
    /// long-press does. If neither opens it the case skips with the blocker named.
    private func openSavedMessagesScreen() throws {
        leaveToHome()
        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats), "Chats tab unavailable")
        let bar = app.navigationBars.firstMatch
        XCTAssertTrue(bar.waitForExistence(timeout: 10), "Chats navigation bar missing")
        let avatar = bar.buttons.allElementsBoundByIndex.first { $0.exists && $0.identifier != "uiTestLogout" && $0.label != "uiTestLogout" }
        guard let avatar else { throw XCTSkip("blocked: no avatar button in the Chats navigation bar") }
        let entry = app.buttons[Wave6Copy.savedMessages].firstMatch
        avatar.tap()
        if !entry.waitForExistence(timeout: 3) {
            avatar.press(forDuration: 1.0)
        }
        guard entry.waitForExistence(timeout: 5) else {
            throw XCTSkip("blocked: the avatar pull-down menu did not open under XCUITest — needs a -UITestMode entry for Saved Messages, like uiTestLogout")
        }
        entry.tap()
        XCTAssertTrue(app.staticTexts[Wave6Copy.savedMessages].waitForExistence(timeout: 10)
                        || app.navigationBars[Wave6Copy.savedMessages].waitForExistence(timeout: 2),
                      "Saved Messages screen did not open")
    }

    private func savedRow(for token: String) -> XCUIElement { pinnedRow(for: token) }

    /// Unsave the row that carries `token` from the Saved Messages screen (swipe → Unsave → confirm).
    private func unsaveRow(_ row: XCUIElement) {
        row.swipeLeft()
        let action = app.buttons[Wave6Copy.unsave].firstMatch
        XCTAssertTrue(action.waitForExistence(timeout: 5), "Swipe did not reveal Unsave")
        action.tap()
        let confirm = app.alerts.buttons[Wave6Copy.unsaveConfirm].firstMatch
        if confirm.waitForExistence(timeout: 4) { confirm.tap() }
    }

    func test_1TO1_SAVE_savedMessageAppearsInSavedList() throws {
        let token = try openOptionsOnNewMessage(requiring: Copy.save)
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: Copy.save), "Could not tap Save message")
        try openSavedMessagesScreen()
        XCTAssertTrue(savedRow(for: token).waitForExistence(timeout: 12),
                      "The saved message is not listed on Saved Messages")
    }

    func test_1TO1_SAVE_unsaveRemovesFromSavedList() throws {
        let token = try openOptionsOnNewMessage(requiring: Copy.save)
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: Copy.save), "Could not tap Save message")
        try openSavedMessagesScreen()
        let row = savedRow(for: token)
        XCTAssertTrue(row.waitForExistence(timeout: 12), "The saved message is not listed before unsave")
        unsaveRow(row)
        XCTAssertTrue(waitForCondition(timeout: 10) { !self.savedRow(for: token).exists },
                      "The unsaved message is still listed on Saved Messages")
    }

    /// The empty state shows once nothing is saved. The shared app accumulates saved messages
    /// from earlier runs, so every row is unsaved first (bounded) before the state is asserted.
    func test_1TO1_SAVE_emptyStateWhenNothingSaved() throws {
        _ = try openOptionsOnNewMessage(requiring: Copy.save)
        app.tap() // dismiss the options popup; the Save option only had to exist
        try openSavedMessagesScreen()
        let empty = app.staticTexts[Copy.savedEmpty]
        var budget = 12
        while !empty.exists, budget > 0, app.cells.firstMatch.waitForExistence(timeout: 3) {
            unsaveRow(app.cells.firstMatch)
            budget -= 1
            _ = empty.waitForExistence(timeout: 2)
        }
        XCTAssertTrue(empty.waitForExistence(timeout: 8), "Saved Messages did not show its empty state once nothing was saved")
    }

    /// Tapping a saved row opens the message's own conversation, scrolled to the message.
    func test_1TO1_SAVE_tappingSavedRowOpensTheMessage() throws {
        let token = try openOptionsOnNewMessage(requiring: Copy.save)
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: Copy.save), "Could not tap Save message")
        try openSavedMessagesScreen()
        let row = savedRow(for: token)
        XCTAssertTrue(row.waitForExistence(timeout: 12), "The saved message is not listed")
        row.tap()
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Tapping the saved row did not open a conversation")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8),
                      "The opened conversation is not the one with \(TestConfig.userBDisplayName)")
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 15),
                      "The saved message is not shown in the opened conversation")
    }
}
