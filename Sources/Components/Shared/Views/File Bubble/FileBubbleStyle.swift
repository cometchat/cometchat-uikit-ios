//
//  FileBubbleStyle.swift
 
//
//  Created by Abdullah Ansari on 23/05/22.
//

import Foundation
import UIKit

public final class FileBubbleStyle: BaseStyle {
    
    private (set) var titleColor = CometChatTheme.palatte.accent900
    private (set) var titleFont = CometChatTheme.typography.text2
    private (set) var subtitleColor = CometChatTheme.palatte.accent700
    private (set) var subtitleFont = CometChatTheme.typography.subtitle2
    private (set) var iconTint = CometChatTheme.palatte.primary
    override var background: UIColor {
        get {
            return CometChatTheme.palatte.secondary
        }
        set {
            super.background = newValue
        }
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    @discardableResult
    public func set(subtitleColor: UIColor) -> Self {
        self.subtitleColor = subtitleColor
        return self
    }
    
    @discardableResult
    public func set(subtitleFont: UIFont) -> Self {
        self.subtitleFont = subtitleFont
        return self
    }
    
    @discardableResult
    public func set(iconTint: UIColor) -> Self {
        self.iconTint = iconTint
        return self
    }
      
}
