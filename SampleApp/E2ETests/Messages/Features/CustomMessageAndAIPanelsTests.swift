import XCTest

/// Two receive-side structural rows from the Flutter kit's integration suite.
///
/// **Custom message.** The sample app registers no template for an app-defined custom type,
/// and the kit's default `MessagesRequest` is scoped to the data source's registered types
/// (`getAllMessageTypes()`), so such a message is never fetched at all — it neither renders nor
/// reaches the "not supported" bubble (that branch is only for fetched types without a
/// template, e.g. the retired form). Measured on 2026-09-19: the seeded custom message left no
/// trace in the group. The contract pinned here is therefore that a peer's unregistered custom
/// message is filtered out cleanly: a text sent right after it still renders, no raw payload
/// leaks, and the chat stays usable. An app that wants such messages shown registers a template.
///
/// **AI panels.** `enableConversationStarters` and `enableSmartReplies` are both OFF in the
/// sample app, so the structural expectation is ABSENCE. The smart-replies panel has a title
/// ("Suggest a reply") and both panels share an error label, which is what can be asserted;
/// a populated starters panel exposes no label of its own on iOS, so its presence — were the
/// feature on — could not be asserted without an identifier on `CometChatAIConversationStarter`.
final class CustomMessageAndAIPanelsTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let captured = group; group = nil
        runBlocking {
            await SeedData.deleteTestGroup(captured)
            await SeedData.cleanup()
        }
    }

    private enum Copy {
        static let notSupported = "This message type is not supported"
        static let suggestReply = "Suggest a reply"
        static let aiError = "Something went wrong"
    }

    // MARK: - Custom message

    func test_GRP_customMessageFromPeerIsFilteredOutCleanly() throws {
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = created
        let marker = "cust\(UUID().uuidString.prefix(6).lowercased())"
        let after = "after\(UUID().uuidString.prefix(6).lowercased())"
        try runBlocking {
            _ = try await PeerActions.sendCustomMessage(type: "e2e_custom",
                                                        customData: ["marker": marker, "kind": "e2e"],
                                                        receiver: created.guid, receiverType: "group")
            _ = try await PeerActions.sendGroupTextMessage("E2E \(after)", groupId: created.guid)
        }
        app = openSeededGroup(created)
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: after, timeout: 20),
                      "The text sent after the custom message did not render")
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", marker)).firstMatch.exists,
                       "Raw custom data leaked into the list as text")
        XCTAssertFalse(app.staticTexts[Copy.notSupported].exists,
                       "An unregistered custom type reached the list as an unsupported bubble — the fetch is no longer scoped to registered types")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer missing after the custom message")
    }

    // MARK: - AI panels (feature off → absent)

    /// An empty chat opens with no conversation-starter panel: no starter error label, and the
    /// list's own empty state is what fills the screen.
    func test_GRP_AI_conversationStartersAbsentWhenFeatureOff() throws {
        let created = try runBlocking { try await SeedData.createEmptyTestGroup() }
        group = created
        app = openSeededGroup(created)
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format: "label BEGINSWITH %@", Copy.aiError)).firstMatch
                        .waitForExistence(timeout: 4),
                       "An AI panel error label is shown in an empty chat with starters off")
        XCTAssertFalse(app.staticTexts[Copy.suggestReply].exists,
                       "A smart-replies panel is shown in an empty chat")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer missing on the empty chat")
    }

    /// After a peer message arrives, no smart-replies panel appears (feature off), and the chat
    /// stays usable.
    func test_1TO1_AI_smartRepliesAbsentAfterPeerMessageWhenFeatureOff() throws {
        app = openSeededConversation()
        let token = "smart\(UUID().uuidString.prefix(6).lowercased())"
        try runBlocking { _ = try await PeerActions.sendTextMessage("E2E \(token)") }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20),
                      "Peer message did not arrive")
        XCTAssertFalse(app.staticTexts[Copy.suggestReply].waitForExistence(timeout: 5),
                       "A smart-replies panel appeared although the feature is off")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer missing after the peer message")
    }
}
