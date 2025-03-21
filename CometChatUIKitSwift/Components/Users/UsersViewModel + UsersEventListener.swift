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
        user.status = .online
        update(user: user)
    }
    
    public func onUserOffline(user: User) {
        user.status = .offline
        update(user: user)
    }
}

extension UsersViewModel: CometChatUserEventListener {
    
    public func ccUserUnblocked(user: CometChatSDK.User) {
        // update user
        user.blockedByMe = false
        update(user: user)
    }
    
    public func ccUserBlocked(user: User) {
        // update user
        user.blockedByMe = true
        update(user: user)
    }
}
