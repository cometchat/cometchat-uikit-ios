//
//  GroupMembersStyle.swift
 
//
//  Created by Pushpsen Airekar on 22/11/22.
//
import Foundation
import UIKit
import CometChatSDK

public final class GroupMembersStyle: BaseStyle {
    
    private(set) var titleColor = CometChatTheme.palatte.accent
    private(set) var titleFont = CometChatTheme.typography.heading
    private(set) var largeTitleColor = CometChatTheme.palatte.accent
    private(set) var largeTitleFont = CometChatTheme.typography.largeHeading
    private(set) var backIconTint = CometChatTheme.palatte.primary
    private(set) var searchBorderColor = CometChatTheme.palatte.accent100
    private(set) var searchBackgroundColor = CometChatTheme.palatte.accent100
    private(set) var searchBorderRadius = CometChatCornerStyle(cornerRadius: 12.0)
    private(set) var searchTextColor = CometChatTheme.palatte.accent900
    private(set) var searchTextFont = CometChatTheme.typography.text1
    private(set) var searchPlaceholderColor = CometChatTheme.palatte.accent600
    private(set) var searchPlaceholderFont = CometChatTheme.typography.text1
    private(set) var searchIconTint = CometChatTheme.palatte.accent500
    private(set) var searchClearIconTint = CometChatTheme.palatte.accent500
    private(set) var searchCancelButtonFont = CometChatTheme.typography.text1
    private(set) var searchCancelButtonTint = CometChatTheme.palatte.primary
    private(set) var searchBorderWidth = 0.0
    private(set) var onlineStatusColor = CometChatTheme.palatte.success
    
    //override
    override public var background: UIColor {
        get {
            return CometChatTheme.palatte.secondary
        }
        set {}
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
    public func set(largeTitleFont: UIFont) -> Self {
        self.largeTitleFont = largeTitleFont
        return self
    }
    
    @discardableResult
    public func set(backIconTint: UIColor) -> Self {
        self.backIconTint = backIconTint
        return self
    }
    
    @discardableResult
    public func set(searchBorderColor: UIColor) -> Self {
        self.searchBorderColor = searchBorderColor
        return self
    }
    
    @discardableResult
    public func set(searchBackgroundColor: UIColor) -> Self {
        self.searchBackgroundColor = searchBackgroundColor
        return self
    }
    
    @discardableResult
    public func set(searchBorderRadius: CometChatCornerStyle) -> Self {
        self.searchBorderRadius = searchBorderRadius
        return self
    }
    
    @discardableResult
    public func set(searchTextColor: UIColor) -> Self {
        self.searchTextColor = searchTextColor
        return self
    }
    
    @discardableResult
    public func set(searchTextFont: UIFont) -> Self {
        self.searchTextFont = searchTextFont
        return self
    }
    
    @discardableResult
    public func set(searchPlaceholderColor: UIColor) -> Self {
        self.searchPlaceholderColor = searchPlaceholderColor
        return self
    }
    
    @discardableResult
    public func set(searchPlaceholderFont: UIFont) -> Self {
        self.searchPlaceholderFont = searchPlaceholderFont
        return self
    }
    
    @discardableResult
    public func set(searchIconTint: UIColor) -> Self {
        self.searchIconTint = searchIconTint
        return self
    }
    
    @discardableResult
    public func set(searchClearIconTint: UIColor) -> Self {
        self.searchClearIconTint = searchClearIconTint
        return self
    }
    
    @discardableResult
    public func set(searchBorderWidth: CGFloat) -> Self {
        self.searchBorderWidth = searchBorderWidth
        return self
    }
    
    @discardableResult
    public func set(searchCancelButtonFont: UIFont) -> Self {
        self.searchCancelButtonFont = searchCancelButtonFont
        return self
    }
    
    @discardableResult
    public func set(searchCancelButtonTint: UIColor) -> Self {
        self.searchCancelButtonTint = searchCancelButtonTint
        return self
    }
}

