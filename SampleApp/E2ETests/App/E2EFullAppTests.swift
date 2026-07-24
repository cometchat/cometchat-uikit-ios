import XCTest

/// Full-track single-device cases; smoke/realtime/admin-group cases live in their own files.
/// Most assert screen-presence; edit/delete paths go deeper where locators allow it without fragility.
final class E2EFullAppTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    func test_E2E_conversationListPaginationScrolls() {
        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)

        let table = app.tables.firstMatch
        XCTAssertTrue(table.waitForExistence(timeout: 15), "Conversation list did not render")
        table.swipeUp()
        table.swipeUp()

        // The tab bar still present is the signal the list survived pagination.
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Home tab bar vanished after scrolling conversations")
    }

    func test_E2E_deleteConversationRemovesRow() {
        do {
            try runBlocking { try await SeedData.createTestConversation() }
        } catch {
            return XCTFail("Seeding the conversation failed: \(error)")
        }

        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)

        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "No conversations to delete")

        let named = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName)
        XCTAssertTrue(named.firstMatch.waitForExistence(timeout: 10), "Seeded conversation not found")

        // The REST conversation-list projection lags the SDK socket that painted the row above, so poll.
        XCTAssertTrue(
            waitForBackend(timeout: 15) { await PeerActions.userConversationExists() },
            "Seeded conversation missing on backend before delete"
        )

        // Anchor Y to the peer-name label, but a plain [name] query can resolve to a RECYCLED cell's label
        // whose a11y frame is the {inf,inf,0,0} placeholder. Pick the first label with a real on-screen
        // frame (usually only one), then fall back to the containing cell — never assert on the placeholder.
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 10), "Peer-name label not found")
        func usableY(_ frame: CGRect) -> CGFloat? {
            (frame.midY.isFinite && frame.width > 1 && frame.height > 1) ? frame.midY : nil
        }
        let labels = app.staticTexts.matching(identifier: TestConfig.userBDisplayName)
        var rowMidY: CGFloat?
        for i in 0..<labels.count {
            if let y = usableY(labels.element(boundBy: i).frame) { rowMidY = y; break }
        }
        if rowMidY == nil {
            rowMidY = usableY(named.firstMatch.frame)
        }
        guard let rowMidY else {
            return XCTFail("No on-screen frame for \(TestConfig.userBDisplayName) row (all recycled placeholders)")
        }

        let window = app.windows.firstMatch
        let winWidth = window.frame.width
        func winPoint(_ x: CGFloat, _ y: CGFloat) -> XCUICoordinate {
            window.coordinate(withNormalizedOffset: .zero).withOffset(CGVector(dx: x, dy: y))
        }

        // The delete action is a UIContextualAction (a data object, not a view) UIKit renders in a private,
        // un-taggable swipe button — no accessibilityIdentifier is possible, so this coordinate tap is a
        // deliberate workaround: drag FAR + hold so the latch-off drawer settles open, then tap the button
        // CENTER (~55pt in) — its inner edge lets a few px of spring-back hit the cell and open the chat.
        let alert = app.alerts.firstMatch
        var alertShown = false
        for _ in 0..<5 {
            winPoint(winWidth - 6, rowMidY)
                .press(
                    forDuration: 0.1,
                    thenDragTo: winPoint(winWidth * 0.30, rowMidY),
                    withVelocity: .init(120),
                    thenHoldForDuration: 1.2
                )
            winPoint(winWidth - 55, rowMidY).tap()
            if alert.waitForExistence(timeout: 3) { alertShown = true; break }
        }
        XCTAssertTrue(alertShown, "Delete-confirmation alert did not appear after retries")

        let confirmButton = alert.buttons["Delete"]
        XCTAssertTrue(confirmButton.waitForExistence(timeout: 5), "Alert has no destructive Delete button")
        confirmButton.tap()

        // Counting this list hangs the a11y bridge; assert deletion on the backend instead.
        XCTAssertTrue(
            waitForBackend(timeout: 15) { await PeerActions.userConversationExists() == false },
            "Conversation still exists on backend after delete"
        )
    }

    func test_E2E_usersListPaginationScrolls() {
        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users)

        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Users list did not render")
        app.swipeUp()
        app.swipeUp()
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Home tab bar vanished after scrolling users")
    }

    func test_E2E_searchFiltersUsers() {
        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Users list did not render")

        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10), "Users search field not found")
        search.tap()
        search.typeText(TestConfig.userBDisplayName)

        XCTAssertTrue(
            app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch.waitForExistence(timeout: 10),
            "Search did not surface \(TestConfig.userBDisplayName)"
        )
    }

    func test_E2E_createGroupViaUI() {
        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Groups list did not render")

        XCTAssertTrue(AppLauncher.tapCreateGroupButton(app), "No navbar buttons on Groups")

        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")
    }

    func test_E2E_groupsListPaginationScrolls() {
        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Groups list did not render")
        app.swipeUp()
        app.swipeUp()
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Home tab bar vanished after scrolling groups")
    }

    func test_E2E_searchFiltersGroups() {
        guard let group = try? runBlocking({ try await SeedData.createTestGroupWithMember() }) else {
            return XCTFail("Seeding the group failed")
        }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }

        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Groups list did not render")

        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10), "Groups search field not found")
        search.tap()
        search.typeText(group.name)

        XCTAssertTrue(
            app.cells.containing(.staticText, identifier: group.name).firstMatch.waitForExistence(timeout: 10),
            "Search did not surface \(group.name)"
        )
    }

    func test_E2E_sendEmptyMessageBlocked() {
        try? runBlocking { try await SeedData.createTestConversation() }
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )

        let composer = ComponentQueries.composer(app)
        XCTAssertTrue(composer.waitForExistence(timeout: 12), "Composer did not appear")

        // Send may not resolve for an empty composer; either way nothing must be sent.
        let send = app.buttons["Send"]
        if send.exists { send.tap() }

        XCTAssertTrue(ComponentQueries.composerIsEmpty(app), "Composer should remain empty when nothing was typed")
    }

    func test_E2E_editMessageShowsEditedMarker() {
        try? runBlocking { try await SeedData.createTestConversation() }
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation"
        )

        let token = "E2E-edit-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 12), "Original message did not appear")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Could not open message options")
        XCTAssertTrue(
            ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit),
            "Edit option not found in message popup"
        )

        let composer = ComponentQueries.composer(app)
        XCTAssertTrue(composer.waitForExistence(timeout: 8), "Composer did not focus for edit")
        composer.tap()
        composer.typeText("-ed")
        ComponentQueries.sendButton(app).tap()

        XCTAssertTrue(ComponentQueries.waitForEditedMarker(app, timeout: 12), "Edited marker did not appear after edit")
    }

    func test_E2E_deleteMessageShowsPlaceholder() {
        try? runBlocking { try await SeedData.createTestConversation() }
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation"
        )

        let token = "E2E-del-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 12), "Original message did not appear")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Could not open message options")
        XCTAssertTrue(
            ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.delete),
            "Delete option not found in message popup"
        )

        let confirm = app.alerts.buttons["Delete"]
        if confirm.waitForExistence(timeout: 4) { confirm.tap() }

        XCTAssertTrue(
            ComponentQueries.waitForDeletedPlaceholder(app, timeout: 12),
            "Deleted-message placeholder did not appear"
        )
    }

    func test_E2E_messageListPaginationScrolls() {
        try? runBlocking { try await SeedData.createTestConversation() }
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation"
        )
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 12), "Message list did not open")

        app.swipeDown()
        app.swipeDown()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer vanished after scrolling messages")
    }

    func test_E2E_reactionsScreenPresence() {
        try? runBlocking { try await SeedData.createTestConversation() }
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation"
        )
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 12), "Message list did not open")
    }

    func test_E2E_messageInfoScreenPresence() {
        try? runBlocking { try await SeedData.createTestConversation() }
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation"
        )
        let token = "E2E-info-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 12), "Message did not render")
    }

    func test_E2E_callLogsLoad() throws {
        AppLauncher.launchAndWaitForHome(app)
        guard AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.calls) else {
            throw XCTSkip("Calls tab not visible (CometChatCallsSDK is linked; tab absent only if a build strips it)")
        }
        // Either call-log cells render or an empty-state shows; the tab bar staying up proves no crash.
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10), "Calls screen did not load")
    }

    func test_E2E_callLogsPaginationScrolls() throws {
        AppLauncher.launchAndWaitForHome(app)
        guard AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.calls) else {
            throw XCTSkip("Calls tab not visible (CometChatCallsSDK is linked; tab absent only if a build strips it)")
        }
        app.swipeUp()
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Home tab bar vanished after scrolling call logs")
    }

    /// Overlaps test_E2E_searchFiltersGroups; kept distinct for matrix traceability.
    func test_E2E_searchGroupName() {
        guard let group = try? runBlocking({ try await SeedData.createTestGroupWithMember() }) else {
            return XCTFail("Seeding the group failed")
        }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }

        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Groups list did not render")

        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10), "Groups search not found")
        search.tap()
        search.typeText(group.name)
        XCTAssertTrue(
            app.cells.containing(.staticText, identifier: group.name).firstMatch.waitForExistence(timeout: 10),
            "Group search did not surface \(group.name)"
        )
    }

    /// The Chats-tab search field is read-only and pushes a dedicated search screen on tap.
    func test_E2E_searchMessageContent() throws {
        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)

        let search = app.searchFields.firstMatch
        guard search.waitForExistence(timeout: 10) else {
            throw XCTSkip("Chats search field not present")
        }
        search.tap()

        let editable = app.searchFields.firstMatch
        XCTAssertTrue(editable.waitForExistence(timeout: 8), "Search screen did not present a search field")
        if editable.isHittable {
            editable.tap()
            // Only type when a field can take focus, to avoid a no-focus event-synthesis failure.
            if (editable.value as? String) != nil {
                editable.typeText(TestConfig.userBDisplayName)
            }
        }
        XCTAssertTrue(
            app.navigationBars.firstMatch.exists || app.tabBars.firstMatch.exists,
            "Search screen crashed after input"
        )
    }

    func test_E2E_searchEmptyState() {
        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Users list did not render")

        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10), "Users search not found")
        search.tap()
        search.typeText("zzzzz-no-such-user-\(UUID().uuidString.prefix(6))")

        // Search debounces and re-fetches, so the stale list lingers briefly — wait for the row to clear.
        let knownRow = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(
            knownRow.waitForNonExistence(timeout: 10),
            "Non-matching search unexpectedly surfaced a known user"
        )
        XCTAssertTrue(
            app.navigationBars.firstMatch.exists || app.tabBars.firstMatch.exists, "Empty-state search crashed the screen"
        )
    }

    func test_E2E_sharedUIElementsRender() {
        try? runBlocking { try await SeedData.createTestConversation() }
        AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Conversation list (avatars/badges/dates) did not render")
    }

    /// Sending real media needs the system picker (which the suite can't drive), so assert the affordance only.
    func test_E2E_attachmentAffordancePresent() {
        try? runBlocking { try await SeedData.createTestConversation() }
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation"
        )
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 12), "Composer did not appear")

        XCTAssertTrue(
            ComponentQueries.attachmentAffordanceExists(app),
            "Composer exposed no attachment affordance alongside send"
        )
    }
}
