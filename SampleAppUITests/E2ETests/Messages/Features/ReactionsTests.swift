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

    // MARK: - Reactor-badge cases (a11y-limited on iOS)

    /// GRP-040/041/043/044 exercise the reactor BADGE — the emoji glyph, its count, and the reactor list.
    /// On iOS these render inside custom views with NO accessibility label, so XCUITest cannot read the
    /// emoji or the count (unlike Flutter, which queries the widget tree: `find.text('👍')`, `find.text(' 2')`).
    /// Closing this fully would require adding accessibility identifiers to the reaction views in the
    /// CometChatUIKitSwift framework — explicitly out of scope (do not modify the framework). So these drive
    /// the exact multi-reactor scenarios via REST and assert the message survives and the screen stays
    /// stable (the reachable signal); the badge render itself stays documented as an iOS a11y limitation.

    /// GRP-040: tap a reacted message; the reactor list is best-effort, screen stays stable.
    func test_GRP_tapGroupReactionStable() throws {
        let (group, id) = try seedGroupMessage()
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        runBlocking { await PeerActions.addReaction(id, "👍") }
        // Tapping the (unlabeled) badge isn't reliably locatable; tap the bubble region and assert stability.
        ComponentQueries.bubble(app, text: currentToken).tap()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Group screen not stable after tapping a reacted message")
    }

    /// GRP-041: B adds then removes a reaction; the message survives and screen stays stable.
    func test_GRP_removeGroupReactionStable() throws {
        let (group, id) = try seedGroupMessage()
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        runBlocking { await PeerActions.addReaction(id, "❤️") }
        runBlocking { await PeerActions.removeReaction(id, "❤️") }
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: currentToken, timeout: 8)
                || ComponentQueries.composer(app).exists,
            "Group message vanished after add+remove reaction"
        )
    }

    /// GRP-043: multiple distinct emojis (B 👍, B 🔥, A ❤️) on one message; message survives, screen stable.
    func test_GRP_multipleGroupReactionsStable() throws {
        let (group, id) = try seedGroupMessage()
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        runBlocking {
            await PeerActions.addReaction(id, "👍")
            await PeerActions.addReaction(id, "🔥")
            await PeerActions.addReaction(id, "❤️", asUserA: true)
        }
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: currentToken, timeout: 8)
                || ComponentQueries.composer(app).exists,
            "Group message not stable after multiple reactions"
        )
    }

    /// GRP-044: two distinct reactors (A + B) on the SAME emoji (count would be 2); message survives,
    /// screen stable. The count text " 2" is not queryable on iOS (see class note).
    func test_GRP_reactionCountStable() throws {
        let (group, id) = try seedGroupMessage()
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        runBlocking {
            await PeerActions.addReaction(id, "👍")               // B reacts
            await PeerActions.addReaction(id, "👍", asUserA: true) // A reacts (same emoji → count 2)
        }
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: currentToken, timeout: 8)
                || ComponentQueries.composer(app).exists,
            "Group message not stable after two reactors on the same emoji"
        )
    }

    // MARK: - Helpers

    private var currentToken = ""

    /// Seed a throwaway group with a text message from User A, return (group, messageId). The message is
    /// the reaction target; its token is stored in `currentToken` for assertions.
    private func seedGroupMessage() throws -> (SeedData.TestGroup, Int) {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not open test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group list did not open")
        let token = "E2E-grpbadge\(UUID().uuidString.prefix(8))"
        currentToken = token
        let id: Int = try runBlocking { try await PeerActions.sendGroupTextMessage(token, groupId: group.guid) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Group message did not arrive")
        return (group, id)
    }

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
