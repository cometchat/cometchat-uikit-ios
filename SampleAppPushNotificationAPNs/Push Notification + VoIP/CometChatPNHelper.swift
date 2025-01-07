//
//  CometChatPNHelper.swift
//  CometChatPushNotification
//
//  Created by Sandesh on 20/05/24.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift

class CometChatPNHelper {
    
    let cometchatAPNsHelper = CometChatAPNsHelper()
    static var currentActiveUser: CometChatSDK.User?
    static var currentActiveGroup: CometChatSDK.Group?

    static func handleTapActionOnNotification(userInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        guard let notificationType = userInfo["type"] as? String,
              let receiverType = userInfo["receiverType"] as? String else {
            print("Notification type or receiver type not found in payload")
            completionHandler()
            return
        }
        
        switch notificationType {
        case "chat":
            if receiverType == "user" {
                handleChatNotification(userInfo: userInfo)
            } else if receiverType == "group" {
                handleGroupChatNotification(userInfo: userInfo)
            } else {
                print("Invalid receiver type for chat notification")
            }
            
        case "call":
            if receiverType == "user" {
                handleChatNotification(userInfo: userInfo)
            } else if receiverType == "group" {
                handleGroupChatNotification(userInfo: userInfo)
            } else {
                print("Invalid receiver type for call notification")
            }
            
        default:
            navigateToDefaultScreen()
        }
        
        completionHandler()
    }
    
    static func handleQuickReplyActionOnNotification(userInfo: [AnyHashable: Any], text: String, completionHandler: @escaping () -> Void) {
        guard let notificationType = userInfo["type"] as? String,
              let receiverType = userInfo["receiverType"] as? String else {
            print("Notification type or receiver type not found in payload")
            completionHandler()
            return
        }
        
        switch notificationType {
        case "chat":
            if receiverType == "user" {
                replyToUserWith(message: text, userInfo: userInfo)
            } else if receiverType == "group" {
                replyToGroupWith(message: text, userInfo: userInfo)
            } else {
                print("Invalid receiver type for chat notification")
            }
        default:
            break
        }
        
        completionHandler()
    }

    static func navigateToViewController(_ viewController: UIViewController) {
        
        guard let window = UIApplication.shared.windows.first else {
            print("Window not found")
            return
        }
        
        if let navigationController = window.rootViewController as? UINavigationController {
            if let currentViewController = navigationController.viewControllers.last,
               currentViewController.description == viewController.description {
                print("Already in same view")
                return
                
            }
            navigationController.popViewController(animated: false)
            navigationController.pushViewController(viewController, animated: false)
        } else {
            print("Root view controller is not a UINavigationController")
        }
        
    }
    
    static func replyToUserWith(message text: String, userInfo: [AnyHashable: Any], withParentId: Int? = nil) {
        guard let sender = userInfo["sender"] as? String,
              let senderName = userInfo["senderName"] as? String else {
            print("Sender information missing in payload")
            return
        }
        
        let textMessage = TextMessage(receiverUid: sender, text: text, receiverType: .user)
        if let parentID = withParentId {
            textMessage.parentMessageId = parentID
        }
        CometChatUIKit.sendTextMessage(message: textMessage)
    }
    
    static func replyToGroupWith(message text: String, userInfo: [AnyHashable: Any], withParentId: Int? = nil) {
        guard let groupID = userInfo["receiver"] as? String,
              let groupName = userInfo["receiverName"] as? String else {
            print("Group information missing in payload")
            return
        }
                
        let textMessage = TextMessage(receiverUid: groupID, text: text, receiverType: .group)
        if let parentID = withParentId {
            textMessage.parentMessageId = parentID
        }
        CometChatUIKit.sendTextMessage(message: textMessage)
    }
    
