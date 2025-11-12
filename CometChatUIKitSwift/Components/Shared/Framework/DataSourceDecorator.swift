//
//  DataSourceDecorator.swift
 
//
//  Created by Pushpsen Airekar on 14/02/23.
//

import Foundation
import UIKit
import CometChatSDK

public class DataSourceDecorator: DataSource {
   
    var dataSource: DataSource
    
    public init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    public func getMessageTypeToSubtitle(messageType: String, controller: UIViewController) -> String? {
        return dataSource.getMessageTypeToSubtitle(messageType: messageType, controller: controller)
    }
    
    public func getAttachmentOptions(controller: UIViewController, user: CometChatSDK.User?, group: CometChatSDK.Group?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageComposerAction]? {
        return dataSource.getAttachmentOptions(controller: controller, user: user, group: group, id: id, additionalConfiguration: additionalConfiguration)
    }
    
    public func getAllMessageTypes() -> [String]? {
        return dataSource.getAllMessageTypes()
    }
    
    public func getAllMessageCategories() -> [String]? {
        return dataSource.getAllMessageCategories()
    }
    
    public func getMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        return dataSource.getMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
    }
    
    public func getTextMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        return dataSource.getTextMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
    }
    
    public func getImageMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        return dataSource.getImageMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
    }
    
    public func getVideoMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        return dataSource.getVideoMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
    }
    
    public func getAudioMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        return dataSource.getAudioMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
    }
    
    public func getFileMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]? {
        return dataSource.getFileMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
    }
    
    public func getCommonOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption] {
        return dataSource.getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group, additionalConfiguration: additionalConfiguration)
    }
        
    public func getAuxiliaryOptions(user: CometChatSDK.User?, group: CometChatSDK.Group?, controller: UIViewController?, id: [String : Any]?) -> UIView? {
        return dataSource.getAuxiliaryOptions(user: user, group: group, controller: controller, id: id)
    }
    
    public func getAIOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?, aiOptionsStyle: AIOptionsStyle?) -> [CometChatMessageComposerAction]? {
        return dataSource.getAIOptions(controller: controller, user: user, group: group, id: id, aiOptionsStyle: aiOptionsStyle)
    }
    
    public func getId() -> String {
        return dataSource.getId()
    }
        
    public func getLastConversationMessage(conversation: CometChatSDK.Conversation, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString? {
        return dataSource.getLastConversationMessage(conversation: conversation, additionalConfiguration: additionalConfiguration)
    }
    
    public func getLastConversationMessage(conversation: Conversation) -> String? {
        return dataSource.getLastConversationMessage(conversation: conversation, additionalConfiguration: nil)?.string
    }

    public func getAuxiliaryHeaderMenu(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration) -> UIStackView? {
        return dataSource.getAuxiliaryHeaderMenu(user: user, group: group, controller: controller, id: id, additionalConfiguration: additionalConfiguration)
    }
    
    
    //MARK: Duplicate Functions With CustomConfigurator
    public func getAllMessageTemplates(additionalConfiguration:AdditionalConfiguration?) -> [CometChatMessageTemplate] {
        return dataSource.getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
    }
    
    public func getTextMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate {
        return dataSource.getTextMessageTemplate(additionalConfiguration: additionalConfiguration)
    }
    
    public func getAIAssistantMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate {
        return dataSource.getAIAssistantMessageTemplate(additionalConfiguration: additionalConfiguration)
    }
    
    public func getAudioMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate {
        return dataSource.getAudioMessageTemplate(additionalConfiguration: additionalConfiguration)
    }
    
    public func getVideoMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate {
        return dataSource.getVideoMessageTemplate(additionalConfiguration: additionalConfiguration)
    }
    
    public func getImageMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate {
        return dataSource.getImageMessageTemplate(additionalConfiguration: additionalConfiguration)
    }
    
    public func getGroupActionTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate {
        return dataSource.getGroupActionTemplate(additionalConfiguration: additionalConfiguration)
    }
    
    public func getFileMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate {
        return dataSource.getFileMessageTemplate(additionalConfiguration: additionalConfiguration)
    }
    
    public func getFormMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate {
        return dataSource.getFormMessageTemplate(additionalConfiguration: additionalConfiguration)
    }
    
    public func getSchedulerMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate {
        return dataSource.getSchedulerMessageTemplate(additionalConfiguration: additionalConfiguration)
    }
    
    public func getCardMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate {
        return dataSource.getCardMessageTemplate(additionalConfiguration: additionalConfiguration)
    }
    
    public func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate? {
        return dataSource.getMessageTemplate(messageType: messageType, messageCategory: messageCategory, additionalConfiguration: additionalConfiguration)
    }
    
    public func getBottomView(message: CometChatSDK.BaseMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getBottomView(message: message, controller: controller, alignment: alignment, additionalConfiguration: additionalConfiguration)
    }
    
    public func getTextMessageContentView(message: CometChatSDK.TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getTextMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getAIAssistantMessageContentView(message: CometChatSDK.AIAssistantMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AIAssistantBubbleStyle?, additionalConfiguration: AdditionalConfiguration?) -> UIView? {
        return dataSource.getAIAssistantMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getImageMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ImageBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getImageMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getVideoMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: VideoBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getVideoMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getFileMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FileBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getFileMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getAudioMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AudioBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getAudioMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getFormMessageContentView(message: FormMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getFormMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getSchedulerContentView(message: SchedulerMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getSchedulerContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getCardMessageContentView(message: CardMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getCardMessageContentView(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getDeleteMessageBubble(messageObject: CometChatSDK.BaseMessage, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getDeleteMessageBubble(messageObject: messageObject, additionalConfiguration: additionalConfiguration)
    }
    
    public func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getVideoMessageBubble(videoUrl: videoUrl, thumbnailUrl: thumbnailUrl, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getTextMessageBubble(messageText: String?, message: CometChatSDK.TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getTextMessageBubble(messageText: messageText, message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getAIAssistantMessageBubble(messageText: String?, message: CometChatSDK.AIAssistantMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AIAssistantBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getAIAssistantMessageBubble(messageText: messageText, message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getImageMessageBubble(imageUrl: String?, caption: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getImageMessageBubble(imageUrl: imageUrl, caption: caption, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getAudioMessageBubble(audioUrl: String?, title: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: AudioBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getAudioMessageBubble(audioUrl: audioUrl, title: title, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getFormBubble(message: FormMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getFormBubble(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getCardBubble(message: CardMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getCardBubble(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getSchedulerBubble(message: SchedulerMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getSchedulerBubble(message: message, controller: controller, alignment: alignment, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getFileMessageBubble(fileUrl: String?, fileMimeType: String?, title: String?, id: Int?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: FileBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView? {
        return dataSource.getFileMessageBubble(fileUrl: fileUrl, fileMimeType: fileMimeType, title: title, id: id, message: message, controller: controller, style: style, additionalConfiguration: additionalConfiguration)
    }
    
    public func getTextFormatters() -> [CometChatTextFormatter] {
        return dataSource.getTextFormatters()
    }
    
}
