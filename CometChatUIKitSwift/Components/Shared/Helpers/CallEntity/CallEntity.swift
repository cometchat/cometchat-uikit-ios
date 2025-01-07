//
//  CallEntity.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 28/11/23.
//

#if canImport(CometChatCallsSDK)

import CometChatCallsSDK
import Foundation
import CometChatSDK

extension CallGroup {
    
    func getChatSDKGroup() -> Group {
        let group = Group(guid: self.guid, name: self.name, groupType: .public, password: "")
        group.icon = self.icon
        return group
    }
    
}

extension CallUser {
    
    func getChatSDKUser() -> User {
        let user = User(uid: self.uid, name: self.name)
        user.avatar = self.avatar
        return user
    }
    
}

#endif
