//
//  CometChatUserEvents.swift
 
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatSDK
import Foundation


@objc public protocol CometChatUserEventListener {
    
    @objc optional func ccUserBlocked(user: User)
    @objc optional func ccUserUnblocked(user: User)

    @available(*, deprecated, message: "Use `ccUserBlocked(user: User)` instead")
    @objc optional func onUserBlock(user: User)
    
    @available(*, deprecated, message: "Use `ccUserUnblocked(user: User)` instead")
    @objc optional func onUserUnblock(user: User)
    
}
