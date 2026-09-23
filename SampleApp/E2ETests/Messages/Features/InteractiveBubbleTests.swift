import XCTest

/// Interactive-message bubbles (category `interactive`).
///
/// FORM is intentionally retired: `CometChatFormBubble` was removed as dead API
/// (ENG-38811, commit dc4e69bf5). A form message must therefore render the
/// "not supported" placeholder — that is the CORRECT behaviour, and the test below locks it in
/// so a future change cannot silently resurrect a half-working form bubble.
///
/// SCHEDULER is different: `CometChatSchedulerBubble` is still in the Kit and carries its own
/// component and snapshot tests, so a scheduler message is expected to render properly.
///
/// Both types are seeded over REST before the conversation is opened, so these render from the
/// history fetch and do not depend on real-time delivery (KIT-GAPS.md #3).
///
/// NOT covered: poll / sticker / whiteboard / document bubbles — gated on
/// `CometChat.isExtensionEnabled`, and the dev app has no extensions enabled (they cannot be
/// enabled through the app REST API; dashboard only).
final class InteractiveBubbleTests: XCTestCase {

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

    private static let unsupportedPlaceholder = "This message type is not supported"

    // MARK: - Form: retired by design

    /// A received form message renders the unsupported placeholder, and specifically does NOT
    /// render form chrome. `CometChatFormBubble` is gone; this is the intended outcome.
    func test_1TO1_formMessageRendersUnsupportedPlaceholder() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        let stamp = UUID().uuidString.prefix(6).lowercased()
        try runBlocking {
            _ = try await PeerActions.sendFormMessage(title: "E2E Form \(stamp)",
                                                      fieldLabel: "Your name",
                                                      buttonText: "Submit \(stamp)")
        }
        app = openSeededConversation()

        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: Self.unsupportedPlaceholder,
                                                              timeout: 25),
                      "A form message should render the unsupported placeholder")
        XCTAssertFalse(app.buttons["Submit \(stamp)"].exists,
                       "Form submit button rendered — the retired form bubble is back")
        XCTAssertFalse(ComponentQueries.waitForBubbleContaining(app, substring: "E2E Form \(stamp)",
                                                               timeout: 3),
                       "Form title rendered — the retired form bubble is back")
    }

    /// The same in a group: retired everywhere, not just in 1:1.
    func test_GROUP_formMessageRendersUnsupportedPlaceholder() throws {
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = created
        let stamp = UUID().uuidString.prefix(6).lowercased()
        try runBlocking {
            _ = try await PeerActions.sendFormMessage(title: "E2E GForm \(stamp)",
                                                      fieldLabel: "Team input",
                                                      buttonText: "Go \(stamp)",
                                                      receiver: created.guid,
                                                      receiverType: "group")
        }
        app = openSeededGroup(created)
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: Self.unsupportedPlaceholder,
                                                              timeout: 25),
                      "A form message in a group should render the unsupported placeholder")
    }

    // MARK: - Scheduler: still a live component

    /// A received scheduler message renders the scheduler bubble with its title.
    func test_1TO1_schedulerBubbleRendersTitle() throws {
        try runBlocking { try await SeedData.createTestConversation() }
        let stamp = UUID().uuidString.prefix(6).lowercased()
        let title = "E2E Meet \(stamp)"
        try runBlocking {
            _ = try await PeerActions.sendSchedulerMessage(title: title, buttonText: "Book \(stamp)")
        }
        app = openSeededConversation()
        XCTAssertTrue(ComponentQueries.waitForBubbleContaining(app, substring: title, timeout: 25),
                      "Scheduler bubble did not render its title")
    }
}
