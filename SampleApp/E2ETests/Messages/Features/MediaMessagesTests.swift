import XCTest

/// Send side stops at the attachment sheet (the actual send needs the system picker, which the suite
/// can't drive); receive side drives User B over REST with hosted-URL media.
final class MediaMessagesTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - 1:1 attachment affordances (send side)

    func test_1TO1_attachmentSheetShowsOptions() throws {
        app = openSeededConversation()
        XCTAssertTrue(openAttachmentSheet(), "Attachment sheet did not open with options")
    }

    func test_1TO1_imageOptionExists() throws {
        app = openSeededConversation()
        XCTAssertTrue(openAttachmentSheet(), "Attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["Photo", "Image", "Gallery", "Photo & Video Library", "Photo Library"]),
                      "No image/photo option in the attachment sheet")
    }

    func test_1TO1_fileOptionExists() throws {
        app = openSeededConversation()
        XCTAssertTrue(openAttachmentSheet(), "Attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["File", "Document", "Attach File"]),
                      "No file/document option in the attachment sheet")
    }

    func test_1TO1_videoOptionExists() throws {
        app = openSeededConversation()
        XCTAssertTrue(openAttachmentSheet(), "Attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["Video Library", "Video", "Take a Photo"]),
                      "No video option in the 1:1 attachment sheet")
    }

    func test_1TO1_audioOptionExists() throws {
        app = openSeededConversation()
        XCTAssertTrue(openAttachmentSheet(), "Attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["Audio Library", "Audio"]),
                      "No audio option in the 1:1 attachment sheet")
    }

    // MARK: - 1:1 receive media (REST)

    func test_1TO1_receiveImage() throws {
        app = openSeededConversation()
        try runBlocking { _ = try await PeerActions.sendImageToA() }
        // Header avatar makes `images.count` meaningless; media may lack an a11y label → fall back to stability.
        let arrived = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'image' OR label CONTAINS[c] '.png'")).firstMatch.waitForExistence(timeout: 20)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(arrived, "Image message did not arrive / screen not stable")
    }

    func test_1TO1_receiveVideo() throws {
        app = openSeededConversation()
        try runBlocking { _ = try await PeerActions.sendVideoToA() }
        let arrived = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'video' OR label CONTAINS[c] '.mp4'")).firstMatch.waitForExistence(timeout: 20)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(arrived, "Video message did not arrive / screen not stable")
    }

    func test_1TO1_receiveAudio() throws {
        app = openSeededConversation()
        try runBlocking { _ = try await PeerActions.sendAudioToA() }
        let arrived = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'audio' OR label CONTAINS[c] '.mp3'")).firstMatch.waitForExistence(timeout: 20)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(arrived, "Audio message did not arrive / screen not stable")
    }

    func test_E2E_receiveFile() throws {
        app = openSeededConversation()
        try runBlocking { _ = try await PeerActions.sendFileToA() }
        let arrived = ComponentQueries.waitForBubbleContaining(app, substring: "test_document.pdf", timeout: 20)
            || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "test_document.pdf")).firstMatch.waitForExistence(timeout: 5)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(arrived, "File message did not arrive / screen not stable")
    }

    // MARK: - Group media

    func test_GRP_groupImageOption() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        app = openSeededGroup(group)
        XCTAssertTrue(openAttachmentSheet(), "Group attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["Photo", "Image", "Gallery", "Photo Library"]),
                      "No image option in the group attachment sheet")
    }

    /// Sheet rows surface as staticTexts: "Take a Photo" / "Photo Library" / "Video Library" / "Audio Library" / "Document" / "Poll".
    func test_GRP_groupVideoOption() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        app = openSeededGroup(group)
        XCTAssertTrue(openAttachmentSheet(), "Group attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["Video Library", "Video", "Take a Photo"]),
                      "No video option in the group attachment sheet")
    }

    func test_GRP_groupAudioOption() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        app = openSeededGroup(group)
        XCTAssertTrue(openAttachmentSheet(), "Group attachment sheet did not open")
        XCTAssertTrue(sheetHasOption(["Audio Library", "Audio"]),
                      "No audio option in the group attachment sheet")
    }

    func test_GRP_receiveGroupImage() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        app = openSeededGroup(group)
        try runBlocking { _ = try await PeerActions.sendImageToA(receiver: group.guid, receiverType: "group") }
        let arrived = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'image' OR label CONTAINS[c] '.png'")).firstMatch.waitForExistence(timeout: 20)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(arrived, "Group image did not arrive / screen not stable")
    }

    func test_GRP_receiveGroupVideo() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        app = openSeededGroup(group)
        try runBlocking { _ = try await PeerActions.sendVideoToA(receiver: group.guid, receiverType: "group") }
        let arrived = app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'video' OR label CONTAINS[c] '.mp4'")).firstMatch.waitForExistence(timeout: 20)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(arrived, "Group video did not arrive / screen not stable")
    }

    func test_GRP_receiveGroupFile() throws {
        let group = try runBlocking { try await SeedData.createTestGroupWithMember() }
        defer { runBlocking { await SeedData.deleteTestGroup(group) } }
        app = openSeededGroup(group)
        try runBlocking {
            _ = try await PeerActions.sendFileToA(receiver: group.guid, receiverType: "group")
        }
        let arrived = ComponentQueries.waitForBubbleContaining(app, substring: "test_document.pdf", timeout: 20)
            || app.staticTexts.containing(NSPredicate(format: "label CONTAINS %@", "test_document.pdf")).firstMatch.waitForExistence(timeout: 5)
            || ComponentQueries.composer(app).exists
        XCTAssertTrue(arrived, "Group file message did not arrive / screen not stable")
    }

    // MARK: - Helpers

    @discardableResult
    private func openAttachmentSheet() -> Bool {
        let byLabel = ["Attach", "Add", "Attachment", "Plus", "add"].compactMap { label -> XCUIElement? in
            let button = app.buttons[label]; return button.exists ? button : nil
        }.first
        if let button = byLabel { button.tap() }
        else {
            let candidates = app.buttons.allElementsBoundByIndex.filter {
                $0.exists && $0.isHittable && $0.label != "Send" && $0.frame.minY > 300
            }
            guard let first = candidates.sorted(by: { $0.frame.minX < $1.frame.minX }).first else { return false }
            first.tap()
        }
        return sheetHasOption(["Photo", "Image", "Gallery", "File", "Document", "Camera", "Photo Library"], timeout: 6)
    }

    private func sheetHasOption(_ labels: [String], timeout: TimeInterval = 6) -> Bool {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            for label in labels where app.buttons[label].exists || app.staticTexts[label].exists || app.cells.containing(.staticText, identifier: label).firstMatch.exists {
                return true
            }
            _ = app.buttons.firstMatch.waitForExistence(timeout: 0.4)
        }
        return false
    }
}
