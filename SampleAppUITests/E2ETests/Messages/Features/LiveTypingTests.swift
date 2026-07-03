import XCTest

/// The ONE part of typing that REST can't do: a real incoming typing indicator. `SecondClient` hosts a
/// live CometChat client logged in as User B inside this runner process (separate process from the app,
/// so no singleton collision — see `SecondClient`) and calls `startTyping`; we assert the app's header
/// subtitle updates. Everything else typing-related is structural in `TypingIndicatorTests`.
///
/// If B's in-process client can't come up on the busy shared backend, the test `XCTSkip`s rather than
/// failing — this one live capability degrades gracefully and never destabilizes the suite.
final class LiveTypingTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        // Stop any live typing frame and release B's socket so it can't race REST-driven B tests.
        runBlocking { await SecondClient.shared.endTyping() }
        runBlocking { await SecondClient.shared.logout() }
        runBlocking { await SeedData.cleanup() }
    }

    /// User B (live SDK client) types to User A in a 1:1 → header subtitle shows "Typing...".
    func test_RT_TYPE_liveIncomingTypingShows1to1() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        try bringUpUserB()

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open the 1:1 with User B"
        )
        // The chat must be OPEN before startTyping — the header viewModel gates the event on the open
        // conversation's uid, so a typing frame that arrives before the chat is open is dropped.
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")

        runBlocking { await SecondClient.shared.startTyping(toUser: TestConfig.userAUid) }
        XCTAssertTrue(
            ComponentQueries.waitForTypingIndicator(app, timeout: 8),
            "Header did not show 'Typing...' from live User B typing"
        )
        runBlocking { await SecondClient.shared.endTyping() }
    }

    /// User B (live SDK client) types in a group → header shows "<name> is typing...".
    func test_RT_TYPE_liveIncomingTypingShowsGroup() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        try bringUpUserB()

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

    /// Bring User B's in-process client up; skip (not fail) if the busy shared backend won't cooperate.
    private func bringUpUserB() throws {
        do {
            try runBlocking(timeout: 60) { try await SecondClient.shared.ensureLoggedInAsUserB() }
        } catch {
            throw XCTSkip("Second SDK client unavailable: \(error)")
        }
    }
}
