<div style="width:100%">
    <div style="width:50%; display:inline-block">
        <p align="center">
        <img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro/ios-swift-chat-app/blob/master/Screenshots/logo.png">    
        </p>    
    </div>    
</div>
</div>

</br>

# CometChat iOS Chat SDK

<a href="https://cocoapods.org/pods/CometChatPro"><img src="https://img.shields.io/badge/platform-iOS-orange.svg" /></a>
<a href=""><img src="https://img.shields.io/badge/language-Objective--C%20%7C%20Swift-orange.svg" /></a>
<a href=""> <img src="https://img.shields.io/badge/Contributors-4-yellowgreen" /></a>
<a href=" "> <img src="https://img.shields.io/badge/Version-3.0.900-red" /></a>
<a href=""> <img src="https://img.shields.io/github/stars/cometchat-pro/ios-chat-sdk?style=social" /></a>

</p>
</br></br>

CometChat enables you to add voice, video & text chat for your website & app.
___

## Prerequisites :star:

Before you begin, ensure you have met the following requirements:

✅ &nbsp; You have installed the latest version of Xcode. (Above Xcode 12 Recommended)

✅ &nbsp; iOS Chat SDK works for the iOS devices from iOS 11 and above.

___

## Installing iOS Chat SDK 

## 1. Setup  :wrench:

To install iOS Chat SDK, you  need to first register on CometChat Dashboard. [Click here to sign up](https://app.cometchat.com/login).

### i. Get your Application Keys :key:

* Create a new app
* Head over to the Quick Start or API & Auth Keys section and note the `App ID`, `Auth Key`,  and  `Region`.
---

### ii. Add the CometChatPro Dependency


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
     pod 'CometChatPro', '3.0.900'
end
________________________________________________________________


```
v3.0.1+ onwards, Voice & Video Calling functionality has been moved to a separate framework. Please add the following pod to your app Podfile in case you plan on using the Voice and Video Calling feature.   

```bash
________________________________________________________________

For Xcode 12 and above:

platform :ios, '11.0'
use_frameworks!

target 'YourApp' do
     pod 'CometChatPro', '3.0.900'
     pod 'CometChatCalls', '2.1.1'
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

### i. Initialize CometChat :star2:

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

### ii.Create User :bust_in_silhouette:

Once initialisation is successful, you will need to create a user. To create users on the fly, you can use the `createUser()` method. This method takes an `User` object and the `Auth Key` as input parameters and returns the created User object if the request is successful.

```swift

let newUser : User = User(uid: "user1", name: "Kevin") // Replace with your uid and the name for the user to be created.
let authKey = "authKey" // Replace with your Auth Key.
CometChat.createUser(user: newUser, apiKey: authKey, onSuccess: { (User) in
      print("User created successfully. \(User.stringValue())")
  }) { (error) in
     print("The error is \(String(describing: error?.description))")
}

```
___

### iii.Log in your User :bust_in_silhouette:

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
---

# Checkout our iOS UI Kit

Visit our [iOS Chat UI Kit](https://github.com/cometchat-pro/ios-chat-ui-kit) repo to integrate it inside your app.


---

# Checkout our sample apps

## Swift: 
Visit our [Swift sample app](https://github.com/cometchat-pro-samples/ios-swift-chat-app) repo to run the swift sample app.

## Objective C: 
Visit our [Objective-C sample app](https://github.com/cometchat-pro-samples/ios-objective-c-chat-app) repo to run the objective-c sample app.

---


# Troubleshooting

- To read the full dcoumentation on CometChat integration visit our [Documentation](https://prodocs.cometchat.com/docs/ios-quick-start).

- Facing any issues while integrating or installing the UI Kit please <a href="https://app.cometchat.io/"> connect with us via real time support present in CometChat Dashboard.</a>.

---


# Contributors

Thanks to the following people who have contributed to this project:

[@pushpsenairekar2911 👨‍💻](https://github.com/pushpsenairekar2911) <br>
[@ghanshyammansata 👨‍💻](https://github.com/ghanshyammansata) <br>
[@jeetkapadia 👨‍💻](https://github.com/jeetkapadia) <br>
[@NishantTiwarins 👨‍💻](https://github.com/NishantTiwarins) <br>

---

# Contact :mailbox:

Contact us via real time support present in [CometChat Dashboard.](https://app.cometchat.io/)

---

# License

This project uses the following [license](https://github.com/cometchat-pro/ios-swift-chat-ui-kit/blob/master/License.md).


# CometChatWorkspace
