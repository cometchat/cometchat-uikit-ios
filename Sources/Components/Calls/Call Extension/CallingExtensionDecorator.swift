//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 14/03/23.
//
import CometChatSDK
import UIKit
import Foundation
#if canImport(CometChatCallsSDK)
import CometChatCallsSDK

class CallingExtensionDecorator: DataSourceDecorator {
    
    var callCategoryConstant = "call"
    var audioCallTypeConstant = "audio"
    var videoCallTypeConstant = "video"
    var conferenceCallTypeConstant = "meeting"
    var callingConfiguration : CallingConfiguration?
    var anInterface : DataSource?
    var spacer: String = "       "
    private var call: Call?
    
    private override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
        self.anInterface = dataSource
    }
    
    public convenience init(dataSource: DataSource, configuration: CallingConfiguration?) {
        self.init(dataSource: dataSource)
        if let uiKitSettings = CometChatUIKit.uiKitSettings {
            let callAppSettings = CallAppSettingsBuilder().setAppId(uiKitSettings.appID).setRegion(uiKitSettings.region).build()
            CometChatCalls.init(callsAppSettings: callAppSettings) {_  in
            } onError: {_ in
            }
        }
        self.callingConfiguration = configuration
        disconnect()
        connect()
    }
    
    @discardableResult
    public func connect() -> Self {
        CometChat.addCallListener("call-decorator-call-listener", self)
        return self
    }
    
    @discardableResult
    public func disconnect() -> Self {
        CometChat.removeCallListener("call-decorator-call-listener")
        return self
    }
    
    override func getAllMessageTypes() -> [String]? {
        var messageTypes = super.getAllMessageTypes()
        messageTypes?.append(audioCallTypeConstant)
        messageTypes?.append(videoCallTypeConstant)
        messageTypes?.append(conferenceCallTypeConstant)
        return messageTypes
    }
    
    override func getAllMessageCategories() -> [String]? {
        if let categories = super.getAllMessageCategories(), !categories.contains(obj: MessageCategoryConstants.custom) {
            var messageCategories = categories
            messageCategories.append(callCategoryConstant)
            return messageCategories
        }
        return super.getAllMessageCategories()
    }
    
    override func getAllMessageTemplates() -> [CometChatMessageTemplate] {
        var templates = super.getAllMessageTemplates()
        templates.append(getAudioCallTemplate())
        templates.append(getVideoCallTemplate())
        templates.append(getConferenceCallTemplate())
        return templates
    }

    public func getAudioCallTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.call, type: audioCallTypeConstant, contentView: { message, alignment, controller in
            guard let message = message as? Call else { return UIView() }
            return self.getCallActionBubble(call: message)
        }, bubbleView: nil, headerView: nil, footerView: nil, bottomView: nil, options: nil)
    }
    
    public func getVideoCallTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.call, type: videoCallTypeConstant, contentView: { message, alignment, controller in
            guard let message = message as? Call else { return UIView() }
            return self.getCallActionBubble(call: message)
        }, bubbleView: nil, headerView: nil, footerView: nil, bottomView: nil, options: nil)
    }
    
    public func getCallActionBubble(call: Call) -> UIView {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        let view = CometChatMessageDateHeader()
        self.call = call
        let isLoggedInUser: Bool = (call.callInitiator as? User)?.uid == LoggedInUserInformation.getUID()
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        switch call.callType {
        case .audio:
            icon.image = UIImage(named: "VoiceCall", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        case .video:
            icon.image = UIImage(named: "VideoCall", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        @unknown default:
            break
        }
        
        switch call.callStatus  {
        case .initiated where call.receiverType == .user:
            let callStatus: String = isLoggedInUser ? "OUTGOING_CALL".localize() : "INCOMING_CALL".localize()
            view.text = spacer + callStatus
            view.textColor = CometChatTheme.palatte.accent900
            icon.tintColor = CometChatTheme.palatte.accent500
                        
        case .unanswered where  call.receiverType == .user:
            let callStatus: String = isLoggedInUser ? "CALL_UNANSWERED".localize() : "MISSED_CALL".localize()
            view.text = spacer + callStatus
            view.textColor =  isLoggedInUser ? CometChatTheme.palatte.accent900 : CometChatTheme.palatte.error
            icon.tintColor =  isLoggedInUser ? CometChatTheme.palatte.accent500 : CometChatTheme.palatte.error
            view.set(borderColor: isLoggedInUser ? .clear : CometChatTheme.palatte.error)
            

        case .rejected where call.receiverType == .user:
            let callStatus: String = isLoggedInUser ? "CALL_REJECTED".localize() : "MISSED_CALL".localize()
            view.text = spacer + callStatus
            view.textColor =  isLoggedInUser ? CometChatTheme.palatte.accent900 : CometChatTheme.palatte.error
            icon.tintColor =  isLoggedInUser ? CometChatTheme.palatte.accent500 : CometChatTheme.palatte.error
            view.set(borderColor: isLoggedInUser ? .clear : CometChatTheme.palatte.error)
            
        case .cancelled where call.receiverType == .user:
            let callStatus: String = isLoggedInUser ? "CALL_CANCELLED".localize() : "MISSED_CALL".localize()
            view.text = spacer + callStatus
            view.textColor =  isLoggedInUser ? CometChatTheme.palatte.accent900 : CometChatTheme.palatte.error
            icon.tintColor =  isLoggedInUser ? CometChatTheme.palatte.accent500 : CometChatTheme.palatte.error
            view.set(borderColor: isLoggedInUser ? .clear : CometChatTheme.palatte.error)
            
        case .busy where call.receiverType == .user:
            let callStatus: String = isLoggedInUser ? "CALL_REJECTED".localize() : "MISSED_CALL".localize()
            view.text = spacer + callStatus
            view.textColor =  isLoggedInUser ? CometChatTheme.palatte.accent900 : CometChatTheme.palatte.error
            icon.tintColor =  isLoggedInUser ? CometChatTheme.palatte.accent500 : CometChatTheme.palatte.error
            view.set(borderColor: isLoggedInUser ? .clear : CometChatTheme.palatte.error)
            
        case .ended:  view.text = spacer + "CALL_ENDED".localize()
            view.textColor = CometChatTheme.palatte.accent900
            icon.tintColor = CometChatTheme.palatte.accent500
            
        case .ongoing: view.text = spacer + "CALL_ACCEPTED".localize()
            view.textColor = CometChatTheme.palatte.accent900
            icon.tintColor = CometChatTheme.palatte.accent500
            
        case .unanswered:  view.text = spacer + "CALL_UNANSWERED".localize()
        @unknown default: view.text =  spacer + "CALL_CANCELLED".localize()
        }
        
        view.addSubview(icon)
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            icon.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 18),
            icon.heightAnchor.constraint(equalToConstant: 18),
        ])
        
        view.font = CometChatTheme.typography.caption1
        view.set(backgroundColor: .clear)
        stackView.addArrangedSubview(view)
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }
    
    public func getConferenceCallTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: conferenceCallTypeConstant, contentView: { message, alignment, controller in
            guard let call = message as? CustomMessage else { return UIView() }
            if (call.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: call) {
                    return deletedBubble
                }
            }
            let callBubble = CometChatCallBubble(frame: CGRect(x: 0, y: 0, width: 228, height: 130))
            callBubble.set(title: "Conference Call")
            if let icon = self.callingConfiguration?.callBubbleConfiguration?.icon {
                callBubble.set(icon: icon)
            } else {
                callBubble.set(icon: UIImage(named: "video-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
            }
            if message?.sender?.uid == CometChat.getLoggedInUser()?.uid {
                callBubble.set(subTitle: "YOU_INITIATED_GROUP_VIDEO_CALL".localize())
            } else {
                callBubble.set(subTitle: "\(call.sender?.name?.capitalized ?? "") " + "HAS_INITIATED_GROUP_AUDIO_CALL".localize())
            }
            if let callBubbleStyle = self.callingConfiguration?.callBubbleConfiguration?.style {
                callBubble.set(style: callBubbleStyle)
            } else {
                callBubble.set(style: CallBubbleStyle())
            }
            callBubble.set(joinButtonText: "JOIN".localize())
            callBubble.setOnClick {
                if let onClick = self.callingConfiguration?.callBubbleConfiguration?.onClick {
                    onClick()
                } else {
                    if let customData = call.customData, let sessionID = customData["sessionID"] as? String {
                        DispatchQueue.main.async {
                            let ongoingCall = CometChatOngoingCall()
                            ongoingCall.set(sessionId: sessionID)
                            ongoingCall.set(callSettingsBuilder: CallingDefaultBuilder.callSettingsBuilder)
                            ongoingCall.set(callWorkFlow: .directCalling)
                            ongoingCall.modalPresentationStyle = .fullScreen
                            controller?.present(ongoingCall, animated: true)
                        }
                    }
                }
            }
            return callBubble
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message = message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            return nil
        }
        
    }
    
    override func getId() -> String {
        return "Call"
    }
    
    override func getLastConversationMessage(conversation: Conversation, isDeletedMessagesHidden: Bool) -> String? {
        
        if let lastMessage = conversation.lastMessage as? Call {
            switch lastMessage.callType {
            case .audio:
                return "Audio Call"
            case .video:
                return "Video Call"
            @unknown default: break
            }
        } else if let lastMessage = conversation.lastMessage as? CustomMessage, lastMessage.type == conferenceCallTypeConstant {
            return "Conference Call"
        }
        return super.getLastConversationMessage(conversation: conversation, isDeletedMessagesHidden: isDeletedMessagesHidden)
    }
    
    override func getAuxiliaryHeaderMenu(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIStackView? {
        if let user = user {
            let callButton = CometChatCallButtons(width: 75, height: 40)
            callButton.set(controller: controller)
            callButton.set(user: user)
            setupConfigurationFor(callButton: callButton)
            return callButton
        }
        if let group = group {
            let callButton = CometChatCallButtons(width: 75, height: 40)
            callButton.set(controller: controller)
            callButton.set(group: group)
            setupConfigurationFor(callButton: callButton)
            return callButton
        }
        return nil
    }
    
    private func setupConfigurationFor(callButton: CometChatCallButtons) {
        if let callButtonConfiguration = self.callingConfiguration?.callButtonConfiguration {
            if let videoCallIcon = callButtonConfiguration.videoCallIcon {
                callButton.set(videoCallIcon: videoCallIcon)
            }
            if let voiceCallIcon = callButtonConfiguration.voiceCallIcon {
                callButton.set(voiceCallIcon: voiceCallIcon)
            }
            if let hideVideoCall = callButtonConfiguration.hideVideoCall {
                callButton.hide(videoCall: hideVideoCall)
            }
            if let hideVoiceCall = callButtonConfiguration.hideVoiceCall {
                callButton.hide(videoCall: hideVoiceCall)
            }
            if let callButtonsStyle = callButtonConfiguration.callButtonsStyle {
                callButton.set(callButtonsStyle: callButtonsStyle)
            }
            if let onVideoCallClick = callButtonConfiguration.onVideoCallClick {
                callButton.setOnVideoCallClick(onVideoCallClick: onVideoCallClick)
            }
            if let onVoiceCallClick = callButtonConfiguration.onVoiceCallClick {
                callButton.setOnVoiceCallClick(onVoiceCallClick: onVoiceCallClick)
            }
            if let onError = callButtonConfiguration.onError {
                callButton.setOnError(onError: onError)
            }
        }
        if let outgoingCallConfiguration = self.callingConfiguration?.outgoingCallConfiguration {
            callButton.set(outgoingCallConfiguration: outgoingCallConfiguration)
        }
    }
    
}

