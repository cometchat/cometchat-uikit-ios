import XCTest

/// Group @-mention picker coverage. Throwaway per-run group (A owner, B member) so the shared
/// `supergroup` is never touched. Typing `@` opens a suggestion table; the group form carries an
/// `@all` row ("@all  (Notify everyone in this group)") ABOVE the member rows — the 1:1 form omits it.
/// The picker is a second table alongside the message list, so locate its rows by content, not index.
final class MentionTests: XCTestCase {

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

    // The @all row's label is a parenthetical form, so match by prefix rather than an exact string.
    private let atAllRow = NSPredicate(format: "label BEGINSWITH[c] '@all'")

    // Picker shows the group members AND an @all row after typing @.
    func test_GRP_mentionsPickerShowsMembersAndAll() throws {
        openGroup()
        let composer = ComponentQueries.composer(app)
        composer.tap()
        composer.typeText("@")

        let atAll = app.staticTexts.containing(atAllRow).firstMatch
        XCTAssertTrue(atAll.waitForExistence(timeout: 8), "Mention picker did not surface an @all row")

        // A group member (User B) is offered alongside @all.
        XCTAssertTrue(
            app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 6),
            "Mention picker did not list the group member \(TestConfig.userBDisplayName)"
        )
    }

    // Selecting @all inserts the mention; the message then sends and renders (resolution itself not asserted).
    func test_GRP_atAllMentionSends() throws {
        openGroup()
        let composer = ComponentQueries.composer(app)
        composer.tap()
        composer.typeText("@")

        let atAll = app.staticTexts.containing(atAllRow).firstMatch
        XCTAssertTrue(atAll.waitForExistence(timeout: 8), "Mention picker did not surface an @all row to tap")
        atAll.tap()

        let tail = "gatall\(UUID().uuidString.prefix(8))"
        composer.typeText(" \(tail)")
        let send = ComponentQueries.sendButton(app)
        XCTAssertTrue(send.waitForExistence(timeout: 5), "Send button did not appear")
        send.tap()

        XCTAssertTrue(
            ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
            "@all group message tail did not render"
        )
    }

    /// Wave 6 — tapping a member's @mention in a group bubble opens that member's 1:1 chat
    /// (the sample app's `CometChatMentionsFormatter` tap handler pushes `MessagesVC(user:)`).
    /// The message is composed so the mention is its first token, and the tap lands on the
    /// leading edge of the bubble where that token renders.
    func test_GRP_tappingMentionOpensMentionedUsersChat() throws {
        openGroup()
        let composer = ComponentQueries.composer(app)
        composer.tap()
        composer.typeText("@" + String(TestConfig.userBDisplayName.split(separator: " ").first ?? ""))
        // The header shows the GROUP's name here, so B's name can only be the picker row.
        let suggestion = app.staticTexts[TestConfig.userBDisplayName].firstMatch
        XCTAssertTrue(suggestion.waitForExistence(timeout: 8), "Mention picker did not offer \(TestConfig.userBDisplayName)")
        suggestion.tap()

        let tail = "mtap\(UUID().uuidString.prefix(6).lowercased())"
        composer.typeText(" \(tail)")
        ComponentQueries.sendButton(app).tap()
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Mention message did not render")

        let bubble = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", tail)).firstMatch.exists
            ? app.buttons.matching(NSPredicate(format: "label CONTAINS %@", tail)).firstMatch
            : app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", tail)).firstMatch
        XCTAssertTrue(bubble.waitForExistence(timeout: 5), "Mention bubble not found for tapping")
        bubble.coordinate(withNormalizedOffset: CGVector(dx: 0.08, dy: 0.5)).tap()

        // The pushed 1:1 shows B's name in its header and no longer the group's name.
        XCTAssertTrue(waitForCondition(timeout: 12) {
            self.app.staticTexts[TestConfig.userBDisplayName].exists
                && !self.app.staticTexts[self.group?.name ?? ""].exists
        }, "Tapping the @mention did not open \(TestConfig.userBDisplayName)'s chat")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10),
                      "The mentioned user's chat has no composer")
    }

    // MARK: - Helpers

    private func openGroup() {
        // Surface the seeding error: `try?` reported "Could not create the test group" for a
        // whole run without saying why.
        var testGroup: SeedData.TestGroup?
        do { testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() } }
        catch { XCTFail("Could not create the test group: \(error)") }
        group = testGroup
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(openGroupUntilComposerShows(app, named: testGroup!.name), "Could not open the test group")
    }
}
