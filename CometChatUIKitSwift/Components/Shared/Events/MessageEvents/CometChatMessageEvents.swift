//
//  DeprecatedMessageEvents.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 15/06/24.
//

import Foundation
import CometChatSDK

public class CometChatMessageEvents {
    
    static private var observer = NSMapTable<NSString, AnyObject>(keyOptions: .strongMemory, valueOptions: .weakMemory)

    // Concurrency. This table is process-wide: components register and unregister from
    // SDK callback threads while broadcasts iterate on main. NSMapTable is not
    // thread-safe, and mutating one while another thread enumerates it is undefined
    // behaviour, not merely a stale read. The observed symptoms were an event delivered
    // twice and a listener silently dropped from the table.
    //
    // A lock ALONE would not fix this, for two reasons unrelated to other threads:
    //   1. values are `.weakMemory`, so ARC can zero an entry DURING an enumeration;
    //   2. callbacks used to run inside the enumeration loop, so a listener that called
    //      removeListener (directly, or by releasing the last strong ref to another
    //      listener) mutated the table on the SAME thread. A plain lock deadlocks there;
    //      a recursive lock lets the mutation through and corrupts the enumerator anyway.
    //
    // Hence snapshot-then-dispatch: copy into strong references under the lock, release
    // it, then call the listeners. Callbacks therefore run with no lock held, so a
    // listener may freely add or remove listeners during delivery.
    private static let lock = NSLock()

