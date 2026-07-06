import XCTest

/// Unread-count badge on the conversation list — appears when messages arrive while A is away, and
/// clears once A opens the conversation. The badge is
/// the one thing on a conversation row rendered as a bare integer (`CometChatBadge: UILabel`), so it's
/// located as a pure-digit staticText on the same row as the peer's name.
///
/// The A↔B 1:1 lives on the shared backend, so its prior unread count isn't ours to control — the test
/// asserts a POSITIVE badge appeared (not an exact 3), and that it clears after reading.
final class UnreadBadgeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    /// Messages arriving while A sits on another tab surface an unread badge on B's conversation row.
    func test_RT_MSG_unreadBadgeIncrements() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()

        // A is not viewing the conversation while B sends.
        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users), "Users tab unavailable")
        try runBlocking { _ = try await PeerActions.sendMultipleMessages(3, prefix: "E2E-unread") }

        // New activity bumps the conversation up the Chats list with an unread badge.
        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats), "Chats tab unavailable")
        let badge = waitForUnreadBadge(rowNamed: TestConfig.userBDisplayName, timeout: 20)
        XCTAssertNotNil(badge, "No unread badge on B's conversation after new messages arrived while away")
    }

    /// Opening the conversation reads it; the unread badge on its row then clears.
    func test_RT_MSG_unreadBadgeResetsOnOpen() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()

        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.users), "Users tab unavailable")
        try runBlocking { _ = try await PeerActions.sendMultipleMessages(3, prefix: "E2E-unread-reset") }
        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats), "Chats tab unavailable")
        XCTAssertNotNil(waitForUnreadBadge(rowNamed: TestConfig.userBDisplayName, timeout: 20),
                        "Precondition failed: unread badge did not appear before reading")

        // Open the conversation from the Chats row (marks it read), then return to the list.
        let bRow = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(bRow.waitForExistence(timeout: 8), "B's conversation row not found")
        bRow.tap()
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
        ComponentQueries.headerBackButton(app)?.tap()

        // Back on the list, B's row no longer carries an unread badge.
        XCTAssertTrue(
            waitForBadgeCleared(rowNamed: TestConfig.userBDisplayName, timeout: 12),
                      "Unread badge did not clear after opening the conversation"
        )
    }

    // MARK: - Helpers

    /// The unread badge is the pure-digit (optionally "N+") staticText on the same row as `name`. Returns
    /// nil if no such badge is present on that row right now.
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
