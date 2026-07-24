import XCTest

final class GroupJoinTests: XCTestCase {

    private static let password = "secret123"

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedGroup = group; group = nil
        // The password group is owned by B — delete on behalf of B.
        runBlocking { if let capturedGroup { await PeerActions.deleteGroup(guid: capturedGroup.guid, owner: TestConfig.userBUid) } }
    }

    func test_GRP_joinPasswordGroupCorrect() throws {
        openJoinSheet()
        enterPassword(Self.password)
        tapJoin()

        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Group did not open after entering the correct password")

        guard let testGroup = group else { return XCTFail("no group") }
        let joined = waitForBackend(timeout: 15) {
            let members = try await PeerActions.groupMemberUIDs(guid: testGroup.guid, as: nil)
            return members.contains(TestConfig.userAUid)
        }
        XCTAssertTrue(joined, "User A did not join the group on the backend after a correct password")
    }

    func test_GRP_joinPasswordGroupWrong() throws {
        openJoinSheet()
        enterPassword("wrong-\(UUID().uuidString.prefix(6))")
        tapJoin()

        XCTAssertFalse(ComponentQueries.composer(app).waitForExistence(timeout: 8),
                       "Group opened despite a wrong password")

        guard let testGroup = group else { return XCTFail("no group") }
        let members = (try? runBlocking { try await PeerActions.groupMemberUIDs(guid: testGroup.guid, as: nil) }) ?? []
        XCTAssertFalse(members.contains(TestConfig.userAUid),
                       "User A joined the group despite a wrong password")
    }

    // MARK: - Helpers

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
