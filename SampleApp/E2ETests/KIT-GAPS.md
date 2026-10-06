# E2E-blocking Kit gaps (ENG-38638)

Two new E2E suites are written and correct but **parked with `XCTSkip`** because they
cannot pass without changes in the UI Kit (`CometChatUIKitSwift`) — i.e. the layer owned
by the main session, not this E2E fork. Each unskips the moment its Kit change lands; no
test rewrite is needed.

## 1. RESOLVED — the search bar never appeared when opened from a conversation
Originally filed as "the search field has no accessibility identifier". That was wrong: the field
was absent from the accessibility tree because it was **never installed**, not because it lacked a
label. Reproduced by hand before it was diagnosed — open a chat, More → Search, and the search
screen has no input at all.

**Cause.** `MessagesVC.viewWillDisappear` un-hides the navigation bar with `animated: true`. That
animation is still in flight while the pushed `CometChatSearch` installs its field via
`navigationItem.searchController`, so the field never gets installed — the bar reserves the height
(measured 114pt) but shows nothing. `HomeScreenViewController` un-hides **non-animated**, which is
why routing through Conversations first "fixed" it: that push happens from a settled state, and the
navigation bar keeps the correct layout afterwards.

**Fix.** One line — un-hide without animation when leaving to a non-`MessagesVC` destination.
Took `SearchInConversationTests` from 0 to 9 of 12 passing.

**Same pattern elsewhere, unverified:** `examples/push-notification-app/.../MessagesVC.swift`
carries the identical `setNavigationBarHidden(false, animated: true)` in `viewWillDisappear`, so it
very likely has the same bug. Not changed here because it has not been tested.

**Three search defects remain** — found by these tests, parked with reasons, each a real product
issue rather than a harness limitation:
- **The no-results state never renders.** Searching a keyword with no matches shows neither the
  "No results" title nor its subtitle. Manual QA reported the same failure independently (SC_005).
- **Emoji text is not returned by search** (SC_032).
- **A spaces-only query** leaves the screen in neither the initial nor the no-results state (SC_033).

## 2. RESOLVED — form bubble is retired by design (not a gap)
Originally filed as "form/scheduler bubbles render as not supported". Half of that was wrong.

**Form: correct as-is.** `CometChatFormBubble` was deliberately removed as dead API
(ENG-38811, `dc4e69bf5`, -1,381 lines). A form message therefore renders the
"This message type is not supported" placeholder, which is the intended behaviour — confirmed by
the developer. `InteractiveBubbleTests` now LOCKS THIS IN: it asserts the placeholder renders and
that no form title or submit button appears, so a future change cannot half-resurrect the bubble.

**Leftovers to finish the retirement** (Kit-side, small):
- `Components/Shared/Views/Interactive Bubble/FormBubbleStyle.swift` is now orphaned.
- `MessagesDataSource.getFormMessageTemplate(...)` is still defined and still registered in
  `getAllMessageTemplates(...)`, so a template is handed out for a view that no longer exists.
  Worth removing so the "not supported" path is reached deliberately rather than incidentally.

**Scheduler: same placeholder in the message list.** `MessagesDataSource.getSchedulerBubble` returns the
"not supported" bubble (unchanged since before v5.1.22); `CometChatSchedulerBubble` remains a public
standalone component with its own component and snapshot tests but is not used by the message list.
`test_1TO1_schedulerMessageRendersUnsupportedPlaceholder` locks the current behaviour in. Wiring the real
bubble into the message list would be a product decision.

## 3. No real-time delivery in this local dev setup (blocks ~most remaining tests)
- **Suites affected:** `SwipeToReplyTests`, `MentionOneToOneTests`, `ReactionListTests` — and by
  the same mechanism a large share of the existing 257 tests, which are heavily real-time.
- **Symptom:** "Seeded message did not arrive" / "Message did not arrive". The test opens a
  screen, has User B send over REST, and waits for live arrival.
- **Evidence:**
  - A probe message sent while the app was running never appeared live, and the Chats list
    preview for that conversation kept showing an older message.
  - Opening the conversation afterwards shows the probe message — so REST delivery and the
    history fetch are both fine; only live delivery is missing.
  - The app's network activity contains **no `wss://` connection at all** — only HTTPS calls to
    `*.cometchat.io`. No socket ⇒ no real-time events.
- **IMPORTANT — attribution not yet established.** This may well be an artifact of the
  **local dev wiring** this branch required (hand-assembled `LocalDev` package: dev
  `CometChatUIKitSwift.xcframework` built here + dev `CometChatSDK`/`CometChatStarscream`
  binaries vendored from `uikit-iOS/Pods`), rather than a product regression. Starscream is the
  websocket layer and is linked through that local package; if it is not initialising in this
  configuration, real-time dies exactly this way while REST keeps working.
  **Do not treat this as a product bug until it is reproduced on a normally-integrated build**
  (published Kit + published SDK, e.g. the sample app on `master-v5`).
- **Next step to attribute it:** run any existing real-time test (e.g.
  `ReceiveMessageTests.test_1TO1_receiveTextRealtime`) on a stock published-Kit build. If it
  passes there and fails here, the cause is the local dev packaging and not the Kit.

