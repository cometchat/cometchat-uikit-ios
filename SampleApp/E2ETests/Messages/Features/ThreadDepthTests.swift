import XCTest

/// Deeper thread flows than ThreadRepliesTests. Replies are seeded over REST BEFORE the chat
/// opens, so the cases test what the thread shows rather than real-time delivery; outcomes
/// the UI cannot prove (ordering on the wire, where a reply landed) are read from the backend.
final class ThreadDepthTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        let captured = group; group = nil
        runBlocking {
            await SeedData.deleteTestGroup(captured)
            await SeedData.cleanup()
        }
    }

    private func stamp() -> String { String(UUID().uuidString.prefix(6)).lowercased() }

    private func openConversationAfterSeeding() {
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation with \(TestConfig.userBDisplayName)")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }

    private func openThread(on text: String) {
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: text, timeout: 20), "Parent \(text) not in the list")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: text), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: "Reply in Thread"),
                      "Reply in Thread option missing")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10), "Thread did not open")
    }

    func test_1TO1_THREAD_seededRepliesShowInSentOrder() throws {
        let s = stamp()
        let parent = "tpar\(s)", replies = ["tr1\(s)", "tr2\(s)", "tr3\(s)"]
        try runBlocking {
            try await SeedData.createTestConversation()
            let pid = try await PeerActions.sendTextMessage(parent)
            for r in replies { _ = try await PeerActions.sendThreadReply(parentId: pid, text: r) }
        }
        openConversationAfterSeeding()
        openThread(on: parent)
        for r in replies {
            XCTAssertTrue(ComponentQueries.waitForBubble(app, text: r, timeout: 15), "Reply \(r) missing from the thread")
        }
        let ys = replies.map { ComponentQueries.bubble(app, text: $0).frame.midY }
        XCTAssertEqual(ys, ys.sorted(), "Thread replies are not in the order they were sent")
    }

    func test_1TO1_THREAD_replyFromThreadIsStoredUnderItsParent() throws {
        let s = stamp()
        let parent = "tsp\(s)", reply = "tsr\(s)"
        var pid = 0
        try runBlocking {
            try await SeedData.createTestConversation()
            pid = try await PeerActions.sendTextMessage(parent)
        }
        openConversationAfterSeeding()
        openThread(on: parent)
        ComponentQueries.typeAndSend(app, text: reply)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: reply, timeout: 15), "Reply did not render in the thread")
        let stored = waitForBackend(timeout: 20) {
            await PeerActions.threadReplyTexts(parentId: pid).contains(reply)
        }
        XCTAssertTrue(stored, "The reply sent from the thread is not stored as a reply to its parent")
    }

    func test_1TO1_THREAD_editedReplyShowsNewTextInThread() throws {
        let s = stamp()
        let parent = "tep\(s)", original = "teo\(s)", edited = "ted\(s)"
        try runBlocking {
            try await SeedData.createTestConversation()
            let pid = try await PeerActions.sendTextMessage(parent)
            let rid = try await PeerActions.sendThreadReply(parentId: pid, text: original)
            try await PeerActions.editMessage(rid, newText: edited)
        }
        openConversationAfterSeeding()
        openThread(on: parent)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: edited, timeout: 15), "Edited reply text not shown")
        XCTAssertFalse(ComponentQueries.waitForBubble(app, text: original, timeout: 2), "Pre-edit reply text still shown")
    }

    func test_1TO1_THREAD_deletedReplyLeavesThread() throws {
        let s = stamp()
        let parent = "tdp\(s)", kept = "tdk\(s)", removed = "tdx\(s)"
        try runBlocking {
            try await SeedData.createTestConversation()
            let pid = try await PeerActions.sendTextMessage(parent)
            _ = try await PeerActions.sendThreadReply(parentId: pid, text: kept)
            let rid = try await PeerActions.sendThreadReply(parentId: pid, text: removed)
            try await PeerActions.deleteMessage(rid)
        }
        openConversationAfterSeeding()
        openThread(on: parent)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: kept, timeout: 15), "Surviving reply missing")
        XCTAssertFalse(ComponentQueries.waitForBubble(app, text: removed, timeout: 3), "Deleted reply still shows its text")
    }

    // MARK: - Group threads, peer replying live (Wave 6)

    /// A's own group message gains a reply count as B replies in its thread — "1 reply", then
    /// "2 replies" — without A leaving the screen. Real-time.
    func test_GRP_THREAD_parentReplyCountUpdatesOnPeerReply() throws {
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = created
        app = openSeededGroup(created)
        let parent = "gcnt\(stamp())"
        ComponentQueries.typeAndSend(app, text: parent)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: parent, timeout: 15), "Group message did not send")
        var pid = 0
        XCTAssertTrue(waitForBackend(timeout: 20) {
            let last = await PeerActions.lastConversationMessage(group: created.guid)
            guard ((last?["data"] as? [String: Any])?["text"] as? String) == parent,
                  let id = PeerActions.messageID(of: last) else { return false }
            pid = id
            return true
        }, "Could not find the sent message on the backend")

        try runBlocking { _ = try await PeerActions.sendThreadReply(parentId: pid, text: "gr1\(self.stamp())",
                                                                   receiver: created.guid, receiverType: "group") }
        XCTAssertTrue(app.staticTexts["1 reply"].waitForExistence(timeout: 20),
                      "Parent did not show '1 reply' after B's first thread reply")

        try runBlocking { _ = try await PeerActions.sendThreadReply(parentId: pid, text: "gr2\(self.stamp())",
                                                                   receiver: created.guid, receiverType: "group") }
        XCTAssertTrue(app.staticTexts["2 replies"].waitForExistence(timeout: 20),
                      "Parent did not show '2 replies' after B's second thread reply")
    }

    /// Opening the thread of A's own group message shows the reply B posted after the chat was
    /// already open (the seeded-before-open case is `test_GRP_THREAD_seededGroupRepliesShowInThread`).
    func test_GRP_THREAD_openingThreadShowsPeersLiveReply() throws {
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = created
        app = openSeededGroup(created)
        let parent = "gopn\(stamp())", reply = "gorp\(stamp())"
        ComponentQueries.typeAndSend(app, text: parent)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: parent, timeout: 15), "Group message did not send")
        var pid = 0
        XCTAssertTrue(waitForBackend(timeout: 20) {
            let last = await PeerActions.lastConversationMessage(group: created.guid)
            guard ((last?["data"] as? [String: Any])?["text"] as? String) == parent,
                  let id = PeerActions.messageID(of: last) else { return false }
            pid = id
            return true
        }, "Could not find the sent message on the backend")
        try runBlocking { _ = try await PeerActions.sendThreadReply(parentId: pid, text: reply,
                                                                   receiver: created.guid, receiverType: "group") }

        openThread(on: parent)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: reply, timeout: 20),
                      "B's thread reply is not shown when the thread opens")
    }

    func test_GRP_THREAD_seededGroupRepliesShowInThread() throws {
        let s = stamp()
        let parent = "gtp\(s)", reply = "gtr\(s)"
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = created
        try runBlocking {
            let pid = try await PeerActions.sendGroupTextMessage(parent, groupId: created.guid)
            _ = try await PeerActions.sendThreadReply(parentId: pid, text: reply,
                                                      receiver: created.guid, receiverType: "group")
        }
        app = openSeededGroup(created)
        openThread(on: parent)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: reply, timeout: 15), "Group thread reply missing")
    }
}
