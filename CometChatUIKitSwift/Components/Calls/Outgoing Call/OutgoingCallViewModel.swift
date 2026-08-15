//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import Foundation
import CometChatSDK


protocol OutgoingCallViewModelProtocol {
    
    var onOutgoingCallAccepted: ((CometChatSDK.Call) -> Void)? { get }
    var onOutgoingCallRejected: ((CometChatSDK.Call) -> Void)? { get }
    var onError: ((CometChatSDK.CometChatException) -> Void)? { get }
}

class OutgoingCallViewModel: OutgoingCallViewModelProtocol {
    /// Seam over the listener registries, so `connect()`/`disconnect()` symmetry is
    /// assertable without a live SDK. Defaults to the real registrar.
    internal var listeners: ListenerRegistering = SDKListenerRegistrar.shared

   
    let listenerID = "outgoing-call-listener"
    var onOutgoingCallAccepted: ((CometChatSDK.Call) -> Void)?
    var onOutgoingCallRejected: ((CometChatSDK.Call) -> Void)?
    var onError: ((CometChatSDK.CometChatException) -> Void)?
   
    public init () { }
    
    func connect() {
        listeners.add(.callSDK, id: listenerID, listener: self)
    }
    
    func disconnect() {
        listeners.remove(.callSDK, id: listenerID)
    }
}

extension OutgoingCallViewModel: CometChatCallDelegate {
    
    func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
    
    func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let call = acceptedCall {
            self.onOutgoingCallAccepted?(call)
        }
    }
    
    func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let call = rejectedCall {
            self.onOutgoingCallRejected?(call)
        }
    }
    
    func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
}
