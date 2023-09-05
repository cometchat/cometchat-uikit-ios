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
        let onlineUser = user
        onlineUser.status = .online
        update(user: onlineUser)
        
        print("UsersViewModel - event - onUserOnline")
    }
    
    public func onUserOffline(user: User) {
        update(user: user)
        
        print("UsersViewModel - event - onUserOffline")
    }
}

extension UsersViewModel: CometChatUserEventListener {
    
    public func onUserUnblock(user: CometChatSDK.User) {
        // update user
        update(user: user)
        user.hasBlockedMe = false
        print("UsersViewModel - event - onUserUnblock")
    }
    
    public func onUserBlock(user: User) {
        // update user
        update(user: user)
        user.hasBlockedMe = true
        print("UsersViewModel - event - onUserBlock")
    }
}
