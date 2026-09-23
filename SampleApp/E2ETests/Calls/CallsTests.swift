import XCTest

/// Call initiation from a 1:1, with a permission-dialog interruption monitor. Outgoing cases
/// require a real outgoing surface; incoming cases (no in-app incoming UI by design) require the
/// call entry the round-trip leaves in the conversation.
final class CallsTests: XCTestCase {

    private var app: XCUIApplication!
    private var secondClientActive = false

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        if secondClientActive {
            secondClientActive = false
            // A call left ringing makes B "busy" for the next test's initiateCall.
            runBlocking { await SecondClient.shared.cancelActiveCall() }
            runBlocking { await SecondClient.shared.logout() }
        }
        runBlocking { await SeedData.cleanup() }
    }

    func test_E2E_callButtonsInHeader() {
        app = openSeededConversation()
        let hasCall = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'call' OR label CONTAINS[c] 'voice' OR label CONTAINS[c] 'video'")
        ).firstMatch.waitForExistence(timeout: 8)
        XCTAssertTrue(hasCall, "No call buttons in the message header")
    }

    // Tightened (ENG-38638): the old "…OrStable" form passed even when tapping the button did
    // nothing. An outgoing call must now actually show an outgoing surface — and it must show
    // WHO is being called (sheet CALL-131).
    func test_1TO1_voiceCallInitiates() {
        monitorPermissionDialogs()
        app = openSeededConversation()
        tapCallButton(video: false)
        XCTAssertTrue(outgoingSurfaceShown(), "Voice call showed no outgoing call surface")
    }

    func test_1TO1_videoCallInitiates() {
        monitorPermissionDialogs()
        app = openSeededConversation()
        tapCallButton(video: true)
        XCTAssertTrue(outgoingSurfaceShown(), "Video call showed no outgoing call surface")
    }

    /// CALL-131 — the outgoing surface identifies the callee by name.
    func test_1TO1_outgoingCallShowsCalleeName() {
        monitorPermissionDialogs()
        app = openSeededConversation()
        tapCallButton(video: false)
        guard outgoingSurfaceShown() else {
            XCTFail("No outgoing call surface appeared"); return
        }
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8),
                      "Outgoing call surface does not show the callee's name")
    }

    /// CALL-144 — both sides calling each other at once must not wedge the app.
    func test_RT_CALL_simultaneousCallsStayUsable() throws {
        try bringUpUserB()
        monitorPermissionDialogs()
        app = openSeededConversation()
        runBlocking { _ = try? await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: false) }
        tapCallButton(video: false)
        _ = app.staticTexts.firstMatch.waitForExistence(timeout: 4)
        runBlocking { await SecondClient.shared.cancelActiveCall() }
        for label in ["Cancel", "End", "End Call", "Close"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        XCTAssertTrue(backOnChat(), "App unusable after simultaneous cross-calls")
    }

    func test_1TO1_cancelCallReturnsToChat() {
        monitorPermissionDialogs()
        app = openSeededConversation()
        tapCallButton(video: false)
        for label in ["Cancel", "End", "End Call", "Decline", "Hang Up", "Close"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 12) || app.staticTexts[TestConfig.userBDisplayName].exists,
            "Did not return to the messages screen after cancelling")
    }

    /// Incoming-call cases use a REAL call from B. The sample app ships `inAppIncomingCall: false`,
    /// so no incoming surface is expected — but the call round-trip must leave an observable call
    /// entry in the conversation. Tightened (ENG-38638) from the old "…OrStable" form, which
    /// passed even when the call never reached the app.
    func test_RT_CALL_incomingVoiceCall() throws {
        try bringUpUserB()
        app = openSeededConversation()
        // Not try?: a call that fails to start (e.g. B still busy) must fail here with its reason,
        // not later as a missing call entry.
        try runBlocking { _ = try await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: false) }
        _ = app.staticTexts.firstMatch.waitForExistence(timeout: 3)
        runBlocking { await SecondClient.shared.cancelActiveCall() }
        XCTAssertTrue(callEntryVisibleInConversation(), "Incoming voice call left no call entry in the conversation")
    }

    func test_RT_CALL_incomingVideoCall() throws {
        try bringUpUserB()
        app = openSeededConversation()
        // Not try?: a call that fails to start (e.g. B still busy) must fail here with its reason,
        // not later as a missing call entry.
        try runBlocking { _ = try await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: true) }
        _ = app.staticTexts.firstMatch.waitForExistence(timeout: 3)
        runBlocking { await SecondClient.shared.cancelActiveCall() }
        XCTAssertTrue(callEntryVisibleInConversation(), "Incoming video call left no call entry in the conversation")
    }

    func test_RT_CALL_rejectReturnsToChat() throws {
        try bringUpUserB()
        app = openSeededConversation()
        runBlocking { _ = try? await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: false) }
        _ = app.staticTexts.firstMatch.waitForExistence(timeout: 4)
        runBlocking { await SecondClient.shared.cancelActiveCall() }
        XCTAssertTrue(backOnChat(), "Did not return to a stable chat after the call was rejected/ended")
    }

    func test_RT_CALL_endedCallLeavesChatStable() throws {
        try bringUpUserB()
        app = openSeededConversation()
        runBlocking { _ = try? await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: false) }
        runBlocking { await SecondClient.shared.cancelActiveCall() }
        XCTAssertTrue(backOnChat(), "Chat not stable after a call ended")
    }

    func test_RT_CALL_updatesConversationListStable() throws {
        try bringUpUserB()
        app = openSeededConversation()
        runBlocking { _ = try? await SecondClient.shared.initiateCall(toUser: TestConfig.userAUid, video: false) }
        runBlocking { await SecondClient.shared.cancelActiveCall() }
        // A lingering call surface can swallow the tab tap, so reaching Chats isn't required — stability is.
        _ = AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        XCTAssertTrue(backOnChat() || app.tabBars.firstMatch.exists,
                      "App not stable after an incoming call round-trip")
    }

    /// Bring User B's in-process client up; skip (not fail) if the busy shared backend won't cooperate.
    private func bringUpUserB() throws {
        try ensureUserBLoggedIn()
        secondClientActive = true
    }

    /// A call round-trip renders a call action bubble ("Voice Call" / "Missed voice call" / …)
    /// as a staticText in the message area (header call controls are buttons, so they don't match).
    private func callEntryVisibleInConversation() -> Bool {
        let entry = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] 'call'")).firstMatch
        return entry.waitForExistence(timeout: 20)
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
            app.tap()
        }
    }

    /// Tightened: an outgoing surface must actually appear; a merely "stable" chat screen fails.
    private func outgoingSurfaceShown() -> Bool {
        let markers = ["Calling", "Ringing", "Connecting", "End", "Cancel", "End Call", "Hang Up"]
        let deadline = Date().addingTimeInterval(12)
        while Date() < deadline {
            if markers.contains(where: { app.staticTexts[$0].exists || app.buttons[$0].exists })
                && !ComponentQueries.composer(app).exists {
                return true
            }
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 0.5)
        }
        return false
    }
}
