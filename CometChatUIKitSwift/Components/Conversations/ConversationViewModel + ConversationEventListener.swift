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
        // Offline ON: the event is matched to a row by (type, with), and a pin event about a chat
        // that is not shown is fetched and inserted (UIK-CONV-01).
        if OfflineGate.isOn() {
            offlineHandleConversationUpdate(conversation)
            return
        }
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

extension ConversationsViewModel: ConversationPinStateListener {

    /// A pin or unpin frame from the SDK (the user's other device, or an admin pin). Its
    /// conversation is compact (no name, avatar, last message or unread count), so only its pin
    /// state goes onto the row shown, which keeps its user or group, last message and unread count
    /// and moves to its pin tier (BUG-11), as the Android UI Kit's `withPinState` does. A chat that
    /// is not shown: offline ON fetches and inserts it (UIK-CONV-01); offline OFF leaves it.
    func applyPinState(from event: Conversation) {
        let index: Int?
        if OfflineGate.isOn() {
            switch ConversationRows.pinEventAction(event, rows: conversations, loggedInUid: service.loggedInUserUid(), filtered: requestNarrows) {
            case .ignore:
                return
            case .fetchAndInsert:
                offlineHandleConversationUpdate(event)
                return
            case .update(let row):
                index = row
            }
        } else {
            index = ConversationRows.index(of: event, in: conversations)
                ?? event.conversationId.flatMap { id in conversations.firstIndex { $0.conversationId == id } }
        }
        guard let index = index, conversations.indices.contains(index) else { return }
        let row = conversations[index]
        row.pinnedAt = event.pinnedAt
        row.pinnedBy = event.pinnedBy
        repositionForPinChange(conversation: row)
    }
}
