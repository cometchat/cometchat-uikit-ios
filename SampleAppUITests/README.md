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
  coverage/           Coverage matrices (reference only, not built)
```

A test's XCUITest method name carries its source-of-truth case id (for example
`test_1TO1_006_headerShowsName`), so each test maps directly back to the coverage sheet.

## Prerequisites

- **Xcode 16 or later** (the test target uses a synchronized file-system group).
- An **iOS Simulator** (deployment target is iOS 13+; use any modern simulator runtime).
- A **CometChat app** you control, with:
  - two test users (User A and User B), and
  - one test group that User A owns.
- That app's **App ID**, **Region**, **Auth Key**, and **REST API Key**.

> Note:
> No host-machine setup is required beyond Xcode and credentials. The suite does **not**
> shell out to `simctl`, host scripts, or any tooling outside the test process — a clean
> clone plus your credentials is enough to run it.

## Configuring credentials

Credentials live in **`SampleAppUITests/Helpers/TestSecrets.swift`**, which is **git-ignored**
so your keys are never committed. The test *logic* stays in the committed `TestConfig.swift`;
only the values are ignored. Create your copy from the template:

```bash
cp SampleAppUITests/Helpers/TestSecrets.swift.example \
   SampleAppUITests/Helpers/TestSecrets.swift
```

Then open `TestSecrets.swift` and replace each `PASTE_…` placeholder with your app's values:

| Field | Where to find it in the CometChat dashboard |
| ---------------------------------------- | ------------------------------------------------------------ |
| `appId`, `region`                        | App overview (`region` is `us`, `eu`, or `in`)               |
| `authKey`, `restApiKey`                  | **API & Auth Keys**                                          |
| `userAUid`, `userBUid`                   | **Users** — the two users the tests act as                   |
| `groupGuid`                              | **Groups** — a group User A owns                             |
| `userAName`, `userBName`, `groupName`    | the **display names** shown in the app for those users/group (cells are located by name, so these must match exactly) |

> Important:
> Never commit real keys. `TestSecrets.swift` is git-ignored on purpose; commit only the
> `TestSecrets.swift.example` template. If a key is ever pushed, rotate it at the CometChat
> dashboard — editing history does not un-leak it.
>
> Each value can also be overridden by an environment variable of the same name (for example
> `COMETCHAT_AUTH_KEY`), which is handy for CI without editing the file.

## Running

Credentials are compiled in from `TestSecrets.swift`, so there is no test plan to select and
no environment to set up — just build and run.

### From Xcode

1. Open `CometChatUIKitSwift.xcodeproj` (Swift Package dependencies resolve automatically).
2. Select the **SampleApp** scheme and a Simulator destination.
3. Press **⌘U** to run the whole suite, or run a single suite/test from the Test navigator.

### From the command line

```bash
make e2e                                                       # whole suite
make e2e T=MessageHeaderTests                                  # one class
make e2e T=MessageHeaderTests/test_1TO1_006_headerShowsName    # one test
make e2e DEVICE='iPhone 16'                                    # pick a simulator
```

The result bundle opens in Xcode automatically when the run finishes. If `TestSecrets.swift`
is missing, `make e2e` prints the one-time setup and exits.
