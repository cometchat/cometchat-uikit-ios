

# Prerequisites


The  **CometChat Kitchen Sink**  Library depends on two major libraries. i.e `CometChatPro` SDK and `Kingfisher`. Also, to use  **CometChat Kitchen Sink** user must created an app in  **CometChat Dashboard**

##  **Create app in CometChat Dashboard**

<a href="https://app.cometchat.io" target="_blank">Signup for CometChat</a> and then:

1. Create a new app: Enter a name & region  then hit the **+** button
2. Head over to the **API Keys** section and click on the **Create API Key** button
3. Enter a name and select the scope as **Auth Only**
4. Now note the **API Key** , **App ID**  and **Region Code** 
---

## **Add CometChatPro dependancy**

CometChatPro SDK supports installation through Cocoapods. To Add CometChatPro dependancy. Kindly, [Click here](https://prodocs.cometchat.com/docs/ios-quick-start).
---

## **Add Kingfisher dependancy**

Kingfisher is a powerful, pure-Swift library for downloading and caching images from the web. It provides you a chance to use a pure-Swift way to work with remote images in your next app.

```
target 'MyApp' do

  pod 'Kingfisher', '~> 5.0'

end
```
---

## **Add Request Authorization**

Prepare your app for this requirement by providing justification strings. The justification string is a localizable message that you add to your app's Info.plist file to tell the user why your app needs access to the user's photo library, Camera, Microphone. Then, App prompts the user to grant permission for access, the alert displays the justification string you provided, in the language of the locale selected on the user's device. You can do this as follows:

![Studio Guide](https://files.readme.io/1a4fdb6-infoplist.png)   

```
<key>NSAppTransportSecurity</key>
  <dict>
	  <key>NSAllowsArbitraryLoads</key>
	  <true />
  </dict>
<key>NSCameraUsageDescription</key>
	<string>$(PRODUCT_NAME) need access to the camera in order to update your avatar</string>
<key>NSPhotoLibraryUsageDescription</key>
	<string>$(PRODUCT_NAME) need access to the Photo Library in order to send Media Messages</string>
<key>NSMicrophoneUsageDescription</key>
	<string>$(PRODUCT_NAME) need access to the Microphone in order to connect Audio/Video call </string>


```
---
 
