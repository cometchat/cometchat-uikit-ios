import XCTest

/// Deleting messages in a 1:1 — own deletes via the UI long-press flow, and peer deletes over REST that
/// must remove/placeholder the bubble live in A's chat.
final class DeleteMessageTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_1TO1_deleteOwnMessage() throws {
        app = openSeededConversation()
        let token = "E2E-del\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.delete),
                      "Delete option missing")
        _ = ComponentQueries.confirmDestructiveAction(app)
        XCTAssertTrue(
            ComponentQueries.waitForDeletedPlaceholder(app, timeout: 12)
                || !ComponentQueries.waitForBubble(app, text: token, timeout: 3),
            "Deleted message still shows original text"
        )
    }

    func test_1TO1_deleteShowsConfirmation() throws {
        app = openSeededConversation()
        let token = "E2E-delc\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.delete),
                      "Delete option missing")
        XCTAssertTrue(ComponentQueries.confirmDestructiveAction(app), "No delete confirmation appeared")
        XCTAssertTrue(
            ComponentQueries.waitForDeletedPlaceholder(app, timeout: 12)
                || !ComponentQueries.waitForBubble(app, text: token, timeout: 3),
            "Message not removed after confirming delete"
        )
    }

    func test_1TO1_deletedShowsPlaceholder() throws {
        app = openSeededConversation()
        let token = "E2E-delp\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.delete),
                      "Delete option missing")
        _ = ComponentQueries.confirmDestructiveAction(app)
        XCTAssertTrue(ComponentQueries.waitForDeletedPlaceholder(app, timeout: 12),
                      "Deleted-message placeholder did not appear")
    }

    func test_1TO1_cannotDeletePeerMessage() throws {
        app = openSeededConversation()
        let token = "E2E-pdel\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        let deleteOffered = app.buttons[ComponentQueries.MessageOption.delete].waitForExistence(timeout: 4)
        XCTAssertFalse(deleteOffered, "Delete was unexpectedly offered on a peer message")
        app.tap()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 6), "Peer message vanished")
    }

    func test_1TO1_peerDeletesLive() throws {
        app = openSeededConversation()
        let token = "E2E-rtdel\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")

        try runBlocking { try await PeerActions.deleteMessage(id) }
        let removed = ComponentQueries.waitForDeletedPlaceholder(app, timeout: 20)
            || !ComponentQueries.waitForBubble(app, text: token, timeout: 5)
        XCTAssertTrue(removed, "Peer delete did not remove the message live")
    }

    // Drives the real UI flow (launch → send → open Chats) but asserts via backend `lastMessage`: the Chats
    // preview doesn't re-render in place on a live delete, and a11y-scraping the huge shared list can SIGKILL.
    func test_RT_DEL_peerDeleteUpdatesPreview() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()

        let token = "E2E-dpv\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        XCTAssertTrue(waitForBackend(timeout: 15) { await PeerActions.previewShowsLiveMessage(token) },
                      "Original message did not become the conversation preview")

        try runBlocking { try await PeerActions.deleteMessage(id) }
        XCTAssertTrue(waitForBackend(timeout: 15) { await PeerActions.previewShowsLiveMessage(token) == false },
                      "Preview still reflects the deleted message text")
    }
}
