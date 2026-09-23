# CometChat AI Sample App

The CometChat UI Kit sample focused on the **AI Agents** experience — chatting with AI
assistants alongside the standard messaging flows.

## Prerequisites

- Xcode 15 or later
- iOS 15.1+ simulator or device
- A CometChat app with AI Agents configured — create one on the [CometChat Dashboard](https://app.cometchat.com/) to get an **App ID**, **Region**, and **Auth Key**.

## Setup

Open `AppConstants.swift` and fill in your credentials:

```swift
static var APP_ID:   String = "<YOUR_APP_ID>"
static var AUTH_KEY: String = "<YOUR_AUTH_KEY>"
static var REGION:   String = "<YOUR_REGION>"   // us | eu | in
```

> These fields ship as placeholders. You must set them before the app can connect.

## Run

1. Open `CometChatAISampleApp.xcodeproj` in Xcode.
2. Let Swift Package Manager resolve dependencies.
3. Select a simulator and press **Run**.

## Documentation

See the [iOS UI Kit documentation](https://www.cometchat.com/docs/ui-kit/ios/overview) and the [AI Agents guide](https://www.cometchat.com/docs/ai-agents/overview) for details.
