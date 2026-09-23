import XCTest

/// Group Info option visibility per member scope, against the sample app's real matrix
/// (GroupDetailsViewController.updateGroupInfo): owner/admin see everything incl. Delete and Exit;
/// moderator loses Add Members and Delete; participant additionally loses Banned Members.
/// Plus create-screen password validation and multi-select Add Members.
/// Sheet sources: GRP-062…GRP-066, GRP-003, GRP-073.
final class GroupRoleVisibilityTests: XCTestCase {

    private var app: XCUIApplication!
    private var ctx: SeedData.TestGroupContext?
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { [ctx, group] in
            await SeedData.deleteTestGroup(ctx)
            await SeedData.deleteTestGroup(group)
        }
        ctx = nil; group = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - Shared steps

    private func openGroupInfo(as scope: String?) throws {
        if let scope {
            ctx = try runBlocking { try await SeedData.createGroupOwnedByBWithAAs(scope) }
            app = openSeededGroup(ctx!.group)
        }
        XCTAssertTrue(ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.groupInfo),
                      "Could not open Group Info")
        XCTAssertTrue(visible("View Members").waitForExistence(timeout: 10),
                      "Group Info did not load (View Members missing)")
    }

    /// Options render as labeled rows/buttons; match either representation.
    private func visible(_ label: String) -> XCUIElement {
        let asText = app.staticTexts[label]
        if asText.exists { return asText }
        return app.buttons[label]
    }

    /// Search for one user in Add Members and tap their row. The field keeps the previous
    /// query between selections, so it is cleared character-by-character first — tapping a
    /// stray button inside the field was selecting the wrong element.
    private func selectAddMember(named name: String) {
        let search = app.searchFields.firstMatch.exists
            ? app.searchFields.firstMatch : app.textFields.firstMatch
        if search.waitForExistence(timeout: 8) {
            search.tap()
            let current = (search.value as? String) ?? ""
            if !current.isEmpty, current != search.placeholderValue {
                search.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue,
                                       count: current.count))
            }
            search.typeText(name)
        }
        let cell = app.cells.containing(.staticText, identifier: name).firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 12), "\(name) not listed in Add Members")
        cell.tap()
    }

    private func assertOption(_ label: String, shown: Bool) {
        let element = visible(label)
        if shown {
            XCTAssertTrue(element.waitForExistence(timeout: 6), "\(label) should be visible")
        } else {
            XCTAssertFalse(element.waitForExistence(timeout: 2), "\(label) should be hidden")
        }
    }

    // MARK: - Role matrix

    /// GRP-063/064/065/066 — a participant sees members + Leave, and none of the admin surface.
    func test_GRP_participantInfoHidesAdminOptions() throws {
        try openGroupInfo(as: "participant")
        assertOption("View Members", shown: true)
        assertOption("Leave", shown: true)
        assertOption("Add Members", shown: false)
        assertOption("Banned Members", shown: false)
        assertOption("Delete and Exit", shown: false)
    }

    /// GRP-064 — a moderator regains Banned Members but still cannot add or delete.
    func test_GRP_moderatorInfoShowsBannedOnly() throws {
        try openGroupInfo(as: "moderator")
        assertOption("Banned Members", shown: true)
        assertOption("Add Members", shown: false)
        assertOption("Delete and Exit", shown: false)
        assertOption("Leave", shown: true)
    }

    /// GRP-063/066 — an admin gets the full owner surface, including Delete and Exit.
    func test_GRP_adminInfoShowsFullSurface() throws {
        try openGroupInfo(as: "admin")
        assertOption("Add Members", shown: true)
        assertOption("Banned Members", shown: true)
        assertOption("Delete and Exit", shown: true)
    }

    /// GRP-065 — the sole owner of an empty group cannot Leave (only Delete and Exit).
    func test_GRP_soleOwnerHasNoLeaveOption() throws {
        group = try runBlocking { try await SeedData.createEmptyTestGroup() }
        app = openSeededGroup(group!)
        try openGroupInfo(as: nil)
        assertOption("Delete and Exit", shown: true)
        assertOption("Leave", shown: false)
    }

    // MARK: - Create-screen validation

    /// GRP-003 — a password group with an empty password must not be created.
    func test_GRP_passwordGroupRequiresPassword() throws {
        app = AppLauncher.launchAndWaitForHome()
        AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups)
        XCTAssertTrue(AppLauncher.tapCreateGroupButton(app), "Create-group button not found")
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 10),
                      "Create-group screen did not appear")

        let nameField = app.textFields.firstMatch
        XCTAssertTrue(nameField.waitForExistence(timeout: 8), "Group name field not found")
        nameField.tap()
        nameField.typeText("E2E NoPw \(UUID().uuidString.prefix(6))")

        let passwordSegment = ["Password", "PASSWORD", "Protected"].lazy
            .map { self.app.buttons[$0] }.first { $0.exists }
        XCTAssertNotNil(passwordSegment, "No Password segment on the type selector")
        passwordSegment?.tap()

        // Leave the password empty and try to create.
        for label in ["Create Group", "Create", "CREATE_GROUP"] where app.buttons[label].exists {
            app.buttons[label].tap(); break
        }
        XCTAssertTrue(ComponentQueries.createGroupScreenVisible(app, timeout: 3) || app.alerts.firstMatch.exists,
                      "Password group was created without a password")
    }

    // MARK: - Multi-select add

    /// GRP-073/074 — selecting two users in Add Members adds both (verified over REST).
    func test_GRP_addMultipleMembersAtOnce() throws {
        var created: SeedData.TestGroup?
        (app, created) = openSeededGroupWithMember()
        group = created
        guard let group else { return }

        // This case needs two users beyond A and B who are never members of throwaway groups —
        // the provisioned e2e_mod / e2e_pat. Their display names are read from the backend rather
        // than hardcoded, and the case skips when they do not exist on the app the secrets file
        // points at, instead of failing on "E2E Mod not listed" for a reason unrelated to
        // multi-select.
        let extraUids = ["e2e_mod", "e2e_pat"]
        let extraNames: [String] = try runBlocking {
            var names: [String] = []
            for uid in extraUids {
                if let name = await PeerActions.userDisplayName(uid) { names.append(name) }
            }
            return names
        }
        if extraNames.count < extraUids.count {
            throw XCTSkip("Needs provisioned users \(extraUids.joined(separator: ", ")) on this app")
        }

        try openGroupInfo(as: nil)
        visible("Add Members").tap()

        for name in extraNames {
            selectAddMember(named: name)
        }
        // The confirm button's title carries the live selection count ("Add 2 Members"), so it
        // can only be matched by prefix — a fixed "Add Members" label never exists.
        let confirm = app.buttons.matching(
            NSPredicate(format: "label BEGINSWITH[c] 'Add' AND label CONTAINS[c] 'member'")
        ).firstMatch
        XCTAssertTrue(confirm.waitForExistence(timeout: 8),
                      "Add-members confirm button not found")
        confirm.tap()

        XCTAssertTrue(waitForBackend(timeout: 20) {
            let members = (try? await PeerActions.groupMemberUIDs(guid: group.guid)) ?? []
            return extraUids.allSatisfy(members.contains)
        }, "Both selected users were not added to the group")
    }
}
