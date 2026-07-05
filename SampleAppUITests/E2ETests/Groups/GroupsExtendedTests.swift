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

    /// GRP-001: create a PASSWORD-protected group end-to-end via the UI. Enter a unique name, select the
    /// PASSWORD segment (which reveals the password field), enter a password, tap Create Group. On success
    /// the sheet dismisses and opens the new group's chat — assert the composer appears (and the group
    /// name shows in the header). This is a real end-to-end assertion: on failure the create screen shows
    /// an error alert and the composer never appears. (The other create tests only reach the create sheet;
    /// this one actually creates. Field/button strings can render as raw `.localize()` keys, so probes
    /// accept both human and key forms.)
    func test_GRP_createPasswordGroup() {
        openCreateGroup()
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")

        let groupName = "E2E PW UI \(UUID().uuidString.prefix(6))"

        // Name — the field is a textField with placeholder "Enter the group name" (confirmed on device).
        let nameField = fieldByPlaceholder(["Enter the group name", "Enter group name", "ENTER_GROUP_NAME"])
            ?? app.textFields.firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 8), "Group name field not found")
        nameField.tap(); nameField.typeText(groupName)

        // Select the Password type (a UISegmentedControl segment surfaces as a button).
        let passwordSegment = firstExisting(buttons: ["Password", "PASSWORD", "Protected", "PROTECTED"])
        XCTAssertNotNil(passwordSegment, "No Password segment on the group-type selector")
        passwordSegment?.tap()

        // The password field reveals only after selecting Password. It's a plain textField (NOT secure)
        // with placeholder "Enter Password" (confirmed on device) — the second textField on the screen.
        let passwordField = fieldByPlaceholder(["Enter Password", "Enter the password", "ENTER_PASSWORD"])
        XCTAssertNotNil(passwordField, "Password field did not appear for a password group")
        XCTAssertTrue(passwordField!.waitForExistence(timeout: 8), "Password field did not appear for a password group")
        passwordField!.tap(); passwordField!.typeText("secret123")

        // Create.
        let create = firstExisting(buttons: ["Create Group", "CREATE_GROUP", "Create"])
        XCTAssertNotNil(create, "Create Group button not found")
        create?.tap()

        // Success: the sheet dismisses and opens the new group's message list.
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 20)
                || app.staticTexts[groupName].waitForExistence(timeout: 5),
            "Password group was not created / did not open its chat"
        )
        // And an error alert must NOT be showing (would indicate the create failed).
        XCTAssertFalse(app.alerts.firstMatch.exists, "Create-group error alert appeared for the password group")
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

    /// First existing element among the given labels, for each element kind (tolerant to raw `.localize()` keys).
    private func firstExisting(buttons labels: [String]) -> XCUIElement? {
        labels.map { app.buttons[$0] }.first { $0.exists }
    }
    /// A text field matched by its placeholder value (the create-group fields expose no label/id, only a
    /// placeholder). Accepts several candidate placeholders (localized/raw forms).
    private func fieldByPlaceholder(_ placeholders: [String]) -> XCUIElement? {
        for field in app.textFields.allElementsBoundByIndex where field.exists {
            if let ph = field.placeholderValue, placeholders.contains(ph) { return field }
        }
        return nil
    }

    private func openCreateGroup() {
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups)
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Groups list did not render")
        XCTAssertTrue(AppLauncher.tapCreateGroupButton(app), "No navbar buttons on Groups")
    }
}
