//
//  CometChatCallButton.swift
//  
//
//  Created by Pushpsen Airekar on 14/03/23.
//

#if canImport(CometChatCallsSDK)


import Foundation
import UIKit
import CometChatSDK
import CometChatCallsSDK

public class CometChatCallButtons: UIStackView {
    
    public var user: User?
    public var group: Group?
    public var voiceCallIconText: String?
    public var videoCallIconText: String?
    public var conferenceCallIconText: String?
    public weak var controller : UIViewController?
    public var hideVoiceCall : Bool = false
    public var hideVideoCall : Bool = false
    public var callButtonsStyle : ButtonStyle?
    public var voiceCallButton : CometChatButton?
    public var videoCallButton : CometChatButton?
    public var conferenceCallButton: CometChatButton?
    public var outgoingCallConfiguration : OutgoingCallConfiguration?
    public var onVoiceCallClick: ((_ user: User?, _ group: Group?) -> Void)?
    public var onVideoCallClick: ((_ user: User?, _ group: Group?) -> Void)?
    public var onError: ((_ error: CometChatException?) -> Void)?
    public var callSettingsBuilderCallBack: ((_ user: User?, _ group: Group?, _ isAudioOnly: Bool) -> Any)?
    private var disabled = false
    private var uniqueID = Date().timeIntervalSince1970
    
    public static var style = CallButtonStyle()
    public var style = CometChatCallButtons.style
    
