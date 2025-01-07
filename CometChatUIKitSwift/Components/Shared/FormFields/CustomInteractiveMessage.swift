//
//  CustomInteractiveMessage.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 02/02/24.
//

import Foundation
import CometChatSDK

public class CustomInteractiveMessage: InteractiveMessage {
    
    public override init() {
        super.init()
    }
    
    public static func toCustomInteractiveMessage(_ interactiveMessage: InteractiveMessage) -> CustomInteractiveMessage {
        
        let customInteractiveMessage = CustomInteractiveMessage()
        customInteractiveMessage.type = MessageCategoryConstants.custom
        customInteractiveMessage.id = interactiveMessage.id
        customInteractiveMessage.receiverType = interactiveMessage.receiverType
        customInteractiveMessage.receiver = interactiveMessage.receiver
        customInteractiveMessage.sender = interactiveMessage.sender
        customInteractiveMessage.senderUid = interactiveMessage.senderUid
        customInteractiveMessage.sentAt = interactiveMessage.sentAt
        customInteractiveMessage.readAt = interactiveMessage.readAt
        customInteractiveMessage.deliveredAt = interactiveMessage.deletedAt
        customInteractiveMessage.updatedAt = interactiveMessage.updatedAt
        customInteractiveMessage.deletedBy = interactiveMessage.deletedBy
        customInteractiveMessage.interactionGoal = interactiveMessage.interactionGoal
        customInteractiveMessage.metaData = interactiveMessage.metaData
        customInteractiveMessage.muid = interactiveMessage.muid
        customInteractiveMessage.rawMessage = interactiveMessage.rawMessage
        customInteractiveMessage.conversationId = interactiveMessage.conversationId
        customInteractiveMessage.readByMeAt = interactiveMessage.readByMeAt
        customInteractiveMessage.receiverUid = interactiveMessage.receiverUid
        customInteractiveMessage.replyCount = interactiveMessage.replyCount
        customInteractiveMessage.tags = interactiveMessage.tags
        customInteractiveMessage.allowSenderInteraction = interactiveMessage.allowSenderInteraction
        customInteractiveMessage.interactions = interactiveMessage.interactions
        customInteractiveMessage.interactiveData = interactiveMessage.interactiveData
        customInteractiveMessage.reactions = interactiveMessage.reactions
        customInteractiveMessage.mentionedMe = interactiveMessage.mentionedMe
        customInteractiveMessage.mentionedUsers = interactiveMessage.mentionedUsers
        
        return customInteractiveMessage
    }
    
    
    public static func interactiveMessage(from customInteractiveMessage: CustomInteractiveMessage) -> InteractiveMessage {
        
        let interactiveMessage = InteractiveMessage()
        interactiveMessage.type = MessageCategoryConstants.custom
        interactiveMessage.id = customInteractiveMessage.id
        interactiveMessage.receiverType = customInteractiveMessage.receiverType
        interactiveMessage.receiver = customInteractiveMessage.receiver
        interactiveMessage.sender = customInteractiveMessage.sender
        interactiveMessage.senderUid = customInteractiveMessage.senderUid
        interactiveMessage.sentAt = customInteractiveMessage.sentAt
        interactiveMessage.readAt = customInteractiveMessage.readAt
        interactiveMessage.deliveredAt = customInteractiveMessage.deletedAt
        interactiveMessage.updatedAt = customInteractiveMessage.updatedAt
        interactiveMessage.deletedBy = customInteractiveMessage.deletedBy
        interactiveMessage.interactionGoal = customInteractiveMessage.interactionGoal
        interactiveMessage.metaData = customInteractiveMessage.metaData
        interactiveMessage.muid = customInteractiveMessage.muid
        interactiveMessage.rawMessage = customInteractiveMessage.rawMessage
        interactiveMessage.conversationId = customInteractiveMessage.conversationId
        interactiveMessage.readByMeAt = customInteractiveMessage.readByMeAt
        interactiveMessage.receiverUid = customInteractiveMessage.receiverUid
        interactiveMessage.replyCount = customInteractiveMessage.replyCount
        interactiveMessage.tags = customInteractiveMessage.tags
        interactiveMessage.allowSenderInteraction = customInteractiveMessage.allowSenderInteraction
        interactiveMessage.interactions = customInteractiveMessage.interactions
        interactiveMessage.interactiveData = customInteractiveMessage.interactiveData
                
        return interactiveMessage
    }
    
}
