//
//  SearchViewModel + CometChatConversationEventListener.swift
//  CometChatUIKitSwift
//
//  Created by Prathmesh on 17/12/25.
//

import Foundation
import CometChatSDK

extension SearchViewModel: CometChatConversationEventListener {
    
    public func ccConversationDeleted(conversation: Conversation) {
        if let index = filteredConversations.firstIndex(where: { $0.conversationId == conversation.conversationId }) {
            filteredConversations.remove(at: index)
            reload?()
        }
    }
}
