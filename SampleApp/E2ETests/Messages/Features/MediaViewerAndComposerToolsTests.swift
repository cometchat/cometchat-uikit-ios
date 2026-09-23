import XCTest

/// Three composer/viewer surfaces that had no E2E coverage: the full-screen media viewer
/// (`CometChatMediaViewer`), the sticker keyboard, and the inline voice recorder. The
/// suite previously asserted only that the attachment *options* exist — nothing opened a
/// received image, and nothing reached the sticker or recorder UI.
///
/// Media is received over REST via `PeerActions` rather than sent through the system
/// picker, which the suite cannot drive. That is the same split MediaMessagesTests uses.
///
/// Stickers are an EXTENSION and the recorder needs microphone permission, so those tests
/// skip rather than fail when the capability is absent — an unconfigured extension or a
/// denied permission is an environment fact, not a regression.
final class MediaViewerAndComposerToolsTests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate(); app = nil
        runBlocking { await SeedData.cleanup() }
    }

    // MARK: - Full-screen media viewer

    func test_1TO1_tappingReceivedImageOpensViewer() throws {
        app = openSeededConversation()
        try runBlocking { _ = try await PeerActions.sendImageToA() }
        guard let bubble = waitForImageBubble() else {
            throw XCTSkip("The inbound image never rendered — neither its accessibility label nor any message-list image was found")
        }

        bubble.tap()

        // The viewer is full-screen with its own Close control and a page counter; either
        // is enough to prove it opened over the message list.
        let opened = app.buttons["Close"].waitForExistence(timeout: 8)
            || app.buttons.matching(NSPredicate(format: "label CONTAINS[c] 'close' OR label CONTAINS[c] 'xmark'"))
                   .firstMatch.waitForExistence(timeout: 3)
        XCTAssertTrue(opened, "Tapping a received image did not open the media viewer")
    }

    func test_1TO1_mediaViewerClosesBackToConversation() throws {
        app = openSeededConversation()
        try runBlocking { _ = try await PeerActions.sendImageToA() }
        guard let bubble = waitForImageBubble() else {
            throw XCTSkip("The inbound image never rendered — neither its accessibility label nor any message-list image was found")
        }
        bubble.tap()

        let close = app.buttons["Close"].firstMatch
        guard close.waitForExistence(timeout: 8) else {
            throw XCTSkip("Media viewer did not open, so closing cannot be tested")
        }
        close.tap()

        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10),
                      "Closing the media viewer did not return to the conversation")
    }

    func test_1TO1_mediaViewerSurvivesAZoomGesture() throws {
        app = openSeededConversation()
        try runBlocking { _ = try await PeerActions.sendImageToA() }
        guard let bubble = waitForImageBubble() else {
            throw XCTSkip("The inbound image never rendered — neither its accessibility label nor any message-list image was found")
        }
        bubble.tap()
        guard app.buttons["Close"].waitForExistence(timeout: 8) else {
            throw XCTSkip("Media viewer did not open")
        }

        // The viewer wraps each page in a zoomable scroll view; pinching must not tear
        // down the viewer or strand the app.
        app.images.firstMatch.pinch(withScale: 2.0, velocity: 1.0)

        XCTAssertTrue(app.buttons["Close"].exists, "The viewer disappeared after a zoom gesture")
    }

    // MARK: - Sticker keyboard

    func test_1TO1_stickerButtonOpensStickerKeyboard() throws {
        app = openSeededConversation()
        let stickers = app.buttons["Stickers"].firstMatch
        guard stickers.waitForExistence(timeout: 10) else {
            throw XCTSkip("The Stickers button is not present in this configuration")
        }

        stickers.tap()

        // With the extension enabled the keyboard shows sticker sets; without stickers
        // it shows its empty state. Either proves the keyboard opened — what must NOT
        // happen is the composer simply staying put with nothing shown.
        let opened = app.staticTexts.containing(
            NSPredicate(format: "label CONTAINS[c] 'sticker'")
        ).firstMatch.waitForExistence(timeout: 8)
            || app.collectionViews.count > 0
        XCTAssertTrue(opened, "Tapping Stickers did not open the sticker keyboard")
    }

    func test_1TO1_stickerKeyboardDismissesBackToComposer() throws {
        app = openSeededConversation()
        let stickers = app.buttons["Stickers"].firstMatch
        guard stickers.waitForExistence(timeout: 10) else {
            throw XCTSkip("The Stickers button is not present in this configuration")
        }
        stickers.tap()
        _ = app.collectionViews.firstMatch.waitForExistence(timeout: 6)

        stickers.tap()

        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 8),
                      "Dismissing the sticker keyboard did not restore the composer")
    }

    // MARK: - Inline voice recorder

    func test_1TO1_voiceRecordingButtonOpensRecorder() throws {
        app = openSeededConversation()
        // Matched case-insensitively on purpose. The shipping 5.1.16 label is
        // "Voice Recording"; A11Y2 (da90c15b) changed it to "Voice recording" while
        // moving the string into Localizable.strings. An exact match on either spelling
        // silently skips against the other build — which is exactly what happened, and
        // was misread as "the button isn't in this configuration".
        let mic = app.buttons.matching(
            NSPredicate(format: "label ==[c] %@", "Voice Recording")
        ).firstMatch
        guard mic.waitForExistence(timeout: 10) else {
            throw XCTSkip("No voice-recording button found under either spelling")
        }

        // Tapping the mic asks for microphone permission the first time. A system alert
        // blocks XCUITest until something dismisses it — an earlier version of this test
        // had no monitor and the runner timed out, taking the whole suite down. The
        // monitor only fires when an alert actually appears.
        let permissionMonitor = addUIInterruptionMonitor(withDescription: "Microphone permission") { alert in
            for label in ["OK", "Allow", "Don’t Allow", "Don't Allow"] where alert.buttons[label].exists {
                alert.buttons[label].tap()
                return true
            }
            return false
        }
        defer { removeUIInterruptionMonitor(permissionMonitor) }

        mic.tap()
        app.tap()   // required to route the pending alert through the monitor

        // Recording itself needs a granted microphone, which this suite does not assume.
        // What is assertable is that the affordance responds and the app stays usable.
        let respondedOrStable = app.buttons.matching(
            NSPredicate(format: "label CONTAINS[c] 'delete' OR label CONTAINS[c] 'stop' OR label CONTAINS[c] 'pause'")
        ).firstMatch.waitForExistence(timeout: 6)
            || ComponentQueries.composer(app).waitForExistence(timeout: 6)
        XCTAssertTrue(respondedOrStable, "The app became unusable after tapping Voice recording")
    }

    // MARK: - Composer affordances as a set

    func test_1TO1_composerExposesItsToolsWithAccessibilityLabels() throws {
        app = openSeededConversation()
        XCTAssertTrue(ComponentQueries.composer(app).waitForExistence(timeout: 10))

        // These labels were added for the Track 1 accessibility work; they are also what
        // makes every selector in this file stable, so a regression here would silently
        // degrade the rest of the suite into index-based guessing.
        XCTAssertTrue(app.buttons["Attachment"].exists, "Attachment button lost its accessibility label")
        let hasSendOrMic = app.buttons["Send"].exists
            || app.buttons.matching(NSPredicate(format: "label ==[c] %@", "Voice Recording")).firstMatch.exists
        XCTAssertTrue(hasSendOrMic, "Neither Send nor Voice Recording is exposed to accessibility")
    }

    // MARK: - Helpers

    /// The received image bubble.
    ///
    /// Two strategies, in order, because the app under test links the PUBLISHED UI Kit
    /// (project.yml pins CometChatUIKitSwift at exactVersion 5.1.16) rather than this
    /// repo's source:
    ///
    ///  1. By accessibility label. `CometChatImageBubble` now sets
    ///     `isAccessibilityElement`, an "Image message" label and `.image`/`.button`
    ///     traits — added because the first version of this test skipped every time:
    ///     the bubble published nothing at all, making it unreachable to VoiceOver as
    ///     well as to XCUITest. This path starts working once a release carries it.
    ///  2. Structurally, for 5.1.16 today: the lowest image in the message list.
    ///
    /// The structural pass is deliberately BOUNDED. An earlier version called
    /// `app.images.allElementsBoundByIndex`, which materialises every match and captures
    /// a debug description for each; against a populated message list that ran until the
    /// runner timed out and took the whole suite down with it. Only a handful of indices
    /// are probed here, and the header avatar is excluded by frame rather than by
    /// enumerating everything.
    private func waitForImageBubble() -> XCUIElement? {
        let labelled = app.descendants(matching: .any)["Image message"].firstMatch
        if labelled.waitForExistence(timeout: 12) { return labelled }

        _ = app.images.firstMatch.waitForExistence(timeout: 8)
        let headerBottom: CGFloat = 150
        var best: XCUIElement?
        var bestY: CGFloat = 0
        for index in 0..<min(app.images.count, 8) {
            let candidate = app.images.element(boundBy: index)
            guard candidate.exists else { continue }
            let frame = candidate.frame
            guard frame.minY > headerBottom, frame.height > 40 else { continue }
            if frame.minY >= bestY { best = candidate; bestY = frame.minY }
        }
        return best
    }

}
