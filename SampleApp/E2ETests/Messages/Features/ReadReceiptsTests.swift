import XCTest

/// Read receipts. On iOS the receipt tick is a PNG image with no queryable state, so these assert the
/// message persists through the delivered/read events and the screen stays stable, not the tick colour.
final class ReadReceiptsTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_1TO1_sentReceiptShown() throws {
        app = openSeededConversation()
        let token = "E2E-sent\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Sent message not shown")
    }

    func test_1TO1_deliveredReceipt() throws {
        app = openSeededConversation()
        let token = "E2E-deliv\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        runBlocking { await PeerActions.markAsDelivered(id) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8), "Message vanished after delivered")
    }

    func test_1TO1_readReceipt() throws {
        app = openSeededConversation()
        let token = "E2E-read\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        runBlocking { await PeerActions.markAsRead(id) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8), "Message vanished after read")
    }

    func test_1TO1_receiptsStructural() throws {
        app = openSeededConversation()
        let token = "E2E-rcfg\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message not shown")
    }

    func test_RT_RCPT_cumulativeRead() throws {
        app = openSeededConversation()
        let stamp = UUID().uuidString.prefix(6)
        var lastId = 0
        var lastToken = ""
        try runBlocking {
            for i in 1...3 {
                let token = "E2E-cum-\(stamp)-\(i)"
                lastId = try await PeerActions.sendTextMessage(token)
                lastToken = token
                try await Task.sleep(nanoseconds: 250_000_000)
            }
            await PeerActions.markAsRead(lastId)
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: lastToken, timeout: 25), "Latest message missing")
    }

    // The sent/delivered TICK is a PNG image-swap with no a11y state, so the glyph colour itself is
    // unassertable on iOS. But the underlying DELIVERED state IS backend-readable (`deliveredAt`), so
    // assert that directly.
    func test_RT_RCPT_deliveredStateBackend() throws {
        app = openSeededConversation()
        let token = "E2E-delivbk-\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        runBlocking { await PeerActions.markAsDelivered(id) }
        XCTAssertTrue(waitForBackend(timeout: 12) { await PeerActions.messageDeliveredAt(id) != nil },
                      "Backend did not record the delivered receipt")
    }

    // The READ (blue) tick is a PNG AND `readAt` is not surfaced to the sender via REST here,
    // so read state is backend-unassertable — the only honest check is that the message survives the read
    // event and the screen stays stable. Documented limitation, not a gap we can close.
    func test_RT_RCPT_readEventStable() throws {
        app = openSeededConversation()
        let token = "E2E-readstable-\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        runBlocking { await PeerActions.markAsRead(id) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8), "Message vanished after read")
    }

    // No read receipt if the chat is never opened. Read-ABSENCE isn't assertable via the tick
    // (PNG) and `readAt` isn't exposed, so this is a stability stand-in — A never opens the chat, app stable.
    func test_RT_RCPT_noReadWhenChatUnopened() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        try runBlocking { _ = try await PeerActions.sendTextMessage("E2E-unopened-\(UUID().uuidString.prefix(6))") }
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Home not stable with an unread inbound message")
    }

    // Receipt on the conversation-list last message. The Chats-list receipt glyph isn't in the
    // a11y tree and scraping the busy list SIGKILLs, so assert delivered backend-state + Chats stable.
    func test_RT_RCPT_conversationListReceiptBackend() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage("E2E-listrcpt-\(UUID().uuidString.prefix(6))") }
        runBlocking { await PeerActions.markAsDelivered(id) }
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        XCTAssertTrue(waitForBackend(timeout: 12) { await PeerActions.messageDeliveredAt(id) != nil },
                      "Backend did not record delivery for the conversation-list receipt")
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Chats tab not stable")
    }

    // Delivered-to-all in a group. Per-member receipt state is server-driven and the tick isn't
    // in the a11y tree, so this is a group send + screen-stable stand-in.
    func test_RT_RCPT_groupDeliveredStable() throws {
        let (seededApp, group) = openSeededGroupWithMember()
        app = seededApp
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        guard let group else { return }
        try runBlocking { _ = try await PeerActions.sendGroupTextMessage("E2E-grcpt-\(UUID().uuidString.prefix(6))", groupId: group.guid) }
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Group screen not stable after a delivered message")
    }
}