    public init(width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        self.spacing = CometChatSpacing.Spacing.s2
        self.distribution = .fill
        self.alignment = .fill
        disconnect()
        connect()
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            setupStyle()
        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func connect() -> Self {
        CometChatMessageEvents.addListener("call-button-message-event-listener-\(uniqueID)", self)
        CometChat.addCallListener("call-button-call-listener-\(uniqueID)", self)
        CometChatCallEvents.addListener("call-button-call-event-listner-\(uniqueID)", self)
        return self
    }
    
    @discardableResult
    public func disconnect() -> Self {
        CometChatMessageEvents.removeListener("call-button-message-event-listener-\(uniqueID)")
        CometChat.removeCallListener("call-button-call-listener-\(uniqueID)")
        CometChatCallEvents.removeListener("call-button-call-event-listner-\(uniqueID)")
        return self
    }
    
    deinit {
        disconnect()
    }
    
    open func setupStyle() {
        
        if let voiceCallButton = voiceCallButton {
            voiceCallButton.set(icon: style.audioCallIcon)
            if let voiceCallIconText = voiceCallIconText { voiceCallButton.set(text: voiceCallIconText) }
            voiceCallButton.imageView?.tintColor = style.audioCallIconTint
            if voiceCallButton.titleLabel?.text != "" && voiceCallButton.titleLabel?.text != nil {
                voiceCallButton.titleLabel?.font = style.audioCallTextFont
            }
            voiceCallButton.setTitleColor(style.audioCallTextColor, for: .normal)
            voiceCallButton.backgroundColor = style.audioCallButtonBackground
            if let audioCallButtonBorder = style.audioCallButtonBorder {
                voiceCallButton.borderWith(width: audioCallButtonBorder)
            }
            if let audioCallButtonBorderColor = style.audioCallButtonBorderColor {
                voiceCallButton.borderColor(color: audioCallButtonBorderColor)
            }
            if let audioCallButtonCornerRadius = style.audioCallButtonCornerRadius {
                voiceCallButton.set(cornerRadius: audioCallButtonCornerRadius)
            }
        }
        
        if let videoCallButton = videoCallButton {
            videoCallButton.set(icon: style.videoCallIcon)
            if let videoCallIconText = videoCallIconText { videoCallButton.set(text: videoCallIconText) }
            videoCallButton.imageView?.tintColor = style.videoCallIconTint
            videoCallButton.setTitleColor(style.videoCallTextColor, for: .normal)
            videoCallButton.backgroundColor = style.videoCallButtonBackground
            if videoCallButton.titleLabel?.text != "" && videoCallButton.titleLabel?.text != nil {
                videoCallButton.titleLabel?.font = style.videoCallTextFont
            }
            if let videoCallButtonBorder = style.videoCallButtonBorder {
                videoCallButton.borderWith(width: videoCallButtonBorder)
            }
            if let videoCallButtonBorderColor = style.videoCallButtonBorderColor {
                videoCallButton.borderColor(color: videoCallButtonBorderColor)
            }
            if let videoCallButtonCornerRadius = style.videoCallButtonCornerRadius {
                videoCallButton.set(cornerRadius: videoCallButtonCornerRadius)
            }
        }
    }
    
    open func buildButton(forUser: User) {
        self.subviews.forEach({$0.removeFromSuperview()})
        
        // Audio Call
        voiceCallButton = CometChatButton().withoutAutoresizingMaskConstraints()
        if let voiceCallButton = voiceCallButton {
            voiceCallButton.isHidden = hideVoiceCall
            guard let user = self.user, let uid = user.uid else { return }
            let call = Call(receiverId: uid, callType: .audio, receiverType: .user)
            
            voiceCallButton.setOnClick {
                if self.onVoiceCallClick != nil {
                    self.onVoiceCallClick?(forUser, nil)
                } else if !self.disabled {
                    self.disabled = true
                    self.initiateDefaultAudioCall(call)
                }
            }
            
            self.addArrangedSubview(voiceCallButton)
        }
        
        // Video Call
        videoCallButton = CometChatButton().withoutAutoresizingMaskConstraints()
        if let videoCallButton = videoCallButton {
            videoCallButton.isHidden = hideVideoCall

            guard let user = self.user, let uid = user.uid else { return }
         
            let call = Call(receiverId: uid, callType: .video, receiverType: .user)
   
            videoCallButton.setOnClick {
                if self.onVideoCallClick != nil {
                    self.onVideoCallClick?(forUser, nil)
                } else if !self.disabled {
                    self.disabled = true
                    self.initiateDefaultVideoCall(call)
                }
            }
            self.addArrangedSubview(videoCallButton)
           
        }
        
    }
    
    open func buildButton(forGroup: Group) {
        
        self.subviews.forEach({$0.removeFromSuperview()})
    
        voiceCallButton = CometChatButton().withoutAutoresizingMaskConstraints()
        voiceCallButton!.setOnClick { [weak self] in
            guard let this = self else { return }
            if this.onVoiceCallClick != nil {
                this.onVoiceCallClick?(nil, forGroup)
            } else if !this.disabled {
                this.disabled = true
                
                if let sessionID = this.group?.guid {
                    let voiceMeeting = CustomMessage(receiverUid: this.group?.guid ?? "", receiverType: .group, customData: ["sessionID":"\(sessionID)", "callType":"audio"], type: "meeting")
                    voiceMeeting.metaData = [
                        "pushNotification":"\(String(describing: CometChat.getLoggedInUser()?.name))" + "has initiated group audio call",
                        "incrementUnreadCount": true
                    ]
                    voiceMeeting.updateConversation = true
                    voiceMeeting.metaData?["incrementUnreadCount"] = true
                    voiceMeeting.muid = "\(Int(Date().timeIntervalSince1970))"
                    voiceMeeting.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                    voiceMeeting.sender = CometChat.getLoggedInUser()
                    
                    CometChatUIKit.sendCustomMessage(message: voiceMeeting)
                    this.startGroupCall(sessionID: "\(sessionID)_\(Date().timeIntervalSince1970)", group: forGroup, isVideoCall: false)
                }
            }
        }
        self.addArrangedSubview(voiceCallButton!)
        
        // Conference Call
        videoCallButton = CometChatButton().withoutAutoresizingMaskConstraints()
        videoCallButton!.setOnClick { [weak self] in
            guard let this = self else { return }
            if this.onVideoCallClick != nil {
                this.onVideoCallClick?(nil, forGroup)
            } else if !this.disabled {
                this.disabled = true
                
                if let sessionID = this.group?.guid {
                    let videoMeeting = CustomMessage(receiverUid: this.group?.guid ?? "", receiverType: .group, customData: ["sessionID":"\(sessionID)", "callType":"video"], type: "meeting")
                    videoMeeting.metaData = [
                        "pushNotification":"\(String(describing: CometChat.getLoggedInUser()?.name))" + "has initiated group video call",
                        "incrementUnreadCount": true
                    ]
                    videoMeeting.updateConversation = true
                    videoMeeting.metaData?["incrementUnreadCount"] = true
                    videoMeeting.muid = "\(Int(Date().timeIntervalSince1970))"
                    videoMeeting.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                    videoMeeting.sender = CometChat.getLoggedInUser()
                    
                    CometChatUIKit.sendCustomMessage(message: videoMeeting)
                    this.startGroupCall(sessionID: "\(sessionID)_\(Date().timeIntervalSince1970)", group: forGroup, isVideoCall: true)
                }
            }
        }
        self.addArrangedSubview(videoCallButton!)
        self.distribution = .fill
    }
    
    open func startGroupCall(sessionID: String, group: Group, isVideoCall: Bool) {
        DispatchQueue.main.async {
            let ongoingCall = CometChatOngoingCall()
            ongoingCall.set(sessionId: sessionID)
            if let callSettingsBuilderCallBack = self.callSettingsBuilderCallBack {
                let callSettingsBuilder = callSettingsBuilderCallBack(nil, group, false) as? CometChatCallsSDK.CallSettingsBuilder
                ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
            } else {
                var callSettingsBuilder = CallingDefaultBuilder.callSettingsBuilder as? CometChatCallsSDK.CallSettingsBuilder
                callSettingsBuilder = callSettingsBuilder?.setIsAudioOnly(!isVideoCall)
                callSettingsBuilder = callSettingsBuilder?.setDefaultAudioMode(isVideoCall ? "SPEAKER" : "EARPIECE")
                if isVideoCall {
                    callSettingsBuilder = callSettingsBuilder?.setStartVideoMuted(false)
                }
                ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
            }
            ongoingCall.set(callWorkFlow: .directCalling)
            ongoingCall.modalPresentationStyle = .fullScreen
            self.controller?.present(ongoingCall, animated: true, completion: { [weak self] in
                self?.disabled = false
            })
        }
    }
    
    private func setupOutgoingCallConfiguration(outgoingCall: CometChatOutgoingCall) {
        if let outgoingCallConfiguration = self.outgoingCallConfiguration {
            if let declineButtonIcon = outgoingCallConfiguration.declineButtonIcon {
                outgoingCall.style.declineButtonIcon = declineButtonIcon
            }
            if let disableSoundForCalls = outgoingCallConfiguration.disableSoundForCalls {
                outgoingCall.disable(soundForCalls: disableSoundForCalls)
            }
            if let customSoundForCalls = outgoingCallConfiguration.customSoundForCalls {
                outgoingCall.set(customSoundForCalls: customSoundForCalls)
            }
            if let avatarStyle = outgoingCallConfiguration.avatarStyle {
                outgoingCall.avatarStyle = avatarStyle
            }
            if let outgoingCallStyle = outgoingCallConfiguration.outgoingCallStyle {
                outgoingCall.style = outgoingCallStyle
            }
            if let callSettingsBuilder = outgoingCallConfiguration.callSettingsBuilder {
                outgoingCall.set(callSettingsBuilder: callSettingsBuilder)
            }
        }
    }
}

extension CometChatCallButtons: CometChatMessageEventListener {
    
