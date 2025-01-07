//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 15/02/23.
//

import CometChatSDK
import UIKit
import Foundation

class StickersExtensionDecorator: DataSourceDecorator {

    var stickerTypeConstant = "extension_sticker"
    var configuration : StickerConfiguration?
    var anInterface : DataSource?
    
    public override init(dataSource: DataSource) {
        super.init(dataSource: dataSource)
        self.anInterface = dataSource
    }
    
    public init(dataSource: DataSource, configuration: StickerConfiguration?) {
        super.init(dataSource: dataSource)
        self.anInterface = dataSource
        self.configuration = configuration
    }
    
    override func getAllMessageTemplates(additionalConfiguration: AdditionalConfiguration?) -> [CometChatMessageTemplate] {
        var templates = super.getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        templates.append(getTemplate(additionalConfiguration: additionalConfiguration))
        return templates
    }
    
    override func getAuxiliaryOptions(user: User?, group: Group?, controller: UIViewController?, id: [String : Any]?) -> UIView? {
        var auxiliaryButtons: UIStackView = UIStackView()
        if let view = super.getAuxiliaryOptions(user: user, group: group, controller: controller, id: id) as? UIStackView {
            auxiliaryButtons = view
        }
        auxiliaryButtons.addArrangedSubview(getStickerAuxiliaryButton(user: user, group: group, controller: controller, id: id))
        
        return auxiliaryButtons
    }
    
    override func getAllMessageTypes() -> [String]? {
        var messageTypes = super.getAllMessageTypes()
        messageTypes?.append(stickerTypeConstant)
        return messageTypes
    }
    
    override func getAllMessageCategories() -> [String]? {
        if let categories = super.getAllMessageCategories(), !categories.contains(obj: MessageCategoryConstants.custom) {
            var messageCategories = categories
            messageCategories.append(MessageCategoryConstants.custom)
            return messageCategories
        }
        return super.getAllMessageCategories()
    }
    
    public func getTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.custom, type: stickerTypeConstant, contentView: { message, alignment, controller in
            guard let message = message as? CustomMessage else { return UIView() }
            if (message.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: message, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            if let customData = message.customData, let stickerUrl = customData["sticker_url"] as? String {
                let stickerBubble = self.getStickerMessageBubble(stickerUrl: stickerUrl, message: message, controller: controller, style: StickerBubbleStyle(), additionalConfiguration: additionalConfiguration)
                return stickerBubble
            }
            return UIView()
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let message = message else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: message, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let message = message, let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: user, messageObject: message, controller: controller, group: group)
        }
        
    }
    
    public override func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate? {
        if messageType == MessageCategoryConstants.custom && messageCategory == stickerTypeConstant {
            return getTemplate(additionalConfiguration: additionalConfiguration)
        }
        return super.getMessageTemplate(messageType: messageType, messageCategory: messageCategory)
    }
    
    public func getStickerMessageBubble(stickerUrl: String?, message: CometChatSDK.CustomMessage?, controller: UIViewController?, style: StickerBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        let stickerBubble = CometChatStickerBubble()
        stickerBubble.set(imageUrl: stickerUrl ?? "")
        
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message?.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.stickersBubbleStyle { stickerBubble.style = style }
        
        stickerBubble.style.backgroundColor = .clear
        stickerBubble.imageView.contentMode = .scaleAspectFit
        stickerBubble.pin(anchors: [.height, .width], to: 160)
        return stickerBubble
    }
    
    public func getStickerAuxiliaryButton(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIView {
      
        let stickerAuxillaryButton = StickerAuxiliaryButton().withoutAutoresizingMaskConstraints()
        stickerAuxillaryButton.pin(anchors: [.width, .height], to: 24)
        let stickerKeyboard = getStickerKeyboard(user: user, group: group, controller: controller, id: id)
        stickerAuxillaryButton.setOnStickerTap {
            let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackLight.impactOccurred()
            
            CometChatUIEvents.showPanel(id: id, alignment: .composerBottom, view: stickerKeyboard)
        }
        stickerAuxillaryButton.setOnKeyboardTap {
            let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackLight.impactOccurred()
            
            CometChatUIEvents.hidePanel(id: id, alignment: .composerBottom)
        }
        return stickerAuxillaryButton
    }

    override func getId() -> String {
        return "stickers"
    }
    
    public override func getLastConversationMessage(conversation: Conversation, isDeletedMessagesHidden: Bool, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        if let customMessage = conversation.lastMessage as? CustomMessage, let additionalConfiguration {
            if customMessage.type == MessageTypeConstants.sticker {
                return addImageToText(text: ConversationConstants.customMessageSticker, image: "messages-stickers", additionalConfiguration: additionalConfiguration)
            }
        }
        return super.getLastConversationMessage(conversation: conversation, isDeletedMessagesHidden: isDeletedMessagesHidden, additionalConfiguration: additionalConfiguration)
    }
    
    public func getStickerKeyboard(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> CometChatStickerKeyboard {
        let stickerKeyboard = CometChatStickerKeyboard()
        stickerKeyboard.setOnStickerTap { sticker in
            var stickerData = [String: Any]()
            var metaData = [String: Any]()
            let pushNotificationMessage = "HAS_SHARED_A_STICKER".localize()
            
            stickerData["sticker_url"] = sticker.url
            stickerData["sticker_name"] = sticker.name
            metaData["incrementUnreadCount"] = true
            metaData["pushNotification"] = pushNotificationMessage
            
            var customMessage: CustomMessage?
            if user != nil {
                customMessage = CustomMessage(receiverUid: user?.uid ?? "", receiverType: .user, customData: stickerData, type: self.stickerTypeConstant)
            }
            if group != nil {
                customMessage = CustomMessage(receiverUid: group?.guid ?? "", receiverType: .group, customData: stickerData, type: self.stickerTypeConstant)
            }
            if let parentMessageId = id?["parentMessageId"] as? Int {
                customMessage?.parentMessageId = parentMessageId
            }
    
            customMessage?.updateConversation = true
            if let customMessage = customMessage {
                customMessage.muid = "\(Int(Date().timeIntervalSince1970))"
                customMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                customMessage.sender = CometChat.getLoggedInUser()
                CometChatUIKit.sendCustomMessage(message: customMessage)
            }
        }
        return stickerKeyboard
    }
}
