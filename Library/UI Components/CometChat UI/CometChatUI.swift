
//  CometChatUI.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChat UI : CometChat UI is a way to launch a fully working chat application using the UI Kit. In UI CometChat UI all the UI Screens and UI Components working together to give the full experience of a chat application with minimal coding effort.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

public enum Controller : String {
    case chats = "chats"
    case calls = "calls"
    case users = "users"
    case groups = "groups"
    case settings = "settings"
}


/// **CometChatUI**  is a way to launch a fully working chat application using the UI Kit. In CometChatUI all the UI Screens and UI Components working together to give the full experience of a chat application with minimal coding effort.
@objc  class CometChatUI: UITabBarController {
    
    // MARK: - Declaration of Variables
    
    // Declaration of UINavigationController's  to Embed CometChatConversationList, CometChatUserList, CometChatGroupList, CometChatUserProfile.
     let conversations = UINavigationController()
     let calls = UINavigationController()
     let users = UINavigationController()
     let groups = UINavigationController()
     let more = UINavigationController()
    
    //  Initialization of variables for UIScreens such as CometChatConversationList, CometChatUserList, CometChatGroupList, CometChatUserProfile.
    var conversationList:CometChatConversationList = CometChatConversationList()
    var callsList: CometChatCallsList = CometChatCallsList()
    var userList:CometChatUserList =  CometChatUserList()
    var groupList:CometChatGroupList = CometChatGroupList()
    var userInfo: CometChatUserProfile = CometChatUserProfile()
    
    
    // MARK: -  Methods
    
    /**
     This methods sets the UI Screens tabs for the view controllers which user wants to display in Tabbar.
     - Parameter controllers: This takes the array of UIScreens view controllers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUI Documentation](https://prodocs.cometchat.com/docs/ios-ui-unified)
     */
    @objc public func set(controllers: [UIViewController]?){
       
        // Adding Navigation controllers for view controllers.
        conversations.viewControllers = [conversationList]
        calls.viewControllers = [callsList]
        users.viewControllers = [userList]
        groups.viewControllers = [groupList]
        more.viewControllers = [userInfo]
      
        conversations.tabBarItem.image = UIImage(named: "cometchatui-chats.png", in: UIKitSettings.bundle, compatibleWith: nil)
        conversations.tabBarItem.title = "CHATS".localized()
        
        calls.tabBarItem.image = UIImage(named:"cometchatui-calls", in: UIKitSettings.bundle, compatibleWith: nil)
        calls.tabBarItem.title = "CALLS".localized()
        
        users.tabBarItem.image = UIImage(named:"cometchatui-users", in: UIKitSettings.bundle, compatibleWith: nil)
        users.tabBarItem.title = "USERS".localized()
        
        groups.tabBarItem.image = UIImage(named:"cometchatui-groups", in: UIKitSettings.bundle, compatibleWith: nil)
        groups.tabBarItem.title = "GROUPS".localized()
        
        more.tabBarItem.image = UIImage(named:"cometchatui-more", in: UIKitSettings.bundle, compatibleWith: nil)
        more.tabBarItem.title = "MORE".localized()
        
     
        // Setting title and  LargeTitleDisplayMode for view controllers.
        
        conversationList.set(title: "CHATS".localized(), mode: .automatic)
        callsList.set(title: "CALLS".localized(), mode: .automatic)
        userList.set(title: "USERS".localized(), mode: .automatic)
        groupList.set(title: "GROUPS".localized(), mode: .automatic)
        userInfo.set(title: "MORE".localized(), mode: .automatic)
        
        self.tabBar.tintColor = UIKitSettings.primaryColor
        self.tabBar.unselectedItemTintColor = UIKitSettings.secondaryColor
        
        
//        Assigning Calling Delegate
//        CometChat.calldelegate = self
        
        // Adding view controllers in Tabbar
        self.viewControllers = controllers
    }
    
    
    
    /**
     This methods provides the modalPresentationStyle to display CometChatUI such as `.fullSreen` or `.popover`.
     -  Parameter withStyle: Specifies the  modalPresentationStyle to display CometChatUI such as `.fullSreen` or `.popover`
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUI Documentation](https://prodocs.cometchat.com/docs/ios-ui-unified)
     */
    @objc public func setup(withStyle: UIModalPresentationStyle){
        self.modalPresentationStyle = withStyle
        var controllers = [UIViewController]()

        for tab in UIKitSettings.tabs {
            
            FeatureRestriction.isRecentChatListEnabled { (success) in
                switch success {
                case .enabled where tab == .chats: controllers.append(self.conversations)
                case .disabled, .enabled: break
                }
            }
            
            FeatureRestriction.isCallListEnabled { (success) in
                switch success {
                case .enabled where tab == .calls: controllers.append(self.calls)
                case .disabled, .enabled: break
                }
            }
            
            FeatureRestriction.isUserListEnabled { (success) in
                switch success {
                case .enabled where tab == .users: controllers.append(self.users)
                case .disabled, .enabled: break
                }
            }
            
            FeatureRestriction.isGroupListEnabled { (success) in
                switch success {
                case .enabled where tab == .groups: controllers.append(self.groups)
                case .disabled, .enabled: break
                }
            }

            FeatureRestriction.isUserSettingsEnabled { (success) in
                switch success {
                case .enabled where tab == .settings: controllers.append(self.more)
                case .disabled, .enabled: break
                }
            }
        }
        
        set(controllers: controllers)
    }
}

/*  ----------------------------------------------------------------------------------------- */
