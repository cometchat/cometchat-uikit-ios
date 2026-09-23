import XCTest

/// Accessibility audits across the Kit's main screens (Track 1 **A11Y4**).
///
/// `performAccessibilityAudit()` walks the live view hierarchy and reports problems iOS can
/// detect on its own: elements with no label, contrast below threshold, tap targets under
/// 44×44pt, elements that look interactive but aren't exposed as such, and — the one this
/// suite exists for — **text that clips when the reader enlarges it**.
///
/// ## Why there are two passes
///
/// An audit at the default text size mostly re-checks A11Y1's labelling work. The valuable
/// pass is the second one: the app is relaunched with
/// `-UIPreferredContentSizeCategoryName UICTContentSizeCategoryAccessibilityXXXL`, so every
/// screen renders at the largest accessibility size. That is what turns
/// "286 fixed-height constraints, unknown risk" into a named list of the ones that actually
/// break — the input the remainder of A11Y3 needs before anyone starts moving constraints.
///
/// ## Why these do not fail the build yet
///
/// `failOnFindings` is `false`. This suite's first job is to *establish* a baseline, and a
/// gate that goes red on its first run tells you nothing you can act on — it just gets
/// disabled. Each test prints a per-screen, per-category report and passes.
///
/// **Flip `failOnFindings` to `true` once the findings are triaged and fixed.** From then on
/// it is a real regression gate, and that is the point of writing it this way round.
///
/// ## Scope note
///
/// These audit the *sample app*, which is the only place the Kit's components are assembled
/// into real screens. Findings are therefore attributable to the Kit unless the sample app
/// obviously caused them — worth remembering when triaging.
@available(iOS 17.0, *)
final class E2EAccessibilityAuditTests: XCTestCase {

    /// Turn on once the baseline is triaged. See the type documentation.
    private static let failOnFindings = false

