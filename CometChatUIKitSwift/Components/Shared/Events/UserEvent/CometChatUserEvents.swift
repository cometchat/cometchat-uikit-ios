//
//  CometChatUserEvents.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 16/06/24.
//

import Foundation
import CometChatSDK

public class CometChatUserEvents {
    
    static private var observer = NSMapTable<NSString, AnyObject>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    
    @objc public static func addListener(_ id: String, _ observer: CometChatUserEventListener) {
        self.observer.setObject(observer, forKey: NSString(string: id))
    }
    
    @objc public static func removeListener(_ id: String) {
        self.observer.removeObject(forKey: NSString(string: id))
    }
    
    public static func ccUserBlocked(user: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUserEventListener {
            observer.ccUserBlocked?(user: user)
        }
    }
    
    public static func ccUserUnblocked(user: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUserEventListener {
            observer.ccUserUnblocked?(user: user)
        }
    }
    
}


extension CometChatUserEvents {
    
    @available(*, deprecated, message: "Use `ccUserBlocked(user: User)` instead")
    internal static func emitOnUserBlock(user: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUserEventListener {
            observer.onUserBlock?(user: user)
        }
    }
    
    @available(*, deprecated, message: "Use `ccUserBlocked(user: User)` instead")
    internal static func emitOnUserUnblock(user: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatUserEventListener {
            observer.onUserUnblock?(user: user)
        }
    }
}
