# CometChat Sample App E2E UI Tests

End-to-end UI tests for the CometChat UIKit iOS sample app, written with **XCUITest**.

The suite drives the real app in a Simulator against a real CometChat backend — messages, groups,
presence and read receipts are seeded and verified over the CometChat REST API and, where REST
can't reach (a live typing indicator), through a second chat session running inside the test
process.

Two ways to use it:

- **Run it** to confirm the sample app works against your own CometChat app.
- **Read it** as executable documentation — each test shows how a UIKit component is expected to
  behave, which is often quicker than reading the component source.

## Prerequisites

- **Xcode 16 or later** with an **iOS 18+ Simulator**.
- **XcodeGen** (`brew install xcodegen`) — the `.xcodeproj` is generated from `project.yml`.
- A **CometChat app** you control, containing:
  - two users (referred to below as User A and User B), and
  - one group owned by User A.
- That app's **App ID**, **Region**, **Auth Key** and **REST API Key**, all from the
  [CometChat dashboard](https://app.cometchat.com).

Nothing else is required — no `simctl` scripting, no host setup. A clone plus your credentials is
enough.

## Configuring credentials

Credentials live in `E2ETests/Helpers/TestSecrets.swift`, which ships with `PASTE_…` placeholders.
Open it and replace each placeholder with your value. It compiles into the test target, so there is
no environment or scheme setup.

> ### ⚠️ Do not commit your filled-in credentials
>
> `TestSecrets.swift` is a tracked file, so your keys will appear in `git status` once you edit it.
> Keep the change local and never `git add` it. If you do commit a key, rotate it in the CometChat
> dashboard — rewriting git history does not un-leak it.

| Field | Where to find it |
| --- | --- |
| `appId`, `region` | App overview (`region` is `us`, `eu` or `in`) |
| `authKey`, `restApiKey` | **API & Auth Keys** |
| `userAUid`, `userBUid` | **Users** — the two users the tests act as |
| `userAName`, `userBName` | The **display names** of those users. Tests locate list cells by name, so these must match exactly. |

## Running

```bash
xcodegen generate
xcodebuild test \
  -project CometChatSampleApp.xcodeproj \
  -scheme CometChatSampleApp \
  -destination 'platform=iOS Simulator,name=iPhone 17'
```

Substitute any installed iOS 18+ Simulator; list yours with
`xcrun simctl list devices available`.

From Xcode: run `xcodegen generate`, open the generated project, select the **CometChatSampleApp**
scheme and a Simulator, then press **⌘U**. Individual tests can be run from the Test navigator.

Narrow a run with `-only-testing:`:

```bash
-only-testing:CometChatSampleAppUITests/MessageHeaderTests
-only-testing:CometChatSampleAppUITests/MessageHeaderTests/test_1TO1_headerShowsName
```

## How the suite is organized

```
E2ETests/
  Session/          Auth, connection, presence, REST connectivity
  Conversations/    Conversation list, unread badge
  Messages/         1:1 send / receive / edit / delete, composer, header, edge cases
    Features/       Media, reactions, thread replies, read receipts, typing
  Groups/           Group create / join / lifecycle / message actions / permissions
  Calls/            Call initiation from a chat
  App/              App-wide: configuration (rotation, theme), broad slices
  Helpers/          Launch, element queries, REST seeding, second client, async support
```

The **Users** list, search and user-detail flows don't have their own folder — they're
exercised inside `Messages/E2E1to1ConversationTests` (`test_1TO1_openChatFromUsersTab`,
`test_E2E_searchSurfacesUser`, `test_1TO1_userInfoShows…`), where opening a 1:1 chat
naturally goes through the Users list.

Test names follow `test_<CATEGORY>_<behavior>` — a category prefix (`1TO1`, `GRP`, `RT_MSG`, …)
plus a descriptive suffix, for example `test_1TO1_headerShowsName`.
