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

    private static func listeners() -> [CometChatCardEventListener] {
        lock.lock()
        defer { lock.unlock() }
        var snapshot: [CometChatCardEventListener] = []
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCardEventListener {
            snapshot.append(value)
        }
        return snapshot
    }
    
    public static func addListener(_ id: String, _ observer: CometChatCardEventListener) {
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
    
    public static func ccCardActionClicked(message: BaseMessage, action: CometChatCardActionEvent) {
        for value in listeners() {
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