## 4. Media bubbles are not exposed to accessibility
- **Suites affected:** `MediaFromHistoryTests` (image + video cases parked); also the reason the
  existing `receiveImage`/`receiveVideo` tests fall back to "…OR the composer still exists",
  an assertion that passes even when no media arrives.
- **Symptom:** after an image or video message renders, the only `Image` elements XCUITest can
  see on the screen are the message-header avatar and the scroll-to-bottom chevron. The media
  bubble has no queryable element, label or identifier.
- **Impact:** media rendering cannot be asserted at all on iOS. File messages are the exception —
  they render their filename as text, so `test_1TO1_seededFileRendersWithItsName` and its group
  counterpart pass and are kept as the real coverage for attachments.
- **Ask:** an `accessibilityIdentifier` (or label) on the image/video bubble content view — the
  same one-line fix as the search field in #1. That unparks these two immediately and lets the
  existing media tests be tightened off their "…OrStable" fallback.

## Useful technique: seed before opening
Media and other inbound messages seeded over REST **before** the conversation is opened render
via the history fetch, which works fine — only the real-time append into an already-open chat is
broken (#3). Receive-side cases written this way are unblocked today; that is how the two file
cases pass. Prefer it for any new inbound coverage until #3 is fixed.

## 5. Behaviour findings needing a product decision (not blockers)
These are verified behaviours the new tests reached and measured. Each is parked, not deleted —
unskip if the behaviour should change, delete the test if the current behaviour is intended.
- **Composer drafts are discarded when leaving a conversation.** Drafts survive rotation
  (`test_E2E_rotationPreservesDraft`) but not navigation; the composer returns empty. Most chat
  apps retain a per-conversation draft. (`test_1TO1_draftSurvivesLeavingConversation`)
- **Bullet list emits a literal "• " glyph, not markdown "- ".** Every other format (bold,
  italic, strikethrough, inline code, code block, numbered list) emits real markdown, so this is
  inconsistent. The test accepts either today. (`test_1TO1_bulletListFormatSendsMarkdown`)
- **A cancelled incoming call leaves no record in the conversation.** Surfaced by tightening the
  old "…OrStable" assertions, which passed without the feature working.
  (`test_RT_CALL_incomingVoiceCall` / `…VideoCall`)
- **Copy cannot be verified from a test.** Cross-process pasteboard reads need a system paste
  prompt on iOS 16+; verifying Copy needs a `-UITestMode`-only echo view in the app.
  (`test_1TO1_copyPutsMessageTextOnPasteboard` and the group variant)

## 6. Compact composer formatting (`CompactComposerFormattingTests`)
68 cases drive the toolbar and typed markdown in `CometChatCompactMessageComposer` and assert
the exact text on the wire. They found:
- **By design — emoji are never formatted.** Bold on, type `héllo x 😀`, send: the wire text is
  `**héllo x **😀`. `test_1TO1_FMT_emojiStaysOutsideBoldRun` asserts that, and that the bubble
  shows no literal `**` (the closing marker follows a space, which strict CommonMark would not
  accept — so the other platforms' renderers are worth a glance).
- **Unconfirmed — autocorrect can corrupt code block text.** Typing `func name() {…}` into a
  code block once sent `funcfname() {…}unction`: a correction to "function" landed at a stale
  offset after the composer rewrote the text. Seen once, under XCUITest typing. The test now
  avoids dictionary words. Check by hand before filing: does autocorrect stay on inside a
  code block, and does accepting a suggestion there put it in the right place?
- **Unconfirmed — typed `**x**` markers sometimes stay visible in the composer.** The wire text
  is right either way. The markers were hidden in a composer that had already sent messages,
  but not in a fresh one. No test asserts this until someone checks it by hand.
- **By design, not a bug:** Code Block does nothing while a list is active
  (`FormatCompatibilityMatrix` disables it), and stacked formats nest as `~~<u>**_x_**</u>~~`.

## 7. Harness fixes from the 2026-09-17 full run
- **Incoming calls never started.** `SecondClient.initiateCall` failed with "Framework not
  installed please install" on every run: the Chat SDK needs CometChatCallsSDK linked into the
  process that places the call, and the UI-test runner did not link it. `try?` hid the error, so
  the tests reported "no call entry" instead. The runner now links CometChatCallsSDK, starting a
  call is no longer `try?`, and B's unanswered call is cancelled with `rejectCall(.cancelled)`
  (as the kit does) rather than `endCall`, which only ends a joined call.
- **BACKEND DEFECT — a conversation's last message can go backwards.** Send a text and then a
  card from the same user back to back: the conversation list's `lastMessage` settles on the
  OLDER text and stayed there for over a minute of polling (ids 391627 vs 391628). Sequenced —
  wait for the text to show, then send the card — the card shows in ~10 s. The preview test now
  sequences its sends; the ordering bug belongs to the backend team.
- **Card buttons checked before layout settled.** `cardButton` looked once with `.exists`, then
  swiped, which could scroll the card away while its images loaded. It now waits first.
