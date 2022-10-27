
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

<a href=""><img src="https://img.shields.io/badge/Repo%20Size-13.3%20MB-brightgreen" /></a>
<a href=""> <img src="https://img.shields.io/badge/Contributors-2-yellowgreen" /></a>
<a href=" "> <img src="https://img.shields.io/badge/Version-3.0.910--1-red" /></a>
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

- iOS Chat UI Kit works for the iOS devices from iOS 11 and above.

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

## Installing iOS Chat UI Kit

## 1. Setup

To install iOS UI Kit, you  need to first register on CometChat Dashboard. [Click here to sign up](https://app.cometchat.com/login).

### i. Get your Application Keys

* Create a new app
* Head over to the Quick Start or API & Auth Keys section and note the `App ID`, `Auth Key`,  and  `Region`.
---

### ii. Add the CometChat Dependency


We recommend using CocoaPods, as they are the most advanced way of managing iOS project dependencies. Open a terminal window, move to your project directory, and then create a Podfile by running the following command


Create podfile using below command.

```bash
$ pod init
```
Add the following lines to the Podfile.

```bash
________________________________________________________________

For Xcode 12 and above:

platform :ios, '11.0'
use_frameworks!

target 'YourApp' do
     pod 'CometChatPro', '3.0.910'
     pod 'CometChatCalls', '2.2.0'
end
________________________________________________________________

```
And then install the `CometChatPro` framework through CocoaPods.

```bash
pod install
```

If you're facing any issues while installing pods then use below command. 


```bash
pod install --repo-update
```

___

## 2. Configure CometChat inside your app

### i. Initialize CometChat

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


## 3. Add UI Kit to your project

To integrate CometChat UIKit inside your app. Kindly follow the below steps: 

i. Simply clone the UIKit Library from ios-chat-uikit repository. 

ii. After cloning the repository, Navigate to `Library` folder and drag and drop `Library` folder inside your project's folder. 

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/addLibraryToProject.png)

iii. Make sure you've selected `✅ Copy items if needed`  as well as `🔘 Create groups` options while adding Library inside your project. 


iv. If the Library is added sucessfully,  all added folders  will be in Yellow color. 


___

## 4. Launch CometChat UI

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/UIUnified.jpg)


**CometChat UI** is a way to launch a fully working chat application using the **CometChat Kitchen Sink**.In CometChat UI all the UI Components working together to give the full experience of a chat application with minimal coding effort. 

To use CometChat UI user has to launch `CometChatUI` class.  `CometChatUI` is a subclass of  `UITabbarController`.

```swift

DispatchQueue.main.async {
let cometChatUI = CometChatUI()
cometChatUI.setup(withStyle: .fullScreen)
self.present(cometChatUI, animated: true, completion: nil)
}


```

Note: Please run the above code snippet in the main thread. 

`CometChatUI` provides below method to present this activity: 

1. `setup(withStyle: .fullScreen)` : This will present the window in Full screen.

2. `setup(withStyle: .popover)` : This will present the window as a popover.

---

To receive real time call events, user has to register for them in `App Delegate` class. 

```swift

CometChatCallManager().registerForCalls(application: self)

```
---

# Checkout our sample apps

## Swift: 
Visit our [Swift sample app](https://github.com/cometchat-pro-samples/ios-swift-chat-app) repo to run the swift sample app.

## Objective C: 
Visit our [Objective-C sample app](https://github.com/cometchat-pro-samples/ios-objective-c-chat-app) repo to run the objective-c sample app.

---

# Troubleshooting

- To read the full dcoumentation on UI Kit integration visit our [Documentation](https://prodocs.cometchat.com/docs/ios-ui-kit)  .

- Facing any issues while integrating or installing the UI Kit please <a href="https://app.cometchat.io/"> connect with us via real time support present in CometChat Dashboard.</a>.

---


# Contributors

Thanks to the following people who have contributed to this project:

[@pushpsenairekar2911 👨‍💻](https://github.com/pushpsenairekar2911) <br>
[@AbdullahAnsarri 👨‍💻](https://github.com/AbdullahAnsarri) <br>
[@ajayv-cometchat 👨‍💻](https://github.com/ajayv-cometchat) 

---

# Contact

Contact us via real time support present in [CometChat Dashboard.](https://app.cometchat.io/)

---

# License

---

This project uses the following [license](https://github.com/cometchat-pro/ios-swift-chat-ui-kit/blob/master/License.md).
