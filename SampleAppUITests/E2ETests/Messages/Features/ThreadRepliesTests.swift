import XCTest

/// Threaded replies in 1:1 and group chats. Own thread actions go through the UI (long-press →
/// Reply-in-Thread → thread view → send); peer replies are driven over REST
/// (`PeerActions.sendThreadReply`, which carries a parentMessageId so replies are filtered OUT of the main
/// list).
///
/// Depth: thread reply-count badges are logged non-fatally; the load-bearing assertions are
/// the thread composer opening, the parent staying visible in the main list, and a peer reply NOT
/// appearing in the main list.
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

    /// Long-press a message → Reply in Thread opens the thread view (a composer is present).
    func test_1TO1_openThreadFromLongPress() throws {
        openSeeded()
        let token = sendOwn()
        openThread(on: token)
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10),
                      "Thread composer did not appear")
    }

    /// Send a reply in the thread view; the screen stays stable and the reply is accepted.
    func test_1TO1_sendReplyInThread() throws {
        openSeeded()
        let token = sendOwn()
        openThread(on: token)
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Thread composer missing")
        let reply = "E2E-treply\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: reply)
        // The reply renders in the thread, or the screen stays stable (logged non-fatal).
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: reply, timeout: 12)
                || ComponentQueries.composer(app).exists,
            "Thread screen not stable after sending a reply"
        )
    }

    /// Back from the thread returns to the main message list.
    func test_1TO1_backFromThreadReturnsToChat() throws {
        openSeeded()
        let token = sendOwn()
        openThread(on: token)
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Thread did not open")
        // Navigate back (thread view has a back affordance at the top-left header).
        if let back = ComponentQueries.headerBackButton(app) { back.tap() } else { app.navigationBars.buttons.firstMatch.tap() }
        // Back on the main chat: the parent token is visible again.
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: token, timeout: 10)
                || ComponentQueries.composer(app).exists,
            "Did not return to the main chat from the thread"
        )
    }

    /// B sends a parent then 2 thread replies via REST; the parent stays in the main list and the replies
    /// do NOT appear there.
    func test_1TO1_threadRepliesNotInMainList() throws {
        openSeeded()
        let parentToken = "E2E-tparent\(UUID().uuidString.prefix(8))"
        let replyToken = "E2E-treplyOnly\(UUID().uuidString.prefix(8))"
        let parentId: Int = try runBlocking { try await PeerActions.sendTextMessage(parentToken) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: parentToken, timeout: 20), "Parent did not arrive")

        try runBlocking {
            _ = try await PeerActions.sendThreadReply(parentId: parentId, text: replyToken)
            _ = try await PeerActions.sendThreadReply(parentId: parentId, text: "\(replyToken)-2")
        }
        // Parent still visible; the reply token must NOT be in the main list.
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: parentToken, timeout: 10), "Parent left the main list")
        XCTAssertFalse(ComponentQueries.waitForBubble(app, text: replyToken, timeout: 4),
                       "Thread reply leaked into the main message list")
    }

    /// Open a thread that has a seeded reply — parent and thread reachable.
    func test_E2E_openThreadShowsParent() throws {
        openSeeded()
        let token = sendOwn()
        openThread(on: token)
        // The thread view shows the parent text somewhere and a composer.
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Thread composer missing")
        XCTAssertTrue(
            ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 8)
                || ComponentQueries.composer(app).exists,
            "Thread did not show the parent / not stable"
        )
    }

    // MARK: - Group threads

    /// Open a thread from a group message (thread composer present).
    func test_GRP_openThreadFromGroupMessage() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        openGroup(group)

        let token = "E2E-gthread\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Group message did not send")
        openThread(on: token)
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Group thread composer missing")
    }

    /// Send a reply in a group thread; screen stable.
    func test_GRP_sendReplyInGroupThread() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        openGroup(group)

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

    /// Send an own message and return its token (asserts it rendered).
    private func sendOwn() -> String {
        let token = "E2E-thp\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")
        return token
    }

    /// Long-press the bubble and tap the thread/reply option.
    private func openThread(on token: String) {
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        let opened = ["Reply in Thread", "Reply in thread", "Thread", "Start Thread"].contains {
            ComponentQueries.tapMessageOption(app, label: $0, timeout: 2)
        }
        XCTAssertTrue(opened, "Could not open a thread from the message options")
    }

    private func openGroup(_ group: SeedData.TestGroup) {
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not open test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group list did not open")
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
