//
//  CallInitiator.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 28/11/23.
//

import Foundation
import CometChatSDK

#if canImport(CometChatCallsSDK)

extension UIViewController {
    
    internal func initiateDefaultAudioCall(_ call: Call, onError: ((CometChatSDK.CometChatException?) -> ())? = nil){
        CometChat.initiateCall(call: call) { call in
            DispatchQueue.main.async {
                guard let call = call else { return }
                CometChatCallEvents.ccOutgoingCall(call: call)
                let outgoingCall = CometChatOutgoingCall()
                outgoingCall.set(call: call)
                outgoingCall.modalPresentationStyle = .fullScreen
                outgoingCall.set(onCancelClick: { call, controller in
                    CometChat.rejectCall(sessionID: call?.sessionID ?? "", status: .cancelled) { call in
                        if let call = call {
                            CometChatCallEvents.ccCallRejected(call: call)
                            CometChat.clearActiveCall()
                        }
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    } onError: { error in
                        onError?(error)
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    }
                })
               
                self.present(outgoingCall, animated: true)
            }
        } onError: { error in
            onError?(error)
            DispatchQueue.main.async {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(title: "SOMETHING_WENT_WRONG_ERROR".localize())
                confirmDialog.set(confirmButtonText: "OK".localize())
                confirmDialog.open {
                }
            }
            
        }
    }
    
    internal func initiateDefaultVideoCall(_ call : Call, outgoingCallConfiguration: OutgoingCallConfiguration? = nil, onError: ((CometChatSDK.CometChatException?) -> ())? = nil){
        CometChat.initiateCall(call: call) { call in
            DispatchQueue.main.async {
                guard let call = call else { return }
                CometChatCallEvents.ccOutgoingCall(call: call)
                let outgoingCall = CometChatOutgoingCall()
                outgoingCall.set(call: call)
                outgoingCall.modalPresentationStyle = .fullScreen
                outgoingCall.set(onCancelClick: { call, controller in
                    CometChat.rejectCall(sessionID: call?.sessionID ?? "", status: .cancelled) { call in
                        if let call = call {
                            CometChatCallEvents.ccCallRejected(call: call)
                            CometChat.clearActiveCall()
                        }
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    } onError: { error in
                        onError?(error)
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    }
                })
                self.present(outgoingCall, animated: true)
            }
        } onError: { error in
            onError?(error)
            DispatchQueue.main.async {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(title: "SOMETHING_WENT_WRONG_ERROR".localize())
                confirmDialog.set(confirmButtonText: "OK".localize())
                confirmDialog.open {
                }
            }
        }
    }
}

#endif
