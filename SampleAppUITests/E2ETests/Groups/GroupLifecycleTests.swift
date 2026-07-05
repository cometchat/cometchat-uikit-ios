import XCTest

/// Group lifecycle flows that mutate membership/ownership — leave, ownership transfer, and the
/// banned-members list + unban.
/// Each uses a THROWAWAY per-run group and asserts the outcome on the BACKEND (membership / scope /
/// banned-state), not the UI list, which has a known refresh glitch.
///
/// Confirmed UI flow (via diagnostic dump, not guessed):
/// - Group Info exposes cards "View Members" / "Add Members" / "Banned Members" and actions "Leave" /
///   "Delete Chat" / "Delete and Exit".
/// - Leave (participant): tap "Leave" → confirm card "Leave this group?" → the hittable "Leave" button.
/// - Leave (owner): tap "Leave" → "Ownership Transfer" card → "Transfer" → member picker → select a
///   member → "Done" (an owner must transfer before leaving).
/// - Banned Members: the banned row carries a trailing "Close" (X) control → "Unban Member" card →
///   "Unban".
final class GroupLifecycleTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?
    private var ctx: SeedData.TestGroupContext?

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedGroup = group; group = nil
        let capturedContext = ctx; ctx = nil
        runBlocking {
            await SeedData.deleteTestGroup(capturedGroup)
            await SeedData.deleteTestGroup(capturedContext)
        }
    }

    // MARK: - Leave group

    /// As a participant, Leave the group: tap Leave → confirm → the member is removed on the backend.
    func test_GRP_leaveGroup() throws {
        // A must be a non-owner to leave without transferring ownership.
        let context = try runBlocking { try await SeedData.createGroupOwnedByBWithAAs("participant") }
        ctx = context
        openGroupInfo(name: context.group.name)

        tapCard("Leave")
        // Confirm card "Leave this group?" — tap the hittable "Leave" (not the card's own label).
        XCTAssertTrue(tapHittable("Leave", timeout: 8), "Leave confirmation did not appear")

        // Backend truth: User A is no longer a member of the group. Read as admin (`as: nil`) — a
        // just-departed A can't read the members list (ERR_GROUP_NOT_JOINED).
        let left = waitForBackend(timeout: 15) {
            let members = try await PeerActions.groupMemberUIDs(guid: context.group.guid, as: nil)
            return !members.contains(TestConfig.userAUid)
        }
        XCTAssertTrue(left, "User A still a member after leaving (backend)")
    }

    // MARK: - Transfer ownership

    /// As the owner, leaving requires transferring ownership: Leave → Ownership Transfer → Transfer →
    /// select member → Done. Assert on the backend that the new owner (B) is admin-scoped.
    func test_GRP_transferOwnership() throws {
        let testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() } // A = owner
        group = testGroup
        openGroupInfo(name: testGroup.name)

        tapCard("Leave")
        // Owner path: an "Ownership Transfer" card appears with a "Transfer" button.
        XCTAssertTrue(
            app.staticTexts["Ownership Transfer"].waitForExistence(timeout: 8)
                || app.buttons["Transfer"].exists,
            "Ownership Transfer prompt did not appear for the owner"
        )
        XCTAssertTrue(tapHittable("Transfer", timeout: 8), "Transfer button did not respond")

        // Member picker: select the other member (B), then confirm with Done.
        let member = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(member.waitForExistence(timeout: 10), "Member picker did not list the transfer target")
        member.tap()
        XCTAssertTrue(tapHittable("Done", timeout: 8), "Done did not commit the ownership transfer")

        // Backend truth: B is now an admin (owner scope surfaces as admin in the members list). Read as
        // admin (`as: nil`) — after transferring, A may have left and can't read the members list.
        let transferred = waitForBackend(timeout: 20) {
            let scope = try await PeerActions.memberScope(guid: testGroup.guid, uid: TestConfig.userBUid, as: nil)
            return scope?.lowercased() == "admin"
        }
        XCTAssertTrue(transferred, "Ownership did not transfer to B on the backend (B not admin)")
    }

    // MARK: - Add members

    /// The Add Members screen lists non-member users.
    func test_GRP_addMembersShowsNonMembers() throws {
        let testGroup = try runBlocking { try await SeedData.createEmptyTestGroup() }
        group = testGroup
        openGroupInfo(name: testGroup.name)
        tapCard("Add Members")

        // The picker opens as a modal user list with a search field, populated with non-member users.
        // Assert the picker opened (its search field) and that it has at least one user row — a content/
        // structure signal, not an index binding on an async, reorderable list.
        XCTAssertTrue(app.searchFields.firstMatch.waitForExistence(timeout: 10), "Add Members picker did not open")
        XCTAssertTrue(app.cells.firstMatch.waitForExistence(timeout: 12), "Add Members picker listed no users")
    }

    /// Selecting a user and confirming adds them to the group (backend-verified). Search for User B,
    /// select the row, tap "Add N Members".
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

        // A confirm button appears once a user is selected — "Add N Members".
        let add = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Add'")).firstMatch
        XCTAssertTrue(add.waitForExistence(timeout: 8), "Add confirm button did not appear after selecting a user")
        add.tap()

        // Backend truth: User B is now a member.
        let added = waitForBackend(timeout: 20) {
            let members = try await PeerActions.groupMemberUIDs(guid: testGroup.guid)
            return members.contains(TestConfig.userBUid)
        }
        XCTAssertTrue(added, "Selected user was not added to the group on the backend")
    }

    // MARK: - Delete and exit

    /// GRP-069: as the owner, "Delete and Exit" removes the group. Open Group Info → tap "Delete and Exit"
    /// → confirm → assert on the BACKEND that the group no longer exists. Operates on a THROWAWAY group.
    /// Distinct from Leave (GRP-066, which only removes the member and leaves the group intact) — this
    /// deletes the whole group, verified by `groupExists` going false.
    func test_GRP_deleteAndExitGroup() throws {
        let testGroup = try runBlocking { try await SeedData.createTestGroupWithMember() } // A = owner
        group = testGroup

        // Precondition: the group exists before the UI delete.
        XCTAssertTrue(try runBlocking { await PeerActions.groupExists(guid: testGroup.guid) },
                      "Precondition failed: throwaway group was not created")

        openGroupInfo(name: testGroup.name)

        tapCard("Delete and Exit")
        // Confirm card — the destructive verb varies ("Delete and Exit" / "Delete" / "Yes"); tap the
        // hittable confirm.
        XCTAssertTrue(
            tapHittable("Delete and Exit", timeout: 6)
                || tapHittable("Delete", timeout: 4)
                || tapHittable("Yes", timeout: 4),
            "Delete-and-Exit confirmation did not appear"
        )

        // Backend truth: the group is gone.
        let gone = waitForBackend(timeout: 20) {
            !(await PeerActions.groupExists(guid: testGroup.guid))
        }
        XCTAssertTrue(gone, "Group still exists on the backend after Delete and Exit")
        // Already deleted — avoid a redundant teardown delete of a gone group.
        if gone { group = nil }
    }

    // MARK: - Banned members list

    /// A member banned via REST appears in the Banned Members list.
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

    // MARK: - Unban

    /// Unban a banned member from the Banned Members list: tap the row's trailing "Close" (X) → "Unban"
    /// confirm → assert on the backend the member is no longer banned (the ERR_BANNED probe clears).
    func test_GRP_unbanMember() throws {
        let testGroup = try runBlocking { () -> SeedData.TestGroup in
            let created = try await SeedData.createTestGroupWithMember()
            try await PeerActions.banGroupMember(guid: created.guid, uid: created.memberUid)
            return created
        }
        group = testGroup

        // Precondition: confirm B really is banned before the UI unban (so the assertion is meaningful).
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

        // "Unban Member" confirm card → tap "Unban".
        XCTAssertTrue(tapHittable("Unban", timeout: 8), "Unban confirmation did not appear")

        // Backend truth: the ERR_BANNED probe now clears (the kick succeeds → no longer banned). Note this
        // is a mutating probe (it kicks the now-unbanned member), which is fine — the group is thrown away.
        let unbanned = waitForBackend(timeout: 15) {
            !(await PeerActions.isGroupMemberBanned(guid: testGroup.guid, uid: testGroup.memberUid))
        }
        XCTAssertTrue(unbanned, "Member still banned on the backend after UI unban")
    }

    // MARK: - Helpers

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

    /// Tap the HITTABLE button with `label` — confirmation dialogs reuse the action's verb ("Leave",
    /// "Transfer"), so the same label exists as both the (non-hittable) source card and the (hittable)
    /// confirm button. Prefer the hittable one.
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
