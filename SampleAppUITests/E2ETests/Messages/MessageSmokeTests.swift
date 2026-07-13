import XCTest

/// Bubbles surface as buttons — assert via `ComponentQueries.waitForBubble`, never raw `staticTexts`.
/// REST seed/cleanup bridge through `runBlocking`; `XCUIApplication.launch()` requires the main thread.
final class MessageSmokeTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    func test_sendTextMessageAppears() throws {
        try runBlocking { try await SeedData.createTestConversation() }

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )

        // Unique token guards against matching a stale bubble on the shared backend.
        let token = "E2E-1to1-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)

        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: token, timeout: 12),
            "Sent message '\(token)' did not appear"
        )
    }

    func test_composerClearsAfterSend() throws {
        try runBlocking { try await SeedData.createTestConversation() }

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )

        let token = "E2E-clear-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)

        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: token, timeout: 12),
            "Sent message '\(token)' did not appear"
        )
        XCTAssertTrue(
            ComponentQueries.composerIsEmpty(app),
            "Composer did not clear after send"
        )
    }

    func test_headerShowsName() throws {
        try runBlocking { try await SeedData.createTestConversation() }

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )

        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 15),
            "Message list did not open (composer not found)"
        )
        XCTAssertTrue(
            app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 10),
            "Header did not show \(TestConfig.userBDisplayName)"
        )
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

    // Mention resolution isn't asserted — only the trailing plain words.
    func test_1TO1_messageWithMentionSends() throws {
        app = openSeededConversation()
        let tail = "mention-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "@\(TestConfig.userBDisplayName) hi \(tail)")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 12),
                      "Mention message tail did not render")
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

    // Full blocked-send behavior lives in the block suite; only screen stability here.
    func test_1TO1_screenStableForBlockedCase() throws {
        app = openSeededConversation()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Message screen not stable")
    }
}
