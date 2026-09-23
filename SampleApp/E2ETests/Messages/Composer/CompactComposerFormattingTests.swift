import XCTest

/// Rich-text formatting in `CometChatCompactMessageComposer`, driven through the real
/// toolbar and the live-markdown shortcuts, one conversation per test.
///
/// XCUITest cannot read attributed styling, so every case asserts the two contracts that
/// are observable end to end:
///   1. the exact text the composer put on the wire, read back from the backend
///      (`PeerActions.lastConversationMessageText`) — this is what other clients render;
///   2. where it matters, what the bubble shows: the content without its markers.
///
/// The wire grammar these expect (probed against the sample app, and matching
/// `FormatType.markdownSyntax`):
///   bold `**x**` · italic `_x_` · underline `<u>x</u>` · strikethrough `~~x~~`
///   inline code `` `x` `` · code block "```\nx\n```" · bullet `• x` · numbered `1. x`
///   blockquote `> x`. Stacked inline formats nest as `~~<u>**_x_**</u>~~`.
/// Bullets go out as a literal `• `, not markdown `- ` (see KIT-GAPS.md).
///
/// Every token carries a per-test stamp, so a read-back can never match another test's
/// message on the shared conversation.
final class CompactComposerFormattingTests: XCTestCase {

    private var app: XCUIApplication!
    private var stamp = ""

