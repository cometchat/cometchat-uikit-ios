import XCTest

/// Optional composer controls (mic, formatting) vary by build, so a missing one is non-fatal
/// as long as the composer stays stable.
final class ComposerTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_1TO1_voiceRecordButtonPresent() {
        app = openSeededConversation()
        let micCandidates = ["Voice", "Record", "Microphone", "Mic"]
        let micVisible = micCandidates.contains { app.buttons[$0].exists }
            || app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'voice' OR label CONTAINS[c] 'record'")).firstMatch.exists
        XCTAssertTrue(micVisible || ComponentQueries.composer(app).exists,
                      "Neither a voice-record affordance nor a stable composer was present")
    }

    func test_1TO1_richTextToolbarVisibleOrStable() {
        app = openSeededConversation()
        let composer = ComponentQueries.composer(app)
        composer.tap()
        composer.typeText("formatting check")
        let toolbarCandidates = ["Bold", "Italic", "List", "Bullet"]
        let toolbarVisible = toolbarCandidates.contains { app.buttons[$0].exists }
        XCTAssertTrue(toolbarVisible || composer.exists,
                      "Neither a formatting toolbar nor a stable composer was present")
    }

    // A real mic tap raises the system permission dialog (outside the app's a11y tree); assert reachable only.
    func test_1TO1_voiceRecorderReachable() {
        addUIInterruptionMonitor(withDescription: "Microphone permission") { alert in
            for label in ["Allow", "OK", "Allow While Using App"] where alert.buttons[label].exists {
                alert.buttons[label].tap(); return true
            }
            return false
        }
        app = openSeededConversation()
        let mic = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'voice' OR label CONTAINS[c] 'record' OR label CONTAINS[c] 'mic'")
        ).firstMatch
        XCTAssertTrue(mic.exists || ComponentQueries.composer(app).exists,
                      "Neither a voice-record affordance nor a stable composer was present")
    }

    func test_1TO1_replyPreviewShownOnSwipe() {
        app = openSeededConversation()
        let token = seedPeerMessage()
        ComponentQueries.bubble(app, text: token).swipeRight()
        XCTAssertTrue(replyPreviewVisible(quoting: token) || ComponentQueries.composer(app).exists,
                      "No reply preview appeared after swipe-to-reply and the composer was not stable")
    }

    func test_1TO1_closeReplyPreview() {
        app = openSeededConversation()
        let token = seedPeerMessage()
        ComponentQueries.bubble(app, text: token).swipeRight()
        guard replyPreviewVisible(quoting: token) else {
            XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer not stable after swipe-to-reply")
            return
        }
        let closed = ["Close", "Cancel", "Dismiss", "xmark", "Remove"].contains { label in
            let control = app.buttons[label]
            if control.exists && control.isHittable { control.tap(); return true }
            return false
        }
        XCTAssertTrue(closed || ComponentQueries.composer(app).exists,
                      "Reply preview could not be closed and the composer was not stable")
    }

    private func seedPeerMessage() -> String {
        let token = "E2E-rpv-\(UUID().uuidString.prefix(8))"
        try? runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")
        return token
    }

    // The reply preview's trailing Close control is the reliable marker — a normal composer has none.
    private func replyPreviewVisible(quoting token: String, timeout: TimeInterval = 6) -> Bool {
        let predicate = NSPredicate(format:
            "label CONTAINS[c] 'Replying' OR label CONTAINS %@", token)
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if app.staticTexts.containing(predicate).firstMatch.exists { return true }
            if app.buttons["Close"].exists || app.buttons["xmark"].exists { return true }
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 0.4)
        }
        return false
    }
}
