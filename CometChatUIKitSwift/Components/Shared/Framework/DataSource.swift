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
    
    func getBottomView(message: BaseMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView?
    
    func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getImageMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ImageBubbleStyle?) -> UIView?
    
    func getImageMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ImageBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getVideoMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: VideoBubbleStyle?) -> UIView?
    
    func getVideoMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: VideoBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getFileMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FileBubbleStyle?) -> UIView?
    
    func getFileMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FileBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getAudioMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AudioBubbleStyle?) -> UIView?
    
    func getAudioMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AudioBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getFormMessageContentView(message: FormMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?) -> UIView?
    
    func getFormMessageContentView(message: FormMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
 
    func getSchedulerContentView(message: SchedulerMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?) -> UIView?
    
    func getSchedulerContentView(message: SchedulerMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getCardMessageContentView(message: CardMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?) -> UIView?
    
    func getCardMessageContentView(message: CardMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getTextMessageTemplate() -> CometChatMessageTemplate
    
    func getTextMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
    
    func getAudioMessageTemplate() -> CometChatMessageTemplate
    
    func getAudioMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
    
    func getVideoMessageTemplate() -> CometChatMessageTemplate
    
    func getVideoMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
    
    func getImageMessageTemplate() -> CometChatMessageTemplate
    
    func getImageMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
    
    func getGroupActionTemplate() -> CometChatMessageTemplate
    
    func getGroupActionTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
    
    func getFileMessageTemplate() -> CometChatMessageTemplate
    
    func getFileMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
    
    func getFormMessageTemplate() -> CometChatMessageTemplate
    
    func getFormMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate

    func getSchedulerMessageTemplate() -> CometChatMessageTemplate
    
    func getSchedulerMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
    
    func getCardMessageTemplate() -> CometChatMessageTemplate
    
    func getCardMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
    
    func getAllMessageTemplates() -> [CometChatMessageTemplate]
    
    func getAllMessageTemplates(additionalConfiguration:AdditionalConfiguration?) -> [CometChatMessageTemplate]
    
    func getMessageTemplate(messageType: String, messageCategory: String) -> CometChatMessageTemplate?
    
    func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate?
    
    func getMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]?
    
    func getCommonOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?) -> [CometChatMessageOption]
    
    func getMessageTypeToSubtitle(messageType: String, controller: UIViewController) -> String?
    
    // Might be a callback
    func getAttachmentOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?) -> [CometChatMessageComposerAction]?
    
    func getAllMessageTypes() -> [String]?
    
    func getAllMessageCategories() -> [String]?
    
    func getAuxiliaryOptions(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIView?
    
    func getAIOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?, aiOptionsStyle: AIOptionsStyle?) -> [CometChatMessageComposerAction]?
    
    func getId() -> String
    
    func getDeleteMessageBubble(messageObject: BaseMessage) -> UIView?
    
    func getDeleteMessageBubble(messageObject: BaseMessage, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?) -> UIView?
    
    func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getTextMessageBubble(messageText: String?, message: TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?) -> UIView?
    
    func getTextMessageBubble(messageText: String?, message: TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getImageMessageBubble(imageUrl:String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?) -> UIView?
    
    func getImageMessageBubble(imageUrl:String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getAudioMessageBubble(audioUrl:String?, title: String?, message: MediaMessage?, controller: UIViewController?, style: AudioBubbleStyle?) -> UIView?
    
    func getAudioMessageBubble(audioUrl:String?, title: String?, message: MediaMessage?, controller: UIViewController?, style: AudioBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getFormBubble(message: FormMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?) -> UIView?
    
    func getFormBubble(message: FormMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getCardBubble(message: CardMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?) -> UIView?
    
    func getCardBubble(message: CardMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?

    func getSchedulerBubble(message: SchedulerMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?) -> UIView?
    
    func getSchedulerBubble(message: SchedulerMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getFileMessageBubble(fileUrl:String?, fileMimeType: String?, title: String?, id: Int?, message: MediaMessage?, controller: UIViewController?, style: FileBubbleStyle?) -> UIView?
    
    func getFileMessageBubble(fileUrl:String?, fileMimeType: String?, title: String?, id: Int?, message: MediaMessage?, controller: UIViewController?, style: FileBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getLastConversationMessage(conversation: Conversation, isDeletedMessagesHidden: Bool) -> String?
    
    func getLastConversationMessage(conversation: CometChatSDK.Conversation, isDeletedMessagesHidden: Bool, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString?
    
    func getAuxiliaryHeaderMenu(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIStackView?
    
    func getTextFormatters() -> [CometChatTextFormatter]
    
}
