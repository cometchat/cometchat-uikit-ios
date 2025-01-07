//
//  File.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 15/06/24.
//

import Foundation
import CometChatSDK


public class CometChatUIEvents {
    
    static private var observer = NSMapTable<NSString, AnyObject>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    
    public static func addListener(_ id: String, _ observer: CometChatUIEventListener) {
        if let anyObject = observer as? AnyObject {
            self.observer.setObject(anyObject, forKey: NSString(string: id))
        }
    }
    
    public static func removeListener(_ id: String) {
        self.observer.removeObject(forKey: NSString(string: id))
    }
    
    public static func showPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.showPanel(id: id, alignment: alignment, view: view)
        }
    }
    
    public static func hidePanel(id: [String:Any]?, alignment: UIAlignment) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.hidePanel(id: id, alignment: alignment)
        }
    }
    
    public static func ccActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.ccActiveChatChanged(id: id, lastMessage: lastMessage, user: user, group: group)
        }
    }
    
    public static func openChat(user: User?, group: Group?) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.openChat(user: user, group: group)
        }
    }
    
    public static func ccComposeMessage(id: [String:Any]?, message: BaseMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.ccComposeMessage(id: id, message: message)
        }
    }
    
    public static func onAiFeatureTapped(user:User?, group:Group?) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.onAiFeatureTapped(user: user, group: group)
        }
    }
}

//MARK: Deprecated Functions
extension CometChatUIEvents {
    
    @available(*, deprecated, message: "Use `showPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?` instead")
    public static func emitShowPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.showPanel(id: id, alignment: alignment, view: view)
        }
    }
    
    @available(*, deprecated, message: "Use `ccActiveChatChanged(_ message: TransientMessage)` instead")
    public static func emitOnOpenChat(user: User?, group: Group?) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.openChat(user: user, group: group)
        }
    }
    
    @available(*, deprecated, message: "Use `ccActiveChatChanged(_ message: TransientMessage)` instead")
    public static func emitOnActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.onActiveChatChanged(id: id, lastMessage: lastMessage, user: user, group: group)
        }
    }
    
    @available(*, deprecated, message: "Use `emitHidePanel(id: [String:Any]?, alignment: UIAlignment)` instead")
    public static func emitHidePanel(id: [String:Any]?, alignment: UIAlignment) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.hidePanel(id: id, alignment: alignment)
        }
    }
    
    @available(*, deprecated, message: "This method is now deprecated")
    public static func emitCCMessageEdited(id: [String:Any]?, message: BaseMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            observer.ccComposeMessage(id: id, message: message)
        }
    }
    
}
