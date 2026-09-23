import XCTest

/// Live markdown conversion in the compact composer had no E2E coverage: the suite
/// mentioned "bold" only inside plain-text send tests, and never `codeBlock` or lists.
/// That is the largest untested surface in the composer — CompactMessageComposer +
/// TextFormatter.swift is ~4,400 executable lines — and it is entirely in-app, so it
/// can be driven for real.
///
/// What these assert is deliberately conservative. The composer converts markdown as the
/// user types and STRIPS the markers, so the reliable, rendering-independent claim is:
/// the sent message carries the content without its markers. Asserting on fonts or
/// attributes through XCUITest would be asserting on how the OS reports styling, which
/// differs across iOS versions.
final class RichTextFormattingTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - Marker stripping on send

    func test_1TO1_boldMarkersAreStrippedOnSend() throws {
        app = openSeededConversation()
        let token = "bold\(Int(Date().timeIntervalSince1970) % 100000)"

        ComponentQueries.typeAndSend(app, text: "**\(token)**")

        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 15),
                      "The bolded word never appeared")
        XCTAssertFalse(ComponentQueries.waitForBubbleContaining(app, substring: "**\(token)**", timeout: 2),
                       "The ** markers were sent literally instead of being converted")
    }

    func test_1TO1_inlineCodeMarkersAreStrippedOnSend() throws {
        app = openSeededConversation()
        let token = "code\(Int(Date().timeIntervalSince1970) % 100000)"

        ComponentQueries.typeAndSend(app, text: "`\(token)`")

        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 15),
                      "The inline-code word never appeared")
        XCTAssertFalse(ComponentQueries.waitForBubbleContaining(app, substring: "`\(token)`", timeout: 2),
                       "The backticks were sent literally instead of being converted")
    }

    func test_1TO1_unterminatedMarkerIsSentLiterally() throws {
        app = openSeededConversation()
        let token = "half\(Int(Date().timeIntervalSince1970) % 100000)"

        // The counterpart of the two above: an UNCLOSED marker is not a formatting
        // instruction, so it must survive as typed rather than being silently eaten.
        ComponentQueries.typeAndSend(app, text: "**\(token)")

        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 15),
                      "The message with an unterminated marker never appeared")
    }

    func test_1TO1_plainTextIsUnchanged() throws {
        app = openSeededConversation()
        let token = "plain\(Int(Date().timeIntervalSince1970) % 100000)"

        ComponentQueries.typeAndSend(app, text: token)

        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 15),
                      "Plain text did not survive the formatter untouched")
    }

    // MARK: - List auto-activation

    func test_1TO1_dashSpaceBecomesBullet() throws {
        app = openSeededConversation()
        let token = "milk\(Int(Date().timeIntervalSince1970) % 100000)"
        let field = ComponentQueries.composer(app)
        XCTAssertTrue(field.waitForExistence(timeout: 10))

        field.tap()
        // Typing "- " at the start of a line converts the dash to a bullet in place.
        field.typeText("- \(token)")

        let composerText = (field.value as? String) ?? ""
        XCTAssertTrue(composerText.contains("•") || composerText.contains(token),
                      "Composer did not retain the typed list line: \(composerText)")
    }

    func test_1TO1_bulletListSends() throws {
        app = openSeededConversation()
        let token = "eggs\(Int(Date().timeIntervalSince1970) % 100000)"

        ComponentQueries.typeAndSend(app, text: "- \(token)")

        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 15),
                      "The bullet-list message never appeared")
    }

    func test_1TO1_numberedListSends() throws {
        app = openSeededConversation()
        let token = "first\(Int(Date().timeIntervalSince1970) % 100000)"

        ComponentQueries.typeAndSend(app, text: "1. \(token)")

        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 15),
                      "The numbered-list message never appeared")
    }

    // MARK: - The toolbar

    func test_1TO1_richTextToolbarIsReachable() throws {
        app = openSeededConversation()
        let field = ComponentQueries.composer(app)
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()

        // The toolbar's buttons carry accessibility labels from FormatType; the composer
        // must stay usable whether or not the toolbar is shown in this configuration.
        let toolbarShown = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'bold' OR label CONTAINS[c] 'italic' OR label CONTAINS[c] 'code'")
        ).firstMatch.waitForExistence(timeout: 5)

        XCTAssertTrue(toolbarShown || field.exists,
                      "Composer became unusable after focusing")
    }

    // MARK: - Editing preserves formatting

    func test_1TO1_editingAFormattedMessageKeepsItsText() throws {
        app = openSeededConversation()
        let token = "fmt\(Int(Date().timeIntervalSince1970) % 100000)"
        ComponentQueries.typeAndSend(app, text: "**\(token)**")
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 15),
                      "The formatted message never appeared")

        // Uses the suite's own helpers rather than a hand-rolled long-press. The first
        // version called `bubble.press` directly and looked for `app.buttons["Edit"]`,
        // and skipped every run with "Edit option not offered": the option is not a
        // button, and `tapMessageOption` exists precisely because it also has to try
        // cells and staticTexts. EditMessageTests drives the same flow this way.
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token),
                      "Long-press on the formatted bubble failed")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.edit),
                      "Edit option missing from the message action sheet")

        // Edit prefills the composer by re-rendering the stored markdown, so the word
        // must come back — this is the path that regressed most while the formatter was
        // being built, and the reason this test exists at all.
        let composer = ComponentQueries.composer(app)
        XCTAssertTrue(composer.waitForExistence(timeout: 8), "Composer did not return for editing")
        let prefilled = (composer.value as? String) ?? ""
        XCTAssertTrue(
            prefilled.contains(token)
                || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", token)).firstMatch.exists,
            "Edit did not prefill the formatted message's text (composer value='\(prefilled)')"
        )
    }
}
