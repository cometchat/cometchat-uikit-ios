//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public class  DataItemConfiguration: CometChatConfiguration {
  
    var background: [CGColor]?
    var inputData: InputData?
    var avatarConfiguration: AvatarConfiguration?
    var statusIndicatorConfiguration: StatusIndicatorConfiguration?

    
    public func set(background: [CGColor]) -> DataItemConfiguration {
        self.background = background
        return self
    }
    
    public func set(avatarConfiguration: AvatarConfiguration) -> DataItemConfiguration {
        self.avatarConfiguration = avatarConfiguration
        return self
    }
    
    public func set(statusIndicatorConfiguration: StatusIndicatorConfiguration) -> DataItemConfiguration {
        self.statusIndicatorConfiguration = statusIndicatorConfiguration
        return self
    }
    
    
    public func set(inputData: InputData) -> DataItemConfiguration {
        self.inputData = inputData
        return self
    }
    
}

