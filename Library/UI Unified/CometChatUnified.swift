
//  CometChatUnified.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 UI Unified : UI Unified is a way to launch a fully working chat application using the UI Kit. In UI Unified all the UI Screens and UI Components working together to give the full experience of a chat application with minimal coding effort.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

/// **CometChatUnified**  is a way to launch a fully working chat application using the UI Kit. In UI Unified all the UI Screens and UI Components working together to give the full experience of a chat application with minimal coding effort.
@objc public class CometChatUnified: UITabBarController {
    
    // MARK: - Declaration of Variables
    
    // Declaration of UINavigationController's  to Embed CometChatConversationList, CometChatUserList, CometChatGroupList, CometChatUserInfo.
    public let conversations = UINavigationController()  
    public let users = UINavigationController()
    public let groups = UINavigationController()
    public let more = UINavigationController()
    
    //  Initialization of variables for UIScreens such as CometChatConversationList, CometChatUserList, CometChatGroupList, CometChatUserInfo.
    var conversationList:CometChatConversationList = CometChatConversationList()
    var userList:CometChatUserList =  CometChatUserList()
    var groupList:CometChatGroupList = CometChatGroupList()
    var userInfo: CometChatUserInfo = CometChatUserInfo()
    
    
    // MARK: - Public Methods
    
    /**
     This methods sets the UI Screens tabs for the view controllers which user wants to display in Tabbar.
     - Parameter controllers: This takes the array of UIScreens view controllers.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [UI Unified Documentation](https://prodocs.cometchat.com/docs/ios-ui-unified)
     */
    @objc public func set(controllers: [UIViewController]?){
        
        // Loading the fonts which required for the application.
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        
        // Adding Navigation controllers for view controllers.
        conversations.viewControllers = [conversationList]
        users.viewControllers = [userList]
        groups.viewControllers = [groupList]
        more.viewControllers = [userInfo]
        
        // Setting title and icons for Tabbar
        if #available(iOS 11.0, *) {
            conversations.tabBarItem.image = #imageLiteral(resourceName: "chats")
            conversations.tabBarItem.title = "Chats"
            
            users.tabBarItem.image = #imageLiteral(resourceName: "contacts")
            users.tabBarItem.title = "Contacts"
            
            groups.tabBarItem.image = #imageLiteral(resourceName: "groups")
            groups.tabBarItem.title = "Groups"
            
            more.tabBarItem.image = #imageLiteral(resourceName: "more")
            more.tabBarItem.title = "More"
        } 
        
        // Setting title and  LargeTitleDisplayMode for view controllers.
        conversationList.set(title: "Chats", mode: .automatic)
        userList.set(title: "Contacts", mode: .automatic)
        groupList.set(title: "Groups", mode: .automatic)
        userInfo.set(title: "More", mode: .automatic)
        
        // Adding view controllers in Tabbar
        self.viewControllers = controllers
    }
    
    
    /**
     This methods provides the modalPresentationStyle to display UI Unified such as `.fullSreen` or `.popover`.
     -  Parameter withStyle: Specifies the  modalPresentationStyle to display UI Unified such as `.fullSreen` or `.popover`
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [UI Unified Documentation](https://prodocs.cometchat.com/docs/ios-ui-unified)
     */
    @objc public func setup(withStyle: UIModalPresentationStyle){
        self.modalPresentationStyle = withStyle
        set(controllers: [conversations,users,groups, more])
    }
}
 
/*  ----------------------------------------------------------------------------------------- */


