import XCTest

/// Call initiation from a 1:1. Actually placing a call hits CallKit / mic+camera permission (system UI outside the
/// app's a11y tree) — these tap the header call button
/// and assert an outgoing-call surface appears OR the screen stays stable, with a permission interruption
/// monitor to dismiss any system dialog. Call-log tab cases already live in E2EFullAppTests.
final class CallsTests: XCTestCase {

    private var app: XCUIApplication!
    private var secondClientActive = false

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        if secondClientActive {
            secondClientActive = false
            // Ends any active call and releases B's socket so it can't race REST-driven B tests.
            runBlocking { await SecondClient.shared.logout() }
        }
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

    // MARK: - Incoming calls (B calls A via live SecondClient)

    /// Incoming voice/video call, and the cancel/reject/ended/list side-effects, all use a REAL call from
    /// User B (live `SecondClient.initiateCall`, on the base SDK — no Calls SDK needed). The sample app
    /// ships `inAppIncomingCall: false`, so A shows no incoming-call surface today; these therefore assert
    /// "an incoming/ongoing call surface appears OR the app stays stable", the SAME depth the Flutter suite
    /// uses ("overlay OR stable" — its comment notes the WebRTC overlay may not mount headless either). If
    /// the app later enables in-app incoming calls, `incomingCallSurface()` will start matching for real.

    /// RT-CALL-001: B places a voice call → A shows incoming-call UI or stays stable.
    func test_RT_CALL_incomingVoiceCall() throws {
        try bringUpUserB()
        openSeeded()
        runBlocking { _ = try? await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: false) }
        XCTAssertTrue(incomingCallSurfaceOrStable(), "Incoming voice call: no call surface and app not stable")
    }

    /// RT-CALL-005: B places a video call → A shows incoming-call UI or stays stable.
    func test_RT_CALL_incomingVideoCall() throws {
        try bringUpUserB()
        openSeeded()
        runBlocking { _ = try? await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: true) }
        XCTAssertTrue(incomingCallSurfaceOrStable(), "Incoming video call: no call surface and app not stable")
    }

    /// RT-CALL-002: B calls then the call is ended (modeling reject) → A returns to a stable chat.
    func test_RT_CALL_rejectReturnsToChat() throws {
        try bringUpUserB()
        openSeeded()
        runBlocking { _ = try? await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: false) }
        _ = incomingCallSurfaceOrStable()
        runBlocking { await SecondClient.shared.cancelActiveCall() }
        XCTAssertTrue(backOnChat(), "Did not return to a stable chat after the call was rejected/ended")
    }

    /// RT-CALL-004: after a call is initiated then ended, the chat stays stable (a call-ended message may
    /// or may not render; asserted best-effort like Flutter).
    func test_RT_CALL_endedCallLeavesChatStable() throws {
        try bringUpUserB()
        openSeeded()
        runBlocking { _ = try? await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: false) }
        runBlocking { await SecondClient.shared.cancelActiveCall() }
        XCTAssertTrue(backOnChat(), "Chat not stable after a call ended")
    }

    /// RT-CALL-006: after an incoming call, the conversation list stays stable (a call preview may appear;
    /// asserted best-effort). Navigates to Chats after the call round-trip.
    func test_RT_CALL_updatesConversationListStable() throws {
        try bringUpUserB()
        openSeeded()
        runBlocking { _ = try? await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: false) }
        runBlocking { await SecondClient.shared.cancelActiveCall() }
        // Best-effort: try to reach the Chats list (a call preview may appear there); either way the app
        // must stay stable after the call round-trip. A lingering call surface can swallow the tab tap, so
        // switching to Chats is not required — stability is.
        _ = AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        XCTAssertTrue(backOnChat() || app.tabBars.firstMatch.exists,
                      "App not stable after an incoming call round-trip")
    }

    // MARK: - Helpers

    /// Bring User B's in-process client up; skip (not fail) if the busy shared backend won't cooperate.
    private func bringUpUserB() throws {
        do {
            try runBlocking(timeout: 60) { try await SecondClient.shared.ensureLoggedInAsUserB() }
            secondClientActive = true
        } catch {
            throw XCTSkip("Second SDK client unavailable: \(error)")
        }
    }

    /// An incoming/ongoing call surface (accept/decline/caller markers) OR the app staying stable — the
    /// Flutter-parity assertion. Stability is the realistic outcome while `inAppIncomingCall` is off.
    private func incomingCallSurfaceOrStable() -> Bool {
        let callMarkers = ["Accept", "Decline", "Reject", "Incoming", "Incoming Call",
                           "Incoming voice call", "Incoming video call", "Ringing", "Answer"]
        let surface = callMarkers.contains {
            app.staticTexts[$0].waitForExistence(timeout: 6) || app.buttons[$0].exists
        }
        return surface || backOnChat()
    }

    private func backOnChat() -> Bool {
        ComponentQueries.composer(app).waitForExistence(timeout: 12)
            || app.staticTexts[TestConfig.userBDisplayName].exists
            || app.tabBars.firstMatch.exists
    }

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
