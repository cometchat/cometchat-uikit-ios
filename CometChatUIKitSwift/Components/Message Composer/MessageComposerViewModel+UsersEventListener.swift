//
//  MessageComposerViewModel+UserEventListener.swift
//  CometChatUIKitSwift
//
//  Created by nabhodipta on 28/06/24.
//

import Foundation
import CometChatSDK

extension MessageComposerViewModel: CometChatUserEventListener {
    
    public func onUserUnblock(user: CometChatSDK.User) {
        if user.uid == self.user?.uid{
            self.user?.blockedByMe = false
        }
    }
    
    public func onUserBlock(user: User) {
        
        if user.uid == self.user?.uid{
            self.user?.blockedByMe = true
        }
    }
}
