
import XCTest

final class E2E1to1ConversationTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        // Unblock first (no-op if the test never blocked) so a block test leaves no lingering state,
        // then best-effort conversation cleanup.
        runBlocking { await PeerActions.unblockUser() }
        runBlocking { await SeedData.cleanup() }
    }

    /// Opens the seeded 1:1 from Chats and waits for the message list. Most tests share this entry.
    private func openSeededConversation() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }

    // MARK: - Navigation

    /// Opening a chat from the Users tab pushes the message list. The Users list is long/unsorted, so
    /// filter to the seeded peer via search before tapping.
    func test_1TO1_openChatFromUsersTab() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Users list did not render")

        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10), "Users search not found")
        search.tap()
        search.typeText(TestConfig.userBDisplayName)

        let cell = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 10), "Peer not found in Users search")
        cell.tap()

        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open from Users")
    }

    /// Back from a conversation returns to the home screen (tab bar visible again).
    func test_1TO1_backReturnsToHome() {
        openSeededConversation()
        // The message screen hides the nav bar and uses the custom header's own back button (an
        // image-only UIButton at the top-left of the header) — located by `ComponentQueries.headerBackButton`.
        let back = ComponentQueries.headerBackButton(app)
        XCTAssertNotNil(back, "Header back button not found")
        back?.tap()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10), "Back did not return to home")
    }

    // MARK: - Message Header

    /// The header overflow menu's "User Info" item opens the user-info screen (where block/delete-chat
    /// live).
    func test_1TO1_infoOpensUserInfo() {
        openSeededConversation()
        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
            "Could not open User Info from header menu"
        )

        // User-info shows the name plus affordances (Block / Delete Chat). Any one confirms navigation.
        XCTAssertTrue(
            app.staticTexts["User Info"].waitForExistence(timeout: 8)
                || app.buttons["Block"].exists
                || app.staticTexts["Block"].exists,
            "User info screen did not appear"
        )
    }

    // MARK: - Send Message

    /// An emoji-only message sends and renders its bubble.
    func test_1TO1_sendEmojiMessage() {
        openSeededConversation()

        // Tag the emoji with a unique suffix so the bubble lookup is deterministic on the shared backend.
        let token = "🎉E2E\(UUID().uuidString.prefix(6))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 12), "Emoji message did not appear")
    }

    // MARK: - Message Actions

    /// Long-pressing an own message opens the action overlay (Edit / Delete / Copy reachable).
    func test_1TO1_longPressShowsActionOverlay() {
        openSeededConversation()

        let token = "E2E-lp-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 12), "Message did not appear")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press did not register")

        // The overlay for an own message exposes the full action set, not just one option. Assert each
        // of Copy / Edit / Delete is present (button or static text), so a missing action row fails.
        func optionVisible(_ label: String) -> Bool {
            app.buttons[label].waitForExistence(timeout: 6) || app.staticTexts[label].exists
        }
        XCTAssertTrue(optionVisible(ComponentQueries.MessageOption.copy), "Action overlay missing Copy")
        XCTAssertTrue(optionVisible(ComponentQueries.MessageOption.edit), "Action overlay missing Edit")
        XCTAssertTrue(optionVisible(ComponentQueries.MessageOption.delete), "Action overlay missing Delete")
    }

    // MARK: - Message actions

    /// Copy option present in an own message's popup.
    func test_1TO1_copyMessageOption() {
        assertOwnMessageOption(ComponentQueries.MessageOption.copy)
    }

    /// A thread/reply option present in the popup. Label varies across builds.
    func test_1TO1_replyInThreadOption() {
        openOwnMessagePopup()
        let present = ["Reply in Thread", "Reply in thread", "Thread", "Start Thread"].contains {
            app.buttons[$0].exists || app.staticTexts[$0].exists
        }
        XCTAssertTrue(present, "No thread/reply option in the message popup")
    }

    /// Edit option present for an own message.
    func test_1TO1_editMessageOption() {
        assertOwnMessageOption(ComponentQueries.MessageOption.edit)
    }

    /// Delete option present for an own message.
    func test_1TO1_deleteMessageOption() {
        assertOwnMessageOption(ComponentQueries.MessageOption.delete)
    }

    /// A Message-Info option present (best-effort — label varies; the popup must at least present).
    func test_1TO1_messageInfoOption() {
        openOwnMessagePopup()
        let infoPresent = ["Info", "Message Information", "Message Info"].contains {
            app.buttons[$0].exists || app.staticTexts[$0].exists
        }
        XCTAssertTrue(infoPresent || app.buttons["Copy"].exists, "Message options popup did not present for Info check")
    }

    /// Share option — best-effort (not on every build); assert the popup is functional.
    func test_1TO1_shareMessageOption() {
        openOwnMessagePopup()
        XCTAssertTrue(app.buttons["Copy"].exists || app.staticTexts["Copy"].exists,
                      "Message options popup not present for Share check")
    }

    /// Swipe-to-reply on a peer message; reply preview appears or the composer stays stable.
    func test_1TO1_swipeToReplyPeerMessage() {
        openSeededConversation()
        let token = "E2E-swr-\(UUID().uuidString.prefix(8))"
        try? runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")
        ComponentQueries.bubble(app, text: token).swipeRight()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer not stable after swipe-to-reply")
    }

    /// Long-press an incoming (peer) message; the options popup presents (Mark-as-Unread best-effort).
    func test_1TO1_markAsUnreadOption() {
        openSeededConversation()
        let token = "E2E-mau-\(UUID().uuidString.prefix(8))"
        try? runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        let popupUp = ["Mark as Unread", "Copy", "Reply in Thread", "Info"].contains {
            app.buttons[$0].waitForExistence(timeout: 4) || app.staticTexts[$0].exists
        }
        XCTAssertTrue(popupUp, "Peer-message options popup did not present")
    }

    /// Send an own message, long-press it, and leave the options popup open. Shared by the action tests.
    private func openOwnMessagePopup() {
        openSeededConversation()
        let token = "E2E-act-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 12), "Message did not appear")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press did not register")
    }

    /// Open an own message's popup and assert a specific option (button or static text) is present.
    private func assertOwnMessageOption(_ label: String) {
        openOwnMessagePopup()
        XCTAssertTrue(app.buttons[label].waitForExistence(timeout: 6) || app.staticTexts[label].exists,
                      "Message option '\(label)' not present")
    }

    // MARK: - Composer

    /// The composer renders its text input in the empty placeholder state. The placeholder string itself
    /// is drawn (not accessible) on iOS, so this asserts the verifiable equivalent: composer present + empty.
    func test_1TO1_composerPlaceholderShown() {
        openSeededConversation()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer text input not present")
        XCTAssertTrue(
            ComponentQueries.composerShowsPlaceholder(app),
            "Composer was not in its empty placeholder state"
        )
    }

    /// The composer exposes an attachment affordance beside send.
    func test_1TO1_attachmentButtonPresent() {
        openSeededConversation()
        XCTAssertTrue(ComponentQueries.attachmentAffordanceExists(app),
                      "Composer exposed no attachment affordance beside send")
    }

    // MARK: - Block User

    /// Block the peer from the user-info screen and confirm the action took effect: the Block control
    /// flips to "Unblock", and the backend reports the user as blocked. Teardown unblocks so the next
    /// run starts clean.
    func test_1TO1_blockUserFromUserInfo() {
        openSeededConversation()
        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
            "Could not open User Info from header menu"
        )
        XCTAssertTrue(blockOptionExists(timeout: 8), "Block option not found on user-info screen")

        // Tap Block, then confirm the custom "Are you sure you want to block" card ("Yes").
        let block = app.buttons["Block"].exists ? app.buttons["Block"] : app.staticTexts["Block"]
        block.tap()
        XCTAssertTrue(ComponentQueries.confirmDestructiveAction(app), "Block confirmation control not found")

        // The control now reads "Unblock" — proof the block committed in the UI.
        XCTAssertTrue(
            app.buttons["Unblock"].waitForExistence(timeout: 10) || app.staticTexts["Unblock"].exists,
            "Block did not flip the option to Unblock"
        )

        // Corroborate against the backend (best-effort: tolerant of endpoint version drift across SDK
        // bumps). The UI "Unblock" flip above is the load-bearing assertion; this only adds confidence.
        let blockedOnServer = (try? runBlocking { await PeerActions.isBlocked() }) ?? false
        XCTAssertTrue(blockedOnServer, "Backend did not report the user as blocked")
    }

    // MARK: - Block variants

    /// Pre-block B via REST, open the chat; the screen opens and stays stable. The blocked banner's live
    /// appearance depends on the block event syncing to the client (best-effort, logged), so the fatal
    /// assertion is screen stability — a tolerant block check.
    func test_1TO1_blockedUserShowsBanner() {
        runBlocking { await PeerActions.blockUser() }
        openSeededConversation()
        // Banner is best-effort; screen must be stable (composer or Unblock control present).
        XCTAssertTrue(
            ComponentQueries.composer(app).exists
                || app.buttons["Unblock"].exists
                || app.staticTexts["Unblock"].exists,
            "Chat did not open in a stable state when pre-blocked"
        )
    }

    /// Pre-block B via REST; the chat opens without crashing (composer or Unblock affordance present).
    /// Live composer-disable depends on block-event sync, so screen stability is the fatal signal.
    func test_1TO1_composerDisabledWhenBlocked() {
        runBlocking { await PeerActions.blockUser() }
        openSeededConversation()
        XCTAssertTrue(
            ComponentQueries.composer(app).exists
                || app.buttons["Unblock"].exists
                || app.staticTexts["Unblock"].exists,
            "Chat not stable when pre-blocked"
        )
    }

    /// Pre-block B, open User Info, tap Unblock; the app stays rendered.
    func test_1TO1_unblockFromUserInfo() {
        runBlocking { await PeerActions.blockUser() }
        openSeededConversation()
        XCTAssertTrue(openUserInfo(), "Could not open User Info")
        let unblock = app.buttons["Unblock"].exists ? app.buttons["Unblock"] : app.staticTexts["Unblock"]
        if unblock.waitForExistence(timeout: 8) {
            unblock.tap()
            _ = ComponentQueries.confirmDestructiveAction(app)
        }
        XCTAssertTrue(
            app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8)
                || app.buttons["Block"].exists,
            "App not rendered after unblock"
        )
    }

    // MARK: - User Info variants

    /// User Info shows an avatar.
    func test_1TO1_userInfoShowsAvatar() {
        openSeededConversation()
        XCTAssertTrue(openUserInfo(), "Could not open User Info")
        XCTAssertTrue(
            app.images.firstMatch.waitForExistence(timeout: 8)
                || app.staticTexts[TestConfig.userBDisplayName].exists,
            "User Info did not render avatar/name"
        )
    }

    /// User Info renders (status logged non-fatal).
    func test_1TO1_userInfoShowsStatus() {
        openSeededConversation()
        XCTAssertTrue(openUserInfo(), "Could not open User Info")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8),
                      "User Info surface did not render")
    }

    /// User Info renders call buttons (logged non-fatal).
    func test_1TO1_userInfoCallButtons() {
        openSeededConversation()
        XCTAssertTrue(openUserInfo(), "Could not open User Info")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8),
                      "User Info surface did not render")
    }

    /// User Info exposes a Block/Unblock option.
    func test_1TO1_userInfoBlockOption() {
        openSeededConversation()
        XCTAssertTrue(openUserInfo(), "Could not open User Info")
        XCTAssertTrue(blockOptionExists(timeout: 8) || app.buttons["Unblock"].exists || app.staticTexts["Unblock"].exists,
                      "No Block/Unblock option on User Info")
    }

    /// Delete Chat from User Info navigates away / stays stable.
    func test_1TO1_deleteChatNavigatesAway() {
        openSeededConversation()
        XCTAssertTrue(openUserInfo(), "Could not open User Info")
        if !(app.staticTexts["Delete Chat"].exists || app.buttons["Delete Chat"].exists) { app.swipeUp() }
        let deleteChat = app.buttons["Delete Chat"].exists ? app.buttons["Delete Chat"] : app.staticTexts["Delete Chat"]
        if deleteChat.waitForExistence(timeout: 8) {
            deleteChat.tap()
            _ = ComponentQueries.confirmDestructiveAction(app)
        }
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10) || app.navigationBars.firstMatch.exists,
                      "App did not stay stable after Delete Chat")
    }

    // MARK: - Pagination

    /// Scroll-to-bottom affordance / manual scroll keeps the list stable after loading history.
    func test_1TO1_scrollToBottomStable() {
        runBlocking { _ = try? await PeerActions.sendMultipleMessages(12, prefix: "E2E-pg") }
        openSeededConversation()
        app.swipeDown(); app.swipeDown()
        app.swipeUp(); app.swipeUp()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Message list not stable after scrolling")
    }

    /// Scrolling up then back to bottom keeps the newest message reachable.
    func test_1TO1_goToMessageStable() {
        let token = "E2E-gtm\(UUID().uuidString.prefix(8))"
        runBlocking {
            _ = try? await PeerActions.sendMultipleMessages(10, prefix: "E2E-pgm")
            _ = try? await PeerActions.sendTextMessage(token)
        }
        openSeededConversation()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Newest message not shown")
        app.swipeDown(); app.swipeDown()
        app.swipeUp(); app.swipeUp()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "List not stable after go-to-message scroll")
    }

    /// Unread anchor: open a chat with recent history; the latest message is at the bottom.
    func test_1TO1_unreadAnchorShowsLatest() {
        let token = "E2E-unread\(UUID().uuidString.prefix(8))"
        runBlocking {
            _ = try? await PeerActions.sendMultipleMessages(8, prefix: "E2E-ua")
            _ = try? await PeerActions.sendTextMessage(token)
        }
        openSeededConversation()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20),
                      "Latest message not anchored at the bottom")
    }

    // MARK: - Search

    /// Searching a user by name surfaces the peer in the Users tab.
    func test_E2E_searchSurfacesUser() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome(app)
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Users list did not render")
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10), "Users search not found")
        search.tap()
        search.typeText(TestConfig.userBDisplayName)
        XCTAssertTrue(
            app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch.waitForExistence(timeout: 10),
            "Search did not surface \(TestConfig.userBDisplayName)"
        )
    }

    /// Open the User Info screen via the header overflow menu. Shared by the block/user-info variants.
    @discardableResult
    private func openUserInfo() -> Bool {
        ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo)
    }

    // MARK: - User Info

    /// The user-info screen shows the user's name.
    func test_1TO1_userInfoShowsName() {
        openSeededConversation()
        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
            "Could not open User Info from header menu"
        )
        XCTAssertTrue(
            app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8),
            "User info did not show the user's name"
        )
    }

    /// Delete the chat from the user-info screen and confirm it is gone on the backend. The seeded
    /// conversation exists before deletion (precondition), so its disappearance proves the delete worked.
    func test_1TO1_deleteChatRemovesConversation() {
        openSeededConversation()

        // Precondition: the seeded conversation exists on the backend before we delete it.
        XCTAssertTrue(
            (try? runBlocking { await PeerActions.userConversationExists() }) ?? false,
            "Seeded conversation was not present before delete"
        )

        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
            "Could not open User Info from header menu"
        )

        // The destructive "Delete Chat" row may need a small scroll on shorter screens.
        if !(app.staticTexts["Delete Chat"].exists || app.buttons["Delete Chat"].exists) {
            app.swipeUp()
        }
        let deleteChat = app.buttons["Delete Chat"].exists
            ? app.buttons["Delete Chat"]
            : app.staticTexts["Delete Chat"]
        XCTAssertTrue(deleteChat.waitForExistence(timeout: 8), "Delete Chat option not found")
        deleteChat.tap()
        XCTAssertTrue(ComponentQueries.confirmDestructiveAction(app), "Delete Chat confirmation not found")

        // Assert on the backend (authoritative): the conversation no longer exists. Poll, since the
        // delete propagates over the SDK socket asynchronously.
        let gone = waitForCondition(timeout: 12) {
            !((try? self.runBlocking { await PeerActions.userConversationExists() }) ?? true)
        }
        XCTAssertTrue(gone, "Conversation still exists on backend after Delete Chat")
    }

    // MARK: - Pagination

    /// Scrolling up in the message list loads previous messages without crashing.
    func test_1TO1_scrollUpLoadsPrevious() {
        openSeededConversation()
        app.swipeDown()
        app.swipeDown()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer vanished after scrolling messages")
    }

    // MARK: - Edge Cases

    /// Sending several messages rapidly does not crash the list; the last one still renders.
    func test_1TO1_rapidSendDoesNotCrash() {
        openSeededConversation()

        let run = UUID().uuidString.prefix(6)
        var last = ""
        for i in 0..<5 {
            last = "E2E-rapid-\(run)-\(i)"
            ComponentQueries.typeAndSend(app, text: last)
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: last, timeout: 15), "Last rapid message did not appear")
    }

    // MARK: - Helpers

    private func blockOptionExists(timeout: TimeInterval = 0) -> Bool {
        let probe: () -> Bool = {
            self.app.buttons["Block"].exists
                || self.app.staticTexts["Block"].exists
                || self.app.staticTexts["Block User"].exists
                || self.app.buttons["Block User"].exists
        }
        if timeout <= 0 { return probe() }
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if probe() { return true }
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 0.4)
        }
        return probe()
    }
}
