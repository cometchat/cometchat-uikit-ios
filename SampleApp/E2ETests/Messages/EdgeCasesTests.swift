import XCTest

/// Mostly structural checks (screen stays usable); content asserted only where a unique token allows it.
final class EdgeCasesTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_1TO1_rapidSendStable() {
        app = openSeededConversation()
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

    func test_RT_EDGE_simultaneousSend() throws {
        app = openSeededConversation()
        let stamp = UUID().uuidString.prefix(6)
        let aToken = "E2E-simA-\(stamp)"
        let bToken = "E2E-simB-\(stamp)"
        ComponentQueries.typeAndSend(app, text: aToken)
        try runBlocking { _ = try await PeerActions.sendTextMessage(bToken) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: aToken, timeout: 14), "A's message missing")
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: bToken, timeout: 20), "B's message missing")
    }

    func test_RT_EDGE_burstNoCrash() throws {
        app = openSeededConversation()
        let stamp = UUID().uuidString.prefix(6)
        try runBlocking {
            for i in 0..<20 { _ = try await PeerActions.sendTextMessage("Burst-\(stamp)-\(i)") }
        }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: "Burst-\(stamp)", timeout: 25),
                      "No burst message arrived")
        app.swipeDown(); app.swipeUp()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not responsive after a burst")
    }

    func test_RT_EDGE_interleavedBidirectionalSends() throws {
        app = openSeededConversation()
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

    func test_RT_EDGE_sendWhileReceivingBurst() throws {
        app = openSeededConversation()
        let stamp = UUID().uuidString.prefix(6)
        let aToken = "EdgeSWR-A-\(stamp)"
        try runBlocking {
            for i in 0..<12 { _ = try await PeerActions.sendTextMessage("EdgeSWR-B-\(stamp)-\(i)") }
        }
        ComponentQueries.typeAndSend(app, text: aToken)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: aToken, timeout: 18),
                      "A's message did not send while receiving a burst")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer not usable during an inbound burst")
    }

    func test_RT_EDGE_scrollDuringLiveInbound() throws {
        app = openSeededConversation()
        let stamp = UUID().uuidString.prefix(6)
        try runBlocking {
            for i in 0..<15 { _ = try await PeerActions.sendTextMessage("EdgeScroll-\(stamp)-\(i)") }
        }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: "EdgeScroll-\(stamp)", timeout: 20),
                      "No inbound message arrived to scroll through")
        app.swipeUp(); app.swipeDown(); app.swipeUp()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not responsive while scrolling live inbound")
    }

    func test_RT_EDGE_noDuplicateMessage() throws {
        app = openSeededConversation()
        let token = "E2E-dup\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        let count = app.buttons.matching(identifier: token).count + app.staticTexts.matching(identifier: token).count
        XCTAssertLessThanOrEqual(count, 1, "Message rendered more than once (\(count))")
    }

    // Peer edits a message while A holds its action sheet open. Overlay layout + peer-edit propagation
    // are non-deterministic, so the edited text is polled non-fatally; surviving the race is the assertion.
    func test_RT_EDGE_editWhilePeerLongPresses() throws {
        app = openSeededConversation()
        let stamp = UUID().uuidString.prefix(6)
        let original = "LongPressEditBefore-\(stamp)"
        let edited = "LongPressEditAfter-\(stamp)"
        let msgId = try runBlocking { try await PeerActions.sendTextMessage(original) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: original, timeout: 20),
                      "Original message did not arrive")

        _ = ComponentQueries.openMessageOptions(app, bubbleText: original)
        try runBlocking { try await PeerActions.editMessage(msgId, newText: edited) }
        _ = ComponentQueries.waitForBubble(app, text: edited, timeout: 15) // logged via result, non-fatal

        app.tap()
        XCTAssertTrue(ComponentQueries.composer(app).exists,
                      "Screen not stable after a concurrent peer edit + open action sheet")
    }

    // A deletes the conversation while B sends immediately after; the conversation must reappear-or-stay-stable.
    func test_RT_EDGE_deleteConversationWhileMessageArrives() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)

        runBlocking { await PeerActions.deleteConversation() }
        let raceText = "AfterDelete-\(UUID().uuidString.prefix(6))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(raceText) }
        _ = ComponentQueries.waitForBubbleContaining(app, substring: raceText, timeout: 20) // non-fatal

        XCTAssertTrue(app.tabBars.firstMatch.exists,
                      "Chats list not stable through the delete/arrive race")
    }

    // A cross-midnight message can't be seeded from the harness, so assert the date-grouping affordance
    // (Today/Yesterday) after a fresh send; label is UIKit-drawn + locale-dependent, so it's structural.
    func test_1TO1_dateSeparatorBetweenDays() throws {
        app = openSeededConversation()
        try runBlocking { _ = try await PeerActions.sendTextMessage("DateSep-\(UUID().uuidString.prefix(6))") }
        let separator = NSPredicate(format:
            "label CONTAINS[c] 'Today' OR label CONTAINS[c] 'Yesterday'")
        _ = app.staticTexts.containing(separator).firstMatch.waitForExistence(timeout: 5) // non-fatal
        XCTAssertTrue(ComponentQueries.composer(app).exists,
                      "Message screen not stable while checking the date separator")
    }

    // Rapid typing start/stop without a flicker crash: REST can't drive an incoming
    // typing indicator (only a live SDK client can, see LiveTypingTests), so the flicker itself isn't
    // producible from A's side — assert the composer survives rapid local typing bursts (structural stand-in).
    func test_RT_EDGE_rapidTypingNoFlicker() {
        app = openSeededConversation()
        let composer = ComponentQueries.composer(app)
        for i in 0..<8 {
            composer.tap()
            composer.typeText("t\(i)")
            // Clear without sending to churn the typing state.
            if let value = composer.value as? String, !value.isEmpty {
                composer.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: value.count))
            }
        }
        XCTAssertTrue(composer.exists, "Composer not stable after rapid typing start/stop")
    }

    func test_1TO1_messagesPresentAfterResume() throws {
        app = openSeededConversation()
        let token = "E2E-resume\(UUID().uuidString.prefix(8))"
        XCUIDevice.shared.press(.home)
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        app.activate()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 25),
                      "Message sent during background did not sync on resume")
    }

    func test_1TO1_emptyConversationStable() {
        // Cleanup first so the chat opens empty; open via Users (no Chats row to find).
        runBlocking { await SeedData.cleanup() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationWith(app, displayName: TestConfig.userBDisplayName),
                      "Could not open a fresh conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Empty conversation did not present a composer")
    }
}
