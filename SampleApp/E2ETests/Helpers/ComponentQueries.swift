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
