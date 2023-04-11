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

✅ &nbsp; macOS

✅ &nbsp; Xcode

✅ &nbsp; iOS 13.0 and later

✅ &nbsp; Swift 4.0+

___

## Installing UI Kit

## 1. Setup  :wrench:

To install iOS Chat UIKit, you  need to first register on CometChat Dashboard. [Click here to sign up](https://app.cometchat.com/login).

### i. Get your Application Keys :key:

* Create a new app
* Head over to the Quick Start or API & Auth Keys section and note the `App ID`, `Auth Key`,  and  `Region`.
---

### ii. You can install UIKit for iOS through Swift Package Manager.

* Go to your Swift Package Manager's File tab and select Add Packages.

* Add CometChatProUIKit into your Package Repository as below:
  * https://github.com/cometchat-pro/ios-swift-chat-ui-kit.git
  
* To add the package, select Version Rules, enter Up to Exact Version, [3.0.912-pluto.beta.2.0](https://github.com/cometchat-pro/ios-swift-chat-ui-kit/tree/pluto), and click Next

___

## 2. Calling Functionality
If you want calling functionality inside your application then you need to install calling SDK additionally inside your project. You can install CometChatProCalls Calling SDK for iOS through Swift Package Manager.

* Go to your Swift Package Manager's File tab and select Add Packages

* Add CometChatProCalls into your Package Repository as below:

  * https://github.com/cometchat-pro/ios-calls-sdk.git

* To add the package, select Version Rules, enter Up to Exact Version, 3.0.0, and click Next.

___

## 3. Configure CometChat inside your app

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
