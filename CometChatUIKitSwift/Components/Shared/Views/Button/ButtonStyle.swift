//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 08/03/23.
//

import Foundation
import UIKit

public class ButtonStyle : BaseStyle {
    
    private (set) var iconTint = CometChatTheme_v4.palatte.primary
    private (set) var textFont = CometChatTheme_v4.typography.subtitle2
    private (set) var textColor = CometChatTheme_v4.palatte.primary
    private (set) var iconBackground: UIColor?
    private (set) var iconCornerRadius: CGFloat?
    private (set) var iconBorder: CGFloat?
    
    @discardableResult
    public func set(iconTint: UIColor) -> Self {
        self.iconTint = iconTint
        return self
    }
    
    @discardableResult
    public func set(textFont: UIFont) -> Self {
        self.textFont = textFont
        return self
    }
    
    @discardableResult
    public func set(textColor: UIColor) -> Self {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    public func set(iconBackground: UIColor?) -> Self {
        self.iconBackground = iconBackground
        return self
    }
    
    @discardableResult
    public func set(iconCornerRadius: CGFloat?) -> Self {
        self.iconCornerRadius = iconCornerRadius
        return self
    }
    
    @discardableResult
    public func set(iconBorder: CGFloat?) -> Self {
        self.iconBorder = iconBorder
        return self
    }
}
