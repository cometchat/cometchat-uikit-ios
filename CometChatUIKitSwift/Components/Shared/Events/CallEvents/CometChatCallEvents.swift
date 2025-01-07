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
    
    public static func addListener(_ id: String, _ observer: CometChatCallEventListener) {
        if let anyObject = observer as? AnyObject {
            self.observer.setObject(anyObject, forKey: NSString(string: id))
        }
    }
    
    public static func removeListener(_ id: String) {
        self.observer.removeObject(forKey: NSString(string: id))
    }
    
    public static func ccOutgoingCall(call: Call) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            value.ccOutgoingCall(call: call)
        }
    }
    
    public static func ccCallAccepted(call: Call) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            value.ccCallAccepted(call: call)
        }
    }
    
    public static func ccCallRejected(call: Call) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            value.ccCallRejected(call: call)
        }
    }
    
    public static func ccCallEnded(call: Call) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            value.ccCallEnded(call: call)
        }
    }
}

//MARK: Deprecated Functions
extension CometChatCallEvents {
    
    @available(*, deprecated, message: "Use `ccCallAccepted(call: Call)` instead")
    internal static func emitOnIncomingCallAccepted(call: Call) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            value.onIncomingCallAccepted(call: call)
        }
    }
    
    @available(*, deprecated, message: "Use `ccCallRejected(call: Call)` instead")
    internal static func emitOnIncomingCallRejected(call: Call) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            value.onIncomingCallRejected(call: call)
        }
    }
    
    @available(*, deprecated, message: "Use `ccCallEnded(call: Call)` instead")
    internal static func emitOnCallEnded(call: Call) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            value.onCallEnded(call: call)
        }
    }
    
    @available(*, deprecated, message: "Use `ccOutgoingCall(call: Call)` instead")
    internal static func emitOnCallInitiated(call: Call) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            value.onCallInitiated(call: call)
        }
    }
    
    @available(*, deprecated, message: "Use `ccOutgoingCall(call: Call)` instead")
    internal static func emitOnOutgoingCallAccepted(call: Call) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            value.onOutgoingCallAccepted(call: call)
        }
    }
    
    @available(*, deprecated, message: "Use `ccCallRejected(call: Call)` instead")
    internal static func emitOnOutgoingCallRejected(call: Call) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatCallEventListener {
            value.onOutgoingCallRejected(call: call)
        }
    }
}
