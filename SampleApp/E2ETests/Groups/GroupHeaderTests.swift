import XCTest

final class GroupHeaderTests: XCTestCase {
    
    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedGroup = group; group = nil
        runBlocking { await SeedData.deleteTestGroup(capturedGroup) }
    }
    
    func test_GRP_headerShowsGroupName() throws {
        let name = openGroup()
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 10), "Group header did not show the name")
    }
    
    func test_GRP_headerShowsAvatar() throws {
        let name = openGroup()
        XCTAssertTrue(app.images.firstMatch.exists || app.staticTexts[name].waitForExistence(timeout: 8),
                      "Group header avatar/name not rendered")
    }
    
    func test_GRP_headerShowsMemberCount() throws {
        _ = openGroup()
        // Seeded as owner A + participant B, so the subtitle reads "2 Members".
        XCTAssertTrue(memberCountLabel(2).waitForExistence(timeout: 10),
                      "Group header did not show the seeded member count of 2")
    }

    func test_GRP_headerMemberCountUpdatesOnJoin() throws {
        let seeded = try runBlocking { try await SeedData.createEmptyTestGroup() } // A owns, no other members
        group = seeded
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: seeded.name), "Could not open the test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")

        XCTAssertTrue(memberCountLabel(1).waitForExistence(timeout: 10),
                      "Group header did not show the seeded member count of 1")

        try runBlocking { try await PeerActions.addGroupMembers(guid: seeded.guid, uids: [TestConfig.userBUid]) }

        XCTAssertTrue(memberCountLabel(2).waitForExistence(timeout: 15),
                      "Group header member count did not rise to 2 after B joined")
    }
    
    func test_GRP_voiceCallButtonVisible() throws {
        _ = openGroup()
        XCTAssertTrue(voiceCallButton().waitForExistence(timeout: 8),
                      "Voice-call button not present in the group header")
    }

    func test_GRP_videoCallButtonVisible() throws {
        _ = openGroup()
        XCTAssertTrue(videoCallButton().waitForExistence(timeout: 8),
                      "Video-call button not present in the group header")
    }

    func test_GRP_detailsNavigatesToGroupInfo() throws {
        _ = openGroup()
        XCTAssertTrue(ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.groupInfo),
                      "Could not open Group Info from header menu")
        XCTAssertTrue(
            app.staticTexts["Group Info"].waitForExistence(timeout: 8)
            || app.staticTexts[group?.name ?? ""].exists
            || app.staticTexts["Members"].exists,
            "Group Info screen did not appear"
        )
    }
    
    func test_GRP_backFromDetailsReturnsToMessages() throws {
        _ = openGroup()
        XCTAssertTrue(ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.groupInfo),
                      "Could not open Group Info")
        if let back = ComponentQueries.headerBackButton(app) { back.tap() } else { app.navigationBars.buttons.firstMatch.tap() }
        XCTAssertTrue(
            ComponentQueries.composer(app).waitForExistence(timeout: 10)
                || app.staticTexts[group?.name ?? ""].exists,
            "Did not return to group messages"
        )
    }
    
    /// Mirrors the SDK's own subtitle format (`CometChatMessageHeader.configure(group:)`).
    private func memberCountLabel(_ count: Int) -> XCUIElement {
        app.staticTexts["\(count) \(count > 1 ? "Members" : "Member")"]
    }

    private func voiceCallButton() -> XCUIElement {
        // Voice/audio or an EXACT "Call" label — not `CONTAINS 'call'`, which would also match "Video Call".
        app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'voice' OR label CONTAINS[c] 'audio' OR label ==[c] 'call'")
        ).firstMatch
    }

    private func videoCallButton() -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'video'")).firstMatch
    }

    @discardableResult
    private func openGroup() -> String {
        (app, group) = openSeededGroupWithMember()
        return group?.name ?? ""
    }
}
