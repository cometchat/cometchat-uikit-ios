import XCTest

enum AppLauncher {

    static let bundleId = "com.cometchat.sampleapp.ios"

    /// -UITestUID auto-login idempotently establishes User A's session regardless of prior state, so no reset is needed.
    @discardableResult
    static func launch(_ app: XCUIApplication = XCUIApplication()) -> XCUIApplication {
        TestConfig.validate()
        CredentialPreflight.runOnce()
        app.launchArguments = [
            "-UITestMode",
            "-UITestAppID",    TestConfig.appId,
            "-UITestAuthKey",  TestConfig.authKey,
            "-UITestRegion",   TestConfig.region,
            "-UITestUID",      TestConfig.userAUid,
        ]
        app.launch()
        return app
    }

    /// -UITestStartLoggedOut forces the Login route without clearing the SDK's Keychain session; credentials are still injected to skip the credentials screen.
    @discardableResult
    static func launchToLogin(_ app: XCUIApplication = XCUIApplication()) -> XCUIApplication {
        TestConfig.validate()
        CredentialPreflight.runOnce()
        app.launchArguments = [
            "-UITestMode",
            "-UITestStartLoggedOut",
            "-UITestAppID",   TestConfig.appId,
            "-UITestAuthKey", TestConfig.authKey,
            "-UITestRegion",  TestConfig.region,
        ]
        app.launch()
        return app
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
    static func openConversationFromChats(_ app: XCUIApplication, displayName: String, timeout: TimeInterval = 12) -> Bool {
        openConversationWith(app, displayName: displayName, timeout: timeout)
    }

    @discardableResult
    static func openConversationWith(_ app: XCUIApplication, displayName: String, timeout: TimeInterval = 12) -> Bool {
        navigateToTab(app, title: TabLabel.users)
        guard app.cells.firstMatch.waitForExistence(timeout: timeout) else { return false }

        let search = app.searchFields.firstMatch
        if search.waitForExistence(timeout: timeout) {
            search.tap()
            search.typeText(displayName)
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
        search.tap()
        search.typeText(name)

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
