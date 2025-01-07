//
//  CometChatUserEvents.swift
 
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatSDK
import Foundation

public class CometChatConversationEvents {
    
    static private var observer = NSMapTable<NSString, AnyObject>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    
    @objc public static func addListener(_ id: String, _ observer: CometChatConversationEventListener) {
        self.observer.setObject(observer, forKey: NSString(string: id))
    }
    
    @objc public static func removeListener(_ id: String) {
        self.observer.removeObject(forKey: NSString(string: id))
    }
    
    public static func ccConversationDeleted(conversation: Conversation) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatConversationEventListener {
            observer.ccConversationDeleted?(conversation: conversation)
        }
    }
}

//MARK: Deprecated Function
extension CometChatConversationEvents {
    
    @available(*, deprecated, message: "Use `ccConversationDeleted(conversation: Conversation)` instead")
    internal static func emitConversationDelete(conversation: Conversation) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatConversationEventListener {
            observer.onConversationDelete?(conversation: conversation)
        }
    }
}
