import XCTest

/// XCUIApplication.launch() requires the main thread, so REST seeding goes through runBlocking.
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

        let token = "E2E-slice-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)

        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: token, timeout: 12),
            "Sent message '\(token)' did not appear in the message list"
        )
    }
}
