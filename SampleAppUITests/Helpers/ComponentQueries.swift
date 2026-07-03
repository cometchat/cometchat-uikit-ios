import XCTest

/// Content-query layer for elements INSIDE CometChat UIKit framework components.
///
/// Accessbility identifiers exist only on SampleApp-owned screens (Login, Home
/// tabs). Anything inside a framework component (message list / header / composer) must be located
/// by content — `staticTexts` / `cells` / `textViews`. This file centralizes
/// those locators.
///
/// Locator notes:
/// - Send button: the compact composer's send button sets `accessibilityLabel = "Send"`, so
///   `buttons["Send"]` resolves for regular users. `sendButton(_:)` keeps a position fallback.
/// - Bubbles: message bubbles surface as buttons (the tap/long-press gesture wrapper), reachable via
///   `buttons[text]`, falling back to `staticTexts[text]`. Always assert on a UNIQUE per-run token to
///   avoid matching a stale bubble on the shared backend.
/// - Composer empty value: an empty `UITextView` reports either "" or the placeholder string
///   depending on iOS version — `composerIsEmpty(_:)` accepts both.
enum ComponentQueries {

    // MARK: - Composer

    /// The message composer's text input (a `UITextView`).
    static func composer(_ app: XCUIApplication) -> XCUIElement {
        app.textViews.firstMatch
    }

    /// The composer's Send button.
    ///
    /// Primary match is by label "Send" (the compact composer sets `accessibilityLabel = "Send"`).
    /// If that ever fails to resolve (e.g. an unlabeled composer variant or a localization change),
    /// fall back to the last button on screen, which in the composer layout is the rightmost
    /// (send) control. Callers should `waitForExistence` before tapping.
    static func sendButton(_ app: XCUIApplication) -> XCUIElement {
        let labeled = app.buttons["Send"]
        if labeled.exists { return labeled }
        // Position fallback: rightmost/last button (send sits at the trailing edge of the composer).
        let all = app.buttons
        if all.count > 0 { return all.element(boundBy: all.count - 1) }
        return labeled // return the labeled query so a failed assertion reports "Send"
    }

    /// Text bubbles surface as buttons (the tap/long-press gesture wrapper), not static texts; the
    /// latter are only timestamps/headers. Fall back to static texts for older variants. Pass a
    /// unique per-run token.
    static func bubble(_ app: XCUIApplication, text: String) -> XCUIElement {
        // `.firstMatch` — the same token can render in more than one place (list bubble + preview), and
        // acting on a multi-match query throws "Multiple matching elements found".
        let asButton = app.buttons[text].firstMatch
        if asButton.exists { return asButton }
        return app.staticTexts[text].firstMatch
    }

    // MARK: - Actions

    /// Type `text` into the composer and tap Send. Does not wait for the bubble — callers assert.
    static func typeAndSend(_ app: XCUIApplication, text: String) {
        let field = composer(app)
        XCTAssertTrue(field.waitForExistence(timeout: 10), "Composer text view did not appear")
        field.tap()
        field.typeText(text)

        let send = sendButton(app)
        XCTAssertTrue(send.waitForExistence(timeout: 5), "Send button did not appear")
        send.tap()
    }

