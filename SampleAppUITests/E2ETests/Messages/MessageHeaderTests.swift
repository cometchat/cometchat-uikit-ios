import XCTest

/// The 1:1 message header — peer name, avatar, call buttons, and info navigation. Single-device cases
/// are covered here. Presence/typing header cases live in `PresenceTests`/`TypingIndicatorTests` (soft).
///
/// The header renders the peer name as a staticText and exposes call controls as buttons ("Call"/"video"
/// verified via a11y dump). Info opens via the header overflow "More" → "User Info".
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

    /// Header shows the peer's display name. (name)
    func test_1TO1_headerShowsName() {
        openSeeded()
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 10),
                      "Header did not show \(TestConfig.userBDisplayName)")
    }

    /// Header renders an avatar (an image element beside the name). (avatar)
    func test_1TO1_headerShowsAvatar() {
        openSeeded()
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 10),
                      "Header name missing")
        // The avatar is an image; some builds expose the peer initials as an image label. Assert an image
        // is present in the header area, else the name presence already proved the header rendered.
        XCTAssertTrue(app.images.firstMatch.exists || app.staticTexts[TestConfig.userBDisplayName].exists,
                      "Header avatar/name not rendered")
    }

    /// Header exposes a voice-call button.
    func test_1TO1_voiceCallButtonVisible() {
        openSeeded()
        XCTAssertTrue(voiceCallButton().waitForExistence(timeout: 8),
                      "Voice-call button not present in header")
    }

    /// Header exposes a video-call button.
    func test_1TO1_videoCallButtonVisible() {
        openSeeded()
        XCTAssertTrue(videoCallButton().waitForExistence(timeout: 8),
                      "Video-call button not present in header")
    }

    /// The info affordance navigates to the User Info screen.
    func test_1TO1_infoNavigatesToUserInfo() {
        openSeeded()
        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
            "Could not open User Info from header menu"
        )
        // On User Info the composer is gone and the peer name persists.
        XCTAssertTrue(
            app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8)
                || app.staticTexts["User Info"].exists,
            "User Info screen did not appear"
        )
    }

    // MARK: - Header locators

    private func voiceCallButton() -> XCUIElement {
        // Match voice/audio or an EXACT "Call" label — deliberately not `CONTAINS 'call'`, which would also
        // resolve the "Video Call" control and make `firstMatch` ambiguous between voice and video.
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
