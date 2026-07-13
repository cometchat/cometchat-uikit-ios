import XCTest

/// Editing messages in a 1:1 — own edits via the UI long-press flow, and peer edits over REST that must
/// update live in A's chat.
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

    func test_1TO1_editOwnMessageUpdatesText() throws {
        app = openSeededConversation()
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

    func test_1TO1_editShowsOriginalInComposer() throws {
        app = openSeededConversation()
        let token = "E2E-orig\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit),
                      "Edit option missing")
        let composer = ComponentQueries.composer(app)
        XCTAssertTrue(composer.waitForExistence(timeout: 8), "Composer not present in edit mode")
        let value = (composer.value as? String) ?? ""
        XCTAssertTrue(value.contains(token) || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", token)).firstMatch.exists,
                      "Original text not loaded into composer for edit (value='\(value)')")
    }

    func test_1TO1_cancelEditRestoresComposer() throws {
        app = openSeededConversation()
        let token = "E2E-cancel\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit),
                      "Edit option missing")
        for label in ["Close", "Cancel", "close", "cancel"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8),
                      "Original message lost after cancelling edit")
    }

    func test_1TO1_editedMessageShowsMarker() throws {
        app = openSeededConversation()
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

    func test_1TO1_cannotEditPeerMessage() throws {
        app = openSeededConversation()
        let token = "E2E-peer\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        let editOffered = app.buttons[ComponentQueries.MessageOption.edit].waitForExistence(timeout: 4)
        XCTAssertFalse(editOffered, "Edit was unexpectedly offered on a peer message")
    }

    func test_RT_EDIT_peerEditUpdatesLive() throws {
        app = openSeededConversation()
        let original = "E2E-rtorig\(UUID().uuidString.prefix(8))"
        let edited = "E2E-rtedit\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(original) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: original, timeout: 20), "Original did not arrive")

        try runBlocking { try await PeerActions.editMessage(id, newText: edited) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: edited, timeout: 20),
                      "Peer edit did not update live to '\(edited)'")
    }

    func test_RT_EDIT_peerEditShowsMarker() throws {
        app = openSeededConversation()
        let original = "E2E-rtm-o\(UUID().uuidString.prefix(8))"
        let edited = "E2E-rtm-e\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(original) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: original, timeout: 20), "Original did not arrive")

        try runBlocking { try await PeerActions.editMessage(id, newText: edited) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: edited, timeout: 20), "Edited text did not arrive")
        XCTAssertTrue(ComponentQueries.waitForEditedMarker(app, timeout: 12), "Edited marker did not appear")
    }
}
