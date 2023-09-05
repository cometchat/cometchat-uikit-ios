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
    
    // called when user block
    func onUserBlock(user: CometChatSDK.User) {
        // TODO:- Needs to ask. Not updating in real time.
//        guard let row = self.conversations.firstIndex(where: { ( $0.conversationWith as? User)?.uid == user.uid }) else { return }
//        user.hasBlockedMe = true
//        self.conversations.remove(at: row)
//        onDelete?(0, row)
        print("ConversationsViewModel - events - onUserBlock")
    }
    
    // called when user un-block
    func onUserUnblock(user: CometChatSDK.User) {
        // TODO:- According to figma, there is no code when user is got unblock.
        
        print("ConversationsViewModel - events - onUserUnblock")
    }
}


extension ConversationsViewModel : CometChatUserDelegate {
    
    public func onUserOnline(user: User) {
        guard let row = self.conversations.firstIndex(where: { ( $0.conversationWith as? User)?.uid == user.uid }) else { return }
        updateStatus?(row, .online)
        print("ConversationsViewModel - sdk - onUserOnline")
    }
    
    public func onUserOffline(user: User) {
        guard let row = self.conversations.firstIndex(where: { ( $0.conversationWith as? User)?.uid == user.uid }) else { return }
        updateStatus?(row, .offline)
        print("ConversationsViewModel - sdk - onUserOffline")
    }
    
}
