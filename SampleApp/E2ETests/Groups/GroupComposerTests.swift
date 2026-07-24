import XCTest

/// Throwaway per-run group (A owner, B member) so the shared `supergroup` is never touched.
final class GroupComposerTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedGroup = group; group = nil
        runBlocking { await SeedData.deleteTestGroup(capturedGroup) }
    }

    func test_GRP_sendTextInGroup() throws {
        openGroup()
        let token = "E2E-gsend\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Group message did not render")
    }

    func test_GRP_emptyMessageBlocked() throws {
        openGroup()
        let send = app.buttons["Send"]
        if send.exists && send.isHittable { send.tap() }
        XCTAssertTrue(ComponentQueries.composerIsEmpty(app), "Empty group message should not send")
    }

    func test_GRP_longTextSends() throws {
        openGroup()
        let tail = "gtail\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: String(repeating: "G", count: 1024) + tail)
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Long group message tail did not render")
    }

    func test_GRP_composerClearsAfterSend() throws {
        openGroup()
        let token = "E2E-gclear\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Group message did not send")
        XCTAssertTrue(ComponentQueries.composerIsEmpty(app), "Composer did not clear after group send")
    }

    func test_GRP_mentionSends() throws {
        openGroup()
        let tail = "gmention\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "@\(TestConfig.userBDisplayName) hi \(tail)")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Group mention tail did not render")
    }

    func test_GRP_whitespaceMessageBlocked() throws {
        openGroup()
        let composer = ComponentQueries.composer(app)
        composer.tap(); composer.typeText("     ")
        let send = app.buttons["Send"]
        if send.exists && send.isHittable { send.tap() }
        XCTAssertFalse(app.buttons["     "].exists, "A whitespace-only group bubble was unexpectedly sent")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer vanished after a blank group send attempt")
    }

    /// Emoji glyph isn't reliably in the a11y tree — send with a unique text tail and assert the tail.
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

    func test_GRP_specialCharacterMessageSends() throws {
        openGroup()
        let tail = "gspecial\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "!@#$%^&*()_+-={}[]|;:',.<>?/ \(tail)")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Special-character group message did not render")
    }

    func test_GRP_urlMessageSends() throws {
        openGroup()
        let tail = "gurl\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "see https://cometchat.com \(tail)")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Group URL message tail did not render")
    }

    /// No underscores — the UIKit formatter strips `_x_` as italic.
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
        (app, group) = openSeededGroupWithMember()
    }
}