extension CallingExtensionDecorator: CometChatCallDelegate {
    
    func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        DispatchQueue.main.async {
            
            if let call = incomingCall {
                let incomingCall = CometChatIncomingCall().set(call: call)
                if let incomingCallConfiguration = self.callingConfiguration?.incomingCallConfiguration {
                    
                    if let declineButtonIcon = incomingCallConfiguration.declineButtonIcon {
                        incomingCall.set(declineButtonIcon: declineButtonIcon)
                    }
                    if let acceptButtonIcon = incomingCallConfiguration.acceptButtonIcon {
                        incomingCall.set(acceptButtonIcon: acceptButtonIcon)
                    }
                    if let disableSoundForCalls = incomingCallConfiguration.disableSoundForCalls {
                        incomingCall.disable(soundForCalls: disableSoundForCalls)
                    }
                    if let customSoundForCalls = incomingCallConfiguration.customSoundForCalls {
                        incomingCall.set(customSoundForCalls: customSoundForCalls)
                    }
                    if let avatarStyle = incomingCallConfiguration.avatarStyle {
                        incomingCall.set(avatarStyle: avatarStyle)
                    }
                    if let acceptButtonStyle = incomingCallConfiguration.acceptButtonStyle {
                        incomingCall.set(acceptButtonStyle: acceptButtonStyle)
                    }
                    if let declineButtonStyle = incomingCallConfiguration.declineButtonStyle {
                        incomingCall.set(declineButtonStyle: declineButtonStyle)
                    }
                    if let incomingCallStyle = incomingCallConfiguration.incomingCallStyle {
                        incomingCall.set(incomingCallStyle: incomingCallStyle)
                    }
                }
                
                incomingCall.modalPresentationStyle = .fullScreen
                if let window = UIApplication.shared.windows.first , let rootViewController = window.rootViewController {
                    var currentController = rootViewController
                    while let presentedController = currentController.presentedViewController {
                        currentController = presentedController
                    }
                    currentController.present(incomingCall, animated: true, completion: nil)
                }
            }
        }
    }
    
    func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
    
    func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
    
    func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
}
#endif
