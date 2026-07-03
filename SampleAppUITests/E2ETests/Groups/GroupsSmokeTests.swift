import XCTest

/// Smoke tests for the Groups bucket (list, open group, create group, send in group).
///
/// `CometChatGroups` is a framework list embedded in the Groups tab; rows are queried by content
/// (`cells`). Group cells expose the name as an inner `staticText` (the cell's own label is empty),
/// and the list is long + activity-sorted, so a target may be far off-screen with no valid hit point.
/// `AppLauncher.openGroup` therefore filters via the list's search field before tapping. Opening a
/// group pushes the message list, detected by the composer appearing. The create-group entry point is
/// the Groups navbar's trailing button (a SampleApp-owned `+`), unlabeled, located positionally. All
/// located by content. Tests target `TestConfig.groupDisplayName` ("SuperGroup"), which
/// User A owns and can post in.
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

    /// The Groups tab shows a list with at least one group cell.
    func test_groupsListShowsItems() {
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups),
            "Groups tab did not appear"
        )

        // Groups sync over the network after the tab appears, so wait for the first cell to render.
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Groups list showed no cells")
    }

    /// Tapping a group opens its message list — signalled by the composer appearing.
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

    /// Tapping the Groups navbar's create button opens the create-group screen.
    func test_createGroupScreenAppears() {
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups),
            "Groups tab did not appear"
        )
        // Wait for the list so the navbar's create button is laid out.
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Groups list did not render")

        // The create button is the Groups navbar's trailing button (SampleApp-owned `+`, unlabeled).
        XCTAssertTrue(AppLauncher.tapCreateGroupButton(app), "No navbar buttons on Groups")

        // The create-group sheet shows a "New Group" title, a group-name field, and a "Create Group"
        // button. Any one appearing confirms the screen — assert presence only.
        XCTAssertTrue(
            ComponentQueries.createGroupScreenVisible(app, timeout: 10),
            "Create-group screen did not appear"
        )
    }

    /// User A sends a unique message into the group; the bubble renders.
    func test_sendGroupMessageAppears() {
        AppLauncher.launchAndWaitForHome(app)

        XCTAssertTrue(
            AppLauncher.openGroup(app, named: TestConfig.groupDisplayName),
            "Could not open \(TestConfig.groupDisplayName)"
        )

        // Unique token guards against matching a stale bubble on the shared group.
        let token = "E2E-grp-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)

        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: token, timeout: 12),
            "Sent group message '\(token)' did not appear"
        )
    }
}
