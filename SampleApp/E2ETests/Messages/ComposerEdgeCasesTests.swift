import XCTest

/// 1:1 composer content edge cases — whitespace-only, long body, URL, markdown, send-button activation.
/// Bubbles surface as buttons — assert via `ComponentQueries.waitForBubble`, never raw `staticTexts`.
/// REST seed/cleanup bridge through `runBlocking`; `XCUIApplication.launch()` requires the main thread.
final class ComposerEdgeCasesTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_1TO1_whitespaceMessageBlocked() throws {
        app = openSeededConversation()
        let composer = ComponentQueries.composer(app)
        composer.tap()
        composer.typeText("     ")
        let send = app.buttons["Send"]
        if send.exists && send.isHittable { send.tap() }
        XCTAssertFalse(app.buttons["     "].exists, "A whitespace-only bubble was unexpectedly sent")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer vanished after blank send attempt")
    }

    func test_1TO1_longTextMessageSends() throws {
        app = openSeededConversation()
        let tail = "longtail-\(UUID().uuidString.prefix(8))"
        let body = String(repeating: "A", count: 1024) + tail
        ComponentQueries.typeAndSend(app, text: body)
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Long message tail '\(tail)' did not render")
    }

    func test_1TO1_messageWithURLSends() throws {
        app = openSeededConversation()
        let tail = "url-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "see https://cometchat.com \(tail)")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 12),
                      "URL message tail did not render")
    }

    // No underscores in test text — the formatter strips `_x_` as italic; use `**bold**`.
    func test_1TO1_markdownBoldSends() throws {
        app = openSeededConversation()
        let word = "boldword\(UUID().uuidString.prefix(6))"
        ComponentQueries.typeAndSend(app, text: "**\(word)**")
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: word, timeout: 12)
                || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", word)).firstMatch.exists,
            "Bold word '\(word)' did not render"
        )
    }

    func test_1TO1_sendButtonActivatesOnText() throws {
        app = openSeededConversation()
        let composer = ComponentQueries.composer(app)
        composer.tap()
        composer.typeText("hello")
        XCTAssertTrue(ComponentQueries.sendButton(app).waitForExistence(timeout: 5),
                      "Send affordance not present after typing")
    }
}