    /// Polls both element types since the bubble's class isn't known until it renders, and waits on
    /// the async WebSocket delivery rather than sleeping.
    @discardableResult
    static func waitForBubble(_ app: XCUIApplication, text: String, timeout: TimeInterval = 10) -> Bool {
        let asButton = app.buttons[text]
        let asText = app.staticTexts[text]
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if asButton.exists || asText.exists { return true }
            _ = asButton.waitForExistence(timeout: 0.5)
        }
        return asButton.exists || asText.exists
    }

    /// Like `waitForBubble` but matches a bubble whose label CONTAINS `substring` — for messages sent with
    /// extra surrounding text (long body + tail token, "@mention hi tail", "see <url> tail") where the
    /// bubble's accessibility label is the whole message, not just the token. Pass a unique token.
    @discardableResult
    static func waitForBubbleContaining(_ app: XCUIApplication, substring: String, timeout: TimeInterval = 12) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", substring)
        let asButton = app.buttons.containing(predicate).firstMatch
        let asText = app.staticTexts.containing(predicate).firstMatch
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if asButton.exists || asText.exists { return true }
            _ = asButton.waitForExistence(timeout: 0.5)
        }
        return asButton.exists || asText.exists
    }

    // MARK: - Typing indicator

    /// A live 1:1 typing indicator renders in the header subtitle. Verified against
    /// `CometChatMessageHeader.updateTypingStatus`: for a 1:1 the subtitle is exactly the `TYPING`
    /// localization — `"Typing..."` (NO sender name). The name-prefixed `"<name> is typing..."` form is
    /// group-only (see `waitForGroupTypingIndicator`). Match the exact string, with a tolerant
    /// BEGINSWITH fallback in case capitalization varies across a build.
    static func waitForTypingIndicator(_ app: XCUIApplication, timeout: TimeInterval = 8) -> Bool {
        if app.staticTexts["Typing..."].waitForExistence(timeout: timeout) { return true }
        let predicate = NSPredicate(format: "label BEGINSWITH 'Typing'")
        return app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: 1)
    }

    /// A live GROUP typing indicator renders the sender name: `"<name> is typing..."` (`IS_TYPING`).
    /// Match `CONTAINS 'is typing'` (name-agnostic); optionally require the name too.
    static func waitForGroupTypingIndicator(_ app: XCUIApplication, name: String? = nil, timeout: TimeInterval = 8) -> Bool {
        let format = name.map { _ in "label CONTAINS %@ AND label CONTAINS %@" } ?? "label CONTAINS %@"
        let predicate = name.map { NSPredicate(format: format, $0, "is typing") }
            ?? NSPredicate(format: format, "is typing")
        return app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: timeout)
    }

    /// True if the composer is empty. An empty `UITextView` reports "" on some iOS versions and the
    /// placeholder string on others, so accept either. Pass the known placeholder if available.
    static func composerIsEmpty(_ app: XCUIApplication, placeholder: String? = nil) -> Bool {
        let value = (composer(app).value as? String) ?? ""
        if value.isEmpty { return true }
        if let placeholder, value == placeholder { return true }
        return false
    }

    // MARK: - Message options (long-press popup)

    /// Long-press a rendered bubble to open the message-options popup. The popup is the UIKit
    /// `MessagePopupViewController` (a blurred-snapshot modal, not a UIAlertController) whose option rows
    /// surface as buttons labelled with the localized action text (Edit / Delete / Copy / Reply / Info).
    /// Verified automatable: the popup presents and its rows are reachable. Returns true if the bubble
    /// was found and long-pressed.
    @discardableResult
    static func openMessageOptions(_ app: XCUIApplication, bubbleText: String, duration: TimeInterval = 1.2) -> Bool {
        let target = bubble(app, text: bubbleText)
        guard target.waitForExistence(timeout: 10) else { return false }
        target.press(forDuration: duration)
        return true
    }

    /// English labels from the message-options popup (resolved from the UIKit `en.lproj` strings).
    /// The popup rows are not AX-identified, so we match by visible text.
    enum MessageOption {
        static let edit = "Edit"
        static let delete = "Delete"
        static let copy = "Copy"
        static let replyInThread = "Reply in Thread"
        static let info = "Info"
    }

    /// Tap an option row in the open message-options popup. Rows surface as buttons; fall back to a cell
    /// or static text containing the label for layout variants. Uses `.firstMatch` throughout — the same
    /// label can resolve to more than one element (e.g. a popup row plus a formatting-toolbar button), and
    /// tapping a multi-match query throws "Multiple matching elements found".
    @discardableResult
    static func tapMessageOption(_ app: XCUIApplication, label: String, timeout: TimeInterval = 6) -> Bool {
        let asButton = app.buttons[label].firstMatch
        if asButton.waitForExistence(timeout: timeout) {
            asButton.tap()
            return true
        }
        let asCell = app.cells.containing(.staticText, identifier: label).firstMatch
        if asCell.exists {
            asCell.tap()
            return true
        }
        let asText = app.staticTexts[label].firstMatch
        if asText.exists {
            asText.tap()
            return true
        }
        return false
    }

    /// The "edited" marker is prepended to the message timestamp ("Edited  2:34 PM"), so match a
    /// staticText that begins with "Edited".
    static func waitForEditedMarker(_ app: XCUIApplication, timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "label BEGINSWITH 'Edited'")
        return app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: timeout)
    }

    /// The deleted-message placeholder bubble shows this exact English text.
    static func waitForDeletedPlaceholder(_ app: XCUIApplication, timeout: TimeInterval = 10) -> Bool {
        app.staticTexts["This message was deleted"].waitForExistence(timeout: timeout)
    }

    // MARK: - Message header overflow menu

    /// Open the message header's overflow menu and tap "User Info" / "Group Info" to push the details
    /// screen. The header's ellipsis surfaces as `buttons["More"]` and its `showsMenuAsPrimaryAction`
    /// UIMenu — unlike the avatar logout menu — DOES open under XCUITest: tapping "More" presents the
    /// menu whose items become accessible BUTTONS ("User Info"/"Group Info"), not `menuItems`. Verified.
    /// - Parameter infoLabel: "User Info" for a 1:1, "Group Info" for a group.
    /// - Returns: true if the menu opened and the info item was tapped.
    @discardableResult
    static func openHeaderDetails(_ app: XCUIApplication, infoLabel: String, timeout: TimeInterval = 8) -> Bool {
        let more = app.buttons["More"]
        guard more.waitForExistence(timeout: timeout) else { return false }
        more.tap()

        let info = app.buttons[infoLabel]
        guard info.waitForExistence(timeout: timeout) else { return false }
        info.tap()
        return true
    }

    /// Labels for the header overflow menu's info item.
    enum HeaderMenu {
        static let userInfo = "User Info"
        static let groupInfo = "Group Info"
    }

    /// The composer's empty-state placeholder strings (`en.lproj`: TYPE_A_MESSAGE / COMPOSER_PLACEHOLDER).
    /// Kept for reference, but NOT queryable on iOS — see `composerShowsPlaceholder`.
    enum ComposerPlaceholder {
        private static let primary = "Type a Message here"
        private static let alternate = "Type your message here..."
        static let all = [primary, alternate]
    }

    /// True if the composer is in its empty placeholder state. The UIKit composer draws its placeholder
    /// directly on a custom `UITextView` subclass (a painted `placeholder: String?`, not a label), so the
    /// string is NOT in the accessibility tree — neither the field's `.value`/`.placeholderValue` nor any
    /// static text exposes it (verified: both come back empty). LIMITATION (per Apple docs): the relevant
    /// API, `XCUIElement.placeholderValue`, only reflects what the control published to accessibility;
    /// `UITextView` has no native placeholder, and a custom-drawn one is invisible to XCUITest unless the
    /// app sets `accessibilityValue` — a framework edit we don't make. (XCUITest is out-of-process and
    /// can't read drawn pixels, so it never sees a custom-drawn hint.)
    /// So XCUITest can only assert the verifiable equivalent: the composer text input exists and is EMPTY —
    /// the same fallback used when the hint isn't directly readable.
    static func composerShowsPlaceholder(_ app: XCUIApplication) -> Bool {
        let field = composer(app)
        guard field.exists else { return false }
        // Accept the placeholder if a build ever surfaces it; otherwise require an empty field.
        let value = (field.value as? String) ?? ""
        if ComposerPlaceholder.all.contains(value) { return true }
        if ComposerPlaceholder.all.contains(where: { app.staticTexts[$0].exists }) { return true }
        return value.isEmpty
    }

    /// Confirm a destructive action in the system alert. The confirm button reuses the action's own verb:
    /// the block alert's confirm is "Block", delete-chat's is "Delete" (see SampleApp UserDetailsVC →
    /// showAlert). "Yes"/"Confirm"/"OK" cover other dialogs. Taps whichever appears, as a button or an
    /// alert button. Returns true if a confirm control was tapped.
    @discardableResult
    static func confirmDestructiveAction(_ app: XCUIApplication, timeout: TimeInterval = 6) -> Bool {
        let labels = ["Block", "Delete", "Yes", "Confirm", "OK"]
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            for label in labels {
                let asButton = app.buttons[label]
                if asButton.exists && asButton.isHittable { asButton.tap(); return true }
                let asAlert = app.alerts.buttons[label]
                if asAlert.exists { asAlert.tap(); return true }
            }
            _ = app.buttons.firstMatch.waitForExistence(timeout: 0.4)
        }
        return false
    }

    // MARK: - Header back button

    /// The custom message/thread/group header hides the nav bar, and its back control is an image-only
    /// button with NO accessibility label, so it can only be located positionally: the top-left-most
    /// hittable button in the header region (`minY < 160 && minX < 80`, then smallest x).
    ///
    /// FLAG: this heuristic is brittle by nature — a robust fix needs an `accessibilityIdentifier` on the
    /// framework header button (e.g. `CometChatMessageHeader`), which is out of the test target's scope.
    /// Centralized here so all callers share one locator until that hook exists.
    static func headerBackButton(_ app: XCUIApplication) -> XCUIElement? {
        app.buttons.allElementsBoundByIndex
            .filter { $0.exists && $0.frame.minY < 160 && $0.frame.minX < 80 }
            .sorted { $0.frame.minX < $1.frame.minX }
            .first
    }

    // MARK: - Create-group screen

    /// True if the create-group screen is showing. Its title/button/field strings come from `.localize()`
    /// keys that may render as the raw key when untranslated, so probe several forms plus the Public/Private
    /// type markers; any one appearing confirms the screen.
    static func createGroupScreenVisible(_ app: XCUIApplication, timeout: TimeInterval) -> Bool {
        let candidates: [XCUIElement] = [
            app.staticTexts["New Group"], app.staticTexts["NEW_GROUP"],
            app.buttons["Create Group"], app.buttons["CREATE_GROUP"], app.staticTexts["Create Group"],
            app.textFields["Enter group name"], app.textFields["ENTER_GROUP_NAME"],
            app.staticTexts["Public"], app.staticTexts["Private"],
        ]
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if candidates.contains(where: { $0.exists }) { return true }
            _ = candidates[0].waitForExistence(timeout: 0.5)
        }
        return candidates.contains(where: { $0.exists })
    }

    // MARK: - Composer attachment affordance

    /// True if the composer exposes an attachment affordance beside Send. The add/attach control's label
    /// varies (Attach/Add/paperclip) and may be an unlabeled icon, so accept a known label OR any non-Send
    /// button in the composer region (lower part of the screen) — never just "≥2 buttons exist", which the
    /// header alone satisfies.
    static func attachmentAffordanceExists(_ app: XCUIApplication) -> Bool {
        let known = app.buttons.matching(NSPredicate(format:
            "label CONTAINS[c] 'attach' OR label CONTAINS[c] 'add' OR label CONTAINS[c] 'camera' OR label CONTAINS[c] 'media' OR label CONTAINS[c] 'plus'"
        )).firstMatch
        if known.exists { return true }
        return app.buttons.allElementsBoundByIndex.contains { $0.exists && $0.label != "Send" && $0.frame.minY > 300 }
    }
}
