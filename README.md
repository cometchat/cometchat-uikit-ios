
<div style="width:100%">
    <div style="width:50%; display:inline-block">
        <p align="center">
        <img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro/ios-swift-chat-app/blob//v2/Screenshots/CometChat%20Logo.png">    
        </p>    
    </div>    
</div>

</br>
</br>
</div>


CometChat UIKit (built using **CometChat Pro**) is a fully functional messaging kit capable of **one-on-one** (private) and **group** messaging along with recent conversations. This kit enables users to send **text** and **multimedia messages like  images, documents.**

## Table of Contents

1. [Screenshots](#Screenshots)

2. [Prerequisites](#Prerequisites)

3. [Setup](#Setup)

4. [Integration](#Integration)

5. [Troubleshoot](#Troubleshoot)

6. [Contributing](#Contributing) 


# Screenshots

<img align="left" src="Enter Link here">
   
<br></br><br></br><br></br><br></br><br></br><br></br><br></br><br></br>

# Prerequisites

Before you begin, we strongly recommend you read the Prerequisites which are required to add CometChat UIKit inside your app. Kindly, [Click here](https://Prerequisites.md link here).

# Setup

We hope you followed instructions given in Prerequisites section and you have added necessory dependancies inside you app. 

To integrate CometChat UIKit inside your app. Kindly follow the below steps: 

1. Simply clone the UIKit Library from ios-chat-uikit repository. 

2. After cloning the repository, Navigate to `Library` folder and Add the folder inside your app. 

![Studio Guide](https://Enter add library to project link here)

3. Make sure you've selected `✅ Copy items if needed`  as well as `🔘 Create groups` options while adding Library inside your project. 

4. If the Library is added sucessfully, it will look like mentioned in the below image. 

![Studio Guide](https://Enter library structure to project link here)

You can refer the CometChat UIKit iOS Sample app. [Click here](https://Sample app link here) to refer the sample app. 

# Integration

CometChat UIKit is Divided into two sections i.e. UIComponents and UIScreens. UIScreens are ready made easy to use predefined screens present in library. User can create their own layout using screen in few minutes whereas  UIComponents includes components such as Avtar, Status Indicator, Badge Count etc. which user can use anywhere inside the App. 

## UIScreens: 

1. CometChatLauncher: 

CometChatLauncher is a combined screen which is a subclass of UITabBarController and includes all screens as shown in the image. Developer can launch this screen using below code snippet or assign the class to UITabBarController to launch this activity. 

```
let launcher = CometChatLauncher()
launcher.setup(withStyle: .fullScreen)
self.present(launcher, animated: true, completion: nil)

```

2. CometChatUserList: 

CometChatUserList is a subclass of UIViewController which displays user list in alphabetical sections.  Developer can launch this screen using below code snippet or assign the class to UIViewController to launch this activity. To display the title in `CometChatUserList` please attach the UINavigationController to it. 

```
let userList = CometChatUserList()
let navigationController = UINavigationController(rootViewController: userList)
navigationController.modalPresentationStyle = .fullScreen
userList.set(title: "Contacts", mode: .automatic)
self.present(navigationController, animated: true, completion: nil)

```

3. CometChatGroupList: 

CometChatGroupList is a subclass of UIViewController which displays list of groups.  Developer can launch this screen using below code snippet or assign the class to UIViewController to launch this activity. To display the title in `CometChatGroupList` please attach the UINavigationController to it. 

```
let groupList = CometChatGroupList()
let navigationController = UINavigationController(rootViewController: groupList)
navigationController.modalPresentationStyle = .fullScreen
groupList.set(title: "Groups", mode: .automatic)
self.present(navigationController, animated: true, completion: nil)

```

4. CometChatConversationList: 

CometChatConversationList is a subclass of UIViewController which displays list of recent conversations.  Developer can launch this screen using below code snippet or assign the class to UIViewController to launch this activity. To display the title in `CometChatConversationList` please attach the UINavigationController to it. 

```
let conversationList = CometChatConversationList()
let navigationController = UINavigationController(rootViewController: conversationList)
navigationController.modalPresentationStyle = .fullScreen
conversationList.set(title: "Chats", mode: .automatic)
self.present(navigationController, animated: true, completion: nil)

```

5. CometChatConversationList: 

CometChatConversationList is a subclass of UIViewController which displays list of recent conversations.  Developer can launch this screen using below code snippet or assign the class to UIViewController to launch this activity. To display the title in `CometChatConversationList` please attach the UINavigationController to it. 

```
let conversationList = CometChatConversationList()
let navigationController = UINavigationController(rootViewController: conversationList)
navigationController.modalPresentationStyle = .fullScreen
conversationList.set(title: "Chats", mode: .automatic)
self.present(navigationController, animated: true, completion: nil)

```


## UIComponents:

This will be the UI components dedicated to chat interface like Avatar, BadgeCount, StatusIndicator, ChatView, MessageBubbles etc. These Components will be highly customizable to meet users demand.

Kindly, [Click here](https://UIComponents doocumentation link here) to refer further documentation for UIComponents. 


5. [Troubleshoot](#Troubleshoot)

6. [Contributing](#Contributing) 



