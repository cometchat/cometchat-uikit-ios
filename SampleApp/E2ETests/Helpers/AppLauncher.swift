import XCTest

enum AppLauncher {

    static let bundleId = "com.cometchat.sampleapp.ios"

    /// -UITestUID auto-login idempotently establishes User A's session regardless of prior state, so no reset is needed.
    @discardableResult
    static func launch(_ app: XCUIApplication = XCUIApplication()) -> XCUIApplication {
        TestConfig.validate()
        CredentialPreflight.runOnce()
        setLaunchArguments(app, [
            "-UITestMode",
            "-UITestAppID",    TestConfig.appId,
            "-UITestAuthKey",  TestConfig.authKey,
            "-UITestRegion",   TestConfig.region,
            "-UITestUID",      TestConfig.userAUid,
        ])
        app.launch()
        return app
    }

    /// -UITestStartLoggedOut forces the Login route without clearing the SDK's Keychain session; credentials are still injected to skip the credentials screen.
    @discardableResult
    static func launchToLogin(_ app: XCUIApplication = XCUIApplication()) -> XCUIApplication {
        TestConfig.validate()
        CredentialPreflight.runOnce()
        setLaunchArguments(app, [
            "-UITestMode",
            "-UITestStartLoggedOut",
            "-UITestAppID",   TestConfig.appId,
            "-UITestAuthKey", TestConfig.authKey,
            "-UITestRegion",  TestConfig.region,
        ])
        app.launch()
        return app
    }

    /// The harness arguments go first; anything the caller put on `app.launchArguments` before
    /// launching (the accessibility audits' `-UIPreferredContentSizeCategoryName …`) is kept
    /// after them. This used to be a plain assignment, which silently threw those away — so
    /// every "largest text size" audit was in fact running at the default size.
    private static func setLaunchArguments(_ app: XCUIApplication, _ base: [String]) {
        let extra = app.launchArguments.filter { !base.contains($0) }
        app.launchArguments = base + extra
    }

    static func waitForHome(_ app: XCUIApplication, timeout: TimeInterval = 45) {
        let home = app.tabBars.firstMatch
        XCTAssertTrue(home.waitForExistence(timeout: timeout), "Home screen did not appear within \(timeout)s")
    }

    @discardableResult
    static func launchAndWaitForHome(_ app: XCUIApplication = XCUIApplication()) -> XCUIApplication {
        launch(app)
        waitForHome(app)
        return app
    }

    enum TabLabel {
        static let chats         = "Chats"
        static let calls         = "Calls"
        static let users         = "Users"
        static let groups        = "Groups"
        static let notifications = "Notifications"
    }

    @discardableResult
    static func navigateToTab(_ app: XCUIApplication, title: String, timeout: TimeInterval = 10) -> Bool {
        let tab = app.tabBars.buttons[title]
        guard tab.waitForExistence(timeout: timeout) else { return false }
        tab.tap()
        return true
    }

    static func openFirstCell(_ app: XCUIApplication) {
        let cell = app.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 8), "No cells found in list")
        cell.tap()
    }

    static func goBack(_ app: XCUIApplication) {
        app.navigationBars.buttons.firstMatch.tap()
    }

    /// Name kept for call-site compatibility; opens via Users search because the Chats-first path is flaky on the busy shared backend.
    @discardableResult
    /// Type `text` into a list search field, replacing whatever it already holds. The Users and
    /// Groups searches keep their last query across tab switches, so typing straight into one
    /// lands at the caret and yields a garbled query ("9e0405E2E Group 069e0405" was one) and an
    /// empty list — which read as "could not reopen the group / the 1:1" in the rapid-switching
    /// case. Clears via the search bar's own control when it exists, else select-all + delete.
    static func replaceSearchText(_ search: XCUIElement, with text: String) {
        search.tap()
        if let current = search.value as? String, !current.isEmpty, current != "Search" {
            let clear = search.buttons["Clear text"].firstMatch
            if clear.exists {
                clear.tap()
                search.tap()
            } else {
                search.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: current.count))
            }
        }
        search.typeText(text)
    }

    static func openConversationFromChats(_ app: XCUIApplication, displayName: String, timeout: TimeInterval = 12) -> Bool {
        openConversationWith(app, displayName: displayName, timeout: timeout)
    }

    @discardableResult
    static func openConversationWith(_ app: XCUIApplication, displayName: String, timeout: TimeInterval = 12) -> Bool {
        navigateToTab(app, title: TabLabel.users)
        guard app.cells.firstMatch.waitForExistence(timeout: timeout) else { return false }

        let search = app.searchFields.firstMatch
        if search.waitForExistence(timeout: timeout) {
            replaceSearchText(search, with: displayName)
        }
        let cell = app.cells.containing(.staticText, identifier: displayName).firstMatch
        guard cell.waitForExistence(timeout: timeout) else { return false }
        cell.tap()
        return true
    }

    /// The Groups list is activity-sorted and long — an offscreen match has no hit point — so filter via search first.
    @discardableResult
    static func openGroup(_ app: XCUIApplication, named name: String, timeout: TimeInterval = 12) -> Bool {
        navigateToTab(app, title: TabLabel.groups)

        let search = app.searchFields.firstMatch
        guard search.waitForExistence(timeout: timeout) else { return false }
        replaceSearchText(search, with: name)

        let cell = app.cells.containing(.staticText, identifier: name).firstMatch
        guard cell.waitForExistence(timeout: timeout), cell.isHittable else { return false }
        cell.tap()
        return true
    }

    /// The create-group "+" is unlabeled, so it's located positionally as the last navbar button.
    @discardableResult
    static func tapCreateGroupButton(_ app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        let navButtons = app.navigationBars.buttons
        guard navButtons.firstMatch.waitForExistence(timeout: timeout) else { return false }
        navButtons.element(boundBy: navButtons.count - 1).tap()
        return true
    }
}
