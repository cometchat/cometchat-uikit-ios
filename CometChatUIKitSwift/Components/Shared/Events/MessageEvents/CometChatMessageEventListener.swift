//
//  CometChatMessageEvents.swift
 
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatSDK
import Foundation

public protocol CometChatMessageEventListener {
    
    //event for message sent by logged-in user
    func ccMessageSent(message: BaseMessage, status: MessageStatus)

    //event for message edited by logged-in user
    func ccMessageEdited(message: BaseMessage, status: MessageStatus)

    //event for message deleted by logged-in user
    func ccMessageDeleted(message: BaseMessage)

    //event for message read by logged-in user
    func ccMessageRead(message: BaseMessage)

    //event for transient message sent by logged-in user
    func ccLiveReaction(reaction: TransientMessage)
    
    //event for listening to test message events
    func onTextMessageReceived(textMessage: TextMessage)
    
    //event for listening to media message events
    func onMediaMessageReceived(mediaMessage: MediaMessage)
    
    //event for listening to custom message events
    func onCustomMessageReceived(customMessage: CustomMessage)
    
    //event for typing started
    func onTypingStarted(_ typingIndicator: TypingIndicator)
    
    //event for typing ended
    func onTypingEnded(_ typingIndicator: TypingIndicator)
    
    //event for listening message delivered
    func onMessagesDelivered(receipt: MessageReceipt)
    
    //event for listening message read
    func onMessagesRead(receipt: MessageReceipt)
    
    //event for listening message edit
    func onMessageEdited(message: BaseMessage)
    
    //event for listening message deletion
    func onMessageDeleted(message: BaseMessage)
    
    //event for listening to transient message events
    func onTransientMessageReceived(_ message: TransientMessage)
    
    //event for listening to form message events
    func onFormMessageReceived(message: FormMessage)
    
    //event for listening to card message events
    func onCardMessageReceived(message: CardMessage)
    
    //event for listening to meeting message events
    func onSchedulerMessageReceived(message: SchedulerMessage)
    
    //event for listening to Custom Interactive message
    func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage)
    
    ///[onMessageReactionAdded] is called when a reaction is added to a message
    func onMessageReactionAdded(reactionEvent: ReactionEvent)
    
    ///[onMessageReactionRemoved] is called when a reaction is removed from a message
    func onMessageReactionRemoved(reactionEvent: ReactionEvent)
    
    ///[onMessagesReadByAll] is called when a group message is marked as read by all the group members
    func onMessagesReadByAll(receipt: MessageReceipt)
    
    ///[onMessagesDeliveredToAll] is called when a group message is marked as delivered by all the group members
    func onMessagesDeliveredToAll(receipt: MessageReceipt)
    
    ///MARK: Deprecated Functions
    @available(*, deprecated, message: "This method is now deprecated")
    func onMessageReply(message: BaseMessage, status: MessageStatus)
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onParentMessageUpdate(message: BaseMessage)
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onMessageError(error: CometChatException)
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onVoiceCall(user: User)
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onVoiceCall(group: Group)
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onVideoCall(user: User)
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onVideoCall(group: Group)
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onViewInformation(user: User)
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onViewInformation(group: Group)
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onError(message: BaseMessage?, error: CometChatException)
    
    @available(*, deprecated, message: "Use `onTransientMessageReceived(_ message: TransientMessage)` instead")
    func onTransisentMessageReceived(_ message: TransientMessage)
    
    @available(*, deprecated, message: "Use `ccMessageSent(message: BaseMessage, status: MessageStatus)` instead")
    func onMessageSent(message: BaseMessage, status: MessageStatus)
    
    @available(*, deprecated, message: "Use `ccMessageEdit(message: BaseMessage, status: MessageStatus)` instead")
    func onMessageEdit(message: BaseMessage, status: MessageStatus)
    
    @available(*, deprecated, message: "Use `ccMessageDelete(message: BaseMessage)` instead")
    func onMessageDelete(message: BaseMessage)
    
    @available(*, deprecated, message: "Use `ccMessageRead(message: BaseMessage)` instead")
    func onMessageRead(message: BaseMessage)
    
    @available(*, deprecated, message: "Use `ccLiveReaction(reaction: TransientMessage)` instead")
    func onLiveReaction(reaction: TransientMessage)
    
    @available(*, deprecated)
    func onMessageReact(message: CometChatSDK.BaseMessage, reaction: CometChatMessageReaction)

}

