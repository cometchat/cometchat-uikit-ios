//
//  CometChatUserEvents.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatPro
import Foundation


@objc public protocol CometChatConversationEventListner {
    
    func onItemClick(conversation: Conversation, index: IndexPath?)
    func onItemLongClick(conversation: Conversation, index: IndexPath?)
    func onConversationDelete(conversation: Conversation)
    func onStartConversationClick()
    func onError(conversation: Conversation?, error: CometChatException)
    
}

public class CometChatConversationEvents {
    
    static private var observer = [String: CometChatConversationEventListner]()
    
    @objc public static func addListener(_ id: String,_ observer: CometChatConversationEventListner) {
        self.observer[id] = observer
    }
    
    @objc public static func removeListner(_ id: String) {
        self.observer.removeValue(forKey: id)
    }
    
    
    internal static  func emitOnItemClick(converation: Conversation, index: IndexPath?) {
        self.observer.forEach({
            (key,observer) in
            observer.onItemClick(conversation: converation, index: index)
        })
    }
    
    internal static  func emitOnItemLongClick(converation: Conversation, index: IndexPath?) {
        self.observer.forEach({
            (key,observer) in
            observer.onItemLongClick(conversation: converation, index: index)
        })
    }
    
    internal static  func emitStartConversationClick() {
        self.observer.forEach({
            (key,observer) in
            observer.onStartConversationClick()
        })
    }
    
    internal static  func emitConversationDelete(conversation: Conversation) {
        self.observer.forEach({
            (key,observer) in
            observer.onConversationDelete(conversation: conversation)
        })
    }
    
    
    internal static  func emitOnError(conversation: Conversation?, error: CometChatException) {
        self.observer.forEach({
            (key,observer) in
            observer.onError(conversation: conversation, error: error)
        })
    }
  
}