    private static func listeners() -> [CometChatMessageEventListener] {
        lock.lock()
        defer { lock.unlock() }
        var snapshot: [CometChatMessageEventListener] = []
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            snapshot.append(value)
        }
        return snapshot
    }
    
    public static func addListener(_ id: String,_ observer: CometChatMessageEventListener) {
        lock.lock()
        defer { lock.unlock() }
        if let anyObject = observer as? AnyObject {
            self.observer.setObject(anyObject, forKey: NSString(string: id))
        }
    }
    
    public static func removeListener(_ id: String) {
        lock.lock()
        defer { lock.unlock() }
         self.observer.removeObject(forKey: NSString(string: id))
    }
    
    /// Pin is conversation-wide, so this fires on every participant's device. Save is
    /// private, so `onMessageSaved`/`onMessageUnsaved` only ever reach the saving user's
    /// other devices.
    public static func onMessagePinned(message: BaseMessage) {
        for value in listeners() {
            value.onMessagePinned(message: message)
        }
    }

    public static func onMessageUnpinned(message: BaseMessage) {
        for value in listeners() {
            value.onMessageUnpinned(message: message)
        }
    }

    public static func onMessageSaved(message: BaseMessage) {
        for value in listeners() {
            value.onMessageSaved(message: message)
        }
    }

    public static func onMessageUnsaved(message: BaseMessage) {
        for value in listeners() {
            value.onMessageUnsaved(message: message)
        }
    }

    /// Emitted by the acting surface so panels update without waiting on realtime.
    /// Read `message.pinnedAt` to tell pin from unpin.
    public static func ccMessagePinned(message: BaseMessage, status: MessageStatus) {
        for value in listeners() {
            value.ccMessagePinned(message: message, status: status)
        }
    }

    public static func ccMessageSaved(message: BaseMessage, status: MessageStatus) {
        for value in listeners() {
            value.ccMessageSaved(message: message, status: status)
        }
    }

    public static func onMessagesReadByAll(receipt: MessageReceipt) {
        for value in listeners() {
            value.onMessagesReadByAll(receipt: receipt)
        }
    }
    
    public static func onMessagesDeliveredToAll(receipt: MessageReceipt) {
        for value in listeners() {
            value.onMessagesDeliveredToAll(receipt: receipt)
        }
    }
    
    public static  func onTextMessageReceived(textMessage: TextMessage) {
        
        for value in listeners() {
            value.onTextMessageReceived(textMessage: textMessage)
        }
    }
    
    public static  func onMessageModerated(message: BaseMessage) {
        
        for value in listeners() {
            value.onMessageModerated(message: message)
        }
    }
    
    public static  func onAIAssistantMessageReceived(message: AIAssistantMessage) {
        
        for value in listeners() {
            value.onAIAssistantMessageReceived(message: message)
        }
    }
    
    public static  func onMediaMessageReceived(message: MediaMessage) {
        
        for value in listeners() {
            value.onMediaMessageReceived(mediaMessage: message)
        }
    }
    
    public static func onCustomMessageReceived(message: CustomMessage) {
        
        for value in listeners() {
            value.onCustomMessageReceived(customMessage: message)
        }
    }

    public static func onTypingStarted(_ typingIndicator: TypingIndicator) {
        
        for value in listeners() {
            value.onTypingStarted(typingIndicator)
        }
    }

    public static func onTypingEnded(_ typingIndicator: TypingIndicator) {
        
        for value in listeners() {
            value.onTypingEnded(typingIndicator)
        }
    }

    public static func onMessagesDelivered(receipt: MessageReceipt) {
        
        for value in listeners() {
            value.onMessagesDelivered(receipt: receipt)
        }
    }

    public static func onMessagesRead(receipt: MessageReceipt) {
        
        for value in listeners() {
            value.onMessagesRead(receipt: receipt)
        }
    }

    public static func onTransientMessageReceived(_ message: TransientMessage) {
        
        for value in listeners() {
            value.onTransientMessageReceived(message)
        }
    }

    public static func onFormMessageReceived(message: FormMessage) {
        
        for value in listeners() {
            value.onFormMessageReceived(message: message)
        }
    }

    public static func onCardMessageReceived(message: CardMessage) {
        
        for value in listeners() {
            value.onCardMessageReceived(message: message)
        }
    }

    public static func onSchedulerMessageReceived(message: SchedulerMessage) {
        
        for value in listeners() {
            value.onSchedulerMessageReceived(message: message)
        }
    }

    public static func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {
        
        for value in listeners() {
            value.onCustomInteractiveMessageReceived(message: message)
        }
    }

    public static func ccMessageSent(message: BaseMessage, status: MessageStatus) {
        
        for value in listeners() {
            value.ccMessageSent(message: message, status: status)
            value.onMessageSent(message: message, status: status)
        }
    }

    public static func ccMessageEdited(message: BaseMessage, status: MessageStatus) {
        
        for value in listeners() {
            value.ccMessageEdited(message: message, status: status)
            value.onMessageEdit(message: message, status: status)
        }
    }
    
    public static func ccReplyToMessage(message: BaseMessage, status: MessageStatus) {
        
        for value in listeners() {
            value.ccReplyToMessage(message: message, status: status)
        }
    }

    public static func onMessageEdited(message: BaseMessage) {
        
        for value in listeners() {
            value.onMessageEdited(message: message)
        }
    }

    public static func ccMessageDeleted(message: BaseMessage) {
        
        for value in listeners() {
            value.ccMessageDeleted(message: message)
            value.onMessageDelete(message: message)
        }
    }

    public static func onMessageDeleted(message: BaseMessage) {
        
        for value in listeners() {
            value.onMessageDeleted(message: message)
        }
    }

    public static func ccMessageRead(message: BaseMessage) {
        
        for value in listeners() {
            value.ccMessageRead(message: message)
            value.onMessageRead(message: message)
        }
    }

    public static func onMessageRead(receipt: MessageReceipt) {
        
        for value in listeners() {
            value.onMessagesRead(receipt: receipt)
        }
    }

    public static func ccLiveReaction(reaction: TransientMessage) {
        
        for value in listeners() {
            value.ccLiveReaction(reaction: reaction)
            value.onLiveReaction(reaction: reaction)
        }
    }

    public static func onMessageReactionAdded(reactionEvent: ReactionEvent) {
        
        for value in listeners() {
            value.onMessageReactionAdded(reactionEvent: reactionEvent)
        }
    }

    public static func onMessageReactionRemoved(reactionEvent: ReactionEvent) {
        
        for value in listeners() {
            value.onMessageReactionRemoved(reactionEvent: reactionEvent)
        }
    }

    public static func onNewCardMessageReceived(cardMessage: BaseMessage) {
        
        for value in listeners() {
            value.onNewCardMessageReceived(cardMessage: cardMessage)
        }
    }

}



