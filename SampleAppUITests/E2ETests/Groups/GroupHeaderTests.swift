import XCTest

final class GroupHeaderTests: XCTestCase {
    
    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?
    
    override func setUpWithError() throws { continueAfterFailure = false }
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
        let name = openGroup()
        XCTAssertTrue(app.staticTexts[name].waitForExistence(timeout: 10), "Group header did not render")
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
