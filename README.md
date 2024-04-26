<p align="center">
  <img alt="CometChat" src="https://assets.cometchat.io/website/images/logos/banner.png">
</p>

# CometChat iOS UI Kit

CometChat Swift UIKit provides a pre-built user interface kit that developers can use to quickly integrate a reliable & fully-featured chat experience into an existing or a new mobile app.<br />

<div style="
    display: flex;
    align-items: center;
    justify-content: center;">
   <img src="./Screenshots/overview_cometchat_screens.png" />
</div>

## Prerequisites

 - Xcode
 - iOS 13.0 and later
 - Swift 4.0+

## Getting Started

To set up Swift Chat UIKit and utilize CometChat for your chat functionality, you'll need to follow these steps:
- Registration: Go to the [CometChat Dashboard](https://www.cometchat.com/) and sign up for an account.
- Create an App: After registering, log in to your CometChat account and create a new app. Provide the necessary details such as the app name, platform (Swift/iOS), and other relevant information. Once you've created the app, CometChat will generate an Auth Key and App ID for you. Make sure to keep these credentials secure, as you'll need them later.
- Check the [Key Concepts](https://www.cometchat.com/docs/v4/ios-uikit/key-concepts) to understand the basic components of CometChat.
- Refer to the [Integration Steps](https://www.cometchat.com/docs/v4/ios-uikit/integration) in our documentation to integrate the UI Kit into your iOS app.

## Dependencies
Swift Chat UIKit handles all the Chat SDK-related dependencies internally except calling dependency. To add calling functionality inside your application, you can install CometChatCallsSDK Calling SDK for iOS through Swift Package Manager.

1. Go to your Swift Package Manager's File tab and select Add Packages.
2. Add CometChatCallsSDK into your Package Repository as below:
  ```
  https://github.com/cometchat-pro/ios-calls-sdk.git
  ```
3. Select Version Rules, add the latest Calls SDK version and click Next.

  
## Help and Support
For issues running the project or integrating with our UI Kits, consult our [documentation](https://www.cometchat.com/docs/ios-uikit/integration) or create a [support ticket](https://help.cometchat.com/hc/en-us) or seek real-time support via the [CometChat Dashboard](https://app.cometchat.com/).
