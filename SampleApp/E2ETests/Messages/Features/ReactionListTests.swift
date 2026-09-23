import XCTest

/// The reaction-list sheet: existing tests assert tapping a reaction is *stable*; this asserts the
/// sheet actually names who reacted. Sheet source: catalog E2E-038 testTapReactionShowsList.
final class ReactionListTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_1TO1_reactionListNamesTheReactor() throws {
        app = openSeededConversation()
        let token = "rlist\(UUID().uuidString.prefix(6).lowercased())"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage("E2E \(token)") }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20),
                      "Message did not arrive")
        try runBlocking { try await PeerActions.addReaction(id, "🔥") }

        let chip = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "🔥")).firstMatch
        let chipText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "🔥")).firstMatch
        let deadline = Date().addingTimeInterval(15)
        while Date() < deadline, !chip.exists, !chipText.exists {
            _ = chip.waitForExistence(timeout: 0.5)
        }
        XCTAssertTrue(chip.exists || chipText.exists, "Reaction chip did not appear on the bubble")
        (chip.exists ? chip : chipText).tap()

        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 10),
                      "Reaction list sheet does not name the reactor")
    }
}
