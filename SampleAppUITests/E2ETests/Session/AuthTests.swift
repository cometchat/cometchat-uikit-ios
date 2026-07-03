import XCTest

/// Authentication flows.
///
/// Assertions are screen-presence only: each test proves the app routes to the right screen after an
/// auth action, not anything deeper.
///
/// Tests are synchronous (`XCUIApplication.launch()` needs the main thread). Each test owns its launch
/// path — logged-out via `launchToLogin`, logged-in via `launchAndWaitForHome` — so they are
/// order-independent.
final class AuthTests: XCTestCase {

    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    // MARK: - Valid login navigates to home

    func test_validLoginNavigatesToHome() {
        // `-UITestUID` auto-logs-in User A; home is ready when the tab bar appears.
        app = AppLauncher.launch()
        AppLauncher.waitForHome(app)

        XCTAssertTrue(
            app.tabBars.buttons[AppLauncher.TabLabel.chats].waitForExistence(timeout: 10),
            "Chats tab not present — home screen did not render after a valid login"
        )
    }

    // MARK: - Invalid credentials show an error

    func test_invalidCredentialsShowsError() {
        // Start on the Login screen, then drive the UI by hand with a bad UID.
        app = AppLauncher.launchToLogin()
        XCTAssertTrue(app.buttons[Login.continueButton].waitForExistence(timeout: 15), "Login screen did not appear")

        let uidField = app.textFields.firstMatch
        XCTAssertTrue(uidField.waitForExistence(timeout: 10), "UID text field not found")
        uidField.tap()
        uidField.typeText("e2e-nonexistent-\(UUID().uuidString.prefix(8))")

        app.buttons[Login.continueButton].tap()

        // A failed login surfaces the error alert (presentSomethingWentWrongAlert), located by title.
        XCTAssertTrue(
            app.alerts[Login.errorAlertTitle].waitForExistence(timeout: 30),
            "Invalid login did not show the error alert"
        )
        // Login did not succeed → Home never appeared.
        XCTAssertFalse(
            app.tabBars.buttons[AppLauncher.TabLabel.chats].exists,
            "Invalid login unexpectedly navigated to Home"
        )
    }

    // MARK: - Logout returns to login

    func test_logoutReturnsToLogin() {
        app = AppLauncher.launchAndWaitForHome()

        // The avatar's real logout is a `showsMenuAsPrimaryAction` pull-down on a custom-view bar
        // button, which XCUITest can't open. The app exposes a DEBUG-only
        // `uiTestLogout` bar button under -UITestMode that invokes the SAME logout path.
        let logout = app.buttons["uiTestLogout"]
        XCTAssertTrue(logout.waitForExistence(timeout: 10), "Test logout button not found")
        logout.tap()

        XCTAssertTrue(
            app.buttons[Login.continueButton].waitForExistence(timeout: 15),
            "Did not return to the Login screen after logout"
        )
    }

    // MARK: - Existing session skips login on relaunch

    func test_existingSessionSkipsLogin() {
        // First launch establishes and persists the SDK session.
        app = AppLauncher.launchAndWaitForHome()
        app.terminate()

        // Relaunch the SAME install: with a persisted session, auto-login short-circuits
        // (`getLoggedInUser() != nil`) and routing goes straight to Home — the Login screen never
        // appears. Reuse the same args so the only difference is the now-persisted session.
        AppLauncher.launch(app)

        XCTAssertTrue(
            app.tabBars.buttons[AppLauncher.TabLabel.chats].waitForExistence(timeout: 30),
            "Home did not appear on relaunch with an existing session"
        )
        XCTAssertFalse(
            app.buttons[Login.continueButton].exists,
            "Login screen appeared on relaunch despite an existing session"
        )
    }
}

private enum Login {
    static let continueButton = "Continue"
    static let uidPlaceholder = "Enter Your UID"
    static let errorAlertTitle = "Something went wrong!"
}
