import XCTest

/// Deleting messages in a 1:1 — own deletes via the UI long-press flow, and peer (User B) deletes driven
/// over REST that must remove/placeholder the bubble live in A's chat.
///
/// Own-delete flow: long-press bubble → popup → Delete → (destructive confirm) → the bubble is replaced by
/// the "This message was deleted" placeholder. Peer deletes: `PeerActions.deleteMessage(id)` on behalf of
/// B; A's chat updates over the socket.
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

    /// Delete an own message: send, delete via popup + confirm, the original text is gone.
    func test_1TO1_deleteOwnMessage() throws {
        openSeeded()
        let token = "E2E-del\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.delete),
                      "Delete option missing")
        _ = ComponentQueries.confirmDestructiveAction(app)
        // The original text bubble is gone (placeholder replaces it).
        XCTAssertTrue(
            ComponentQueries.waitForDeletedPlaceholder(app, timeout: 12)
                || !ComponentQueries.waitForBubble(app, text: token, timeout: 3),
            "Deleted message still shows original text"
        )
    }

    /// Deleting shows a confirmation affordance before removing.
    func test_1TO1_deleteShowsConfirmation() throws {
        openSeeded()
        let token = "E2E-delc\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.delete),
                      "Delete option missing")
        // A confirm control ("Delete"/"Yes") appears; confirm it.
        XCTAssertTrue(ComponentQueries.confirmDestructiveAction(app), "No delete confirmation appeared")
        XCTAssertTrue(
            ComponentQueries.waitForDeletedPlaceholder(app, timeout: 12)
                || !ComponentQueries.waitForBubble(app, text: token, timeout: 3),
            "Message not removed after confirming delete"
        )
    }

    /// The deleted-message placeholder replaces the bubble.
    func test_1TO1_deletedShowsPlaceholder() throws {
        openSeeded()
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

    /// A peer (B) message survives A's long-press — A cannot remove it from view.
    func test_1TO1_cannotDeletePeerMessage() throws {
        openSeeded()
        let token = "E2E-pdel\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        // Delete must not be offered for the peer's message; dismiss the popup and confirm it survives.
        let deleteOffered = app.buttons[ComponentQueries.MessageOption.delete].waitForExistence(timeout: 4)
        XCTAssertFalse(deleteOffered, "Delete was unexpectedly offered on a peer message")
        // Dismiss the popup (tap elsewhere) and assert the message is still there.
        app.tap()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 6), "Peer message vanished")
    }

    /// B deletes a message via REST; A sees it removed/placeholdered live.
    func test_1TO1_peerDeletesLive() throws {
        openSeeded()
        let token = "E2E-rtdel\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")

        try runBlocking { try await PeerActions.deleteMessage(id) }
        // The original text disappears (or the deleted placeholder appears).
        let removed = ComponentQueries.waitForDeletedPlaceholder(app, timeout: 20)
            || !ComponentQueries.waitForBubble(app, text: token, timeout: 5)
        XCTAssertTrue(removed, "Peer delete did not remove the message live")
    }

    /// B deletes a message while A is on the Chats list; the preview drops/placeholders it.
    func test_RT_DEL_peerDeleteUpdatesPreview() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()

        let token = "E2E-dpv\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        XCTAssertTrue(
            ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20)
                || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", token)).firstMatch.exists,
            "Original preview did not appear"
        )

        try runBlocking { try await PeerActions.deleteMessage(id) }
        // The preview no longer shows the original token (deleted placeholder or dropped).
        let cleared = !ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 8)
        XCTAssertTrue(cleared || app.staticTexts["This message was deleted"].exists,
                      "Preview still shows the deleted message text")
    }

    // MARK: - Helpers

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
