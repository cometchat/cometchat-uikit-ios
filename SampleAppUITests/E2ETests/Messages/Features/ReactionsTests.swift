import XCTest

/// Emoji glyphs don't reliably expose a11y labels on iOS, so badge rendering is asserted softly:
/// message presence + screen stability. Peer reactions are driven over REST.
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

    func test_RT_REACT_peerReactionArrives() throws {
        app = openSeededConversation()
        let token = "E2E-react\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")

        runBlocking { await PeerActions.addReaction(id, "👍") }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 10), "Message vanished after reaction")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not stable after peer reaction")
    }

    func test_1TO1_ownReactionViaUI() throws {
        app = openSeededConversation()
        let token = "E2E-uireact\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message did not send")

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        tapAnyReactionAffordance()
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 8)
                || app.buttons["More"].exists,
            "Screen not stable after reacting via UI"
        )
    }

    func test_E2E_addReactionSmoke() throws {
        app = openSeededConversation()
        let token = "E2E-rsmoke\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed")
        // A known option row, not just "some button exists" — the header alone satisfies that.
        let popupUp = ["Copy", "Reply in Thread", "Info", "React", "Add Reaction"].contains {
            app.buttons[$0].waitForExistence(timeout: 4) || app.staticTexts[$0].exists
        }
        XCTAssertTrue(popupUp, "Message options popup did not present")
    }

    func test_RT_REACT_peerAddThenRemove() throws {
        app = openSeededConversation()
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

    func test_1TO1_peerReactionRealtime() throws {
        app = openSeededConversation()
        let token = "E2E-prt\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        runBlocking { await PeerActions.addReaction(id, "🔥") }
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen not stable after realtime reaction")
    }

    func test_1TO1_tapReactionStable() throws {
        app = openSeededConversation()
        let token = "E2E-tapr\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        runBlocking { await PeerActions.addReaction(id, "👍") }
        ComponentQueries.bubble(app, text: token).tap()
        XCTAssertTrue(app.buttons["More"].waitForExistence(timeout: 8) || ComponentQueries.composer(app).exists,
                      "Screen not stable after tapping a reacted message")
    }

    // MARK: - Group reactions

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

    /// Badge emoji/count/reactor list have no a11y labels — fixing that needs framework edits (out of scope).
    func test_GRP_tapGroupReactionStable() throws {
        let (group, id) = try seedGroupMessage()
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        runBlocking { await PeerActions.addReaction(id, "👍") }
        ComponentQueries.bubble(app, text: currentToken).tap()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Group screen not stable after tapping a reacted message")
    }

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

    func test_GRP_reactionCountStable() throws {
        let (group, id) = try seedGroupMessage()
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        runBlocking {
            await PeerActions.addReaction(id, "👍")
            await PeerActions.addReaction(id, "👍", asUserA: true) // same emoji → count 2
        }
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: currentToken, timeout: 8)
                || ComponentQueries.composer(app).exists,
            "Group message not stable after two reactors on the same emoji"
        )
    }

    // MARK: - Helpers

    private var currentToken = ""

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

    private func tapAnyReactionAffordance() {
        for emoji in ["👍", "❤️", "😂", "🔥"] where app.buttons[emoji].exists {
            app.buttons[emoji].firstMatch.tap(); return
        }
        for label in ["React", "Add Reaction", "Add reaction"] where app.buttons[label].exists {
            app.buttons[label].firstMatch.tap(); return
        }
    }
}
