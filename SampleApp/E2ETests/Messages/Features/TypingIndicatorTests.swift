import XCTest

/// Typing indicators. The REST API has no "start typing" endpoint, so a live B→A typing event cannot be
/// produced headlessly — every case here is structural/negative.
final class TypingIndicatorTests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }
    
    func test_1TO1_selfTypingNoIndicator() throws {
        app = openSeededConversation()
        let composer = ComponentQueries.composer(app)
        composer.tap(); composer.typeText("typing check")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].exists, "Header lost the peer name while typing")
        XCTAssertFalse(app.staticTexts["Typing..."].exists, "A spurious self 'Typing…' appeared")
    }

    func test_RT_TYPE_typeThenSendClears() throws {
        app = openSeededConversation()
        let token = "E2E-type\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message not sent")
        XCTAssertFalse(app.staticTexts["Typing..."].exists, "Typing indicator stuck after send")
    }

    func test_1TO1_peerHeaderStableNoTyping() throws {
        app = openSeededConversation()
        let token = "E2E-peerhdr\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].exists, "Header lost the peer name")
    }

    func test_RT_TYPE_groupHeaderStable() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not open test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group list did not open")
        let token = "E2E-gtype\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendGroupTextMessage(token, groupId: group.guid) }
        _ = ComponentQueries.waitForBubble(app, text: token, timeout: 20)
        XCTAssertTrue(ComponentQueries.composer(app).exists, "Group header/screen not stable")
    }
}
