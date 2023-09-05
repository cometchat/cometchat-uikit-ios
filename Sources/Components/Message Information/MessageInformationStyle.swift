///  MessageInformationStyle.swift
///  Created by Ajay Verma on 06/07/23.

import Foundation
import UIKit

public final class MessageInformationStyle: BaseStyle {
    var width = 0.0
    var height = 0.0
    var titleTextColor = CometChatTheme.palatte.accent
    var titleTextFont = CometChatTheme.typography.heading
    var sendIconTint = CometChatTheme.palatte.accent500
    var readIconTint = CometChatTheme.palatte.primary
    var deliveredIconTint = CometChatTheme.palatte.accent500
    var subtitleTextColor = CometChatTheme.palatte.accent600
    var subtitleTextFont = CometChatTheme.typography.subtitle1
    var dividerTint = CometChatTheme.palatte.accent100
    
    override public var cornerRadius: CometChatCornerStyle {
        get {
            return CometChatCornerStyle(cornerRadius: 10)
        }
        set {}
    }
    
    @discardableResult
    public func set(titleTextColor: UIColor) -> Self {
        self.titleTextColor = titleTextColor
        return self
    }
    
    @discardableResult
    public func set(subtitleTextColor: UIColor) -> Self {
        self.subtitleTextColor = subtitleTextColor
        return self
    }
    
    @discardableResult
    public func set(titleTextFont: UIFont) -> Self {
        self.titleTextFont = titleTextFont
        return self
    }
    
    @discardableResult
    public func set(subtitleTextFont: UIFont) -> Self {
        self.subtitleTextFont = subtitleTextFont
        return self
    }
    
    @discardableResult
    public func set(sendIconTint: UIColor) -> Self {
        self.sendIconTint = sendIconTint
        return self
    }
    
    @discardableResult
    public func set(deliveredIconTint: UIColor) -> Self {
        self.deliveredIconTint = deliveredIconTint
        return self
    }
    
    @discardableResult
    public func set(readIconTint: UIColor) -> Self {
        self.readIconTint = readIconTint
        return self
    }
    
    @discardableResult
    public func set(dividerTint: UIColor) -> Self {
        self.dividerTint = dividerTint
        return self
    }
    
    @discardableResult
    public func set(width: CGFloat) -> Self {
        self.width = width
        return self
    }
    
    @discardableResult
    public func set(height: CGFloat) -> Self {
        self.height = height
        return self
    }
    
}
