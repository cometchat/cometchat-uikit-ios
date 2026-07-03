import XCTest

/// Sending messages in a group. Uses a throwaway
/// per-run group (User A owner, User B member) so the shared `supergroup` is never touched. Mirrors the
/// 1:1 send-variant depth: unique tokens, bubble presence, composer-clears.
final class GroupComposerTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedGroup = group; group = nil
        runBlocking { await SeedData.deleteTestGroup(capturedGroup) }
    }

    /// Send text in a group; the bubble renders.
    func test_GRP_sendTextInGroup() throws {
        openGroup()
        let token = "E2E-gsend\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Group message did not render")
    }

    /// Empty message cannot be sent in a group.
    func test_GRP_emptyMessageBlocked() throws {
        openGroup()
        let send = app.buttons["Send"]
        if send.exists && send.isHittable { send.tap() }
        XCTAssertTrue(ComponentQueries.composerIsEmpty(app), "Empty group message should not send")
    }

    /// Long text sends in a group; the tail renders.
    func test_GRP_longTextSends() throws {
        openGroup()
        let tail = "gtail\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: String(repeating: "G", count: 1024) + tail)
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Long group message tail did not render")
    }

    /// Composer clears after a successful group send.
    func test_GRP_composerClearsAfterSend() throws {
        openGroup()
        let token = "E2E-gclear\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Group message did not send")
        XCTAssertTrue(ComponentQueries.composerIsEmpty(app), "Composer did not clear after group send")
    }

    /// A mention message sends in a group; trailing words render.
    func test_GRP_mentionSends() throws {
        openGroup()
        let tail = "gmention\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "@\(TestConfig.userBDisplayName) hi \(tail)")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Group mention tail did not render")
    }

    // MARK: - Helpers

    private func openGroup() {
        let testGroup = try? runBlocking { try await SeedData.createTestGroupWithMember() }
        group = testGroup
        XCTAssertNotNil(testGroup, "Could not create the test group")
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: testGroup!.name), "Could not open the test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")
    }
}
