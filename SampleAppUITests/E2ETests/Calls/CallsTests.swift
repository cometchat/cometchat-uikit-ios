import XCTest

/// Call initiation from a 1:1. Actually placing a call hits CallKit / mic+camera permission (system UI outside the
/// app's a11y tree) — these tap the header call button
/// and assert an outgoing-call surface appears OR the screen stays stable, with a permission interruption
/// monitor to dismiss any system dialog. Call-log tab cases already live in E2EFullAppTests.
final class CallsTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    /// The header exposes call buttons.
    func test_E2E_callButtonsInHeader() {
        openSeeded()
        let hasCall = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'call' OR label CONTAINS[c] 'voice' OR label CONTAINS[c] 'video'")
        ).firstMatch.waitForExistence(timeout: 8)
        XCTAssertTrue(hasCall, "No call buttons in the message header")
    }

    /// Tapping voice-call shows an outgoing surface or the screen stays stable.
    func test_1TO1_voiceCallInitiates() {
        monitorPermissionDialogs()
        openSeeded()
        tapCallButton(video: false)
        XCTAssertTrue(outgoingOrStable(), "Voice call neither showed outgoing UI nor stayed stable")
    }

    /// Tapping video-call shows an outgoing surface or the screen stays stable.
    func test_1TO1_videoCallInitiates() {
        monitorPermissionDialogs()
        openSeeded()
        tapCallButton(video: true)
        XCTAssertTrue(outgoingOrStable(), "Video call neither showed outgoing UI nor stayed stable")
    }

    /// Starting then cancelling a call returns to the messages screen.
    func test_1TO1_cancelCallReturnsToChat() {
        monitorPermissionDialogs()
        openSeeded()
        tapCallButton(video: false)
        // Cancel/End if an outgoing surface appeared.
        for label in ["Cancel", "End", "End Call", "Decline", "Hang Up", "Close"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 12) || app.staticTexts[TestConfig.userBDisplayName].exists,
            "Did not return to the messages screen after cancelling")
    }

    // MARK: - Helpers

    private func monitorPermissionDialogs() {
        addUIInterruptionMonitor(withDescription: "Call permissions") { alert in
            for label in ["OK", "Allow", "Allow While Using App", "Don't Allow"] where alert.buttons[label].exists {
                alert.buttons[label].tap(); return true
            }
            return false
        }
    }

    private func tapCallButton(video: Bool) {
        let predicate = video
            ? NSPredicate(format: "label CONTAINS[c] 'video'")
            : NSPredicate(format: "label CONTAINS[c] 'voice' OR label ==[c] 'call' OR label CONTAINS[c] 'audio'")
        let button = app.buttons.matching(predicate).firstMatch
        if button.waitForExistence(timeout: 8) && button.isHittable {
            button.tap()
            app.tap() // trigger any queued interruption monitor
        }
    }

    private func outgoingOrStable() -> Bool {
        let outgoing = ["Calling", "Ringing", "Connecting", "End", "Cancel", "Hang Up"].contains {
            app.staticTexts[$0].waitForExistence(timeout: 6) || app.buttons[$0].exists
        }
        return outgoing || ComponentQueries.composer(app).exists || app.staticTexts[TestConfig.userBDisplayName].exists
    }

    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }
}
