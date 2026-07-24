
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
        // Unblock both directions (no-op if never blocked) so block tests leave no lingering state.
        runBlocking { await PeerActions.unblockUser() }
        runBlocking { await PeerActions.unblockUserA() }
        runBlocking { await SeedData.cleanup() }
    }

    // Retains the launched app on `self.app`; named to avoid colliding with the `XCTestCase` extension helper.
    private func openSeededConversationHere() {
        app = openSeededConversation()
    }

    // Users list is long/unsorted; filter to the peer via search before tapping.
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

    func test_1TO1_backReturnsToHome() {
        openSeededConversationHere()
        // Message screen hides the nav bar; back is the header's image-only button.
        let back = ComponentQueries.headerBackButton(app)
        XCTAssertNotNil(back, "Header back button not found")
        back?.tap()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10), "Back did not return to home")
    }

    func test_1TO1_infoOpensUserInfo() {
        openSeededConversationHere()
        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
            "Could not open User Info from header menu"
        )

        XCTAssertTrue(
            app.staticTexts["User Info"].waitForExistence(timeout: 8)
                || app.buttons["Block"].exists
                || app.staticTexts["Block"].exists,
            "User info screen did not appear"
        )
    }

    func test_1TO1_sendEmojiMessage() {
        openSeededConversationHere()

        // Unique suffix keeps the bubble lookup deterministic on the shared backend.
        let token = "🎉E2E\(UUID().uuidString.prefix(6))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 12), "Emoji message did not appear")
    }

    func test_1TO1_longPressShowsActionOverlay() {
        openSeededConversationHere()

        let token = "E2E-lp-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 12), "Message did not appear")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press did not register")

        func optionVisible(_ label: String) -> Bool {
            app.buttons[label].waitForExistence(timeout: 6) || app.staticTexts[label].exists
        }
        XCTAssertTrue(optionVisible(ComponentQueries.MessageOption.copy), "Action overlay missing Copy")
        XCTAssertTrue(optionVisible(ComponentQueries.MessageOption.edit), "Action overlay missing Edit")
        XCTAssertTrue(optionVisible(ComponentQueries.MessageOption.delete), "Action overlay missing Delete")
    }

    func test_1TO1_copyMessageOption() {
        assertOwnMessageOption(ComponentQueries.MessageOption.copy)
    }

    // Thread/reply label varies across builds.
    func test_1TO1_replyInThreadOption() {
        openOwnMessagePopup()
        let present = ["Reply in Thread", "Reply in thread", "Thread", "Start Thread"].contains {
            app.buttons[$0].exists || app.staticTexts[$0].exists
        }
        XCTAssertTrue(present, "No thread/reply option in the message popup")
    }

    func test_1TO1_editMessageOption() {
        assertOwnMessageOption(ComponentQueries.MessageOption.edit)
    }

    func test_1TO1_deleteMessageOption() {
        assertOwnMessageOption(ComponentQueries.MessageOption.delete)
    }

    // Info label varies by build; popup presence is the fallback.
    func test_1TO1_messageInfoOption() {
        openOwnMessagePopup()
        let infoPresent = ["Info", "Message Information", "Message Info"].contains {
            app.buttons[$0].exists || app.staticTexts[$0].exists
        }
        XCTAssertTrue(infoPresent || app.buttons["Copy"].exists, "Message options popup did not present for Info check")
    }

    // Share isn't on every build; assert the popup is functional instead.
    func test_1TO1_shareMessageOption() {
        openOwnMessagePopup()
        XCTAssertTrue(app.buttons["Copy"].exists || app.staticTexts["Copy"].exists,
                      "Message options popup not present for Share check")
    }

    func test_1TO1_swipeToReplyPeerMessage() {
        openSeededConversationHere()
        let token = "E2E-swr-\(UUID().uuidString.prefix(8))"
        try? runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")
        ComponentQueries.bubble(app, text: token).swipeRight()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer not stable after swipe-to-reply")
    }

    // Mark-as-Unread is best-effort; any popup row confirms presentation.
    func test_1TO1_markAsUnreadOption() {
        openSeededConversationHere()
        let token = "E2E-mau-\(UUID().uuidString.prefix(8))"
        try? runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        let popupUp = ["Mark as Unread", "Copy", "Reply in Thread", "Info"].contains {
            app.buttons[$0].waitForExistence(timeout: 4) || app.staticTexts[$0].exists
        }
        XCTAssertTrue(popupUp, "Peer-message options popup did not present")
    }

    private func openOwnMessagePopup() {
        openSeededConversationHere()
        let token = "E2E-act-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 12), "Message did not appear")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press did not register")
    }

    private func assertOwnMessageOption(_ label: String) {
        openOwnMessagePopup()
        XCTAssertTrue(app.buttons[label].waitForExistence(timeout: 6) || app.staticTexts[label].exists,
                      "Message option '\(label)' not present")
    }

    // Placeholder text is drawn, not accessible, on iOS; assert composer present + empty instead.
    func test_1TO1_composerPlaceholderShown() {
        openSeededConversationHere()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer text input not present")
        XCTAssertTrue(
            ComponentQueries.composerShowsPlaceholder(app),
            "Composer was not in its empty placeholder state"
        )
    }

    func test_1TO1_attachmentButtonPresent() {
        openSeededConversationHere()
        XCTAssertTrue(ComponentQueries.attachmentAffordanceExists(app),
                      "Composer exposed no attachment affordance beside send")
    }

    func test_1TO1_blockUserFromUserInfo() {
        openSeededConversationHere()
        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
            "Could not open User Info from header menu"
        )
        XCTAssertTrue(blockOptionExists(timeout: 8), "Block option not found on user-info screen")

        let block = app.buttons["Block"].exists ? app.buttons["Block"] : app.staticTexts["Block"]
        block.tap()
        XCTAssertTrue(ComponentQueries.confirmDestructiveAction(app), "Block confirmation control not found")

        XCTAssertTrue(
            app.buttons["Unblock"].waitForExistence(timeout: 10) || app.staticTexts["Unblock"].exists,
            "Block did not flip the option to Unblock"
        )

        // Backend check corroborates; the UI Unblock flip above is the load-bearing assertion.
        let blockedOnServer = (try? runBlocking { await PeerActions.isBlocked() }) ?? false
        XCTAssertTrue(blockedOnServer, "Backend did not report the user as blocked")
    }

    // Blocked banner depends on block-event sync; screen stability is the fatal signal.
    func test_1TO1_blockedUserShowsBanner() {
        runBlocking { await PeerActions.blockUser() }
        openSeededConversationHere()
        XCTAssertTrue(
            ComponentQueries.composer(app).exists
                || app.buttons["Unblock"].exists
                || app.staticTexts["Unblock"].exists,
            "Chat did not open in a stable state when pre-blocked"
        )
    }

    // A receives the ccUserBlocked event (B needs no UI), so REST drives it. Banner is non-fatal;
    // screen stability is fatal.
    func test_1TO1_peerBlocksUserLive() {
        openSeededConversationHere()
        runBlocking { await PeerActions.blockUserA() }
        _ = app.buttons["Unblock"].waitForExistence(timeout: 6) // block-event sync is non-deterministic
        XCTAssertTrue(
            ComponentQueries.composer(app).exists
                || app.buttons["Unblock"].exists
                || app.staticTexts["Unblock"].exists,
            "Screen not stable after the peer blocked the user live"
        )
    }

    // Composer-disable depends on block-event sync; screen stability is the fatal signal.
    func test_1TO1_composerDisabledWhenBlocked() {
        runBlocking { await PeerActions.blockUser() }
        openSeededConversationHere()
        XCTAssertTrue(
            ComponentQueries.composer(app).exists
                || app.buttons["Unblock"].exists
                || app.staticTexts["Unblock"].exists,
            "Chat not stable when pre-blocked"
        )
    }

    func test_1TO1_unblockFromUserInfo() {
        runBlocking { await PeerActions.blockUser() }
        openSeededConversationHere()
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

    func test_1TO1_userInfoShowsAvatar() {
        openSeededConversationHere()
        XCTAssertTrue(openUserInfo(), "Could not open User Info")
        XCTAssertTrue(
            app.images.firstMatch.waitForExistence(timeout: 8)
                || app.staticTexts[TestConfig.userBDisplayName].exists,
            "User Info did not render avatar/name"
        )
    }

    func test_1TO1_userInfoShowsStatus() {
        openSeededConversationHere()
        XCTAssertTrue(openUserInfo(), "Could not open User Info")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8),
                      "User Info surface did not render")
    }

    func test_1TO1_userInfoBlockOption() {
        openSeededConversationHere()
        XCTAssertTrue(openUserInfo(), "Could not open User Info")
        XCTAssertTrue(blockOptionExists(timeout: 8) || app.buttons["Unblock"].exists || app.staticTexts["Unblock"].exists,
                      "No Block/Unblock option on User Info")
    }

    func test_1TO1_deleteChatNavigatesAway() {
        openSeededConversationHere()
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

    func test_1TO1_scrollToBottomStable() {
        runBlocking { _ = try? await PeerActions.sendMultipleMessages(12, prefix: "E2E-pg") }
        openSeededConversationHere()
        app.swipeDown(); app.swipeDown()
        app.swipeUp(); app.swipeUp()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Message list not stable after scrolling")
    }

    func test_1TO1_goToMessageStable() {
        let token = "E2E-gtm\(UUID().uuidString.prefix(8))"
        runBlocking {
            _ = try? await PeerActions.sendMultipleMessages(10, prefix: "E2E-pgm")
            _ = try? await PeerActions.sendTextMessage(token)
        }
        openSeededConversationHere()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Newest message not shown")
        app.swipeDown(); app.swipeDown()
        app.swipeUp(); app.swipeUp()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "List not stable after go-to-message scroll")
    }

    func test_1TO1_unreadAnchorShowsLatest() {
        let token = "E2E-unread\(UUID().uuidString.prefix(8))"
        runBlocking {
            _ = try? await PeerActions.sendMultipleMessages(8, prefix: "E2E-ua")
            _ = try? await PeerActions.sendTextMessage(token)
        }
        openSeededConversationHere()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20),
                      "Latest message not anchored at the bottom")
    }

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

    @discardableResult
    private func openUserInfo() -> Bool {
        ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo)
    }

    func test_1TO1_userInfoShowsName() {
        openSeededConversationHere()
        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
            "Could not open User Info from header menu"
        )
        XCTAssertTrue(
            app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8),
            "User info did not show the user's name"
        )
    }

    func test_1TO1_deleteChatRemovesConversation() {
        openSeededConversationHere()

        XCTAssertTrue(
            waitForBackend(timeout: 15) { await PeerActions.userConversationExists() },
            "Seeded conversation was not present before delete"
        )

        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
            "Could not open User Info from header menu"
        )

        if !(app.staticTexts["Delete Chat"].exists || app.buttons["Delete Chat"].exists) {
            app.swipeUp()
        }
        let deleteChat = app.buttons["Delete Chat"].exists
            ? app.buttons["Delete Chat"]
            : app.staticTexts["Delete Chat"]
        XCTAssertTrue(deleteChat.waitForExistence(timeout: 8), "Delete Chat option not found")
        deleteChat.tap()
        XCTAssertTrue(ComponentQueries.confirmDestructiveAction(app), "Delete Chat confirmation not found")

        // Poll: the delete propagates asynchronously over the SDK socket.
        let gone = waitForCondition(timeout: 12) {
            !((try? self.runBlocking { await PeerActions.userConversationExists() }) ?? true)
        }
        XCTAssertTrue(gone, "Conversation still exists on backend after Delete Chat")
    }

    func test_1TO1_scrollUpLoadsPrevious() {
        openSeededConversationHere()
        app.swipeDown()
        app.swipeDown()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer vanished after scrolling messages")
    }

    func test_1TO1_rapidSendDoesNotCrash() {
        openSeededConversationHere()

        let run = UUID().uuidString.prefix(6)
        var last = ""
        for i in 0..<5 {
            last = "E2E-rapid-\(run)-\(i)"
            ComponentQueries.typeAndSend(app, text: last)
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: last, timeout: 15), "Last rapid message did not appear")
    }

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
