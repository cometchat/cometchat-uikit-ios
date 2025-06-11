//
//  File.swift
//
//
//  Created by Pushpsen Airekar on 14/02/23.
//

import Foundation
import CometChatSDK
import UIKit

public class MessagesDataSource: DataSource {

    public func getEditOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.editMessage, title: "EDIT".localize(), icon: AssetConstants.edit)
    }
    
    public func getDeleteOption(controller: UIViewController?) -> CometChatMessageOption {
        
        var messageOptionStyle = MessageOptionStyle()
        messageOptionStyle.titleColor = CometChatTheme.errorColor
        messageOptionStyle.imageTintColor = CometChatTheme.errorColor
        
        return CometChatMessageOption(id: MessageOptionConstants.deleteMessage, title: "DELETE_MESSAGE".localize(), icon: AssetConstants.delete, style: messageOptionStyle)
    }
    
    public func getReplyOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.replyMessage, title: "REPLY".localize(), icon: AssetConstants.reply)
    }
    
    public func getShareOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.shareMessage, title: "SHARE".localize(), icon: AssetConstants.share)
    }
    
    public func getMessagePrivatelyOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.messagePrivately, title: "MESSAGE_PRIVATELY".localize(), icon: AssetConstants.privately)
    }
    
    public func getReplyInThreadOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.replyInThread, title: "REPLY_IN_THREAD".localize(), icon: AssetConstants.thread)
    }
    
    public func getCopyOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.copyMessage, title: "COPY".localize(), icon: AssetConstants.copy)
    }
    
    public func getForwardOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.forwardMessage, title: "FORWARD_MESSAGE".localize(), icon: AssetConstants.forward)
    }
    
    public func getInformationOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.messageInformation, title: "INFO".localize(), icon: AssetConstants.messageInfo)
    }
    
    public func isSentByMe(loggedInUser: User, message: BaseMessage) -> Bool {
        return loggedInUser.uid == message.sender?.uid;
    }
    
    public func getTextMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        
        let isSentByMe = isSentByMe(loggedInUser: loggedInUser, message: messageObject)
        var messageOptions = [CometChatMessageOption]()
        
        if (messageObject.parentMessageId == 0) && !additionalConfiguration.hideReplyInThreadOption {
            messageOptions.append(getReplyInThreadOption(controller: controller))
        }
        
        if isMessageCategory(message: messageObject) && !additionalConfiguration.hideShareMessageOption {
            messageOptions.append(getShareOption(controller: controller))
        }
        
        if !additionalConfiguration.hideCopyMessageOption{
            messageOptions.append(getCopyOption(controller: controller))
        }
        
        if isSentByMe && !additionalConfiguration.hideEditMessageOption {
            messageOptions.append(getEditOption(controller: controller))
        }
        
        if isSentByMe && !additionalConfiguration.hideMessageInfoOption {
            messageOptions.append(getInformationOption(controller: controller))
        }
        
        if (isSentByMe || group?.scope == .admin || group?.scope == .moderator) && !additionalConfiguration.hideDeleteMessageOption  {
            messageOptions.append(getDeleteOption(controller: controller))
        }
        
        if (group != nil && !isSentByMe) && !additionalConfiguration.hideMessagePrivatelyOption {
            messageOptions.append(getMessagePrivatelyOption(controller: controller))
        }
        
        if isSentByMe && (messageObject.metaData?["error"] as? Bool == true){
            return nil
        }
        
        return messageOptions
    }
    
    public func getImageMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        var messageOptions = [CometChatMessageOption]()
        messageOptions.append(contentsOf: ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration))
        return messageOptions
    }
    
    public func getVideoMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        var messageOptions = [CometChatMessageOption]()
        messageOptions.append(contentsOf: ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration))
        return messageOptions
    }
    
    public func getAudioMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        var messageOptions = [CometChatMessageOption]()
        messageOptions.append(contentsOf: ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration))
        return messageOptions
    }
    
    public func getFileMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        var messageOptions = [CometChatMessageOption]()
        messageOptions.append(contentsOf: ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration))
        return messageOptions
    }
    
    public func getDeleteMessageBubble(messageObject: CometChatSDK.BaseMessage, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        
        let style = additionalConfiguration?.messageBubbleStyle
        let isLoggedInUser = messageObject.sender?.uid == LoggedInUserInformation.getUID()
        let deleteBubbleStyle = isLoggedInUser ? style?.outgoing.deleteBubbleStyle : style?.incoming.deleteBubbleStyle
        
        let deleteBubble = CometChatDeleteBubble()
        if let deleteBubbleStyle { deleteBubble.style = deleteBubbleStyle }
        return deleteBubble
    }
    
    public func getGroupActionBubble(messageObject: CometChatSDK.BaseMessage, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        let isLoggedIn = (messageObject.sender?.uid == LoggedInUserInformation.getUID())
        let actionBubbleStyle = additionalConfiguration?.actionBubbleStyle
        let view = CometChatGroupActionBubble()
        view.set(messageObject: messageObject)
        if let style = actionBubbleStyle{ view.style = style}
        return view
    }
    
    public func getBottomView(message: CometChatSDK.BaseMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return UIStackView()
    }
    
    public func getTextMessageTemplate() -> CometChatMessageTemplate {
        self.getTextMessageTemplate(additionalConfiguration: nil)
    }
    
    public func getTextMessageTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.text, contentView: { message, alignment, controller in
            guard let textMessage = message as? TextMessage else { return UIView() }
            if (textMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: textMessage, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getTextMessageContentView(message: textMessage, controller: controller, alignment: alignment, style: TextBubbleStyle(), additionalConfiguration: additionalConfiguration)
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let textMessage = message as? TextMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: textMessage, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let textMessage = message as? TextMessage , let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: textMessage, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }

    }
    
    public func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return ChatConfigurator.getDataSource().getTextMessageBubble(messageText: message.text, message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getAudioMessageTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.audio, contentView: { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return UIView() }
            if (mediaMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: mediaMessage, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getAudioMessageContentView(message: mediaMessage, controller: controller, alignment: alignment, style: AudioBubbleStyle(), additionalConfiguration: additionalConfiguration)
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: mediaMessage, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let mediaMessage = message as? MediaMessage , let user = LoggedInUserInformation.getUser() else {return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: mediaMessage, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }

    }
    
    public func getAudioMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AudioBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return ChatConfigurator.getDataSource().getAudioMessageBubble(audioUrl: message.attachment?.fileUrl, title: message.attachment?.fileName, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getFormMessageTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.interactive, type: MessageTypeConstants.form, contentView: { message, alignment, controller in
            guard let formMessage = message as? FormMessage else { return UIView() }
            if (formMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: formMessage, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getFormMessageContentView(message: formMessage, controller: controller, alignment: alignment, style: FormBubbleStyle(), additionalConfiguration: additionalConfiguration)
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let formMessage = message as? FormMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: formMessage, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let formMessage = message as? FormMessage , let user = LoggedInUserInformation.getUser() else {return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: formMessage, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }

    }
    
    public func getSchedulerMessageTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.interactive, type: MessageTypeConstants.scheduler, contentView: { message, alignment, controller in
            guard let meetingMessage = message as? SchedulerMessage else { return UIView() }
            if (meetingMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: meetingMessage, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getSchedulerBubble(message: meetingMessage, controller: controller, alignment: alignment, style: SchedulerBubbleStyle(), additionalConfiguration: additionalConfiguration)
        }, bubbleView: nil, headerView: nil, footerView: nil, bottomView: { message, alignment, controller in
            guard let cardMessage = message as? CardMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: cardMessage, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        }, options: { message, group, controller in
            guard let meetingMessage = message as? SchedulerMessage , let user = LoggedInUserInformation.getUser() else {return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: meetingMessage, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        })
    }
    
    public func getCardMessageTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.interactive, type: MessageTypeConstants.card, contentView: { message, alignment, controller in
            guard let cardMessage = message as? CardMessage else { return UIView() }
            if (cardMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: cardMessage, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getCardMessageContentView(message: cardMessage, controller: controller, alignment: alignment, style: CardBubbleStyle(), additionalConfiguration: additionalConfiguration)
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let cardMessage = message as? CardMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: cardMessage, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let cardMessage = message as? CardMessage , let user = LoggedInUserInformation.getUser() else {return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: cardMessage, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }

    }
    
    public func getFormMessageContentView(message: FormMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return ChatConfigurator.getDataSource().getFormBubble(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
        
    }
    
    public func getSchedulerContentView(message: SchedulerMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return ChatConfigurator.getDataSource().getSchedulerBubble(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getCardMessageContentView(message: CardMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return ChatConfigurator.getDataSource().getCardBubble(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
        
    }
    
    public func getVideoMessageTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.video, contentView: { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return UIView() }
            if (mediaMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: mediaMessage, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getVideoMessageContentView(message: mediaMessage, controller: controller, alignment: alignment, style: VideoBubbleStyle(), additionalConfiguration: additionalConfiguration)
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: mediaMessage, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let mediaMessage = message as? MediaMessage , let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: mediaMessage, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }
    }
    
    public func getVideoMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: VideoBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return ChatConfigurator.getDataSource().getVideoMessageBubble(videoUrl: message.attachment?.fileUrl, thumbnailUrl: nil, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getImageMessageTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.image, contentView: { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return UIView() }
            if (mediaMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: mediaMessage, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getImageMessageContentView(message: mediaMessage, controller: controller, alignment: alignment, style: ImageBubbleStyle(), additionalConfiguration: additionalConfiguration)
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: mediaMessage, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let mediaMessage = message as? MediaMessage , let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: mediaMessage, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }

    }
    
    public func getImageMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ImageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        
        return ChatConfigurator.getDataSource().getImageMessageBubble(imageUrl: message.attachment?.fileUrl, caption: message.caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
    }
   
    
    public func getGroupActionTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.action, type: MessageTypeConstants.groupMember, contentView: { message, alignment, controller in
            guard let message = message else { return UIView() }
            return self.getGroupActionBubble(messageObject: message, additionalConfiguration: additionalConfiguration)
        }, bubbleView: nil, headerView: nil, footerView: nil, bottomView: nil, options: nil)
    }
    
    //Doubt: Why no view is building
    public func getDefaultMessageActionsTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.action, type: MessageTypeConstants.message, contentView: nil, bubbleView: nil, headerView: nil, footerView: nil, bottomView: nil, options: nil)
    }
    
    public func getFileMessageTemplate(additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.file, contentView: { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return UIView() }
            if (mediaMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: mediaMessage, additionalConfiguration: additionalConfiguration) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getFileMessageContentView(message: mediaMessage, controller: controller, alignment: alignment, style: FileBubbleStyle(), additionalConfiguration: additionalConfiguration)
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: mediaMessage, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
        } options: { message, group, controller in
            guard let mediaMessage = message as? MediaMessage , let user = LoggedInUserInformation.getUser() else {return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: mediaMessage, controller: controller, group: group, additionalConfiguration: additionalConfiguration ?? AdditionalConfiguration())
        }

    }
    
    public func getFileMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FileBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return ChatConfigurator.getDataSource().getFileMessageBubble(fileUrl: message.attachment?.fileUrl, fileMimeType: message.attachment?.fileMimeType, title: message.attachment?.fileName, id: message.id, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getAllMessageTemplates(additionalConfiguration: AdditionalConfiguration?) -> [CometChatMessageTemplate] {
        return [
            ChatConfigurator.getDataSource().getTextMessageTemplate(additionalConfiguration: additionalConfiguration),
            ChatConfigurator.getDataSource().getImageMessageTemplate(additionalConfiguration: additionalConfiguration),
            ChatConfigurator.getDataSource().getVideoMessageTemplate(additionalConfiguration: additionalConfiguration),
            ChatConfigurator.getDataSource().getAudioMessageTemplate(additionalConfiguration: additionalConfiguration),
            ChatConfigurator.getDataSource().getFileMessageTemplate(additionalConfiguration: additionalConfiguration),
            ChatConfigurator.getDataSource().getGroupActionTemplate(additionalConfiguration: additionalConfiguration),
            ChatConfigurator.getDataSource().getFormMessageTemplate(additionalConfiguration: additionalConfiguration),
            ChatConfigurator.getDataSource().getCardMessageTemplate(additionalConfiguration: additionalConfiguration),
            ChatConfigurator.getDataSource().getSchedulerMessageTemplate(additionalConfiguration: additionalConfiguration)
        ]
    }
    
    public func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration: AdditionalConfiguration?) -> CometChatMessageTemplate? {
        var template : CometChatMessageTemplate?
        if (messageCategory != MessageCategoryConstants.call) {
            switch (messageType) {
            case MessageTypeConstants.text:
                template = ChatConfigurator.getDataSource()
                    .getTextMessageTemplate(additionalConfiguration: additionalConfiguration)
                
            case MessageTypeConstants.image:
                template = ChatConfigurator.getDataSource()
                    .getImageMessageTemplate(additionalConfiguration: additionalConfiguration)
                
            case MessageTypeConstants.video:
                template = ChatConfigurator.getDataSource()
                    .getVideoMessageTemplate(additionalConfiguration: additionalConfiguration)
                
            case MessageTypeConstants.groupMember:
                template = ChatConfigurator.getDataSource()
                    .getGroupActionTemplate(additionalConfiguration: additionalConfiguration)
                
            case MessageTypeConstants.file:
                template = ChatConfigurator.getDataSource()
                    .getFileMessageTemplate(additionalConfiguration: additionalConfiguration)
                
            case MessageTypeConstants.audio:
                template = ChatConfigurator.getDataSource()
                    .getAudioMessageTemplate(additionalConfiguration: additionalConfiguration)
                
            case MessageTypeConstants.form:
                template = ChatConfigurator.getDataSource()
                    .getFormMessageTemplate(additionalConfiguration: additionalConfiguration)
                
            case MessageTypeConstants.card:
                template = ChatConfigurator.getDataSource()
                    .getCardMessageTemplate(additionalConfiguration: additionalConfiguration)
                default: break }
        }
        return template
    }
    
    public func getMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        var options = [CometChatMessageOption]()
        if (messageObject.messageCategory == .message) {
            switch messageObject.messageType {
            case .text:
                options = ChatConfigurator.getDataSource().getTextMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration) ?? []
                
            case .image:
                options = ChatConfigurator.getDataSource().getImageMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration) ?? []
                
            case .video:
                options = ChatConfigurator.getDataSource().getVideoMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration) ?? []
            case .audio:
                options = ChatConfigurator.getDataSource().getAudioMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration) ?? []
            case .file:
                options = ChatConfigurator.getDataSource().getFileMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration) ?? []
            case .custom:
                options = ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
            case .groupMember: options = []
            @unknown default: break
            }
        }
        if let messageObject = messageObject as? InteractiveMessage, messageObject.messageCategory == .interactive {
            switch messageObject.type {
            case MessageTypeConstants.form, MessageTypeConstants.card, MessageTypeConstants.scheduler:
                options = ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
            default: break
            }
        }
        return options
    }
    
    public func getCommonOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption] {
        var options = [CometChatMessageOption]()
        let isSentByMe = isSentByMe(loggedInUser: loggedInUser, message: messageObject)
        
        if (messageObject.parentMessageId == 0) && !additionalConfiguration.hideReplyInThreadOption {
            options.append(getReplyInThreadOption(controller: controller))
        }
        
        if isMessageCategory(message: messageObject) {
            options.append(getShareOption(controller: controller))
        }
        if isSentByMe && !additionalConfiguration.hideMessageInfoOption {
            options.append(getInformationOption(controller: controller))
        }
        
        if (isSentByMe || group?.scope == .admin || group?.scope == .moderator) && !additionalConfiguration.hideDeleteMessageOption  {
            options.append(getDeleteOption(controller: controller))
        }
        
        if group != nil && !isSentByMe && !additionalConfiguration.hideMessagePrivatelyOption {
            options.append(getMessagePrivatelyOption(controller: controller))
        }
        
        return options
    }
    
    public func getMessageTypeToSubtitle(messageType: String, controller: UIViewController) -> String? {
        var subtitle = messageType
        switch (messageType) {
        case MessageTypeConstants.text:
            subtitle = ""
        case MessageTypeConstants.image:
            subtitle = "MESSAGE_IMAGE".localize()
        case MessageTypeConstants.video:
            subtitle = "MESSAGE_VIDEO".localize()
        case MessageTypeConstants.file:
            subtitle = "MESSAGE_FILE".localize()
        case MessageTypeConstants.audio:
            subtitle = "MESSAGE_AUDIO".localize()
        case MessageTypeConstants.form:
            subtitle = "FORM".localize()
        case MessageTypeConstants.card:
            subtitle = "CARD".localize()
        default: break
        }
        return subtitle
    }
    
    public func takePhotoOption(controller: UIViewController?) -> CometChatMessageComposerAction{
        return CometChatMessageComposerAction(id: ComposerAttachmentConstants.camera, text: "TAKE_A_PHOTO".localize(), startIcon: UIImage(systemName: "camera.fill") ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil)
    }
    
    public func photoAndVideoLibraryOption(controller: UIViewController?) -> CometChatMessageComposerAction{
        return   CometChatMessageComposerAction(id: ComposerAttachmentConstants.gallery, text: "PHOTO_VIDEO_LIBRARY".localize(), startIcon:  UIImage(systemName: "photo.fill") ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil)
    }
    
    public func fileAttachmentOption(controller: UIViewController?) -> CometChatMessageComposerAction{
        return    CometChatMessageComposerAction(id: ComposerAttachmentConstants.file, text: "CUSTOM_MESSAGE_DOCUMENT".localize(), startIcon: UIImage(systemName: "doc.on.doc.fill") ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil)
    }
    
    
    public func getAttachmentOptions(controller: UIViewController, user: CometChatSDK.User?, group: CometChatSDK.Group?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageComposerAction]? {
        
        var composerAction: [CometChatMessageComposerAction] = []
        
        if !additionalConfiguration.hideImageAttachmentOption{
            composerAction.append(takePhotoOption(controller: controller))
        }
        
        if !additionalConfiguration.hideVideoAttachmentOption{
            composerAction.append(photoAndVideoLibraryOption(controller: controller))
        }
        
        if !additionalConfiguration.hideFileAttachmentOption{
            composerAction.append(fileAttachmentOption(controller: controller))
        }
        
        return composerAction
    }
    
    public func getAIOptions(controller: UIViewController, user: CometChatSDK.User?, group: CometChatSDK.Group?, id: [String : Any]?, aiOptionsStyle: AIOptionsStyle?) -> [CometChatMessageComposerAction]? {
        return [CometChatMessageComposerAction]()
    }
    
    public func getAllMessageTypes() -> [String]? {
        return [
            MessageTypeConstants.text,
            MessageTypeConstants.image,
            MessageTypeConstants.audio,
            MessageTypeConstants.video,
            MessageTypeConstants.file,
            MessageTypeConstants.groupMember,
            MessageTypeConstants.form,
            MessageTypeConstants.card,
            MessageTypeConstants.scheduler
        ]
    }
    
    public func getAllMessageCategories() -> [String]? {
        return [MessageCategoryConstants.message, MessageCategoryConstants.action]
    }
    
    public func getAuxiliaryOptions(user: CometChatSDK.User?, group: CometChatSDK.Group?, controller: UIViewController?, id: [String : Any]?) -> UIView? {
        return UIStackView()
    }
    
    public func getId() -> String {
        return "messageUtils";
    }
    
    public func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        
        let videoBubble = CometChatVideoBubble()
        
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message?.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.videoBubbleStyle { videoBubble.style = style }
        
        if let thumbnailUrl = thumbnailUrl {
            videoBubble.set(thumnailImageUrl: thumbnailUrl, sentAt: Double(message?.sentAt ?? 0))
        }
        
        ///setting local url
        if CometChat.getLoggedInUser()?.uid == message?.senderUid,
           let localFileURLString = message?.metaData?["fileURL"] as? String,
           let localURL = URL(string: localFileURLString),
           localURL.checkFileExist(),
           thumbnailUrl == nil
        {
            videoBubble.set(videoURL: localFileURLString)
        } else {
            videoBubble.set(videoURL: message?.attachment?.fileUrl ?? "")
        }
        
        if let controller = controller {
            videoBubble.set(controller: controller)
        }
        return videoBubble
    }
    
    public func getTextMessageBubble(messageText: String?, message: CometChatSDK.TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        
        let textBubble = CometChatTextBubble()
        textBubble.controller = controller
        
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message?.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.textBubbleStyle { textBubble.style = style }
        
        //processing for TextFormatter
        let textFormatter = additionalConfiguration?.textFormatter ?? []
        if let attributedString = MessageUtils.processTextFormatter(for: message, customText: messageText, in: textBubble.label, textFormatter: textFormatter, controller: controller, alignment: alignment) {
            textBubble.set(attributedText: attributedString)
        } else {
            textBubble.set(text: messageText ?? message?.text ?? "")
        }
        
        return textBubble
    }
    
    public func getImageMessageBubble(imageUrl: String?, caption: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        
        let imageBubble = CometChatImageBubble()
        imageBubble.pin(anchors: [.height, .width], to: 232)
        
        var localImageURL: String?
        if message?.senderUid == CometChat.getLoggedInUser()?.uid {
            localImageURL = message?.metaData?["fileURL"] as? String ///setting image from local path
        }
        
        imageBubble.set(imageUrl: message?.attachment?.fileUrl ?? "", localFileURL: localImageURL, thumbnailURL: imageUrl)

        if let style = style { imageBubble.style = style }
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message?.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.imageBubbleStyle { imageBubble.style = style }
        
        if let controller = controller {
            imageBubble.set(controller: controller)
        }
        
        return imageBubble
    }
    
    public func getAudioMessageBubble(audioUrl: String?, title: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: AudioBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        let audioBubble = CometChatAudioBubble()
        audioBubble.pin(anchors: [.height], to: 50)
        audioBubble.pin(anchors: [.width], to: 240)
        audioBubble.set(fileURL: message?.attachment?.fileUrl ?? "")
        
        
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message?.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.audioBubbleStyle { audioBubble.style = style }

        
        if let controller = controller {
            audioBubble.set(controller: controller)
        }
        return audioBubble
    }
    
    public func getFileMessageBubble(fileUrl: String?, fileMimeType: String?, title: String?, id: Int?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: FileBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        
        let fileLocalURL = URL(string: message?.metaData?["fileURL"] as? String ?? "")

        let fileBubble = CometChatFileBubble()
        fileBubble.set(title: message?.attachment?.fileName.capitalized ?? fileLocalURL?.lastPathComponent ?? "")
        fileBubble.fileImage = CometChatFileBubble.getFileIcon(for: message!, localURL: URL(string: (message?.metaData?["fileURL"] as? String) ?? ""))
        
        var subtitleString = ""
        subtitleString.append(contentsOf: "\(message?.sentAt.toDateFormatted() ?? Int(Date().timeIntervalSince1970).toDateFormatted())")
        subtitleString.append(contentsOf: " • ")
        subtitleString.append(contentsOf: message?.attachment?.fileExtension.capitalized ?? fileLocalURL?.pathExtension ?? "")

        
        fileBubble.set(subtitle: subtitleString)
        fileBubble.set(fileUrl: message?.attachment?.fileUrl ?? "")
        fileBubble.set(cacheFileURL: (message?.metaData?["fileURL"] as? String))
        
        if let controller = controller {
            fileBubble.set(controller: controller)
        }
        
        if let style = style { fileBubble.style = style }
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message?.senderUid)
        let messageBubbleStyle = isLoggedInUser ? additionalConfiguration?.messageBubbleStyle.outgoing : additionalConfiguration?.messageBubbleStyle.incoming
        if let style = messageBubbleStyle?.fileBubbleStyle { fileBubble.style = style }
        
        return fileBubble
    }
    
    public func getFormBubble(message: FormMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        let style = additionalConfiguration?.messageBubbleStyle
        let isLoggedInUser = message?.sender?.uid == LoggedInUserInformation.getUID()
        let deleteBubbleStyle = isLoggedInUser ? style?.outgoing.deleteBubbleStyle : style?.incoming.deleteBubbleStyle
        
        let deleteBubble = CometChatDeleteBubble()
        deleteBubble.messageText = "MESSAGE_TYPE_NOT_SUPPORTED".localize()
        if let deleteBubbleStyle { deleteBubble.style = deleteBubbleStyle }
        return deleteBubble
    }
    
    public func getSchedulerBubble(message: SchedulerMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        let style = additionalConfiguration?.messageBubbleStyle
        let isLoggedInUser = message?.sender?.uid == LoggedInUserInformation.getUID()
        let deleteBubbleStyle = isLoggedInUser ? style?.outgoing.deleteBubbleStyle : style?.incoming.deleteBubbleStyle
        
        let deleteBubble = CometChatDeleteBubble()
        deleteBubble.messageText = "MESSAGE_TYPE_NOT_SUPPORTED".localize()
        if let deleteBubbleStyle { deleteBubble.style = deleteBubbleStyle }
        return deleteBubble
    }
    
    
    public func getCardBubble(message: CardMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        
        //retuning message type not supported
        let style = additionalConfiguration?.messageBubbleStyle
        let isLoggedInUser = message?.sender?.uid == LoggedInUserInformation.getUID()
        let deleteBubbleStyle = isLoggedInUser ? style?.outgoing.deleteBubbleStyle : style?.incoming.deleteBubbleStyle
        
        let deleteBubble = CometChatDeleteBubble()
        deleteBubble.messageText = "MESSAGE_TYPE_NOT_SUPPORTED".localize()
        if let deleteBubbleStyle { deleteBubble.style = deleteBubbleStyle }
        return deleteBubble
        
    }
    
    public func getLastConversationMessage(conversation: Conversation) -> String? {
        return self.getLastConversationMessage(conversation: conversation, additionalConfiguration: nil)?.string
    }
    
    public func getLastConversationMessage(conversation: CometChatSDK.Conversation, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        var lastMessage = ""
        var lastMessageImage: String?
        var attributedLastMessage = NSAttributedString(string: "")
        let textFormatter = additionalConfiguration?.textFormatter
        
        if let currentMessage = conversation.lastMessage {
            
            if currentMessage.deletedAt > 0.0 {
                lastMessage = ConversationConstants.thisMessageDeleted
                lastMessageImage = "deleted-message"
                
            } else {
                
                switch currentMessage.messageCategory {
                case .message:
                    switch currentMessage.messageType {
                    case .text:
                        if let textMessage = currentMessage as? TextMessage {
                            if let textFormatter = textFormatter, !textFormatter.isEmpty {
                                attributedLastMessage = MessageUtils.processTextFormatter(message: textMessage, textFormatter: textFormatter, formattingType: .CONVERSATION_LIST)
                            } else {
                                lastMessage = textMessage.text
                            }
                        }
                    case .image:
                        lastMessage = ConversationConstants.messageImage
                        lastMessageImage = "messages-photo"
                    case .video:
                        lastMessage = ConversationConstants.messageVideo
                        lastMessageImage = "VideoCall"
                    case .audio:
                        lastMessage = ConversationConstants.messageAudio
                        lastMessageImage = "messages-audio-file"
                    case .file:
                        lastMessage = ConversationConstants.messageFile
                        lastMessageImage = "message-document"
                    case .custom:
                        if let customMessage = currentMessage as? CustomMessage {
                            if customMessage.type == MessageTypeConstants.location {
                                lastMessage = ConversationConstants.customMessageLocation
                                lastMessageImage = "messages-location"
                            } else if customMessage.type == MessageTypeConstants.document {
                                lastMessage = ConversationConstants.customMessageDocument
                                lastMessageImage = "message-document"
                            }
                        } else {
                            if let pushNotificationTitle = currentMessage.metaData?["pushNotification"] as? String {
                                if !pushNotificationTitle.isEmpty {
                                    lastMessage = pushNotificationTitle
                                }
                            }
                        }
                    case .groupMember:
                        break
                    @unknown default:
                        break
                    }
                    
                case .action:
                    lastMessage = CometChatUIKit.getActionMessage(baseMessage: currentMessage)
                case .interactive:
                    lastMessage = ConversationConstants.notSupportedMessage
                    lastMessageImage = "deleted-message"
                case .custom:
                    if let customMessage = currentMessage as? CustomMessage {
                        if customMessage.type == MessageTypeConstants.location {
                            lastMessage = ConversationConstants.customMessageLocation
                            lastMessageImage = "messages-location"
                        } else if customMessage.type == MessageTypeConstants.document {
                            lastMessage = ConversationConstants.customMessageDocument
                            lastMessageImage = "message-document"
                        } else if customMessage.type == MessageTypeConstants.meeting {
                            lastMessage = ConversationConstants.hasIntiatedGroupAudioCall
                        } else {
                            if let pushNotificationTitle = customMessage.metaData?["pushNotification"] as? String {
                                if !pushNotificationTitle.isEmpty {
                                    lastMessage = pushNotificationTitle
                                } else {
                                    lastMessage = "\(String(describing: customMessage.customData))"
                                }
                            } else {
                                if let data = customMessage.customData{
                                    lastMessage = String(describing: data)
                                }
                            }
                        }
                    }
                case .call:
                    break
                @unknown default:
                    break
                }
            }
        } else {
            lastMessage = "TAP_TO_START_CONVERSATION".localize()
        }
        
        var prefixString: NSMutableAttributedString?
        
        //Adding Sender name in front of last Message for Group
        if let currentMessage = conversation.lastMessage,
           currentMessage.receiverType == .group,
           currentMessage.messageCategory != .action, let additionalConfiguration {
            if currentMessage.senderUid == CometChat.getLoggedInUser()?.uid {
                prefixString = NSMutableAttributedString(
                    string: "YOU".localize() + ": ",
                    attributes: [.font: CometChatTypography.Body.bold, .foregroundColor: additionalConfiguration.conversationsStyle.listItemSubTitleTextColor]
                )
            } else {
                prefixString = NSMutableAttributedString(
                    string: (currentMessage.sender?.name ?? "") + ": ",
                    attributes: [.font: CometChatTypography.Body.bold, .foregroundColor: additionalConfiguration.conversationsStyle.listItemSubTitleTextColor]
                )
            }
        }
        
        if let prefixString = prefixString, let additionalConfiguration {
            let finalAttributedString = NSMutableAttributedString(attributedString: prefixString)
            
            if let lastMessageImage = lastMessageImage, !lastMessageImage.isEmpty, let image = UIImage(named: lastMessageImage, in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(additionalConfiguration.conversationsStyle.messageTypeImageTint) {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = image
                imageAttachment.bounds = CGRect(x: 0, y: -3.0, width: 16, height: 16)
                
                let imageString = NSAttributedString(attachment: imageAttachment)
                finalAttributedString.append(imageString)
                finalAttributedString.append(NSAttributedString(string: " "))
            }
            
            if !attributedLastMessage.string.isEmpty {
                finalAttributedString.append(attributedLastMessage)
            } else {
                finalAttributedString.append(NSAttributedString(string: lastMessage, attributes: [.font: additionalConfiguration.conversationsStyle.listItemSubTitleFont, .foregroundColor: additionalConfiguration.conversationsStyle.listItemSubTitleTextColor]))
            }
            
            return finalAttributedString
        }
        
        if attributedLastMessage.string.isEmpty {
            if let lastMessageImage = lastMessageImage, !lastMessageImage.isEmpty, let image = UIImage(named: lastMessageImage, in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) , let additionalConfiguration {
                let imageAttachment = NSTextAttachment()
                imageAttachment.image = image.withTintColor(additionalConfiguration.conversationsStyle.messageTypeImageTint)
                imageAttachment.bounds = CGRect(x: 0, y: -3.0, width: 16, height: 16)
                
                let imageString = NSAttributedString(attachment: imageAttachment)
                let finalAttributedString = NSMutableAttributedString()
                finalAttributedString.append(imageString)
                finalAttributedString.append(NSAttributedString(string: " "))
                finalAttributedString.append(NSAttributedString(string: lastMessage, attributes: [.font: additionalConfiguration.conversationsStyle.listItemSubTitleFont, .foregroundColor: additionalConfiguration.conversationsStyle.listItemSubTitleTextColor]))
                
                return finalAttributedString
            } else {
                return NSAttributedString(string: lastMessage)
            }
        } else {
            return attributedLastMessage
        }
    }

    
    public func getAuxiliaryHeaderMenu(user: CometChatSDK.User?, group: CometChatSDK.Group?, controller: UIViewController?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration) -> UIStackView? {
        return nil
    }
    
    func isMessageCategory(message: CometChatSDK.BaseMessage) -> Bool {
        return message.messageCategory == .message ? true : false
    }
    
    public func getTextFormatters() -> [CometChatTextFormatter] {
        return [CometChatMentionsFormatter()]
    }
    
}


