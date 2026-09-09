//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 03/02/23.
//

import Foundation
import CometChatSDK

extension ConversationsViewModel: CometChatConversationEventListener {
    
    func ccConversationDeleted(conversation: Conversation) {
        self.remove(conversation: conversation)
    }
    
    func ccUpdateConversation(conversation: Conversation) {
        // A pin change moves the row between tiers, which `update(conversation:)` cannot do —
        // it reloads in place. Route those through the repositioning path instead.
        if let existing = conversations.first(where: { $0.conversationId == conversation.conversationId }),
           existing.pinnedAt != conversation.pinnedAt {
            self.repositionForPinChange(conversation: conversation)
            return
        }
        self.update(conversation: conversation)
    }
    
}
