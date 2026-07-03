import XCTest

/// Permission-enforcing message actions in a group — who may edit/delete ANOTHER member's message,
/// keyed by the acting user's role. These carry real regression value: they prove the framework hides
/// Edit/Delete for messages the current user isn't allowed to modify, and shows Delete for admins/moderators.
///
/// Setup: the acted-upon message is authored by User B (via REST) so User A is always acting on SOMEONE
/// ELSE's message. User A's role in the group is varied per case:
/// - participant  → cannot edit or delete B's message
/// - admin/owner  → can delete B's message
/// - moderator    → can delete B's message
///
/// A throwaway per-run group is used throughout. For the participant/moderator cases the group is owned
/// by B (so A can be a non-owner); for the admin case A owns the group (default seed).
final class GroupMessagePermissionTests: XCTestCase {

    private var app: XCUIApplication!
    private var ctx: SeedData.TestGroupContext?

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedContext = ctx; ctx = nil
        runBlocking { await SeedData.deleteTestGroup(capturedContext) }
    }

    /// A regular participant cannot EDIT another member's message — the Edit option is absent.
    func test_GRP_participantCannotEditOthersMessage() throws {
        let token = openGroupWithBMessage(aScope: "participant")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press on B's message failed")
        XCTAssertFalse(messageOptionPresent(ComponentQueries.MessageOption.edit),
                       "A participant should NOT see Edit on another member's message")
    }

    /// An admin/owner can DELETE another member's message — the placeholder replaces it.
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

    /// A regular participant cannot DELETE another member's message — the Delete option is absent.
    func test_GRP_participantCannotDeleteOthersMessage() throws {
        let token = openGroupWithBMessage(aScope: "participant")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press on B's message failed")
        XCTAssertFalse(messageOptionPresent(ComponentQueries.MessageOption.delete),
                       "A participant should NOT see Delete on another member's message")
    }

    /// A moderator can DELETE another member's message — the placeholder replaces it.
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

    /// Whether an option row is present in the (already-open) message-options popup. A missing option is
    /// the load-bearing assertion for the permission cases, so this must NOT tap — only probe existence.
    private func messageOptionPresent(_ label: String) -> Bool {
        // Confirm the options popup actually RENDERED before probing for a (possibly absent) row: wait for
        // an option that is always present for any message (Copy). Without this, a slow/failed popup would
        // read the restricted option as "absent" and false-pass the negative permission assertion.
        let copy = ComponentQueries.MessageOption.copy
        let popupUp = app.buttons[copy].waitForExistence(timeout: 6) || app.staticTexts[copy].exists
        XCTAssertTrue(popupUp, "Message-options popup did not present — cannot assert '\(label)' visibility")
        return app.buttons[label].exists || app.staticTexts[label].exists
    }

    /// Seed a throwaway group with User A at `aScope` and a message authored by User B, open it, and wait
    /// for B's bubble. Returns the unique token so the caller can long-press exactly that message.
    /// - "admin" → the default seed where A owns the group; otherwise a B-owned group with A at `aScope`.
    private func openGroupWithBMessage(aScope: String) -> String {
        let token = "E2E-gperm\(UUID().uuidString.prefix(8))"
        let context: SeedData.TestGroupContext? = try? runBlocking {
            let created = aScope == "admin"
                ? try await SeedData.createGroupOwnedByA()
                : try await SeedData.createGroupOwnedByBWithAAs(aScope)
            // B authors the message A will act on.
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
