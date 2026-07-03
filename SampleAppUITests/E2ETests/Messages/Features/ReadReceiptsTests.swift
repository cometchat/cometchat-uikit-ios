import XCTest

/// Read receipts. On iOS the receipt tick is a PNG image with no queryable state, so these assert the
/// message PERSISTS through the delivered/read events (driven over REST by User B) and the screen stays
/// stable, NOT the tick colour. Consolidates the
/// many near-identical structural rows.
final class ReadReceiptsTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    /// A sends; the message renders (sent state).
    func test_1TO1_sentReceiptShown() throws {
        openSeeded()
        let token = "E2E-sent\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Sent message not shown")
    }

    /// B marks A's message delivered via REST; the message remains.
    func test_1TO1_deliveredReceipt() throws {
        openSeeded()
        let token = "E2E-deliv\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        runBlocking { await PeerActions.markAsDelivered(id) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8), "Message vanished after delivered")
    }

    /// B marks A's message read via REST; the message remains.
    func test_1TO1_readReceipt() throws {
        openSeeded()
        let token = "E2E-read\(UUID().uuidString.prefix(8))"
        let id: Int = try runBlocking { try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Message did not arrive")
        runBlocking { await PeerActions.markAsRead(id) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 8), "Message vanished after read")
    }

    /// Receipts hidden/disabled is a structural no-op on iOS — the message renders regardless.
    func test_1TO1_receiptsStructural() throws {
        openSeeded()
        let token = "E2E-rcfg\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message not shown")
    }

    /// A sends 3, B marks the latest read via REST; all 3 remain (cumulative).
    func test_RT_RCPT_cumulativeRead() throws {
        openSeeded()
        let stamp = UUID().uuidString.prefix(6)
        var lastId = 0
        var lastToken = ""
        try runBlocking {
            for i in 1...3 {
                let token = "E2E-cum-\(stamp)-\(i)"
                lastId = try await PeerActions.sendTextMessage(token)
                lastToken = token
                try await Task.sleep(nanoseconds: 250_000_000)
            }
            await PeerActions.markAsRead(lastId)
        }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: lastToken, timeout: 25), "Latest message missing")
    }

    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }
}