    public func ccMessageSent(message: CometChatSDK.BaseMessage, status: MessageStatus) {    }
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(user: User) -> Self {
        self.user = user
        buildButton(forUser: user)
        return self
    }
    
    @discardableResult
    public func set(group: Group) -> Self {
        self.group = group
        buildButton(forGroup: group)
        return self
    }
    
    @discardableResult
    public func set(voiceCallIconText: String) -> Self {
        self.voiceCallIconText = voiceCallIconText
        return self
    }
    
    @discardableResult
    public func set(videoCallIconText: String) -> Self {
        self.videoCallIconText = videoCallIconText
        return self
    }
    
    @discardableResult
    public func hide(voiceCall: Bool) -> Self {
        self.hideVoiceCall = voiceCall
        voiceCallButton?.isHidden = hideVoiceCall
        voiceCallButton?.clipsToBounds = true
        return self
    }
    
    @discardableResult
    public func hide(videoCall: Bool) -> Self {
        self.hideVideoCall = videoCall
        videoCallButton?.isHidden = hideVideoCall
        videoCallButton?.clipsToBounds = true
        return self
    }
    
    
    @discardableResult
    public func set(callButtonsStyle: ButtonStyle) -> Self {
        self.callButtonsStyle = callButtonsStyle
        return self
    }
    
    @discardableResult
    public func set(outgoingCallConfiguration: OutgoingCallConfiguration?) -> Self {
        self.outgoingCallConfiguration = outgoingCallConfiguration
        return self
    }
    
    @discardableResult
    public func setOnVoiceCallClick(onVoiceCallClick: @escaping ((_ user: User?, _ group: Group?) -> Void)) -> Self {
        self.onVoiceCallClick = onVoiceCallClick
        return self
    }
    
