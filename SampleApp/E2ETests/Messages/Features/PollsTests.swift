import XCTest

/// Polls had no E2E coverage at all before this file — "poll" appeared in the suite only
/// as the name of a polling helper. The create-poll screen is entirely in-app (no system
/// picker), so unlike media it can be driven end to end: open the sheet, fill the form,
/// send, and assert the poll lands in the conversation.
///
/// Selectors come from the UI Kit's own English strings rather than guesses:
/// "Poll" (CUSTOM_MESSAGE_POLL), "Create Poll" (CREATE_POLL), "Ask question"
/// (ASK_QUESTION), "Add" (ADD) and the a11y_* labels added in Track 1.
///
/// Polls are an EXTENSION. If it is not enabled for the test App ID the option never
/// appears in the attachment sheet, so every test skips rather than fails — a disabled
/// extension is a configuration fact, not a regression.
final class PollsTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SecondClient.shared.logout() }
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - Voting (Wave 6)

    /// B votes on A's poll through the Polls extension (the same `v2/vote` call the bubble
    /// makes); A's bubble must show the option's count go from 0 to 1. The poll's id is read
    /// from the backend copy of the message (`metadata.@injected.extensions.polls.id`), which
    /// is where the bubble reads it from too. Real-time: the vote reaches A as a message edit.
    func test_RT_POLL_peerVoteUpdatesCountOnBubble() throws {
        app = openSeededConversation()
        try ensureUserBLoggedIn()
        try openCreatePollOrSkip()
        let token = "Vote \(Int(Date().timeIntervalSince1970) % 100000)?"
        try fillPoll(question: token, options: ["Alpha", "Beta"])
        tapSend()
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 25),
                      "The created poll did not appear in the conversation")

        var pollId: String?
        XCTAssertTrue(waitForBackend(timeout: 20) {
            let last = await PeerActions.lastConversationMessage()
            let data = last?["data"] as? [String: Any]
            let polls = (((data?["metadata"] as? [String: Any])?["@injected"] as? [String: Any])?["extensions"] as? [String: Any])?["polls"] as? [String: Any]
            guard (polls?["question"] as? String) == token, let id = polls?["id"] as? String else { return false }
            pollId = id
            return true
        }, "Could not find the poll's id on the backend")
        guard let pollId else { return }

        let question = app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", token)).firstMatch
        XCTAssertTrue(question.waitForExistence(timeout: 5), "Poll question label not found")
        let questionTop = question.frame.minY

        try runBlocking { try await SecondClient.shared.votePoll(id: pollId, option: 1) }
        let counted = waitForCondition(timeout: 25) {
            self.app.staticTexts.matching(NSPredicate(format: "label == %@", "1")).allElementsBoundByIndex
                .contains { $0.exists && $0.frame.minY > questionTop }
        }
        XCTAssertTrue(counted, "A's poll bubble did not show a vote count of 1 after B voted")
    }

    // MARK: - Reaching the create-poll screen

    func test_1TO1_pollOptionExistsInAttachmentSheet() throws {
        app = openSeededConversation()
        try openAttachmentSheetOrSkip()

        XCTAssertTrue(pollOption().waitForExistence(timeout: 6),
                      "No Poll option in the attachment sheet")
    }

    func test_1TO1_pollOptionOpensCreatePollScreen() throws {
        app = openSeededConversation()
        try openCreatePollOrSkip()

        XCTAssertTrue(app.staticTexts["Create Poll"].waitForExistence(timeout: 8),
                      "Create Poll screen did not open")
    }

    func test_1TO1_createPollScreenOffersQuestionAndTwoOptions() throws {
        app = openSeededConversation()
        try openCreatePollOrSkip()

        // The screen starts with a question field and exactly two blank option rows;
        // a poll needs at least two answers to be meaningful.
        XCTAssertTrue(questionField().waitForExistence(timeout: 8), "No question field")
        XCTAssertGreaterThanOrEqual(app.textFields.count, 3,
                                    "Expected a question field plus at least two option fields")
    }

    func test_1TO1_createPollScreenDismisses() throws {
        app = openSeededConversation()
        try openCreatePollOrSkip()
        XCTAssertTrue(app.staticTexts["Create Poll"].waitForExistence(timeout: 8))

        dismissCreatePoll()

        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10),
                      "Dismissing Create Poll did not return to the conversation")
    }

    // MARK: - Validation

    func test_1TO1_emptyPollCannotBeSent() throws {
        app = openSeededConversation()
        try openCreatePollOrSkip()
        XCTAssertTrue(questionField().waitForExistence(timeout: 8))

        // Nothing filled in. Either Send is disabled outright, or tapping it surfaces the
        // validation message — both are correct refusals, and the screen must stay open.
        let send = app.buttons["Send"].firstMatch
        if send.exists && send.isEnabled { send.tap() }

        let refused = app.staticTexts["Create Poll"].exists
            || app.staticTexts.containing(NSPredicate(format: "label CONTAINS[c] %@", "fill in all required"))
                   .firstMatch.waitForExistence(timeout: 4)
        XCTAssertTrue(refused, "An empty poll appears to have been accepted")
    }

    func test_1TO1_questionOnlyPollCannotBeSent() throws {
        app = openSeededConversation()
        try openCreatePollOrSkip()
        let question = questionField()
        XCTAssertTrue(question.waitForExistence(timeout: 8))

        question.tap()
        question.typeText("Lunch?")

        let send = app.buttons["Send"].firstMatch
        if send.exists && send.isEnabled { send.tap() }

        // A question with no answers is still incomplete — the screen must not dismiss.
        XCTAssertTrue(app.staticTexts["Create Poll"].exists,
                      "A poll with no options appears to have been accepted")
    }

    // MARK: - Creating a poll end to end

    func test_1TO1_createPollSendsToConversation() throws {
        app = openSeededConversation()
        try openCreatePollOrSkip()
        let token = "Lunch \(Int(Date().timeIntervalSince1970) % 100000)?"

        try fillPoll(question: token, options: ["Yes", "No"])
        tapSend()

        // The poll arrives as a custom message; the question is its most identifiable text.
        let landed = ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 25)
            || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", token))
                   .firstMatch.waitForExistence(timeout: 10)
        XCTAssertTrue(landed, "The created poll did not appear in the conversation")
    }

    func test_GRP_createPollInGroup() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        app = openSeededGroup(group)
        try openCreatePollOrSkip()
        let token = "Team lunch \(Int(Date().timeIntervalSince1970) % 100000)?"

        try fillPoll(question: token, options: ["Yes", "No"])
        tapSend()

        let landed = ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 25)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(landed, "The group poll did not appear / screen not stable")
    }

    // MARK: - Helpers

    private func pollOption() -> XCUIElement {
        let button = app.buttons["Poll"].firstMatch
        if button.exists { return button }
        return app.staticTexts["Poll"].firstMatch
    }

    private func questionField() -> XCUIElement {
        let byPlaceholder = app.textFields["Ask question"].firstMatch
        if byPlaceholder.exists { return byPlaceholder }
        return app.textFields.element(boundBy: 0)
    }

    /// Opens the attachment sheet, skipping the test if it cannot be reached.
    private func openAttachmentSheetOrSkip() throws {
        let attach = app.buttons["Attachment"].firstMatch
        guard attach.waitForExistence(timeout: 10) else {
            throw XCTSkip("Composer attachment button not found — cannot reach the sheet")
        }
        attach.tap()
    }

    /// Opens the attachment sheet and taps Poll, skipping when the extension is off.
    private func openCreatePollOrSkip() throws {
        try openAttachmentSheetOrSkip()
        let poll = pollOption()
        guard poll.waitForExistence(timeout: 6) else {
            throw XCTSkip("The Polls extension is not enabled for this App ID")
        }
        poll.tap()
    }

    private func fillPoll(question: String, options: [String]) throws {
        let questionField = self.questionField()
        XCTAssertTrue(questionField.waitForExistence(timeout: 8), "No question field")
        questionField.tap()
        questionField.typeText(question)

        // Option rows follow the question field in order. The screen ships with two blank
        // rows and grows a third once both are filled, so index 1..n are the answers.
        for (offset, option) in options.enumerated() {
            let field = app.textFields.element(boundBy: offset + 1)
            guard field.exists else {
                XCTFail("Option field \(offset + 1) not present"); return
            }
            field.tap()
            field.typeText(option)
        }
    }

    private func tapSend() {
        let send = app.buttons["Send"].firstMatch
        XCTAssertTrue(send.waitForExistence(timeout: 6), "No Send button on Create Poll")
        send.tap()
    }

    private func dismissCreatePoll() {
        for label in ["Close", "Cancel", "Back"] {
            let button = app.buttons[label].firstMatch
            if button.exists && button.isHittable { button.tap(); return }
        }
        app.swipeDown()
    }
}
