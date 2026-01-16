//
//  SearchViewModel + MessageEventListener.swift
//  CometChatUIKitSwift
//
//  Created by Prathmesh on 17/12/25.
//


import UIKit
import CometChatSDK

extension SearchViewModel : CometChatMessageEventListener {
    
    public func ccMessageRead(message: BaseMessage) {
        updateReceipt(message: message)
    }
    
    public func onMessagesRead(receipt: MessageReceipt) {
        updateReceiptForConversations(receipt: receipt)
    }
    
    public func onMessagesDelivered(receipt: MessageReceipt) {
        updateReceiptForConversations(receipt: receipt)
    }
    
    func update(conversation: Conversation) {
        if let currentRow = filteredConversations.firstIndex(where: {
            return $0.conversationId == conversation.conversationId
        }) {
            filteredConversations[currentRow] = conversation
            self.reloadAtIndex?(IndexPath(row: currentRow, section: 0))
        }
    }
    
    func updateReceipt(message: BaseMessage) {
        
        if let conversation = filteredConversations.first(where: {
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
//                conversation.updatedAt = message.readAt
            }
            conversation.unreadMessageCount = 0
            update(conversation: conversation)
        }
        
    }
    
    func updateReceiptForConversations(receipt: MessageReceipt) {
        
        if let conversation = filteredConversations.first(where: {
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
            
            //updating last message receipt
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
            
            //updating unread message count when messages are read
            if receipt.receiptType == .read || receipt.receiptType == .readByAll {
                conversation.unreadMessageCount = 0
                update(conversation: conversation)
            }
        }
        
    }
    
}

