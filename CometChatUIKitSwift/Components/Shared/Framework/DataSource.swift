//
//  DataSource.swift
 
//
//  Created by Pushpsen Airekar on 14/02/23.
//

import Foundation
import CometChatSDK

public protocol DataSource {
    
    func getTextMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]?
    
    func getImageMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]?
    
    func getVideoMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]?
    
    func getAudioMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]?
    
    func getFileMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]?
        
    func getBottomView(message: BaseMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getTextMessageContentView(message: TextMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getAIAssistantMessageContentView(message: AIAssistantMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AIAssistantBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getImageMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: ImageBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getVideoMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: VideoBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getFileMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FileBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getAudioMessageContentView(message: MediaMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AudioBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getFormMessageContentView(message: FormMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getSchedulerContentView(message: SchedulerMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getCardMessageContentView(message: CardMessage, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
        
    func getTextMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
    
    func getAIAssistantMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
        
    func getAudioMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
        
    func getVideoMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
        
    func getImageMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
        
    func getGroupActionTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
        
    func getFileMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
        
    func getFormMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
    
    func getSchedulerMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
        
    func getCardMessageTemplate(additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate
        
    func getAllMessageTemplates(additionalConfiguration:AdditionalConfiguration?) -> [CometChatMessageTemplate]
        
    func getMessageTemplate(messageType: String, messageCategory: String, additionalConfiguration:AdditionalConfiguration?) -> CometChatMessageTemplate?
    
    func getMessageOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]?
    
    func getCommonOptions(loggedInUser: User, messageObject: BaseMessage, controller: UIViewController?, group: Group?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageOption]
    
    func getMessageTypeToSubtitle(messageType: String, controller: UIViewController) -> String?
    
    // Might be a callback
    func getAttachmentOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration) -> [CometChatMessageComposerAction]?
    
    func getAllMessageTypes() -> [String]?
    
    func getAllMessageCategories() -> [String]?
    
    func getAuxiliaryOptions(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?) -> UIView?
    
    func getAIOptions(controller: UIViewController, user: User?, group: Group?, id: [String: Any]?, aiOptionsStyle: AIOptionsStyle?) -> [CometChatMessageComposerAction]?
    
    func getId() -> String
        
    func getDeleteMessageBubble(messageObject: BaseMessage, additionalConfiguration:AdditionalConfiguration?) -> UIView?
        
    func getVideoMessageBubble(videoUrl: String?, thumbnailUrl: String?, message: MediaMessage?, controller: UIViewController?, style: VideoBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
        
    func getTextMessageBubble(messageText: String?, message: TextMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: TextBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getAIAssistantMessageBubble(messageText: String?, message: AIAssistantMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: AIAssistantBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
            
    func getImageMessageBubble(imageUrl:String?, caption: String?, message: MediaMessage?, controller: UIViewController?, style: ImageBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
        
    func getAudioMessageBubble(audioUrl:String?, title: String?, message: MediaMessage?, controller: UIViewController?, style: AudioBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
        
    func getFormBubble(message: FormMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: FormBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
        
    func getCardBubble(message: CardMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: CardBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
    
    func getSchedulerBubble(message: SchedulerMessage?, controller: UIViewController?, alignment: MessageBubbleAlignment, style: SchedulerBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
        
    func getFileMessageBubble(fileUrl:String?, fileMimeType: String?, title: String?, id: Int?, message: MediaMessage?, controller: UIViewController?, style: FileBubbleStyle?, additionalConfiguration:AdditionalConfiguration?) -> UIView?
        
    func getLastConversationMessage(conversation: CometChatSDK.Conversation, additionalConfiguration: AdditionalConfiguration?) -> NSAttributedString?
    
    func getAuxiliaryHeaderMenu(user: User?, group: Group?, controller: UIViewController?, id: [String: Any]?, additionalConfiguration: AdditionalConfiguration) -> UIStackView?
    
    func getTextFormatters() -> [CometChatTextFormatter]
    
}
