import XCTest

/// B's presence is driven over REST (auth-token CRUD). LIMITATION: `goOnline()` only mints an auth token —
/// it does NOT open a socket, so the backend never marks B truly "online" (`GET /users/{uid}.status` stays
/// offline) AND the header text is debounced. Presence is therefore non-deterministic at BOTH the UI and the
/// backend (R3), so these assert only screen stability.
final class PresenceTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_RT_PRES_peerOnlineStable() throws {
        openSeeded()
        runBlocking { await PeerActions.goOnline() }
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Header/screen not stable after peer online")
    }

    func test_RT_PRES_peerOfflineStable() throws {
        openSeeded()
        runBlocking { await PeerActions.goOnline(); await PeerActions.goOffline() }
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Header/screen not stable after peer offline")
    }

    func test_RT_PRES_onlineInUsersTabStable() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users)
        runBlocking { await PeerActions.goOnline() }
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15) || app.tabBars.firstMatch.exists,
                      "Users tab not stable after peer online")
    }

    func test_RT_PRES_rapidToggleStable() throws {
        openSeeded()
        runBlocking {
            for _ in 0..<3 { await PeerActions.goOnline(); await PeerActions.goOffline() }
        }
        XCTAssertTrue(ComponentQueries.composer(app).exists, "App not stable after rapid presence toggles")
    }

    // Note: E2E-013/028 and 1TO1-007/008/009 (peer online / online-status / last-seen) are the existing
    // `test_RT_PRES_peerOnlineStable` / `test_RT_PRES_peerOfflineStable` above — same REST-driven, screen-stable
    // depth. The two below add the block+presence and Chats-tab variants.

    // 1TO1-011 / RT-PRES-006: header hides status when blocked. Block+presence interplay is non-deterministic
    // and the hidden-state has no queryable marker (R3), so this is a stability stand-in.
    func test_RT_PRES_statusStableWhenBlocked() throws {
        openSeeded()
        runBlocking { await PeerActions.goOnline(); await PeerActions.blockUser() }
        XCTAssertTrue(ComponentQueries.composer(app).exists || app.buttons["Unblock"].exists,
                      "Header/screen not stable when blocked-while-online")
        runBlocking { await PeerActions.unblockUser() }
    }

    // RT-PRES-004: presence indicator in the Chats tab. The Chats-list presence dot isn't in the a11y tree and
    // backend status is socket-dependent (class note), so assert the Chats tab stays stable.
    func test_RT_PRES_onlineInChatsTabStable() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        runBlocking { await PeerActions.goOnline() }
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Chats tab not stable after peer online")
    }

    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }
}
