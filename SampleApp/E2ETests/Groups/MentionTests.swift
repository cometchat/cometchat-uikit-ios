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

    // MARK: - Helpers

    private func openGroup() {
        let testGroup = try? runBlocking { try await SeedData.createTestGroupWithMember() }
        group = testGroup
        XCTAssertNotNil(testGroup, "Could not create the test group")
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: testGroup!.name), "Could not open the test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")
    }
}
