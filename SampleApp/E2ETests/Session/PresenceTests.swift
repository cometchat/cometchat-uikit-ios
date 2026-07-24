import XCTest

/// The peer's online state in the 1:1 header subtitle. `SecondClient` (live User B) holds a real socket, so B
/// is genuinely online to the backend — `PeerActions.goOnline()` only mints an auth token and can't drive this.
///
/// Constraints:
///   - B must never be typing during an assertion — typing writes the same `subtitleLabel`.
///   - Offline text is time-dependent ("Offline" vs "Last seen ..."), so absence-of-"Online" is the signal.
final class PresenceTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SecondClient.shared.logout() }
        runBlocking { await PeerActions.unblockUser() }
        runBlocking { await SeedData.cleanup() }
    }

    /// Online peer shows "Online" in the header.
    func test_RT_PRES_peerOnlineShowsInHeader() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        try ensureUserBLoggedIn()

        app = openConversationWithB()
        XCTAssertTrue(ComponentQueries.waitForOnlineIndicator(app),
                      "Header did not show 'Online' while User B held a live socket")
    }

    /// Peer going offline clears "Online" from the header.
    func test_RT_PRES_peerOfflineClearsInHeader() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        try ensureUserBLoggedIn()

        app = openConversationWithB()
        XCTAssertTrue(ComponentQueries.waitForOnlineIndicator(app),
                      "Header did not show 'Online' before taking User B offline")

        runBlocking { await SecondClient.shared.disconnect() }
        XCTAssertTrue(ComponentQueries.waitForOnlineIndicatorToClear(app),
                      "Header still showed 'Online' after User B dropped its socket")
    }

    /// Header returns to "Online" after the peer's socket drops and reconnects.
    func test_RT_PRES_reconnectRestoresOnline() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        try ensureUserBLoggedIn()

        app = openConversationWithB()
        XCTAssertTrue(ComponentQueries.waitForOnlineIndicator(app), "Header did not show 'Online' initially")

        runBlocking { await SecondClient.shared.disconnect() }
        XCTAssertTrue(ComponentQueries.waitForOnlineIndicatorToClear(app),
                      "Header did not drop 'Online' when User B went offline")

        runBlocking { await SecondClient.shared.reconnect() }
        XCTAssertTrue(ComponentQueries.waitForOnlineIndicator(app),
                      "Header did not restore 'Online' after User B reconnected")
    }

    /// Blocking an online peer hides their presence. Block via the UI, not REST: hiding is driven by the
    /// `ccUserBlocked` event, which only the UIKit's own block flow fires.
    func test_RT_PRES_blockedPeerHidesOnline() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        try ensureUserBLoggedIn()

        app = openConversationWithB()
        XCTAssertTrue(ComponentQueries.waitForOnlineIndicator(app), "Header did not show 'Online' before blocking")

        XCTAssertTrue(ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
                      "Could not open User Info from header menu")
        let block = app.buttons["Block"].exists ? app.buttons["Block"] : app.staticTexts["Block"]
        XCTAssertTrue(block.waitForExistence(timeout: 8), "Block option not found on user-info screen")
        block.tap()
        XCTAssertTrue(ComponentQueries.confirmDestructiveAction(app), "Block confirmation control not found")
        XCTAssertTrue(app.buttons["Unblock"].waitForExistence(timeout: 10) || app.staticTexts["Unblock"].exists,
                      "Block did not take effect (option never flipped to Unblock)")

        XCTAssertTrue(ComponentQueries.waitForOnlineIndicatorToClear(app),
                      "Header still showed 'Online' for a blocked user")
    }

    private func openConversationWithB() -> XCUIApplication {
        let app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open the 1:1 with User B")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
        return app
    }
}