    @discardableResult
    public func setOnVideoCallClick(onVideoCallClick: @escaping ((_ user: User?, _ group: Group?) -> Void)) -> Self {
        self.onVideoCallClick = onVideoCallClick
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException?) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    /// Configures the settings for calls initiated via CallButton by providing a callback function.
    /// This function takes a callback that is invoked every time a call is initiated via CallButton, either on a User or a Group.
    /// The callback allows customization of the CallSettingsBuilder based on the User, Group, and whether the call is audio-only.
    /// - Parameter groupCallSettingBuilder: A callback function that provides a User (optional), a Group, and a Boolean indicating if the call is audio-only. The callback returns a CallSettingsBuilder object configured with the desired settings.
    /// - Returns: The current instance of CallingConfiguration for declarative coding, allowing further method chaining.
    /// - Note: Ensure that the returned object from the callback is of type CallSettingsBuilder to apply the custom settings.
    @discardableResult public func set(callSettingsBuilder: @escaping ((_ user: User?, _ group: Group?, _ isAudioOnly: Bool) -> Any)) -> Self {
        self.callSettingsBuilderCallBack = callSettingsBuilder
        return self
    }
    
}

extension CometChatCallButtons: CometChatCallDelegate {
    
    public func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {

    }
    
    public func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
    
    public func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        disabled = false
    }
    
    public func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
    
    public func onCallEndedMessageReceived(endedCall: Call?, error: CometChatException?) {
        disabled = false
    }
}

extension CometChatCallButtons: CometChatCallEventListener {
    
    public func ccCallEnded(call: Call) {
        disabled = false
    }
    
    public func ccCallRejected(call: Call) {
        disabled = false
    }
    
    public func ccOutgoingCall(call: Call) {
        if call.callStatus == .cancelled || call.callStatus == .rejected {
            disabled = false
        }
    }
    
}

extension CometChatCallButtons {
    private func initiateDefaultAudioCall(_ call: Call){
        CometChat.initiateCall(call: call) { call in
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                guard let call = call else { return }
                CometChatCallEvents.ccOutgoingCall(call: call)
                let outgoingCall = CometChatOutgoingCall()
                outgoingCall.set(call: call)
                outgoingCall.modalPresentationStyle = .fullScreen
                if let callSettingsBuilder = this.callSettingsBuilderCallBack?(this.user, this.group, true) {
                    outgoingCall.set(callSettingsBuilder: callSettingsBuilder)
                }
                this.setupOutgoingCallConfiguration(outgoingCall: outgoingCall)
                outgoingCall.setOnCancelClick { call, controller in
                    CometChat.rejectCall(sessionID: call?.sessionID ?? "", status: .cancelled) { call in
                        if let call = call {
                            CometChatCallEvents.ccCallRejected(call: call)
                        }
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    } onError: { error in
                        this.onError?(error)
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    }
                }
               
                this.controller?.present(outgoingCall, animated: true)
            }
        } onError: { error in
            self.onError?(error)
            DispatchQueue.main.async {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "OK".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                if let error = error {
                    confirmDialog.set(error: CometChatServerError.get(error: error))
                }
                confirmDialog.open {
                }
            }
            
        }
    }
    
    private func initiateDefaultVideoCall(_ call : Call){
        CometChat.initiateCall(call: call) { call in
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                guard let call = call else { return }
                CometChatCallEvents.ccOutgoingCall(call: call)
                let outgoingCall = CometChatOutgoingCall()
                outgoingCall.set(call: call)
                outgoingCall.modalPresentationStyle = .fullScreen
                if let callSettingsBuilder = this.callSettingsBuilderCallBack?(this.user, this.group, true) {
                    outgoingCall.set(callSettingsBuilder: callSettingsBuilder)
                }
                this.setupOutgoingCallConfiguration(outgoingCall: outgoingCall)
                outgoingCall.setOnCancelClick { call, controller in
                    CometChat.rejectCall(sessionID: call?.sessionID ?? "", status: .cancelled) { call in
                        if let call = call {
                            CometChatCallEvents.ccCallRejected(call: call)
                        }
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    } onError: { error in
                        this.onError?(error)
                        DispatchQueue.main.async {
                            controller?.dismiss(animated: true)
                        }
                    }
                }
                this.controller?.present(outgoingCall, animated: true)
            }
        } onError: { error in
            self.onError?(error)
            DispatchQueue.main.async {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "OK".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                if let error = error {
                    confirmDialog.set(error: CometChatServerError.get(error: error))
                }
                confirmDialog.open {
                }
            }
        }
    }
}
#endif
