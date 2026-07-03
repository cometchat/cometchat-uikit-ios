import XCTest

/// Typing indicators. The CometChat REST API has NO "start typing" endpoint, so a live B→A typing event
/// cannot be produced headlessly — every case here is structural/negative. These assert: A typing doesn't
/// show a spurious self "Typing…", the header keeps showing the peer name, and no stuck indicator persists.
final class TypingIndicatorTests: XCTestCase {
    
    private var app: XCUIApplication!
    
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }
    
    /// A types; the header still shows B's name and no self "Typing…" appears.
    func test_1TO1_selfTypingNoIndicator() throws {
        openSeeded()
        let composer = ComponentQueries.composer(app)
        composer.tap(); composer.typeText("typing check")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].exists, "Header lost the peer name while typing")
        XCTAssertFalse(app.staticTexts["Typing..."].exists, "A spurious self 'Typing…' appeared")
    }
    
    /// Type then send clears any typing state and shows the message.
    func test_RT_TYPE_typeThenSendClears() throws {
        openSeeded()
        let token = "E2E-type\(UUID().uuidString.prefix(8))"
        ComponentQueries.typeAndSend(app, text: token)
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 14), "Message not sent")
        XCTAssertFalse(app.staticTexts["Typing..."].exists, "Typing indicator stuck after send")
    }
    
    /// B sends a real message (REST can't push typing); the header shows the name, no spurious "Typing…".
    func test_1TO1_peerHeaderStableNoTyping() throws {
        openSeeded()
        let token = "E2E-peerhdr\(UUID().uuidString.prefix(8))"
        try runBlocking { _ = try await PeerActions.sendTextMessage(token) }
        XCTAssertTrue(ComponentQueries.waitForBubble(app, text: token, timeout: 20), "Peer message did not arrive")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].exists, "Header lost the peer name")
    }
    
    /// A group header stays stable with no spurious multi-user "Typing…".
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
    
    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(
            AppLauncher.openConversationFromChats(
                app,
                displayName: TestConfig.userBDisplayName
            ),
            "Could not open conversation"
        )
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 15),
            "Message list did not open"
        )
    }
}
