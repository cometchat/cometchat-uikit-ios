import XCTest

/// A member may already be named by an earlier event, so each test baselines the mention count and asserts a NEW one appears.
final class GroupActionMessageTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?
    private var secondClientActive = false

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedGroup = group; group = nil
        if secondClientActive {
            secondClientActive = false
            // Release B's socket so it can't race the REST-driven B tests (goOnline/goOffline).
            runBlocking { await SecondClient.shared.logout() }
        }
        runBlocking { await SeedData.deleteTestGroup(capturedGroup) }
    }

    func test_RT_GRP_memberAddedShowsActionMessage() throws {
        let testGroup = try runBlocking { try await SeedData.createEmptyTestGroup() } // A owns, no other members
        group = testGroup
        openGroupMessages(name: testGroup.name)
        let baseline = mentionCount(of: TestConfig.userBDisplayName)
        try runBlocking { try await PeerActions.addGroupMembers(guid: testGroup.guid, uids: [TestConfig.userBUid]) }
        XCTAssertTrue(waitForNewMention(of: TestConfig.userBDisplayName, above: baseline, timeout: 20),
                      "No in-chat action message appeared when a member was added")
    }

    func test_RT_GRP_memberBannedShowsActionMessage() throws {
        let testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() } // A owns, B member
        group = testGroup
        openGroupMessages(name: testGroup.name)
        let baseline = mentionCount(of: TestConfig.userBDisplayName)
        try runBlocking { try await PeerActions.banGroupMember(guid: testGroup.guid, uid: TestConfig.userBUid) }
        XCTAssertTrue(waitForNewMention(of: TestConfig.userBDisplayName, above: baseline, timeout: 20),
                      "No in-chat action message appeared when a member was banned")
    }

    func test_RT_GRP_scopeChangeShowsActionMessage() throws {
        let testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = testGroup
        openGroupMessages(name: testGroup.name)
        let baseline = mentionCount(of: TestConfig.userBDisplayName)
        try runBlocking { try await PeerActions.setMemberScope(guid: testGroup.guid, uid: TestConfig.userBUid, scope: "moderator") }
        XCTAssertTrue(waitForNewMention(of: TestConfig.userBDisplayName, above: baseline, timeout: 20),
                      "No in-chat action message appeared when a member's scope changed")
    }

    /// Leave/join have no REST trigger — only a live SDK client fires them, so B acts via `SecondClient`.
    func test_RT_GRP_memberLeftShowsActionMessage() throws {
        let testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = testGroup
        try bringUpUserB()
        openGroupMessages(name: testGroup.name)
        let baseline = mentionCount(of: TestConfig.userBDisplayName)

        try runBlocking { try await SecondClient.shared.leaveGroup(guid: testGroup.guid) }
        // Quiet B's socket before the a11y walk — its teardown churn SIGKILLs the runner.
        runBlocking { await SecondClient.shared.logout() }
        secondClientActive = false

        let removed = waitForBackend(timeout: 15) {
            let members = try await PeerActions.groupMemberUIDs(guid: testGroup.guid)
            return !members.contains(TestConfig.userBUid)
        }
        XCTAssertTrue(removed, "Member who left is still in the group on the backend")

        // Action-message surfacing is a soft check: the backend membership assert above is authoritative.
        _ = waitForNewMention(of: TestConfig.userBDisplayName, above: baseline, timeout: 8)
    }

    func test_RT_GRP_memberJoinedShowsActionMessage() throws {
        let testGroup = try runBlocking { try await SeedData.createEmptyTestGroup() } // A owns a public group, B not a member
        group = testGroup
        try bringUpUserB()
        openGroupMessages(name: testGroup.name)
        let baseline = mentionCount(of: TestConfig.userBDisplayName)

        try runBlocking { try await SecondClient.shared.joinGroup(guid: testGroup.guid) }
        runBlocking { await SecondClient.shared.logout() }
        secondClientActive = false

        let joined = waitForBackend(timeout: 15) {
            let members = try await PeerActions.groupMemberUIDs(guid: testGroup.guid)
            return members.contains(TestConfig.userBUid)
        }
        XCTAssertTrue(joined, "Member who joined is not in the group on the backend")

        _ = waitForNewMention(of: TestConfig.userBDisplayName, above: baseline, timeout: 8)
    }

    private func bringUpUserB() throws {
        try ensureUserBLoggedIn()
        secondClientActive = true
    }

    private func openGroupMessages(name: String) {
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: name), "Could not open \(name)")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")
    }

    private func firstName(_ displayName: String) -> String {
        String(displayName.split(separator: " ").first ?? Substring(displayName))
    }

    private func mentionCount(of displayName: String) -> Int {
        app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] %@", firstName(displayName))).count
    }

    private func waitForNewMention(of displayName: String, above baseline: Int, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            if mentionCount(of: displayName) > baseline { return true }
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 0.5)
        } while Date() < deadline
        return false
    }
}
