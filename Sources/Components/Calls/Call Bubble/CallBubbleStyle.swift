//
//  CollaborativeDocumentStyle.swift
 
//
//  Created by Abdullah Ansari on 19/05/22.
//

import Foundation
import UIKit

public final class CallBubbleStyle: BaseStyle {
    
    private(set) var titleFont = CometChatTheme.typography.text2
    private(set) var titleColor = CometChatTheme.palatte.accent900
    private(set) var subtitleFont = CometChatTheme.typography.subtitle2
    private(set) var subtitleColor = CometChatTheme.palatte.accent700
    private(set) var iconTint = CometChatTheme.palatte.accent700
    private(set) var buttonTextFont = CometChatTheme.typography.text1
    private(set) var buttonTextColor = CometChatTheme.palatte.primary
    private(set) var buttonBackground: UIColor = CometChatTheme.palatte.primary
    private(set) var buttonCornerRadius: CGFloat = 16
    
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
    
    @discardableResult
    public func set(buttonTextFont: UIFont) -> Self {
        self.buttonTextFont = buttonTextFont
        return self
    }
    
    @discardableResult
    public func set(buttonTextColor: UIColor) -> Self {
        self.buttonTextColor = buttonTextColor
        return self
    }
    
    @discardableResult
    public func set(buttonBackground: UIColor) -> Self {
        self.buttonBackground = buttonBackground
        return self
    }
    
    @discardableResult
    public func set(buttonCornerRadius: CGFloat) -> Self {
        self.buttonCornerRadius = buttonCornerRadius
        return self
    }
}


