import XCTest

/// B authors the acted-upon message via REST so A always acts on ANOTHER member's message; A's role varies per case.
final class GroupMessagePermissionTests: XCTestCase {

    private var app: XCUIApplication!
    private var ctx: SeedData.TestGroupContext?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedContext = ctx; ctx = nil
        runBlocking { await SeedData.deleteTestGroup(capturedContext) }
    }

    func test_GRP_participantCannotEditOthersMessage() throws {
        let token = openGroupWithBMessage(aScope: "participant")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press on B's message failed")
        XCTAssertFalse(messageOptionPresent(ComponentQueries.MessageOption.edit),
                       "A participant should NOT see Edit on another member's message")
    }

    func test_GRP_adminDeletesOthersMessage() throws {
        let token = openGroupWithBMessage(aScope: "admin") // admin path = A owns the group
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press on B's message failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.delete),
                      "Admin should see Delete on another member's message")
        _ = ComponentQueries.confirmDestructiveAction(app)
        XCTAssertTrue(
            ComponentQueries.waitForDeletedPlaceholder(app, timeout: 12)
                || !ComponentQueries.waitForBubble(app, text: token, timeout: 3),
            "Admin's delete of another member's message did not take effect"
        )
    }

    func test_GRP_participantCannotDeleteOthersMessage() throws {
        let token = openGroupWithBMessage(aScope: "participant")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press on B's message failed")
        XCTAssertFalse(messageOptionPresent(ComponentQueries.MessageOption.delete),
                       "A participant should NOT see Delete on another member's message")
    }

    func test_GRP_moderatorDeletesOthersMessage() throws {
        let token = openGroupWithBMessage(aScope: "moderator")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press on B's message failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.delete),
                      "Moderator should see Delete on another member's message")
        _ = ComponentQueries.confirmDestructiveAction(app)
        XCTAssertTrue(
            ComponentQueries.waitForDeletedPlaceholder(app, timeout: 12)
                || !ComponentQueries.waitForBubble(app, text: token, timeout: 3),
            "Moderator's delete of another member's message did not take effect"
        )
    }

    // MARK: - Helpers

    private func messageOptionPresent(_ label: String) -> Bool {
        // Wait for an always-present option (Copy) first — a slow popup would read the restricted option as absent and false-pass.
        let copy = ComponentQueries.MessageOption.copy
        let popupUp = app.buttons[copy].waitForExistence(timeout: 6) || app.staticTexts[copy].exists
        XCTAssertTrue(popupUp, "Message-options popup did not present — cannot assert '\(label)' visibility")
        return app.buttons[label].exists || app.staticTexts[label].exists
    }

    private func openGroupWithBMessage(aScope: String) -> String {
        let token = "E2E-gperm\(UUID().uuidString.prefix(8))"
        let context: SeedData.TestGroupContext? = try? runBlocking {
            let created = aScope == "admin"
                ? try await SeedData.createGroupOwnedByA()
                : try await SeedData.createGroupOwnedByBWithAAs(aScope)
            _ = try await PeerActions.sendGroupTextMessage(token, groupId: created.group.guid)
            return created
        }
        ctx = context
        XCTAssertNotNil(context, "Could not seed the permission-test group + B message")
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: context!.group.name), "Could not open the test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "B's group message did not arrive")
        return token
    }
}
