import XCTest

/// Throwaway per-run groups; outcomes asserted on the backend — the UI list has a refresh glitch.
final class GroupLifecycleTests: XCTestCase {

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

    func test_GRP_leaveGroup() throws {
        // A must be a non-owner to leave without transferring ownership.
        let context = try runBlocking { try await SeedData.createGroupOwnedByBWithAAs("participant") }
        ctx = context
        openGroupInfo(name: context.group.name)

        tapCard("Leave")
        XCTAssertTrue(tapHittable("Leave", timeout: 8), "Leave confirmation did not appear")

        // Read as admin (`as: nil`) — a just-departed A can't read the members list (ERR_GROUP_NOT_JOINED).
        let left = waitForBackend(timeout: 15) {
            let members = try await PeerActions.groupMemberUIDs(guid: context.group.guid, as: nil)
            return !members.contains(TestConfig.userAUid)
        }
        XCTAssertTrue(left, "User A still a member after leaving (backend)")
    }

    func test_GRP_transferOwnership() throws {
        let testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() } // A = owner
        group = testGroup
        openGroupInfo(name: testGroup.name)

        tapCard("Leave")
        XCTAssertTrue(
            app.staticTexts["Ownership Transfer"].waitForExistence(timeout: 8)
                || app.buttons["Transfer"].exists,
            "Ownership Transfer prompt did not appear for the owner"
        )
        XCTAssertTrue(tapHittable("Transfer", timeout: 8), "Transfer button did not respond")

        let member = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(member.waitForExistence(timeout: 10), "Member picker did not list the transfer target")
        member.tap()
        XCTAssertTrue(tapHittable("Done", timeout: 8), "Done did not commit the ownership transfer")

        // Owner scope surfaces as admin; read as admin (`as: nil`) — A may have left and can't read members.
        let transferred = waitForBackend(timeout: 20) {
            let scope = try await PeerActions.memberScope(guid: testGroup.guid, uid: TestConfig.userBUid, as: nil)
            return scope?.lowercased() == "admin"
        }
        XCTAssertTrue(transferred, "Ownership did not transfer to B on the backend (B not admin)")
    }

    func test_GRP_addMembersShowsNonMembers() throws {
        let testGroup = try runBlocking { try await SeedData.createEmptyTestGroup() }
        group = testGroup
        openGroupInfo(name: testGroup.name)
        tapCard("Add Members")

        // Assert structure (search field + a row), not an index binding on an async, reorderable list.
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 10), "Add Members picker did not open")
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 12), "Add Members picker listed no users")
    }

    func test_GRP_addMemberJoinsGroup() throws {
        let testGroup = try runBlocking { try await SeedData.createEmptyTestGroup() }
        group = testGroup
        openGroupInfo(name: testGroup.name)
        tapCard("Add Members")

        let search = app.searchFields.firstMatch
        XCTAssertTrue(search.waitForExistence(timeout: 10), "Add Members search field missing")
        search.tap()
        search.typeText(TestConfig.userBDisplayName)

        let bRow = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(bRow.waitForExistence(timeout: 12), "User B not found in the Add Members picker")
        bRow.tap()

        let add = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Add'")).firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 8), "Add confirm button did not appear after selecting a user")
        add.tap()

        let added = waitForBackend(timeout: 20) {
            let members = try await PeerActions.groupMemberUIDs(guid: testGroup.guid)
            return members.contains(TestConfig.userBUid)
        }
        XCTAssertTrue(added, "Selected user was not added to the group on the backend")
    }

    func test_GRP_deleteAndExitGroup() throws {
        let testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() } // A = owner
        group = testGroup

        XCTAssertTrue(try runBlocking { await PeerActions.groupExists(guid: testGroup.guid) },
                      "Precondition failed: throwaway group was not created")

        openGroupInfo(name: testGroup.name)

        tapCard("Delete and Exit")
        XCTAssertTrue(
            tapHittable("Delete and Exit", timeout: 6)
                || tapHittable("Delete", timeout: 4)
                || tapHittable("Yes", timeout: 4),
            "Delete-and-Exit confirmation did not appear"
        )

        let gone = waitForBackend(timeout: 20) {
            !(await PeerActions.groupExists(guid: testGroup.guid))
        }
        XCTAssertTrue(gone, "Group still exists on the backend after Delete and Exit")
        if gone { group = nil }
    }

    func test_GRP_bannedMemberInList() throws {
        let testGroup = try runBlocking { () -> SeedData.TestGroup in
            let created = try await SeedData.createTestGroupWithMember()
            try await PeerActions.banGroupMember(guid: created.guid, uid: created.memberUid)
            return created
        }
        group = testGroup
        openGroupInfo(name: testGroup.name)

        tapCard("Banned Members")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 12),
                      "Banned member not shown in the Banned Members list")
    }

    func test_GRP_unbanMember() throws {
        let testGroup = try runBlocking { () -> SeedData.TestGroup in
            let created = try await SeedData.createTestGroupWithMember()
            try await PeerActions.banGroupMember(guid: created.guid, uid: created.memberUid)
            return created
        }
        group = testGroup

        let bannedBefore = try runBlocking { await PeerActions.isGroupMemberBanned(guid: testGroup.guid, uid: testGroup.memberUid) }
        XCTAssertTrue(bannedBefore, "Precondition failed: member was not banned via REST")

        openGroupInfo(name: testGroup.name)
        tapCard("Banned Members")
        XCTAssertTrue(app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 12), "Banned row missing")

        // The unban control is the trailing "Close" (X) button on the banned row.
        let rowY = app.staticTexts[TestConfig.userBDisplayName].frame.midY
        let close = app.buttons.allElementsBoundByIndex
            .filter { $0.exists && $0.isHittable && abs($0.frame.midY - rowY) < 30 }
            .sorted { $0.frame.maxX > $1.frame.maxX }.first
        XCTAssertNotNil(close, "No trailing unban control on the banned row")
        close?.tap()

        XCTAssertTrue(tapHittable("Unban", timeout: 8), "Unban confirmation did not appear")

        let unbanned = waitForBackend(timeout: 15) {
            !(await PeerActions.isGroupMemberBanned(guid: testGroup.guid, uid: testGroup.memberUid))
        }
        XCTAssertTrue(unbanned, "Member still banned on the backend after UI unban")
    }

    private func openGroupInfo(name: String) {
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: name), "Could not open \(name)")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")
        XCTAssertTrue(ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.groupInfo),
                      "Could not open Group Info from header menu")
    }

    /// Tap a Group Info card/action by label (the card view receives the tap, so fall back to a coordinate).
    private func tapCard(_ label: String) {
        let cardElement = app.buttons[label].exists ? app.buttons[label] : app.staticTexts[label]
        XCTAssertTrue(cardElement.waitForExistence(timeout: 8), "\(label) card/action not found")
        if cardElement.isHittable { cardElement.tap() } else { cardElement.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }
    }

    /// Confirm dialogs reuse the action's verb, so the label exists as both source card and confirm button — tap the hittable one.
    @discardableResult
    private func tapHittable(_ label: String, timeout: TimeInterval) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        repeat {
            let hit = app.buttons.matching(identifier: label).allElementsBoundByIndex.first { $0.exists && $0.isHittable }
            if let hit { hit.tap(); return true }
            _ = app.buttons.firstMatch.waitForExistence(timeout: 0.4)
        } while Date() < deadline
        return false
    }
}
