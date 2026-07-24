import XCTest

/// Owner immunity: moderator A must not be offered Kick/Ban on the owner's row (throwaway B-owned group).
/// `E2EAdminCheckTests` shows the same swipe reveals Kick/Ban on a regular member, so absence here is a real signal.
final class GroupOwnerImmunityTests: XCTestCase {

    private var app: XCUIApplication!
    private var ctx: SeedData.TestGroupContext?

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        ctx = try runBlocking { try await SeedData.createGroupOwnedByBWithAAs("moderator") }
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedContext = ctx; ctx = nil
        runBlocking { await SeedData.deleteTestGroup(capturedContext) }
    }

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

        let ownerRow = app.cells.containing(.staticText, identifier: TestConfig.userBDisplayName).firstMatch
        XCTAssertTrue(ownerRow.waitForExistence(timeout: 10), "Owner row not listed in the Members modal")
        XCTAssertTrue(app.staticTexts["Owner"].exists, "Owner badge not shown — cannot confirm this is the owner row")

        for _ in 0..<3 { ownerRow.swipeLeft() }
        XCTAssertFalse(app.buttons["Kick"].exists, "A moderator was offered Kick on the group owner")
        XCTAssertFalse(app.buttons["Ban"].exists, "A moderator was offered Ban on the group owner")
    }

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
