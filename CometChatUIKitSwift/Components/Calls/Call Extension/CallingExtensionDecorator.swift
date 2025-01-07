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
    var callingConfiguration: CallingConfiguration?
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
            
            let callAppSettings = CallAppSettingsBuilder()
                .setAppId(uiKitSettings.appID)
                .setRegion(uiKitSettings.region)
                .build()
            
            CometChatCalls.init(callsAppSettings: callAppSettings) {_ in } onError: {_ in }
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
    
    override func getAllMessageTemplates(additionalConfiguration: AdditionalConfiguration?) -> [CometChatMessageTemplate] {
        var templates = super.getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        templates.append(getAudioCallTemplate(additionalConfiguration: additionalConfiguration))
        templates.append(getVideoCallTemplate(additionalConfiguration: additionalConfiguration))
        templates.append(getConferenceCallTemplate(additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration()))
        return templates
    }

    public func getAudioCallTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.call, type: audioCallTypeConstant, contentView: { [weak self] message, alignment, controller in
            guard let this = self else { return UIView() }
            guard let message = message as? Call else { return UIView() }
            return this.getCallActionBubble(call: message, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }, bubbleView: nil, headerView: nil, footerView: nil, bottomView: nil, options: nil)
    }
    
    public func getVideoCallTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.call, type: videoCallTypeConstant, contentView: { [weak self] message, alignment, controller in
            guard let this = self else { return UIView() }
            guard let message = message as? Call else { return UIView() }
            return this.getCallActionBubble(call: message, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }, bubbleView: nil, headerView: nil, footerView: nil, bottomView: nil, options: nil)
    }
    
    public func getCallActionBubble(call: Call, additionalConfiguration: AdditionalConfiguration) -> UIView {
        let view = UIView().withoutAutoresizingMaskConstraints()

        self.call = call
        let isLoggedInUser: Bool = (call.callInitiator as? User)?.uid == LoggedInUserInformation.getUID()
        
        let callType = call.callType
        var icon : String = ""
        var callStatusText = ""
        var textColor: UIColor = additionalConfiguration.callActionBubbleStyle.callTextColor
        let textFont: UIFont = additionalConfiguration.callActionBubbleStyle.callTextFont
        var iconTintColor: UIColor = additionalConfiguration.callActionBubbleStyle.callImageTintColor
        
        switch call.callStatus {
        case .initiated:
            callStatusText = isLoggedInUser ? "OUTGOING_CALL".localize() : "INCOMING_CALL".localize()
            if !isLoggedInUser{
                icon = callType == .audio ? "phone.arrow.down.left" : "arrow.down.left.video"
            }else{
                icon = callType == .audio ? "phone.arrow.up.right" : "arrow.up.right.video"
            }

        case .unanswered:
            callStatusText = "MISSED_CALL".localize()
            icon = callType == .audio ? "phone.arrow.down.left" : "arrow.down.left.video"
            textColor = additionalConfiguration.callActionBubbleStyle.missedCallTextColor
            iconTintColor = additionalConfiguration.callActionBubbleStyle.missedCallImageTintColor

        case .rejected:
            callStatusText = "CALL_REJECTED".localize()
            icon = callType == .audio ? "phone" : "video"

        case .cancelled:
            callStatusText = "CALL_CANCELLED".localize()
            icon = callType == .audio ? "phone" : "video"

        case .busy:
            callStatusText = "MISSED_CALL".localize()
            icon = callType == .audio ? "phone.arrow.down.left" : "arrow.down.left.video"
            textColor = additionalConfiguration.callActionBubbleStyle.missedCallTextColor
            iconTintColor = additionalConfiguration.callActionBubbleStyle.missedCallImageTintColor

        case .ended:
            callStatusText = "CALL_ENDED".localize()
            icon = callType == .audio ? "phone" : "video"

        case .ongoing:
            callStatusText = "CALL_ACCEPTED".localize()
            icon = callType == .audio ? "phone" : "video"
        @unknown default:
            callStatusText = "CALL_CANCELLED".localize()
        }

        let callStatusItem = createCallStatusItem(iconName: icon, title: callStatusText, textColor: textColor, textFont: textFont, imageTintColor: iconTintColor)
        view.addSubview(callStatusItem)
        
        callStatusItem.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p2).isActive = true
        callStatusItem.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p2).isActive = true
        callStatusItem.heightAnchor.constraint(equalToConstant: 32).isActive = true
        callStatusItem.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.heightAnchor.constraint(equalToConstant: 32).isActive = true
        return view
    }

    private func createCallStatusItem(iconName: String, title: String, textColor: UIColor, textFont: UIFont, imageTintColor: UIColor) -> UIStackView {
        let itemStackView = UIStackView().withoutAutoresizingMaskConstraints()
        itemStackView.axis = .horizontal
        itemStackView.alignment = .center
        itemStackView.distribution = .fill
        itemStackView.spacing = CometChatSpacing.Padding.p1

        let iconImageView = UIImageView()
        iconImageView.image = UIImage(systemName: iconName)
        iconImageView.tintColor = imageTintColor
        iconImageView.contentMode = .scaleAspectFit

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.textColor = textColor
        titleLabel.font = textFont

        itemStackView.addArrangedSubview(iconImageView)
        itemStackView.addArrangedSubview(titleLabel)
        iconImageView.pin(anchors: [.height, .width], to: 20)

        return itemStackView
    }

    
    public func getConferenceCallTemplate(additionalConfiguration: AdditionalConfiguration) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: conferenceCallTypeConstant, contentView: { [weak self] message, alignment, controller in
            
            guard let this = self else { return UIView() }
            guard let call = message as? CustomMessage else { return UIView() }
            if (call.deletedAt != 0.0) {
                if let deletedBubble = this.getDeleteMessageBubble(messageObject: call) {
                    return deletedBubble
                }
            }
            
            let callBubble = CometChatCallBubble()
            callBubble.callType = ((((message as? CustomMessage)?.customData?["callType"] as? String) ?? "") == "audio") ? .audio : .video
            callBubble.widthAnchor.constraint(equalToConstant: 240).isActive = true
            callBubble.dateLabel.text = this.formatDate(from: Double(call.sentAt))
            
            if message?.sender?.uid == CometChat.getLoggedInUser()?.uid{
                callBubble.style = additionalConfiguration.messageBubbleStyle.outgoing.callBubbleStyle
            }else{
                callBubble.style = additionalConfiguration.messageBubbleStyle.incoming.callBubbleStyle
            }
            
            callBubble.setOnClick { [weak self, weak controller] callType in
                guard let this = self else { return }
                
                if let customCallback = this.callingConfiguration?.callBubbleConfiguration?.onClick {
                    customCallback()
                    return
                }
                
                if let customData = call.customData, let sessionID = customData["sessionID"] as? String {
                    DispatchQueue.main.async {
                        let ongoingCall = CometChatOngoingCall()
                        ongoingCall.set(sessionId: sessionID)
                        let group = message?.receiver as? Group
                        var user: User?
                        if group == nil {
                            if (message?.receiver as? User)?.uid == CometChat.getLoggedInUser()?.uid {
                                user = message?.sender as? User
                            } else {
                                user = message?.receiver as? User
                            }
                        }
                        if let callSettingsBuilder = this.callingConfiguration?.groupCallSettingsBuilder?(user, group, false) {
                            ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
                        } else {
                            var callSettingsBuilder = CallingDefaultBuilder.callSettingsBuilder as? CometChatCallsSDK.CallSettingsBuilder
                            callSettingsBuilder = callSettingsBuilder?.setIsAudioOnly(callType == .audio ? true : false)
                            if callType == .video {
                                callSettingsBuilder = callSettingsBuilder?.setDefaultAudioMode("SPEAKER")
                            }
                            ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
                        }
                        ongoingCall.set(callWorkFlow: .directCalling)
                        ongoingCall.modalPresentationStyle = .fullScreen
                        controller?.present(ongoingCall, animated: true)
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
    
    func formatDate(from timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    override func getId() -> String {
        return "Call"
    }
    
    override func getLastConversationMessage(conversation: Conversation, isDeletedMessagesHidden: Bool, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        
        if let lastMessage = conversation.lastMessage as? CustomMessage, lastMessage.type == conferenceCallTypeConstant, let additionalConfiguration {
            if lastMessage.sender?.uid == LoggedInUserInformation.getUID() {
                if (lastMessage.customData?["callType"] as? String ?? "") == "video" {
                    return addImageToText(text: ConversationConstants.youInitiatedGroupCall, image: "initiated_video_call", additionalConfiguration: additionalConfiguration)
                } else {
                    return addImageToText(text: ConversationConstants.youInitiatedGroupAudioCall, image: "initiated_voice_call", additionalConfiguration: additionalConfiguration)
                }
                
            } else {
                if let sender = lastMessage.sender?.name {
                    if (lastMessage.customData?["callType"] as? String ?? "") == "video" {
                        return addImageToText(text: sender + " " + ConversationConstants.hasIntiatedGroupCall, image: "received_video_call", additionalConfiguration: additionalConfiguration)
                    } else {
                        return addImageToText(text: sender + " " + ConversationConstants.hasIntiatedGroupAudioCall, image: "received_voice_call", additionalConfiguration: additionalConfiguration)
                    }
                }
            }
        } else if let call = conversation.lastMessage as? Call {
            let isLoggedInUser: Bool = (call.callInitiator as? User)?.uid == LoggedInUserInformation.getUID()
            switch call.callStatus {
            case .initiated:
                return NSAttributedString(string: isLoggedInUser ? "OUTGOING_CALL".localize() : "INCOMING_CALL".localize())
            case .unanswered:
                return NSAttributedString(string: isLoggedInUser ? "CALL_UNANSWERED".localize() :  "MISSED_CALL".localize())
            case .rejected:
                return NSAttributedString(string: isLoggedInUser ? "CALL_REJECTED".localize() : "MISSED_CALL".localize())
            case .cancelled:
                return NSAttributedString(string: isLoggedInUser ? "CALL_CANCELLED".localize() : "MISSED_CALL".localize())
            case .busy:
                return NSAttributedString(string: isLoggedInUser ? "CALL_REJECTED".localize() : "MISSED_CALL".localize())
            case .ended:
                return NSAttributedString(string: "CALL_ENDED".localize())
            case .ongoing:
                return NSAttributedString(string: "CALL_ACCEPTED".localize())
            @unknown default: break
            }
        }

        return super.getLastConversationMessage(conversation: conversation, isDeletedMessagesHidden: isDeletedMessagesHidden, additionalConfiguration: additionalConfiguration)
    }
    
    override func getAuxiliaryHeaderMenu(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIStackView? {
        if let user = user {
            let callButton = CometChatCallButtons(width: 24, height: 24)
            callButton.set(controller: controller)
            callButton.set(user: user)
            setupConfigurationFor(callButton: callButton)
            return callButton
        }
        if let group = group {
            let callButton = CometChatCallButtons(width: 24, height: 24)
            callButton.set(controller: controller)
            callButton.set(group: group)
            setupConfigurationFor(callButton: callButton)
            return callButton
        }
        return nil
    }
    
    private func setupConfigurationFor(callButton: CometChatCallButtons) {
        if let outgoingCallConfiguration = self.callingConfiguration?.outgoingCallConfiguration {
            callButton.set(outgoingCallConfiguration: outgoingCallConfiguration)
        }
        
        if let callButtonConfiguration = callingConfiguration?.callButtonConfiguration {

            if let hideVoiceCall = callButtonConfiguration.hideVoiceCall {
                callButton.hide(voiceCall: hideVoiceCall)
            }
            
            if let hideVideoCall = callButtonConfiguration.hideVideoCall {
                callButton.hide(videoCall: hideVideoCall)
            }
            
            if let callButtonsStyle = callButtonConfiguration.callButtonsStyle {
                callButton.set(callButtonsStyle: callButtonsStyle)
            }
            
            if let onVoiceCallClick = callButtonConfiguration.onVoiceCallClick {
                callButton.setOnVoiceCallClick(onVoiceCallClick: onVoiceCallClick)
            }
            
            if let onVideoCallClick = callButtonConfiguration.onVideoCallClick {
                callButton.setOnVideoCallClick(onVideoCallClick: onVideoCallClick)
            }
            
            if let onError = callButtonConfiguration.onError {
                callButton.setOnError(onError: onError)
            }
            
            if let callSettingsBuilder = callButtonConfiguration.callSettingsBuilder {
                callButton.set(callSettingsBuilder: callSettingsBuilder)
            }
            
            if let outgoingCallConfiguration = callButtonConfiguration.outgoingCallConfiguration {
                callButton.set(outgoingCallConfiguration: outgoingCallConfiguration)
            }
            
        }
    }
    
}

extension CallingExtensionDecorator: CometChatCallDelegate {
    
    func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        
        if CometChatUIKit.uiKitSettings?.enableIncomingCall == false { return }
        if (incomingCall?.callInitiator as? User)?.uid == CometChat.getLoggedInUser()?.uid { return }
        
        DispatchQueue.main.async {
            if let call = incomingCall {
                let incomingCall = CometChatIncomingCall().set(call: call)
                if let incomingCallConfiguration = self.callingConfiguration?.incomingCallConfiguration {
                    if let disableSoundForCalls = incomingCallConfiguration.disableSoundForCalls {
                        incomingCall.disable(soundForCalls: disableSoundForCalls)
                    }
                    if let customSoundForCalls = incomingCallConfiguration.customSoundForCalls {
                        incomingCall.set(customSoundForCalls: customSoundForCalls)
                    }
                    if let callSettingsBuilder = incomingCallConfiguration.callSettingsBuilder {
                        incomingCall.set(callSettingsBuilder: callSettingsBuilder)
                    }
                }
                
                incomingCall.modalPresentationStyle = .overCurrentContext
                if let window = UIApplication.shared.windows.first , let rootViewController = window.rootViewController {
                    rootViewController.present(incomingCall, animated: true, completion: nil)
                }
            }
        }
    }
    
    func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
    
    func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
    
    func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {}
}
#endif
