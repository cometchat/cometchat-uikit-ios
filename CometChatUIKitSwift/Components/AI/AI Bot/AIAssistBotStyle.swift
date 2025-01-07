//
//  File.swift
//  
//
//  Created by SuryanshBisen on 06/11/23.
//

import Foundation
import UIKit

public class AIAssistBotStyle {
    
    private(set) var buttonTextColor: UIColor?
    private(set) var buttonTextFont: UIFont?
    private(set) var buttonBorder: CGFloat?
    private(set) var buttonBorderRadius: CometChatCornerStyle?
    private(set) var buttonBackground: UIColor?
    private(set) var buttonBorderColor: UIColor?
    
    private(set) var closeIconTint: UIColor?
    private(set) var sendIconTint: UIColor?
    private(set) var titleColor: UIColor?
    private(set) var titleFont: UIFont?
    private(set) var subtitleColor: UIColor?
    private(set) var subtitleFont: UIFont?
    
    public init() { }
    
    @discardableResult
    public func set(buttonTextColor: UIColor) -> Self {
        self.buttonTextColor = buttonTextColor
        return self
    }
    
    @discardableResult
    public func set(buttonTextFont: UIFont) -> Self {
        self.buttonTextFont = buttonTextFont
        return self
    }
    
    @discardableResult
    public func set(buttonBorder: CGFloat) -> Self {
        self.buttonBorder = buttonBorder
        return self
    }
    
    @discardableResult
    public func set(buttonBorderRadius: CometChatCornerStyle) -> Self {
        self.buttonBorderRadius = buttonBorderRadius
        return self
    }
    
    @discardableResult
    public func set(buttonBackground: UIColor) -> Self {
        self.buttonBackground = buttonBackground
        return self
    }
    
    @discardableResult
    public func set(buttonBorderColor: UIColor) -> Self {
        self.buttonBorderColor = buttonBorderColor
        return self
    }
    
    @discardableResult
    public func set(closeIconTint: UIColor) -> Self {
        self.closeIconTint = closeIconTint
        return self
    }
    
    
    @discardableResult
    public func set(sendIconTint: UIColor) -> Self {
        self.sendIconTint = sendIconTint
        return self
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
    public func set(subtitleFont: UIFont) -> Self {
        self.subtitleFont = subtitleFont
        return self
    }
    
    @discardableResult
    public func set(subtitleColor: UIColor) -> Self {
        self.subtitleColor = subtitleColor
        return self
    }

}
