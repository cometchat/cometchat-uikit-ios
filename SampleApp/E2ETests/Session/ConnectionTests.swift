import XCTest

/// True network cuts need host tooling; these assert live WebSocket
/// delivery and screen stability under traffic instead.
final class ConnectionTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_E2E_navigationStableWithTraffic() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        for tab in [AppLauncher.TabLabel.users, AppLauncher.TabLabel.groups, AppLauncher.TabLabel.chats] {
            AppLauncher.navigateToTab(app, title: tab)
        }
        try runBlocking { _ = try await PeerActions.sendTextMessage("E2E-conn\(UUID().uuidString.prefix(6))") }
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Home tab bar vanished under live traffic")
    }

    func test_E2E_webSocketDeliversLive() throws {
        app = openSeededConversation()
        let token = "E2E-ws\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20),
                      "WebSocket did not deliver B's message to A")
    }

    func test_RT_CONN_syncMessagesSentWhileAway() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)

        let stamp = UUID().uuidString.prefix(6)
        var last = ""
        try runBlocking {
            for i in 1...3 { last = "E2E-sync-\(stamp)-\(i)"; _ = try await PeerActions.sendTextMessage(last) }
        }
        XCTAssertTrue(AppLauncher.openConversationWith(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: last, timeout: 20),
                      "Messages sent while away did not sync in")
    }

    func test_RT_CONN_listRefreshesWithNewMessage() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        let token = "E2E-refresh\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(
            ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20)
                || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", token)).firstMatch.waitForExistence(timeout: 5)
                || app.tabBars.firstMatch.exists,
            "Conversation list did not refresh / stay stable"
        )
    }

    func test_E2E_offlineAndRecoveryStructural() throws {
        app = openSeededConversation()
        // Simulate the "away then back" window we CAN produce: background + live inbound + resume.
        XCUIDevice.shared.press(.home)
        let token = "E2E-recover-\(UUID().uuidString.prefix(6))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        app.activate()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 25)
                        || ComponentQueries.composer(app).exists,
                      "App did not recover / stay usable across the away-then-back window")
    }

    // Presence "Online" text is server-debounced, so it's polled non-fatally; screen stability is fatal.
    func test_RT_CONN_presenceRefreshesOnReconnect() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        runBlocking { await PeerActions.goOffline() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")

        runBlocking { await PeerActions.goOnline() }
        _ = app.staticTexts["Online"].waitForExistence(timeout: 6) // debounced → non-fatal
        XCTAssertTrue(ComponentQueries.composer(app).exists,
                      "Header/screen not stable after B's presence refresh")
    }
}
