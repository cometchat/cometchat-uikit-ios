import XCTest

/// Message actions in a group — edit/delete own messages, the long-press popup, copy.
final class GroupMessageActionsTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedGroup = group; group = nil
        runBlocking { await SeedData.deleteTestGroup(capturedGroup) }
    }

    func test_GRP_editOwnGroupMessage() throws {
        openGroup()
        let token = "E2E-gedit\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit), "Edit missing")
        let composer = ComponentQueries.composer(app)
        XCTAssertTrue(composer.waitForExistence(timeout: 8), "Composer did not focus for edit")
        composer.tap(); composer.typeText("Z")
        ComponentQueries.sendButton(app).tap()
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 12), "Edit did not render")
    }

    func test_GRP_editedShowsMarker() throws {
        openGroup()
        let token = "E2E-gmark\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit), "Edit missing")
        let composer = ComponentQueries.composer(app)
        XCTAssertTrue(composer.waitForExistence(timeout: 8), "Composer did not focus")
        composer.tap(); composer.typeText("W")
        ComponentQueries.sendButton(app).tap()
        XCTAssertTrue(ComponentQueries.waitForEditedMarker(app, timeout: 12), "Edited marker did not appear")
    }

    func test_GRP_deleteOwnGroupMessage() throws {
        openGroup()
        let token = "E2E-gdel\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.delete), "Delete missing")
        _ = ComponentQueries.confirmDestructiveAction(app)
        XCTAssertTrue(
            ComponentQueries.waitForDeletedPlaceholder(app, timeout: 12)
                || !ComponentQueries.waitForBubble(app, text: token, timeout: 3),
            "Group message not deleted"
        )
    }

    func test_GRP_cancelEditRestoresComposer() throws {
        openGroup()
        let token = "E2E-gcancel\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Original did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit), "Edit missing")
        for label in ["Close", "Cancel", "close", "cancel"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8),
                      "Original group message lost after cancelling edit")
    }

    func test_GRP_copyGroupMessage() throws {
        openGroup()
        let token = "E2E-gcopy\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(
            app.buttons[ComponentQueries.MessageOption.copy].waitForExistence(timeout: 6)
                || app.staticTexts[ComponentQueries.MessageOption.copy].exists,
            "Copy option missing in group popup"
        )
    }

    func test_GRP_longPressShowsActionPopup() throws {
        openGroup()
        let token = "E2E-glp\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        let anyOption = ["Copy", "Edit", "Delete", "Reply in Thread", "Info"].contains {
            app.buttons[$0].waitForExistence(timeout: 4) || app.staticTexts[$0].exists
        }
        XCTAssertTrue(anyOption, "Group message action popup did not present options")
    }

    /// Info is offered on a group message. The info detail rows themselves aren't in the a11y tree.
    func test_GRP_messageInfoOptionOffered() throws {
        openGroup()
        let token = "E2E-ginfo\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        XCTAssertTrue(
            app.buttons[ComponentQueries.MessageOption.info].waitForExistence(timeout: 6)
                || app.staticTexts[ComponentQueries.MessageOption.info].exists,
            "Info option missing in group popup"
        )
    }

    private func openGroup() {
        (app, group) = openSeededGroupWithMember()
    }
}
