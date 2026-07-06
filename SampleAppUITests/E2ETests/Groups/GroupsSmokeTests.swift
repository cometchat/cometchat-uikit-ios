import XCTest

/// Group name is an inner `staticText` (cell's own label is empty); the long activity-sorted list may put
/// a target off-screen, so `openGroup` filters via the search field first. Target: "SuperGroup" (User A owns).
final class GroupsSmokeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func test_groupsListShowsItems() {
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups),
            "Groups tab did not appear"
        )

        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Groups list showed no cells")
    }

    func test_tapGroupOpensMessages() {
        AppLauncher.launchAndWaitForHome(app)

        XCTAssertTrue(
            AppLauncher.openGroup(app, named: TestConfig.groupDisplayName),
            "Could not open \(TestConfig.groupDisplayName)"
        )

        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 15),
            "Group message list did not open (composer not found)"
        )
    }

    func test_createGroupScreenAppears() {
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups),
            "Groups tab did not appear"
        )
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Groups list did not render")

        XCTAssertTrue(AppLauncher.tapCreateGroupButton(app), "No navbar buttons on Groups")

        XCTAssertTrue(
            ComponentQueries.createGroupScreenVisible(app, timeout: 10),
            "Create-group screen did not appear"
        )
    }

    func test_sendGroupMessageAppears() {
        AppLauncher.launchAndWaitForHome(app)

        XCTAssertTrue(
            AppLauncher.openGroup(app, named: TestConfig.groupDisplayName),
            "Could not open \(TestConfig.groupDisplayName)"
        )

        let token = "E2E-grp-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)

        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: token, timeout: 12),
            "Sent group message '\(token)' did not appear"
        )
    }
}
