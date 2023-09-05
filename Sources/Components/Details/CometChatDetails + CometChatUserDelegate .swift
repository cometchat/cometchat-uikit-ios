//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 29/09/22.
//

import Foundation
import CometChatSDK

extension CometChatDetails : CometChatUserDelegate {
    
    public func onUserOnline(user: User) {
        update(user: user)
    }
    
    public func onUserOffline(user: User) {
        update(user: user)
    }
}
