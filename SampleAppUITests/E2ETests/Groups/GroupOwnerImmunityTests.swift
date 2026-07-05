import XCTest

/// GRP-079 — owner immunity. A moderator cannot Kick/Ban the group OWNER. Seeds a THROWAWAY group OWNED
/// BY User B, with the logged-in User A joined as a `moderator`. A opens the Members modal and swipes the
/// OWNER's (B's) row; the destructive actions (Kick/Ban) must NOT surface for the owner.
///
/// This is a real, falsifiable negative assertion: the same swipe-reveal proven to expose Kick/Ban on a
/// regular member (`E2EAdminCheckTests`) is run against the owner row, and their ABSENCE is asserted — if
/// a regression let a moderator kick the owner, the buttons would appear and this test would fail.
final class GroupOwnerImmunityTests: XCTestCase {

    private var app: XCUIApplication!
    private var ctx: SeedData.TestGroupContext?

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        // Group owned by B; A joins as a moderator (an admin-tier role that still can't touch the owner).
        ctx = try runBlocking { try await SeedData.createGroupOwnedByBWithAAs("moderator") }
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedContext = ctx; ctx = nil
        runBlocking { await SeedData.deleteTestGroup(capturedContext) }
    }

    /// A moderator swiping the owner's member row sees no Kick/Ban actions.
    func test_GRP_moderatorCannotKickOrBanOwner() throws {
        guard let ctx else { return XCTFail("Throwaway B-owned group was not seeded") }
        AppLauncher.launchAndWaitForHome(app)
        XCTAssertTrue(AppLauncher.openGroup(app, named: ctx.group.name), "Could not open \(ctx.group.name)")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")

        XCTAssertTrue(
            ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.groupInfo),
            "Could not open Group Info from header menu"
        )
        openMembersModal()

        // The owner (B) row is present and badged "Owner" (confirmed on device — A's own row renders as
        // "You"). Assert the owner row and its badge exist so the swipe below targets a real row (not an
        // empty list — that would make the negative check vacuous).
        let ownerRow = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(ownerRow.waitForExistence(timeout: 10), "Owner row not listed in the Members modal")
        XCTAssertTrue(app.staticTexts["Owner"].exists, "Owner badge not shown — cannot confirm this is the owner row")

        // Swipe the owner's row; the destructive actions must NOT surface (owner immunity). The POSITIVE
        // CONTROL that this same swipe-reveal DOES expose Kick/Ban on a regular member is established by
        // the green `E2EAdminCheckTests` (A-owned group, member row → Kick/Ban revealed), so this absence
        // is a real signal, not a broken-gesture artifact.
        for _ in 0..<3 { ownerRow.swipeLeft() }
        XCTAssertFalse(app.buttons["Kick"].exists, "A moderator was offered Kick on the group owner")
        XCTAssertFalse(app.buttons["Ban"].exists, "A moderator was offered Ban on the group owner")
    }

    // MARK: - Helpers

    /// Open the "View Members" card → the Members modal (the card view takes the tap, so fall back to a coordinate).
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
}
