//
//  CometChatUserEvents.swift
 
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatSDK
import Foundation


@objc public protocol CometChatCallEventListener {

    func onIncomingCallAccepted(call: Call)
    func onIncomingCallRejected(call: Call)
    func onCallEnded(call: Call)
    
    func onCallInitiated(call: Call)
    func onOutgoingCallAccepted(call: Call)
    func onOutgoingCallRejected(call: Call)
    
    
}

public class CometChatCallEvents {
    
    static private var observer = [String: CometChatCallEventListener]()
    
    @objc public static func addListener(_ id: String,_ observer: CometChatCallEventListener) {
        self.observer[id] = observer
    }
    @objc public static func removeListener(_ id: String) {
        self.observer.removeValue(forKey: id)
    }
    
    internal static func emitOnIncomingCallAccepted(call: Call) {
        self.observer.forEach({
            (key,observer) in
            observer.onIncomingCallAccepted(call: call)
        })
    }
    
    internal static func emitOnIncomingCallRejected(call: Call) {
        self.observer.forEach({
            (key,observer) in
            observer.onIncomingCallRejected(call: call)
        })
    }
    
    internal static func emitOnCallEnded(call: Call) {
        self.observer.forEach({
            (key,observer) in
            observer.onCallEnded(call: call)
        })
    }
    
    internal static func emitOnCallInitiated(call: Call) {
        self.observer.forEach({
            (key,observer) in
            observer.onCallInitiated(call: call)
        })
    }
    
    internal static func emitOnOutgoingCallAccepted(call: Call) {
        self.observer.forEach({
            (key,observer) in
            observer.onOutgoingCallAccepted(call: call)
        })
    }
    
    internal static func emitOnOutgoingCallRejected(call: Call) {
        self.observer.forEach({
            (key,observer) in
            observer.onOutgoingCallRejected(call: call)
        })
    }

}