//Making all functions optional
public extension CometChatMessageEventListener {
    func onTextMessageReceived(textMessage: TextMessage) {}
    func onMediaMessageReceived(mediaMessage: MediaMessage) {}
    func onCustomMessageReceived(customMessage: CustomMessage) {}
    func onTypingStarted(_ typingIndicator: TypingIndicator) {}
    func onTypingEnded(_ typingIndicator: TypingIndicator) {}
    func onMessagesDelivered(receipt: MessageReceipt) {}
    func onMessagesRead(receipt: MessageReceipt) {}
    func onMessageEdited(message: BaseMessage) {}
    func onMessageDeleted(message: BaseMessage) {}
    func onFormMessageReceived(message: FormMessage) {}
    func onCardMessageReceived(message: CardMessage) {}
    func onSchedulerMessageReceived(message: SchedulerMessage) {}
    func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {}
    func onMessageReactionAdded(reactionEvent: ReactionEvent) {}
    func onMessageReactionRemoved(reactionEvent: ReactionEvent) {}
    func ccMessageSent(message: BaseMessage, status: MessageStatus) {}
    func ccMessageEdited(message: BaseMessage, status: MessageStatus) {}
    func ccMessageDeleted(message: BaseMessage) {}
    func ccMessageRead(message: BaseMessage) {}
    func ccLiveReaction(reaction: TransientMessage) {}
    func onTransientMessageReceived(_ message: CometChatSDK.TransientMessage) {}
    func onMessagesReadByAll(receipt: MessageReceipt) {}
    func onMessagesDeliveredToAll(receipt: MessageReceipt) {}
}

//MARK: Deprecated methods
public extension CometChatMessageEventListener {
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onMessageReply(message: BaseMessage, status: MessageStatus) {}
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onParentMessageUpdate(message: BaseMessage) {}
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onMessageError(error: CometChatException) {}
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onVoiceCall(user: User) {}
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onVoiceCall(group: Group) {}
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onVideoCall(user: User) {}
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onVideoCall(group: Group) {}
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onViewInformation(user: User) {}
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onViewInformation(group: Group) {}
    
    @available(*, deprecated, message: "This method is now deprecated")
    func onError(message: BaseMessage?, error: CometChatException) {}
    
    @available(*, deprecated, message: "Use `onTransientMessageReceived(_ message: TransientMessage)` instead")
    func onTransisentMessageReceived(_ message: TransientMessage) {}
    
    @available(*, deprecated, message: "Use `ccMessageSent(message: BaseMessage, status: MessageStatus)` instead")
    func onMessageSent(message: BaseMessage, status: MessageStatus) {}
    
    @available(*, deprecated, message: "Use `ccMessageEdit(message: BaseMessage, status: MessageStatus)` instead")
    func onMessageEdit(message: BaseMessage, status: MessageStatus) {}
    
    @available(*, deprecated, message: "Use `ccMessageDelete(message: BaseMessage)` instead")
    func onMessageDelete(message: BaseMessage) {}
    
    @available(*, deprecated, message: "Use `ccMessageRead(message: BaseMessage)` instead")
    func onMessageRead(message: BaseMessage) {}
    
    @available(*, deprecated, message: "Use `ccLiveReaction(reaction: TransientMessage)` instead")
    func onLiveReaction(reaction: TransientMessage) {}
    
    @available(*, deprecated)
    func onMessageReact(message: CometChatSDK.BaseMessage, reaction: CometChatMessageReaction) {}
}
