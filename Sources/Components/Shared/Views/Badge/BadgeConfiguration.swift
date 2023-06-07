//
//  CometChatSettings.swift
 
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public class BadgeConfiguration: CometChatConfiguration {
  
    private(set) var cornerRadius: CGFloat = 8
    private(set) var style: BadgeStyle?
    
    @discardableResult
    public func set(cornerRadius: CGFloat) -> Self {
        self.cornerRadius = cornerRadius
        return self
    }
    
    @discardableResult
    public func set(style: BadgeStyle) -> Self {
        self.style = style
        return self
    }
}


