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
    
    public func getTextMessageContentView(message: CometChatSDK.TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView? {
        return dataSource.getTextMessageContentView(message: message, controller: controller, alignment: alignment, style: style)
    }
    
    public func getImageMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ImageBubbleStyle?) -> UIView? {
        return dataSource.getImageMessageContentView(message: message, controller: controller, alignment: alignment, style: style)
    }
    
    public func getVideoMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: VideoBubbleStyle?) -> UIView? {
        return dataSource.getVideoMessageContentView(message: message, controller: controller, alignment: alignment, style: style)
    }
    
    public func getFileMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FileBubbleStyle?) -> UIView? {
        return dataSource.getFileMessageContentView(message: message, controller: controller, alignment: alignment, style: style)
    }
    
    public func getAudioMessageContentView(message: CometChatSDK.MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AudioBubbleStyle?) -> UIView? {
        return dataSource.getAudioMessageContentView(message: message, controller: controller, alignment: alignment, style: style)
    }
    
    public func getTextMessageTemplate() -> CometChatMessageTemplate {
        return dataSource.getTextMessageTemplate()
    }
    
    public func getAudioMessageTemplate() -> CometChatMessageTemplate {
        return dataSource.getAudioMessageTemplate()
    }
    
    public func getVideoMessageTemplate() -> CometChatMessageTemplate {
        return dataSource.getVideoMessageTemplate()
    }
    
    public func getImageMessageTemplate() -> CometChatMessageTemplate {
        return dataSource.getImageMessageTemplate()
    }
    
    public func getGroupActionTemplate() -> CometChatMessageTemplate {
        return dataSource.getGroupActionTemplate()
    }
    
    public func getFileMessageTemplate() -> CometChatMessageTemplate {
        return dataSource.getFileMessageTemplate()
    }
    
    public func getAllMessageTemplates() -> [CometChatMessageTemplate] {
        return dataSource.getAllMessageTemplates()
    }
    
    public func getMessageTemplate(messageType: String, messageCategory: String) -> CometChatMessageTemplate? {
        return dataSource.getMessageTemplate(messageType: messageType, messageCategory: messageCategory)
    }
    


    public func getMessageTypeToSubtitle(messageType: String, controller: UIViewController) -> String? {
        return dataSource.getMessageTypeToSubtitle(messageType: messageType, controller: controller)
    }
    
    public func getAttachmentOptions(controller: UIViewController, user: CometChatSDK.User?, group: CometChatSDK.Group?) -> [CometChatMessageComposerAction]? {
        return dataSource.getAttachmentOptions(controller: controller, user: user, group: group)
    }
    
    public func getAllMessageTypes() -> [String]? {
        return dataSource.getAllMessageTypes()
    }
    
    public func getAllMessageCategories() -> [String]? {
        return dataSource.getAllMessageCategories()
    }
    
    public func getMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        return dataSource.getMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
    }
    
    public func getTextMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        return dataSource.getTextMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
    }
    
    public func getImageMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        return dataSource.getImageMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
    }
    
    public func getVideoMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        return dataSource.getVideoMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
    }
    
    public func getAudioMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        return dataSource.getAudioMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
    }
    
    public func getFileMessageOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]? {
        return dataSource.getFileMessageOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
    }
    
    public func getCommonOptions(loggedInUser: CometChatSDK.User, messageObject: CometChatSDK.BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption] {
        return dataSource.getCommonOptions(loggedInUser: loggedInUser, messageObject: messageObject, controller: controller, group: group)
    }
    
    public func getBottomView(message: CometChatSDK.BaseMessage, controller: UIViewController?, alignment: MessageBubbleAlignment) -> UIView? {
        return dataSource.getBottomView(message: message, controller: controller, alignment: alignment)
    }
    
    public func getAuxiliaryOptions(user: CometChatSDK.User?, group: CometChatSDK.Group?, controller: UIViewController?, id: [String : Any]?) -> UIView? {
        return dataSource.getAuxiliaryOptions(user: user, group: group, controller: controller, id: id)
    }
    
    public func getId() -> String {
        return dataSource.getId()
    }
    
    
    public func getDeleteMessageBubble(messageObject: CometChatSDK.BaseMessage) -> UIView? {
        return dataSource.getDeleteMessageBubble(messageObject: messageObject)
    }
    
    public func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?) -> UIView? {
        return dataSource.getVideoMessageBubble(videoUrl: videoUrl, thumbnailUrl: thumbnailUrl, message: message, controller: controller, style: style)
    }
    
    public func getTextMessageBubble(messageText: String?, message: CometChatSDK.TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView? {
        return dataSource.getTextMessageBubble(messageText: messageText, message: message, controller: controller, alignment: alignment, style: style)
    }
    
    public func getImageMessageBubble(imageUrl: String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?) -> UIView? {
        return dataSource.getImageMessageBubble(imageUrl: imageUrl, caption: caption, message: message, controller: controller, style: style)
    }
    
    public func getAudioMessageBubble(audioUrl: String?, title: String?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: AudioBubbleStyle?) -> UIView? {
        return dataSource.getAudioMessageBubble(audioUrl: audioUrl, title: title, message: message, controller: controller, style: style)
    }
    
    public func getFileMessageBubble(fileUrl: String?, fileMimeType: String?, title: String?, id: Int?, message: CometChatSDK.MediaMessage?, controller: UIViewController?, style: FileBubbleStyle?) -> UIView? {
        return dataSource.getFileMessageBubble(fileUrl: fileUrl, fileMimeType: fileMimeType, title: title, id: id, message: message, controller: controller, style: style)
    }
    
    public func getLastConversationMessage(conversation: Conversation, isDeletedMessagesHidden: Bool) -> String? {
        return dataSource.getLastConversationMessage(conversation: conversation, isDeletedMessagesHidden: isDeletedMessagesHidden)
    }

    public func getAuxiliaryHeaderMenu(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIStackView? {
        return dataSource.getAuxiliaryHeaderMenu(user: user, group: group, controller: controller, id: id)
    }
}
