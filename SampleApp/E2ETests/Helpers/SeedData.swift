import Foundation

/// setUp/tearDown fixtures over `PeerActions`. Prepare state via API, not UI.
enum SeedData {

    static func createTestConversation() async throws {
        // Tests seed BEFORE AppLauncher runs, so validate here too — else placeholder creds make the seed's
        // REST calls 4xx and the swallowed error resurfaces as a misleading "conversation missing" assertion.
        TestConfig.validate()
        // A prior block test can leave B blocked (Unblock banner replaces the composer); unblock before seeding.
        await PeerActions.unblockUser()
        try await PeerActions.ensureConversationExists()
    }

    static func cleanup() async {
        await PeerActions.deleteConversation()
    }

    /// Throwaway per-run group (unique guid/name) so tests never mutate the shared `supergroup`.
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

    static func createEmptyTestGroup() async throws -> TestGroup {
        let token = UUID().uuidString.prefix(8).lowercased()
        let guid = "e2e-grp-\(token)"
        let name = "E2E Group \(token)"
        try await PeerActions.createGroup(guid: guid, name: name)
        return TestGroup(guid: guid, name: name, memberUid: TestConfig.userBUid)
    }

    struct TestGroupContext {
        let group: TestGroup
        let ownedByA: Bool
    }

    static func createGroupOwnedByA() async throws -> TestGroupContext {
        TestGroupContext(group: try await createTestGroupWithMember(), ownedByA: true)
    }

    static func createGroupOwnedByBWithAAs(_ scope: String) async throws -> TestGroupContext {
        let token = UUID().uuidString.prefix(8).lowercased()
        let guid = "e2e-grp-\(token)"
        let name = "E2E Group \(token)"
        try await PeerActions.createGroup(guid: guid, name: name, owner: TestConfig.userBUid)
        try await PeerActions.addGroupMembers(guid: guid, uids: [TestConfig.userAUid], by: TestConfig.userBUid)
        if scope != "participant" {
            try await PeerActions.setMemberScope(guid: guid, uid: TestConfig.userAUid, scope: scope, by: TestConfig.userBUid)
        }
        return TestGroupContext(group: TestGroup(guid: guid, name: name, memberUid: TestConfig.userBUid), ownedByA: false)
    }

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

    static func deleteTestGroup(_ ctx: TestGroupContext?) async {
        guard let ctx else { return }
        let owner = ctx.ownedByA ? TestConfig.userAUid : TestConfig.userBUid
        await PeerActions.deleteGroup(guid: ctx.group.guid, owner: owner)
    }
}
