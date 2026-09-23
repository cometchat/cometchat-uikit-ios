import XCTest

/// Message actions asserted on their actual EFFECT, not on the menu item existing. The suite
/// already checks that Copy / Info appear in the long-press menu; these check that Copy really
/// puts the text on the pasteboard and that Info really shows the message. Also covers composer
/// draft retention, which is only tested across rotation today.
/// Sheet sources: sample-app sheet copy/info rows; Sanity composer rows.
final class MessageActionDepthTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { await SecondClient.shared.logout() }
        runBlocking { [group] in await SeedData.deleteTestGroup(group) }
        group = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - Shared steps

    /// Send a message from the app itself, so nothing here depends on real-time inbound delivery.
    @discardableResult
    private func sendOwnMessage() -> String {
        let token = "E2E-act-\(UUID().uuidString.prefix(6))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 15),
                      "Own message did not appear")
        return token
    }

    /// Return to a screen that has the tab bar. The messages screen hides the nav bar and draws
    /// its own header, and a single back tap can land on an intermediate screen, so retry until
    /// the tab bar is actually back.
    private func leaveConversation() {
        for _ in 0..<3 {
            if app.tabBars.firstMatch.exists { return }
            if let back = ComponentQueries.headerBackButton(app), back.isHittable {
                back.tap()
            } else if app.navigationBars.buttons.firstMatch.exists {
                app.navigationBars.buttons.firstMatch.tap()
            }
            _ = app.tabBars.firstMatch.waitForExistence(timeout: 6)
        }
    }

    // MARK: - Copy

    /// Copy must place the message text on the system pasteboard — the existing test only checks
    /// that the "Copy" menu item exists, which passes even if copying does nothing.
    ///
    /// PARKED: not automatable as written. The XCUITest runner is a separate process, and since
    /// iOS 16 reading another app's pasteboard requires the user to confirm a system "Paste"
    /// prompt, so `UIPasteboard.general.string` returns nil here regardless of whether Copy
    /// worked. Verifying this needs app-side support (e.g. a `-UITestMode`-only view that echoes
    /// the pasteboard), which is an app change rather than a test change.
    func test_1TO1_copyPutsMessageTextOnPasteboard() throws {
        throw XCTSkip("Cross-process pasteboard reads need a system paste prompt; needs app-side echo to verify")
        app = openSeededConversation()
        UIPasteboard.general.string = ""
        let token = sendOwnMessage()

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token),
                      "Could not open message options")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.copy),
                      "Copy option not found")

        let copied = waitForCondition(timeout: 8) {
            (UIPasteboard.general.string ?? "").contains(token)
        }
        XCTAssertTrue(copied,
                      "Copy did not put the message on the pasteboard (got: \(UIPasteboard.general.string ?? "nil"))")
    }

    /// The same contract inside a group. PARKED for the same pasteboard reason as above.
    func test_GROUP_copyPutsMessageTextOnPasteboard() throws {
        throw XCTSkip("Cross-process pasteboard reads need a system paste prompt; needs app-side echo to verify")
        var created: SeedData.TestGroup?
        (app, created) = openSeededGroupWithMember()
        group = created
        guard group != nil else { return }

        UIPasteboard.general.string = ""
        let token = sendOwnMessage()
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token),
                      "Could not open message options in the group")
        XCTAssertTrue(ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.copy),
                      "Copy option not found in the group")

        XCTAssertTrue(waitForCondition(timeout: 8) {
            (UIPasteboard.general.string ?? "").contains(token)
        }, "Group copy did not reach the pasteboard")
    }

    // MARK: - Message info

    /// The Info screen must actually show the message it was opened for.
    func test_1TO1_messageInfoShowsTheMessage() throws {
        app = openSeededConversation()
        let token = sendOwnMessage()

        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token),
                      "Could not open message options")
        guard ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.info) else {
            throw XCTSkip("Info option not offered for this message")
        }
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: token, timeout: 12),
                      "Message Info screen does not show the message it was opened for")
    }

    // MARK: - Message info receipts (Wave 6)

    private enum InfoCopy {
        static let delivered = "Delivered"
        static let read = "Read"
        /// What the Info screen prints for a receipt that has no timestamp yet.
        static let noTime = "---"
    }

    /// Backend id of the message the app just sent (its text is `token`), read from the
    /// conversation's `lastMessage` — the only place a UI-sent message's id is visible to the test.
    private func backendID(ofOwnMessage token: String, group guid: String? = nil) -> Int? {
        var found: Int?
        _ = waitForBackend(timeout: 20) {
            let last = await PeerActions.lastConversationMessage(group: guid)
            guard ((last?["data"] as? [String: Any])?["text"] as? String) == token,
                  let id = PeerActions.messageID(of: last) else { return false }
            found = id
            return true
        }
        return found
    }

    private func openInfo(for token: String) throws {
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Could not open message options")
        guard ComponentQueries.tapMessageOption(app, label: ComponentQueries.MessageOption.info) else {
            throw XCTSkip("Info option not offered for this message")
        }
        XCTAssertTrue(app.staticTexts["Message Info"].waitForExistence(timeout: 10)
                        || app.navigationBars["Message Info"].waitForExistence(timeout: 2),
                      "Message Info screen did not open")
    }

    private func infoRow(_ text: String) -> XCUIElement {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", text)).firstMatch
    }

    /// Number of receipt rows still showing the "---" no-timestamp placeholder.
    private func rowsWithoutTime() -> Int {
        app.staticTexts.matching(NSPredicate(format: "label == %@", InfoCopy.noTime)).count
    }

    /// The labels on screen, for a failure message that says what Info actually showed. The
    /// Info screen is presented over the message list, whose labels stay in the tree, so the
    /// interesting ones are near the end.
    private func visibleLabels() -> String {
        app.staticTexts.allElementsBoundByIndex.suffix(30).map(\.label).joined(separator: " | ")
    }

    /// Leave the conversation and open it again, so the list re-fetches the message from the
    /// backend with the receipts B recorded meanwhile. The Info rows are built from the message
    /// object the list holds; without this they only change if the live receipt frame reaches
    /// A, which makes the case real-time for no reason.
    private func reopenConversation(group: SeedData.TestGroup? = nil, showing token: String) {
        leaveConversation()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10), "Did not get back to the tab bar")
        if let group {
            XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not reopen the group")
        } else {
            XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                          "Could not reopen the 1:1")
        }
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Conversation did not reopen")
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20),
                      "The sent message is not in the reopened conversation")
    }

    // The kit's 1:1 Info screen always lists a Read row and a Delivered row for the peer
    // (MessageInformationViewModel builds both from the message itself) and prints "---" in
    // place of a timestamp the message does not carry — so its "Waiting for recipients…"
    // empty state never renders for a user message. The sent → delivered → read progression
    // is therefore asserted on how many rows still lack a time. User B may hold a live
    // session elsewhere while the suite runs (delivery then happens on its own), so the
    // sent-only case only claims the READ row is still pending.

    /// Sent only: both rows are listed and the Read row has no time yet.
    func test_1TO1_INFO_sentOnlyMessageShowsWaitingState() throws {
        app = openSeededConversation()
        let token = sendOwnMessage()
        try openInfo(for: token)
        XCTAssertTrue(infoRow(InfoCopy.read).waitForExistence(timeout: 12), "No Read row on Message Info: \(visibleLabels())")
        XCTAssertTrue(infoRow(InfoCopy.delivered).exists, "No Delivered row on Message Info: \(visibleLabels())")
        XCTAssertGreaterThanOrEqual(rowsWithoutTime(), 1,
                                    "An unread message shows a read time on Message Info: \(visibleLabels())")
    }

    /// Once B has received the message, the Delivered row carries a time (only Read may be pending).
    func test_1TO1_INFO_deliveredReceiptListed() throws {
        app = openSeededConversation()
        let token = sendOwnMessage()
        guard let id = backendID(ofOwnMessage: token) else { XCTFail("Sent message not found on the backend"); return }
        try ensureUserBLoggedIn()
        try runBlocking { try await SecondClient.shared.markReceived(messageId: id, read: false) }
        reopenConversation(showing: token)
        try openInfo(for: token)
        XCTAssertTrue(infoRow(InfoCopy.delivered).waitForExistence(timeout: 12),
                      "Message Info does not list the Delivered receipt: \(visibleLabels())")
        XCTAssertTrue(waitForCondition(timeout: 10) { self.rowsWithoutTime() <= 1 },
                      "The Delivered row still shows no time after B received the message: \(visibleLabels())")
    }

    /// Once B has read the message, every row carries a time.
    func test_1TO1_INFO_readReceiptListed() throws {
        app = openSeededConversation()
        let token = sendOwnMessage()
        guard let id = backendID(ofOwnMessage: token) else { XCTFail("Sent message not found on the backend"); return }
        try ensureUserBLoggedIn()
        try runBlocking { try await SecondClient.shared.markReceived(messageId: id, read: true) }
        reopenConversation(showing: token)
        try openInfo(for: token)
        XCTAssertTrue(infoRow(InfoCopy.read).waitForExistence(timeout: 12),
                      "Message Info does not list the Read receipt: \(visibleLabels())")
        XCTAssertTrue(waitForCondition(timeout: 10) { self.rowsWithoutTime() == 0 },
                      "A row still shows no time after B read the message: \(visibleLabels())")
    }

    /// In a group the receipts are listed per member: B's row, with its Delivered / Read state.
    func test_GRP_INFO_receiptsListedPerMember() throws {
        var created: SeedData.TestGroup?
        (app, created) = openSeededGroupWithMember()
        group = created
        guard let created else { return }
        let token = sendOwnMessage()
        guard let id = backendID(ofOwnMessage: token, group: created.guid) else {
            XCTFail("Sent group message not found on the backend"); return
        }
        try ensureUserBLoggedIn()
        try runBlocking { try await SecondClient.shared.markReceived(messageId: id, groupGuid: created.guid, read: true) }
        reopenConversation(group: created, showing: token)
        try openInfo(for: token)
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 12),
                      "Message Info does not list member \(TestConfig.userBDisplayName): \(visibleLabels())")
        XCTAssertTrue(infoRow(InfoCopy.read).waitForExistence(timeout: 5) || infoRow(InfoCopy.delivered).exists,
                      "Member row carries no Delivered/Read state: \(visibleLabels())")
    }

    // MARK: - Composer drafts

    /// A typed but unsent draft should survive leaving the conversation and coming back.
    ///
    /// FINDING (verified, awaiting a product decision): it does not. Navigation here is correct —
    /// the test reaches the assertion and the composer comes back EMPTY. Drafts survive rotation
    /// (`test_E2E_rotationPreservesDraft`, same screen) but are discarded when the screen is left.
    /// Most chat apps retain a per-conversation draft, so this is parked rather than deleted:
    /// unskip it if drafts should be retained, delete it if discarding is intended.
    func test_1TO1_draftSurvivesLeavingConversation() throws {
        throw XCTSkip("Drafts are discarded when leaving a conversation — product decision needed")
        app = openSeededConversation()
        let draft = "E2E-draft-\(UUID().uuidString.prefix(6))"
        let field = ComponentQueries.composer(app)
        XCTAssertTrue(field.waitForExistence(timeout: 10), "Composer not found")
        field.tap()
        field.typeText(draft)

        // The keyboard is up from typing and covers/blocks the header back control, so dismiss it
        // before navigating — otherwise leaving silently fails and the reopen looks like the bug.
        if app.keyboards.firstMatch.exists { app.swipeDown() }
        leaveConversation()
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 10),
                      "Did not get back to a screen with the tab bar")

        XCTAssertTrue(AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.chats),
                      "Chats tab unavailable")
        let row = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(row.waitForExistence(timeout: 15), "Could not find the conversation row to reopen")
        row.tap()
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Conversation did not reopen")

        let restored = (ComponentQueries.composer(app).value as? String) ?? ""
        XCTAssertTrue(restored.contains(draft),
                      "Draft was not retained when returning to the conversation (composer: \"\(restored)\")")
    }

    /// A draft must not leak from one conversation into another.
    func test_1TO1_draftDoesNotLeakIntoAnotherChat() throws {
        var created: SeedData.TestGroup?
        (app, created) = openSeededGroupWithMember()
        group = created
        guard let group else { return }

        let draft = "E2E-leak-\(UUID().uuidString.prefix(6))"
        let field = ComponentQueries.composer(app)
        XCTAssertTrue(field.waitForExistence(timeout: 10), "Composer not found")
        field.tap()
        field.typeText(draft)

        leaveConversation()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open the 1:1")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "1:1 did not open")

        let other = (ComponentQueries.composer(app).value as? String) ?? ""
        XCTAssertFalse(other.contains(draft),
                       "Draft from \(group.name) leaked into the 1:1 composer")
    }
}
