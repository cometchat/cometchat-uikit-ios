
//  CometChatUnified.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 UI Unified : UI Unified is a way to launch a fully working chat application using the UI Kit. In UI Unified all the UI Screens and UI Components working together to give the full experience of a chat application with minimal coding effort.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

 enum Controller {
    case conversations
    case calls
    case users
    case groups
    case moreInfo
}


/// **CometChatUnified**  is a way to launch a fully working chat application using the UI Kit. In UI Unified all the UI Screens and UI Components working together to give the full experience of a chat application with minimal coding effort.
@objc  class CometChatUnified: UITabBarController {
    
    // MARK: - Declaration of Variables
    
    // Declaration of UINavigationController's  to Embed CometChatConversationList, CometChatUserList, CometChatGroupList, CometChatUserInfo.
     let conversations = UINavigationController()
     let calls = UINavigationController()
     let users = UINavigationController()
     let groups = UINavigationController()
     let more = UINavigationController()
    
    //  Initialization of variables for UIScreens such as CometChatConversationList, CometChatUserList, CometChatGroupList, CometChatUserInfo.
    var conversationList:CometChatConversationList = CometChatConversationList()
    var callsList: CometChatCallsList = CometChatCallsList()
    var userList:CometChatUserList =  CometChatUserList()
    var groupList:CometChatGroupList = CometChatGroupList()
    var userInfo: CometChatUserInfo = CometChatUserInfo()
    
    
    // MARK: -  Methods
    
    /**
     This methods sets the UI Screens tabs for the view controllers which user wants to display in Tabbar.
     - Parameter controllers: This takes the array of UIScreens view controllers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [UI Unified Documentation](https://prodocs.cometchat.com/docs/ios-ui-unified)
     */
    @objc  func set(controllers: [UIViewController]?){
        // Loading the fonts which required for the application.
        // UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        //UIFont.loadMyFonts
        
        // Adding Navigation controllers for view controllers.
        conversations.viewControllers = [conversationList]
        calls.viewControllers = [callsList]
        users.viewControllers = [userList]
        groups.viewControllers = [groupList]
        more.viewControllers = [userInfo]
      
        conversations.tabBarItem.image = UIImage(named: "chats.png", in: UIKitSettings.bundle, compatibleWith: nil)
        conversations.tabBarItem.title = NSLocalizedString("CHATS", bundle: UIKitSettings.bundle, comment: "")
        
        calls.tabBarItem.image = UIImage(named:"calls", in: UIKitSettings.bundle, compatibleWith: nil)
        calls.tabBarItem.title = NSLocalizedString("CALLS", bundle: UIKitSettings.bundle, comment: "")
        
        users.tabBarItem.image = UIImage(named:"contacts", in: UIKitSettings.bundle, compatibleWith: nil)
        users.tabBarItem.title = NSLocalizedString("CONTACTS", bundle: UIKitSettings.bundle, comment: "")
        
        groups.tabBarItem.image = UIImage(named:"groups", in: UIKitSettings.bundle, compatibleWith: nil)
        groups.tabBarItem.title = NSLocalizedString("GROUPS", bundle: UIKitSettings.bundle, comment: "")
        
        more.tabBarItem.image = UIImage(named:"more", in: UIKitSettings.bundle, compatibleWith: nil)
        more.tabBarItem.title = NSLocalizedString("MORE", bundle: UIKitSettings.bundle, comment: "")
        
        //
        // Setting title and  LargeTitleDisplayMode for view controllers.
        
        conversationList.set(title: NSLocalizedString("CHATS", bundle: UIKitSettings.bundle, comment: ""), mode: .automatic)
        callsList.set(title: NSLocalizedString("CALLS", bundle: UIKitSettings.bundle, comment: ""), mode: .automatic)
        userList.set(title: NSLocalizedString("CONTACTS", bundle: UIKitSettings.bundle, comment: ""), mode: .automatic)
        groupList.set(title: NSLocalizedString("GROUPS", bundle: UIKitSettings.bundle, comment: ""), mode: .automatic)
        userInfo.set(title: NSLocalizedString("MORE", bundle: UIKitSettings.bundle, comment: ""), mode: .automatic)
        
        let color = UIKitSettings.primaryColor
        self.tabBar.tintColor = color
        
//        //Assigning Calling Delegate
//        CometChat.calldelegate = self
        
        // Adding view controllers in Tabbar
        self.viewControllers = controllers
    }
    
    
    
    /**
     This methods provides the modalPresentationStyle to display UI Unified such as `.fullSreen` or `.popover`.
     -  Parameter withStyle: Specifies the  modalPresentationStyle to display UI Unified such as `.fullSreen` or `.popover`
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [UI Unified Documentation](https://prodocs.cometchat.com/docs/ios-ui-unified)
     */
    @objc  func setup(withStyle: UIModalPresentationStyle){
        self.modalPresentationStyle = withStyle
        var controllers = [UIViewController]()
        
        if UIKitSettings.conversations == .enabled {
            controllers.append(conversations)
        }
        
        if UIKitSettings.calls == .enabled {
            controllers.append(calls)
        }
        
        if UIKitSettings.groups == .enabled {
            controllers.append(groups)
        }
        
        if UIKitSettings.users == .enabled && UIKitSettings.userInMode != .none {
            controllers.append(users)
        }
        
        if UIKitSettings.userSettings == .enabled {
            controllers.append(more)
        }
        
        set(controllers: controllers)
    }
}

/*  ----------------------------------------------------------------------------------------- */
