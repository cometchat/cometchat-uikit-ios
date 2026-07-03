import XCTest

/// Smoke tests for the Conversations bucket (list shows items, tapping a row opens messages).
///
/// The Chats tab hosts the `CometChatConversations` list; its rows are queried by content (`cells`).
/// Opening a row pushes the message list, whose presence we detect by the composer text view
/// appearing. All located by content (no AX ids). Pure-UI, no peer/seed.
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

    /// The Chats tab shows a conversation list with at least one cell.
    func test_conversationListShowsItems() {
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats),
            "Chats tab did not appear"
        )

        // Conversations sync over the socket after the tab appears, so wait for the first cell.
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 15), "Conversation list showed no cells")
    }

    /// Tapping a conversation opens the message list — signalled by the composer appearing.
    func test_tapConversationOpensMessages() {
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(
            AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats),
            "Chats tab did not appear"
        )

        let firstCell = app.cells.firstMatch
        XCTAssertTrue(firstCell.waitForExistence(timeout: 15), "No conversation to open")
        firstCell.tap()

        // The message list owns the composer text view; the conversation list does not.
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 15),
            "Message list did not open (composer not found)"
        )
    }
}
