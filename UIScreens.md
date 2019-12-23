
# UI Screens

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/UIScreens.png) 

 CometChat Kitchen Sink provides list of screens by using which developer can create screens like User List, Group List, Conversation List, Message List etc. These screens will be the class of UIViewController. These screens can be easily integrated into any view or view controller with minimal efforts. There are different screens available in **UI-KIT**.

 ---

## 1. ComeChatUserList

The `ComeChatUserList` is a view controller with a List of users. The view controller has all the necessary delegates and methods.

 User can present this screen using two methods. 

 1. Launch User List:

 ```
let userList = CometChatUserList()
let navigationController: UINavigationController = UINavigationController(rootViewController: userList)
userList.set(title: "Contacts", mode: .automatic)
self.present(navigationController, animated: true, completion: nil)

```

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/CometChatUserList.gif)

2. Assign User List to View Controller:

To assign user list to view controller make sure that Navigation controller is attached properly. A developer can use this  by subclassing UIViewController as  `CometChatUserList` as shown below:

```
class viewController: CometChatUserList {

override func viewDidLoad() {
      super.viewDidLoad()
		  self.delegate = self
	}

}
```
Also,  he can perform an action on tap on the user by adding `UserListDelegate` in the app's view controller  as shown below: 

```
extension viewController: UserListDelegate {
    
func didSelectUserAtIndexPath(user: User, 
indexPath: IndexPath) {
        //Do Stuff
    }  
}
```
<br>


---

<br>

## 2. ComeChatGroupList

The `CometChatGroupList` is a view controller with a List of groups. The view controller has all the necessary delegates and methods. 

User can present this screen using two methods. 

 1. Launch Group List:

 ```
let groupList = CometChatGroupList()
let navigationController: UINavigationController = UINavigationController(rootViewController: groupList)
groupList.set(title: "Groups", mode: .automatic)
self.present(navigationController, animated: true, completion: nil)

```

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/CometChatGroupList.gif)

2. Assign Group List to View Controller:

To assign Group list to view controller make sure that Navigation controller is attached properly. A developer can use this  by subclassing UIViewController as  `CometChatGroupList` as shown below:

```
class viewController: CometChatGroupList {

override func viewDidLoad() {
      super.viewDidLoad()
		  self.delegate = self
	}
}
```
Also,  he can perform an action on tap on the group by adding `GroupListDelegate` in the app's view controller  as shown below: 

```
extension viewController: GroupListDelegate {
    
func didSelectGroupAtIndexPath(group: Group, 
   indexPath: IndexPath)
        //Do Stuff
    }  
}
```
<br>

---
<br>

## 3. ComeChatConversationList

The `ComeChatConversationList` is a view controller with a List of recent conversations. The view controller has all the necessary delegates and methods. 

User can present this screen using two methods. 

 1. Launch Conversation List:

 ```
let conversationList = CometChatConversationList()
let navigationController: UINavigationController = UINavigationController(rootViewController: conversationList)
conversationList.set(title: "Chats", mode: .automatic)
self.present(navigationController, animated: true, completion: nil)

```

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/CometChatConversationList.gif)

2. Assign Conversation List to View Controller:

To assign Conversation list to view controller make sure that Navigation controller is attached properly. A developer can use this by subclassing UIViewController as  `CometChatConversationList` as shown below:

```
class viewController: CometChatConversationList {

override func viewDidLoad() {
      super.viewDidLoad()
		  self.delegate = self
	}

}
```

Also, he can perform an action on tap on the conversation by adding `ConversationListDelegate` in the app's view controller  as shown below: 

```
extension viewController: ConversationListDelegate {
    
func didSelectConversationAtIndexPath(conversation: Conversation, indexPath: IndexPath){
        //Do Stuff
    }  
}
```

<br>

---


<br>

## 4. CometChatMessageList

The `CometChatMessageList` is a view controller with a List of messages for perticular user or group. The view controller has all the necessary delegates and methods. 

`CometChatMessageList` requires `User` or `Group` object to work properly. 

User can present this screen using two methods. 

 1. Launch Message List:

```
let messageList = CometChatMessageList()
let navigationController = UINavigationController(rootViewController: messageList)
messageList.set(conversationWith: user, type: .user)
self.present(navigationController, animated: true, completion: nil)

```

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/CometChatMessageList.gif)

2. Assign Message List to View Controller:

To assign Message list to view controller make sure that Navigation controller is attached properly. A developer can use this by subclassing UIViewController as  `CometChatMessageList` as shown below:

```
class viewController: CometChatMessageList {

override func viewDidLoad() {
      super.viewDidLoad()
		  set(conversationWith: user, type: .user)
	}
}
```
<br>

---


<br>

## 5. CometChatUserInfo

The `CometChatUserInfo` is a view controller with a user information and list of dummy cells for settings of the app which developer can user in his app. 


User can present this screen using two methods. 

 1. Launch User Info :

```
let userInfo = CometChatUserInfo()
 let navigationController = 
 UINavigationController(rootViewController: userInfo)
 userInfo.set(title: “More”, mode: .automatic)
self.present(navigationController, animated: true, completion: nil)
}

```

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/CometChatUserInfo.gif)

2. Assign Message List to View Controller:

To assign Message list to view controller make sure that Navigation controller is attached properly. A developer can use this by subclassing UIViewController as  `CometChatMessageList` as shown below:

```
class viewController: CometChatUserInfo {

override func viewDidLoad() {
      super.viewDidLoad()
		 
	}
}
```
<br>

---


<br>