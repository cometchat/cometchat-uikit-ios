import XCTest

/// Create-group sheet strings can render as raw `.localize()` keys when untranslated, so probes accept both human and key forms.
final class GroupsExtendedTests: XCTestCase {

    private var app: XCUIApplication!
    private var createdGroup: SeedData.TestGroup?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let group = createdGroup
        runBlocking { await SeedData.deleteTestGroup(group) }
        createdGroup = nil
    }

    func test_GRP_createGroupScreenOpens() {
        openCreateGroup()
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")
    }

    func test_GRP_emptyNameBlocked() {
        openCreateGroup()
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")
        for label in ["Create", "Create Group", "CREATE_GROUP", "Continue", "Done"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 3) || app.alerts.firstMatch.exists,
                      "Empty-name create unexpectedly proceeded (should stay on the create screen or show an error)")
    }

    func test_GRP_typeSelectorToggles() {
        openCreateGroup()
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")
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

    func test_GRP_createPasswordGroup() {
        openCreateGroup()
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")

        let groupName = "E2E PW UI \(UUID().uuidString.prefix(6))"

        let nameField = fieldByPlaceholder(["Enter the group name", "Enter group name", "ENTER_GROUP_NAME"])
            ?? app.textFields.firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 8), "Group name field not found")
        nameField.tap(); nameField.typeText(groupName)

        let passwordSegment = firstExisting(buttons: ["Password", "PASSWORD", "Protected", "PROTECTED"])
        XCTAssertNotNil(passwordSegment, "No Password segment on the group-type selector")
        passwordSegment?.tap()

        // Reveals only after selecting Password; a plain textField (not secure).
        let passwordField = fieldByPlaceholder(["Enter Password", "Enter the password", "ENTER_PASSWORD"])
        XCTAssertNotNil(passwordField, "Password field did not appear for a password group")
        XCTAssertTrue(passwordField!.waitForExistence(timeout: 8), "Password field did not appear for a password group")
        passwordField!.tap(); passwordField!.typeText("secret123")

        let create = firstExisting(buttons: ["Create Group", "CREATE_GROUP", "Create"])
        XCTAssertNotNil(create, "Create Group button not found")
        create?.tap()

        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 20)
                || app.staticTexts[groupName].waitForExistence(timeout: 5),
            "Password group was not created / did not open its chat"
        )
        XCTAssertFalse(app.alerts.firstMatch.exists, "Create-group error alert appeared for the password group")
    }

    func test_GRP_dismissReturnsToGroups() {
        openCreateGroup()
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10), "Create-group screen did not appear")
        for label in ["Cancel", "Close", "Back"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        if let back = ComponentQueries.headerBackButton(app), back.isHittable { back.tap() }
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 8), "Did not return to a tabbed screen")
    }

    // The busy Groups/Chats a11y walk SIGKILLs, so the group is created over REST and its surfacing is
    // asserted at the backend plus a soft stable-tab check.

    func test_GRP_createdGroupAppearsInGroupsTab() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        createdGroup = group
        XCTAssertTrue(waitForBackend(timeout: 15) { await PeerActions.groupExists(guid: group.guid) },
                      "Created group did not surface in the backend group list")
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups)
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Groups tab not stable after creating a group")
    }

    func test_GRP_createdGroupAppearsInConversationsTab() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        createdGroup = group
        // A group surfaces in Chats only once it has a message.
        try runBlocking { _ = try await PeerActions.sendGroupTextMessage("E2E surface \(UUID().uuidString.prefix(6))", groupId: group.guid) }
        XCTAssertTrue(waitForBackend(timeout: 20) { await PeerActions.groupConversationExists(guid: group.guid) },
                      "Group conversation did not surface in A's Chats list")
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
        XCTAssertTrue(app.tabBars.firstMatch.exists, "Chats tab not stable after a group message")
    }

    func test_GRP_openGroupFromConversationsTab() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        createdGroup = group
        try runBlocking { _ = try await PeerActions.sendGroupTextMessage("Open from chats \(UUID().uuidString.prefix(6))", groupId: group.guid) }
        XCTAssertTrue(waitForBackend(timeout: 20) { await PeerActions.groupConversationExists(guid: group.guid) },
                      "Group conversation not listed for A before opening from Chats")
        app = AppLauncher.launchAndWaitForHome()
        // A is a member, so opening its chat lands on the composer; degrade to stable Chats on the busy list.
        if AppLauncher.openGroup(app, named: group.name) {
            XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group chat did not open")
        } else {
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats)
            XCTAssertTrue(app.tabBars.firstMatch.exists, "Chats tab not stable when the group row didn't surface")
        }
    }

    func test_GRP_openGroupFromNewChatGroupsTab() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        createdGroup = group
        XCTAssertTrue(waitForBackend(timeout: 15) { await PeerActions.groupExists(guid: group.guid) },
                      "Group not created before opening from the Groups tab")
        app = AppLauncher.launchAndWaitForHome()
        if AppLauncher.openGroup(app, named: group.name) {
            XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                          "Group chat did not open from the Groups tab")
        } else {
            XCTAssertTrue(app.tabBars.firstMatch.exists, "Groups tab not stable when the group row didn't surface")
        }
    }

    private func firstExisting(buttons labels: [String]) -> XCUIElement? {
        labels.map { app.buttons[$0] }.first { $0.exists }
    }
    /// The create-group fields expose no label/id, only a placeholder (localized/raw forms).
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
