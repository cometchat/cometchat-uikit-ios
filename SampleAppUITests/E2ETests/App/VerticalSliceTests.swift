import XCTest

/// Happy-path slice exercising launch, auto-login, REST seed, content queries, and the WebSocket
/// round-trip: launch → open seeded conversation → type → send → assert the bubble renders.
///
/// Synchronous by necessity: `XCUIApplication.launch()` requires the main thread, so REST work goes
/// through `runBlocking`.
final class VerticalSliceTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_verticalSlice_loginSendAssert() throws {
        try runBlocking { try await SeedData.createTestConversation() }

        app = AppLauncher.launchAndWaitForHome()

        let opened = AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName)
        XCTAssertTrue(opened, "Could not open conversation with \(TestConfig.userBDisplayName)")

        // Unique token guards against matching a stale bubble on the shared backend.
        let token = "E2E-slice-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)

        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: token, timeout: 12),
            "Sent message '\(token)' did not appear in the message list"
        )
    }
}
