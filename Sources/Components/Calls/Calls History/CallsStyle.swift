//
//  GroupsStyle.swift
 
//
//  Created by Abdullah Ansari on 30/08/22.
//

import UIKit

public final class CallsStyle: BaseStyle {
    
    private(set) var titleColor = CometChatTheme.palatte.accent
    private(set) var titleFont = CometChatTheme.typography.heading
    private(set) var largeTitleColor = CometChatTheme.palatte.accent
    private(set) var largeTitleFont = CometChatTheme.typography.largeHeading
    private(set) var subtitleColor = CometChatTheme.palatte.accent500
    private(set) var subtitleFont = CometChatTheme.typography.subtitle1
    private(set) var backIconTint = CometChatTheme.palatte.primary
    private(set) var createGroupIconTint = CometChatTheme.palatte.primary
    private(set) var searchBorderColor = CometChatTheme.palatte.accent100
    private(set) var searchBackgroundColor = CometChatTheme.palatte.accent100
    private(set) var searchBorderRadius = CometChatCornerStyle(cornerRadius: 10.0)
    private(set) var searchBorderWidth = 0.0
    private(set) var searchTextColor = CometChatTheme.palatte.accent900
    private(set) var searchTextFont = CometChatTheme.typography.text1
    private(set) var searchPlaceholderColor = CometChatTheme.palatte.accent600
    private(set) var searchPlaceholderFont = CometChatTheme.typography.text1
    private(set) var searchIconTint = CometChatTheme.palatte.accent500
    private(set) var searchClearIconTint = CometChatTheme.palatte.accent500
    private(set) var searchCancelButtonFont = CometChatTheme.typography.text1
    private(set) var searchCancelButtonTint = CometChatTheme.palatte.primary
    private(set) var avatarStyle : AvatarStyle?
    private(set) var statusIndicatorStyle : StatusIndicatorStyle?
    private(set) var listItemStyle : ListItemStyle?
    private(set) var privateGroupIconBackgroundColor = #colorLiteral(red: 0, green: 0.7843137255, blue: 0.4352941176, alpha: 1)
    private(set) var protectedGroupIconBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.6470588235, blue: 0, alpha: 1)
    private(set) var missedCallTextColor = CometChatTheme.palatte.error
    private(set) var infoIconTint = CometChatTheme.palatte.primary
    private(set) var timeColor = CometChatTheme.palatte.accent400
    private(set) var timeFont = CometChatTheme.typography.subtitle1
   
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
    public func set(backIconTint: UIColor) -> Self {
        self.backIconTint = backIconTint
        return self
    }
    
    @discardableResult
    public func set(missedCallTextColor: UIColor) -> Self {
        self.missedCallTextColor = missedCallTextColor
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
    public func set(searchCancelButtonFont: UIFont) -> Self {
        self.searchCancelButtonFont = searchCancelButtonFont
        return self
    }
    
    @discardableResult
    public func set(searchCancelButtonTint: UIColor) -> Self {
        self.searchCancelButtonTint = searchCancelButtonTint
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> Self {
        self.statusIndicatorStyle = statusIndicatorStyle
        return self
    }
    
    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
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
    
    @discardableResult
    public func set(searchBorderWidth: CGFloat) -> Self {
        self.searchBorderWidth = searchBorderWidth
        return self
    }
    
    @discardableResult
    public func set(createGroupIconTint: UIColor) -> Self {
        self.createGroupIconTint = createGroupIconTint
        return self
    }
}
