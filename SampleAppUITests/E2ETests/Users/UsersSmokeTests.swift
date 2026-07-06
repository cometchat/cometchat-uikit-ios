import XCTest

final class UsersSmokeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func test_usersListShowsItems() {
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users),
            "Users tab did not appear"
        )

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15), "Users list showed no cells")
    }
}
