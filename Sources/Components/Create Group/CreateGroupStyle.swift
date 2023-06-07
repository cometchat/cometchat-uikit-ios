//
//  CreateGroupStyle.swift
 
//
//  Created by Abdullah Ansari on 01/09/22.

import UIKit

public final class CreateGroupStyle: BaseStyle {
    
    private(set) var namePlaceholderTextColor = CometChatTheme.palatte.accent500
    private(set) var namePlaceholderTextFont = CometChatTheme.typography.text1
    private(set) var nameInputTextFont = CometChatTheme.typography.text1
    private(set) var nameInputTextColor = CometChatTheme.palatte.accent
    private(set) var passwordPlaceholderColor = CometChatTheme.palatte.accent500
    private(set) var passwordPlaceholderFont = CometChatTheme.typography.text1
    private(set) var passwordInputTextColor = CometChatTheme.palatte.accent
    private(set) var passwordInputTextFont = CometChatTheme.typography.text1
    private(set) var titleTextColor = CometChatTheme.palatte.accent
    private(set) var titleTextFont = CometChatTheme.typography.heading
    private(set) var tabColor = CometChatTheme.palatte.accent500
    private(set) var tabTextFont = CometChatTheme.typography.caption1
    private(set) var tabTextColor = CometChatTheme.palatte.accent
    private(set) var selectedTabColor = CometChatTheme.palatte.background
    private(set) var selectedTabTextFont = CometChatTheme.typography.caption1
    private(set) var selectedTabTextColor = CometChatTheme.palatte.accent
    private(set) var inputBackgroundColor = CometChatTheme.palatte.background
    private(set) var inputCornerRadius: CGFloat = 10.0
    private(set) var createButtonTextFont = CometChatTheme.typography.title2
    private(set) var createButtonTextColor = CometChatTheme.palatte.primary
    private(set) var cancelButtonTextFont = CometChatTheme.typography.text1
    private(set) var cancelButtonTextColor = CometChatTheme.palatte.primary
    
    override public var background: UIColor {
        get {
            return CometChatTheme.palatte.secondary
        }
        set {}
    }
    
    @discardableResult
    public func set(namePlaceholderTextFont: UIFont) -> Self {
        self.namePlaceholderTextFont = namePlaceholderTextFont
        return self
    }
    
    @discardableResult
    public func set(namePlaceholderTextColor: UIColor) -> Self {
        self.namePlaceholderTextColor = namePlaceholderTextColor
        return self
    }
    
    @discardableResult
    public func set(nameInputTextFont: UIFont) -> Self {
        self.nameInputTextFont = nameInputTextFont
        return self
    }
    
    @discardableResult
    public func set(nameInputTextColor: UIColor) -> Self {
        self.nameInputTextColor = nameInputTextColor
        return self
    }
    
    @discardableResult
    public func set(passwordInputTextColor: UIColor) -> Self {
        self.passwordInputTextColor = passwordInputTextColor
        return self
    }
    
    @discardableResult
    public func set(passwordInputTextFont: UIFont) -> Self {
        self.passwordInputTextFont = passwordInputTextFont
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
    public func set(titleTextColor: UIColor) -> Self {
        self.titleTextColor = titleTextColor
        return self
    }
    
    @discardableResult
    public func set(titleTextFont: UIFont) -> Self {
        self.titleTextFont = titleTextFont
        return self
    }
    
    
    @discardableResult
    public func set(tabColor: UIColor) -> Self {
        self.tabColor = tabColor
        return self
    }
    
    @discardableResult
    public func set(tabTextFont: UIFont) -> Self {
        self.tabTextFont = tabTextFont
        return self
    }
    
    @discardableResult
    public func set(tabTextColor: UIColor) -> Self {
        self.tabTextColor = tabTextColor
        return self
    }
    
    @discardableResult
    public func set(selectedTabTextFont: UIFont) -> Self {
        self.selectedTabTextFont = selectedTabTextFont
        return self
    }
    
    @discardableResult
    public func set(selectedTabTextColor: UIColor) -> Self {
        self.selectedTabTextColor = selectedTabTextColor
        return self
    }
    
    @discardableResult
    public func set(inputBackgroundColor: UIColor) -> Self {
        self.inputBackgroundColor = inputBackgroundColor
        return self
    }
    
    @discardableResult
    public func set(inputCornerRadius: CGFloat) -> Self {
        self.inputCornerRadius = inputCornerRadius
        return self
    }
    
    @discardableResult
    public func set(createButtonTextColor: UIColor) -> Self {
        self.createButtonTextColor = createButtonTextColor
        return self
    }
    
    @discardableResult
    public func set(createButtonTextFont: UIFont) -> Self {
        self.createButtonTextFont = createButtonTextFont
        return self
    }
    
    @discardableResult
    public func set(cancelButtonTextColor: UIColor) -> Self {
        self.cancelButtonTextColor = cancelButtonTextColor
        return self
    }
    
    @discardableResult
    public func set(cancelButtonTextFont: UIFont) -> Self {
        self.cancelButtonTextFont = cancelButtonTextFont
        return self
    }
}
