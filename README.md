
<div style="width:100%">
    <div style="width:50%; display:inline-block">
        <p align="center">
        <img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro/ios-swift-chat-ui-kit/blob/master/Screenshots/logo.png">    
        </p>    
    </div>    
</div>
</div>

</br>



# iOS Chat UI Kit

<p align="left">

<a href=""><img src="https://img.shields.io/badge/Repo%20Size-11.1%20MB-brightgreen" /></a>
<a href=""> <img src="https://img.shields.io/badge/Contributors-2-yellowgreen" /></a>
<a href=" "> <img src="https://img.shields.io/badge/Version-3.0.908--pluto.beta.1-red" /></a>
<a href=""> <img src="https://img.shields.io/github/stars/cometchat-pro/ios-swift-chat-ui-kit?style=social"/></a>
<a href=""> <img src="https://img.shields.io/twitter/follow/cometchat?style=social" /></a>

</p>
</br></br>

<div style="width:100%">
    <div style="width:50%; display:inline-block">
        <p align="center">
        <img align="left" src="https://github.com/cometchat-pro/ios-swift-chat-ui-kit/blob/master/Screenshots/MainScreenshot1.png">    
        </p>    
    </div>    
</div>

The **UI Kit** library is collection of custom **UI Components** and **UI Screens** design to build chat application within few minutes. **UI kit** is designed to avoid boilerplate code for building UI,it has three different ways to build a chat application with fully customizable UI. It will help developers to build a chat application within using various **UI Components**.

___


## Prerequisites

Before you begin, ensure you have met the following requirements:

- You have installed the latest version of Xcode. (Above Xcode 12 Recommended)

- iOS Chat UI Kit works for the iOS devices from iOS 13 and above.

NOTE: Please install the latest pod version on your Mac to avoid integration issues

```bash
Please follow the below steps:

sudo gem update cocoapods --pre
pod update
clean
build

```
NOTE: If you're building the new project, the please add below line in **AppDelegate.swift**

```bash
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
 var window: UIWindow?

}

```

___

## Get Started

You can start building a modern messaging experience in your app by installing Pluto UIKit. This developer kit is an add-on feature to CometChatPro iOS SDK so installing it will also install the core Chat SDK.

## Step 1 : Create a project

To get started, open Xcode and create a new project.

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/UIUnified.jpg)

Enter name, identifier and proceed.

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/UIUnified.jpg)
___

## Step 2 : Install UI Kit

You can install UIKit for iOS through Swift Package Manager.

1. Go to your Swift Package Manager's File tab and select Add Packages.


2.  Add CometChatProUIKit into your Package Repository as below:

```swift

https://github.com/cometchat-pro/ios-swift-chat-ui-kit.git

```

3. To add the package, select Version Rules, enter Up to Exact Version, 3.0.908-pluto.beta.1, and click Next.
___

### i. Initialize Client App

The `init()` method initializes the settings required for CometChat. We suggest calling the `init()` method on app startup, preferably in the `didFinishLaunchingWithOptions()` method of the Application class.

```swift
import CometChatPro

class AppDelegate: UIResponder, UIApplicationDelegate{

   var window: UIWindow?
   let appId: String = "ENTER APP ID"
   let region: String = "ENTER REGION CODE"
    
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

  let mySettings = AppSettings.AppSettingsBuilder().subscribePresenceForAllUsers().setRegion(region: region).build()
  CometChat(appId: appId ,appSettings: mySettings,onSuccess: { (isSuccess) in
  
                print("CometChat Pro SDK intialise successfully.")

        }) { (error) in
            print("CometChat Pro SDK failed intialise with error: \(error.errorDescription)")
        }
        return true
    }
}
```
**Note :**
Make sure you replace the APP_ID with your CometChat `appId` and `region` with your app region in the above code.

___
### ii.Log in your User

The `login()` method returns the User object containing all the information of the logged-in user.

```swift
let uid    = "SUPERHERO1"
let authKey = "ENTER AUTH KEY"

CometChat.login(UID: uid, apiKey: authKey, onSuccess: { (user) in

  print("Login successful: " + user.stringValue())

}) { (error) in

  print("Login failed with error: " + error.errorDescription);

}
```
**Note :** </br>
* Make sure you replace the `authKey` with your CometChat Auth Key in the above code.

* We have setup 5 users for testing having UIDs: `SUPERHERO1`, `SUPERHERO2`, `SUPERHERO3`,`SUPERHERO4` and `SUPERHERO5`.
___


## 3. Launch UI Components

The UIKit is a set of prebuilt UI components that allows you to easily build beautiful in-app chat with all the essential messaging features.

UIKit for iOS manages the lifecycle of its ViewController along with various views and data from the Chat SDK for iOS. It provides the following components:

 To read the full dcoumentation on UI Kit Compoenents visit our [Documentation](https://app.developerhub.io/cometchat-documentation/v3/swift-chat-ui-kit/pluto-ui-components)  .

___

# Troubleshooting

- To read the full dcoumentation on UI Kit integration visit our [Documentation](https://prodocs.cometchat.com/docs/ios-ui-kit)  .

- Facing any issues while integrating or installing the UI Kit please <a href="https://app.cometchat.io/"> connect with us via real time support present in CometChat Dashboard.</a>.

---


# Contributors

Thanks to the following people who have contributed to this project:

[@pushpsenairekar2911 👨‍💻](https://github.com/pushpsenairekar2911) <br>
[@AbdullahAnsarri 👨‍💻](https://github.com/AbdullahAnsarri)

---

# Contact

Contact us via real time support present in [CometChat Dashboard.](https://app.cometchat.io/)

---

# License

---

This project uses the following [license](https://github.com/cometchat-pro/ios-swift-chat-ui-kit/blob/master/License.md).
