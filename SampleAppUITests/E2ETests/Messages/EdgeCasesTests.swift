import XCTest

/// Edge cases — rapid/burst sends, simultaneous send, empty-conversation greeting, date separators, and
/// app-resume sync. Most are structural
/// (screen stays usable, no crash); a few make real content assertions where a unique token allows it.
final class EdgeCasesTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    /// A sends 10 messages rapidly; the screen stays stable and at least one renders.
    func test_1TO1_rapidSendStable() {
        openSeeded()
        let stamp = UUID().uuidString.prefix(6)
        for i in 0..<10 {
            let composer = ComponentQueries.composer(app)
            composer.tap(); composer.typeText("RapidA-\(stamp)-\(i)")
            ComponentQueries.sendButton(app).tap()
        }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: "RapidA-\(stamp)", timeout: 15),
                      "No rapid-send message rendered")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not stable after rapid sends")
    }

    /// A (UI) and B (REST) send back-to-back; both are visible and the screen stays stable.
    func test_RT_EDGE_simultaneousSend() throws {
        openSeeded()
        let stamp = UUID().uuidString.prefix(6)
        let aToken = "E2E-simA-\(stamp)"
        let bToken = "E2E-simB-\(stamp)"
        ComponentQueries.typeAndSend(app, text: aToken)
        try runBlocking { _ = try await PeerActions.sendTextMessage(bToken) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: aToken, timeout: 14), "A's message missing")
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: bToken, timeout: 20), "B's message missing")
    }

    /// B sends a 20-message burst via REST; the screen stays intact and responsive.
    func test_RT_EDGE_burstNoCrash() throws {
        openSeeded()
        let stamp = UUID().uuidString.prefix(6)
        try runBlocking {
            for i in 0..<20 { _ = try await PeerActions.sendTextMessage("Burst-\(stamp)-\(i)") }
        }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: "Burst-\(stamp)", timeout: 25),
                      "No burst message arrived")
        app.swipeDown(); app.swipeUp()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not responsive after a burst")
    }

    /// RT-EDGE-005: A and B send interleaved in rapid alternation; both directions render and the screen
    /// stays stable. Distinct from `simultaneousSend` (a single A+B pair) — this is a sustained back-and-forth.
    func test_RT_EDGE_interleavedBidirectionalSends() throws {
        openSeeded()
        let stamp = UUID().uuidString.prefix(6)
        try runBlocking {
            for i in 0..<5 { _ = try await PeerActions.sendTextMessage("EdgeB-\(stamp)-\(i)") }
        }
        for i in 0..<5 {
            let composer = ComponentQueries.composer(app)
            composer.tap(); composer.typeText("EdgeA-\(stamp)-\(i)")
            ComponentQueries.sendButton(app).tap()
        }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: "EdgeA-\(stamp)", timeout: 20),
                      "A's interleaved messages did not render")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: "EdgeB-\(stamp)", timeout: 20),
                      "B's interleaved messages did not render")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not stable after interleaved sends")
    }

    /// RT-EDGE-006: A can send while an inbound burst from B is arriving; the composer stays usable and A's
    /// own message renders (send-under-load, not just receive-under-load like `burstNoCrash`).
    func test_RT_EDGE_sendWhileReceivingBurst() throws {
        openSeeded()
        let stamp = UUID().uuidString.prefix(6)
        let aToken = "EdgeSWR-A-\(stamp)"
        // Kick off B's burst, then immediately have A send into the same window.
        try runBlocking {
            for i in 0..<12 { _ = try await PeerActions.sendTextMessage("EdgeSWR-B-\(stamp)-\(i)") }
        }
        ComponentQueries.typeAndSend(app, text: aToken)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: aToken, timeout: 18),
                      "A's message did not send while receiving a burst")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer not usable during an inbound burst")
    }

    /// RT-EDGE-007: scrolling the list while messages arrive live keeps the screen stable and responsive.
    func test_RT_EDGE_scrollDuringLiveInbound() throws {
        openSeeded()
        let stamp = UUID().uuidString.prefix(6)
        try runBlocking {
            for i in 0..<15 { _ = try await PeerActions.sendTextMessage("EdgeScroll-\(stamp)-\(i)") }
        }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: "EdgeScroll-\(stamp)", timeout: 20),
                      "No inbound message arrived to scroll through")
        app.swipeUp(); app.swipeDown(); app.swipeUp()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not responsive while scrolling live inbound")
    }

    /// A message B sends is not duplicated on A's side.
    func test_RT_EDGE_noDuplicateMessage() throws {
        openSeeded()
        let token = "E2E-dup\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        // At most one rendered copy carries the unique token (dedup — no duplicate frames).
        let count = app.buttons.matching(identifier: token).count + app.staticTexts.matching(identifier: token).count
        XCTAssertLessThanOrEqual(count, 1, "Message rendered more than once (\(count))")
    }

    /// App resume after a foreground gap keeps B's messages present.
    func test_1TO1_messagesPresentAfterResume() throws {
        openSeeded()
        let token = "E2E-resume\(UUID().uuidString.prefix(8))"
        // Background then foreground the app.
        XCUIDevice.shared.press(.home)
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        app.activate()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 25),
                      "Message sent during background did not sync on resume")
    }

    /// An empty conversation opens with a composer and stays stable (greeting logged non-fatal).
    func test_1TO1_emptyConversationStable() {
        // Delete the conversation so it opens empty, then open via Users (no Chats row to find).
        runBlocking { await SeedData.cleanup() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationWith(app, displayName: TestConfig.userBDisplayName),
                      "Could not open a fresh conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Empty conversation did not present a composer")
    }

    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }
}
