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

    // Concurrency. This table is process-wide: components register and unregister from
    // SDK callback threads while broadcasts iterate on main. NSMapTable is not
    // thread-safe, and mutating one while another thread enumerates it is undefined
    // behaviour, not merely a stale read. The observed symptoms were an event delivered
    // twice and a listener silently dropped from the table.
    //
    // A lock ALONE would not fix this, for two reasons unrelated to other threads:
    //   1. values are `.weakMemory`, so ARC can zero an entry DURING an enumeration;
    //   2. callbacks used to run inside the enumeration loop, so a listener that called
    //      removeListener (directly, or by releasing the last strong ref to another
    //      listener) mutated the table on the SAME thread. A plain lock deadlocks there;
    //      a recursive lock lets the mutation through and corrupts the enumerator anyway.
    //
    // Hence snapshot-then-dispatch: copy into strong references under the lock, release
    // it, then call the listeners. Callbacks therefore run with no lock held, so a
    // listener may freely add or remove listeners during delivery.
    private static let lock = NSLock()

    private static func listeners() -> [CometChatUIEventListener] {
        lock.lock()
        defer { lock.unlock() }
        var snapshot: [CometChatUIEventListener] = []
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatUIEventListener {
            snapshot.append(value)
        }
        return snapshot
    }
    
    public static func addListener(_ id: String, _ observer: CometChatUIEventListener) {
        lock.lock()
        defer { lock.unlock() }
        if let anyObject = observer as? AnyObject {
            self.observer.setObject(anyObject, forKey: NSString(string: id))
        }
    }
    
    public static func removeListener(_ id: String) {
        lock.lock()
        defer { lock.unlock() }
        self.observer.removeObject(forKey: NSString(string: id))
    }
    
    public static func showPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?) {
        
        for observer in listeners() {
            observer.showPanel(id: id, alignment: alignment, view: view)
        }
    }
    
    public static func hidePanel(id: [String:Any]?, alignment: UIAlignment) {
        
        for observer in listeners() {
            observer.hidePanel(id: id, alignment: alignment)
        }
    }
    
    public static func ccActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?) {
        
        for observer in listeners() {
            observer.ccActiveChatChanged(id: id, lastMessage: lastMessage, user: user, group: group)
        }
    }
    
    public static func openChat(user: User?, group: Group?) {
        
        for observer in listeners() {
            observer.openChat(user: user, group: group)
        }
    }
    
    public static func ccComposeMessage(id: [String:Any]?, message: BaseMessage) {
        
        for observer in listeners() {
            observer.ccComposeMessage(id: id, message: message)
        }
    }
    
    public static func onAiFeatureTapped(user:User?, group:Group?) {
        
        for observer in listeners() {
            observer.onAiFeatureTapped(user: user, group: group)
        }
    }
}

//MARK: Deprecated Functions
extension CometChatUIEvents {
    
    @available(*, deprecated, message: "Use `showPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?` instead")
    public static func emitShowPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?) {
        
        for observer in listeners() {
            observer.showPanel(id: id, alignment: alignment, view: view)
        }
    }
    
    @available(*, deprecated, message: "Use `ccActiveChatChanged(_ message: TransientMessage)` instead")
    public static func emitOnOpenChat(user: User?, group: Group?) {
        
        for observer in listeners() {
            observer.openChat(user: user, group: group)
        }
    }
    
    @available(*, deprecated, message: "Use `ccActiveChatChanged(_ message: TransientMessage)` instead")
    public static func emitOnActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?) {
        
        for observer in listeners() {
            observer.onActiveChatChanged(id: id, lastMessage: lastMessage, user: user, group: group)
        }
    }
    
    @available(*, deprecated, message: "Use `emitHidePanel(id: [String:Any]?, alignment: UIAlignment)` instead")
    public static func emitHidePanel(id: [String:Any]?, alignment: UIAlignment) {
        
        for observer in listeners() {
            observer.hidePanel(id: id, alignment: alignment)
        }
    }
    
    @available(*, deprecated, message: "This method is now deprecated")
    public static func emitCCMessageEdited(id: [String:Any]?, message: BaseMessage) {
        
        for observer in listeners() {
            observer.ccComposeMessage(id: id, message: message)
        }
    }
    
}
