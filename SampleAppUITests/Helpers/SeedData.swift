import Foundation

/// setUp/tearDown fixtures over `PeerActions`. Prepare state via API, not UI — driving the peer
/// through the app would be slow and flaky.
enum SeedData {

    static func createTestConversation() async throws {
        // Defensive: a prior block test (or a crashed one whose teardown never ran) can leave User B
        // blocked, which replaces the composer with an Unblock banner and breaks every 1:1 send test.
        // Clean in setUp, don't trust teardown — unblock before seeding.
        await PeerActions.unblockUser()
        try await PeerActions.ensureConversationExists()
    }

    /// Best-effort: a crashed test may leave partial state, and cleanup failure must not mask it.
    static func cleanup() async {
        await PeerActions.deleteConversation()
    }

    /// A throwaway group for admin/member tests so we never mutate the shared `supergroup`. User A
    /// owns it (admin affordances show); User B is added as a member to kick/ban/scope-change. The
    /// guid/name carry a unique per-run token so runs never collide.
    struct TestGroup {
        let guid: String
        let name: String
        let memberUid: String
    }

    static func createTestGroupWithMember() async throws -> TestGroup {
        let token = UUID().uuidString.prefix(8).lowercased()
        let guid = "e2e-grp-\(token)"
        let name = "E2E Group \(token)"
        try await PeerActions.createGroup(guid: guid, name: name, participants: [TestConfig.userBUid])
        return TestGroup(guid: guid, name: name, memberUid: TestConfig.userBUid)
    }

    /// A group owned by User A with NO other members — for the Add-Members UI case, where the test adds
    /// User B through the app and asserts B lands in the backend member list. `memberUid` is B (the user
    /// the test will add), though B is not yet a member at seed time.
    static func createEmptyTestGroup() async throws -> TestGroup {
        let token = UUID().uuidString.prefix(8).lowercased()
        let guid = "e2e-grp-\(token)"
        let name = "E2E Group \(token)"
        try await PeerActions.createGroup(guid: guid, name: name)
        return TestGroup(guid: guid, name: name, memberUid: TestConfig.userBUid)
    }

    /// Whether the logged-in test user (A) owns the throwaway group — false for the B-owned variants
    /// where A joins as participant/moderator. Determines who tears the group down.
    struct TestGroupContext {
        let group: TestGroup
        let ownedByA: Bool
    }

    /// A group where User A is the OWNER/admin (default seed). A can perform admin actions.
    static func createGroupOwnedByA() async throws -> TestGroupContext {
        TestGroupContext(group: try await createTestGroupWithMember(), ownedByA: true)
    }

    /// A group OWNED BY B with User A joined as a `participant` (for "regular member can't edit/delete
    /// others' messages" permission cases). B is the message author so A acts on someone else's message.
    static func createGroupOwnedByBWithAAs(_ scope: String) async throws -> TestGroupContext {
        let token = UUID().uuidString.prefix(8).lowercased()
        let guid = "e2e-grp-\(token)"
        let name = "E2E Group \(token)"
        try await PeerActions.createGroup(guid: guid, name: name, owner: TestConfig.userBUid)
        try await PeerActions.addGroupMembers(guid: guid, uids: [TestConfig.userAUid], by: TestConfig.userBUid)
        if scope != "participant" {
            try await PeerActions.setMemberScope(guid: guid, uid: TestConfig.userAUid, scope: scope, by: TestConfig.userBUid)
        }
        // `memberUid` is B here — B is the author of the message A will (or won't) be able to act on.
        return TestGroupContext(group: TestGroup(guid: guid, name: name, memberUid: TestConfig.userBUid), ownedByA: false)
    }

    /// A password-protected group A is NOT a member of — for the join-with-password cases. Owned by B so
    /// A must join through the app's password sheet.
    static func createPasswordGroupWithoutA(password: String) async throws -> TestGroup {
        let token = UUID().uuidString.prefix(8).lowercased()
        let guid = "e2e-pw-\(token)"
        let name = "E2E PW \(token)"
        try await PeerActions.createGroup(guid: guid, name: name, type: "password", password: password, owner: TestConfig.userBUid)
        return TestGroup(guid: guid, name: name, memberUid: TestConfig.userBUid)
    }

    static func deleteTestGroup(_ group: TestGroup?) async {
        guard let group else { return }
        await PeerActions.deleteGroup(guid: group.guid)
    }

    /// Tear down either variant — B-owned groups must be deleted on behalf of B.
    static func deleteTestGroup(_ ctx: TestGroupContext?) async {
        guard let ctx else { return }
        let owner = ctx.ownedByA ? TestConfig.userAUid : TestConfig.userBUid
        await PeerActions.deleteGroup(guid: ctx.group.guid, owner: owner)
    }
}
