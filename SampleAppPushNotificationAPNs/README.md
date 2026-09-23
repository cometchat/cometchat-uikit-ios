# CometChat Push Notification Sample App

The CometChat UI Kit sample demonstrating **APNs push notifications and VoIP calling**
on top of the standard messaging flows.

## Prerequisites

- Xcode 15 or later
- iOS 15.1+ device (push and VoIP require a real device, not the simulator)
- A CometChat app — create one on the [CometChat Dashboard](https://app.cometchat.com/) to get an **App ID**, **Region**, and **Auth Key**.
- An APNs push notifications extension configured in the CometChat Dashboard, which gives you a **Provider ID**.
- An Apple Developer account with Push Notifications capability enabled for the app's bundle identifier.

## Setup

Open `AppConstants.swift` and fill in your credentials:

```swift
static var APP_ID:      String = "<YOUR_APP_ID>"
static var AUTH_KEY:    String = "<YOUR_AUTH_KEY>"
static var REGION:      String = "<YOUR_REGION>"       // us | eu | in
static var PROVIDER_ID: String = "<YOUR_PROVIDER_ID>"  // from the APNs extension in the dashboard
```

> These fields ship as placeholders. You must set them before the app can connect and receive pushes.

## Run

1. Open `CometChatPushNotificationSampleApp.xcodeproj` in Xcode.
2. Set your development team and a unique bundle identifier under **Signing & Capabilities**.
3. Let Swift Package Manager resolve dependencies.
4. Select a real device and press **Run**.

## Documentation

See the [iOS UI Kit documentation](https://www.cometchat.com/docs/ui-kit/ios/overview) and the [push notifications guide](https://www.cometchat.com/docs/notifications/push-overview) for setup details.
