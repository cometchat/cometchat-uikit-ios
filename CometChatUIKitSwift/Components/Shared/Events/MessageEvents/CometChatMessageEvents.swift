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
    
    public static func addListener(_ id: String,_ observer: CometChatMessageEventListener) {
        if let anyObject = observer as? AnyObject {
            self.observer.setObject(anyObject, forKey: NSString(string: id))
        }
    }
    
    public static func removeListener(_ id: String) {
         self.observer.removeObject(forKey: NSString(string: id))
    }
    
    public static func onMessagesReadByAll(receipt: MessageReceipt) {
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessagesReadByAll(receipt: receipt)
        }
    }
    
    public static func onMessagesDeliveredToAll(receipt: MessageReceipt) {
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessagesDeliveredToAll(receipt: receipt)
        }
    }
    
    public static  func onTextMessageReceived(textMessage: TextMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onTextMessageReceived(textMessage: textMessage)
        }
    }
    
    public static  func onMediaMessageReceived(message: MediaMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMediaMessageReceived(mediaMessage: message)
        }
    }
    
    public static func onCustomMessageReceived(message: CustomMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onCustomMessageReceived(customMessage: message)
        }
    }

    public static func onTypingStarted(_ typingIndicator: TypingIndicator) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onTypingStarted(typingIndicator)
        }
    }

    public static func onTypingEnded(_ typingIndicator: TypingIndicator) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onTypingEnded(typingIndicator)
        }
    }

    public static func onMessagesDelivered(receipt: MessageReceipt) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessagesDelivered(receipt: receipt)
        }
    }

    public static func onMessagesRead(receipt: MessageReceipt) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessagesRead(receipt: receipt)
        }
    }

    public static func onTransientMessageReceived(_ message: TransientMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onTransientMessageReceived(message)
        }
    }

    public static func onFormMessageReceived(message: FormMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onFormMessageReceived(message: message)
        }
    }

    public static func onCardMessageReceived(message: CardMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onCardMessageReceived(message: message)
        }
    }

    public static func onSchedulerMessageReceived(message: SchedulerMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onSchedulerMessageReceived(message: message)
        }
    }

    public static func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onCustomInteractiveMessageReceived(message: message)
        }
    }

    public static func ccMessageSent(message: BaseMessage, status: MessageStatus) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.ccMessageSent(message: message, status: status)
            value.onMessageSent(message: message, status: status)
        }
    }

    public static func ccMessageEdited(message: BaseMessage, status: MessageStatus) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.ccMessageEdited(message: message, status: status)
            value.onMessageEdit(message: message, status: status)
        }
    }

    public static func onMessageEdited(message: BaseMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageEdited(message: message)
        }
    }

    public static func ccMessageDeleted(message: BaseMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.ccMessageDeleted(message: message)
            value.onMessageDelete(message: message)
        }
    }

    public static func onMessageDeleted(message: BaseMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageDeleted(message: message)
        }
    }

    public static func ccMessageRead(message: BaseMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.ccMessageRead(message: message)
            value.onMessageRead(message: message)
        }
    }

    public static func onMessageRead(receipt: MessageReceipt) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessagesRead(receipt: receipt)
        }
    }

    public static func ccLiveReaction(reaction: TransientMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.ccLiveReaction(reaction: reaction)
            value.onLiveReaction(reaction: reaction)
        }
    }

    public static func onMessageReactionAdded(reactionEvent: ReactionEvent) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageReactionAdded(reactionEvent: reactionEvent)
        }
    }

    public static func onMessageReactionRemoved(reactionEvent: ReactionEvent) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageReactionRemoved(reactionEvent: reactionEvent)
        }
    }

}



//MARK: Deprecated Functions
extension CometChatMessageEvents {
    
    @available(*, deprecated, message: "Use `onTransientMessageReceived(_ message: TransientMessage)` instead")
    public static func onTransisentMessageReceived(_ message: TransientMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onTransisentMessageReceived(message)
            value.onTransientMessageReceived(message)
        }
    }
    
    @available(*, deprecated, message: "Use `ccMessageSent(message: BaseMessage, status: MessageStatus)` instead")
    public static func emitOnMessageSent(message: BaseMessage, status: MessageStatus) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageSent(message: message, status: status)
            value.ccMessageSent(message: message, status: status)
        }
    }
    
    @available(*, deprecated, message: "Use `ccMessageEdited(message: BaseMessage)` instead")
    public static func emitOnMessageEdit(message: BaseMessage, status: MessageStatus) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageEdit(message: message, status: status)
            value.ccMessageEdited(message: message, status: status)
        }
    }
    
    @available(*, deprecated, message: "Use `ccMessageDeleted(message: BaseMessage)` instead")
    public static func emitOnMessageDelete(message: BaseMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageDelete(message: message)
            value.ccMessageDeleted(message: message)
        }
    }
    
    @available(*, deprecated, message: "Use `ccMessageEdited(message: BaseMessage, status: MessageStatus)` instead")
    public static func emitOnMessageReply(message: BaseMessage, status: MessageStatus) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageReply(message: message, status: status)
        }
    }
    
    @available(*, deprecated, message: "Use `ccMessageRead(message: BaseMessage)` instead")
    public static func emitOnMessageRead(message: BaseMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageRead(message: message)
            value.ccMessageRead(message: message)
        }
    }
    
    @available(*, deprecated, message: "Use `ccLiveReaction(reaction: TransientMessage)` instead")
    public static func emitOnLiveReaction(reaction: TransientMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onLiveReaction(reaction: reaction)
            value.ccLiveReaction(reaction: reaction)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnVoiceCall(user: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onVoiceCall(user: user)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnVoiceCall(group: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onVoiceCall(group: group)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnVideoCall(user: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onVideoCall(user: user)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnVideoCall(group: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onVideoCall(group: group)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnViewInformation(user: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onViewInformation(user: user)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnViewInformation(group: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onViewInformation(group: group)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnError(message: BaseMessage?, error: CometChatException) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onError(message: message, error: error)
        }
    }
    
    @available(*, deprecated, message: "This function is now deprecated")
    public static func emitOnParentMessageUpdate(message: BaseMessage) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onParentMessageUpdate(message: message)
        }
    }
    
    @available(*, deprecated, message: "Use `onMessageReactionAdded(reactionEvent: ReactionEvent)` instead")
    public static func emitOnMessageReactionAdded(reactionEvent: ReactionEvent) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageReactionAdded(reactionEvent: reactionEvent)
        }
    }
    
    @available(*, deprecated, message: "Use `onMessageReactionRemoved(reactionEvent: ReactionEvent)` instead")
    public static func emitOnMessageReactionRemoved(reactionEvent: ReactionEvent) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatMessageEventListener {
            value.onMessageReactionRemoved(reactionEvent: reactionEvent)
        }
    }
    
}
