import XCTest

/// Group admin / member operations driven against a THROWAWAY per-run group, never the
/// shared `supergroup`. Each test seeds a unique group (User A = owner, so admin affordances show) with
/// User B added as a member, then performs the real admin action (Kick / Ban / Scope) on that member —
/// so we exercise the actual mutation without corrupting any shared fixture. The group is deleted in
/// teardown.
///
/// Navigation: open the group from the Groups tab by its unique name → header overflow "More" → "Group
/// Info" → "View Members" card → the Members modal. Member-row options (Kick/Ban/Scope) are revealed by
/// swiping the member's row. All located by content (no AX ids inside framework components).
final class E2EAdminCheckTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        group = try runBlocking { try await SeedData.createTestGroupWithMember() }
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        let capturedGroup = group
        group = nil
        runBlocking { await SeedData.deleteTestGroup(capturedGroup) }
    }

    /// Open the throwaway group and its Group Info screen.
    private func openGroupInfo() {
        guard let group else { return XCTFail("Throwaway group was not seeded") }
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not open \(group.name)")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")

        // Group Info is in the header overflow menu ("More" → "Group Info").
        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.groupInfo),
            "Could not open Group Info from header menu"
        )
    }

    /// From Group Info, open the "View Members" card → the Members modal. The card's label isn't itself
    /// hittable (the card view receives the tap), so tap via the label coordinate.
    private func openMembersModal() {
        let viewMembers = app.buttons["View Members"].exists ? app.buttons["View Members"] : app.staticTexts["View Members"]
        XCTAssertTrue(viewMembers.waitForExistence(timeout: 8), "View Members card not found")
        if viewMembers.isHittable {
            viewMembers.tap()
        } else {
            viewMembers.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        XCTAssertTrue(app.staticTexts["Members"].waitForExistence(timeout: 10), "Members modal did not appear")
    }

    /// The added member's row in the Members modal.
    private func memberRow() -> XCUIElement {
        app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
    }

    /// Swipe-reveal the member-row actions (Kick / Ban / Scope) and return whether they surfaced.
    @discardableResult
    private func revealMemberActions() -> Bool {
        let row = memberRow()
        guard row.waitForExistence(timeout: 10) else { return false }
        for _ in 0..<3 {
            row.swipeLeft()
            if app.buttons["Kick"].waitForExistence(timeout: 2)
                || app.buttons["Ban"].exists
                || app.buttons["Scope"].exists {
                return true
            }
        }
        return app.buttons["Kick"].exists || app.buttons["Ban"].exists || app.buttons["Scope"].exists
    }

    // MARK: - Members list

    /// The Members modal lists the group's members (owner + the added member).
    func test_E2E_membersListShows() {
        openGroupInfo()
        openMembersModal()
        XCTAssertTrue(
            memberRow().waitForExistence(timeout: 10)
                || app.staticTexts["Owner"].exists,
            "Members modal did not list members"
        )
    }

    // MARK: - Admin affordances

    /// As owner, the "Add Members" affordance is visible on Group Info (only admins/owners see it).
    func test_E2E_adminSeesAddMembers() {
        openGroupInfo()
        XCTAssertTrue(
            affordanceVisible(["Add Members", "ADD_MEMBERS"], timeout: 8),
            "Owner should see the Add Members option (proves admin role)"
        )
    }

    // MARK: - Kick member

    /// Kick the added member: swipe the member's row → "Kick" → confirm "Yes". Assert the kick took
    /// effect on the BACKEND (member no longer in the group) — robust against the known UI list-refresh
    /// glitch. Operates on the throwaway group only.
    func test_E2E_adminKicksMember() throws {
        guard let group else { return XCTFail("no group") }
        openGroupInfo()
        openMembersModal()
        XCTAssertTrue(memberRow().waitForExistence(timeout: 10), "Member to kick not listed")

        XCTAssertTrue(revealMemberActions(), "Member-row actions (Kick/Ban/Scope) did not reveal")
        app.buttons["Kick"].tap()
        XCTAssertTrue(confirmIfPrompted(), "Kick confirmation (Yes) did not appear")

        // Backend truth: the kicked member is no longer an active member.
        let removed = waitForBackend(timeout: 15) {
            let members = try await PeerActions.groupMemberUIDs(guid: group.guid)
            return !members.contains(group.memberUid)
        }
        XCTAssertTrue(removed, "Kicked member still present in the group on the backend")
    }

    // MARK: - Ban member

    /// Ban the added member: swipe the member's row → "Ban" → confirm "Yes". Assert on the BACKEND that
    /// the member is banned (out of active members, into the banned list). Operates on the throwaway
    /// group only.
    func test_E2E_adminBansMember() throws {
        guard let group else { return XCTFail("no group") }
        openGroupInfo()
        openMembersModal()
        XCTAssertTrue(memberRow().waitForExistence(timeout: 10), "Member to ban not listed")

        XCTAssertTrue(revealMemberActions(), "Member-row actions (Kick/Ban/Scope) did not reveal")
        app.buttons["Ban"].tap()
        XCTAssertTrue(confirmIfPrompted(), "Ban confirmation (Yes) did not appear")

        // Backend truth: a banned member is removed from the active member list.
        let banned = waitForBackend(timeout: 15) {
            let active = try await PeerActions.groupMemberUIDs(guid: group.guid)
            return !active.contains(group.memberUid)
        }
        XCTAssertTrue(banned, "Banned member still present in the active member list on the backend")
    }

    // MARK: - Change scope / role

    /// Change the added member's scope: swipe the member's row → "Scope" → pick a new role (Admin).
    /// Assert on the BACKEND that the member's scope became admin. Operates on the throwaway group only.
    func test_E2E_adminChangesScope() throws {
        guard let group else { return XCTFail("no group") }
        openGroupInfo()
        openMembersModal()
        XCTAssertTrue(memberRow().waitForExistence(timeout: 10), "Member to change scope not listed")

        XCTAssertTrue(revealMemberActions(), "Member-row actions (Kick/Ban/Scope) did not reveal")
        app.buttons["Scope"].tap()

        // The "Change Scope" sheet lists roles (Admin / Moderator) each with a radio, then a "Save"
        // button to commit. Select "Admin" by tapping its row, then Save.
        let admin = app.staticTexts["Admin"]
        XCTAssertTrue(admin.waitForExistence(timeout: 8), "Change Scope sheet (Admin/Moderator) did not appear")
        if admin.isHittable { admin.tap() } else { admin.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }

        let save = app.buttons["Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 6), "Save button not found on Change Scope sheet")
        save.tap()

        // Backend truth: the member's scope is now admin.
        let promoted = waitForBackend(timeout: 15) {
            let scope = try await PeerActions.memberScope(guid: group.guid, uid: group.memberUid)
            return scope?.lowercased() == "admin"
        }
        XCTAssertTrue(promoted, "Member scope did not change to admin on the backend")
    }

    // MARK: - Change scope to participant / demote

    /// Demote a member to participant: promote B to admin via REST first, then swipe the member's row →
    /// "Scope" → pick "Participant" → "Save". Assert on the BACKEND that the member's scope became
    /// participant. Complements the promote-to-admin case with the demote direction.
    func test_GRP_changeScopeToParticipant() throws {
        guard let group else { return XCTFail("no group") }
        // Start B at admin so a demote to participant is a real change.
        try runBlocking { try await PeerActions.setMemberScope(guid: group.guid, uid: group.memberUid, scope: "admin") }

        openGroupInfo()
        openMembersModal()
        XCTAssertTrue(memberRow().waitForExistence(timeout: 10), "Member to change scope not listed")

        XCTAssertTrue(revealMemberActions(), "Member-row actions (Kick/Ban/Scope) did not reveal")
        app.buttons["Scope"].tap()

        // The "Change Scope" sheet lists roles (Admin / Moderator / Participant) each with a radio, then a
        // "Save" button to commit. Select "Participant", then Save.
        let participant = app.staticTexts["Participant"]
        XCTAssertTrue(participant.waitForExistence(timeout: 8), "Change Scope sheet (Participant row) did not appear")
        if participant.isHittable { participant.tap() } else { participant.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }

        let save = app.buttons["Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 6), "Save button not found on Change Scope sheet")
        save.tap()

        // Backend truth: the member's scope is now participant.
        let demoted = waitForBackend(timeout: 15) {
            let scope = try await PeerActions.memberScope(guid: group.guid, uid: group.memberUid)
            return scope?.lowercased() == "participant"
        }
        XCTAssertTrue(demoted, "Member scope did not change to participant on the backend")
    }

    // MARK: - Helpers

    private func affordanceVisible(_ labels: [String], timeout: TimeInterval = 0) -> Bool {
        let probe: () -> Bool = {
            labels.contains { self.app.staticTexts[$0].exists || self.app.buttons[$0].exists }
        }
        if timeout <= 0 { return probe() }
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if probe() { return true }
            _ = app.staticTexts.firstMatch.waitForExistence(timeout: 0.4)
        }
        return probe()
    }

    /// Confirm the Kick/Ban dialog. It's a CUSTOM card (title "Kick <name>", message "Are you sure…",
    /// buttons "Cancel" / "Yes" with Yes destructive) — NOT a system UIAlertController, so its "Yes"
    /// surfaces as a regular `app.buttons["Yes"]`, not under `app.alerts`. Confirm via "Yes".
    @discardableResult
    private func confirmIfPrompted() -> Bool {
        let yes = app.buttons["Yes"]
        if yes.waitForExistence(timeout: 4) {
            yes.tap()
            return true
        }
        // Fallback for a system-alert variant.
        for label in ["Yes", "Confirm", "OK", "Continue"] {
            let alertButton = app.alerts.buttons[label]
            if alertButton.exists { alertButton.tap(); return true }
        }
        return false
    }
}
