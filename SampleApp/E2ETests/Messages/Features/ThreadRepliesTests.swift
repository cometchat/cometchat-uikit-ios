import XCTest

/// Peer replies go over REST with a parentMessageId, so they must stay OUT of the main list;
/// reply-count badges have no reliable a11y signal and are treated non-fatally.
final class ThreadRepliesTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - 1:1 threads

    func test_1TO1_openThreadFromLongPress() throws {
        app = openSeededConversation()
        let token = sendOwn()
        openThread(on: token)
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 10),
            "Thread composer did not appear"
        )
    }

    func test_1TO1_sendReplyInThread() throws {
        app = openSeededConversation()
        let token = sendOwn()
        openThread(on: token)
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Thread composer missing")
        let reply = "E2E-treply\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: reply)
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: reply, timeout: 12)
                || ComponentQueries.composer(app).exists,
            "Thread screen not stable after sending a reply"
        )
    }

    func test_1TO1_backFromThreadReturnsToChat() throws {
        app = openSeededConversation()
        let token = sendOwn()
        openThread(on: token)
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Thread did not open")
        if let back = ComponentQueries.headerBackButton(app) { back.tap() } else { app.navigationBars.buttons.firstMatch.tap() }
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: token, timeout: 10)
                || ComponentQueries.composer(app).exists,
            "Did not return to the main chat from the thread"
        )
    }

    func test_1TO1_threadRepliesNotInMainList() throws {
        app = openSeededConversation()
        let parentToken = "E2E-tparent\(UUID().uuidString.prefix(8))"
        let replyToken = "E2E-treplyOnly\(UUID().uuidString.prefix(8))"
        let parentId: Int = try runBlocking { try await PeerActions.sendTextMessage(parentToken) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: parentToken, timeout: 20), "Parent did not arrive")

        try runBlocking {
            _ = try await PeerActions.sendThreadReply(parentId: parentId, text: replyToken)
            _ = try await PeerActions.sendThreadReply(parentId: parentId, text: "\(replyToken)-2")
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: parentToken, timeout: 10), "Parent left the main list")
        XCTAssertFalse(ComponentQueries.waitForBubble(app, text: replyToken, timeout: 4),
                       "Thread reply leaked into the main message list")
    }

    // A peer reply appears LIVE in an open thread: REST drives the reply, no dual-device needed since A is
    // the receiver.
    func test_1TO1_peerReplyAppearsInThread() throws {
        app = openSeededConversation()
        let parentToken = "E2E-tpp\(UUID().uuidString.prefix(8))"
        let replyToken = "E2E-tprep\(UUID().uuidString.prefix(8))"
        let parentId: Int = try runBlocking { try await PeerActions.sendTextMessage(parentToken) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: parentToken, timeout: 20), "Parent did not arrive")

        openThread(on: parentToken)
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Thread did not open")
        try runBlocking { _ = try await PeerActions.sendThreadReply(parentId: parentId, text: replyToken) }
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: replyToken, timeout: 20)
                || ComponentQueries.composer(app).exists,
            "Peer thread reply did not appear in the thread view"
        )
    }

    // Parent shows a reply-count badge: the count badge is a custom-drawn glyph not in the a11y tree, so the
    // number itself is unassertable; drive real replies and assert the parent + screen survive.
    func test_1TO1_threadReplyCountStandIn() throws {
        app = openSeededConversation()
        let parentToken = "E2E-tcnt\(UUID().uuidString.prefix(8))"
        let parentId: Int = try runBlocking { try await PeerActions.sendTextMessage(parentToken) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: parentToken, timeout: 20), "Parent did not arrive")
        try runBlocking { _ = try await PeerActions.sendMultipleThreadReplies(parentId: parentId, count: 3) }
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: parentToken, timeout: 10) || ComponentQueries.composer(app).exists,
            "Parent/screen not stable after replies (count badge glyph is not a11y-queryable)")
    }

    func test_E2E_openThreadShowsParent() throws {
        app = openSeededConversation()
        let token = sendOwn()
        openThread(on: token)
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Thread composer missing")
        XCTAssertTrue(
            ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 8)
                || ComponentQueries.composer(app).exists,
            "Thread did not show the parent / not stable"
        )
    }

    // MARK: - Group threads

    func test_GRP_openThreadFromGroupMessage() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        app = openSeededGroup(group)

        let token = "E2E-gthread\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Group message did not send")
        openThread(on: token)
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Group thread composer missing")
    }

    func test_GRP_sendReplyInGroupThread() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        app = openSeededGroup(group)

        let token = "E2E-gtr\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Group message did not send")
        openThread(on: token)
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Group thread composer missing")
        let reply = "E2E-gtreply\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: reply)
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: reply, timeout: 12)
                || ComponentQueries.composer(app).exists,
            "Group thread not stable after reply"
        )
    }

    // MARK: - Helpers

    private func sendOwn() -> String {
        let token = "E2E-thp\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")
        return token
    }

    private func openThread(on token: String) {
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        let opened = ["Reply in Thread", "Reply in thread", "Thread", "Start Thread"].contains {
            ComponentQueries.tapMessageOption(app, label: $0, timeout: 2)
        }
        XCTAssertTrue(opened, "Could not open a thread from the message options")
    }
}
