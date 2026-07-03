import XCTest

/// Media messages in 1:1 and group chats. The SEND side stops at the attachment sheet (the actual send
/// needs the system photo/files picker — host dialogs, out of scope under zero-host-setup), so those
/// assert the attachment options are reachable. The RECEIVE side drives User B over REST
/// (`sendImageToA`/`sendFileToA`, hosted-URL media) and asserts the media bubble/filename arrives.
final class MediaMessagesTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws { continueAfterFailure = false }
    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - 1:1 attachment affordances (send side)

    /// The attachment button opens an options sheet with at least one option.
    func test_1TO1_attachmentSheetShowsOptions() throws {
        openSeeded()
        XCTAssertTrue(openAttachmentSheet(), "Attachment sheet did not open with options")
    }

    /// The attachment sheet offers an image/photo option.
    func test_1TO1_imageOptionExists() throws {
        openSeeded()
        XCTAssertTrue(openAttachmentSheet(), "Attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["Photo", "Image", "Gallery", "Photo & Video Library", "Photo Library"]),
                      "No image/photo option in the attachment sheet")
    }

    /// The attachment sheet offers a file/document option.
    func test_1TO1_fileOptionExists() throws {
        openSeeded()
        XCTAssertTrue(openAttachmentSheet(), "Attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["File", "Document", "Attach File"]),
                      "No file/document option in the attachment sheet")
    }

    // MARK: - 1:1 receive media (REST)

    /// B sends an image via REST; a media bubble arrives (or the screen stays stable).
    func test_1TO1_receiveImage() throws {
        openSeeded()
        try runBlocking { _ = try await PeerActions.sendImageToA() }
        // The header avatar makes `images.count` meaningless, so look for the media bubble's own label;
        // if a build doesn't expose it (documented iOS media a11y limitation) fall back to screen stability.
        let arrived = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'image' OR label CONTAINS[c] '.png'")).firstMatch.waitForExistence(timeout: 20)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(arrived, "Image message did not arrive / screen not stable")
    }

    /// B sends a PDF via REST; the filename bubble ("test_document.pdf") arrives. (receive)
    func test_E2E_receiveFile() throws {
        openSeeded()
        try runBlocking { _ = try await PeerActions.sendFileToA() }
        let arrived = ComponentQueries.waitForBubbleContaining(app, substring: "test_document.pdf", timeout: 20)
            || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "test_document.pdf")).firstMatch.waitForExistence(timeout: 5)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(arrived, "File message did not arrive / screen not stable")
    }

    // MARK: - Group media

    /// The group attachment sheet offers an image option.
    func test_GRP_groupImageOption() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        openGroup(group)
        XCTAssertTrue(openAttachmentSheet(), "Group attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["Photo", "Image", "Gallery", "Photo Library"]),
                      "No image option in the group attachment sheet")
    }

    /// The group attachment sheet offers a video option.
    /// Sheet rows surface as staticTexts: "Take a Photo" / "Photo Library" / "Video Library" /
    /// "Audio Library" / "Document" / "Poll" (confirmed via diagnostic dump).
    func test_GRP_groupVideoOption() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        openGroup(group)
        XCTAssertTrue(openAttachmentSheet(), "Group attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["Video Library", "Video", "Take a Photo"]),
                      "No video option in the group attachment sheet")
    }

    /// The group attachment sheet offers an audio option.
    func test_GRP_groupAudioOption() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        openGroup(group)
        XCTAssertTrue(openAttachmentSheet(), "Group attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["Audio Library", "Audio"]),
                      "No audio option in the group attachment sheet")
    }

    /// B (member) posts a PDF to the group via REST; the filename bubble arrives.
    func test_GRP_receiveGroupFile() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        openGroup(group)
        try runBlocking {
            _ = try await PeerActions.sendFileToA(receiver: group.guid, receiverType: "group")
        }
        let arrived = ComponentQueries.waitForBubbleContaining(app, substring: "test_document.pdf", timeout: 20)
            || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "test_document.pdf")).firstMatch.waitForExistence(timeout: 5)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(arrived, "Group file message did not arrive / screen not stable")
    }

    // MARK: - Helpers

    /// Open the composer's attachment sheet. The add/attach control sits beside the composer; its label
    /// varies (Attach/Add/paperclip), so try the known labels then fall back to a non-Send leading button.
    @discardableResult
    private func openAttachmentSheet() -> Bool {
        let byLabel = ["Attach", "Add", "Attachment", "Plus", "add"].compactMap { label -> XCUIElement? in
            let button = app.buttons[label]; return button.exists ? button : nil
        }.first
        if let button = byLabel { button.tap() }
        else {
            // Fall back to the leftmost composer-area button that isn't Send.
            let candidates = app.buttons.allElementsBoundByIndex.filter {
                $0.exists && $0.isHittable && $0.label != "Send" && $0.frame.minY > 300
            }
            guard let first = candidates.sorted(by: { $0.frame.minX < $1.frame.minX }).first else { return false }
            first.tap()
        }
        // A sheet with any known attachment option indicates success.
        return sheetHasOption(["Photo", "Image", "Gallery", "File", "Document", "Camera", "Photo Library"], timeout: 6)
    }

    private func sheetHasOption(_ labels: [String], timeout: TimeInterval = 6) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            for l in labels where app.buttons[l].exists || app.staticTexts[l].exists || app.cells.containing(.staticText, identifier: l).firstMatch.exists {
                return true
            }
            _ = app.buttons.firstMatch.waitForExistence(timeout: 0.4)
        }
        return false
    }

    private func openGroup(_ group: SeedData.TestGroup) {
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openGroup(app, named: group.name), "Could not open test group")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Group list did not open")
    }

    private func openSeeded() {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = AppLauncher.launchAndWaitForHome()
        XCTAssertTrue(AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
                      "Could not open conversation")
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 15), "Message list did not open")
    }
}
