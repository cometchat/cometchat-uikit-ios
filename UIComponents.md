

# UI Components

![Studio Guide](https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/UIComponents.png)

**UI Components** are building a block of the **CometChat Kitchen Sink**. **UI Components** are set of custom classes specially designed to build a rich chat app. To achieve high customizability while building an app one can use the UI Components. There are different UI Components available in the **CometChat Kitchen Sink** library.

---
## 1. Avtar

<p align="center"><img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/avatar.png"></p>    


This component will be the class of UIImageView which is customizable to display Avatar. This view has the following custom parameters:

| **Sr. No.**| **Parameter** | **Description** |
| :---: | :---: | :--- |
|1 | Corner Radius | This field specifies the shape for Avtar. |
|2 | Image URL  | This will take Image url and load the corresponding url |
|3 | Border Width | This will accept Int number as parameter.  |
|4 | Border Color | This will accept UIColor as parameter. |

This class can be modified programatically using below methods: 

| **Attributes** | **Methods** |
| :---: | :--- |
| Shape | `set(cornerRadius: CGFloat)` |
| Avtar  | `set(image: URL)` |
| Border Width | `set(borderWidth: CGFloat)` |
| Border Color | `set(borderColor: UIColor)` |

Developer can use this class by assigning it to the UIImageView and modify it as follows: 

```
avtar.set(borderWidth: 5)
     .set(borderColor: .systemGray)
     .set(cornerRadius: 20)
     .set(image: "https://randomuser.me/api/portraits/men/22.jpg")
```
<br>

---

<br>


## 2. Status Indicator 

<p align="center"><img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/statusIndicator.png"></p>    

This component will be the class of UIImageView which is customizable to display the status of the user. This view has the following custom parameters:

| **Sr. No.**| **Parameter** | **Description** |
| :---: | :---: | :--- |
|1 | Corner Radius | This can be Int number which will define a status indicator shape according to radius. |
|2 | Color | This will accept UIColor as parameter and set the color for Status indicator. |
|3 | Border Width | This will accept Int number as parameter.  |
|4 | Border Color | This will accept UIColor as parameter. |
|5 | Status | This will accept CometChatPro.CometChat.UserStatus as a parameter and set the appropriate color automatically as per user status i.e. online/offline. |

This class can be modified programatically using below methods: 

| **Attributes** | **Methods** |
| :---: | :--- |
| Shape | `set(cornerRadius: CGFloat)` |
| Background Color  | `set(backgroundColor: UIColor)` |
| Border Width | `set(borderWidth: CGFloat)` |
| Border Color | `set(borderColor: UIColor)` |
| Status | `set(status: CometChatPro.CometChat.UserStatus)` |


Developer can use this class by assigning it to the UIImageView and modify it as follows: 

```
statusIndicator.set(cornerRadius: 10)
               .set(borderColor: .white)
	       .set(borderWidth: 2) 
	       .set(status: .online)
```
<br>

---

<br>

## 3. Badge Count 

<p align="center"><img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/badgeCount.png"></p>

This component will be the class of UILabel which is customizable to display the unread message count for conversations. This view has the following custom parameters:

| **Sr. No.**| **Parameter** | **Description** |
| :---: | :---: | :--- |
|1 | Count | This can be Int number which sets the count for Badge |
|2 | Background Color | This will accept UIColor as parameter and set the color for Badge Count. |
|3 | Border Width | This will accept Int number as parameter.  |
|4 | Border Color | This will accept UIColor as parameter. |

This class can be modified programatically using below methods: 

| **Attributes** | **Methods** |
| :---: | :--- |
| Count | `set(count : Int) ` |
| Background Color  | `set(backgroundColor: UIColor)` |
| Border Width | `set(borderWidth: CGFloat)` |
| Border Color | `set(borderColor: UIColor)` |


Developer can use this class by assigning it to the UIImageView and modify it as follows: 

```
badgeCount.set(count: 10)
	  .set(borderColor: .white)
	  .set(borderWidth: 2)
	  .set(backgroundColor: .red)
```
<br>

---

<br>



## 4. UserView

<p align="center"><img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/userView.png"></p>

This component will be the class of UITableViewCell with components such as userAvtar(Avtar), userName(UILabel).

Developer can use this  in `tableView` by registering the cell in 'viewDidLoad()' as below: 

```
let userView  = UINib.init(nibName: "CometChatUserView", bundle: nil)
self.tableView.register(userView, forCellReuseIdentifier: "userView")
```

And then pass the `User` object and  reuse it in 'cellForRowAt' :

```
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let userCell = tableView.dequeueReusableCell(withIdentifier: "userView", for: indexPath) as! CometChatUserView
 let user = users[indexPath.row]
     userCell.user = user
     return userCell
 }
```

---

<br>



## 5. GroupView

<p align="center"><img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/groupView.png"></p>

This component will be the class of UITableViewCell with components such as groupAvtar(Avtar),  groupName(UILabel), groupDetails(UILabel). 

Developer can use this  in `tableView` by registering the cell in 'viewDidLoad()' as below: 

```
let groupView  = UINib.init(nibName: "CometChatGroupView", bundle: nil)
self.tableView.register(groupView, forCellReuseIdentifier: "groupView")
```

And then pass the `Group` object and  reuse it in 'cellForRowAt' :

```
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 let groupCell = tableView.dequeueReusableCell(withIdentifier: "groupView", for: indexPath) as! CometChatGroupView 
 let group = groups[indexPath.row]
     groupCell.group = group
     return groupCell
 }
```

---

<br>

## 6. ConversationView

<p align="center"><img align="center" width="180" height="180" alt="" src="https://github.com/cometchat-pro/ios-chat-uikit/blob/master/Screenshots/conversationView.png"></p>

This component will be the class of UITableViewCell with components such as groupAvtar(Avtar),  groupName(UILabel), groupDetails(UILabel). 

Developer can use this  in `tableView` by registering the cell in 'viewDidLoad()' as below: 

```
let conversationView  = UINib.init(nibName: "CometChatConversationView", bundle: nil)
self.tableView.register(conversationView, forCellReuseIdentifier: "conversationView")
```

And then pass the `Conversation` object and  reuse it in 'cellForRowAt' :

```
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversationCell = tableView.dequeueReusableCell(withIdentifier: "conversationView", for: indexPath) as! CometChatConversationView
        let conversation = conversations[indexPath.row]
        conversationCell.conversation = conversation
        return conversationCell
    }
```

---

<br>
