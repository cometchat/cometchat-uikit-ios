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
    
}
