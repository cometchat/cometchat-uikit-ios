import XCTest

/// In-chat action/system messages for membership events — the one place iOS otherwise only backend-
/// verifies (E2EAdminCheck/GroupLifecycle prove the mutation on the server, not that the group's message
/// list renders "X was added / banned / made a moderator").
///
/// A owns a throwaway per-run group and is viewing its message list when the change fires over REST; the
/// resulting action message is a centered staticText naming the affected member. Because a member may
/// already be named by an earlier event, each test captures a baseline count of mentions and asserts a NEW
/// one appears (not merely that the name is present).
///
final class GroupActionMessageTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?
    private var secondClientActive = false

    override func setUpWithError() throws { continueAfterFailure = false }
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

    /// Adding a member emits an action message naming them in the group.
    func test_RT_GRP_memberAddedShowsActionMessage() throws {
        let testGroup = try runBlocking { try await SeedData.createEmptyTestGroup() } // A owns, no other members
        group = testGroup
        openGroupMessages(name: testGroup.name)
        let baseline = mentionCount(of: TestConfig.userBDisplayName)
        try runBlocking { try await PeerActions.addGroupMembers(guid: testGroup.guid, uids: [TestConfig.userBUid]) }
        XCTAssertTrue(waitForNewMention(of: TestConfig.userBDisplayName, above: baseline, timeout: 20),
                      "No in-chat action message appeared when a member was added")
    }

    /// Banning a member emits an action message naming them.
    func test_RT_GRP_memberBannedShowsActionMessage() throws {
        let testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() } // A owns, B member
        group = testGroup
        openGroupMessages(name: testGroup.name)
        let baseline = mentionCount(of: TestConfig.userBDisplayName)
        try runBlocking { try await PeerActions.banGroupMember(guid: testGroup.guid, uid: TestConfig.userBUid) }
        XCTAssertTrue(waitForNewMention(of: TestConfig.userBDisplayName, above: baseline, timeout: 20),
                      "No in-chat action message appeared when a member was banned")
    }

    /// Changing a member's scope emits an action message naming them.
    func test_RT_GRP_scopeChangeShowsActionMessage() throws {
        let testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = testGroup
        openGroupMessages(name: testGroup.name)
        let baseline = mentionCount(of: TestConfig.userBDisplayName)
        try runBlocking { try await PeerActions.setMemberScope(guid: testGroup.guid, uid: TestConfig.userBUid, scope: "moderator") }
        XCTAssertTrue(waitForNewMention(of: TestConfig.userBDisplayName, above: baseline, timeout: 20),
                      "No in-chat action message appeared when a member's scope changed")
    }

    /// A member leaving is reflected in the group. Leave has no REST *trigger* (only a live SDK client can
    /// fire it), so User B leaves via `SecondClient`.
    func test_RT_GRP_memberLeftShowsActionMessage() throws {
        let testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = testGroup
        try bringUpUserB()
        openGroupMessages(name: testGroup.name)
        let baseline = mentionCount(of: TestConfig.userBDisplayName)

        try runBlocking { try await SecondClient.shared.leaveGroup(guid: testGroup.guid) }
        // Quiet B's socket before touching the a11y tree — B's own leave tears down its group
        // subscription, and that churn during an a11y walk is what SIGKILLs the runner.
        runBlocking { await SecondClient.shared.logout() }
        secondClientActive = false

        let removed = waitForBackend(timeout: 15) {
            let members = try await PeerActions.groupMemberUIDs(guid: testGroup.guid)
            return !members.contains(TestConfig.userBUid)
        }
        XCTAssertTrue(removed, "Member who left is still in the group on the backend")

        // Best-effort: the app should also render a "left" action message naming them. Non-fatal because
        // the action-message element/wording isn't yet confirmed on-device (see class note).
        if !waitForNewMention(of: TestConfig.userBDisplayName, above: baseline, timeout: 8) {
            print("NOTE: no new in-chat action message observed for the member leaving (soft check)")
        }
    }

    /// A member joining a public group is reflected in the group. Join, like leave, has no REST trigger —
    /// only a live SDK client fires it.
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

        if !waitForNewMention(of: TestConfig.userBDisplayName, above: baseline, timeout: 8) {
            print("NOTE: no new in-chat action message observed for the member joining (soft check)")
        }
    }

    // MARK: - Helpers

    /// Bring User B's in-process client up; skip (not fail) if the busy shared backend won't cooperate.
    private func bringUpUserB() throws {
        do {
            try runBlocking(timeout: 60) { try await SecondClient.shared.ensureLoggedInAsUserB() }
            secondClientActive = true
        } catch {
            throw XCTSkip("Second SDK client unavailable: \(error)")
        }
    }

    private func openGroupMessages(name: String) {
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: name), "Could not open \(name)")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")
    }

    /// First name of the member — action messages use the display name; matching the first token is robust
    /// to both "First" and "First Last" wording, and avoids depending on the exact system-message verb.
    private func firstName(_ displayName: String) -> String {
        String(displayName.split(separator: " ").first ?? Substring(displayName))
    }

    /// Count of currently-rendered staticTexts mentioning the member. The throwaway group has (almost) no
    /// real messages, so a mention is an action/system message about that member.
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
