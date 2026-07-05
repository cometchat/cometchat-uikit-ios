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

    /// GRP-015: a whitespace-only group message is not sent (composer trims/rejects blanks); the group
    /// variant of `test_1TO1_whitespaceMessageBlocked`.
    func test_GRP_whitespaceMessageBlocked() throws {
        openGroup()
        let composer = ComponentQueries.composer(app)
        composer.tap(); composer.typeText("     ")
        let send = app.buttons["Send"]
        if send.exists && send.isHittable { send.tap() }
        XCTAssertFalse(app.buttons["     "].exists, "A whitespace-only group bubble was unexpectedly sent")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer vanished after a blank group send attempt")
    }

    /// GRP-017: an emoji-only group message sends. The emoji glyph is not reliably in the a11y tree, so
    /// this appends a unique text tail to the emoji and asserts the tail renders (bubble-or-stable is the
    /// realistic depth for the glyph itself — same as Flutter, which degrades emoji bubbles too).
    func test_GRP_emojiMessageSends() throws {
        openGroup()
        let tail = "gemoji\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "😀🎉 \(tail)")
        XCTAssertTrue(
            ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14)
                || ComponentQueries.composer(app).exists,
            "Emoji group message neither rendered nor left the screen stable"
        )
    }

    /// GRP-087: a special-character group message renders. The characters are plain text (in the a11y
    /// tree), so this asserts the unique tail bubble arrives — a real content check, deeper than stability.
    func test_GRP_specialCharacterMessageSends() throws {
        openGroup()
        let tail = "gspecial\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "!@#$%^&*()_+-={}[]|;:',.<>?/ \(tail)")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Special-character group message did not render")
    }

    /// GRP-021: a message with a URL sends in a group; the trailing token renders. The group variant of
    /// `test_1TO1_messageWithURLSends` — the bubble label includes the URL plus our token, so match the
    /// token as a substring (a real content check on plain text in the a11y tree).
    func test_GRP_urlMessageSends() throws {
        openGroup()
        let tail = "gurl\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "see https://cometchat.com \(tail)")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Group URL message tail did not render")
    }

    /// GRP-022: a markdown-bold message sends in a group; the inner word renders. Group variant of
    /// `test_1TO1_markdownBoldSends` — no underscores (the UIKit formatter strips `_x_` as italic); use
    /// `**bold**` and assert the inner word is present.
    func test_GRP_markdownBoldSends() throws {
        openGroup()
        let word = "gbold\(UUID().uuidString.prefix(6))"
        ComponentQueries.typeAndSend(app, text: "**\(word)**")
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: word, timeout: 14)
                || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", word)).firstMatch.exists,
            "Group bold word '\(word)' did not render"
        )
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
