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

    private static func listeners() -> [CometChatUserEventListener] {
        lock.lock()
        defer { lock.unlock() }
        var snapshot: [CometChatUserEventListener] = []
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatUserEventListener {
            snapshot.append(value)
        }
        return snapshot
    }
    
    @objc public static func addListener(_ id: String, _ observer: CometChatUserEventListener) {
        lock.lock()
        defer { lock.unlock() }
        self.observer.setObject(observer, forKey: NSString(string: id))
    }
    
    @objc public static func removeListener(_ id: String) {
        lock.lock()
        defer { lock.unlock() }
        self.observer.removeObject(forKey: NSString(string: id))
    }
    
    public static func ccUserBlocked(user: User) {
        
        for observer in listeners() {
            observer.ccUserBlocked?(user: user)
        }
    }
    
    public static func ccUserUnblocked(user: User) {
        
        for observer in listeners() {
            observer.ccUserUnblocked?(user: user)
        }
    }
    
}


extension CometChatUserEvents {
    
    @available(*, deprecated, message: "Use `ccUserBlocked(user: User)` instead")
    internal static func emitOnUserBlock(user: User) {
        
        for observer in listeners() {
            observer.onUserBlock?(user: user)
        }
    }
    
    @available(*, deprecated, message: "Use `ccUserBlocked(user: User)` instead")
    internal static func emitOnUserUnblock(user: User) {
        
        for observer in listeners() {
            observer.onUserUnblock?(user: user)
        }
    }
}
