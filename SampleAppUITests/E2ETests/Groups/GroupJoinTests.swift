import XCTest

/// Joining a password-protected group.
/// A throwaway password group is created (owned by User B) that User A is NOT a member of; A finds it in
/// the Groups tab and taps it, which presents the "Join Group" sheet (title "Join Group", a text field
/// with placeholder "Enter Password", and a "Join Group" submit button — confirmed via diagnostic dump).
///
/// - Correct password → the group opens (message list / composer appears) AND A becomes a member on the
///   backend.
/// - Wrong password → the join is blocked: the group does NOT open (no composer) and A is NOT a member.
final class GroupJoinTests: XCTestCase {

    private static let password = "secret123"

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedGroup = group; group = nil
        // The password group is owned by B — delete on behalf of B.
        runBlocking { if let capturedGroup { await PeerActions.deleteGroup(guid: capturedGroup.guid, owner: TestConfig.userBUid) } }
    }

    /// Join with the correct password → the group opens and A joins on the backend.
    func test_GRP_joinPasswordGroupCorrect() throws {
        openJoinSheet()
        enterPassword(Self.password)
        tapJoin()

        // The group opens: the message composer appears.
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Group did not open after entering the correct password")

        // Backend truth: A is now a member. Read as admin — A's membership is the thing under test.
        guard let testGroup = group else { return XCTFail("no group") }
        let joined = waitForBackend(timeout: 15) {
            let members = try await PeerActions.groupMemberUIDs(guid: testGroup.guid, as: nil)
            return members.contains(TestConfig.userAUid)
        }
        XCTAssertTrue(joined, "User A did not join the group on the backend after a correct password")
    }

    /// Join with a wrong password → the join is blocked (group does not open; A is not a member).
    func test_GRP_joinPasswordGroupWrong() throws {
        openJoinSheet()
        enterPassword("wrong-\(UUID().uuidString.prefix(6))")
        tapJoin()

        // The group must NOT open — no composer. The join sheet stays (or an error shows), and crucially
        // A is not admitted. Assert the composer never appears within a reasonable window.
        XCTAssertFalse(ComponentQueries.composer(app).waitForExistence(timeout: 8),
                       "Group opened despite a wrong password")

        // Backend truth: A did NOT join.
        guard let testGroup = group else { return XCTFail("no group") }
        let members = (try? runBlocking { try await PeerActions.groupMemberUIDs(guid: testGroup.guid, as: nil) }) ?? []
        XCTAssertFalse(members.contains(TestConfig.userAUid),
                       "User A joined the group despite a wrong password")
    }

    // MARK: - Helpers

    /// Seed the password group, open the Groups tab, find it, and tap it to present the Join Group sheet.
    private func openJoinSheet() {
        let testGroup = try? runBlocking { try await SeedData.createPasswordGroupWithoutA(password: Self.password) }
        group = testGroup
        XCTAssertNotNil(testGroup, "Could not create the password group")
        app = AppLauncher.launchAndWaitForHome()

        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups)
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 12), "Groups search field missing")
        search.tap(); search.typeText(testGroup!.name)
        let cell = app.cells.containing(.staticText, identifier: testGroup!.name).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 12), "Password group not found in the Groups list")
        cell.tap()

        // The Join Group sheet presents its password field.
        XCTAssertTrue(
            app.textFields["Enter Password"].waitForExistence(timeout: 10)
                || app.textFields.firstMatch.waitForExistence(timeout: 5),
            "Join Group password sheet did not appear"
        )
    }

    private func enterPassword(_ enteredPassword: String) {
        let field = app.textFields["Enter Password"].exists ? app.textFields["Enter Password"] : app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 8), "Password field missing")
        field.tap()
        field.typeText(enteredPassword)
    }

    /// Tap the "Join Group" submit button (the hittable button, distinct from the sheet's title label).
    private func tapJoin() {
        let join = app.buttons.matching(identifier: "Join Group").allElementsBoundByIndex.first { $0.exists && $0.isHittable }
            ?? app.buttons["Join Group"]
        XCTAssertTrue(join.waitForExistence(timeout: 6), "Join Group button missing")
        join.tap()
    }
}
