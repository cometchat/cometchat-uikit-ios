//
//  MessageHeaderViewModel.swift
//  
//
//  Created by Abdullah Ansari on 05/02/23.
//

import Foundation
import CometChatSDK

//MARK: Adding User Status Delegate Methods
extension MessageHeaderViewModel: CometChatUserDelegate {
    
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

extension MessageHeaderViewModel: CometChatUserEventListener {
    
    public func onUserBlock(user: CometChatSDK.User) {
        
        print("MessageHeaderViewModel - onUserBlock")
    }
    
    public func onUserUnblock(user: CometChatSDK.User) {
        
        print("MessageHeaderViewModel - onUserUnblock")
    }

}
