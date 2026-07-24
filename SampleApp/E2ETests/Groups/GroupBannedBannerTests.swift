import XCTest

/// A banned user opening the group must not get a usable composer — a non-member banner replaces it, or the group won't open at all.
final class GroupBannedBannerTests: XCTestCase {

    private var app: XCUIApplication!
    private var ctx: SeedData.TestGroupContext?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedContext = ctx; ctx = nil
        runBlocking { await SeedData.deleteTestGroup(capturedContext) }
    }

    func test_GRP_openGroupAfterBannedShowsNonMemberState() throws {
        let context = try runBlocking { () -> SeedData.TestGroupContext in
            let created = try await SeedData.createGroupOwnedByBWithAAs("participant")
            try await PeerActions.banGroupMember(guid: created.group.guid, uid: TestConfig.userAUid, by: TestConfig.userBUid)
            return created
        }
        ctx = context
        app = AppLauncher.launchAndWaitForHome()

        guard AppLauncher.openGroup(app, named: context.group.name) else {
            XCTAssertTrue(app.tabBars.firstMatch.exists, "App unstable after a banned group failed to open")
            return
        }

        let composerGone = !ComponentQueries.composer(app).waitForExistence(timeout: 8)
        let bannerPredicate = NSPredicate(format:
            "label CONTAINS[c] 'no longer' OR label CONTAINS[c] 'not a member' OR label CONTAINS[c] 'banned' OR label CONTAINS[c] 'Join'")
        let banner = app.staticTexts.containing(bannerPredicate).firstMatch.waitForExistence(timeout: 8)
        XCTAssertTrue(composerGone || banner,
                      "Banned user still sees a usable composer with no non-member banner")
    }
}
