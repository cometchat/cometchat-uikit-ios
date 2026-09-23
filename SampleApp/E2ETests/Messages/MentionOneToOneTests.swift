import XCTest

/// @-mention composer behaviour in a 1:1 (the existing group tests only cover the group picker
/// and @All). The 1:1 suggestion list is populated from the app's USERS, not just the peer, so a
/// bare "@" shows whoever comes first and the test user is not necessarily among them — every
/// case types "@" plus a filter fragment. Incoming mentions arrive as `<@uid:…>` syntax and must
/// render as a highlighted @Name.
/// Sheet sources: Sanity MEN-01, MEN-02, MEN-07, MEN-08.
final class MentionOneToOneTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - Shared steps

    /// The first word of User B's display name. Typed after the "@", it narrows the suggestion
    /// list to the peer regardless of which users `TestSecrets` names — a literal fragment here
    /// (this was "E2E", for the provisioned "E2E …" users) silently hides the peer as soon as
    /// someone runs the suite with different credentials, and every case fails with
    /// "suggestions did not appear" for a reason that has nothing to do with mentions.
    private static var mentionFilter: String {
        String(TestConfig.userBDisplayName.split(separator: " ").first ?? "")
    }

    private func typeInComposer(_ text: String) {
        let field = ComponentQueries.composer(app)
        XCTAssertTrue(field.waitForExistence(timeout: 10), "Composer not found")
        field.tap()
        field.typeText(text)
    }

    /// Open the mention picker filtered to the e2e users.
    private func typeMentionQuery() {
        typeInComposer("@" + Self.mentionFilter)
    }

    /// The conversation HEADER also shows the peer's name, so a bare `staticTexts[name]` always
    /// matches and every assertion here would pass (or fail) for the wrong reason. The suggestion
    /// list sits above the composer, well below the header, so match a suggestion cell — or a
    /// label low enough on screen that it cannot be the header.
    private func suggestionFor(_ name: String) -> XCUIElement? {
        let cell = app.cells.containing(.staticText, identifier: name).firstMatch
        if cell.exists, cell.frame.minY > 160 { return cell }
        let label = app.staticTexts.matching(NSPredicate(format: "label == %@", name))
            .allElementsBoundByIndex
            .first { $0.exists && $0.frame.minY > 160 }
        return label
    }

    private func waitForSuggestion(_ name: String, timeout: TimeInterval = 10) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if suggestionFor(name) != nil { return true }
            _ = app.cells.firstMatch.waitForExistence(timeout: 0.5)
        }
        return suggestionFor(name) != nil
    }

    // MARK: - Cases

    /// MEN-01 — typing "@" surfaces the mention suggestion list with the peer's name.
    func test_1TO1_atSignShowsSuggestions() throws {
        app = openSeededConversation()
        typeMentionQuery()
        XCTAssertTrue(waitForSuggestion(TestConfig.userBDisplayName),
                      "Mention suggestions did not list \(TestConfig.userBDisplayName)")
    }

    /// MEN-02 — the list narrows while typing and a non-matching query removes the entry.
    func test_1TO1_suggestionsFilterWhileTyping() throws {
        app = openSeededConversation()
        typeMentionQuery()
        XCTAssertTrue(waitForSuggestion(TestConfig.userBDisplayName), "Suggestions did not appear")
        ComponentQueries.composer(app).typeText("zzzqx")
        // Existence-only here: `suggestionFor` reads the cell's frame after checking it exists,
        // and the cell is being removed at exactly this moment, so that two-step read races the
        // list and fails on "no matches for query" rather than on the assertion.
        let peerCell = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName)
            .firstMatch
        let deadline = Date().addingTimeInterval(6)
        while Date() < deadline, peerCell.exists {
            _ = app.cells.firstMatch.waitForExistence(timeout: 0.5)
        }
        XCTAssertFalse(peerCell.exists, "Suggestion list did not filter out a non-matching query")
    }

    /// MEN-01 — selecting a suggestion inserts the mention and it sends as a highlighted token.
    func test_1TO1_selectSuggestionInsertsAndSends() throws {
        app = openSeededConversation()
        typeMentionQuery()
        XCTAssertTrue(waitForSuggestion(TestConfig.userBDisplayName), "Suggestions did not appear")
        suggestionFor(TestConfig.userBDisplayName)?.tap()
        let value = (ComponentQueries.composer(app).value as? String) ?? ""
        XCTAssertTrue(value.contains(TestConfig.userBDisplayName),
                      "Mention not inserted into the composer: \(value)")
        ComponentQueries.composer(app).typeText("ping \(UUID().uuidString.prefix(6))")
        ComponentQueries.sendButton(app).tap()
        XCTAssertTrue(
            ComponentQueries.waitForBubbleContaining(app, substring: TestConfig.userBDisplayName, timeout: 15),
            "Sent mention bubble missing the mentioned name")
    }

    /// MEN-07 — deleting the "@" and retyping it re-opens the suggestion list.
    func test_1TO1_deleteAndRetypeAtReopensSuggestions() throws {
        app = openSeededConversation()
        typeMentionQuery()
        XCTAssertTrue(waitForSuggestion(TestConfig.userBDisplayName),
                      "Suggestions did not appear the first time")
        let field = ComponentQueries.composer(app)
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue,
                              count: Self.mentionFilter.count + 1))
        field.typeText("@" + Self.mentionFilter)
        XCTAssertTrue(waitForSuggestion(TestConfig.userBDisplayName),
                      "Suggestions did not reappear after delete + retype")
    }

    /// MEN-08 — two mentions coexist in one message.
    func test_1TO1_multipleMentionsInOneMessage() throws {
        app = openSeededConversation()
        typeMentionQuery()
        XCTAssertTrue(waitForSuggestion(TestConfig.userBDisplayName), "Suggestions did not appear")
        suggestionFor(TestConfig.userBDisplayName)?.tap()
        let field = ComponentQueries.composer(app)
        field.typeText("and @" + Self.mentionFilter)
        // In a 1:1 the second suggestion may be self; fall back to B if self isn't offered.
        _ = waitForSuggestion(TestConfig.userADisplayName, timeout: 6)
        let target = suggestionFor(TestConfig.userADisplayName) ?? suggestionFor(TestConfig.userBDisplayName)
        XCTAssertNotNil(target, "Second mention suggestion missing")
        target?.tap()
        field.typeText("done")
        ComponentQueries.sendButton(app).tap()
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: "done", timeout: 15),
                      "Message with multiple mentions did not send")
    }

    /// Receiver side — an incoming `<@uid:…>` mention renders as @Name, never as raw syntax.
    func test_1TO1_incomingMentionRendersHighlighted() throws {
        app = openSeededConversation()
        let token = "mnt\(UUID().uuidString.prefix(6).lowercased())"
        try runBlocking {
            _ = try await PeerActions.sendTextMessage("<@uid:\(TestConfig.userAUid)> \(token)")
        }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20),
                      "Mention message did not arrive")
        let raw = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS %@", "<@uid:")).firstMatch
        XCTAssertFalse(raw.exists, "Incoming mention rendered as raw <@uid:…> syntax")
        XCTAssertTrue(
            ComponentQueries.waitForBubbleContaining(app, substring: TestConfig.userADisplayName, timeout: 5)
                || ComponentQueries.waitForBubbleContaining(app, substring: "you", timeout: 2),
            "Incoming mention did not render the mentioned name")
    }
}
