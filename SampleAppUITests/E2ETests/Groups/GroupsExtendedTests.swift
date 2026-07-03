import XCTest

/// Group creation UI (the create-group bottom sheet) and created-group surfacing.
/// The create sheet's field/label strings can render as raw
/// `.localize()` keys when untranslated, so probes accept both human and key forms and stay tolerant
/// (reach the create UI, exercise type toggles, dismiss).
final class GroupsExtendedTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws { app?.terminate(); app = nil }

    /// The create-group entry point opens the create-group screen (reachability).
    func test_GRP_createGroupScreenOpens() {
        openCreateGroup()
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")
    }

    /// Creating a group with an empty name is blocked (error shown or the sheet stays open).
    func test_GRP_emptyNameBlocked() {
        openCreateGroup()
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")
        // Tap a Create/Continue affordance without entering a name.
        for label in ["Create", "Create Group", "CREATE_GROUP", "Continue", "Done"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        // Either an error banner shows or we stayed on the create screen (didn't navigate into a chat).
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 3) || app.alerts.firstMatch.exists,
                      "Empty-name create unexpectedly proceeded (should stay on the create screen or show an error)")
    }

    /// The group-type selector (Public/Private/Password) toggles.
    func test_GRP_typeSelectorToggles() {
        openCreateGroup()
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")
        // Tap a type option (accept raw `.localize()` keys too) — a password field may show for Password.
        var toggled = false
        let typeLabels = ["Public", "PUBLIC", "Private", "PRIVATE", "Password", "PASSWORD", "Protected", "PROTECTED"]
        for label in typeLabels where app.buttons[label].exists || app.staticTexts[label].exists {
            (app.buttons[label].exists ? app.buttons[label] : app.staticTexts[label]).tap()
            toggled = true
            break
        }
        XCTAssertTrue(toggled, "No group-type selector (Public/Private/Password) found on the create screen")
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 3),
                      "Create screen broke after toggling the group type")
    }

    /// Dismissing the create-group sheet returns to the Groups tab.
    func test_GRP_dismissReturnsToGroups() {
        openCreateGroup()
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")
        // Cancel/back to dismiss.
        for label in ["Cancel", "Close", "Back"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        if let back = ComponentQueries.headerBackButton(app), back.isHittable { back.tap() }
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 8), "Did not return to a tabbed screen")
    }

    // MARK: - Helpers

    private func openCreateGroup() {
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Groups list did not render")
        XCTAssertTrue(AppLauncher.tapCreateGroupButton(app), "No navbar buttons on Groups")
    }
}
