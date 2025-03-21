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
        if self.user?.uid == user.uid && self.user?.blockedByMe == false {
            self.user = user
            updateUserStatus?(true)
            onUpdate?()
        }
    }
    
    public func onUserOffline(user: User) {
        if self.user?.uid == user.uid  && self.user?.blockedByMe == false {
            self.user = user
            updateUserStatus?(false)
            onUpdate?()
        }
    }
}

extension MessageHeaderViewModel: CometChatUserEventListener {
    
    public func ccUserBlocked(user: CometChatSDK.User) {
        
        if user.uid == self.user?.uid{
            DispatchQueue.main.async {
                self.user = user
                self.hideUserStatus?()
                self.onUpdate?()
            }
            
            
        }
    }
    
    public func ccUserUnblocked(user: CometChatSDK.User) {
        
        if user.uid == self.user?.uid{
            DispatchQueue.main.async {
                self.user = user
                self.unHideUserStatus?()
                if user.status == .online {
                    self.updateUserStatus?(true)
                }
                self.onUpdate?()
            }
        }
    }

}
