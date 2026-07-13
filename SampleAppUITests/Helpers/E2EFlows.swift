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
        XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not open test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Group list did not open")
        return app
    }

    /// Seed a throwaway group with User B, launch, open it, and wait for the composer.
    /// Returns the created group so the caller can retain it (or `nil` if seeding failed).
    func openSeededGroupWithMember() -> (app: XCUIApplication, group: SeedData.TestGroup?) {
        let group = try? runBlocking { try await SeedData.createTestGroupWithMember() }
        XCTAssertNotNil(group, "Could not create the test group")
        let app = AppLauncher.launchAndWaitForHome()
        if let group {
            XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not open the test group")
            XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                          "Group message list did not open")
        }
        return (app, group)
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
