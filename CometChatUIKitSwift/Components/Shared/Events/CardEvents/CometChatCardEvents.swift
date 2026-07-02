//
//  CometChatCardEvents.swift
//  CometChatUIKitSwift
//
//  Created for developer card action events.
//

import Foundation
import CometChatSDK
import CometChatCardsSwift

/// Emits events when a user interacts with a developer card's action elements.
public class CometChatCardEvents {
    
    static private var observer = NSMapTable<NSString, AnyObject>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    
    public static func addListener(_ id: String, _ observer: CometChatCardEventListener) {
        if let anyObject = observer as? AnyObject {
            self.observer.setObject(anyObject, forKey: NSString(string: id))
        }
    }
    
    public static func removeListener(_ id: String) {
        self.observer.removeObject(forKey: NSString(string: id))
    }
    
    public static func ccCardActionClicked(message: BaseMessage, action: CometChatCardActionEvent) {
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCardEventListener {
            value.ccCardActionClicked(message: message, action: action)
        }
    }
}

/// Protocol for listening to developer card action events.
public protocol CometChatCardEventListener {
    func ccCardActionClicked(message: BaseMessage, action: CometChatCardActionEvent)
}

public extension CometChatCardEventListener {
    func ccCardActionClicked(message: BaseMessage, action: CometChatCardActionEvent) {}
}
