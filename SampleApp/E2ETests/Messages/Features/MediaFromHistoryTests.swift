import XCTest

/// Media bubbles asserted on what actually renders.
///
/// Two deliberate differences from the existing media tests:
/// 1. Media is seeded BEFORE the conversation is opened, so these render from the history fetch
///    and do not depend on inbound real-time delivery (see KIT-GAPS.md #3).
/// 2. They assert the bubble itself. The existing `receiveImage`/`receiveVideo` tests fall back to
///    "…OR the composer still exists", which passes even when no media arrives at all.
/// Sheet sources: catalog CometChatMediaMessages rows; sample-app sheet file rows.
///
/// The image/video cases are parked: the media bubble itself is not in the accessibility tree —
/// the only `Image` elements on the screen are the header avatar and the scroll-to-bottom
/// chevron — so there is nothing for XCUI to assert on. File messages render their filename as
/// text, which is why those two cases work and are kept. See KIT-GAPS.md #4.
final class MediaFromHistoryTests: XCTestCase {

    private var app: XCUIApplication!
    private var group: SeedData.TestGroup?

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        runBlocking { [group] in await SeedData.deleteTestGroup(group) }
        group = nil
        runBlocking { await SeedData.cleanup() }
    }

    /// Media rendered inside the message list, excluding the header avatar (top of screen) and
    /// anything drawn at/below the composer.
    private func mediaInMessageList() -> [XCUIElement] {
        let composerTop = ComponentQueries.composer(app).frame.minY
        return app.images.allElementsBoundByIndex.filter {
            $0.exists && $0.frame.minY > 160
                && (composerTop <= 0 || $0.frame.maxY < composerTop)
                && $0.frame.width > 40 && $0.frame.height > 40
        }
    }

    private func waitForMediaBubble(timeout: TimeInterval = 25) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if !mediaInMessageList().isEmpty { return true }
            _ = app.images.firstMatch.waitForExistence(timeout: 0.5)
        }
        return !mediaInMessageList().isEmpty
    }

    // MARK: - Cases

    /// A file message renders its filename, so this one is exactly assertable.
    func test_1TO1_seededFileRendersWithItsName() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        try runBlocking { _ = try await PeerActions.sendFileToA() }
        app = openSeededConversation()
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: "test_document", timeout: 25),
                      "File bubble did not render the file name")
    }

    /// An image message renders an image bubble in the message list — not merely "a stable screen".
    func test_1TO1_seededImageRendersBubble() throws {
        throw XCTSkip("Media bubble is not exposed to accessibility — see KIT-GAPS.md #4")
        try runBlocking { try await SeedData.createTestConversation() }
        try runBlocking { _ = try await PeerActions.sendImageToA() }
        app = openSeededConversation()
        XCTAssertTrue(waitForMediaBubble(), "No image bubble rendered in the message list")
    }

    /// A video message renders a bubble (thumbnail / play affordance) in the message list.
    func test_1TO1_seededVideoRendersBubble() throws {
        throw XCTSkip("Media bubble is not exposed to accessibility — see KIT-GAPS.md #4")
        try runBlocking { try await SeedData.createTestConversation() }
        try runBlocking { _ = try await PeerActions.sendVideoToA() }
        app = openSeededConversation()
        XCTAssertTrue(waitForMediaBubble(), "No video bubble rendered in the message list")
    }

    /// The same contract inside a group conversation.
    func test_GROUP_seededFileRendersWithItsName() throws {
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = created
        try runBlocking { _ = try await PeerActions.sendFileToA(receiver: created.guid, receiverType: "group") }
        app = openSeededGroup(created)
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: "test_document", timeout: 25),
                      "File bubble did not render in the group")
    }
}
