import XCTest

/// Swipe-to-reply on message bubbles. The composer's reply preview quotes the swiped message and
/// calls `becomeFirstResponder()`, so the keyboard is part of the contract — the three
/// keyboard-related cases failed in the manual iOS run and may legitimately fail here too.
/// Sheet sources: "swipe to reply" tab; "Read the sent reply" from the sample-app sheet.
final class SwipeToReplyTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - Shared steps

    /// Seed a message from B and swipe it right; returns the token so callers can assert on the preview.
    private func seedAndSwipe() -> String {
        let token = "swipe\(UUID().uuidString.prefix(6).lowercased())"
        try? runBlocking { _ = try await PeerActions.sendTextMessage("E2E \(token)") }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20),
                      "Seeded message did not arrive")
        ComponentQueries.swipeToReply(ComponentQueries.bubble(app, text: "E2E \(token)"), app: app)
        return token
    }

    /// The reply preview strip quotes the swiped message above the composer and carries the
    /// kit's Close control. This used to demand the token in two `staticTexts` (bubble + quote),
    /// but a bubble exposes its text as a *button*, so the count never reached two even with the
    /// preview plainly open — the recordings of the "failed" runs show it. Now: the Close control
    /// is present and the quote carries this test's token.
    private func replyPreviewVisible(for token: String, timeout: TimeInterval = 8) -> Bool {
        let close = app.buttons["Close"].firstMatch
        let quote = app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", token)).firstMatch
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if close.exists && quote.exists { return true }
            _ = close.waitForExistence(timeout: 0.5)
        }
        return close.exists && quote.exists
    }

    // MARK: - Cases

    /// Swiping a bubble opens the reply preview and (⚠ manual FAIL) focuses the keyboard.
    func test_1TO1_swipeOpensReplyPreviewAndKeyboard() throws {
        app = openSeededConversation()
        let token = seedAndSwipe()
        XCTAssertTrue(replyPreviewVisible(for: token), "Reply preview did not appear after swipe")
        XCTAssertTrue(app.keyboards.firstMatch.waitForExistence(timeout: 8),
                      "Keyboard did not open after swipe-to-reply (becomeFirstResponder)")
    }

    /// (⚠ manual FAIL) Sending the reply clears the preview and dismisses the keyboard.
    func test_1TO1_sendingReplyClearsPreviewAndKeyboard() throws {
        app = openSeededConversation()
        let token = seedAndSwipe()
        XCTAssertTrue(replyPreviewVisible(for: token), "Reply preview did not appear")
        let replyText = "E2E reply \(UUID().uuidString.prefix(6).lowercased())"
        let field = ComponentQueries.composer(app)
        field.tap()
        field.typeText(replyText)
        ComponentQueries.sendButton(app).tap()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: replyText, timeout: 15),
                      "Reply was not sent")
        let deadline = Date().addingTimeInterval(8)
        while Date() < deadline, app.keyboards.firstMatch.exists {
            _ = app.otherElements.firstMatch.waitForExistence(timeout: 0.5)
        }
        XCTAssertFalse(app.keyboards.firstMatch.exists, "Keyboard stayed open after sending the reply")
    }

    /// (⚠ manual FAIL) The same flow works inside a group conversation.
    func test_GROUP_swipeToReplyWorks() throws {
        var group: SeedData.TestGroup?
        (app, group) = openSeededGroupWithMember()
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        guard let group else { return }

        let token = "gswipe\(UUID().uuidString.prefix(6).lowercased())"
        try runBlocking { _ = try await PeerActions.sendGroupTextMessage("E2E \(token)", groupId: group.guid) }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20),
                      "Group message did not arrive")
        ComponentQueries.swipeToReply(ComponentQueries.bubble(app, text: "E2E \(token)"), app: app)
        XCTAssertTrue(replyPreviewVisible(for: token), "Reply preview did not appear in group")

        let replyText = "E2E greply \(UUID().uuidString.prefix(6).lowercased())"
        let field = ComponentQueries.composer(app)
        field.tap()
        field.typeText(replyText)
        ComponentQueries.sendButton(app).tap()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: replyText, timeout: 15),
                      "Group reply was not sent")
    }

    /// Swiping a system/action message must not open a reply preview.
    func test_GROUP_swipeOnActionMessageDoesNothing() throws {
        var group: SeedData.TestGroup?
        (app, group) = openSeededGroupWithMember()
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        guard group != nil else { return }

        // Adding B produced an "added" action message in the list.
        let action = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'added'")).firstMatch
        guard action.waitForExistence(timeout: 10) else {
            throw XCTSkip("No action message visible to swipe")
        }
        ComponentQueries.swipeToReply(action)
        XCTAssertFalse(app.keyboards.firstMatch.waitForExistence(timeout: 3),
                       "Swiping an action message opened the composer/keyboard")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Screen unstable after swiping action message")
    }

    /// Rapid repeated swipes on the same bubble leave exactly one stable reply preview.
    func test_1TO1_multipleQuickSwipesStayStable() throws {
        app = openSeededConversation()
        let token = "multi\(UUID().uuidString.prefix(6).lowercased())"
        try runBlocking { _ = try await PeerActions.sendTextMessage("E2E \(token)") }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20))
        let bubble = ComponentQueries.bubble(app, text: "E2E \(token)")
        for _ in 1...3 { ComponentQueries.swipeToReply(bubble, app: app) }
        XCTAssertTrue(replyPreviewVisible(for: token), "Reply preview missing after quick swipes")
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Composer lost after quick swipes")
    }

    /// Swiping while the long-press options sheet is open must not wedge the screen.
    func test_1TO1_swipeWhileMessageOptionsOpen() throws {
        app = openSeededConversation()
        let token = "opt\(UUID().uuidString.prefix(6).lowercased())"
        try runBlocking { _ = try await PeerActions.sendTextMessage("E2E \(token)") }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20))
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: "E2E \(token)"),
                      "Could not open message options")
        app.swipeRight()
        // Dismiss whatever remains and verify the conversation is still usable.
        if app.keyboards.firstMatch.exists { app.swipeDown() }
        app.tap()
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10),
                      "Conversation unusable after swipe during options")
    }

    /// A swipe issued right after scrolling still lands on the bubble and opens the preview.
    func test_1TO1_swipeAfterScrolling() throws {
        app = openSeededConversation()
        let stamp = UUID().uuidString.prefix(6).lowercased()
        try runBlocking {
            _ = try await PeerActions.sendMultipleMessages(6, prefix: "E2E scrollpad \(stamp)")
        }
        let token = "scrolltgt\(stamp)"
        try runBlocking { _ = try await PeerActions.sendTextMessage("E2E \(token)") }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 20))
        app.swipeDown()
        app.swipeUp()
        let bubble = ComponentQueries.bubble(app, text: "E2E \(token)")
        guard bubble.waitForExistence(timeout: 8) else { throw XCTSkip("Bubble scrolled offscreen") }
        ComponentQueries.swipeToReply(bubble, app: app)
        XCTAssertTrue(replyPreviewVisible(for: token), "Reply preview did not open after scroll")
    }

    /// The sent reply renders as a quoted bubble: reply text plus the original above it.
    func test_1TO1_sentReplyShowsQuotedOriginal() throws {
        app = openSeededConversation()
        let token = seedAndSwipe()
        XCTAssertTrue(replyPreviewVisible(for: token), "Reply preview did not appear")
        let replyText = "E2E quoted \(UUID().uuidString.prefix(6).lowercased())"
        let field = ComponentQueries.composer(app)
        field.tap()
        field.typeText(replyText)
        ComponentQueries.sendButton(app).tap()
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: replyText, timeout: 15),
                      "Reply bubble did not render")
        // The original's token remains visible: once in the original bubble (exposed as a
        // button) and once quoted inside the reply bubble (a static text) — so count both kinds.
        let predicate = NSPredicate(format: "label CONTAINS %@", token)
        let deadline = Date().addingTimeInterval(8)
        var count = 0
        while Date() < deadline {
            count = app.buttons.matching(predicate).count + app.staticTexts.matching(predicate).count
            if count >= 2 { break }
            _ = app.staticTexts.matching(predicate).firstMatch.waitForExistence(timeout: 0.5)
        }
        XCTAssertGreaterThanOrEqual(count, 2, "Reply bubble does not quote the original message")
    }
}
