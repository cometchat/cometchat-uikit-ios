import XCTest

enum ComponentQueries {

    static func composer(_ app: XCUIApplication) -> XCUIElement {
        app.textViews.firstMatch
    }

    static func sendButton(_ app: XCUIApplication) -> XCUIElement {
        let labeled = app.buttons["Send"]
        if labeled.exists { return labeled }
        let all = app.buttons
        if all.count > 0 { return all.element(boundBy: all.count - 1) }
        return labeled // return the labeled query so a failed assertion reports "Send"
    }

    /// Bubbles surface as buttons (the gesture wrapper), not staticTexts; pass a unique per-run token.
    static func bubble(_ app: XCUIApplication, text: String) -> XCUIElement {
        // .firstMatch: the same token can render twice (bubble + preview); multi-match actions throw.
        let asButton = app.buttons[text].firstMatch
        if asButton.exists { return asButton }
        return app.staticTexts[text].firstMatch
    }

    /// Swipe-to-reply the way the kit actually recognises it. `CometChatMessageBubble` attaches a
    /// `UISwipeGestureRecognizer` (direction `.right` for both alignments) to the bubble stack —
    /// a flick recogniser, so the gesture needs velocity and must start on the bubble.
    /// `XCUIElement.swipeRight()` on the bubble's label is a short, gentle drag scaled to that
    /// small element and never reaches flick speed, which read as "swipe-to-reply is broken" for
    /// two runs. A fast, fixed-length drag from inside the bubble triggers it — the same
    /// slightly-brisk swipe a finger needs — provided the touch does not pause first: a swipe
    /// recogniser fails a touch that sits still before moving, so both hold durations are zero.
    ///
    /// The flick must also land on a bubble that is done moving. Tests seed the message over
    /// REST right after opening the chat, and the list is still reloading (shimmer, then the
    /// "New" divider re-layout) when the bubble first matches — a swipe issued then hits a cell
    /// that is being replaced, which is what the recordings of the failed runs show. So: wait
    /// for the bubble to be hittable with a frame that holds still, flick, and if no reply
    /// preview follows, flick once more.
    static func swipeToReply(_ bubble: XCUIElement, app: XCUIApplication? = nil) {
        _ = bubble.waitForExistence(timeout: 10)
        var last = bubble.frame
        let deadline = Date().addingTimeInterval(8)
        while Date() < deadline {
            _ = bubble.waitForExistence(timeout: 0.4)
            let now = bubble.frame
            if bubble.isHittable, now == last, now.width > 0 { break }
            last = now
        }
        flick(bubble)
        guard let app else { return }
        if !replyPreviewClose(app).waitForExistence(timeout: 3) {
            flick(bubble)
        }
    }

    private static func flick(_ bubble: XCUIElement) {
        let start = bubble.coordinate(withNormalizedOffset: CGVector(dx: 0.25, dy: 0.5))
        let end = start.withOffset(CGVector(dx: 220, dy: 0))
        start.press(forDuration: 0, thenDragTo: end, withVelocity: .fast, thenHoldForDuration: 0)
    }

    /// The reply preview strip's close control (`CometChatMessagePreview.closeButton`, labelled
    /// with the a11y_close key) — the one element that only exists while a preview is open.
    private static func replyPreviewClose(_ app: XCUIApplication) -> XCUIElement {
        app.buttons["Close"].firstMatch
    }

    static func typeAndSend(_ app: XCUIApplication, text: String) {
        let field = composer(app)
        XCTAssertTrue(field.waitForExistence(timeout: 10), "Composer text view did not appear")
        field.tap()
        field.typeText(text)

        let send = sendButton(app)
        XCTAssertTrue(send.waitForExistence(timeout: 5), "Send button did not appear")
        send.tap()
    }

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

