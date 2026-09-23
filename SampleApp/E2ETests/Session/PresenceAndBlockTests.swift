import XCTest

/// Presence and blocking seen from the OTHER side of the relationship — the cases the Flutter
/// kit's integration suite drives with two devices. Here the second device is `SecondClient`
/// (User B's live SDK session in the runner process) and B's sends go over REST.
///
/// Not covered, deliberately: the Users-tab row's online dot. `CometChatStatusIndicator` is a
/// plain coloured `UIView` with no accessibility label, so whether it is shown or hidden is
/// invisible to XCUITest (see the report for this wave). `PresenceTests` already covers the
/// header going Online → not-Online; this file adds the reverse transition.
final class PresenceAndBlockTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SecondClient.shared.logout() }
        runBlocking { await PeerActions.unblockUser() }
        runBlocking { await PeerActions.unblockUserA() }
        runBlocking { await SeedData.cleanup() }
    }

    private func openConversationWithB() -> XCUIApplication {
        let app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open the 1:1 with User B")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
        return app
    }

    // MARK: - Presence

    /// The header follows the peer coming ONLINE: B is logged in but disconnected when the chat
    /// opens, so the subtitle must not say Online; once B's socket comes up it must.
    func test_RT_PRES_headerFlipsToOnlineWhenPeerConnects() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        try ensureUserBLoggedIn()
        runBlocking { await SecondClient.shared.disconnect() }

        app = openConversationWithB()
        XCTAssertTrue(ComponentQueries.waitForOnlineIndicatorToClear(app, timeout: 15),
                      "Header showed 'Online' while User B had no socket")

        runBlocking { await SecondClient.shared.reconnect() }
        XCTAssertTrue(ComponentQueries.waitForOnlineIndicator(app, timeout: 20),
                      "Header did not flip to 'Online' when User B connected")
    }

    // MARK: - Block / unblock, seen from B

    /// A blocks B from User Info. B's next message must not reach A's chat: either the backend
    /// refuses B's send outright, or it is accepted and A's list never shows it. Both are the
    /// blocked contract; a message that lands in A's open chat is the failure.
    func test_1TO1_BLOCK_peerMessageDoesNotReachBlockedUser() throws {
        app = openSeededConversation()
        XCTAssertTrue(ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
                      "Could not open User Info from the header menu")
        let block = app.buttons["Block"].exists ? app.buttons["Block"] : app.staticTexts["Block"]
        XCTAssertTrue(block.waitForExistence(timeout: 8), "Block option not found on User Info")
        block.tap()
        XCTAssertTrue(ComponentQueries.confirmDestructiveAction(app), "Block confirmation control not found")
        XCTAssertTrue(app.buttons["Unblock"].waitForExistence(timeout: 10) || app.staticTexts["Unblock"].exists,
                      "Block did not take effect (option never flipped to Unblock)")
        XCTAssertTrue(waitForBackend(timeout: 10) { await PeerActions.isBlocked() },
                      "Backend does not report B as blocked")

        // Back to the conversation so a leaked message would have somewhere to render.
        if let back = ComponentQueries.headerBackButton(app) { back.tap() } else { app.navigationBars.buttons.firstMatch.tap() }
        _ = ComponentQueries.composer(app).waitForExistence(timeout: 8)
            || app.buttons["Unblock"].waitForExistence(timeout: 2)

        // Measured on this app: the backend does not answer a blocked peer's send at all (the
        // request sat for the full 60s URLSession timeout on the first run), so the send is
        // bounded here and any failure — HTTP error or timeout — counts as the refusal.
        let token = "blk\(UUID().uuidString.prefix(6).lowercased())"
        PeerActions.requestTimeout = 8
        defer { PeerActions.requestTimeout = 60 }
        let refused: Bool
        do {
            _ = try runBlocking(timeout: 55) { try await PeerActions.sendTextMessage("E2E \(token)") }
            refused = false
        } catch {
            refused = true
            print("E2E blocked-peer send was refused: \(error)")
        }
        if !refused {
            print("E2E blocked-peer send was accepted by the backend; asserting it never renders for A")
            XCTAssertFalse(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 8),
                           "A message from a blocked peer rendered in the blocker's chat")
        }
    }

    /// The inverse: B was blocked, A unblocks from User Info, and B can message A again — the
    /// next send is accepted and shows up in A's chat.
    func test_1TO1_BLOCK_peerCanMessageAgainAfterUnblock() throws {
        app = openSeededConversationKeepingBlock()
        XCTAssertTrue(ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
                      "Could not open User Info from the header menu")
        let unblock = app.buttons["Unblock"].exists ? app.buttons["Unblock"] : app.staticTexts["Unblock"]
        XCTAssertTrue(unblock.waitForExistence(timeout: 8), "Unblock option not offered for a blocked user")
        unblock.tap()
        // The sample app confirms with an alert whose action is also titled "Unblock" (not in
        // `confirmDestructiveAction`'s verb list), so it is tapped explicitly.
        let confirm = app.alerts.buttons["Unblock"].firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 6), "Unblock confirmation alert not shown")
        confirm.tap()
        XCTAssertTrue(app.buttons["Block"].waitForExistence(timeout: 10) || app.staticTexts["Block"].exists,
                      "Unblock did not take effect (option never flipped back to Block)")
        XCTAssertTrue(waitForBackend(timeout: 10) { await PeerActions.isBlocked() == false },
                      "Backend still reports B as blocked after Unblock")

        if let back = ComponentQueries.headerBackButton(app) { back.tap() } else { app.navigationBars.buttons.firstMatch.tap() }
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10),
                      "Composer did not come back after unblocking")

        let token = "unb\(UUID().uuidString.prefix(6).lowercased())"
        try runBlocking { _ = try await PeerActions.sendTextMessage("E2E \(token)") }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20),
                      "B's message after the unblock did not reach A's chat")
    }

    /// `openSeededConversation` unblocks B as part of seeding; this variant seeds the
    /// conversation first, then re-applies the block so the chat opens in the blocked state.
    private func openSeededConversationKeepingBlock() -> XCUIApplication {
        try? runBlocking { try await SeedData.createTestConversation() }
        runBlocking { await PeerActions.blockUser() }
        let app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open the 1:1 with User B")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15)
                        || app.buttons["Unblock"].waitForExistence(timeout: 5),
                      "Blocked conversation did not open")
        return app
    }
}
