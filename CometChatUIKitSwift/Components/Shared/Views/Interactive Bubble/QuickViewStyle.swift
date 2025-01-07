//
//  QuickViewStyle.swift
//  
//
//  Created by Abhishek Saralaya on 20/10/23.
//

import Foundation
import UIKit

class QuickViewStyle:BaseStyle {
    public var titleFont: UIFont = CometChatTheme_v4.typography.title2
    public var titleColor: UIColor = CometChatTheme_v4.palatte.primary
    public var subtitleFont: UIFont = CometChatTheme_v4.typography.subtitle2
    public var subtitleColor: UIColor = CometChatTheme_v4.palatte.accent900
    public var closeIconTint: UIColor = CometChatTheme_v4.palatte.accent900
    public var leadingBarTint: UIColor = CometChatTheme_v4.palatte.primary
    public var leadingBarWidth: CGFloat = 10
    
    
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    @discardableResult
    public func set(subtitleFont: UIFont) -> Self {
        self.subtitleFont = subtitleFont
        return self
    }
    @discardableResult
    public func set(subtitleColor: UIColor) -> Self {
        self.subtitleColor = subtitleColor
        return self
    }
    @discardableResult
    public func set(closeIconTint: UIColor) -> Self {
        self.closeIconTint = closeIconTint
        return self
    }
    @discardableResult
    public func set(leadingBarTint: UIColor) -> Self {
        self.leadingBarTint = leadingBarTint
        return self
    }
    @discardableResult
    public func set(leadingBarWidth: CGFloat) -> Self {
        self.leadingBarWidth = leadingBarWidth
        return self
    }

}
