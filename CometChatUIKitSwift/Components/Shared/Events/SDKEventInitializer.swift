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

    /// A per-user conversation pin syncs from the user's other devices; an admin-global pin
    /// (`pinnedBy` == `app_system`) broadcasts to everyone affected. Both land here.
    ///
    /// Forwarded onto the existing conversation update event rather than a new pin-specific
    /// one: the payload is a full conversation carrying the new `pinnedAt`, and the list
    /// already listens for this to reposition the row.
    ///
    /// > Important: the `conversation_pin` envelope these ride on is **unverified** — the SDK
    /// > infers its shape from the confirmed `message_save` frame, both being per-user
    /// > self-echoes, and no real frame has been captured yet. Message pin/save (below) is
    /// > confirmed; this pair should be re-checked against live traffic.
    public func onConversationPinned(conversation: Conversation) {
        CometChatConversationEvents.ccUpdateConversation(conversation: conversation)
    }
    public func onConversationUnpinned(conversation: Conversation) {
        CometChatConversationEvents.ccUpdateConversation(conversation: conversation)
    }
    
    /// Live frames, forwarded onto the kit's own bus.
    ///
    /// Pin is conversation-wide, so a pin reaches every participant; save is private and its
    /// frames only ever reach the saving user's other devices. The acting device receives its
    /// own echo here too, on top of the `ccMessagePinned`/`ccMessageSaved` the surface emits —
    /// listeners must therefore tolerate both for one action.
    public func onMessagePinned(message: BaseMessage) {
        CometChatMessageEvents.onMessagePinned(message: message)
    }

    public func onMessageUnpinned(message: BaseMessage) {
        CometChatMessageEvents.onMessageUnpinned(message: message)
    }

    public func onMessageSaved(message: BaseMessage) {
        CometChatMessageEvents.onMessageSaved(message: message)
    }

    public func onMessageUnsaved(message: BaseMessage) {
        CometChatMessageEvents.onMessageUnsaved(message: message)
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
    
    public func onMessageModerated(_ message: BaseMessage) {
        CometChatMessageEvents.onMessageModerated(message: message)
    }
    
    public func onAIAssistantMessageReceived(_ message: AIAssistantMessage) {
        CometChatMessageEvents.onAIAssistantMessageReceived(message: message)
    }
    
    public func onCardMessageReceived(cardMessage: CometChatSDK.CardMessage) {
        CometChatMessageEvents.onNewCardMessageReceived(cardMessage: cardMessage)
    }
    
}
