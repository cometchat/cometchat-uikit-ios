//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 17/07/22.
//

import Foundation
import CometChatPro


extension CometChatConversationList : CometChatUserDelegate {

    public func onUserOnline(user: User) {
        updateUserStatus(user: user, userStatus: .online)
    }

    public func onUserOffline(user: User) {
        updateUserStatus(user: user, userStatus: .online)
    }
    
    private func updateUserStatus(user: User, userStatus: CometChat.UserStatus) {
        if conversationType == .user || conversationType == .none {
            if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == user.uid}) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let conversationListItem = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem {
                        conversationListItem.set(statusIndicator: userStatus)
                        conversationListItem.reloadInputViews()
                    }
                }
            }
        }
    }

}
