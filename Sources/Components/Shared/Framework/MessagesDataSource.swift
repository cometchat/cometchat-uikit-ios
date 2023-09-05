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
        return CometChatMessageOption(id: MessageOptionConstants.editMessage, title: "EDIT_MESSAGE".localize(), icon: AssetConstants.edit)
    }
    
    public func getDeleteOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.deleteMessage, title: "DELETE_MESSAGE".localize(), icon: AssetConstants.delete)
    }
    
    public func getReplyOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.replyMessage, title: "REPLY".localize(), icon: AssetConstants.reply)
    }
    
    public func getShareOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.shareMessage, title: "SHARE_MESSAGE".localize(), icon: AssetConstants.share)
    }
    
    public func getMessagePrivatelyOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.messagePrivately, title: "MESSAGE_IN_PRIVATE".localize(), icon: AssetConstants.privately)
    }
    
    public func getReplyInThreadOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.replyInThread, title: "START_THREAD".localize(), icon: AssetConstants.thread)
    }
    
    public func getCopyOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.copyMessage, title: "COPY_MESSAGE".localize(), icon: AssetConstants.copy)
    }
    
    public func getForwardOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.forwardMessage, title: "FORWARD_MESSAGE".localize(), icon: AssetConstants.forward)
    }
    
    public func getInformationOption(controller: UIViewController?) -> CometChatMessageOption {
        return CometChatMessageOption(id: MessageOptionConstants.messageInformation, title: "MESSAGE_INFORMATION".localize(), icon: AssetConstants.messageInfo)
    }
    
    public func isSentByMe(loggedInUser: User, message: BaseMessage) -> Bool {
        return loggedInUser.uid == message.sender?.uid;
    }
    
    public func getTextMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        
        let isSentByMe = isSentByMe(loggedInUser: loggedInUser, message: messageObject)
        var messageOptions = [CometChatMessageOption]()
        if isSentByMe {
            messageOptions.append(getEditOption(controller: controller))
        }
        messageOptions.append(contentsOf: ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group))
        print("getting text options from message Utils2 \(messageOptions)")
        return messageOptions
    }
    
    public func getImageMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        var messageOptions = [CometChatMessageOption]()
        messageOptions.append(contentsOf: ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group))
        return messageOptions
    }
    
    public func getVideoMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        var messageOptions = [CometChatMessageOption]()
        messageOptions.append(contentsOf: ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group))
        return messageOptions
    }
    
    public func getAudioMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        var messageOptions = [CometChatMessageOption]()
        messageOptions.append(contentsOf: ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group))
        return messageOptions
    }
    
    public func getFileMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        var messageOptions = [CometChatMessageOption]()
        messageOptions.append(contentsOf: ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group))
        return messageOptions
    }
    
    public func getDeleteMessageBubble(messageObject: CometChatSDK.BaseMessage) -> UIView? {
        let deleteBubble = CometChatDeleteBubble()
        let deleteBubbleStyle = DeleteBubbleStyle()
        deleteBubbleStyle.set(background: CometChatTheme.palatte.background)
            .set(titleColor: CometChatTheme.palatte.accent500)
            .set(borderColor: CometChatTheme.palatte.accent200)
            .set(borderWidth: 1)
            .set(titleFont: CometChatTheme.typography.text1)
        deleteBubble.set(style: deleteBubbleStyle)
        return deleteBubble
    }
    
    public func getGroupActionBubble(messageObject: CometChatSDK.BaseMessage) -> UIView? {
        let stackView = UIStackView()
        let view = CometChatMessageDateHeader()
        view.text = (messageObject as? ActionMessage)?.message ?? ""
        view.textColor = CometChatTheme.palatte.accent700
        view.font = CometChatTheme.typography.caption1
        stackView.addArrangedSubview(view)
        stackView.layoutMargins = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }
    
    public func getBottomView(message: CometChatSDK.BaseMessage, controller: UIViewController?, alignment: MessageBubbleAlignment) -> UIView? {
        return UIStackView()
    }
    
    public func getTextMessageTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.text, contentView: { message, alignment, controller in
            guard let textMessage = message as? TextMessage else { return UIView() }
            if (textMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: textMessage) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getTextMessageContentView(message: textMessage, controller: controller, alignment: alignment, style: TextBubbleStyle())
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let textMessage = message as? TextMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: textMessage, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let textMessage = message as? TextMessage , let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: textMessage, controller: controller, group: group)
        }

    }
    
    public func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView? {
        return ChatConfigurator.getDataSource().getTextMessageBubble(messageText: message.text, message: message, controller: controller, alignment: alignment, style: style)
    }
    
    public func getAudioMessageTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.audio, contentView: { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return UIView() }
            if (mediaMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: mediaMessage) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getAudioMessageContentView(message: mediaMessage, controller: controller, alignment: alignment, style: AudioBubbleStyle())
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: mediaMessage, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let mediaMessage = message as? MediaMessage , let user = LoggedInUserInformation.getUser() else {return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: mediaMessage, controller: controller, group: group)
        }

    }
    
    public func getAudioMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AudioBubbleStyle?) -> UIView? {
        return ChatConfigurator.getDataSource().getAudioMessageBubble(audioUrl: message.attachment?.fileUrl, title: message.attachment?.fileName, message: message, controller: controller, style: style)
    }
    
    public func getVideoMessageTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.video, contentView: { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return UIView() }
            if (mediaMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: mediaMessage) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getVideoMessageContentView(message: mediaMessage, controller: controller, alignment: alignment, style: VideoBubbleStyle())
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: mediaMessage, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let mediaMessage = message as? MediaMessage , let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: mediaMessage, controller: controller, group: group)
        }
    }
    
    public func getVideoMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: VideoBubbleStyle?) -> UIView? {
        return ChatConfigurator.getDataSource().getVideoMessageBubble(videoUrl: message.attachment?.fileUrl, thumbnailUrl: nil, message: message, controller: controller, style: style)
    }
    
    public func getImageMessageTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.image, contentView: { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return UIView() }
            if (mediaMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: mediaMessage) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getImageMessageContentView(message: mediaMessage, controller: controller, alignment: alignment, style: ImageBubbleStyle())
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: mediaMessage, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let mediaMessage = message as? MediaMessage , let user = LoggedInUserInformation.getUser() else { return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: mediaMessage, controller: controller, group: group)
        }

    }
    
    public func getImageMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ImageBubbleStyle?) -> UIView? {
        
        return ChatConfigurator.getDataSource().getImageMessageBubble(imageUrl: message.attachment?.fileUrl, caption: message.caption, message: message, controller: controller, style: style)
    }
   
    
    public func getGroupActionTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.action, type: MessageTypeConstants.groupMember, contentView: { message, alignment, controller in
            guard let message = message else { return UIView() }
            return self.getGroupActionBubble(messageObject: message)
        }, bubbleView: nil, headerView: nil, footerView: nil, bottomView: nil, options: nil)
    }
    
    public func getDefaultMessageActionsTemplate() -> CometChatMessageTemplate {
        return CometChatMessageTemplate(category: MessageCategoryConstants.action, type: MessageTypeConstants.message, contentView: nil, bubbleView: nil, headerView: nil, footerView: nil, bottomView: nil, options: nil)
    }
    
    public func getFileMessageTemplate() -> CometChatMessageTemplate {        
        return CometChatMessageTemplate(category: MessageCategoryConstants.message, type: MessageTypeConstants.file, contentView: { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return UIView() }
            if (mediaMessage.deletedAt != 0.0) {
                if let deletedBubble = self.getDeleteMessageBubble(messageObject: mediaMessage) {
                    return deletedBubble
                }
            }
            return ChatConfigurator.getDataSource().getFileMessageContentView(message: mediaMessage, controller: controller, alignment: alignment, style: FileBubbleStyle())
            
        }, bubbleView: nil, headerView: nil, footerView: nil) { message, alignment, controller in
            guard let mediaMessage = message as? MediaMessage else { return nil }
            return ChatConfigurator.getDataSource().getBottomView(message: mediaMessage, controller: controller, alignment: alignment)
        } options: { message, group, controller in
            guard let mediaMessage = message as? MediaMessage , let user = LoggedInUserInformation.getUser() else {return [] }
            return ChatConfigurator.getDataSource().getMessageOptions(loggedInUser: user, messageObject: mediaMessage, controller: controller, group: group)
        }

    }
    
    public func getFileMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FileBubbleStyle?) -> UIView? {
        return ChatConfigurator.getDataSource().getFileMessageBubble(fileUrl: message.attachment?.fileUrl, fileMimeType: message.attachment?.fileMimeType, title: message.attachment?.fileName, id: message.id, message: message, controller: controller, style: style)
    }
    
    public func getAllMessageTemplates() -> [CometChatMessageTemplate] {
        return [
            ChatConfigurator.getDataSource().getTextMessageTemplate(),
            ChatConfigurator.getDataSource().getImageMessageTemplate(),
            ChatConfigurator.getDataSource().getVideoMessageTemplate(),
            ChatConfigurator.getDataSource().getAudioMessageTemplate(),
            ChatConfigurator.getDataSource().getFileMessageTemplate(),
            ChatConfigurator.getDataSource().getGroupActionTemplate(),
        ]
    }
    
    public func getMessageTemplate(messageType: String, messageCategory: String) -> CometChatMessageTemplate? {
        var template : CometChatMessageTemplate?
        if (messageCategory != MessageCategoryConstants.call) {
            switch (messageType) {
            case MessageTypeConstants.text:
                template = ChatConfigurator.getDataSource()
                    .getTextMessageTemplate()
                
            case MessageTypeConstants.image:
                template = ChatConfigurator.getDataSource()
                    .getImageMessageTemplate()
                
            case MessageTypeConstants.video:
                template = ChatConfigurator.getDataSource()
                    .getVideoMessageTemplate()
                
            case MessageTypeConstants.groupMember:
                template = ChatConfigurator.getDataSource()
                    .getGroupActionTemplate()
                
            case MessageTypeConstants.file:
                template = ChatConfigurator.getDataSource()
                    .getFileMessageTemplate()
                
            case MessageTypeConstants.audio:
                template = ChatConfigurator.getDataSource()
                    .getAudioMessageTemplate()
                
                default: break }
        }
        return template
    }
    
    public func getMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        var options = [CometChatMessageOption]()
        if (messageObject.messageCategory == .message) {
            switch messageObject.messageType {
            case .text:
                options = ChatConfigurator.getDataSource().getTextMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group) ?? []
                
            case .image:
                options = ChatConfigurator.getDataSource().getImageMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group) ?? []
                
            case .video:
                options = ChatConfigurator.getDataSource().getVideoMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group) ?? []
            case .audio:
                options = ChatConfigurator.getDataSource().getAudioMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group) ?? []
            case .file:
                options = ChatConfigurator.getDataSource().getFileMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group) ?? []
            case .custom:
                options = ChatConfigurator.getDataSource().getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
            case .groupMember: options = []
            @unknown default: break
            }
        }
        return options
    }
    
    public func getCommonOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption] {
        var options = [CometChatMessageOption]()
        let isSentByMe = isSentByMe(loggedInUser: loggedInUser, message: messageObject)
        
        if (messageObject.parentMessageId == 0) {
            options.append(getReplyInThreadOption(controller: controller))
        }
        
        if isMessageCategory(message: messageObject) {
            options.append(getShareOption(controller: controller))
        }
        
        options.append(getInformationOption(controller: controller))
        
        if group != nil && !isSentByMe {
            options.append(getMessagePrivatelyOption(controller: controller))
        }
        
        if isSentByMe || group?.scope == .admin || group?.scope == .moderator  {
            options.append(getDeleteOption(controller: controller))
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
        default: break
        }
        return subtitle
    }
    
    public func takePhotoOption(controller: UIViewController?) -> CometChatMessageComposerAction{
        return CometChatMessageComposerAction(id: MessageTypeConstants.image, text: "TAKE_A_PHOTO".localize(), startIcon: UIImage(named: "messages-camera.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil)
    }
    
    public func photoAndVideoLibraryOption(controller: UIViewController?) -> CometChatMessageComposerAction{
        return   CometChatMessageComposerAction(id: MessageTypeConstants.image, text: "PHOTO_VIDEO_LIBRARY".localize(), startIcon:  UIImage(named: "photo-library.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil)
    }
    
    public func fileAttachmentOption(controller: UIViewController?) -> CometChatMessageComposerAction{
        return    CometChatMessageComposerAction(id: MessageTypeConstants.file, text: "DOCUMENT".localize(), startIcon: UIImage(named: "messages-file-upload.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), endIcon: nil, startIconTint: nil, endIconTint: nil, textColor: nil, textFont: nil)
    }
    
    
    public func getAttachmentOptions(controller: UIViewController, user: CometChatSDK.User?, group: CometChatSDK.Group?) -> [CometChatMessageComposerAction]? {
        return [takePhotoOption(controller: controller),
                photoAndVideoLibraryOption(controller: controller),
                fileAttachmentOption(controller: controller)]
    }
    
    public func getAllMessageTypes() -> [String]? {
        return [
            MessageTypeConstants.text,
            MessageTypeConstants.image,
            MessageTypeConstants.audio,
            MessageTypeConstants.video,
            MessageTypeConstants.file,
            MessageTypeConstants.groupMember
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
    
    public func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?) -> UIView? {
        let videoBubble = CometChatVideoBubble()
        videoBubble.set(videoURL: message?.attachment?.fileUrl ?? "")
        if let thumbnailUrl = thumbnailUrl , let sentAt = Double(message?.sentAt ?? 0) as? Double {
            videoBubble.set(thumnailImageUrl: thumbnailUrl, sentAt: sentAt)
        }
        if let controller = controller {
            videoBubble.set(controller: controller)
        }
        return videoBubble
    }
    
    public func getTextMessageBubble(messageText: String?, message: CometChatSDK.TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView? {
        let textBubble = CometChatTextBubble()
        textBubble.set(style: style ?? TextBubbleStyle())
        if let messageText = messageText {
            textBubble.set(text: messageText)
        } else {
            textBubble.set(text: message?.text ?? "")
        }
        if let font =  message?.text.applyLargeSizeEmoji() {
            textBubble.set(textFont: font)
        }
        
        if let translatedMessage = message?.metaData?["translated-message"] as? String, !translatedMessage.isEmpty {
            let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(string: "\(translatedMessage)\n\n", attributes: [.font: style?.titleFont, .foregroundColor: alignment == .left ? CometChatTheme.palatte.accent900 : UIColor.white]))
            attributedString.append(NSAttributedString(string: "\(message?.text ?? "")\n\n", attributes: [.font: CometChatTheme.typography.subtitle2, .foregroundColor: alignment == .left ? CometChatTheme.palatte.accent800 : UIColor.white]))
            attributedString.append(NSAttributedString(string: "\("TRANSLATED_MESSAGE".localize())", attributes: [.font: UIFont.systemFont(ofSize: 11.0, weight: .regular), .foregroundColor: alignment == .left ? CometChatTheme.palatte.accent600 : UIColor.white]))
            textBubble.set(attributedText: attributedString)
            
        } else {
            switch alignment {
            case .right:
                textBubble.set(textColor: .white)
            case .left:
                textBubble.set(textColor: CometChatTheme.palatte.accent)
            default: break
            }
            textBubble.set(text: (messageText ?? message?.text) ?? "")
        }
        return textBubble
    }
    
    public func getImageMessageBubble(imageUrl: String?, caption: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?) -> UIView? {
        let imageBubble = CometChatImageBubble()
        if let imageUrl = imageUrl , let sentAt = Double(message?.sentAt ?? 0) as? Double {
            imageBubble.set(imageUrl: imageUrl, sentAt: sentAt)
        } else {
            imageBubble.set(imageUrl: message?.attachment?.fileUrl ?? "")
        }
        imageBubble.set(caption: message?.caption ?? "")
        if let style = style {
            imageBubble.set(style: style)
        }
        if let controller = controller {
            imageBubble.set(controller: controller)
        }
        imageBubble.setOnClick {
            imageBubble.previewMediaMessage(url: message?.attachment?.fileUrl ?? "") { success, fileLocation in
                if success {
                    if let url = fileLocation {
                        imageBubble.previewItemURL = url as NSURL
                        imageBubble.setupPreviewController()
                    }
                }
            }
        }
        return imageBubble
    }
    
    public func getAudioMessageBubble(audioUrl: String?, title: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: AudioBubbleStyle?) -> UIView? {
        let audioBubble = CometChatAudioBubble()
        audioBubble.set(title: message?.attachment?.fileName.capitalized ?? "")
        audioBubble.set(subTitle: message?.attachment?.fileExtension.capitalized ?? "")
        audioBubble.set(fileURL: message?.attachment?.fileUrl ?? "")
        if let controller = controller {
            audioBubble.set(controller: controller)
        }
        if let style = style {
            audioBubble.set(style: style)
        }
        return audioBubble
    }
    
    public func getFileMessageBubble(fileUrl: String?, fileMimeType: String?, title: String?, id: Int?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: FileBubbleStyle?) -> UIView? {
        let fileBubble = CometChatFileBubble()
        fileBubble.set(title: message?.attachment?.fileName.capitalized ?? "")
        fileBubble.set(subTitle: message?.attachment?.fileExtension.capitalized ?? "")
        fileBubble.set(fileUrl: message?.attachment?.fileUrl ?? "")
        if let controller = controller {
            fileBubble.set(controller: controller)
        }
        if let style = style {
            fileBubble.set(style: style)
        }
        return fileBubble
    }
    
    public func getLastConversationMessage(conversation: CometChatSDK.Conversation, isDeletedMessagesHidden: Bool) -> String? {
        var lastMessage = ""
        
        if let currentMessage = conversation.lastMessage {
            
            switch currentMessage.messageCategory {
            case .message:
                if currentMessage.deletedAt > 0.0 {
                    if isDeletedMessagesHidden {
                        lastMessage = ""
                    } else {
                        lastMessage = ConversationConstants.thisMessageDeleted
                    }
                } else {
                    switch currentMessage.messageType {
                    case .text where conversation.conversationType == .user:
                        if let textMessage = currentMessage as? TextMessage {
                            lastMessage =  textMessage.text
                        }
                    case .text where conversation.conversationType == .group:
                        if let textMessage = conversation.lastMessage as? TextMessage {
                            lastMessage = textMessage.text
                        }
                    case .image where conversation.conversationType == .user:
                        lastMessage = ConversationConstants.messageImage
                    case .image where conversation.conversationType == .group:
                        lastMessage = ConversationConstants.messageImage
                    case .video  where conversation.conversationType == .user:
                        lastMessage = ConversationConstants.messageVideo
                    case .video  where conversation.conversationType == .group:
                        lastMessage = ConversationConstants.messageVideo
                    case .audio  where conversation.conversationType == .user:
                        lastMessage = ConversationConstants.messageAudio
                    case .audio  where conversation.conversationType == .group:
                        lastMessage = ConversationConstants.messageAudio
                    case .file  where conversation.conversationType == .user:
                        lastMessage = ConversationConstants.messageFile
                    case .file  where conversation.conversationType == .group:
                        lastMessage = ConversationConstants.messageFile
                    case .custom where conversation.conversationType == .user:
                        
                        if let customMessage = conversation.lastMessage as? CustomMessage {
                            if customMessage.type == MessageTypeConstants.location {
                                lastMessage = ConversationConstants.customMessageLocation
                            } else if customMessage.type == MessageTypeConstants.poll {
                                lastMessage = ConversationConstants.customMessagePoll
                            } else if customMessage.type == MessageTypeConstants.sticker {
                                lastMessage = ConversationConstants.customMessageSticker
                            } else if customMessage.type == MessageTypeConstants.whiteboard {
                                lastMessage = ConversationConstants.customMessageWhiteboard
                            } else if customMessage.type == MessageTypeConstants.document {
                                lastMessage = ConversationConstants.customMessageDocument
                            } else if customMessage.type == MessageTypeConstants.meeting {
                                lastMessage = ConversationConstants.hasIntiatedGroupAudioCall
                            }
                            
                        } else {
                            if let pushNotificationTitle = currentMessage.metaData?["pushNotification"] as? String {
                                if !pushNotificationTitle.isEmpty {
                                    lastMessage = pushNotificationTitle
                                }
                            }
                        }
                    case .custom where conversation.conversationType == .group:
                        if let customMessage = conversation.lastMessage as? CustomMessage {
                            if customMessage.type == MessageTypeConstants.location {
                                lastMessage = ConversationConstants.customMessageLocation
                            } else if customMessage.type == MessageTypeConstants.poll {
                                lastMessage = ConversationConstants.customMessagePoll
                            } else if customMessage.type == MessageTypeConstants.sticker {
                                lastMessage = ConversationConstants.customMessageSticker
                            } else if customMessage.type == MessageTypeConstants.whiteboard {
                                lastMessage = ConversationConstants.customMessageWhiteboard
                            } else if customMessage.type == MessageTypeConstants.document {
                                lastMessage = ConversationConstants.customMessageDocument
                            } else if customMessage.type == MessageTypeConstants.meeting {
                                lastMessage = ConversationConstants.hasIntiatedGroupAudioCall
                            }
                        } else {
                            if let pushNotificationTitle = currentMessage.metaData?["pushNotification"] as? String {
                                if !pushNotificationTitle.isEmpty {
                                    lastMessage = pushNotificationTitle
                                }
                            }
                        }
                    case .groupMember, .text, .image, .video,.audio, .file,.custom: break
                    @unknown default: break
                    }
                }
            case .action:
                if let text = ((currentMessage as? ActionMessage)?.message) {
                    lastMessage = text
                }
            case .call:
                lastMessage = ConversationConstants.hasSentACall
            case .custom where conversation.conversationType == .user:
                
                if let customMessage = currentMessage as? CustomMessage {
                    if customMessage.type == MessageTypeConstants.location {
                        lastMessage = ConversationConstants.customMessageLocation
                    } else if customMessage.type == MessageTypeConstants.poll {
                        lastMessage = ConversationConstants.customMessagePoll
                    } else if customMessage.type == MessageTypeConstants.sticker {
                        lastMessage = ConversationConstants.customMessageSticker
                    } else if customMessage.type == MessageTypeConstants.whiteboard {
                        lastMessage = ConversationConstants.customMessageWhiteboard
                    } else if customMessage.type == MessageTypeConstants.document {
                        lastMessage =  ConversationConstants.customMessageDocument
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
                            lastMessage = "\(String(describing: customMessage.customData))"
                        }
                    }
                }
            case .custom where conversation.conversationType == .group:
                if let customMessage = currentMessage as? CustomMessage {
                    if customMessage.type == MessageTypeConstants.location {
                        lastMessage =  ConversationConstants.customMessageLocation
                    } else if customMessage.type == MessageTypeConstants.poll {
                        lastMessage = ConversationConstants.customMessagePoll
                    } else if customMessage.type == MessageTypeConstants.sticker {
                        lastMessage = ConversationConstants.customMessageSticker
                    } else if customMessage.type == MessageTypeConstants.whiteboard {
                        lastMessage = ConversationConstants.customMessageWhiteboard
                    } else if customMessage.type == MessageTypeConstants.document {
                        lastMessage = ConversationConstants.customMessageDocument
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
                            lastMessage = "\(String(describing: customMessage.customData))"
                        }
                    }
                }
            case .custom: break
            @unknown default: break
            }
        } else {
            lastMessage = "TAP_TO_START_CONVERSATION".localize()
        }
        return lastMessage
    }
    
    public func getAuxiliaryHeaderMenu(user: CometChatSDK.User?, group: CometChatSDK.Group?, controller: UIViewController?, id: [String: Any]?) -> UIStackView? {
        return nil
    }
    
    func isMessageCategory(message: CometChatSDK.BaseMessage) -> Bool {
        return message.messageCategory == .message ? true : false
    }
    
}
