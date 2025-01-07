//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 05/02/23.
//

import Foundation
import CometChatSDK

extension UsersViewModel: CometChatUserDelegate {
    
    public func onUserOnline(user: User) {
        update(user: user)
    }
    
    public func onUserOffline(user: User) {
        update(user: user)
    }
}

extension UsersViewModel: CometChatUserEventListener {
    
    public func ccUserUnblocked(user: CometChatSDK.User) {
        // update user
        update(user: user)
        user.hasBlockedMe = false
    }
    
    public func ccUserBlocked(user: User) {
        // update user
        update(user: user)
        user.hasBlockedMe = true
    }
}
