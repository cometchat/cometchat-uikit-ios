
<div style="width:100%">
    <div style="width:50%; display:inline-block">
        <p align="center">
        <img align="left" src="https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/MainScreenshot1.jpg">    
        </p>    
    </div>    
</div>

</br></br>
</div>





</br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br></br>

# What is UI Kit

The **UI Kit** library is collection of custom **UI Components** and **UI Screens** design to build chat application within few minutes. **UI kit** is designed to avoid boilerplate code for building UI,it has three different ways to build a chat application with fully customizable UI.It will help developers to build a chat application within using various **UI Components**.



## Setup

Follow the below metioned steps for easy setup and seamless integration with **UI Kit**.

### Get your Application Keys
<a href="https://app.cometchat.io/" traget="_blank">Signup for CometChat</a> and then:

* Create a new app
* Head over to the API Keys section and note the `API_Key`, `App_ID` and `REGION`.
---

### Add the CometChat Dependency

We recommend using CocoaPods, as they are the most advanced way of managing iOS project dependencies. Open a terminal window, move to your project directory, and then create a Podfile by running the following command
 
**Note:**
</br>
* CometChatPro SDK supports installation through Cocoapods only and it will support up to two latest releases of    
Xcode. Currently, we are supporting Xcode 11.3 and 11.4.
  
* CometChatPro SDK includes video calling components. We suggest you run on physical devices to avoid errors.

Create podfile using below command.

```bash
$ pod init
```
Add the following lines to the Podfile.

```bash
________________________________________________________________

For Xcode 11.4 or Higher:

platform :ios, '10.0'
use_frameworks!

target 'MyApp' do
     pod 'CometChatPro', '2.1.0'
end
________________________________________________________________

```
And then install the `CometChatPro` framework through CocoaPods.

```bash
pod install
```
___
# Initialize CometChat

The `init()` method initializes the settings required for CometChat. We suggest calling the `init()` method on app startup, preferably in the `onCreate()` method of the Application class.

```swift
import CometChatPro

class AppDelegate: UIResponder, UIApplicationDelegate{
{
   var window: UIWindow ?
   let appId: String = "ENTER API KEY"
   let region: String = "ENTER REGION CODE"
    
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

  let mySettings = AppSettings.AppSettingsBuilder().subscribePresenceForAllUsers().setRegion(region: region).build()
  CometChat(appId: appId ,appSettings: mySettings,onSuccess: { (isSuccess) in
  
                print("CometChat Pro SDK intialise successfully.")
            }
        }) { (error) in
            print("CometChat Pro SDK failed intialise with error: \(error.errorDescription)")
        }
        return true
    }
}
```
**Note :**
Make sure you replace the APP_ID with your CometChat `App_ID` and `REGION` with your app region in the above code.

___
# Log in your User

The `login()` method returns the User object containing all the information of the logged-in user.

```swift
let uid    = "SUPERHERO1"
let apiKey = "YOUR_API_KEY"

CometChat.login(UID: uid, apiKey: apiKey, onSuccess: { (user) in

  print("Login successful: " + user.stringValue())

}) { (error) in

  print("Login failed with error: " + error.errorDescription);

}
```
**Note :** </br>
* Make sure you replace the `API_KEY` with your CometChat API Key in the above code.
* We have setup 5 users for testing having UIDs: `SUPERHERO1`, `SUPERHERO2`, `SUPERHERO3`,`SUPERHERO4` and `SUPERHERO5`.
___

# Add UI Kit to your project

To integrate CometChat UIKit inside your app. Kindly follow the below steps: 

1. Simply clone the UIKit Library from ios-chat-uikit repository. 

2. After cloning the repository, Navigate to `Library` folder and Add the folder inside your app. 

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/addLibraryToProject.png)

3. Make sure you've selected `✅ Copy items if needed`  as well as `🔘 Create groups` options while adding Library inside your project. 


4. If the Library is added sucessfully,  all added folders  will be in Yellow color. 


___

# Launch UI Unified

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/UIUnified.jpg)


**UI Unified** is a way to launch a fully working chat application using the **CometChat Kitchen Sink**.In UI Unified all the UI Screens and UI Components working together to give the full experience of a chat application with minimal coding effort. 

To use Unified UI user has to launch `CometChatUnified` class.  `CometChatUnified` is a subclass of  `UITabbarController`.

```swift

let unifiedUI = CometChatUnified()
unifiedUI.setup(withStyle: .fullScreen)
self.present(unifiedUI, animated: true, completion: nil)


```

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/UIUnified.gif)

`CometChatUnified` provides below method to present this activity: 

1. `setup(withStyle: .fullScreen)` : This will present the window in Full screen.

2. `setup(withStyle: .popover)` : This will present the window as a popover.

---

To receive real time call events, user has to register for them in `App Delegate` class. 

```swift

CometChatCallManager().registerForCalls(application: self)

```


# Run the sample App

## Swift: 
Visit our [Swift sample app](https://github.com/cometchat-pro-samples/ios-swift-chat-app) repo to run the swift sample app.

## Objective C: 
Visit our [Objective-C sample app](https://github.com/cometchat-pro-samples/ios-objective-c-chat-app) repo to run the objective-c sample app.

**Note :** </br>
* To run the sample app kindly follow the instructions provided in `Readme.md` file.

*  If you're running Objective - C sample app then please run it on physical device. 

---

# UI Kit Documentation 

To read the full dcoumentation on UI Kit integration visit our [Documentation](https://prodocs.cometchat.com/docs/ios-ui-kit)  .

---

# Troubleshooting
Facing any issues while integrating or installing the UI Kit please <a href="https://forum.cometchat.com/"> visit our forum</a>.

---

