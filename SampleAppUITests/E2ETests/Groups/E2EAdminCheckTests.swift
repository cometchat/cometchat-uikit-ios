import XCTest

/// Real admin mutations (Kick/Ban/Scope) on a throwaway per-run group (A = owner, B = member), never the shared supergroup.
/// Outcomes asserted on the backend — the members UI list has a refresh glitch. Located by content (no AX ids in framework components).
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

    private func openGroupInfo() {
        guard let group else { return XCTFail("Throwaway group was not seeded") }
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not open \(group.name)")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")

        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.groupInfo),
            "Could not open Group Info from header menu"
        )
    }

    /// The card's label isn't hittable (the card view takes the tap), so fall back to a coordinate.
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

    private func memberRow() -> XCUIElement {
        app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
    }

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

    func test_E2E_membersListShows() {
        openGroupInfo()
        openMembersModal()
        XCTAssertTrue(
            memberRow().waitForExistence(timeout: 10)
                || app.staticTexts["Owner"].exists,
            "Members modal did not list members"
        )
    }

    func test_E2E_adminSeesAddMembers() {
        openGroupInfo()
        XCTAssertTrue(
            affordanceVisible(["Add Members", "ADD_MEMBERS"], timeout: 8),
            "Owner should see the Add Members option (proves admin role)"
        )
    }

    func test_E2E_adminKicksMember() throws {
        guard let group else { return XCTFail("no group") }
        openGroupInfo()
        openMembersModal()
        XCTAssertTrue(memberRow().waitForExistence(timeout: 10), "Member to kick not listed")

        XCTAssertTrue(revealMemberActions(), "Member-row actions (Kick/Ban/Scope) did not reveal")
        app.buttons["Kick"].tap()
        XCTAssertTrue(confirmIfPrompted(), "Kick confirmation (Yes) did not appear")

        let removed = waitForBackend(timeout: 15) {
            let members = try await PeerActions.groupMemberUIDs(guid: group.guid)
            return !members.contains(group.memberUid)
        }
        XCTAssertTrue(removed, "Kicked member still present in the group on the backend")
    }

    func test_E2E_adminBansMember() throws {
        guard let group else { return XCTFail("no group") }
        openGroupInfo()
        openMembersModal()
        XCTAssertTrue(memberRow().waitForExistence(timeout: 10), "Member to ban not listed")

        XCTAssertTrue(revealMemberActions(), "Member-row actions (Kick/Ban/Scope) did not reveal")
        app.buttons["Ban"].tap()
        XCTAssertTrue(confirmIfPrompted(), "Ban confirmation (Yes) did not appear")

        let banned = waitForBackend(timeout: 15) {
            let active = try await PeerActions.groupMemberUIDs(guid: group.guid)
            return !active.contains(group.memberUid)
        }
        XCTAssertTrue(banned, "Banned member still present in the active member list on the backend")
    }

    func test_E2E_adminChangesScope() throws {
        guard let group else { return XCTFail("no group") }
        openGroupInfo()
        openMembersModal()
        XCTAssertTrue(memberRow().waitForExistence(timeout: 10), "Member to change scope not listed")

        XCTAssertTrue(revealMemberActions(), "Member-row actions (Kick/Ban/Scope) did not reveal")
        app.buttons["Scope"].tap()

        let admin = app.staticTexts["Admin"]
        XCTAssertTrue(admin.waitForExistence(timeout: 8), "Change Scope sheet (Admin/Moderator) did not appear")
        if admin.isHittable { admin.tap() } else { admin.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }

        let save = app.buttons["Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 6), "Save button not found on Change Scope sheet")
        save.tap()

        let promoted = waitForBackend(timeout: 15) {
            let scope = try await PeerActions.memberScope(guid: group.guid, uid: group.memberUid)
            return scope?.lowercased() == "admin"
        }
        XCTAssertTrue(promoted, "Member scope did not change to admin on the backend")
    }

    func test_GRP_changeScopeToParticipant() throws {
        guard let group else { return XCTFail("no group") }
        // Start B at admin so a demote to participant is a real change.
        try runBlocking { try await PeerActions.setMemberScope(guid: group.guid, uid: group.memberUid, scope: "admin") }

        openGroupInfo()
        openMembersModal()
        XCTAssertTrue(memberRow().waitForExistence(timeout: 10), "Member to change scope not listed")

        XCTAssertTrue(revealMemberActions(), "Member-row actions (Kick/Ban/Scope) did not reveal")
        app.buttons["Scope"].tap()

        let participant = app.staticTexts["Participant"]
        XCTAssertTrue(participant.waitForExistence(timeout: 8), "Change Scope sheet (Participant row) did not appear")
        if participant.isHittable { participant.tap() } else { participant.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap() }

        let save = app.buttons["Save"]
        XCTAssertTrue(save.waitForExistence(timeout: 6), "Save button not found on Change Scope sheet")
        save.tap()

        let demoted = waitForBackend(timeout: 15) {
            let scope = try await PeerActions.memberScope(guid: group.guid, uid: group.memberUid)
            return scope?.lowercased() == "participant"
        }
        XCTAssertTrue(demoted, "Member scope did not change to participant on the backend")
    }

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

    /// The Kick/Ban confirm is a custom card, not a UIAlertController — its "Yes" is a plain button, not under `app.alerts`.
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
