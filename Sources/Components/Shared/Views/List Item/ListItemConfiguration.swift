//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 15/11/22.
//

import Foundation
import UIKit


public class  ListItemConfiguration: CometChatConfiguration {

    private(set) var avatarConfiguration: AvatarConfiguration?
    private(set) var statusIndicatorConfiguration: StatusIndicatorConfiguration?
    private(set) var tail: UIView?
    private(set) var subtitle: UIView?
    private(set) var style: ListItemStyle?

    public func set(avatarConfiguration: AvatarConfiguration?) -> Self {
        self.avatarConfiguration = avatarConfiguration
        return self
    }
    
    public func set(statusIndicatorConfiguration: StatusIndicatorConfiguration) -> Self {
        self.statusIndicatorConfiguration = statusIndicatorConfiguration
        return self
    }
    
    public func set(tail: UIView) -> Self {
        self.tail = tail
        return self
    }
    
    public func set(subtitle: UIView) -> Self {
        self.subtitle = subtitle
        return self
    }
    
    public func set(style: ListItemStyle) -> Self {
        self.style = style
        return self
    }
}

