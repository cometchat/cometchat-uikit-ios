import XCTest

/// Cases whose REAL behaviour depends on a config flag / AI wiring / moderation pipeline that the sample
/// app does NOT expose, so the specific state can't be produced on-device. These exercise the surface and
/// assert the app stays stable (structural stand-ins). Each test names the exact missing capability.
final class ConfigGatedStandInTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // Receipts-disabled: no receipts-off toggle in the sample app, so the hidden-ticks state can't be
    // produced. Structural stand-in.
    func test_1TO1_receiptsDisabledStructural() {
        app = openSeededConversation()
        let token = "E2E-recdis-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14),
                      "Composer/send path not usable (receipts-disabled only exercisable structurally)")
    }

    // Reactions-disabled: no reactions-off toggle exposed, so the disabled state can't be produced.
    // Structural stand-in.
    func test_1TO1_reactionsDisabledStructural() {
        app = openSeededConversation()
        let token = "E2E-rxdis-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14),
                      "Composer not usable (reactions-disabled only exercisable structurally)")
    }

    // Typing suppressed when AI/disabled: no AI user is wired into the test app, so the AI-suppression
    // branch is unreachable. Structural stand-in.
    func test_1TO1_typingSuppressedAIStructural() {
        app = openSeededConversation()
        XCTAssertTrue(ComponentQueries.composer(app).exists,
                      "Composer not present (AI-typing-suppression unreachable without an AI user)")
    }

    // Conversation starters (AI): AI feature not enabled on the test app. Open an empty conversation and
    // assert the screen is stable (structural stand-in).
    func test_1TO1_conversationStartersAIStructural() {
        runBlocking { await SeedData.cleanup() } // open empty so starters would be the surface, if enabled
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationWith(app, displayName: TestConfig.userBDisplayName),
                      "Could not open a fresh conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15),
                      "Empty conversation not stable (AI starters unreachable without AI enabled)")
    }

    // Smart replies (AI): AI not enabled. Receive a message, assert stability (structural stand-in).
    func test_1TO1_smartRepliesAIStructural() throws {
        app = openSeededConversation()
        try runBlocking { _ = try await PeerActions.sendTextMessage("E2E-smart-\(UUID().uuidString.prefix(6))") }
        XCTAssertTrue(ComponentQueries.composer(app).exists,
                      "Screen not stable (smart replies unreachable without AI enabled)")
    }

    // Message moderated after send: moderation is a dashboard-gated server pipeline that isn't enabled here,
    // so no moderation outcome is producible. Send + assert stable (structural stand-in).
    func test_RT_EDGE_moderationStructural() {
        app = openSeededConversation()
        let token = "E2E-mod-\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14)
                        || ComponentQueries.composer(app).exists,
                      "Screen not stable after send (moderation pipeline not enabled to observe an outcome)")
    }

    // Group message-info (sent timestamp / delivered-read list): the info detail rows are not in the a11y
    // tree; assert the info option/popup presents on a group message (structural stand-in).
    func test_GRP_messageInfoStructural() throws {
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: TestConfig.groupDisplayName), "Could not open shared group")
        let token = "E2E-ginfo-\(UUID().uuidString.prefix(6))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Group message did not send")
        XCTAssertTrue(ComponentQueries.openMessageOptions(app, bubbleText: token), "Long-press failed on group message")
        let popupUp = ["Info", "Message Information", "Message Info", "Copy"].contains {
            app.buttons[$0].waitForExistence(timeout: 4) || app.staticTexts[$0].exists
        }
        XCTAssertTrue(popupUp, "Group message-options popup did not present for the info check")
    }
}
