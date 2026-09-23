import XCTest

/// CometChatNotificationFeed, shown by the sample app as its Notifications tab. The feed's
/// items come from campaigns configured on the app, which the tests cannot create, so these
/// assert the surface the kit always renders: the title, the filter chips, and a settled state
/// — either rows or the documented empty state, never a blank screen.
final class NotificationFeedTests: XCTestCase {

    private var app: XCUIApplication!

    private enum Copy {
        static let title = "Notifications"
        static let emptyTitle = "Nothing here yet"
        static let emptySubtitle = "New activity will appear here when available."
        static let allFilter = "All"
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.notifications),
                      "Notifications tab not reachable")
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    /// Rows or the empty state — the two ways a loaded feed can look.
    private func feedSettled(timeout: TimeInterval = 15) -> Bool {
        waitForCondition(timeout: timeout) {
            self.app.cells.count > 0 || self.app.staticTexts[Copy.emptyTitle].exists
        }
    }

    func test_E2E_FEED_tabShowsFeedTitle() {
        XCTAssertTrue(app.staticTexts[Copy.title].firstMatch.waitForExistence(timeout: 10),
                      "Notification feed title missing")
    }

    func test_E2E_FEED_feedSettlesToRowsOrEmptyState() {
        XCTAssertTrue(feedSettled(), "Feed never showed rows or its empty state")
    }

    func test_E2E_FEED_emptyStateCarriesTitleAndSubtitle() throws {
        XCTAssertTrue(feedSettled(), "Feed never settled")
        guard app.cells.count == 0 else {
            throw XCTSkip("This app has feed items, so the empty state is not shown")
        }
        XCTAssertTrue(app.staticTexts[Copy.emptyTitle].exists, "Empty-state title missing")
        XCTAssertTrue(app.staticTexts[Copy.emptySubtitle].exists, "Empty-state subtitle missing")
    }

    func test_E2E_FEED_allFilterIsOffered() {
        XCTAssertTrue(app.staticTexts[Copy.allFilter].firstMatch.waitForExistence(timeout: 10)
                        || app.buttons[Copy.allFilter].firstMatch.exists,
                      "The All filter chip is missing")
    }

    func test_E2E_FEED_switchingFiltersKeepsFeedUsable() throws {
        XCTAssertTrue(feedSettled(), "Feed never settled")
        let chips = app.staticTexts.allElementsBoundByIndex.filter {
            $0.isHittable && ![Copy.title, Copy.allFilter, Copy.emptyTitle, Copy.emptySubtitle].contains($0.label)
                && $0.frame.minY < app.staticTexts[Copy.allFilter].firstMatch.frame.maxY + 4
                && abs($0.frame.midY - app.staticTexts[Copy.allFilter].firstMatch.frame.midY) < 10
        }
        guard let other = chips.first else { throw XCTSkip("This app offers only the All filter") }
        other.tap()
        XCTAssertTrue(feedSettled(), "Feed did not settle after switching filter to \(other.label)")
        app.staticTexts[Copy.allFilter].firstMatch.tap()
        XCTAssertTrue(feedSettled(), "Feed did not settle after switching back to All")
    }

    func test_E2E_FEED_returningToTabKeepsFeed() {
        XCTAssertTrue(feedSettled(), "Feed never settled")
        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats), "Chats tab not reachable")
        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.notifications),
                      "Could not return to Notifications")
        XCTAssertTrue(app.staticTexts[Copy.title].firstMatch.waitForExistence(timeout: 8)
                        && feedSettled(), "Feed was not intact after returning to the tab")
    }
}
