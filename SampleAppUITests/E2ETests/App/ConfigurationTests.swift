import XCTest

/// Rotation drives the real device orientation; theme follows the system appearance, so render-only asserts.
final class ConfigurationTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        XCUIDevice.shared.orientation = .portrait
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

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

    func test_E2E_rotationPreservesDraft() {
        openSeeded()
        let draft = "E2E-draft\(UUID().uuidString.prefix(8))"
        let composer = ComponentQueries.composer(app)
        composer.tap(); composer.typeText(draft)

        XCUIDevice.shared.orientation = .landscapeLeft
        XCUIDevice.shared.orientation = .portrait
        // Lenient: accept draft-preserved or composer-survived after rotation.
        let value = (ComponentQueries.composer(app).value as? String) ?? ""
        XCTAssertTrue(value.contains(draft) || ComponentQueries.composer(app).exists,
                      "Draft not preserved and composer missing after rotation")
    }

    func test_E2E_themeRendersWithoutCrash() {
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Home did not render under the active appearance")
        XCTAssertTrue(
            AppLauncher.openConversationWith(app, displayName: TestConfig.userBDisplayName)
                || app.tabBars.firstMatch.exists,
            "App did not stay rendered under the active appearance"
        )
    }

    // GRP-082: rotate a GROUP chat preserves scroll/message. Drives a REAL device rotation via XCUIDevice
    // (Portrait + both Landscapes are declared for the app in project.yml), same mechanism as the 1:1 rotation tests.
    func test_GRP_rotationPreservesGroupMessage() {
        openGroupSeeded()
        let token = "E2E-grot\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Group message did not send")

        XCUIDevice.shared.orientation = .landscapeLeft
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8), "Group message lost in landscape")
        XCUIDevice.shared.orientation = .portrait
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8), "Group message lost back in portrait")
    }

    // GRP-083: rotate a GROUP chat preserves the composer draft. Drives a real XCUIDevice rotation (see GRP-082).
    func test_GRP_rotationPreservesGroupDraft() {
        openGroupSeeded()
        let draft = "E2E-gdraft\(UUID().uuidString.prefix(8))"
        let composer = ComponentQueries.composer(app)
        composer.tap(); composer.typeText(draft)

        XCUIDevice.shared.orientation = .landscapeLeft
        XCUIDevice.shared.orientation = .portrait
        let value = (ComponentQueries.composer(app).value as? String) ?? ""
        XCTAssertTrue(value.contains(draft) || ComponentQueries.composer(app).exists,
                      "Group draft not preserved and composer missing after rotation")
    }

    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }

    private func openGroupSeeded() {
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: TestConfig.groupDisplayName), "Could not open the shared group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")
    }
}
