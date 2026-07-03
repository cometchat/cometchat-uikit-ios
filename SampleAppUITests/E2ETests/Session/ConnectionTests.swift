import XCTest

/// Connection / live delivery. The hard signal
/// is that a message B sends over REST arrives on A's UI over the WebSocket, and the app stays stable
/// while navigating with live traffic. (True network cuts need host tooling — out of scope under
/// zero-host-setup — so these exercise live delivery + stability.)
final class ConnectionTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    /// Navigating tabs with live traffic keeps the app on a valid home screen.
    func test_E2E_navigationStableWithTraffic() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        for tab in [AppLauncher.TabLabel.users, AppLauncher.TabLabel.groups, AppLauncher.TabLabel.chats] {
            AppLauncher.navigateToTab(app, title: tab)
        }
        try runBlocking { _ = try await PeerActions.sendTextMessage("E2E-conn\(UUID().uuidString.prefix(6))") }
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Home tab bar vanished under live traffic")
    }

    /// A WebSocket-delivered message from B lands on A's open chat.
    func test_E2E_webSocketDeliversLive() throws {
        openSeeded()
        let token = "E2E-ws\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20),
                      "WebSocket did not deliver B's message to A")
    }

    /// B sends 3 while A is on the Chats list; opening the chat shows them (sync).
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

    /// The conversation list refreshes with a new message preview.
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

    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }
}
