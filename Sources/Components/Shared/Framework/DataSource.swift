//
//  DataSource.swift
 
//
//  Created by Pushpsen Airekar on 14/02/23.
//

import Foundation
import CometChatSDK

public protocol DataSource {
    
    func getTextMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]?
    
    func getImageMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]?
    
    func getVideoMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]?
    
    func getAudioMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]?
    
    func getFileMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]?
    
    func getBottomView(message: BaseMessage, controller: UIViewController?, alignment: MessageBubbleAlignment) -> UIView?
    
    func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView?
    
    func getImageMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ImageBubbleStyle?) -> UIView?
    
    func getVideoMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: VideoBubbleStyle?) -> UIView?
    
    func getFileMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FileBubbleStyle?) -> UIView?
    
    func getAudioMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AudioBubbleStyle?) -> UIView?
    
    func getTextMessageTemplate() -> CometChatMessageTemplate
    
    func getAudioMessageTemplate() -> CometChatMessageTemplate
    
    func getVideoMessageTemplate() -> CometChatMessageTemplate
    
    func getImageMessageTemplate() -> CometChatMessageTemplate
    
    func getGroupActionTemplate() -> CometChatMessageTemplate
    
    func getFileMessageTemplate() -> CometChatMessageTemplate
    
    func getAllMessageTemplates() -> [CometChatMessageTemplate]
    
    func getMessageTemplate(messageType: String, messageCategory: String) -> CometChatMessageTemplate?
    
    func getMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]?
    
    func getCommonOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]
    
    func getMessageTypeToSubtitle(messageType: String, controller: UIViewController) -> String?
    
    // Might be a callback
    func getAttachmentOptions(controller: UIViewController, user: User?, group: Group?) -> [CometChatMessageComposerAction]?
    
    func getAllMessageTypes() -> [String]?
    
    func getAllMessageCategories() -> [String]?
    
    func getAuxiliaryOptions(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIView?
    
    func getId() -> String
    
    func getDeleteMessageBubble(messageObject: BaseMessage) -> UIView?
    
    func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?) -> UIView?
    
    func getTextMessageBubble(messageText: String?, message: TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView?
    
    func getImageMessageBubble(imageUrl:String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?) -> UIView?
    
    func getAudioMessageBubble(audioUrl:String?, title: String?, message: MediaMessage?, controller: UIViewController?, style: AudioBubbleStyle?) -> UIView?
    
    func getFileMessageBubble(fileUrl:String?, fileMimeType: String?, title: String?, id: Int?, message: MediaMessage?, controller: UIViewController?, style: FileBubbleStyle?) -> UIView?
    
    func getLastConversationMessage(conversation: Conversation, isDeletedMessagesHidden: Bool) -> String?
    
    func getAuxiliaryHeaderMenu(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIStackView?
    
}
