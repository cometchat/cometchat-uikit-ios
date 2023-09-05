//
//  CometChatSettings.swift
 
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit
import CometChatSDK


public final class AvatarConfiguration {
    
    private(set) var setBackgroundColor: UIColor?
    private(set) var borderColor: UIColor?
    private(set) var cornerRadius: CometChatCornerStyle?
    private(set) var borderWidth: CGFloat = 0
    private(set) var outerViewSpacing: CGFloat = 0
    private(set) var outerViewWidth: CGFloat = 0
    private(set) var style: AvatarStyle?

    public init() {}
    
    @discardableResult
    public func set(cornerRadius: CometChatCornerStyle) -> Self {
        self.cornerRadius = cornerRadius
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        self.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    public func set(outerViewWidth: CGFloat) -> Self {
        self.outerViewWidth = outerViewWidth
        return self
    }
    
    @discardableResult
    public func set(outerViewSpacing: CGFloat) -> Self {
        self.outerViewSpacing = outerViewSpacing
        return self
    }
    
    @discardableResult
    public func set(backgroundColor: UIColor?) -> Self {
        self.setBackgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    public func set(style: AvatarStyle) -> Self {
        self.style = style
        return self
    }
    
}
