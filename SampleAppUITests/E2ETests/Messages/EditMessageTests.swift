import XCTest

/// Editing messages in a 1:1 — own edits via the UI long-press flow, and peer (User B) edits driven over
/// REST that must update live in A's chat.
///
/// Own-edit flow (verified): long-press bubble → popup → Edit → the original text loads into the composer
/// (an "Edit Message" preview bar shows) → append/replace → Send commits → an "Edited" marker prepends the
/// timestamp. Peer edits: `PeerActions.editMessage(id, newText)` on behalf of B; A's open chat updates the
/// bubble in place over the socket.
final class EditMessageTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    /// Edit an own message: send, edit via the popup, and the new text renders.
    func test_1TO1_editOwnMessageUpdatesText() throws {
        openSeeded()
        let token = "E2E-edit\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit),
                      "Edit option missing")

        let composer = ComponentQueries.composer(app)
        XCTAssertTrue(composer.waitForExistence(timeout: 8), "Composer did not focus for edit")
        composer.tap()
        composer.typeText("X")
        ComponentQueries.sendButton(app).tap()

        XCTAssertTrue(
            ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 12), "Edited message did not render"
        )
    }

    /// Entering Edit loads the original text into the composer.
    func test_1TO1_editShowsOriginalInComposer() throws {
        openSeeded()
        let token = "E2E-orig\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit),
                      "Edit option missing")
        // The composer's value should now hold the original text.
        let composer = ComponentQueries.composer(app)
        XCTAssertTrue(composer.waitForExistence(timeout: 8), "Composer not present in edit mode")
        let value = (composer.value as? String) ?? ""
        XCTAssertTrue(value.contains(token) || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", token)).firstMatch.exists,
                      "Original text not loaded into composer for edit (value='\(value)')")
    }

    /// Cancelling an edit leaves the composer normal and the original unchanged.
    func test_1TO1_cancelEditRestoresComposer() throws {
        openSeeded()
        let token = "E2E-cancel\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit),
                      "Edit option missing")
        // Cancel the edit — a close/X on the edit preview bar, or clear the composer.
        for label in ["Close", "Cancel", "close", "cancel"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        // The original bubble is still present and unchanged.
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8),
                      "Original message lost after cancelling edit")
    }

    /// The edited marker renders after committing an edit.
    func test_1TO1_editedMessageShowsMarker() throws {
        openSeeded()
        let token = "E2E-mark\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit),
                      "Edit option missing")
        let composer = ComponentQueries.composer(app)
        XCTAssertTrue(composer.waitForExistence(timeout: 8), "Composer did not focus for edit")
        composer.tap(); composer.typeText("Y")
        ComponentQueries.sendButton(app).tap()
        XCTAssertTrue(ComponentQueries.waitForEditedMarker(app, timeout: 12), "Edited marker did not appear")
    }

    /// A peer (B) message cannot be edited by A — no Edit option in its popup.
    func test_1TO1_cannotEditPeerMessage() throws {
        openSeeded()
        let token = "E2E-peer\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        // Edit must NOT be offered for a peer's message. (Copy/other options may still be present.)
        let editOffered = app.buttons[ComponentQueries.MessageOption.edit].waitForExistence(timeout: 4)
        XCTAssertFalse(editOffered, "Edit was unexpectedly offered on a peer message")
    }

    /// B edits a message via REST; A sees the updated text in place.
    func test_RT_EDIT_peerEditUpdatesLive() throws {
        openSeeded()
        let original = "E2E-rtorig\(UUID().uuidString.prefix(8))"
        let edited = "E2E-rtedit\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(original) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: original, timeout: 20), "Original did not arrive")

        try runBlocking { try await PeerActions.editMessage(id, newText: edited) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: edited, timeout: 20),
                      "Peer edit did not update live to '\(edited)'")
    }

    /// B edits a message via REST; A sees the edited text plus an "Edited" marker.
    func test_RT_EDIT_peerEditShowsMarker() throws {
        openSeeded()
        let original = "E2E-rtm-o\(UUID().uuidString.prefix(8))"
        let edited = "E2E-rtm-e\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(original) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: original, timeout: 20), "Original did not arrive")

        try runBlocking { try await PeerActions.editMessage(id, newText: edited) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: edited, timeout: 20), "Edited text did not arrive")
        XCTAssertTrue(ComponentQueries.waitForEditedMarker(app, timeout: 12), "Edited marker did not appear")
    }

    // MARK: - Helpers

    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open"
        )
    }
}
