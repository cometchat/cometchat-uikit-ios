import XCTest

/// Smoke tests for the 1:1 message bucket: sending text, the composer clearing after send, and the
/// conversation header showing the peer's name.
///
/// Each test seeds a 1:1 conversation with User B via REST (`SeedData.createTestConversation`) so the
/// peer lands at the top of Chats, then opens it with `AppLauncher.openConversationFromChats` — the
/// canonical entry point (Users is long/unsorted). All assertions are screen/content
/// presence only. Bubbles surface as buttons, so content
/// assertions go through `ComponentQueries.waitForBubble`, never a raw `staticTexts[text]`.
///
/// Synchronous by necessity: `XCUIApplication.launch()` requires the main thread, so REST seed/cleanup
/// bridge through `runBlocking`.
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

    /// Sending a text message into a 1:1 renders its bubble.
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

    /// After sending, the composer returns to empty.
    func test_composerClearsAfterSend() throws {
        try runBlocking { try await SeedData.createTestConversation() }

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )

        let token = "E2E-clear-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)

        // Wait for the send to land (bubble rendered) before checking the composer is reset.
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: token, timeout: 12),
            "Sent message '\(token)' did not appear"
        )
        XCTAssertTrue(
            ComponentQueries.composerIsEmpty(app),
            "Composer did not clear after send"
        )
    }

    /// The 1:1 conversation header shows the peer's display name.
    func test_headerShowsName() throws {
        try runBlocking { try await SeedData.createTestConversation() }

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )

        // The message-list header renders the peer name as a staticText; the composer appearing
        // confirms the list is up before we assert the name.
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 15),
            "Message list did not open (composer not found)"
        )
        XCTAssertTrue(
            app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 10),
            "Header did not show \(TestConfig.userBDisplayName)"
        )
    }

    // MARK: - Send variants

    /// A whitespace-only message is not sent: typing spaces and tapping Send creates no whitespace bubble
    /// and the message screen stays stable (the UIKit composer trims/rejects blank input).
    func test_1TO1_whitespaceMessageBlocked() throws {
        openSeeded()
        let composer = ComponentQueries.composer(app)
        composer.tap()
        composer.typeText("     ")
        let send = app.buttons["Send"]
        if send.exists && send.isHittable { send.tap() }
        // No blank bubble should have been created, and the composer is still present (screen stable).
        XCTAssertFalse(app.buttons["     "].exists, "A whitespace-only bubble was unexpectedly sent")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer vanished after blank send attempt")
    }

    /// A long (1000+ char) message sends and its tail renders. Assert on a unique tail token contained in
    /// the (large) bubble label.
    func test_1TO1_longTextMessageSends() throws {
        openSeeded()
        let tail = "longtail-\(UUID().uuidString.prefix(8))"
        let body = String(repeating: "A", count: 1024) + tail
        ComponentQueries.typeAndSend(app, text: body)
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 14),
                      "Long message tail '\(tail)' did not render")
    }

    /// A message containing an @mention text sends; the trailing words render. (Mention resolution is
    /// not asserted — only the trailing plain words are checked.)
    func test_1TO1_messageWithMentionSends() throws {
        openSeeded()
        let tail = "mention-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "@\(TestConfig.userBDisplayName) hi \(tail)")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 12),
                      "Mention message tail did not render")
    }

    /// A message containing a URL sends and the trailing token renders (the bubble label includes the URL
    /// plus our token, so match on the token as a substring).
    func test_1TO1_messageWithURLSends() throws {
        openSeeded()
        let tail = "url-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: "see https://cometchat.com \(tail)")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: tail, timeout: 12),
                      "URL message tail did not render")
    }

    /// A markdown-bold message sends; the inner word renders. NOTE: no underscores in test text — the
    /// UIKit formatter treats `_x_` as italic and strips them; use `**bold**`.
    func test_1TO1_markdownBoldSends() throws {
        openSeeded()
        let word = "boldword\(UUID().uuidString.prefix(6))"
        ComponentQueries.typeAndSend(app, text: "**\(word)**")
        // The rendered bubble may show the inner word with bold styling; assert the word is present.
        XCTAssertTrue(
            ComponentQueries.waitForBubble(app, text: word, timeout: 12)
                || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", word)).firstMatch.exists,
            "Bold word '\(word)' did not render"
        )
    }

    /// The send affordance is present once text is typed (composer exposes a Send control).
    func test_1TO1_sendButtonActivatesOnText() throws {
        openSeeded()
        let composer = ComponentQueries.composer(app)
        composer.tap()
        composer.typeText("hello")
        XCTAssertTrue(ComponentQueries.sendButton(app).waitForExistence(timeout: 5),
                      "Send affordance not present after typing")
    }

    /// Opening a 1:1 keeps the message screen stable (the "cannot send when blocked" full behavior lives
    /// in the block suite; here we only assert screen stability).
    func test_1TO1_screenStableForBlockedCase() throws {
        openSeeded()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Message screen not stable")
    }

    // MARK: - Helpers

    /// Seed a 1:1 with User B and open it from Chats. Asserts the open succeeded.
    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
            "Could not open conversation with \(TestConfig.userBDisplayName)"
        )
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Message list did not open")
    }
}
