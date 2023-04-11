//
//  ConversationsStyle.swift
//
//
//  Created by Abdullah Ansari on 23/09/22.
//

import UIKit

public final class ConversationsStyle: BaseStyle  {

    private(set) var titleColor = CometChatTheme.palatte.accent
    private(set) var titleFont = CometChatTheme.typography.heading
    private(set) var largeTitleColor = CometChatTheme.palatte.accent
    private(set) var largeTitleFont = CometChatTheme.typography.largeHeading
    private(set) var backButtonTint = CometChatTheme.palatte.primary
    private(set) var searchIconTint = CometChatTheme.palatte.accent500
    private(set) var searchTextFont = CometChatTheme.typography.text1
    private(set) var searchTextColor = CometChatTheme.palatte.accent900
    private(set) var searchCornerRadius = CometChatCornerStyle(cornerRadius: 10.0)
    private(set) var searchCancelIconTint = CometChatTheme.palatte.accent500
    private(set) var searchPlaceholderFont = CometChatTheme.typography.text1
    private(set) var searchPlaceholderColor = CometChatTheme.palatte.accent600
    private(set) var onlineStatusColor = CometChatTheme.palatte.success
    private(set) var privateGroupIconBackgroundColor = #colorLiteral(red: 0, green: 0.7843137255, blue: 0.4352941176, alpha: 1)
    private(set) var protectedGroupIconBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.6470588235, blue: 0, alpha: 1)
    
    public override init() {}
    
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
    public func set(largeTitleColor: UIColor) -> Self {
        self.largeTitleColor = largeTitleColor
        return self
    }
    
    @discardableResult
    public func set(largeTitleFont: UIFont) -> Self {
        self.largeTitleFont = largeTitleFont
        return self
    }
    
    @discardableResult
    public func set(backButtonTint: UIColor) -> Self {
        self.backButtonTint = backButtonTint
        return self
    }
    
    @discardableResult
    public func set(searchIconTint: UIColor) -> Self {
        self.searchIconTint = searchIconTint
        return self
    }
    
    @discardableResult
    public func set(searchTextFont: UIFont) -> Self {
        self.searchTextFont = searchTextFont
        return self
    }
    
    @discardableResult
    public func set(searchTextColor: UIColor) -> Self {
        self.searchTextColor = searchTextColor
        return self
    }
    
    @discardableResult
    public func set(searchCancelIconTint: UIColor) -> Self {
        self.searchCancelIconTint = searchCancelIconTint
        return self
    }
    
    @discardableResult
    public func set(searchPlaceholderFont: UIFont) -> Self {
        self.searchPlaceholderFont = searchPlaceholderFont
        return self
    }
    
    @discardableResult
    public func set(searchPlaceholderColor: UIColor) -> Self {
        self.searchPlaceholderColor = searchPlaceholderColor
        return self
    }
    
    @discardableResult
    public func set(searchCornerRadius: CometChatCornerStyle) -> Self {
        self.searchCornerRadius = searchCornerRadius
        return self
    }
    
    @discardableResult
    public func set(privateGroupIconBackgroundColor: UIColor) -> Self {
        self.privateGroupIconBackgroundColor = privateGroupIconBackgroundColor
        return self
    }
    
    @discardableResult
    public func set(protectedGroupIconBackgroundColor: UIColor) -> Self {
        self.protectedGroupIconBackgroundColor = protectedGroupIconBackgroundColor
        return self
    }
    
}
