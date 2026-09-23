//
//  File.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 15/06/24.
//

import Foundation
import CometChatSDK

import Foundation
import CometChatSDK

public class CometChatCallEvents {
    
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

    private static func listeners() -> [CometChatCallEventListener] {
        lock.lock()
        defer { lock.unlock() }
        var snapshot: [CometChatCallEventListener] = []
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            snapshot.append(value)
        }
        return snapshot
    }
    
    public static func addListener(_ id: String, _ observer: CometChatCallEventListener) {
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
    
    public static func ccOutgoingCall(call: Call) {
        
        for value in listeners() {
            value.ccOutgoingCall(call: call)
        }
    }
    
    public static func ccCallAccepted(call: Call) {
        
        for value in listeners() {
            value.ccCallAccepted(call: call)
        }
    }
    
    public static func ccCallRejected(call: Call) {
        
        for value in listeners() {
            value.ccCallRejected(call: call)
        }
    }
    
    public static func ccCallEnded(call: Call) {
        
        for value in listeners() {
            value.ccCallEnded(call: call)
        }
    }
}

//MARK: Deprecated Functions
extension CometChatCallEvents {
    
    @available(*, deprecated, message: "Use `ccCallAccepted(call: Call)` instead")
    internal static func emitOnIncomingCallAccepted(call: Call) {
        
        for value in listeners() {
            value.onIncomingCallAccepted(call: call)
        }
    }
    
    @available(*, deprecated, message: "Use `ccCallRejected(call: Call)` instead")
    internal static func emitOnIncomingCallRejected(call: Call) {
        
        for value in listeners() {
            value.onIncomingCallRejected(call: call)
        }
    }
    
    @available(*, deprecated, message: "Use `ccCallEnded(call: Call)` instead")
    internal static func emitOnCallEnded(call: Call) {
        
        for value in listeners() {
            value.onCallEnded(call: call)
        }
    }
    
    @available(*, deprecated, message: "Use `ccOutgoingCall(call: Call)` instead")
    internal static func emitOnCallInitiated(call: Call) {
        
        for value in listeners() {
            value.onCallInitiated(call: call)
        }
    }
    
    @available(*, deprecated, message: "Use `ccOutgoingCall(call: Call)` instead")
    internal static func emitOnOutgoingCallAccepted(call: Call) {
        
        for value in listeners() {
            value.onOutgoingCallAccepted(call: call)
        }
    }
    
    @available(*, deprecated, message: "Use `ccCallRejected(call: Call)` instead")
    internal static func emitOnOutgoingCallRejected(call: Call) {
        
        for value in listeners() {
            value.onOutgoingCallRejected(call: call)
        }
    }
}
