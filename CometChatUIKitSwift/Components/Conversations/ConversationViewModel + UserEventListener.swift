//
//  ConversationsViewModel + CometChatUserEventListener.swift
//  
//
//  Created by Abdullah Ansari on 03/02/23.
//

import Foundation
import CometChatSDK

// MARK: - CometChatUserEventListener
extension ConversationsViewModel: CometChatUserEventListener {
    
    func ccUserBlocked(user: CometChatSDK.User) {
        if conversationRequest?.includeBlockedUsers == false {
            removerConversation(for: user)
        }
    }
    
}


extension ConversationsViewModel : CometChatUserDelegate {
    
    public func onUserOnline(user: User) {
        guard let row = self.conversations.firstIndex(where: { ( $0.conversationWith as? User)?.uid == user.uid }) else { return }
        self.conversations[row].conversationWith = user
        updateStatus?(row, .online)
    }
    
    public func onUserOffline(user: User) {
        guard let row = self.conversations.firstIndex(where: { ( $0.conversationWith as? User)?.uid == user.uid }) else { return }
        self.conversations[row].conversationWith = user
        updateStatus?(row, .offline)
    }
    
}
