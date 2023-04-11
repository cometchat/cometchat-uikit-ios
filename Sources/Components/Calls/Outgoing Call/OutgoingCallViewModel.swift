//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import Foundation
import CometChatPro


protocol OutgoingCallViewModelProtocol {
    
    var onOutgoingCallAccepted: ((CometChatPro.Call) -> Void)? { get }
    var onOutgoingCallRejected: ((CometChatPro.Call) -> Void)? { get }
    var onError: ((CometChatPro.CometChatException) -> Void)? { get }
}

class OutgoingCallViewModel: OutgoingCallViewModelProtocol {
   
    let listenerID = "outgoing-call-listener"
    var onOutgoingCallAccepted: ((CometChatPro.Call) -> Void)?
    var onOutgoingCallRejected: ((CometChatPro.Call) -> Void)?
    var onError: ((CometChatPro.CometChatException) -> Void)?
   
    public init () { }
    
    func connect() {
        CometChat.addCallListener(listenerID, self)
    }
    
    func disconnect() {
        CometChat.removeCallListener(listenerID)
    }
}

extension OutgoingCallViewModel: CometChatCallDelegate {
    
    func onIncomingCallReceived(incomingCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        
    }
    
    func onOutgoingCallAccepted(acceptedCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        if let call = acceptedCall {
            self.onOutgoingCallAccepted?(call)
        }
    }
    
    func onOutgoingCallRejected(rejectedCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        if let call = rejectedCall {
            self.onOutgoingCallRejected?(call)
        }
    }
    
    func onIncomingCallCancelled(canceledCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        
    }
}
