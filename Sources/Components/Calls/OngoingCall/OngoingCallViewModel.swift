//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 07/03/23.
//

import Foundation
import CometChatPro

protocol OngoingCallViewModelProtocol {
    
    var callSettingsBuilder: CallSettings.CallSettingsBuilder { get }
    var onUserJoined: ((CometChatPro.User) -> Void)? { get }
    var onUserLeft: ((CometChatPro.User) -> Void)? { get }
    var onUserListUpdated: (([CometChatPro.User]) -> Void)? { get }
    var onAudioModesUpdated: (([CometChatPro.AudioDevice]) -> Void)? { get }
    var onCallSwitchedToVideo: (([String : Any]?) -> Void)? { get }
    var onRecordingStarted: ((CometChatPro.User?) -> Void)? { get }
    var onRecordingStopped: ((CometChatPro.User?) -> Void)? { get }
    var onCallEnded: ((CometChatPro.Call) -> Void)? { get }
    var onUserMuted: (([String : CometChatPro.User]?) -> Void)? { get }
    var onError: ((CometChatPro.CometChatException) -> Void)? { get }
    
    func startCall()
}

class OngoingCallViewModel:  OngoingCallViewModelProtocol {
    
    var callSettingsBuilder: CometChatPro.CallSettings.CallSettingsBuilder
    var onUserJoined: ((CometChatPro.User) -> Void)?
    var onUserLeft: ((CometChatPro.User) -> Void)?
    var onUserMuted: (([String : CometChatPro.User]?) -> Void)?
    var onUserListUpdated: (([CometChatPro.User]) -> Void)?
    var onAudioModesUpdated: (([CometChatPro.AudioDevice]) -> Void)?
    var onRecordingStarted: ((CometChatPro.User?) -> Void)?
    var onRecordingStopped: ((CometChatPro.User?) -> Void)?
    var onCallEnded: ((CometChatPro.Call) -> Void)?
    var onCallSwitchedToVideo: (([String : Any]?) -> Void)?
    var onError: ((CometChatPro.CometChatException) -> Void)?
    
    private var callSettings: CallSettings?
    
    init(callSettingsBuilder: CallSettings.CallSettingsBuilder) {
        self.callSettingsBuilder = callSettingsBuilder
        self.callSettings = self.callSettingsBuilder.build()
    }
    
    func startCall() {
        if let callSettings = callSettings {
            DispatchQueue.main.async {
                CometChat.startCall(callSettings: callSettings) { onUserJoined in
                    if let user = onUserJoined {
                        self.onUserJoined?(user)
                    }
                } onUserLeft: { onUserLeft in
                    if let user = onUserLeft {
                        self.onUserLeft?(user)
                    }
                } onUserListUpdated: { onUserListUpdated in
                    if let users = onUserListUpdated {
                        self.onUserListUpdated?(users)
                    }
                } onAudioModesUpdated: { onAudioModesUpdated in
                    if let devices = onAudioModesUpdated {
                        self.onAudioModesUpdated?(devices)
                    }
                } onUserMuted: { onUserMuted in
                    if let users = onUserMuted {
                        self.onUserMuted?(users)
                    }
                } onCallSwitchedToVideo: { onCallSwitchedToVideo in
                    if let user = onCallSwitchedToVideo {
                        self.onCallSwitchedToVideo?(user)
                    }
                } onRecordingStarted: { onRecordingStarted in
                    if let user = onRecordingStarted {
                        self.onRecordingStarted?(user)
                    }
                } onRecordingStopped: { onRecordingStopped in
                    if let user = onRecordingStopped {
                        self.onRecordingStopped?(user)
                    }
                } onError: { onError in
                    if let error = onError {
                        self.onError?(error)
                    }
                } onCallEnded: { onEnded in
                    if let call = onEnded {
                        self.onCallEnded?(call)
                        CometChatCallEvents.emitOnCallEnded(call: call)
                    }
                }
            }
        }
    }
    
}
