import XCTest

/// Badge count isn't ours to control on the shared backend, so tests assert a POSITIVE badge (not exact 3).
final class UnreadBadgeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_RT_MSG_unreadBadgeIncrements() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()

        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users), "Users tab unavailable")
        try runBlocking { _ = try await PeerActions.sendMultipleMessages(3, prefix: "E2E-unread") }

        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats), "Chats tab unavailable")
        let badge = waitForUnreadBadge(rowNamed: TestConfig.userBDisplayName, timeout: 20)
        XCTAssertNotNil(badge, "No unread badge on B's conversation after new messages arrived while away")
    }

    func test_RT_MSG_unreadBadgeResetsOnOpen() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()

        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users), "Users tab unavailable")
        try runBlocking { _ = try await PeerActions.sendMultipleMessages(3, prefix: "E2E-unread-reset") }
        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats), "Chats tab unavailable")
        XCTAssertNotNil(waitForUnreadBadge(rowNamed: TestConfig.userBDisplayName, timeout: 20),
                        "Precondition failed: unread badge did not appear before reading")

        let bRow = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(bRow.waitForExistence(timeout: 8), "B's conversation row not found")
        bRow.tap()
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
        ComponentQueries.headerBackButton(app)?.tap()

        XCTAssertTrue(
            waitForBadgeCleared(rowNamed: TestConfig.userBDisplayName, timeout: 12),
                      "Unread badge did not clear after opening the conversation"
        )
    }

    /// Badge is the pure-digit (optionally "N+") staticText on `name`'s row; nil if none present.
    private func unreadBadgeLabel(rowNamed name: String) -> String? {
        let nameEl = app.staticTexts[name]
        guard nameEl.exists else { return nil }
        let rowY = nameEl.frame.midY
        let digits = NSPredicate(format: "label MATCHES %@", "^[0-9]{1,3}\\+?$")
        return app.staticTexts.matching(digits).allElementsBoundByIndex
            .first { $0.exists && abs($0.frame.midY - rowY) < 44 }?.label
    }

    private func waitForUnreadBadge(rowNamed name: String, timeout: TimeInterval) -> String? {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if let label = unreadBadgeLabel(rowNamed: name) { return label }
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 0.5)
        } while Date() < deadline
        return nil
    }

    private func waitForBadgeCleared(rowNamed name: String, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if app.staticTexts[name].exists && unreadBadgeLabel(rowNamed: name) == nil { return true }
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 0.5)
        } while Date() < deadline
        return false
    }
}
