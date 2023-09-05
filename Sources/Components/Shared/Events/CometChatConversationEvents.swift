//
//  CometChatUserEvents.swift
 
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatSDK
import Foundation


@objc public protocol CometChatConversationEventListener {
    
    @objc optional func onConversationDelete(conversation: Conversation)
    @objc optional func onStartConversationClick()
    
}

public class CometChatConversationEvents {
    
    static private var observer = [String: CometChatConversationEventListener]()
    
    @objc public static func addListener(_ id: String,_ observer: CometChatConversationEventListener) {
        self.observer[id] = observer
    }
    
    @objc public static func removeListener(_ id: String) {
        self.observer.removeValue(forKey: id)
    }
    
    internal static  func emitStartConversationClick() {
        self.observer.forEach({
            (key,observer) in
            observer.onStartConversationClick?()
        })
    }
    
    internal static  func emitConversationDelete(conversation: Conversation) {
        self.observer.forEach({
            (key,observer) in
            observer.onConversationDelete?(conversation: conversation)
        })
    }

}
