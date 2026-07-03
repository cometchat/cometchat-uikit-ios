import XCTest

/// Launches SampleApp with test credentials injected via launch arguments.
///
/// Test independence: there is **no** shared `XCUIApplication`. Each test owns its own instance
/// Isolation strategy: most tests need only "logged in as User A", which `launch()` guarantees
/// idempotently via `-UITestUID` auto-login. Tests that need a logged-out start use `launchToLogin()`,
/// which routes to Login via `-UITestStartLoggedOut`.
enum AppLauncher {

    /// SampleApp bundle identifier (the built app installs as this id).
    static let bundleId = "com.cometchat.internal.swift"

    /// Launch the app auto-logged-in as User A and return the running app handle.
    /// `-UITestUID` triggers auto-login, which idempotently establishes User A's session
    /// regardless of any prior state — so no reset is needed for logged-in tests.
    @discardableResult
    static func launch(_ app: XCUIApplication = XCUIApplication()) -> XCUIApplication {
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

    /// Launch the app showing the Login screen. `-UITestStartLoggedOut` makes the app route to Login
    /// regardless of any persisted session (no uninstall needed); credentials are still injected so
    /// we skip the credentials screen. This does not clear the SDK's Keychain session — it only
    /// forces the Login screen — which is all the current logged-out test needs.
    @discardableResult
    static func launchToLogin(_ app: XCUIApplication = XCUIApplication()) -> XCUIApplication {
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

    /// Wait for the Conversations tab to appear — signals home screen is ready.
    static func waitForHome(_ app: XCUIApplication, timeout: TimeInterval = 45) {
        let tab = app.tabBars.firstMatch
        XCTAssertTrue(tab.waitForExistence(timeout: timeout), "Home screen did not appear within \(timeout)s")
    }

    /// Launch and wait for home in one call — use this in setUp.
    @discardableResult
    static func launchAndWaitForHome(_ app: XCUIApplication = XCUIApplication()) -> XCUIApplication {
        launch(app)
        waitForHome(app)
        return app
    }

    /// Visible (localized, title-cased) tab labels — the content XCUITest sees for each home tab.
    enum TabLabel {
        static let chats         = "Chats"
        static let calls         = "Calls"
        static let users         = "Users"
        static let groups        = "Groups"
        static let notifications = "Notifications"
    }

    /// Navigate to a home tab by its visible title (e.g. `AppLauncher.TabLabel.users`). Located by
    /// content since SampleApp sets no accessibility identifiers.
    /// - Returns: true if the tab resolved and was tapped.
    @discardableResult
    static func navigateToTab(_ app: XCUIApplication, title: String, timeout: TimeInterval = 10) -> Bool {
        let tab = app.tabBars.buttons[title]
        guard tab.waitForExistence(timeout: timeout) else { return false }
        tab.tap()
        return true
    }

    /// Tap the first cell in the current list (conversation, user, or group).
    static func openFirstCell(_ app: XCUIApplication) {
        let cell = app.cells.firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 8), "No cells found in list")
        cell.tap()
    }

    /// Go back one level in the navigation stack.
    static func goBack(_ app: XCUIApplication) {
        app.navigationBars.buttons.firstMatch.tap()
    }

    /// Opens a seeded 1:1 by peer display name. Historically this opened from the Chats tab (the seeded
    /// convo used to land at the top), but the shared backend is now busy — the convo can be far down
    /// among hundreds of activity-sorted cells, and the Chats search field pushes a separate screen whose
    /// field doesn't reliably take focus. The robust path is the Users tab's in-place search
    /// (`openConversationWith`, the canonical open-conversation flow), which this now delegates to. Name kept for
    /// call-site compatibility.
    @discardableResult
    static func openConversationFromChats(_ app: XCUIApplication, displayName: String, timeout: TimeInterval = 12) -> Bool {
        openConversationWith(app, displayName: displayName, timeout: timeout)
    }

    /// Opens (or starts) a 1:1 via the Users tab, filtering the long/unsorted list with its in-place
    /// search field before tapping — the reliable path when the shared backend is busy (the canonical
    /// open-conversation flow). Users search filters in place (unlike Chats search, which pushes a separate screen).
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

    /// Open a group chat deterministically by display name. The Groups list is long and
    /// activity-sorted, so the target may be far off-screen (a found-but-offscreen cell has no valid
    /// hit point). Use the list's search field to filter the list down to the match, then tap it.
    /// - Returns: true if a matching cell was found and tapped.
    @discardableResult
    static func openGroup(_ app: XCUIApplication, named name: String, timeout: TimeInterval = 12) -> Bool {
        navigateToTab(app, title: TabLabel.groups)

        let search = app.searchFields.firstMatch
        guard search.waitForExistence(timeout: timeout) else { return false }
        search.tap()
        search.typeText(name)

        // After filtering, the match renders near the top and on-screen. Locate the cell by its name
        // staticText so we don't tap an empty leading/section cell.
        let cell = app.cells.containing(.staticText, identifier: name).firstMatch
        guard cell.waitForExistence(timeout: timeout), cell.isHittable else { return false }
        cell.tap()
        return true
    }

    /// Tap the Groups navbar's create-group button. It's a SampleApp-owned trailing `+` that is
    /// unlabeled, so it's located positionally as the last navbar button. Centralized so this positional
    /// locator lives in one place. Waits for the navbar to lay out first.
    /// - Returns: true if a navbar button was found and tapped.
    @discardableResult
    static func tapCreateGroupButton(_ app: XCUIApplication, timeout: TimeInterval = 5) -> Bool {
        let navButtons = app.navigationBars.buttons
        guard navButtons.firstMatch.waitForExistence(timeout: timeout) else { return false }
        navButtons.element(boundBy: navButtons.count - 1).tap()
        return true
    }
}
