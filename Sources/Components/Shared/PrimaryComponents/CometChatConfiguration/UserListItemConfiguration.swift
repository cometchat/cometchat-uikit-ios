//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public class  UserListItemConfiguration: CometChatConfiguration {
  
    var background: [CGColor]?
    var hideStatusIndicator: Bool = false
    var hideAvatar: Bool = false
    var inputData: InputData?
  

    public func set(background: [CGColor]) -> UserListItemConfiguration {
        self.background = background
        return self
    }
    
    public func hide(statusIndicator: Bool) -> UserListItemConfiguration {
        self.hideStatusIndicator = statusIndicator
        return self
    }
    
    public func hide(avatar: Bool) -> UserListItemConfiguration {
        self.hideAvatar = avatar
        return self
    }
    
    public func set(inputData: InputData) -> UserListItemConfiguration {
        self.inputData = inputData
        return self
    }
    
}

