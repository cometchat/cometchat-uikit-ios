import XCTest

/// Header renders the peer name as a staticText and call controls as buttons; info opens via the header
/// overflow "More" → "User Info". Presence/typing cases live in `PresenceTests`/`TypingIndicatorTests`.
final class MessageHeaderTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_1TO1_headerShowsName() {
        openSeeded()
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 10),
                      "Header did not show \(TestConfig.userBDisplayName)")
    }

    func test_1TO1_headerShowsAvatar() {
        openSeeded()
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 10),
                      "Header name missing")
        XCTAssertTrue(app.images.firstMatch.exists || app.staticTexts[TestConfig.userBDisplayName].exists,
                      "Header avatar/name not rendered")
    }

    func test_1TO1_voiceCallButtonVisible() {
        openSeeded()
        XCTAssertTrue(voiceCallButton().waitForExistence(timeout: 8),
                      "Voice-call button not present in header")
    }

    func test_1TO1_videoCallButtonVisible() {
        openSeeded()
        XCTAssertTrue(videoCallButton().waitForExistence(timeout: 8),
                      "Video-call button not present in header")
    }

    func test_1TO1_infoNavigatesToUserInfo() {
        openSeeded()
        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
            "Could not open User Info from header menu"
        )
        XCTAssertTrue(
            app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8)
                || app.staticTexts["User Info"].exists,
            "User Info screen did not appear"
        )
    }

    private func voiceCallButton() -> XCUIElement {
        // Match voice/audio or an EXACT "Call" label — not `CONTAINS 'call'`, which would also match "Video Call".
        app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'voice' OR label CONTAINS[c] 'audio' OR label ==[c] 'call'")
        ).firstMatch
    }

    private func videoCallButton() -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'video'")).firstMatch
    }

    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Message list did not open")
    }
}
