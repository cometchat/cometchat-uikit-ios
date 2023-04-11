//
//  File.swift
//  
//
//  Created by Ajay Verma on 13/03/23.
//


import Foundation
import CometChatPro

//MARK: Adding User Status Delegate Methods
extension CallDetailsViewModel: CometChatUserDelegate {
    
    public func onUserOnline(user: User) {
        if self.user?.uid == user.uid {
            updateUserStatus?(true)
        }
    }
    
    public func onUserOffline(user: User) {
        if self.user?.uid == user.uid {
            updateUserStatus?(false)
        }
    }
}

extension CallDetailsViewModel: CometChatUserEventListener {
    
    public func onUserBlock(user: CometChatPro.User) {
        
        print("MessageHeaderViewModel - onUserBlock")
    }
    
    public func onUserUnblock(user: CometChatPro.User) {
        
        print("MessageHeaderViewModel - onUserUnblock")
    }

}
