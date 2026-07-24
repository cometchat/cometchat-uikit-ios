import XCTest

/// Real incoming typing (REST can't do it): `SecondClient` (live User B) calls `startTyping`; `XCTSkip`s if B can't come up.
final class LiveTypingTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SecondClient.shared.endTyping() }
        runBlocking { await SecondClient.shared.logout() }
        runBlocking { await SeedData.cleanup() }
    }

    func test_RT_TYPE_liveIncomingTypingShows1to1() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        try ensureUserBLoggedIn()

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open the 1:1 with User B"
        )
        // Chat must be open before startTyping — the header viewModel gates on the open uid, dropping earlier frames.
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")

        runBlocking { await SecondClient.shared.startTyping(toUser: TestConfig.userAUid) }
        XCTAssertTrue(
            ComponentQueries.waitForTypingIndicator(app, timeout: 8),
            "Header did not show 'Typing...' from live User B typing"
        )
        runBlocking { await SecondClient.shared.endTyping() }
    }

    func test_RT_TYPE_liveIncomingTypingShowsGroup() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        try ensureUserBLoggedIn()

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not open the test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")

        runBlocking { await SecondClient.shared.startTyping(toGroup: group.guid) }
        XCTAssertTrue(
            ComponentQueries.waitForGroupTypingIndicator(app, name: TestConfig.userBDisplayName, timeout: 8),
            "Header did not show '\(TestConfig.userBDisplayName) is typing...' from live group typing"
        )
        runBlocking { await SecondClient.shared.endTyping() }
    }
}