    /// A bubble carries its text as its OWN label, so it must be selected with `matching(_:)`.
    /// `containing(_:)` filters by DESCENDANTS and so never matched a bubble — it reported
    /// "message did not arrive" for messages plainly on screen. Both forms are tried, so
    /// callers that relied on a descendant match keep working.
    @discardableResult
    static func waitForBubbleContaining(_ app: XCUIApplication, substring: String, timeout: TimeInterval = 12) -> Bool {
        let predicate = NSPredicate(format: "label CONTAINS %@", substring)
        let candidates = [
            app.buttons.matching(predicate).firstMatch,
            app.staticTexts.matching(predicate).firstMatch,
            app.buttons.containing(predicate).firstMatch,
            app.staticTexts.containing(predicate).firstMatch,
        ]
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if candidates.contains(where: { $0.exists }) { return true }
            _ = candidates[0].waitForExistence(timeout: 0.5)
        }
        return candidates.contains { $0.exists }
    }

    /// For a 1:1 the header subtitle is exactly "Typing..." (no sender name); the name-prefixed form is group-only.
    static func waitForTypingIndicator(_ app: XCUIApplication, timeout: TimeInterval = 8) -> Bool {
        if app.staticTexts["Typing..."].waitForExistence(timeout: timeout) { return true }
        let predicate = NSPredicate(format: "label BEGINSWITH 'Typing'")
        return app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: 1)
    }

    static func waitForGroupTypingIndicator(_ app: XCUIApplication, name: String? = nil, timeout: TimeInterval = 8) -> Bool {
        let format = name.map { _ in "label CONTAINS %@ AND label CONTAINS %@" } ?? "label CONTAINS %@"
        let predicate = name.map { NSPredicate(format: format, $0, "is typing") }
            ?? NSPredicate(format: format, "is typing")
        return app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: timeout)
    }

    /// The header subtitle is exactly "Online" (`ONLINE`.localize()).
    static func waitForOnlineIndicator(_ app: XCUIApplication, timeout: TimeInterval = 12) -> Bool {
        app.staticTexts["Online"].waitForExistence(timeout: timeout)
    }

    /// Offline text is time-dependent ("Offline" vs "Last seen ..."), so match on absence of "Online".
    static func waitForOnlineIndicatorToClear(_ app: XCUIApplication, timeout: TimeInterval = 12) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if !app.staticTexts["Online"].exists { return true }
            _ = app.staticTexts["Online"].waitForExistence(timeout: 0.5)
        }
        return !app.staticTexts["Online"].exists
    }

    /// An empty UITextView reports "" on some iOS versions and the placeholder string on others; accept either.
    static func composerIsEmpty(_ app: XCUIApplication, placeholder: String? = nil) -> Bool {
        let value = (composer(app).value as? String) ?? ""
        if value.isEmpty { return true }
        if let placeholder, value == placeholder { return true }
        return false
    }

    @discardableResult
    static func openMessageOptions(_ app: XCUIApplication, bubbleText: String, duration: TimeInterval = 1.2) -> Bool {
        let target = bubble(app, text: bubbleText)
        guard target.waitForExistence(timeout: 10) else { return false }
        target.press(forDuration: duration)
        return true
    }

    enum MessageOption {
        static let edit = "Edit"
        static let delete = "Delete"
        static let copy = "Copy"
        static let replyInThread = "Reply in Thread"
        static let info = "Info"
    }

    /// The "More…" row the message-options popup appends when it has overflow. Since 5.1.22
    /// (pin & save) only `MessageOptionConstants.primaryOptionIds` — Reply, Reply in Thread,
    /// thread subscription, Copy, Edit, Delete, Message privately — render inline; Info, Share,
    /// Pin, Save, Mark as unread and Flag all sit behind this row. Its title is "More…" with a
    /// real ellipsis (MORE_OPTIONS). Two traps, both hit: the rows are exposed as `Cell`
    /// elements carrying the title as their label (the button trait does not make them
    /// `buttons`), and the message header's "•••" is a *button* labelled plain "More" — a
    /// prefix match on `buttons` tapped that instead and dismissed the popup.
    private static func moreOptionsRow(_ app: XCUIApplication) -> XCUIElement {
        app.cells.matching(NSPredicate(format: "label == %@", "More…")).firstMatch
    }

    /// The popup row for `label`, or nil. If the row is not on the first screen but a "More…"
    /// row is, expands it once and looks again — so callers never need to know which options
    /// the kit currently classifies as overflow.
    ///
    /// `ContextMenuTextCell` sets `isAccessibilityElement = true` and carries the title as its
    /// own `accessibilityLabel`, which collapses the cell: its `titleLabel` leaves the a11y
    /// tree entirely. So `cells.containing(.staticText,…)` and `staticTexts[label]` cannot
    /// match a popup row — they filter on descendants that no longer exist. Matching the
    /// cell's OWN label is the query that works, and it must be an equality predicate:
    /// `cells[label]` is a prefix/partial match and "More" would also select "More…".
    static func messageOption(_ app: XCUIApplication, label: String, timeout: TimeInterval = 6) -> XCUIElement? {
        func find() -> XCUIElement? {
            let asButton = app.buttons[label].firstMatch
            if asButton.exists { return asButton }
            let asCell = app.cells.matching(NSPredicate(format: "label == %@", label)).firstMatch
            if asCell.exists { return asCell }
            // Retained for any row the kit does not expose as a collapsed cell.
            let asLegacyCell = app.cells.containing(.staticText, identifier: label).firstMatch
            if asLegacyCell.exists { return asLegacyCell }
            let asText = app.staticTexts[label].firstMatch
            if asText.exists { return asText }
            return nil
        }
        let deadline = Date().addingTimeInterval(timeout)
        var expandedMore = false
        while Date() < deadline {
            if let row = find() { return row }
            if !expandedMore, moreOptionsRow(app).exists {
                moreOptionsRow(app).tap()
                expandedMore = true
                continue
            }
            _ = app.buttons[label].firstMatch.waitForExistence(timeout: 0.5)
        }
        return find()
    }

    /// True when the popup offers `label`, expanding "More…" if that is where it lives.
    static func messageOptionExists(_ app: XCUIApplication, label: String, timeout: TimeInterval = 6) -> Bool {
        messageOption(app, label: label, timeout: timeout) != nil
    }

    @discardableResult
    static func tapMessageOption(_ app: XCUIApplication, label: String, timeout: TimeInterval = 6) -> Bool {
        guard let row = messageOption(app, label: label, timeout: timeout) else { return false }
        row.tap()
        return true
    }

    static func waitForEditedMarker(_ app: XCUIApplication, timeout: TimeInterval = 10) -> Bool {
        let predicate = NSPredicate(format: "label BEGINSWITH 'Edited'")
        return app.staticTexts.containing(predicate).firstMatch.waitForExistence(timeout: timeout)
    }

    static func waitForDeletedPlaceholder(_ app: XCUIApplication, timeout: TimeInterval = 10) -> Bool {
        app.staticTexts["This message was deleted"].waitForExistence(timeout: timeout)
    }

    /// The header's "More" UIMenu opens under XCUITest (unlike the avatar logout menu); its items surface as buttons, not menuItems.
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

    enum HeaderMenu {
        static let userInfo = "User Info"
        static let groupInfo = "Group Info"
    }

    enum ComposerPlaceholder {
        private static let primary = "Type a Message here"
        private static let alternate = "Type your message here..."
        static let all = [primary, alternate]
    }

    /// The placeholder is custom-drawn and never enters the a11y tree (XCUITest is out-of-process), so assert the verifiable equivalent: the composer exists and is empty.
    static func composerShowsPlaceholder(_ app: XCUIApplication) -> Bool {
        let field = composer(app)
        guard field.exists else { return false }
        let value = (field.value as? String) ?? ""
        if ComposerPlaceholder.all.contains(value) { return true }
        if ComposerPlaceholder.all.contains(where: { app.staticTexts[$0].exists }) { return true }
        return value.isEmpty
    }

    /// The confirm button reuses the action's own verb (Block / Delete), so try several labels.
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

    /// The custom header hides the nav bar and its back control is an image-only button with no a11y label, so it can only be located positionally.
    /// Brittle by nature; an accessibilityIdentifier on the framework header button would make this exact.
    static func headerBackButton(_ app: XCUIApplication) -> XCUIElement? {
        app.buttons.allElementsBoundByIndex
            .filter { $0.exists && $0.frame.minY < 160 && $0.frame.minX < 80 }
            .sorted { $0.frame.minX < $1.frame.minX }
            .first
    }

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

    static func attachmentAffordanceExists(_ app: XCUIApplication) -> Bool {
        let known = app.buttons.matching(NSPredicate(format:
            "label CONTAINS[c] 'attach' OR label CONTAINS[c] 'add' OR label CONTAINS[c] 'camera' OR label CONTAINS[c] 'media' OR label CONTAINS[c] 'plus'"
        )).firstMatch
        if known.exists { return true }
        return app.buttons.allElementsBoundByIndex.contains { $0.exists && $0.label != "Send" && $0.frame.minY > 300 }
    }
}
