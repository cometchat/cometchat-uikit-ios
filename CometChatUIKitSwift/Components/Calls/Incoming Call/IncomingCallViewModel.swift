//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import Foundation
import CometChatSDK


protocol IncomingCallViewModelProtocol {
    
    var onIncomingCallReceived: ((CometChatSDK.Call) -> Void)? { get }
    var dismissIncomingCallView: ((CometChatSDK.Call) -> Void)? { get }
    var onError: ((CometChatSDK.CometChatException) -> Void)? { get }
}

class IncomingCallViewModel: IncomingCallViewModelProtocol {
   
    let listenerID = "incoming-call-listener"
    var onIncomingCallReceived: ((CometChatSDK.Call) -> Void)?
    var dismissIncomingCallView: ((CometChatSDK.Call) -> Void)?
    var onCallAccepted: ((CometChatSDK.Call) -> Void)?
    var onCallRejected: ((CometChatSDK.Call) -> Void)?
    var onError: ((CometChatSDK.CometChatException) -> Void)?
    var call: Call?
   
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
            CometChatCallEvents.ccCallAccepted(call: call)
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
            CometChatCallEvents.ccCallRejected(call: call)
            self.onCallRejected?(call)
        } onError: { error in
            guard let error = error else { return }
            self.onError?(error)
        }
    }
    
    func getSubtitle(call: Call) -> String {
        return call.callType == .audio ? "INCOMING_AUDIO_CALL".localize():"INCOMING_VIDEO_CALL".localize()
    }
}

extension IncomingCallViewModel: CometChatCallDelegate {
    
    func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let call = incomingCall {
            self.onIncomingCallReceived?(call)
        }
    }
    
    func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if acceptedCall?.sessionID == call?.sessionID {
            if let call = acceptedCall {
                self.dismissIncomingCallView?(call)
            }
        }
    }
    
    func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if rejectedCall?.sessionID == call?.sessionID {
            if let call = rejectedCall {
                self.dismissIncomingCallView?(call)
            }
        }
    }
    
    func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let call = canceledCall {
            self.dismissIncomingCallView?(call)
        }
    }
}