//MARK: Deprecated Functions
extension CometChatMessageEvents {
    
    @available(*, deprecated, message: "Use `onTransientMessageReceived(_ message: TransientMessage)` instead")
    public static func onTransisentMessageReceived(_ message: TransientMessage) {
        
        for value in listeners() {
            value.onTransisentMessageReceived(message)
            value.onTransientMessageReceived(message)
        }
    }
    
    @available(*, deprecated, message: "Use `ccMessageSent(message: BaseMessage, status: MessageStatus)` instead")
    public static func emitOnMessageSent(message: BaseMessage, status: MessageStatus) {
        
        for value in listeners() {
            value.onMessageSent(message: message, status: status)
            value.ccMessageSent(message: message, status: status)
        }
    }
    
    @available(*, deprecated, message: "Use `ccMessageEdited(message: BaseMessage)` instead")
    public static func emitOnMessageEdit(message: BaseMessage, status: MessageStatus) {
        
        for value in listeners() {
            value.onMessageEdit(message: message, status: status)
            value.ccMessageEdited(message: message, status: status)
        }
    }
    
    @available(*, deprecated, message: "Use `ccMessageDeleted(message: BaseMessage)` instead")
    public static func emitOnMessageDelete(message: BaseMessage) {
        
        for value in listeners() {
            value.onMessageDelete(message: message)
            value.ccMessageDeleted(message: message)
        }
    }
    
    @available(*, deprecated, message: "Use `ccMessageEdited(message: BaseMessage, status: MessageStatus)` instead")
    public static func emitOnMessageReply(message: BaseMessage, status: MessageStatus) {
        
        for value in listeners() {
            value.onMessageReply(message: message, status: status)
        }
    }
    
    @available(*, deprecated, message: "Use `ccMessageRead(message: BaseMessage)` instead")
    public static func emitOnMessageRead(message: BaseMessage) {
        
        for value in listeners() {
            value.onMessageRead(message: message)
            value.ccMessageRead(message: message)
        }
    }
    
    @available(*, deprecated, message: "Use `ccLiveReaction(reaction: TransientMessage)` instead")
    public static func emitOnLiveReaction(reaction: TransientMessage) {
        
        for value in listeners() {
            value.onLiveReaction(reaction: reaction)
            value.ccLiveReaction(reaction: reaction)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnVoiceCall(user: User) {
        
        for value in listeners() {
            value.onVoiceCall(user: user)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnVoiceCall(group: Group) {
        
        for value in listeners() {
            value.onVoiceCall(group: group)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnVideoCall(user: User) {
        
        for value in listeners() {
            value.onVideoCall(user: user)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnVideoCall(group: Group) {
        
        for value in listeners() {
            value.onVideoCall(group: group)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnViewInformation(user: User) {
        
        for value in listeners() {
            value.onViewInformation(user: user)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnViewInformation(group: Group) {
        
        for value in listeners() {
            value.onViewInformation(group: group)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnError(message: BaseMessage?, error: CometChatException) {
        
        for value in listeners() {
            value.onError(message: message, error: error)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnParentMessageUpdate(message: BaseMessage) {
        
        for value in listeners() {
            value.onParentMessageUpdate(message: message)
        }
    }
    
    @available(*, deprecated, message: "Use `onMessageReactionAdded(reactionEvent: ReactionEvent)` instead")
    public static func emitOnMessageReactionAdded(reactionEvent: ReactionEvent) {
        
        for value in listeners() {
            value.onMessageReactionAdded(reactionEvent: reactionEvent)
        }
    }
    
    @available(*, deprecated, message: "Use `onMessageReactionRemoved(reactionEvent: ReactionEvent)` instead")
    public static func emitOnMessageReactionRemoved(reactionEvent: ReactionEvent) {
        
        for value in listeners() {
            value.onMessageReactionRemoved(reactionEvent: reactionEvent)
        }
    }
    
}
