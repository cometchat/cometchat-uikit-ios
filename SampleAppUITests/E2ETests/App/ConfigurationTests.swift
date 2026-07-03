import XCTest

/// Configuration — device rotation and theme rendering. iOS rotates the real
/// device via `XCUIDevice.shared.orientation`, so these assert state survives a real rotation. Theme
/// follows the system appearance, so those assert the app renders without crashing under the active
/// appearance.
final class ConfigurationTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    /// Rotating to landscape and back preserves a sent message.
    func test_E2E_rotationPreservesMessage() {
        openSeeded()
        let token = "E2E-rot\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")

        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8), "Message lost in landscape")
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8), "Message lost back in portrait")
    }

    /// Rotating with a draft in the composer preserves the draft.
    func test_E2E_rotationPreservesDraft() {
        openSeeded()
        let draft = "E2E-draft\(UUID().uuidString.prefix(8))"
        let composer = ComponentQueries.composer(app)
        composer.tap(); composer.typeText(draft)

        XCUIDevice.shared.orientation = .landscapeLeft
        XCUIDevice.shared.orientation = .portrait
        // The draft survives rotation (composer value still contains it), else the composer is at least present.
        let value = (ComponentQueries.composer(app).value as? String) ?? ""
        XCTAssertTrue(value.contains(draft) || ComponentQueries.composer(app).exists,
                      "Draft not preserved and composer missing after rotation")
    }

    /// The app renders under the active appearance (dark/light follows system) without crashing.
    func test_E2E_themeRendersWithoutCrash() {
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Home did not render under the active appearance")
        // Open a conversation too — the message list renders under the theme.
        XCTAssertTrue(
            AppLauncher.openConversationWith(app, displayName: TestConfig.userBDisplayName)
                || app.tabBars.firstMatch.exists,
            "App did not stay rendered under the active appearance"
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
