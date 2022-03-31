//
//  InputData.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 22/03/22.
//

import Foundation
import CometChatPro

public struct InputData {
    
    var id: String
    var thumbnail: String?
    var userStatus: CometChat.UserStatus?
    var groupType: CometChatPro.CometChat.groupType?
    var title: String?
    var subTitle: String?
    var time: String?
    var unreadCount: Int?
    
    
    init(id: String?, thumbnail: String?, userStatus: CometChat.UserStatus?, title: String?, subTitle: String?) {
        self.id = id ?? ""
        self.thumbnail = thumbnail
        self.userStatus = userStatus
        self.title = title
        self.subTitle = subTitle
    }
    
    init(id: String?, thumbnail: String?, groupType: CometChatPro.CometChat.groupType?, title: String?, subTitle: String?) {
        self.id = id ?? ""
        self.thumbnail = thumbnail
        self.groupType = groupType
        self.title = title
        self.subTitle = subTitle
    }
    
    init(id: String?, thumbnail: String?, userStatus: CometChat.UserStatus?, groupType: CometChatPro.CometChat.groupType?, title: String?, subTitle: String?,time: String, unreadCount: Int? ) {
        self.id = id ?? ""
        self.thumbnail = thumbnail
        self.groupType = groupType
        self.title = title
        self.subTitle = subTitle
        self.userStatus = userStatus
        self.time = time
        self.unreadCount = unreadCount
    }
}
