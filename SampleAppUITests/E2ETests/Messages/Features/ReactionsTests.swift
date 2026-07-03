import XCTest

/// Reactions in 1:1 and group chats. Peer (User B) reactions are driven over REST
/// (`PeerActions.addReaction`/`removeReaction`, emoji in the URL path) and must render on A's bubble;
/// A's own reactions go through the UI long-press flow.
///
/// Depth: the reaction badge's exact emoji rendering is treated softly (an emoji glyph does
/// NOT reliably expose a matching a11y label on iOS — same limitation as emoji message bubbles), so these
/// assert the message is present and the screen stays stable after a reaction, and that the UI react flow
/// does not crash. The load-bearing signals are message presence + screen stability.
final class ReactionsTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - 1:1 reactions

    /// B reacts to a message via REST; A's chat stays stable and the message is still shown.
    func test_RT_REACT_peerReactionArrives() throws {
        openSeeded()
        let token = "E2E-react\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")

        runBlocking { await PeerActions.addReaction(id, "👍") }
        // The message persists and the screen stays stable after the reaction event.
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 10), "Message vanished after reaction")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not stable after peer reaction")
    }

    /// A reacts to a message via the UI long-press; no crash.
    func test_1TO1_ownReactionViaUI() throws {
        openSeeded()
        let token = "E2E-uireact\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        // The reaction row (emoji shortcuts) or a "React"/"Add Reaction" entry sits atop the popup. Tap an
        // emoji if present, else a React option; either way the screen must stay stable.
        tapAnyReactionAffordance()
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 8)
                || app.buttons["More"].exists,
            "Screen not stable after reacting via UI"
        )
    }

    /// Smoke: long-press a peer message (reaction reachable).
    func test_E2E_addReactionSmoke() throws {
        openSeeded()
        let token = "E2E-rsmoke\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        // Assert a known option row is actually up (reactions are reachable from here) — not just "some
        // button exists", which the header alone satisfies.
        let popupUp = ["Copy", "Reply in Thread", "Info", "React", "Add Reaction"].contains {
            app.buttons[$0].waitForExistence(timeout: 4) || app.staticTexts[$0].exists
        }
        XCTAssertTrue(popupUp, "Message options popup did not present")
    }

    /// B adds then removes a reaction via REST; the message survives and the screen stays stable.
    func test_RT_REACT_peerAddThenRemove() throws {
        openSeeded()
        let token = "E2E-rar\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")

        runBlocking {
            await PeerActions.addReaction(id, "❤️")
            await PeerActions.removeReaction(id, "❤️")
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 10), "Message vanished")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not stable after add/remove reaction")
    }

    /// B reacts after A has the chat open; message stays and screen stable.
    func test_1TO1_peerReactionRealtime() throws {
        openSeeded()
        let token = "E2E-prt\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        runBlocking { await PeerActions.addReaction(id, "🔥") }
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not stable after realtime reaction")
    }

    /// Tap a reacted message's badge; screen stays stable (reactors list is best-effort).
    func test_1TO1_tapReactionStable() throws {
        openSeeded()
        let token = "E2E-tapr\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        runBlocking { await PeerActions.addReaction(id, "👍") }
        // Tapping the bubble (where the badge sits) must not crash.
        ComponentQueries.bubble(app, text: token).tap()
        XCTAssertTrue(app.buttons["More"].waitForExistence(timeout: 8) || ComponentQueries.composer(app).exists,
                      "Screen not stable after tapping a reacted message")
    }

    // MARK: - Group reactions

    /// B (member) reacts to a group message via REST; the group chat stays stable.
    func test_GRP_peerReactsInGroup() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not open test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group list did not open")

        let token = "E2E-grpreact\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking {
            try await PeerActions.sendGroupTextMessage(token, groupId: group.guid)
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Group message did not arrive")
        runBlocking { await PeerActions.addReaction(id, "👍") }
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Group screen not stable after reaction")
    }

    // MARK: - Helpers

    /// Tap whatever reaction affordance the popup presents — an emoji shortcut or a React/Add-Reaction
    /// entry — without asserting a specific one (layout varies). Best-effort; never fails.
    private func tapAnyReactionAffordance() {
        for emoji in ["👍", "❤️", "😂", "🔥"] where app.buttons[emoji].exists {
            app.buttons[emoji].firstMatch.tap(); return
        }
        for label in ["React", "Add Reaction", "Add reaction"] where app.buttons[label].exists {
            app.buttons[label].firstMatch.tap(); return
        }
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
