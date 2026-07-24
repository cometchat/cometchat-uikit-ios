import XCTest

/// Each test owns its launch path (launchToLogin vs launchAndWaitForHome), so tests are order-independent.
final class AuthTests: XCTestCase {

    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    func test_validLoginNavigatesToHome() {
        app = AppLauncher.launch()
        AppLauncher.waitForHome(app)

        XCTAssertTrue(
            app.tabBars.buttons[AppLauncher.TabLabel.chats].waitForExistence(timeout: 10),
            "Chats tab not present — home screen did not render after a valid login"
        )
    }

    func test_invalidCredentialsShowsError() {
        app = AppLauncher.launchToLogin()
        XCTAssertTrue(app.buttons[Login.continueButton].waitForExistence(timeout: 15), "Login screen did not appear")

        let uidField = app.textFields.firstMatch
        XCTAssertTrue(uidField.waitForExistence(timeout: 10), "UID text field not found")
        uidField.tap()
        uidField.typeText("e2e-nonexistent-\(UUID().uuidString.prefix(8))")

        app.buttons[Login.continueButton].tap()

        XCTAssertTrue(
            app.alerts[Login.errorAlertTitle].waitForExistence(timeout: 30),
            "Invalid login did not show the error alert"
        )
        XCTAssertFalse(
            app.tabBars.buttons[AppLauncher.TabLabel.chats].exists,
            "Invalid login unexpectedly navigated to Home"
        )
    }

    func test_logoutReturnsToLogin() {
        app = AppLauncher.launchAndWaitForHome()

        // Real logout is a menu-as-primary-action pull-down XCUITest can't open; the DEBUG-only
        // uiTestLogout button (-UITestMode) invokes the same logout path.
        let logout = app.buttons["uiTestLogout"]
        XCTAssertTrue(logout.waitForExistence(timeout: 10), "Test logout button not found")
        logout.tap()

        XCTAssertTrue(
            app.buttons[Login.continueButton].waitForExistence(timeout: 15),
            "Did not return to the Login screen after logout"
        )
    }

    func test_existingSessionSkipsLogin() {
        app = AppLauncher.launchAndWaitForHome()
        app.terminate()

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
