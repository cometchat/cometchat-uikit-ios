//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import Foundation
import CometChatPro


protocol IncomingCallViewModelProtocol {
    
    var onIncomingCallReceived: ((CometChatPro.Call) -> Void)? { get }
    var onIncomingCallCancelled: ((CometChatPro.Call) -> Void)? { get }
    var onError: ((CometChatPro.CometChatException) -> Void)? { get }
}

class IncomingCallViewModel: IncomingCallViewModelProtocol {
   
    let listenerID = "incoming-call-listener"
    var onIncomingCallReceived: ((CometChatPro.Call) -> Void)?
    var onIncomingCallCancelled: ((CometChatPro.Call) -> Void)?
    var onCallAccepted: ((CometChatPro.Call) -> Void)?
    var onCallRejected: ((CometChatPro.Call) -> Void)?
    var onError: ((CometChatPro.CometChatException) -> Void)?
   
    public init () { }
    
    func connect() {
        CometChat.addCallListener(listenerID, self)
    }
    
    func disconnect() {
        CometChat.removeCallListener(listenerID)
    }
    
    func acceptCall(call: Call) {
        guard let sessionID = call.sessionID else { return }
        CometChat.acceptCall(sessionID: sessionID) { call in
            guard let call = call else { return }
            CometChatCallEvents.emitOnIncomingCallAccepted(call: call)
            self.onCallAccepted?(call)
        } onError: { error in
            guard let error = error else { return }
            self.onError?(error)
        }
    }
    
    func rejectCall(call: Call) {
        guard let sessionID = call.sessionID else { return }
        CometChat.rejectCall(sessionID: sessionID, status: .rejected) { call in
            guard let call = call else { return }
            CometChatCallEvents.emitOnIncomingCallRejected(call: call)
            self.onCallRejected?(call)
        } onError: { error in
            guard let error = error else { return }
            self.onError?(error)
        }
    }
}

extension IncomingCallViewModel: CometChatCallDelegate {
    
    func onIncomingCallReceived(incomingCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        if let call = incomingCall {
            self.onIncomingCallReceived?(call)
        }
    }
    
    func onOutgoingCallAccepted(acceptedCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        
    }
    
    func onOutgoingCallRejected(rejectedCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
       
    }
    
    func onIncomingCallCancelled(canceledCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        if let call = canceledCall {
            self.onIncomingCallCancelled?(call)
        }
    }
}
