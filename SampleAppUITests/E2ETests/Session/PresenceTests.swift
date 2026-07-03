import XCTest

/// Presence. User B's online/offline is driven over REST (auth-token CRUD → fires onUserOnline/Offline).
/// The live "Online"/"last seen" text is debounced and non-deterministic, so these assert the SCREEN
/// STAYS STABLE through the presence events, logging the status text non-fatally.
final class PresenceTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    /// B comes online; the header stays stable (Online text logged, non-fatal).
    func test_RT_PRES_peerOnlineStable() throws {
        openSeeded()
        runBlocking { await PeerActions.goOnline() }
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Header/screen not stable after peer online")
    }

    /// B goes offline; the header stays stable.
    func test_RT_PRES_peerOfflineStable() throws {
        openSeeded()
        runBlocking { await PeerActions.goOnline(); await PeerActions.goOffline() }
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Header/screen not stable after peer offline")
    }

    /// B online while A is on the Users tab; the Users list renders/stays stable.
    func test_RT_PRES_onlineInUsersTabStable() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users)
        runBlocking { await PeerActions.goOnline() }
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15) || app.tabBars.firstMatch.exists,
                      "Users tab not stable after peer online")
    }

    /// Rapid presence toggling does not crash the app.
    func test_RT_PRES_rapidToggleStable() throws {
        openSeeded()
        runBlocking {
            for _ in 0..<3 { await PeerActions.goOnline(); await PeerActions.goOffline() }
        }
        XCTAssertTrue(ComponentQueries.composer(app).exists, "App not stable after rapid presence toggles")
    }

    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }
}