    /// The largest accessibility text size iOS offers. Anything that survives this survives
    /// everything.
    private static let hugeTextArgs = [
        "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"
    ]

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = true   // one screen's findings must not hide the next screen's
    }

    private var group: SeedData.TestGroup?

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
        let captured = group; group = nil
        runBlocking {
            await SeedData.deleteTestGroup(captured)
            await SeedData.cleanup()
        }
    }

    // MARK: - Running an audit

    /// Audits whatever is currently on screen and records what it finds.
    ///
    /// The handler returns `false` for every issue, which tells XCTest "do not raise this as a
    /// test failure" — we collect them ourselves instead. That is what makes the reporting
    /// mode possible without `XCTExpectFailure` gymnastics.
    @discardableResult
    private func audit(_ screen: String, textSize: String) -> [String] {
        // Let the screen settle first. The audit resolves each element it reports on, and
        // an element that vanishes mid-walk — a shimmer placeholder being replaced by real
        // data, a push animation still running — makes XCTest raise
        // "Failed to get matching snapshot" and abandon the rest of the walk. Waiting for
        // the hierarchy to stop moving is what makes the findings reproducible.
        _ = app.wait(for: .runningForeground, timeout: 5)
        Thread.sleep(forTimeInterval: 1.5)

        var found: [String] = []

        // In baseline mode nothing in here should redden the run — the report IS the output.
        //
        // The do/catch below is not sufficient on its own. XCTest records some audit problems
        // through its issue-reporting mechanism rather than by throwing, so they never reach a
        // Swift catch. "Failed to get matching snapshot" is the one that bites: it fires when
        // the audit tries to resolve an element that moved or was replaced mid-walk, and it is
        // environmental rather than a fact about the UI.
        //
        // `.nonStrict()` means "it is also fine if nothing fails", so this does not itself
        // become a source of failures on the screens that audit cleanly.
        let runAudit = {
            do {
                try self.app.performAccessibilityAudit { issue in
                    let element = issue.element?.label ?? issue.element?.identifier ?? "<unnamed>"
                    found.append("[\(Self.name(for: issue.auditType))] \(element) — \(issue.compactDescription)")
                    return !Self.failOnFindings   // true = handled/ignored
                }
            } catch {
                found.append("[audit-error] \(error.localizedDescription)")
            }
        }

        if Self.failOnFindings {
            runAudit()
        } else {
            XCTExpectFailure("A11Y4 baseline mode: findings are reported, not enforced",
                             options: .nonStrict(),
                             failingBlock: runAudit)
        }

        report(screen: screen, textSize: textSize, findings: found)
        return found
    }

    private func report(screen: String, textSize: String, findings: [String]) {
        guard !findings.isEmpty else {
            print("A11Y4 ✓ \(screen) @ \(textSize): no issues")
            return
        }
        // Grouped by category so the output is triageable rather than a wall of lines.
        var byCategory: [String: Int] = [:]
        for f in findings {
            let cat = f.split(separator: "]").first.map { String($0.dropFirst()) } ?? "?"
            byCategory[cat, default: 0] += 1
        }
        let summary = byCategory.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: " ")
        print("A11Y4 ✗ \(screen) @ \(textSize): \(findings.count) issue(s) — \(summary)")
        for f in findings { print("    \(f)") }
    }

    private static func name(for type: XCUIAccessibilityAuditType) -> String {
        switch type {
        case .contrast:                 return "contrast"
        case .elementDetection:         return "element-detection"
        case .hitRegion:                return "hit-region"
        case .sufficientElementDescription: return "missing-label"
        case .textClipped:              return "TEXT-CLIPPED"
        case .dynamicType:              return "dynamic-type"
        case .trait:                    return "trait"
        default:                        return "other"
        }
    }

    // MARK: - Default text size
    //
    // Mostly verifies A11Y1's labelling against the real UI rather than against a grep.

    func test_A11Y_conversationsAtDefaultTextSize() throws {
        app = AppLauncher.launchAndWaitForHome()
        audit("Conversations", textSize: "default")
    }

    func test_A11Y_messageListAndComposerAtDefaultTextSize() throws {
        app = openSeededConversation()
        audit("MessageList + Composer", textSize: "default")
    }

    // One test per tab, not a loop. A single flaky audit used to abandon its test, and every
    // tab after it then reported "not present" — which reads like a finding and is not one.
    func test_A11Y_usersTabAtDefaultTextSize() throws {
        auditTab(AppLauncher.TabLabel.users, textSize: "default", args: [])
    }

    func test_A11Y_groupsTabAtDefaultTextSize() throws {
        auditTab(AppLauncher.TabLabel.groups, textSize: "default", args: [])
    }

    func test_A11Y_callsTabAtDefaultTextSize() throws {
        auditTab(AppLauncher.TabLabel.calls, textSize: "default", args: [])
    }

    // MARK: - Largest accessibility text size
    //
    // THE POINT OF THIS SUITE. `.textClipped` findings here name the fixed-height
    // constraints that break, which is what the rest of A11Y3 needs scoping from.

    func test_A11Y_conversationsAtLargestTextSize() throws {
        app = XCUIApplication()
        app.launchArguments += Self.hugeTextArgs
        AppLauncher.launchAndWaitForHome(app)
        audit("Conversations", textSize: "AX-XXXL")
    }

    func test_A11Y_messageListAndComposerAtLargestTextSize() throws {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = XCUIApplication()
        app.launchArguments += Self.hugeTextArgs
        AppLauncher.launchAndWaitForHome(app)

        guard AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName) else {
            XCTFail("Could not open the seeded conversation at the largest text size — which is " +
                    "itself a finding: the list cell may be unreachable when text is enlarged.")
            return
        }
        _ = ComponentQueries.composer(app).waitForExistence(timeout: 15)
        audit("MessageList + Composer", textSize: "AX-XXXL")
    }

    func test_A11Y_usersTabAtLargestTextSize() throws {
        auditTab(AppLauncher.TabLabel.users, textSize: "AX-XXXL", args: Self.hugeTextArgs)
    }

    func test_A11Y_groupsTabAtLargestTextSize() throws {
        auditTab(AppLauncher.TabLabel.groups, textSize: "AX-XXXL", args: Self.hugeTextArgs)
    }

    func test_A11Y_callsTabAtLargestTextSize() throws {
        auditTab(AppLauncher.TabLabel.calls, textSize: "AX-XXXL", args: Self.hugeTextArgs)
    }

    /// Launches fresh, opens one tab, audits it. Fresh launch per tab so no earlier screen's
    /// state — or an earlier audit's failure — can affect the result.
    private func auditTab(_ tab: String, textSize: String, args: [String]) {
        app = XCUIApplication()
        app.launchArguments += args
        AppLauncher.launchAndWaitForHome(app)
        guard AppLauncher.navigateToTab(app, title: tab) else {
            XCTFail("The \(tab) tab could not be reached — check AppLauncher.TabLabel against " +
                    "the sample app's tab titles before reading this as an accessibility finding.")
            return
        }
        audit("\(tab) tab", textSize: textSize)
    }

    // MARK: - Message options sheet
    //
    // Its own test because it is a presented sheet with dense rows — the surface most likely
    // to clip first, and the one carrying the labels L10N2 was leaking as raw keys.

    func test_A11Y_messageOptionsSheetAtLargestTextSize() throws {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = XCUIApplication()
        app.launchArguments += Self.hugeTextArgs
        AppLauncher.launchAndWaitForHome(app)

        guard AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName),
              ComponentQueries.composer(app).waitForExistence(timeout: 15) else {
            throw XCTSkip("Could not reach the message list at the largest text size")
        }

        let text = "A11Y audit \(Int(Date().timeIntervalSince1970))"
        ComponentQueries.typeAndSend(app, text: text)
        guard ComponentQueries.waitForBubble(app, text: text, timeout: 12),
              ComponentQueries.openMessageOptions(app, bubbleText: text) else {
            throw XCTSkip("Could not open the message options sheet")
        }
        audit("Message options sheet", textSize: "AX-XXXL")
    }

    // MARK: - Wave 6: the screens the Flutter kit's integration suite audits
    //
    // Same shape as the tab audits: each screen has one test per text size, a fresh launch,
    // and the screen is reached through the app's own navigation. `openScreen` throws
    // XCTSkip when the navigation cannot be completed — a screen that could not be reached
    // is not an accessibility finding.

    private static let defaultSize = (label: "default", args: [String]())
    private static let hugeSize = (label: "AX-XXXL", args: hugeTextArgs)

    /// Login screen — launched logged out; the UID entry is the first screen.
    private func openLoginScreen(args: [String]) throws {
        app = XCUIApplication()
        app.launchArguments += args
        AppLauncher.launchToLogin(app)
        guard app.buttons["Continue"].waitForExistence(timeout: 20) else {
            throw XCTSkip("Login screen did not appear")
        }
    }

    func test_A11Y_loginScreenAtDefaultTextSize() throws {
        try openLoginScreen(args: Self.defaultSize.args)
        audit("Login", textSize: Self.defaultSize.label)
    }

    func test_A11Y_loginScreenAtLargestTextSize() throws {
        try openLoginScreen(args: Self.hugeSize.args)
        audit("Login", textSize: Self.hugeSize.label)
    }

    /// Create group — the sheet the Groups tab's "+" presents.
    private func openCreateGroupScreen(args: [String]) throws {
        app = XCUIApplication()
        app.launchArguments += args
        AppLauncher.launchAndWaitForHome(app)
        guard AppLauncher.navigateToTab(app, title: AppLauncher.TabLabel.groups),
              app.cells.firstMatch.waitForExistence(timeout: 15),
              AppLauncher.tapCreateGroupButton(app),
              ComponentQueries.createGroupScreenVisible(app, timeout: 10) else {
            throw XCTSkip("Create-group screen could not be reached")
        }
    }

    func test_A11Y_createGroupAtDefaultTextSize() throws {
        try openCreateGroupScreen(args: Self.defaultSize.args)
        audit("Create group", textSize: Self.defaultSize.label)
    }

    func test_A11Y_createGroupAtLargestTextSize() throws {
        try openCreateGroupScreen(args: Self.hugeSize.args)
        audit("Create group", textSize: Self.hugeSize.label)
    }

    /// Group messages — a throwaway group with User B as a member, opened to its composer.
    private func openGroupMessages(args: [String]) throws {
        let created = try runBlocking { try await SeedData.createTestGroupWithMember() }
        group = created
        app = XCUIApplication()
        app.launchArguments += args
        AppLauncher.launchAndWaitForHome(app)
        guard openGroupUntilComposerShows(app, named: created.name) else {
            throw XCTSkip("Group message list could not be reached")
        }
    }

    func test_A11Y_groupMessagesAtDefaultTextSize() throws {
        try openGroupMessages(args: Self.defaultSize.args)
        audit("Group messages", textSize: Self.defaultSize.label)
    }

    func test_A11Y_groupMessagesAtLargestTextSize() throws {
        try openGroupMessages(args: Self.hugeSize.args)
        audit("Group messages", textSize: Self.hugeSize.label)
    }

    /// Group info — More → Group Info from inside the group.
    private func openGroupInfo(args: [String]) throws {
        try openGroupMessages(args: args)
        guard ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.groupInfo),
              app.staticTexts["Group Info"].waitForExistence(timeout: 8)
                || app.staticTexts[group?.name ?? ""].waitForExistence(timeout: 4) else {
            throw XCTSkip("Group Info could not be reached")
        }
    }

    func test_A11Y_groupInfoAtDefaultTextSize() throws {
        try openGroupInfo(args: Self.defaultSize.args)
        audit("Group info", textSize: Self.defaultSize.label)
    }

    func test_A11Y_groupInfoAtLargestTextSize() throws {
        try openGroupInfo(args: Self.hugeSize.args)
        audit("Group info", textSize: Self.hugeSize.label)
    }

    /// The seeded 1:1 with User B, opened to its composer.
    private func openOneToOne(args: [String]) throws {
        try? runBlocking { try await SeedData.createTestConversation() }
        app = XCUIApplication()
        app.launchArguments += args
        AppLauncher.launchAndWaitForHome(app)
        // One retry: on the busy backend the Users row occasionally does not push the list.
        var opened = false
        for attempt in 0..<2 where !opened {
            guard AppLauncher.openConversationFromChats(app, displayName: TestConfig.userBDisplayName) else { break }
            opened = ComponentQueries.composer(app).waitForExistence(timeout: 15)
            if !opened, attempt == 0, !app.tabBars.firstMatch.exists { break }
        }
        guard opened else { throw XCTSkip("The seeded 1:1 could not be reached") }
    }

    /// Search — More → Search from inside the 1:1 (CometChatSearch scoped to messages).
    private func openSearchScreen(args: [String]) throws {
        try openOneToOne(args: args)
        let more = app.buttons["More"]
        guard more.waitForExistence(timeout: 10) else { throw XCTSkip("Header More menu not found") }
        more.tap()
        let item = app.buttons["Search"]
        guard item.waitForExistence(timeout: 8) else { throw XCTSkip("Search menu item not found") }
        item.tap()
        guard app.textFields.firstMatch.waitForExistence(timeout: 10)
                || app.searchFields.firstMatch.waitForExistence(timeout: 2) else {
            throw XCTSkip("Search screen did not present its field")
        }
    }

    func test_A11Y_searchScreenAtDefaultTextSize() throws {
        try openSearchScreen(args: Self.defaultSize.args)
        audit("Search", textSize: Self.defaultSize.label)
    }

    func test_A11Y_searchScreenAtLargestTextSize() throws {
        try openSearchScreen(args: Self.hugeSize.args)
        audit("Search", textSize: Self.hugeSize.label)
    }

    /// User info — More → User Info from inside the 1:1.
    private func openUserInfo(args: [String]) throws {
        try openOneToOne(args: args)
        guard ComponentQueries.openHeaderDetails(app, infoLabel: ComponentQueries.HeaderMenu.userInfo),
              app.staticTexts[TestConfig.userBDisplayName].waitForExistence(timeout: 8) else {
            throw XCTSkip("User Info could not be reached")
        }
    }

    func test_A11Y_userInfoAtDefaultTextSize() throws {
        try openUserInfo(args: Self.defaultSize.args)
        audit("User info", textSize: Self.defaultSize.label)
    }

    func test_A11Y_userInfoAtLargestTextSize() throws {
        try openUserInfo(args: Self.hugeSize.args)
        audit("User info", textSize: Self.hugeSize.label)
    }
}
