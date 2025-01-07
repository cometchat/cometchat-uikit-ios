//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 03/02/23.
//

import Foundation
import CometChatSDK

extension ConversationsViewModel: CometChatMessageEventListener {
    
    public func onFormMessageReceived(message: FormMessage) {
        if checkForConversationUpdate(message: message) {
            newMessageReceived?(message)
            update(lastMessage: message)
        }
    }
    
    func onSchedulerMessageReceived(message: SchedulerMessage) {
        if checkForConversationUpdate(message: message) {
            newMessageReceived?(message)
            update(lastMessage: message)
        }
    }
    
    func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {
        if checkForConversationUpdate(message: message) {
            newMessageReceived?(message)
            update(lastMessage: message)
        }
    }
    
    public func onCardMessageReceived(message: CardMessage) {
        if checkForConversationUpdate(message: message) {
            newMessageReceived?(message)
            update(lastMessage: message)
        }
    }
    
    func ccMessageSent(message: BaseMessage, status: MessageStatus) {
        if status == .success {
            if checkForConversationUpdate(message: message) {
                update(lastMessage: message)
            }
        }
    }
    
    public func onTextMessageReceived(textMessage: TextMessage) {
        if checkForConversationUpdate(message: textMessage) {
            newMessageReceived?(textMessage)
            update(lastMessage: textMessage)
            
        }
    }
    
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        if checkForConversationUpdate(message: mediaMessage) {
            newMessageReceived?(mediaMessage)
            update(lastMessage: mediaMessage)
        }
    }
    
    public func onCustomMessageReceived(customMessage: CustomMessage) {
        if checkForConversationUpdate(message: customMessage) {
            newMessageReceived?(customMessage)
            update(lastMessage: customMessage)
        }
    }
    
    public func onTypingStarted(_ typingDetails: TypingIndicator) {
        if let row = getConversationRow(with: typingDetails) {
            updateTypingIndicator?(row,typingDetails , true)
        }
    }
    
    public func onTypingEnded(_ typingDetails: TypingIndicator) {
        if let row = getConversationRow(with: typingDetails) {
            updateTypingIndicator?(row, typingDetails, false)
        }
    }
    
    public func ccMessageDeleted(message: BaseMessage) {
        update(lastMessage: message, updateCount: false)
    }
    
    func onMessageDeleted(message: BaseMessage) {
        updateAlreadyPresent(lastMessage: message)
    }
    
    func onMessagesRead(receipt: MessageReceipt) {
        updateReceipt(receipt: receipt)
    }
    
    func ccMessageRead(message: BaseMessage) {
        updateReceipt(message: message)
    }
    
    func onMessagesDelivered(receipt: MessageReceipt) {
        updateReceipt(receipt: receipt)
    }
    
    func onMessagesReadByAll(receipt: MessageReceipt) {
        updateReceipt(receipt: receipt)
    }
    
    func onMessagesDeliveredToAll(receipt: MessageReceipt) {
        updateReceipt(receipt: receipt)
    }
    
    func ccMessageEdited(message: BaseMessage, status: MessageStatus) {
        if checkForConversationUpdate(message: message) {
            if status == .success {
                updateAlreadyPresent(lastMessage: message)
            }
        }
    }
    
    func onMessageEdited(message: BaseMessage) {
        if checkForConversationUpdate(message: message) {
            updateAlreadyPresent(lastMessage: message)
        }
    }
    
    func updateReceipt(receipt: MessageReceipt) {
        
        if let conversation = conversations.first(where: {
            (
                ($0.conversationWith as? Group)?.guid == receipt.receiverId &&
                receipt.receiverType == .group
            ) || (
                (
                    ($0.conversationWith as? User)?.uid == receipt.sender?.uid ||
                    ($0.conversationWith as? User)?.uid == receipt.receiverId
                ) &&
                receipt.receiverType == .user
            )
        }) {
            
            //updating last message
            if conversation.lastMessage?.senderUid == CometChat.getLoggedInUser()?.uid {
                if receipt.receiverType == .user {
                    if receipt.receiptType == .read && conversation.lastMessage?.readAt == 0 {
                        conversation.lastMessage?.readAt = receipt.readAt
                    } else if receipt.receiptType == .delivered && conversation.lastMessage?.deliveredAt == 0  {
                        conversation.lastMessage?.deliveredAt = receipt.deliveredAt
                    }
                } else if receipt.receiverType == .group {
                    if receipt.receiptType == .readByAll && conversation.lastMessage?.readAt == 0 {
                        conversation.lastMessage?.readAt = receipt.readAt
                    } else if receipt.receiptType == .deliveredToAll && conversation.lastMessage?.deliveredAt == 0  {
                        conversation.lastMessage?.deliveredAt = receipt.deliveredAt
                    }
                }
                update(conversation: conversation)
            }
            
            //updating unread message count
            if receipt.receiptType == .read {
                conversation.unreadMessageCount = 0
                update(conversation: conversation)
            }
            
            
        }
        
    }
    
    func updateReceipt(message: BaseMessage) {
        
        if let conversation = conversations.first(where: {
            (
                ($0.conversationWith as? Group)?.guid == message.receiverUid &&
                message.receiverType == .group
            )
            ||
            (
                ($0.conversationWith as? User)?.uid == message.senderUid &&
                message.receiverType == .user
            )
        }) {
            if conversation.lastMessage?.id == message.id {
                conversation.lastMessage = message
                conversation.updatedAt = message.readAt
            }
            conversation.unreadMessageCount = 0
            update(conversation: conversation)
        }
        
    }
    
}
