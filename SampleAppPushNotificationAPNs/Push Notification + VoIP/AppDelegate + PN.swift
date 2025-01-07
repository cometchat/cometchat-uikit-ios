//
//  AppDelegate + CometChatPN.swift
//  CometChatPushNotification
//
//  Created by SuryanshBisen on 05/09/23.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatUIKitSwift

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    
    //Registering PN Token on CometChat server
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        if CometChat.getLoggedInUser() != nil {
            cometchatAPNsHelper.registerTokenForPushNotification(deviceToken: deviceToken)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("willPresent notification: \(notification.request.content.userInfo)")
        let userInfo = notification.request.content.userInfo
        
        if CometChatPNHelper.shouldPresentNotification(userInfo: userInfo) == false {
            completionHandler([])
            return
        }
        
        completionHandler([.alert, .badge, .sound])
        
    }

    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo

        if response.actionIdentifier == "REPLY_ACTION" {
            if let textResponse = response as? UNTextInputNotificationResponse {
                let userReply = textResponse.userText
                CometChatPNHelper.handleQuickReplyActionOnNotification(userInfo: userInfo, text: userReply, completionHandler: completionHandler)
            }
            completionHandler()
            return
        }
        
        CometChatPNHelper.handleTapActionOnNotification(userInfo: userInfo, completionHandler: completionHandler)
    }
}
