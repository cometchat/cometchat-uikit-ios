import XCTest

/// Smoke tests for the Users bucket (list, user-detail, search).
///
/// `CometChatUsers` is a framework list component embedded in the Users tab — its rows are queried
/// by content (`cells`). All elements here are located by content (no AX ids). Pure-UI, no peer/seed.
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

    /// The Users tab shows a list with at least one user cell.
    func test_usersListShowsItems() {
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users),
            "Users tab did not appear"
        )

        // Users load over the network after the tab appears, so wait for the first cell to render.
        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15), "Users list showed no cells")
    }
}
