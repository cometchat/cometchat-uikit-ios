import XCTest

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
}
