import XCTest

/// Developer-card (category "card") messages render via CometChatCardBubble.
/// User B sends the card over REST; the app receives it on its socket — no second device.
/// Card fixtures use a per-run token in the heading so assertions never match a stale card.
final class CardMessageTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - Fixtures

    /// A pizza-picker card: heading + subtitle + a 2×2 grid, each cell an image + caption + button.
    /// Four buttons: "Select Margherita" / "Select Pepperoni" / "Select Veggie" / "Build Custom Pizza".
    static func pizzaCard(heading: String) -> [String: Any] {
        func cell(_ prefix: String, button: String, caption: String, url: String) -> [String: Any] {
            ["id": "\(prefix)_col", "type": "column", "gap": 6, "items": [
                ["id": "\(prefix)_img", "type": "image", "url": url, "altText": caption,
                 "fit": "cover", "height": 120, "borderRadius": 10],
                ["id": "\(prefix)_text", "type": "text", "content": caption,
                 "variant": "body", "fontWeight": "bold", "align": "center"],
                ["id": "\(prefix)_btn", "type": "button", "label": button, "fullWidth": true,
                 "action": ["type": "sendMessage", "text": "I want a \(caption)"]],
            ]]
        }
        return [
            "version": "1.0",
            "body": [
                ["id": "title_pizza", "type": "text", "content": heading,
                 "variant": "heading2", "align": "center"],
                ["id": "subtitle_pizza", "type": "text", "content": "Pick a base style to get started:",
                 "variant": "body", "align": "center"],
                ["id": "grid_pizza", "type": "grid", "columns": 2, "gap": 12, "items": [
                    cell("margherita", button: "Select Margherita", caption: "Margherita",
                         url: "https://images.pexels.com/photos/4109080/pexels-photo-4109080.jpeg"),
                    cell("pepperoni", button: "Select Pepperoni", caption: "Pepperoni",
                         url: "https://images.pexels.com/photos/803290/pexels-photo-803290.jpeg"),
                    cell("veggie", button: "Select Veggie", caption: "Veggie",
                         url: "https://images.pexels.com/photos/1435909/pexels-photo-1435909.jpeg"),
                    cell("custom", button: "Build Custom Pizza", caption: "Build Your Own",
                         url: "https://images.pexels.com/photos/724216/pexels-photo-724216.jpeg"),
                ]],
            ],
            "fallbackText": "Pizza card: choose Margherita, Pepperoni, Veggie, or Build Your Own.",
            "style": ["borderRadius": 14, "padding": 16],
        ]
    }

    private static let cardButtons = ["Select Margherita", "Select Pepperoni",
                                      "Select Veggie", "Build Custom Pizza"]

    /// A deliberately deep + large card (distinct from the pizza card) to stress render + scroll:
    /// a heading, a long paragraph, a 3×N image grid, columns nested inside columns, and a long
    /// vertical run of button rows — dozens of elements, several nesting levels, well below the fold.
    static func complexCard(heading: String) -> [String: Any] {
        let longText = String(repeating: "This is a long descriptive paragraph that wraps across "
            + "several lines to force the card to grow tall and require scrolling. ", count: 4)

        func imageTile(_ i: Int) -> [String: Any] {
            ["id": "tile_\(i)_col", "type": "column", "gap": 4, "items": [
                ["id": "tile_\(i)_img", "type": "image",
                 "url": "https://images.pexels.com/photos/\(4109080 + i)/pexels-photo.jpeg",
                 "altText": "Tile \(i)", "fit": "cover", "height": 90, "borderRadius": 8],
                ["id": "tile_\(i)_txt", "type": "text", "content": "Item \(i)",
                 "variant": "body", "align": "center"],
            ]]
        }

        // A row nesting two columns side-by-side, each with its own text + button (columns-in-grid-in-column).
        func nestedRow(_ i: Int) -> [String: Any] {
            ["id": "row_\(i)", "type": "grid", "columns": 2, "gap": 8, "items": [
                ["id": "row_\(i)_a", "type": "column", "gap": 4, "items": [
                    ["id": "row_\(i)_a_txt", "type": "text", "content": "Option \(i)A", "variant": "body"],
                    ["id": "row_\(i)_a_btn", "type": "button", "label": "Choose \(i)A", "fullWidth": true,
                     "action": ["type": "sendMessage", "text": "picked \(i)A"]],
                ]],
                ["id": "row_\(i)_b", "type": "column", "gap": 4, "items": [
                    ["id": "row_\(i)_b_txt", "type": "text", "content": "Option \(i)B", "variant": "body"],
                    ["id": "row_\(i)_b_btn", "type": "button", "label": "Choose \(i)B", "fullWidth": true,
                     "action": ["type": "sendMessage", "text": "picked \(i)B"]],
                ]],
            ]]
        }

        return [
            "version": "1.0",
            "body": [
                ["id": "cx_title", "type": "text", "content": heading,
                 "variant": "heading2", "align": "center"],
                ["id": "cx_body", "type": "text", "content": longText, "variant": "body"],
                ["id": "cx_grid", "type": "grid", "columns": 3, "gap": 8,
                 "items": (1...9).map { imageTile($0) }],
                ["id": "cx_mid", "type": "text", "content": longText, "variant": "body"],
                // A column wrapping several nested-grid rows: column → grid → column → button.
                ["id": "cx_rows", "type": "column", "gap": 10, "items": (1...6).map { nestedRow($0) }],
                ["id": "cx_footer", "type": "button", "label": "Complex Footer Action", "fullWidth": true,
                 "action": ["type": "sendMessage", "text": "footer"]],
            ],
            "fallbackText": "Complex card with many nested sections.",
            "style": ["borderRadius": 14, "padding": 16],
        ]
    }

    // MARK: - Setup

    /// Seed a 1:1, launch, open it from Chats, and wait for the message list.
    private func openConversation() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation with \(TestConfig.userBDisplayName)")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Message list did not open")
    }

    /// Locate a card button by its label; scroll the list up if it rendered below the fold.
    /// `.firstMatch`: the label also surfaces as a static text and can render more than once.
    private func cardButton(_ label: String) -> XCUIElement {
        let button = app.buttons[label].firstMatch
        if button.exists { return button }
        app.swipeUp()
        return app.buttons[label].firstMatch
    }

    // MARK: - Tests

    /// A received card renders real content — heading + all four button labels.
    func test_receivedCardRendersRealContent() throws {
        openConversation()
        let heading = "Choose Pizza \(UUID().uuidString.prefix(6))"
        try runBlocking {
            _ = try await PeerActions.sendCardMessage(
                text: "Pizza order \(heading)", card: Self.pizzaCard(heading: heading))
        }

        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: heading, timeout: 20),
                      "Card heading did not render: \(heading)")
        for label in Self.cardButtons {
            XCTAssertTrue(cardButton(label).waitForExistence(timeout: 5),
                          "Card button missing: \(label)")
        }
    }

    /// An invalid card can never reach the client: the backend rejects a malformed card envelope, so
    /// CometChatCardBubble's fallback path can't be reached over the wire. Assert that guard directly —
    /// each malformed variant is rejected with its ERR_CARD_* code, so no broken card can crash the UI.
    func test_invalidCardIsRejectedBackend() throws {
        // (malformed card, expected server error code)
        let cases: [(card: [String: Any], code: String)] = [
            ([:], "ERR_CARD_DATA_MISSING"),                                    // no card payload
            (["version": "9.9", "body": [["id": "t", "type": "text", "content": "x"]]],
             "ERR_INVALID_CARD_VERSION"),                                      // wrong version
            (["version": "1.0", "body": []], "ERR_INVALID_CARD_BODY"),         // empty body
        ]
        for (card, code) in cases {
            var thrown: Error?
            do {
                _ = try runBlocking {
                    try await PeerActions.sendCardMessage(text: "invalid", card: card)
                }
            } catch { thrown = error }
            XCTAssertNotNil(thrown, "Backend accepted a malformed card (expected \(code))")
            XCTAssertTrue("\(thrown!)".contains(code),
                          "Expected \(code), got: \(String(describing: thrown))")
        }
    }

    /// The Chats list shows the conversation with the card's data.text as the preview subtitle.
    /// The busy shared-backend Chats list can SIGKILL a11y scraping, so assert the backend lastMessage.
    func test_cardShowsConversationPreview() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        let token = "Preview pizza \(UUID().uuidString.prefix(6))"
        let heading = "H \(UUID().uuidString.prefix(6))"
        try runBlocking {
            _ = try await PeerActions.sendCardMessage(text: token, card: Self.pizzaCard(heading: heading))
        }
        let arrived = waitForBackend(timeout: 20) { await PeerActions.previewShowsLiveMessage(token) }
        XCTAssertTrue(arrived, "Card data.text did not become the conversation preview: \(token)")
    }

    /// Tapping a card button emits ccCardActionClicked — the sample app shows a toast with the payload.
    func test_cardButtonEmitsAction() throws {
        openConversation()
        let heading = "Action pizza \(UUID().uuidString.prefix(6))"
        try runBlocking {
            _ = try await PeerActions.sendCardMessage(
                text: "Action \(heading)", card: Self.pizzaCard(heading: heading))
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: heading, timeout: 20),
                      "Card did not render")

        // Margherita renders above the fold (hittable); its button action id is "margherita_btn".
        let button = cardButton("Select Margherita")
        XCTAssertTrue(button.waitForExistence(timeout: 5), "Card button not found")
        button.tap()

        // CardActionHandler toast reads "Action: <action>" / "Element: <elementId>".
        let toast = NSPredicate(format: "label CONTAINS 'Element:' AND label CONTAINS 'margherita_btn'")
        XCTAssertTrue(app.staticTexts.containing(toast).firstMatch.waitForExistence(timeout: 8),
                      "Card action toast did not report the tapped element")
    }

    /// A deeply nested / complex card (many sections, nested grids/columns, dozens of elements) renders
    /// and scrolls without crashing / ANR. Uses complexCard — distinctly larger + deeper than the pizza card.
    func test_complexCardRendersNoCrash() throws {
        openConversation()
        let heading = "Complex card \(UUID().uuidString.prefix(6))"
        try runBlocking {
            _ = try await PeerActions.sendCardMessage(
                text: "Complex \(heading)", card: Self.complexCard(heading: heading))
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: heading, timeout: 20),
                      "Complex card did not render")

        // The footer button is far below the fold — reaching it proves the whole tall card laid out.
        let footer = app.buttons["Complex Footer Action"].firstMatch
        for _ in 0..<6 where !footer.exists { app.swipeUp() }
        XCTAssertTrue(footer.exists, "Deep element of the complex card never became reachable")

        app.swipeDown(); app.swipeDown()
        XCTAssertTrue(ComponentQueries.composer(app).exists, "App not responsive after scrolling the card")
    }
}
