//
//  JoinProtectedGroupStyle.swift
//  
//
//  Created by Abdullah Ansari on 01/09/22.
//

import UIKit

public final class JoinProtectedGroupStyle: BaseStyle {
    
    private(set) var titleTextFont = CometChatTheme.typography.title2
    private(set) var titleTextColor = CometChatTheme.palatte.accent
    private(set) var errorTextColor = CometChatTheme.palatte.accent
    private(set) var errorTextFont = CometChatTheme.typography.text1
    private(set) var passwordTextColor = CometChatTheme.palatte.accent
    private(set) var passwordTextFont = CometChatTheme.typography.text1
    private(set) var passwordPlaceholderColor = CometChatTheme.palatte.accent500
    private(set) var passwordPlaceholderFont = CometChatTheme.typography.text1
    private(set) var passwordInputBackground = CometChatTheme.palatte.background
    private(set) var passwordInputCornerRadius = 10.0
    private(set) var joinButtonTextFont = CometChatTheme.typography.title2
    private(set) var joinButtonTextColor = CometChatTheme.palatte.primary
    private(set) var cancelButtonTextColor = CometChatTheme.palatte.primary
    private(set) var cancelButtonTextFont = CometChatTheme.typography.text1
    private(set) var captionTextColor = CometChatTheme.palatte.accent600
    private(set) var captionTextFont = CometChatTheme.typography.subtitle2
    
    override public var background: UIColor {
        get {
            return CometChatTheme.palatte.secondary
        }
        set {}
    }
    
    @discardableResult
    public func set(titleTextFont: UIFont) -> Self {
        self.titleTextFont = titleTextFont
        return self
    }
    
    @discardableResult
    public func set(titleTextColor: UIColor) -> Self {
        self.titleTextColor = titleTextColor
        return self
    }
    
    @discardableResult
    public func set(errorTextColor: UIColor) -> Self {
        self.errorTextColor = errorTextColor
        return self
    }
    
    @discardableResult
    public func set(errorTextFont: UIFont) -> Self {
        self.errorTextFont = errorTextFont
        return self
    }
    
    @discardableResult
    public func set(passwordTextColor: UIColor) -> Self {
        self.passwordTextColor = passwordTextColor
        return self
    }
    
    @discardableResult
    public func set(passwordTextFont: UIFont) -> Self {
        self.passwordTextFont = passwordTextFont
        return self
    }
    
    
    @discardableResult
    public func set(passwordPlaceholderColor: UIColor) -> Self {
        self.passwordPlaceholderColor = passwordPlaceholderColor
        return self
    }
    
    @discardableResult
    public func set(passwordPlaceholderFont: UIFont) -> Self {
        self.passwordPlaceholderFont = passwordPlaceholderFont
        return self
    }
    
    @discardableResult
    public func set(passwordInputBackground: UIColor) -> Self {
        self.passwordInputBackground = passwordInputBackground
        return self
    }
    
    @discardableResult
    public func set(passwordInputCornerRadius: CGFloat) -> Self {
        self.passwordInputCornerRadius = passwordInputCornerRadius
        return self
    }
    
    @discardableResult
    public func set(joinButtonTextFont: UIFont) -> Self {
        self.joinButtonTextFont = joinButtonTextFont
        return self
    }
    
    @discardableResult
    public func set(joinButtonTextColor: UIColor) -> Self {
        self.joinButtonTextColor = joinButtonTextColor
        return self
    }
    
    @discardableResult
    public func set(cancelButtonTextFont: UIFont) -> Self {
        self.cancelButtonTextFont = cancelButtonTextFont
        return self
    }
    
    @discardableResult
    public func set(cancelButtonTextColor: UIColor) -> Self {
        self.cancelButtonTextColor = cancelButtonTextColor
        return self
    }
    
    @discardableResult
    public func set(captionTextFont: UIFont) -> Self {
        self.captionTextFont = captionTextFont
        return self
    }
    
    @discardableResult
    public func set(captionTextColor: UIColor) -> Self {
        self.captionTextColor = captionTextColor
        return self
    }
    
}
