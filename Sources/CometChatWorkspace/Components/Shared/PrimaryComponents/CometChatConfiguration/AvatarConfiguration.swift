//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit
import CometChatPro


public class AvatarConfiguration: CometChatConfiguration  {
    
    var cornerRadius: CGFloat = 20
    var borderWidth: CGFloat = 0
    var outerViewWidth: CGFloat = 0
    var outerViewSpacing: CGFloat = 0
    
    public func set(cornerRadius: CGFloat) -> AvatarConfiguration {
        self.cornerRadius = cornerRadius
        return self
    }
    
    public func set(borderWidth: CGFloat) -> AvatarConfiguration {
        self.borderWidth = borderWidth
        return self
    }
    
    public func set(outerViewWidth: CGFloat) -> AvatarConfiguration {
        self.outerViewWidth = outerViewWidth
        return self
    }
    
    public func set(outerViewSpacing: CGFloat) -> AvatarConfiguration {
        self.outerViewSpacing = outerViewSpacing
        return self
    }
    
}


