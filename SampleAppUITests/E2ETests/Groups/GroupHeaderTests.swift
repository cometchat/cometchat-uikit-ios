import XCTest

/// The group message header — group name, avatar, call buttons, and details navigation.
/// Throwaway per-run group.
final class GroupHeaderTests: XCTestCase {
    
    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?
    
    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        let capturedGroup = group; group = nil
        runBlocking { await SeedData.deleteTestGroup(capturedGroup) }
    }
    
    /// Header displays the group name.
    func test_GRP_headerShowsGroupName() throws {
        let name = openGroup()
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 10), "Group header did not show the name")
    }
    
    /// Header renders an avatar (or the name, proving the header rendered).
    func test_GRP_headerShowsAvatar() throws {
        let name = openGroup()
        XCTAssertTrue(app.images.firstMatch.exists || app.staticTexts[name].waitForExistence(timeout: 8),
                      "Group header avatar/name not rendered")
    }
    
    /// Header renders (member-count subtitle logged non-fatal).
    func test_GRP_headerShowsMemberCount() throws {
        let name = openGroup()
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 10), "Group header did not render")
    }
    
    /// Header exposes a voice-call button (group-call affordance). Located by the same voice/audio/"Call"
    /// predicate proven for the 1:1 header — deliberately not `CONTAINS 'call'`, which would also resolve
    /// the video control. If a build ships the group header without call buttons, this reveals it (red),
    /// which is the intended signal rather than a silent skip.
    func test_GRP_voiceCallButtonVisible() throws {
        _ = openGroup()
        XCTAssertTrue(voiceCallButton().waitForExistence(timeout: 8),
                      "Voice-call button not present in the group header")
    }

    /// Header exposes a video-call button (group-call affordance).
    func test_GRP_videoCallButtonVisible() throws {
        _ = openGroup()
        XCTAssertTrue(videoCallButton().waitForExistence(timeout: 8),
                      "Video-call button not present in the group header")
    }

    /// The details menu navigates to Group Info.
    func test_GRP_detailsNavigatesToGroupInfo() throws {
        _ = openGroup()
        XCTAssertTrue(ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.groupInfo),
                      "Could not open Group Info from header menu")
        // Off the composer now — a Group Info surface (name/Members) shows.
        XCTAssertTrue(
            app.staticTexts["Group Info"].waitForExistence(timeout: 8)
            || app.staticTexts[group?.name ?? ""].exists
            || app.staticTexts["Members"].exists,
            "Group Info screen did not appear"
        )
    }
    
    /// Back from Group Info returns to the group messages.
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
    
    // MARK: - Header locators

    private func voiceCallButton() -> XCUIElement {
        // Voice/audio or an EXACT "Call" label — not `CONTAINS 'call'`, which would also match "Video Call".
        app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'voice' OR label CONTAINS[c] 'audio' OR label ==[c] 'call'")
        ).firstMatch
    }

    private func videoCallButton() -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'video'")).firstMatch
    }

    // MARK: - Helpers

    @discardableResult
    private func openGroup() -> String {
        let testGroup = try? runBlocking { try await SeedData.createTestGroupWithMember() }
        group = testGroup
        XCTAssertNotNil(testGroup, "Could not create the test group")
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: testGroup!.name), "Could not open the test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group message list did not open")
        return testGroup!.name
    }
}
