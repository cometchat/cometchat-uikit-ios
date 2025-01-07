//
//  File.swift
//  
//
//  Created by Admin on 30/10/23.
//

import Foundation
import CometChatSDK

public class SDKEventInitializer : CometChatMessageDelegate {
    init() {
        CometChat.addMessageListener("sdk-listener", self)
    }
    
    public func onTextMessageReceived(textMessage: TextMessage) {
        CometChatMessageEvents.onTextMessageReceived(textMessage: textMessage)
    }
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        CometChatMessageEvents.onMediaMessageReceived(message: mediaMessage)
    }
    public func onCustomMessageReceived(customMessage: CustomMessage) {
        CometChatMessageEvents.onCustomMessageReceived(message: customMessage)
    }
    public func onTypingStarted(_ typingIndicator: TypingIndicator) {
        CometChatMessageEvents.onTypingStarted(typingIndicator)
    }
    public func onTypingEnded(_ typingIndicator: TypingIndicator) {
        CometChatMessageEvents.onTypingEnded(typingIndicator)
    }
    public func onMessagesDelivered(receipt: MessageReceipt) {
        CometChatMessageEvents.onMessagesDelivered(receipt: receipt)
    }
    public func onMessagesRead(receipt: MessageReceipt) {
        CometChatMessageEvents.onMessagesRead(receipt: receipt)
    }
    public func onMessageEdited(message: BaseMessage) {
        CometChatMessageEvents.onMessageEdited(message: message)
    }
    public func onMessageDeleted(message: BaseMessage ) {
        CometChatMessageEvents.onMessageDeleted(message: message)
    }
    public func onTransisentMessageReceived(_ message: TransientMessage) {
        CometChatMessageEvents.onTransientMessageReceived(message)
    }
    
    public func onMessagesReadByAll(receipt: MessageReceipt) {
        CometChatMessageEvents.onMessagesReadByAll(receipt: receipt)
    }
    
    public func onMessagesDeliveredToAll(receipt: MessageReceipt) {
        CometChatMessageEvents.onMessagesDeliveredToAll(receipt: receipt)
    }
    
    public func onInteractiveMessageReceived(interactiveMessage: InteractiveMessage) {
        if interactiveMessage.type == MessageTypeConstants.form {
            CometChatMessageEvents.onFormMessageReceived(message: FormMessage.toFormMessage(interactiveMessage));
        } else if interactiveMessage.type == MessageTypeConstants.card {
            CometChatMessageEvents.onCardMessageReceived(message: CardMessage.toCardMessage(interactiveMessage));
        } else if interactiveMessage.type == MessageTypeConstants.scheduler {
            CometChatMessageEvents.onSchedulerMessageReceived(message: SchedulerMessage.toSchedulerMessage(interactiveMessage));
        } else{
            CometChatMessageEvents.onCustomInteractiveMessageReceived(message: CustomInteractiveMessage.toCustomInteractiveMessage(interactiveMessage));
        }
    }
    
    public func onMessageReactionAdded(reactionEvent: ReactionEvent) {
        CometChatMessageEvents.onMessageReactionAdded(reactionEvent: reactionEvent)
    }
    
    public func onMessageReactionRemoved(reactionEvent: ReactionEvent) {
        CometChatMessageEvents.onMessageReactionRemoved(reactionEvent: reactionEvent)
    }
    
}
