import XCTest

/// Shared setup flows composed from `AppLauncher` + `SeedData` + `SecondClient`.
/// Helpers return values rather than assigning instance state so call sites stay explicit
/// (each test still does `app = ...` / `group = ...`), and `runBlocking` — an `XCTestCase`
/// method — is reachable here where `AppLauncher`'s static context couldn't reach it.
extension XCTestCase {

    /// Seed a 1:1 conversation with User B, launch, open it, and wait for the composer.
    @discardableResult
    func openSeededConversation() -> XCUIApplication {
        try? runBlocking { try await SeedData.createTestConversation() }
        let app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Message list did not open")
        return app
    }

    /// Launch, open an already-seeded group, and wait for the composer.
    @discardableResult
    func openSeededGroup(_ group: SeedData.TestGroup) -> XCUIApplication {
        let app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(openGroupUntilComposerShows(app, named: group.name), "Could not open test group")
        return app
    }

    /// Seed a throwaway group with User B, launch, open it, and wait for the composer.
    /// Returns the created group so the caller can retain it (or `nil` if seeding failed).
    func openSeededGroupWithMember() -> (app: XCUIApplication, group: SeedData.TestGroup?) {
        let group = try? runBlocking { try await SeedData.createTestGroupWithMember() }
        XCTAssertNotNil(group, "Could not create the test group")
        let app = AppLauncher.launchAndWaitForHome()
        if let group {
            XCTAssertTrue(openGroupUntilComposerShows(app, named: group.name), "Could not open the test group")
        }
        return (app, group)
    }

    /// `AppLauncher.openGroup` taps the matching Groups-tab row, but on the busy shared backend
    /// the filtered list can still be reloading under the tap, which then lands on nothing —
    /// the row is found, the composer never appears, and the tab bar is still there. Seen
    /// three times in one session across unrelated classes. One more attempt from the tab
    /// bar covers it; a group that genuinely will not open still fails.
    @discardableResult
    func openGroupUntilComposerShows(_ app: XCUIApplication, named name: String) -> Bool {
        for attempt in 0..<2 {
            guard AppLauncher.openGroup(app, named: name) else { return false }
            if ComponentQueries.composer(app).waitForExistence(timeout: 15) { return true }
            guard attempt == 0, app.tabBars.firstMatch.exists else { return false }
        }
        return false
    }

    /// Log the second SDK client in as User B, skipping the test if it's unavailable.
    func ensureUserBLoggedIn() throws {
        do {
            try runBlocking(timeout: 60) { try await SecondClient.shared.ensureLoggedInAsUserB() }
        } catch {
            throw XCTSkip("Second SDK client unavailable: \(error)")
        }
    }
}
