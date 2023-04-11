//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 14/03/23.
//

import Foundation
import UIKit
import CometChatPro

public class CometChatCallButton: UIStackView {
    
    private(set) var user: User?
    private(set) var group: Group?
    private(set) var voiceCallIcon = UIImage(named: "voice-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private(set) var videoCallIcon = UIImage(named: "video-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private(set) var voiceCallIconText: String?
    private(set) var videoCallIconText: String?
    private(set) var controller : UIViewController?
    private(set) var hideVoiceCall : Bool = false
    private(set) var hideVideoCall : Bool = false
    private(set) var isFromCallDetail: Bool = false
    private(set) var callButtonsStyle : ButtonStyle?
    private(set) var onVoiceCallClick : (() -> Void)?
    private(set) var onVideoCallClick : (() -> Void)?
    private(set) var voiceCallButton : CometChatButton?
    private(set) var videoCallButton : CometChatButton?
    
    public init(width: CGFloat, height: CGFloat) {
        super.init(frame: CGRect(x: 0, y: 0, width: width, height: height))
        disconnect()
        connect()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult
    public func connect() -> Self {
        CometChatMessageEvents.addListener("call-button-message-event-listener", self)
        CometChat.addCallListener("call-button-call-listener", self)
        return self
    }
    
    @discardableResult
    public func disconnect() -> Self {
        CometChatMessageEvents.removeListener("call-button-message-event-listener")
        CometChat.removeCallListener("call-button-call-listener")
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(user: User) -> Self {
        self.user = user
        setupApprearance(forUser: user)
        return self
    }
    
    //For handling spacer in case of conference call
    @discardableResult
    public func check(isFromCallDetail: Bool) -> Self {
        self.isFromCallDetail = isFromCallDetail
        return self
    }
    
    @discardableResult
    public func set(group: Group) -> Self {
        self.group = group
        setupApprearance(forGroup: group)
        return self
    }
    
    @discardableResult
    public func set(voiceCallIcon: UIImage) -> Self {
        self.voiceCallIcon = voiceCallIcon
        return self
    }
    
    @discardableResult
    public func set(videoCallIcon: UIImage) -> Self {
        self.videoCallIcon = videoCallIcon
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
        return self
    }
    
    @discardableResult
    public func hide(videoCall: Bool) -> Self {
        self.hideVideoCall = hideVideoCall
        return self
    }
    
    @discardableResult
    public func hide(callButtonsStyle: ButtonStyle) -> Self {
        self.callButtonsStyle = callButtonsStyle
        return self
    }
    
    @discardableResult
    public func setOnVoiceCallClick(_ onVoiceCallClick: @escaping () -> Void) -> Self {
        self.onVoiceCallClick = onVoiceCallClick
        return self
    }
    
    @discardableResult
    public func setOnVideoCallClick(_ onVideoCallClick: @escaping () -> Void) -> Self {
        self.onVideoCallClick = onVideoCallClick
        return self
    }
    
    private func setupApprearance(forUser: User) {
        let style = ButtonStyle()
        style.set(iconBackground: .clear)
            .set(iconTint: CometChatTheme.palatte.primary)
        
        // Audio Call
        voiceCallButton = CometChatButton(width: 40, height:38)
        if let voiceCallButton = voiceCallButton {
            voiceCallButton.contentMode = .scaleAspectFit
            voiceCallButton.set(icon: voiceCallIcon)
            voiceCallButton.set(backgroundColor: CometChatTheme.palatte.background)
            voiceCallButton.set(text: voiceCallIconText ?? "")
            voiceCallButton.set(style: callButtonsStyle ?? style)
            voiceCallButton.set(cornerRadius: CometChatCornerStyle(cornerRadius: callButtonsStyle?.iconCornerRadius ?? 8.0))
            voiceCallButton.setOnClick {
                if self.onVoiceCallClick != nil {
                    self.onVoiceCallClick?()
                } else {
                    guard let user = self.user, let uid = user.uid else { return }
                    let call = Call(receiverId: uid, callType: .audio, receiverType: .user)
                    CometChat.initiateCall(call: call) { call in
                        DispatchQueue.main.async {
                            guard let call = call else { return }
                            CometChatCallEvents.emitOnCallInitiated(call: call)
                            let outgoingCall = CometChatOutgoingCall()
                            outgoingCall.set(call: call)
                            outgoingCall.modalPresentationStyle = .fullScreen
                            outgoingCall.setOnCancelClick { call, controller in
                                CometChat.rejectCall(sessionID: call?.sessionID ?? "", status: .cancelled) { call in
                                    if let call = call {
                                        CometChatCallEvents.emitOnOutgoingCallRejected(call: call)
                                    }
                                    DispatchQueue.main.async {
                                        controller?.dismiss(animated: true)
                                    }
                                } onError: { error in
                                    DispatchQueue.main.async {
                                        controller?.dismiss(animated: true)
                                    }
                                }
                            }
                            self.controller?.present(outgoingCall, animated: true)
                        }
                    } onError: { error in
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
            self.addArrangedSubview(voiceCallButton)
        }
        
        // Video Call
        videoCallButton = CometChatButton(width: 40, height:38)
        if let videoCallButton = videoCallButton {
            videoCallButton.contentMode = .scaleAspectFit
            videoCallButton.set(icon: videoCallIcon)
            videoCallButton.set(backgroundColor: CometChatTheme.palatte.background)
            videoCallButton.set(text: videoCallIconText ?? "")
            videoCallButton.set(style: callButtonsStyle ?? style)
            videoCallButton.set(cornerRadius: CometChatCornerStyle(cornerRadius: callButtonsStyle?.iconCornerRadius ?? 8.0))
            videoCallButton.setOnClick {
                if self.onVideoCallClick != nil {
                    self.onVideoCallClick?()
                } else {
                    guard let user = self.user, let uid = user.uid else { return }
                    let call = Call(receiverId: uid, callType: .video, receiverType: .user)
                    CometChat.initiateCall(call: call) { call in
                        DispatchQueue.main.async {
                            guard let call = call else { return }
                            CometChatCallEvents.emitOnCallInitiated(call: call)
                            let outgoingCall = CometChatOutgoingCall()
                            outgoingCall.set(call: call)
                            outgoingCall.modalPresentationStyle = .fullScreen
                            outgoingCall.setOnCancelClick { call, controller in
                                CometChat.rejectCall(sessionID: call?.sessionID ?? "", status: .cancelled) { call in
                                    if let call = call {
                                        CometChatCallEvents.emitOnOutgoingCallRejected(call: call)
                                    }
                                    DispatchQueue.main.async {
                                        controller?.dismiss(animated: true)
                                    }
                                } onError: { error in
                                    DispatchQueue.main.async {
                                        controller?.dismiss(animated: true)
                                    }
                                }
                            }
                            self.controller?.present(outgoingCall, animated: true)
                        }
                    } onError: { error in
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
            self.addArrangedSubview(videoCallButton)
        }
        
        self.spacing = 10
        self.distribution = .fillEqually
    }
    
    private func setupApprearance(forGroup: Group) {
        let style = ButtonStyle()
        style.set(iconBackground: .clear)
            .set(iconTint: CometChatTheme.palatte.primary)
        
        let spacer = CometChatButton(width: 40, height:40)
        
        // Conference Call
        let conferenceCallButton = CometChatButton(width: 80, height: 40)
        conferenceCallButton.set(text: "VIDEOS".localize())
        conferenceCallButton.set(icon: videoCallIcon)
        conferenceCallButton.set(backgroundColor: CometChatTheme.palatte.background)
        conferenceCallButton.set(text: videoCallIconText ?? "")
        conferenceCallButton.set(style: callButtonsStyle ?? style)
        conferenceCallButton.set(cornerRadius: CometChatCornerStyle(cornerRadius: callButtonsStyle?.iconCornerRadius ?? 8.0))
        conferenceCallButton.setOnClick {
            if self.onVideoCallClick != nil {
                self.onVideoCallClick?()
            } else {
                if let sessionID = self.group?.guid {
                    let videoMeeting = CustomMessage(receiverUid: self.group?.guid ?? "", receiverType: .group, customData: ["sessionID":sessionID, "callType":"video"], type: "meeting")
                    videoMeeting.metaData = ["pushNotification":"\(String(describing: CometChat.getLoggedInUser()?.name))" + "HAS_INITIATED_GROUP_VIDEO_CALL"]
                    videoMeeting.muid = "\(Int(Date().timeIntervalSince1970))"
                    videoMeeting.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                    videoMeeting.sender = CometChat.getLoggedInUser()
                    CometChatUIKit.sendCustomMessage(message: videoMeeting)
                }
            }
        }
        self.distribution = .fill
        
        if !isFromCallDetail {
            self.addArrangedSubview(spacer)
        }
        self.addArrangedSubview(conferenceCallButton)
    }
}

extension CometChatCallButton: CometChatMessageEventListener {
    
    public func onMessageSent(message: CometChatPro.BaseMessage, status: MessageStatus) {
        if let call = message as? CustomMessage, status == .success, call.type == "meeting", let customData = call.customData, let sessionID = customData["sessionID"] as? String {
            DispatchQueue.main.async {
                let ongoingCall = CometChatOngoingCall()
                ongoingCall.set(sessionId: sessionID)
                ongoingCall.modalPresentationStyle = .fullScreen
                self.controller?.present(ongoingCall, animated: true)
            }
        }
    }
    
    public func onMessageEdit(message: CometChatPro.BaseMessage, status: MessageStatus) {}
    
    public func onMessageDelete(message: CometChatPro.BaseMessage) {}
    
    public func onMessageReply(message: CometChatPro.BaseMessage, status: MessageStatus) {}
    
    public func onMessageRead(message: CometChatPro.BaseMessage) {}
    
    public func onParentMessageUpdate(message: CometChatPro.BaseMessage) {}
    
    public func onLiveReaction(reaction: CometChatPro.TransientMessage) {}
    
    public func onMessageError(error: CometChatPro.CometChatException) {}
    
    public func onVoiceCall(user: CometChatPro.User) {}
    
    public func onVoiceCall(group: CometChatPro.Group) {}
    
    public func onVideoCall(user: CometChatPro.User) {}
    
    public func onVideoCall(group: CometChatPro.Group) {}
    
    public func onViewInformation(user: CometChatPro.User) {}
    
    public func onViewInformation(group: CometChatPro.Group) {}
    
    public func onError(message: CometChatPro.BaseMessage?, error: CometChatPro.CometChatException) {
        
    }
    
    public func onMessageReact(message: CometChatPro.BaseMessage, reaction: CometChatMessageReaction) {
        
    }
}

extension CometChatCallButton: CometChatCallDelegate {
    
    public func onIncomingCallReceived(incomingCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        voiceCallButton?.disable(button: true)
        videoCallButton?.disable(button: true)
    }
    
    public func onOutgoingCallAccepted(acceptedCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        
    }
    
    public func onOutgoingCallRejected(rejectedCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        
    }
    
    public func onIncomingCallCancelled(canceledCall: CometChatPro.Call?, error: CometChatPro.CometChatException?) {
        
    }
}
