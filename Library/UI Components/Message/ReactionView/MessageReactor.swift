//
//  MessageReactor.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 24/11/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import Foundation

class MessageReactor {
    
    var uid: String?
    var name: String?
    var avatar: String?
    
    
    init(uid: String ,name: String, avatar: String) {
        self.uid = uid
        self.name = name
        self.avatar = avatar
    }
}
