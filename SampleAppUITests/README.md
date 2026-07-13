# SampleApp E2E UI Tests

End-to-end UI tests for the CometChat UIKit iOS **SampleApp**, written with **XCUITest**.
The suite drives the real app in a Simulator and asserts against real CometChat backend
state — messages, groups, presence, and receipts are seeded and mutated over the CometChat
REST API and, where REST cannot (a live typing indicator), through a headless in-process
second client.

## How the suite is organized

Tests live under `SampleAppUITests/` and are grouped into feature suites:

```
SampleAppUITests/
  E2ETests/
    Session/          Auth, connection, presence, REST connectivity
    Conversations/    Conversation list, unread badge
    Users/            Users list / detail / search
    Messages/         1:1 send / receive / edit / delete, composer, header, edge cases
      Features/       Media, reactions, thread replies, read receipts, typing
    Groups/           Group create / join / lifecycle / message actions / permissions
    Calls/            Call initiation from a chat
    App/              App-wide: configuration (rotation/theme), broad slices
  Helpers/            Launch, queries, REST peer actions, seeding, async support
```

Test method names follow `test_<CATEGORY>_<behavior>` — a category prefix (`1TO1`, `GRP`,
`RT_MSG`, …) plus a descriptive suffix, for example `test_1TO1_headerShowsName`.

## Prerequisites

- **Xcode 15 or later** with an **iOS 18+ Simulator** (the test target's deployment target is iOS 18).
- A **CometChat app** you control, with:
  - two test users (User A and User B), and
  - one test group that User A owns.
- That app's **App ID**, **Region**, **Auth Key**, and **REST API Key**.

> Note:
> No host-machine setup is required beyond Xcode and credentials. The suite does **not**
> shell out to `simctl`, host scripts, or any tooling outside the test process — a clean
> clone plus your credentials is enough to run it.

## Configuring credentials

Credentials live in `SampleAppUITests/Helpers/TestSecrets.swift`, which holds only
`PASTE_…` placeholders. **Fill it in to run the suite:** open the file and replace each `PASTE_…`
with your value. It's compiled into the test target, so no environment setup is needed.

| Field | Where to find it in the CometChat dashboard |
| ---------------------------------------- | ------------------------------------------------------------ |
| `appId`, `region`                        | App overview (`region` is `us`, `eu`, or `in`)               |
| `authKey`, `restApiKey`                  | **API & Auth Keys**                                          |
| `userAUid`, `userBUid`                   | **Users** — the two users the tests act as                   |
| `groupGuid`                              | **Groups** — a group User A owns                             |
| `userAName`, `userBName`, `groupName`    | the **display names** shown in the app for those users/group (cells are located by name, so these must match exactly) |

> **`TestSecrets.swift` is tracked.** Your filled-in values show up in `git status` — **never
> commit real keys.** Treat the edit as local-only and do not `git add` it. If a key is ever
> committed, rotate it at the CometChat dashboard — editing history does not un-leak it.

## Running

Once `TestSecrets.swift` is filled in (above), just build and run. The **SampleApp** scheme runs
`SampleApp.xctestplan` by default (random test order, no parallelization).

### From Xcode

1. Open `CometChatUIKitSwift.xcodeproj` (Swift Package dependencies resolve automatically).
2. Select the **SampleApp** scheme and a Simulator destination.
3. Press **⌘U** to run the whole suite, or run a single suite/test from the Test navigator.

### From the command line

```bash
xcodebuild test \
  -project CometChatUIKitSwift.xcodeproj \
  -scheme SampleApp \
  -destination 'platform=iOS Simulator,name=<your iOS 18+ Simulator>'
```

Use any installed iOS 18+ Simulator for the destination name (for example
`iPhone 17`); list what you have with `xcrun simctl list devices available`.

Add `-only-testing:` to narrow the run:

```bash
-only-testing:SampleAppUITests/MessageHeaderTests                              # one class
-only-testing:SampleAppUITests/MessageHeaderTests/test_1TO1_headerShowsName    # one test
```
