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

    // MARK: - Structural typing transitions (Wave 6)

    private func openOneToOneWithLiveB() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        try ensureUserBLoggedIn()
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open the 1:1 with User B")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }

    /// The header shows "Typing..." while B types and reverts once B stops — the peer's name
    /// stays put throughout, and the subtitle no longer says Typing.
    func test_RT_TYPE_headerRevertsWhenPeerStopsTyping() throws {
        try openOneToOneWithLiveB()
        runBlocking { await SecondClient.shared.startTyping(toUser: TestConfig.userAUid) }
        XCTAssertTrue(ComponentQueries.waitForTypingIndicator(app, timeout: 10), "Header never showed 'Typing...'")

        runBlocking { await SecondClient.shared.endTyping() }
        XCTAssertTrue(waitForCondition(timeout: 10) { !self.app.staticTexts["Typing..."].exists },
                      "Header kept 'Typing...' after B stopped typing")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].exists, "Header lost the peer's name")
    }

    /// After B stops, an idle window must not bring the indicator back: nothing is typing, so
    /// nothing may say so. The window is well past the kit's own typing debounce.
    func test_RT_TYPE_noIndicatorPersistsAfterIdle() throws {
        try openOneToOneWithLiveB()
        runBlocking { await SecondClient.shared.startTyping(toUser: TestConfig.userAUid) }
        XCTAssertTrue(ComponentQueries.waitForTypingIndicator(app, timeout: 10), "Header never showed 'Typing...'")
        runBlocking { await SecondClient.shared.endTyping() }
        XCTAssertTrue(waitForCondition(timeout: 10) { !self.app.staticTexts["Typing..."].exists },
                      "Header kept 'Typing...' after B stopped typing")

        // Idle: no typing events for 8s. The indicator must stay away the whole time.
        XCTAssertFalse(app.staticTexts["Typing..."].waitForExistence(timeout: 8),
                       "'Typing...' reappeared while the peer was idle")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].exists, "Header lost the peer's name")
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
