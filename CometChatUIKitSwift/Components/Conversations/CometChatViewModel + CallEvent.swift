//
//  CometChatViewModel + CallEvent.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 28/06/24.
//

import Foundation
import CometChatSDK

extension ConversationsViewModel: CometChatCallEventListener {
    
    func ccCallAccepted(call: Call) {
        if checkForConversationUpdate(message: call) {
            update(lastMessage: call)
        }
    }
    
    func ccOutgoingCall(call: Call) {
        if checkForConversationUpdate(message: call) {
            update(lastMessage: call)
        }
    }
    
    func ccCallRejected(call: Call) {
        if checkForConversationUpdate(message: call) {
            update(lastMessage: call)
        }
    }
    
    func ccCallEnded(call: Call) {
        if checkForConversationUpdate(message: call) {
            update(lastMessage: call)
        }
    }
    
}


extension ConversationsViewModel: CometChatCallDelegate {
   
    func onIncomingCallReceived(incomingCall: Call?, error: CometChatException?) {
        if let call = incomingCall, checkForConversationUpdate(message: call) {
            update(lastMessage: call)
        }
    }
    
    func onOutgoingCallAccepted(acceptedCall: Call?, error: CometChatException?) {
        if let call = acceptedCall, checkForConversationUpdate(message: call) {
            update(lastMessage: call)
        }
    }
    
    func onOutgoingCallRejected(rejectedCall: Call?, error: CometChatException?) {
        if let call = rejectedCall, checkForConversationUpdate(message: call) {
            update(lastMessage: call)
        }
    }
    
    func onIncomingCallCancelled(canceledCall: Call?, error: CometChatException?) {
        if let call = canceledCall, checkForConversationUpdate(message: call) {
            update(lastMessage: call)
        }
    }
    
    func onCallEndedMessageReceived(endedCall: Call?, error: CometChatException?) {
        if let call = endedCall, checkForConversationUpdate(message: call) {
            update(lastMessage: call)
        }
    }
    
}
