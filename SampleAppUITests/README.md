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

- **Xcode 16 or later** (the test target uses a synchronized file-system group).
- An **iOS 18+ Simulator** (the test target's deployment target is iOS 18).
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

Credentials are compiled in from `TestSecrets.swift`, so there is no environment to set
up — just build and run. The **SampleApp** scheme runs `SampleApp.xctestplan` by default
(random test order, no parallelization).

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

## Running in CI

The suite is CI-ready without committing any secret. Two things a fresh clone needs:

1. **A `TestSecrets.swift` to compile against.** It is git-ignored, so a clean CI clone
   doesn't have one. Copy it from the committed template before building — it holds only
   `PASTE_…` stubs, never real keys:

   ```bash
   cp SampleAppUITests/Helpers/TestSecrets.swift.example \
      SampleAppUITests/Helpers/TestSecrets.swift
   ```

2. **The real values, injected as environment variables.** `TestConfig` reads env first and
   falls back to the file, so the env vars override the placeholder stub at runtime. Store
   these as your CI's encrypted secrets (never as plaintext in the repo or logs):

   | Env var | Meaning |
   | ------------------------ | ------------------------------------ |
   | `COMETCHAT_APP_ID`       | App ID |
   | `COMETCHAT_REGION`       | `us`, `eu`, or `in` |
   | `COMETCHAT_AUTH_KEY`     | Auth Key |
   | `COMETCHAT_REST_API_KEY` | REST API Key |
   | `TEST_USER_A_UID`        | User A UID |
   | `TEST_USER_B_UID`        | User B UID |
   | `TEST_GROUP_GUID`        | GUID of a group User A owns |
   | `TEST_USER_A_NAME`       | User A display name (cells located by name) |
   | `TEST_USER_B_NAME`       | User B display name |
   | `TEST_GROUP_NAME`        | Group display name |

A CI job then looks like:

```bash
cp SampleAppUITests/Helpers/TestSecrets.swift.example \
   SampleAppUITests/Helpers/TestSecrets.swift
xcodebuild test \
  -project CometChatUIKitSwift.xcodeproj \
  -scheme SampleApp \
  -destination 'platform=iOS Simulator,name=<your iOS 18+ Simulator>'
```

If any credential is still a placeholder or empty at launch, `TestConfig.validate()` fails
the test immediately with a message naming the missing env vars — so a misconfigured CI run
fails fast instead of timing out on a failed login.

> Run tests serially in CI (the default test plan already uses no parallelization). Batching
> UI tests back-to-back can trip the Simulator's accessibility bridge; if you shard, prefer
> one Simulator per shard.
