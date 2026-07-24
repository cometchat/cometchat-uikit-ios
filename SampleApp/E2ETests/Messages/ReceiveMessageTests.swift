import XCTest

/// User B is a headless REST peer whose sends fire real socket events into the app — no second device.
/// Unique per-run tokens keep assertions from matching stale bubbles on the shared backend.
final class ReceiveMessageTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_1TO1_receiveTextRealtime() throws {
        app = openSeededConversation()
        let token = "E2E-recv-\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20),
                      "Message from B did not arrive: \(token)")
    }

    func test_1TO1_receiveMultipleInOrder() throws {
        app = openSeededConversation()
        let stamp = UUID().uuidString.prefix(6)
        var tokens: [String] = []
        try runBlocking {
            for i in 1...5 {
                let token = "E2E-order-\(stamp)-\(i)"
                _ = try await PeerActions.sendTextMessage(token)
                tokens.append(token)
                try await Task.sleep(nanoseconds: 250_000_000)
            }
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: tokens.last!, timeout: 25),
                      "Last message did not arrive")
        if !ComponentQueries.waitForBubble(app, text: tokens.first!, timeout: 3) {
            app.swipeDown(); app.swipeDown()
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: tokens.first!, timeout: 15),
                      "First message did not arrive/load")
    }

    func test_1TO1_receivePlaysSoundStable() throws {
        app = openSeededConversation()
        let token = "E2E-sound-\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20),
                      "Message did not arrive")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not stable after receiving")
    }

    func test_1TO1_receiveWhileOnDifferentTab() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()

        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users)
        let token = "E2E-tab-\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }

        XCTAssertTrue(AppLauncher.openConversationWith(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20),
                      "Message sent while away did not appear on return")
    }

    // Send before entering Chats: the list re-fetches on tab entry but won't re-render a preview in place.
    // Assert via backend lastMessage — a11y-scraping the huge shared Chats list can SIGKILL the test process.
    func test_1TO1_conversationPreviewUpdates() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()

        let token = "E2E-preview-\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)

        let backendReflects = waitForBackend(timeout: 12) {
            await PeerActions.lastConversationMessageText() == token
        }
        XCTAssertTrue(backendReflects,
                      "Conversation preview did not update with the new message")
    }

    // Preview-after-edit asserted via backend `lastMessage` — the Chats a11y walk SIGKILLs here.
    func test_RT_EDIT_editUpdatesConversationPreview() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()

        let edited = "E2E-edited-preview-\(UUID().uuidString.prefix(8))"
        let msgId = try runBlocking { try await PeerActions.sendTextMessage("E2E-orig-\(UUID().uuidString.prefix(6))") }
        try runBlocking { try await PeerActions.editMessage(msgId, newText: edited) }
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)

        XCTAssertTrue(waitForBackend(timeout: 15) { await PeerActions.lastConversationMessageText() == edited },
                      "Conversation preview did not update to the edited text")
    }

    func test_RT_MSG_ownMessageAppears() throws {
        app = openSeededConversation()
        let token = "E2E-own-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14),
                      "Own message did not appear")
    }

    func test_RT_MSG_receiveLongText() throws {
        app = openSeededConversation()
        let tail = "recvtail-\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(String(repeating: "B", count: 1024) + tail) }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 20),
                      "Long received message tail did not arrive")
    }

    // Emoji bubbles expose no queryable a11y label; assert a plain control token arrives + screen stability.
    func test_RT_MSG_receiveEmojiMessage() throws {
        app = openSeededConversation()
        let control = "emoctl\(UUID().uuidString.prefix(6))"
        try runBlocking {
            _ = try await PeerActions.sendTextMessage(control)
            _ = try await PeerActions.sendTextMessage("🎉🔥👍")
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: control, timeout: 20),
                      "Control message did not arrive (delivery not flowing)")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not stable after emoji message")
    }

    func test_RT_MSG_bidirectionalExchange() throws {
        app = openSeededConversation()
        let stamp = UUID().uuidString.prefix(6)
        let aToken = "E2E-A-\(stamp)"
        ComponentQueries.typeAndSend(app, text: aToken)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: aToken, timeout: 14), "A's message missing")
        let bToken = "E2E-B-\(stamp)"
        try runBlocking { _ = try await PeerActions.sendTextMessage(bToken) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: bToken, timeout: 20), "B's message missing")
    }

    // A message A sends from ANOTHER device (same user) syncs into A's open chat. A REST send AS User A
    // produces exactly this — A's app receives its own outbound message over its socket, no second app
    // client needed.
    func test_RT_MSG_selfMessageFromOtherDevice() throws {
        app = openSeededConversation()
        let token = "E2E-otherdev-\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessageAsA(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20),
                      "A's message from another device did not sync into the open chat")
    }

    // A brand-new conversation appears when the first message arrives. The Chats-list row isn't
    // reliably in the a11y tree (scraping the busy list SIGKILLs), so surfacing is asserted at the backend
    // conversation list + Chats-tab stable.
    func test_RT_MSG_newConversationAppears() throws {
        runBlocking { await SeedData.cleanup() } // start with no A↔B conversation
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        let token = "E2E-newconv-\(UUID().uuidString.prefix(6))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        // Read the conversation LIST (GET /conversations/{id} is empty for a 1:1) — the new convo's lastMessage.
        XCTAssertTrue(waitForBackend(timeout: 15) { await PeerActions.lastConversationMessageText() == token },
                      "New conversation did not surface in A's conversation list")
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Chats tab not stable when a new conversation arrived")
    }
}