extension CometChatUIKit {
    
    static func getActionMessage(baseMessage: BaseMessage) -> String {
        
        if let actionMessage = baseMessage as? ActionMessage {
            if let action = actionMessage.action {
                switch action {
                case .joined:
                    if let user = (actionMessage.actionBy as? User)?.name {
                        return user + " " + "JOINED".localize()
                    }
                case .left:
                    if let user = (actionMessage.actionBy as? User)?.name {
                        return user + " " + "LEFT".localize()
                    }
                case .kicked:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,let actionOn = (actionMessage.actionOn as? User)?.name  {
                        return actionBy + " " + "KICKED".localize() +  " " + actionOn
                    }
                case .banned:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,let actionOn = (actionMessage.actionOn as? User)?.name  {
                        return actionBy + " " + "BANNED".localize() +  " " + actionOn
                    }
                case .unbanned:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,let actionOn = (actionMessage.actionOn as? User)?.name  {
                        return actionBy + " " + "UNBANNED".localize() +  " " + actionOn
                    }
                case .scopeChanged:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,let actionOn = (actionMessage.actionOn as? User)?.name{
                        
                        switch actionMessage.newScope {
                            
                        case .admin:
                            let admin = "ADMIN".localize()
                            return actionBy + " " + "MADE".localize() + " \(actionOn) \(admin)"
                        case .moderator:
                            let moderator = "MODERATOR".localize()
                            return actionBy + " " + "MADE".localize() + " \(actionOn) \(moderator)"
                        case .participant:
                            let participant = "PARTICIPANT".localize()
                            return actionBy + " " + "MADE".localize() + " \(actionOn) \(participant)"
                        @unknown default:
                            break
                        }
                        
                    }
                case .messageEdited:
                    return actionMessage.message ?? ""
                case .messageDeleted:
                    return actionMessage.message ?? ""
                case .added:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,
                        let actionOn = (actionMessage.actionOn as? User)?.name {
                        return actionBy + " " + "ADDED".localize() +  " " + actionOn
                    }
                @unknown default:
                    return "ACTION_MESSAGE".localize()
                }
            }
            
        }
        return ""
    }
}
