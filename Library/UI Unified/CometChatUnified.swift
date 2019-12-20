
//  CombinedList.swift
//  CometChatUIKitDemo
//
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.


import UIKit

class CometChatUnified: UITabBarController {
    
    public let conversations = UINavigationController()
    public let users = UINavigationController()
    public let groups = UINavigationController()
    public let more = UINavigationController()
    
    
    var conversationList:CometChatConversationList = CometChatConversationList()
    var userList:CometChatUserList =  CometChatUserList()
    var groupList:CometChatGroupList = CometChatGroupList()
    var userInfo: CometChatUserInfo = CometChatUserInfo()

    
    @objc public func set(controllers: [UIViewController]?){
         UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        // Adding Navigation controllers for view controllers.
        conversations.viewControllers = [conversationList]
        users.viewControllers = [userList]
        groups.viewControllers = [groupList]
        more.viewControllers = [userInfo]
        
        
        // Setting title and icons for Tabbar
        if #available(iOS 13.0, *) {
            conversations.tabBarItem.image = #imageLiteral(resourceName: "chats")
            conversations.tabBarItem.title = "Chats"
            
            users.tabBarItem.image = #imageLiteral(resourceName: "contacts")
            users.tabBarItem.title = "Contacts"
            
            groups.tabBarItem.image = #imageLiteral(resourceName: "groups")
            groups.tabBarItem.title = "Groups"
            
            more.tabBarItem.image = #imageLiteral(resourceName: "more")
            more.tabBarItem.title = "More"
        } else {}
        
        // Setting title and  LargeTitleDisplayMode for view controllers.
        conversationList.set(title: "Chats", mode: .automatic)
        userList.set(title: "Contacts", mode: .automatic)
        groupList.set(title: "Groups", mode: .automatic)
        userInfo.set(title: "More", mode: .automatic)
        
        
        // Adding view controllers in Tabbar
        self.viewControllers = controllers
    }
    
    @objc public func setup(withStyle: UIModalPresentationStyle){
        self.modalPresentationStyle = withStyle
        set(controllers: [conversations,users,groups, more])
    }
    
}
