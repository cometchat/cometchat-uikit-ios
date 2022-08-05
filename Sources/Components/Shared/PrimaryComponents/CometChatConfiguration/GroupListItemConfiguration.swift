//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public class  GroupListItemConfiguration: CometChatConfiguration {
  
    var background: [CGColor]?
    var hideStatusIndicator: Bool = false
    var hideAvatar: Bool = false
    var inputData: InputData?
    var avatarConfiguration: AvatarConfiguration?
    var statusIndicatorConfiguration: StatusIndicatorConfiguration?

    
    public func set(background: [CGColor]) -> GroupListItemConfiguration {
        self.background = background
        return self
    }
    
    public func set(avatarConfiguration: AvatarConfiguration) -> GroupListItemConfiguration {
        self.avatarConfiguration = avatarConfiguration
        return self
    }
    
    public func set(statusIndicatorConfiguration: StatusIndicatorConfiguration) -> GroupListItemConfiguration {
        self.statusIndicatorConfiguration = statusIndicatorConfiguration
        return self
    }
    
    
    public func hide(statusIndicator: Bool) -> GroupListItemConfiguration {
        self.hideStatusIndicator = statusIndicator
        return self
    }
    
    public func hide(avatar: Bool) -> GroupListItemConfiguration {
        self.hideAvatar = avatar
        return self
    }
    
    public func set(inputData: InputData) -> GroupListItemConfiguration {
        self.inputData = inputData
        return self
    }
    
}