    static func handleChatNotification(userInfo: [AnyHashable: Any]) {
        guard let sender = userInfo["sender"] as? String,
              let senderName = userInfo["senderName"] as? String else {
            print("Sender information missing in payload")
            return
        }
        
        let senderUser = User(uid: sender, name: senderName)
        senderUser.avatar = userInfo["senderAvatar"] as? String
        
        getUser(forUID: sender) { retrievedUser in
            DispatchQueue.main.async {
                if let user = retrievedUser {
                    senderUser.status = user.status
                } else {
                    print("Failed to retrieve user status")
                }
                
                let chatViewController = MessagesVC()
                chatViewController.user = retrievedUser
                self.navigateToViewController(chatViewController)
            }
            
        }
    }
    
    
    static func handleGroupChatNotification(userInfo: [AnyHashable: Any]) {
        guard let groupID = userInfo["receiver"] as? String,
              let groupName = userInfo["receiverName"] as? String else {
            print("Group information missing in payload")
            return
        }
        
        let groupUser = Group(guid: groupID, name: groupName, groupType: .private, password: nil)
        
        self.getGroup(for: groupUser, guid: groupID) { fetchedGroup in
            DispatchQueue.main.async {
                if let group = fetchedGroup {
                    groupUser.membersCount = group.membersCount
                    groupUser.icon = group.icon
                } else {
                    print("Failed to fetch group members count")
                }
                let chatViewController = MessagesVC()
                chatViewController.group = fetchedGroup
                self.navigateToViewController(chatViewController)
            }
        }
    }
    
    static func handleCallNotification(userInfo: [AnyHashable: Any]) {
        guard let sender = userInfo["sender"] as? String,
              let senderName = userInfo["senderName"] as? String else {
            print("Sender information missing in payload")
            return
        }
        
        let user = User(uid: sender, name: senderName)
        user.avatar = userInfo["senderAvatar"] as? String
        DispatchQueue.main.async {
            let callViewController = MessagesVC()
            callViewController.user = user
            CometChatPNHelper.navigateToViewController(callViewController)
        }
    }
    
    static func handleGroupCallNotification(userInfo: [AnyHashable: Any]) {
        guard let groupID = userInfo["receiver"] as? String,
              let groupName = userInfo["receiverName"] as? String else {
            print("Group information missing in payload")
            return
        }
        
        let groupUser = Group(guid: groupID, name: groupName, groupType: .private, password: nil)
        groupUser.icon = userInfo["receiverAvatar"] as? String
        DispatchQueue.main.async {
            
            let callViewController = MessagesVC()
            callViewController.group = groupUser
            CometChatPNHelper.navigateToViewController(callViewController)
        }
    }
    
    static func navigateToDefaultScreen() {
        DispatchQueue.main.async {
            let defaultViewController = HomeScreenViewController()
            
            guard let window = UIApplication.shared.windows.first else {
                print("Window not found")
                return
            }
            
            if let navigationController = window.rootViewController as? UINavigationController {
                navigationController.pushViewController(defaultViewController, animated: true)
            } else {
                print("Root view controller is not a UINavigationController")
            }
        }
    }
    static func getUser(forUID uid: String, completionHandler: @escaping (CometChatSDK.User?) -> Void) {
        CometChat.getUser(UID: uid, onSuccess: { user in
            let user = user
            completionHandler(user)
        }) { error in
            print("User fetching failed with error: \(error?.errorDescription ?? "Unknown error")")
            completionHandler(nil)
        }
    }
    
    static func getGroup(for group: Group, guid: String, completionHandler: @escaping (Group?) -> Void) {
        CometChat.getGroup(GUID: guid, onSuccess: { fetchedGroup in
            completionHandler(fetchedGroup)
        }) { error in
            print("Group details fetching failed with error: \(error?.errorDescription ?? "Unknown error")")
            completionHandler(nil)
        }
    }
    
    static func shouldPresentNotification(userInfo: [AnyHashable: Any]) -> Bool {
        guard let notificationType = userInfo["type"] as? String,
              let receiverType = userInfo["receiverType"] as? String else {
            return true
        }
        
        if notificationType == "chat" {
            if receiverType == "user" {
                let sender = userInfo["sender"] as? String
                if sender == CometChatPNHelper.currentActiveUser?.uid {
                    return false
                }
            } else if receiverType == "group" {
                let receiver = userInfo["receiver"] as? String
                if receiver == CometChatPNHelper.currentActiveGroup?.guid {
                    return false
                }
            }
        }
        
        return true
    }
}