    override func setUpWithError() throws {
        continueAfterFailure = false
        stamp = String(UUID().uuidString.prefix(6)).lowercased()
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - Shared steps

    private enum Format {
        static let bold = "Bold"
        static let italic = "Italic"
        static let underline = "Underline"
        static let strikethrough = "Strikethrough"
        static let inlineCode = "Inline Code"
        static let codeBlock = "Code Block"
        static let bullet = "Bullet List"
        static let numbered = "Numbered List"
        static let blockquote = "Blockquote"
    }

    private func token(_ prefix: String) -> String { "\(prefix)\(stamp)" }

    private var field: XCUIElement { ComponentQueries.composer(app) }

    private func focusComposer() {
        XCTAssertTrue(field.waitForExistence(timeout: 10), "Composer not found")
        field.tap()
    }

    private func formatButton(_ label: String) -> XCUIElement {
        app.buttons[label].firstMatch
    }

    private func tap(_ label: String, file: StaticString = #filePath, line: UInt = #line) {
        let button = formatButton(label)
        XCTAssertTrue(button.waitForExistence(timeout: 8),
                      "\(label) toolbar button not found", file: file, line: line)
        button.tap()
    }

    private func type(_ text: String) {
        field.typeText(text)
    }

    private func send(file: StaticString = #filePath, line: UInt = #line) {
        let button = ComponentQueries.sendButton(app)
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Send button not found", file: file, line: line)
        button.tap()
    }

    /// The text stored on the backend for the message carrying `marker`.
    private func sentText(containing marker: String) -> String? {
        var text: String?
        _ = waitForBackend(timeout: 25) {
            let latest = await PeerActions.lastConversationMessageText()
            if latest?.contains(marker) == true { text = latest; return true }
            return false
        }
        return text
    }

    /// Send what is in the composer and assert the exact wire text.
    private func sendAndExpect(_ expected: String, marker: String,
                               file: StaticString = #filePath, line: UInt = #line) {
        send(file: file, line: line)
        let actual = sentText(containing: marker)
        XCTAssertEqual(actual, expected, "Wire text differs", file: file, line: line)
    }

    /// Live conversion runs just after each keystroke, so poll the composer's value.
    @discardableResult
    private func waitForComposer(timeout: TimeInterval = 4, _ condition: @escaping (String) -> Bool) -> Bool {
        waitForCondition(timeout: timeout) { condition((self.field.value as? String) ?? "") }
    }

    /// The accessibility label of the first bubble whose text contains `text`.
    private func renderedLabel(containing text: String) -> String {
        let predicate = NSPredicate(format: "label CONTAINS %@", text)
        for query in [app.buttons, app.staticTexts] {
            let match = query.matching(predicate).firstMatch
            if match.exists { return match.label }
        }
        return ""
    }

    private func bubbleExists(containing text: String, timeout: TimeInterval = 15) -> Bool {
        ComponentQueries.waitForBubbleContaining(app, substring: text, timeout: timeout)
    }

    // MARK: - Single formats from the toolbar

    func test_1TO1_FMT_boldSendsDoubleAsterisks() {
        app = openSeededConversation()
        let t = token("bold")
        focusComposer(); tap(Format.bold); type(t)
        sendAndExpect("**\(t)**", marker: t)
    }

    func test_1TO1_FMT_italicSendsUnderscores() {
        app = openSeededConversation()
        let t = token("ital")
        focusComposer(); tap(Format.italic); type(t)
        sendAndExpect("_\(t)_", marker: t)
    }

    func test_1TO1_FMT_underlineSendsUTags() {
        app = openSeededConversation()
        let t = token("undr")
        focusComposer(); tap(Format.underline); type(t)
        sendAndExpect("<u>\(t)</u>", marker: t)
    }

    func test_1TO1_FMT_strikethroughSendsTildes() {
        app = openSeededConversation()
        let t = token("strk")
        focusComposer(); tap(Format.strikethrough); type(t)
        sendAndExpect("~~\(t)~~", marker: t)
    }

    func test_1TO1_FMT_inlineCodeSendsBackticks() {
        app = openSeededConversation()
        let t = token("icod")
        focusComposer(); tap(Format.inlineCode); type(t)
        sendAndExpect("`\(t)`", marker: t)
    }

    func test_1TO1_FMT_codeBlockSendsFencedBlock() {
        app = openSeededConversation()
        let t = token("cblk")
        focusComposer(); tap(Format.codeBlock); type(t)
        sendAndExpect("```\n\(t)\n```", marker: t)
    }

    func test_1TO1_FMT_bulletListSendsBulletGlyph() {
        app = openSeededConversation()
        let t = token("bull")
        focusComposer(); tap(Format.bullet); type(t)
        sendAndExpect("• \(t)", marker: t)
    }

    func test_1TO1_FMT_numberedListSendsOneDot() {
        app = openSeededConversation()
        let t = token("numb")
        focusComposer(); tap(Format.numbered); type(t)
        sendAndExpect("1. \(t)", marker: t)
    }

    func test_1TO1_FMT_blockquoteSendsQuotePrefix() {
        app = openSeededConversation()
        let t = token("quot")
        focusComposer(); tap(Format.blockquote); type(t)
        sendAndExpect("> \(t)", marker: t)
    }

    // MARK: - Toggling a format off closes its range

    func test_1TO1_FMT_boldToggleOffLeavesTrailingTextPlain() {
        app = openSeededConversation()
        let t = token("boff")
        focusComposer(); tap(Format.bold); type(t); tap(Format.bold); type(" plain")
        sendAndExpect("**\(t)** plain", marker: t)
    }

    func test_1TO1_FMT_italicToggleOffLeavesTrailingTextPlain() {
        app = openSeededConversation()
        let t = token("ioff")
        focusComposer(); tap(Format.italic); type(t); tap(Format.italic); type(" plain")
        sendAndExpect("_\(t)_ plain", marker: t)
    }

    func test_1TO1_FMT_underlineToggleOffLeavesTrailingTextPlain() {
        app = openSeededConversation()
        let t = token("uoff")
        focusComposer(); tap(Format.underline); type(t); tap(Format.underline); type(" plain")
        sendAndExpect("<u>\(t)</u> plain", marker: t)
    }

    func test_1TO1_FMT_strikethroughToggleOffLeavesTrailingTextPlain() {
        app = openSeededConversation()
        let t = token("soff")
        focusComposer(); tap(Format.strikethrough); type(t); tap(Format.strikethrough); type(" plain")
        sendAndExpect("~~\(t)~~ plain", marker: t)
    }

    func test_1TO1_FMT_inlineCodeToggleOffLeavesTrailingTextPlain() {
        app = openSeededConversation()
        let t = token("coff")
        focusComposer(); tap(Format.inlineCode); type(t); tap(Format.inlineCode); type(" plain")
        sendAndExpect("`\(t)` plain", marker: t)
    }

    // MARK: - A format in the middle of a sentence

    func test_1TO1_FMT_boldWordMidSentence() {
        app = openSeededConversation()
        let t = token("bmid")
        focusComposer(); type("start "); tap(Format.bold); type(t); tap(Format.bold); type(" end")
        sendAndExpect("start **\(t)** end", marker: t)
    }

    func test_1TO1_FMT_italicWordMidSentence() {
        app = openSeededConversation()
        let t = token("imid")
        focusComposer(); type("start "); tap(Format.italic); type(t); tap(Format.italic); type(" end")
        sendAndExpect("start _\(t)_ end", marker: t)
    }

    func test_1TO1_FMT_underlineWordMidSentence() {
        app = openSeededConversation()
        let t = token("umid")
        focusComposer(); type("start "); tap(Format.underline); type(t); tap(Format.underline); type(" end")
        sendAndExpect("start <u>\(t)</u> end", marker: t)
    }

    func test_1TO1_FMT_twoDifferentFormatsInOneMessage() {
        app = openSeededConversation()
        let a = token("fa"), b = token("fb")
        focusComposer()
        tap(Format.bold); type(a); tap(Format.bold)
        type(" and ")
        tap(Format.italic); type(b); tap(Format.italic)
        sendAndExpect("**\(a)** and _\(b)_", marker: b)
    }

    // MARK: - Stacked inline formats

    func test_1TO1_FMT_boldItalic() {
        app = openSeededConversation()
        let t = token("bi")
        focusComposer(); tap(Format.bold); tap(Format.italic); type(t)
        sendAndExpect("**_\(t)_**", marker: t)
    }

    func test_1TO1_FMT_boldItalicUnderline() {
        app = openSeededConversation()
        let t = token("biu")
        focusComposer(); tap(Format.bold); tap(Format.italic); tap(Format.underline); type(t)
        sendAndExpect("<u>**_\(t)_**</u>", marker: t)
    }

    func test_1TO1_FMT_boldUnderline() {
        app = openSeededConversation()
        let t = token("bu")
        focusComposer(); tap(Format.bold); tap(Format.underline); type(t)
        sendAndExpect("<u>**\(t)**</u>", marker: t)
    }

    func test_1TO1_FMT_italicUnderline() {
        app = openSeededConversation()
        let t = token("iu")
        focusComposer(); tap(Format.italic); tap(Format.underline); type(t)
        sendAndExpect("<u>_\(t)_</u>", marker: t)
    }

    func test_1TO1_FMT_boldStrikethrough() {
        app = openSeededConversation()
        let t = token("bs")
        focusComposer(); tap(Format.bold); tap(Format.strikethrough); type(t)
        sendAndExpect("~~**\(t)**~~", marker: t)
    }

    func test_1TO1_FMT_italicStrikethrough() {
        app = openSeededConversation()
        let t = token("is")
        focusComposer(); tap(Format.italic); tap(Format.strikethrough); type(t)
        sendAndExpect("~~_\(t)_~~", marker: t)
    }

    func test_1TO1_FMT_underlineStrikethrough() {
        app = openSeededConversation()
        let t = token("us")
        focusComposer(); tap(Format.underline); tap(Format.strikethrough); type(t)
        sendAndExpect("~~<u>\(t)</u>~~", marker: t)
    }

    func test_1TO1_FMT_allFourInlineFormats() {
        app = openSeededConversation()
        let t = token("bius")
        focusComposer()
        tap(Format.bold); tap(Format.italic); tap(Format.underline); tap(Format.strikethrough)
        type(t)
        sendAndExpect("~~<u>**_\(t)_**</u>~~", marker: t)
    }

    func test_1TO1_FMT_stackOrderDoesNotChangeWireText() {
        app = openSeededConversation()
        let t = token("ord")
        // Italic before Bold must serialize the same as Bold before Italic.
        focusComposer(); tap(Format.italic); tap(Format.bold); type(t)
        sendAndExpect("**_\(t)_**", marker: t)
    }

    func test_1TO1_FMT_droppingOneOfTwoStackedFormats() {
        app = openSeededConversation()
        let t = token("drop")
        focusComposer()
        tap(Format.bold); tap(Format.italic); type(t)
        tap(Format.italic); type(" boldonly")
        tap(Format.bold); type(" plain")
        send()
        let text = sentText(containing: t) ?? ""
        XCTAssertTrue(text.contains(t) && text.contains("boldonly") && text.hasSuffix(" plain"),
                      "Content lost or trailing text still formatted: \(text)")
        XCTAssertFalse(text.contains("_ plain") || text.contains("** plain**"),
                       "A dropped format leaked onto the plain tail: \(text)")
    }

    // MARK: - Inline formats inside block formats

    func test_1TO1_FMT_bulletWithBold() {
        app = openSeededConversation()
        let t = token("bb")
        focusComposer(); tap(Format.bullet); tap(Format.bold); type(t)
        sendAndExpect("• **\(t)**", marker: t)
    }

    func test_1TO1_FMT_bulletWithItalic() {
        app = openSeededConversation()
        let t = token("bit")
        focusComposer(); tap(Format.bullet); tap(Format.italic); type(t)
        sendAndExpect("• _\(t)_", marker: t)
    }

    func test_1TO1_FMT_bulletWithUnderline() {
        app = openSeededConversation()
        let t = token("bun")
        focusComposer(); tap(Format.bullet); tap(Format.underline); type(t)
        sendAndExpect("• <u>\(t)</u>", marker: t)
    }

    func test_1TO1_FMT_numberedWithBold() {
        app = openSeededConversation()
        let t = token("nb")
        focusComposer(); tap(Format.numbered); tap(Format.bold); type(t)
        sendAndExpect("1. **\(t)**", marker: t)
    }

    func test_1TO1_FMT_blockquoteWithItalic() {
        app = openSeededConversation()
        let t = token("qi")
        focusComposer(); tap(Format.blockquote); tap(Format.italic); type(t)
        sendAndExpect("> _\(t)_", marker: t)
    }

    func test_1TO1_FMT_blockquoteWithBold() {
        app = openSeededConversation()
        let t = token("qb")
        focusComposer(); tap(Format.blockquote); tap(Format.bold); type(t)
        sendAndExpect("> **\(t)**", marker: t)
    }

    // MARK: - Multi-line blocks

    func test_1TO1_FMT_codeBlockKeepsTwoLines() {
        app = openSeededConversation()
        let t = token("cb2")
        // Second line starts with a digit: the keyboard would otherwise auto-capitalise it,
        // which is the keyboard's doing, not the composer's.
        focusComposer(); tap(Format.codeBlock); type("\(t)\n2nd\(stamp)")
        sendAndExpect("```\n\(t)\n2nd\(stamp)\n```", marker: t)
    }

    func test_1TO1_FMT_codeBlockKeepsThreeLinesAndIndentation() {
        app = openSeededConversation()
        let t = token("cb3")
        // No dictionary words: autocorrect rewrites them mid-typing (see KIT-GAPS.md).
        focusComposer(); tap(Format.codeBlock); type("\(t)(9) {\n    7\n}")
        sendAndExpect("```\n\(t)(9) {\n    7\n}\n```", marker: t)
    }

    func test_1TO1_FMT_codeBlockKeepsMarkdownCharactersLiteral() {
        app = openSeededConversation()
        let t = token("cbl")
        // Inside a code block, ** and _ are code, not formatting instructions.
        focusComposer(); tap(Format.codeBlock); type("**\(t)** _x_")
        sendAndExpect("```\n**\(t)** _x_\n```", marker: t)
    }

    func test_1TO1_FMT_bulletListTwoItems() {
        app = openSeededConversation()
        let a = token("b1"), b = token("b2")
        focusComposer(); tap(Format.bullet); type("\(a)\n\(b)")
        sendAndExpect("• \(a)\n• \(b)", marker: b)
    }

    func test_1TO1_FMT_bulletListThreeItems() {
        app = openSeededConversation()
        let a = token("c1"), b = token("c2"), c = token("c3")
        focusComposer(); tap(Format.bullet); type("\(a)\n\(b)\n\(c)")
        sendAndExpect("• \(a)\n• \(b)\n• \(c)", marker: c)
    }

    func test_1TO1_FMT_numberedListTwoItemsCountsUp() {
        app = openSeededConversation()
        let a = token("n1"), b = token("n2")
        focusComposer(); tap(Format.numbered); type("\(a)\n\(b)")
        sendAndExpect("1. \(a)\n2. \(b)", marker: b)
    }

    func test_1TO1_FMT_numberedListThreeItemsCountsUp() {
        app = openSeededConversation()
        let a = token("m1"), b = token("m2"), c = token("m3")
        focusComposer(); tap(Format.numbered); type("\(a)\n\(b)\n\(c)")
        sendAndExpect("1. \(a)\n2. \(b)\n3. \(c)", marker: c)
    }

    func test_1TO1_FMT_bulletItemsWithDifferentInlineFormats() {
        app = openSeededConversation()
        let a = token("x1"), b = token("x2")
        focusComposer(); tap(Format.bullet)
        tap(Format.bold); type(a); tap(Format.bold)
        type("\n")
        tap(Format.italic); type(b); tap(Format.italic)
        sendAndExpect("• **\(a)**\n• _\(b)_", marker: b)
    }

    // MARK: - Live markdown typed by hand

    func test_1TO1_FMT_typedBoldMarkdownIsKept() {
        app = openSeededConversation()
        let t = token("tb")
        focusComposer(); type("**\(t)** tail")
        sendAndExpect("**\(t)** tail", marker: t)
    }

    func test_1TO1_FMT_typedItalicMarkdownIsKept() {
        app = openSeededConversation()
        let t = token("ti")
        focusComposer(); type("_\(t)_ tail")
        sendAndExpect("_\(t)_ tail", marker: t)
    }

    func test_1TO1_FMT_typedStrikethroughMarkdownIsKept() {
        app = openSeededConversation()
        let t = token("ts")
        focusComposer(); type("~~\(t)~~ tail")
        sendAndExpect("~~\(t)~~ tail", marker: t)
    }

    func test_1TO1_FMT_typedInlineCodeMarkdownIsKept() {
        app = openSeededConversation()
        let t = token("tc")
        focusComposer(); type("`\(t)` tail")
        sendAndExpect("`\(t)` tail", marker: t)
    }

    func test_1TO1_FMT_typedMarkdownMidSentenceIsKept() {
        app = openSeededConversation()
        let a = token("ma"), b = token("mb")
        focusComposer(); type("start **\(a)** middle _\(b)_ end")
        sendAndExpect("start **\(a)** middle _\(b)_ end", marker: b)
    }

    func test_1TO1_FMT_typedQuotePrefixBecomesBlockquote() {
        app = openSeededConversation()
        let t = token("tq")
        focusComposer(); type("> \(t)")
        sendAndExpect("> \(t)", marker: t)
    }

    func test_1TO1_FMT_typedDashSpaceBecomesBullet() {
        app = openSeededConversation()
        let t = token("td")
        // The conversion runs just after the space lands; a real typist is never faster.
        focusComposer(); type("- "); waitForComposer { $0.hasPrefix("•") }; type(t)
        sendAndExpect("• \(t)", marker: t)
    }

    func test_1TO1_FMT_typedOneDotSpaceBecomesNumberedList() {
        app = openSeededConversation()
        let t = token("tn")
        focusComposer(); type("1. \(t)")
        sendAndExpect("1. \(t)", marker: t)
    }

    func test_1TO1_FMT_unterminatedBoldIsSentLiterally() {
        app = openSeededConversation()
        let t = token("ub")
        focusComposer(); type("**\(t)")
        sendAndExpect("**\(t)", marker: t)
    }

    func test_1TO1_FMT_unterminatedCodeFenceIsSentLiterally() {
        app = openSeededConversation()
        let t = token("uf")
        focusComposer(); type("```\(t)")
        sendAndExpect("```\(t)", marker: t)
    }

    func test_1TO1_FMT_plainTextIsSentUnchanged() {
        app = openSeededConversation()
        let t = token("pl")
        focusComposer(); type("just \(t) words")
        sendAndExpect("just \(t) words", marker: t)
    }

    func test_1TO1_FMT_boldAroundAccentedText() {
        app = openSeededConversation()
        let t = token("ac")
        focusComposer(); tap(Format.bold); type("héllo \(t) çava")
        sendAndExpect("**héllo \(t) çava**", marker: t)
    }

    /// Emoji are deliberately never formatted: with Bold on, the emoji goes out after the
    /// closing marker (`**héllo x **😀`). Asserts that, and that the bubble still renders
    /// the bold run rather than literal asterisks.
    func test_1TO1_FMT_emojiStaysOutsideBoldRun() {
        app = openSeededConversation()
        let t = token("em")
        focusComposer(); tap(Format.bold); type("héllo \(t) 😀")
        send()
        let text = sentText(containing: t) ?? ""
        XCTAssertTrue(text.hasPrefix("**héllo \(t)"), "Bold run lost its text: \(text)")
        XCTAssertTrue(text.hasSuffix("**😀"), "Emoji was formatted or dropped: \(text)")
        XCTAssertTrue(bubbleExists(containing: t), "Bubble did not render")
        let rendered = renderedLabel(containing: t)
        XCTAssertFalse(rendered.contains("**"), "Bubble shows literal ** markers: \(rendered)")
    }

    // MARK: - Switching between block formats

    func test_1TO1_FMT_codeBlockIsUnavailableInsideBulletList() {
        app = openSeededConversation()
        let t = token("sw1")
        // FormatCompatibilityMatrix: a list disables code block, so the tap must be a no-op.
        focusComposer(); tap(Format.bullet); tap(Format.codeBlock); type(t)
        sendAndExpect("• \(t)", marker: t)
    }

    func test_1TO1_FMT_bulletListReplacesCodeBlock() {
        app = openSeededConversation()
        let t = token("sw2")
        focusComposer(); tap(Format.codeBlock); tap(Format.bullet); type(t)
        sendAndExpect("• \(t)", marker: t)
    }

    func test_1TO1_FMT_codeBlockReplacesBlockquote() {
        app = openSeededConversation()
        let t = token("sw3")
        focusComposer(); tap(Format.blockquote); tap(Format.codeBlock); type(t)
        sendAndExpect("```\n\(t)\n```", marker: t)
    }

    func test_1TO1_FMT_codeBlockToggledOffSendsPlainText() {
        app = openSeededConversation()
        let t = token("cbo")
        focusComposer(); tap(Format.codeBlock); tap(Format.codeBlock); type(t)
        sendAndExpect(t, marker: t)
    }

    // MARK: - State after send

    func test_1TO1_FMT_formatDoesNotCarryIntoNextMessage() {
        app = openSeededConversation()
        let first = token("f1"), second = token("f2")
        focusComposer(); tap(Format.bold); type(first)
        sendAndExpect("**\(first)**", marker: first)
        focusComposer(); type(second)
        sendAndExpect(second, marker: second)
    }

    func test_1TO1_FMT_codeBlockDoesNotCarryIntoNextMessage() {
        app = openSeededConversation()
        let first = token("g1"), second = token("g2")
        focusComposer(); tap(Format.codeBlock); type(first)
        sendAndExpect("```\n\(first)\n```", marker: first)
        focusComposer(); type(second)
        sendAndExpect(second, marker: second)
    }

    func test_1TO1_FMT_listDoesNotCarryIntoNextMessage() {
        app = openSeededConversation()
        let first = token("h1"), second = token("h2")
        focusComposer(); tap(Format.bullet); type(first)
        sendAndExpect("• \(first)", marker: first)
        focusComposer(); type(second)
        sendAndExpect(second, marker: second)
    }

    func test_1TO1_FMT_composerIsEmptyAfterFormattedSend() {
        app = openSeededConversation()
        let t = token("emp")
        focusComposer(); tap(Format.codeBlock); type("\(t)\n2nd\(stamp)")
        sendAndExpect("```\n\(t)\n2nd\(stamp)\n```", marker: t)
        XCTAssertTrue(waitForCondition(timeout: 5) { ComponentQueries.composerIsEmpty(self.app) },
                      "Composer kept text after sending: \((self.field.value as? String) ?? "nil")")
    }

    // MARK: - Rendering in the message list

    func test_1TO1_FMT_boldBubbleShowsNoMarkers() {
        app = openSeededConversation()
        let t = token("rb")
        focusComposer(); tap(Format.bold); type(t)
        sendAndExpect("**\(t)**", marker: t)
        XCTAssertTrue(bubbleExists(containing: t), "Bold bubble did not render")
        XCTAssertFalse(bubbleExists(containing: "**\(t)", timeout: 2), "Bubble shows literal ** markers")
    }

    func test_1TO1_FMT_underlineBubbleShowsNoTags() {
        app = openSeededConversation()
        let t = token("ru")
        focusComposer(); tap(Format.underline); type(t)
        sendAndExpect("<u>\(t)</u>", marker: t)
        XCTAssertTrue(bubbleExists(containing: t), "Underline bubble did not render")
        XCTAssertFalse(bubbleExists(containing: "<u>", timeout: 2), "Bubble shows literal <u> tags")
    }

    func test_1TO1_FMT_codeBlockBubbleShowsNoFences() {
        app = openSeededConversation()
        let t = token("rc")
        focusComposer(); tap(Format.codeBlock); type(t)
        sendAndExpect("```\n\(t)\n```", marker: t)
        XCTAssertTrue(bubbleExists(containing: t), "Code block bubble did not render")
        XCTAssertFalse(bubbleExists(containing: "```", timeout: 2), "Bubble shows literal ``` fences")
    }

    /// Open the conversation after B's message is already on the backend. These cases test how an
    /// incoming message RENDERS; sending it into an already-open chat also made them depend on
    /// real-time socket delivery, which missed the 20 s window once in a full run
    /// (ReceiveMessageTests owns real-time delivery).
    private func openConversation(afterPeerSends text: String) throws {
        try runBlocking {
            try await SeedData.createTestConversation()
            _ = try await PeerActions.sendTextMessage(text)
        }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation with \(TestConfig.userBDisplayName)")
        XCTAssertTrue(field.waitForExistence(timeout: 15), "Message list did not open")
    }

    func test_1TO1_FMT_receivedUnderlineAndStrikethroughRenderWithoutMarkers() throws {
        let t = token("rx")
        try openConversation(afterPeerSends: "<u>\(t)</u> and ~~gone~~")
        XCTAssertTrue(bubbleExists(containing: t, timeout: 20), "Incoming formatted message did not render")
        XCTAssertFalse(bubbleExists(containing: "<u>\(t)", timeout: 2), "Incoming <u> rendered literally")
        XCTAssertFalse(bubbleExists(containing: "~~gone~~", timeout: 2), "Incoming ~~ rendered literally")
    }

    func test_1TO1_FMT_receivedCodeBlockRendersWithoutFences() throws {
        let t = token("ry")
        try openConversation(afterPeerSends: "```\n\(t)\n```")
        XCTAssertTrue(bubbleExists(containing: t, timeout: 20), "Incoming code block did not render")
        XCTAssertFalse(bubbleExists(containing: "```", timeout: 2), "Incoming ``` rendered literally")
    }
}
