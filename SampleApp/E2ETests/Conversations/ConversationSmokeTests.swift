import XCTest

/// Message-list presence is detected by the composer text view appearing.
final class ConversationSmokeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
    }

    func test_conversationListShowsItems() {
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats),
            "Chats tab did not appear"
        )

        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Conversation list showed no cells")
    }

    func test_tapConversationOpensMessages() {
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats),
            "Chats tab did not appear"
        )

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15), "No conversation to open")
        firstCell.tap()

        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 15),
            "Message list did not open (composer not found)"
        )
    }
}
