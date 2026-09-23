import XCTest

/// Group lifecycle beyond GroupLifecycleTests: changes made to a group outside the app (rename,
/// kick, delete) and joining a public group from the Groups tab. Each change is made over REST
/// before the app opens, so the cases test what the app shows afterwards; membership outcomes
/// are read back from the backend.
final class GroupLifecycleDepthTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?
    private var ctx: SeedData.TestGroupContext?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedGroup = group; group = nil
        let capturedContext = ctx; ctx = nil
        runBlocking {
            await SeedData.deleteTestGroup(capturedGroup)
            await SeedData.deleteTestGroup(capturedContext)
        }
    }

    private func groupsSearch(for name: String) -> XCUIElement {
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups)
        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 12), "Groups search field missing")
        AppLauncher.replaceSearchText(search, with: name)
        return app.cells.containing(.staticText, identifier: name).firstMatch
    }

    func test_GRP_LIFE_renamedGroupOpensUnderItsNewName() throws {
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = created
        let renamed = "E2E Renamed \(UUID().uuidString.prefix(6).lowercased())"
        try runBlocking { try await PeerActions.renameGroup(guid: created.guid, to: renamed) }

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: renamed), "Group not found under its new name")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Renamed group did not open")
        XCTAssertTrue(app.staticTexts[renamed].firstMatch.waitForExistence(timeout: 8),
                      "Header does not show the new group name")
    }

    func test_GRP_LIFE_oldNameNoLongerListedAfterRename() throws {
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = created
        try runBlocking {
            try await PeerActions.renameGroup(guid: created.guid, to: "E2E Renamed \(UUID().uuidString.prefix(6).lowercased())")
        }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertFalse(groupsSearch(for: created.name).waitForExistence(timeout: 6),
                       "The group is still listed under its old name")
    }

    func test_GRP_LIFE_kickedMemberShowsActionMessage() throws {
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() } // A owns, B member
        group = created
        try runBlocking { try await PeerActions.kickGroupMember(guid: created.guid, uid: TestConfig.userBUid) }

        app = openSeededGroup(created)
        let kickedLine = app.staticTexts.matching(
            NSPredicate(format: "label CONTAINS[c] %@ AND label CONTAINS[c] 'kick'", TestConfig.userBDisplayName)
        ).firstMatch
        XCTAssertTrue(kickedLine.waitForExistence(timeout: 15), "No action message for the kicked member")
        let members = (try? runBlocking { try await PeerActions.groupMemberUIDs(guid: created.guid) }) ?? []
        XCTAssertFalse(members.contains(TestConfig.userBUid), "Kicked member is still in the group (backend)")
    }

    func test_GRP_LIFE_joinPublicGroupFromGroupsTab() throws {
        let token = UUID().uuidString.prefix(8).lowercased()
        let guid = "e2e-pub-\(token)", name = "E2E Public \(token)"
        try runBlocking {
            try await PeerActions.createGroup(guid: guid, name: name, owner: TestConfig.userBUid)
        }
        ctx = SeedData.TestGroupContext(group: SeedData.TestGroup(guid: guid, name: name, memberUid: TestConfig.userBUid),
                                        ownedByA: false)

        app = AppLauncher.launchAndWaitForHome()
        let cell = groupsSearch(for: name)
        XCTAssertTrue(cell.waitForExistence(timeout: 12), "Public group not listed for a non-member")
        cell.tap()
        // A public group joins on open; tap Join if the kit asks first.
        if app.buttons["Join"].firstMatch.waitForExistence(timeout: 3) { app.buttons["Join"].firstMatch.tap() }
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Public group did not open")
        let joined = waitForBackend(timeout: 20) {
            try await PeerActions.groupMemberUIDs(guid: guid, as: nil).contains(TestConfig.userAUid)
        }
        XCTAssertTrue(joined, "User A is not a member after opening the public group (backend)")
    }

    func test_GRP_LIFE_groupDeletedByOwnerLeavesGroupsList() throws {
        let context = try runBlocking { try await SeedData.createGroupOwnedByBWithAAs("participant") }
        runBlocking { await PeerActions.deleteGroup(guid: context.group.guid, owner: TestConfig.userBUid) }
        XCTAssertFalse(try runBlocking { await PeerActions.groupExists(guid: context.group.guid) },
                       "Precondition failed: group still exists after the owner deleted it")

        app = AppLauncher.launchAndWaitForHome()
        XCTAssertFalse(groupsSearch(for: context.group.name).waitForExistence(timeout: 6),
                       "A deleted group is still listed in the Groups tab")
    }
}
