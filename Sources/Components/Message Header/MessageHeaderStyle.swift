//
//  MessageHeaderStyle.swift
//
//
//  Created by Abdullah Ansari on 25/08/22.
//

import UIKit

public final class MessageHeaderStyle: BaseStyle {
    
    private(set) var backIconTint = CometChatTheme.palatte.primary
    private(set) var detailIconTint = CometChatTheme.palatte.primary
    private(set) var typingIndicatorTextColor = CometChatTheme.palatte.primary
    private(set) var typingIndicatorTextFont: UIFont = CometChatTheme.typography.subtitle2
    private(set) var onlineStatusColor = CometChatTheme.palatte.success
    private(set) var subtitleTextColor = CometChatTheme.palatte.primary
    private(set) var subtitleTextFont:UIFont = CometChatTheme.typography.subtitle2
    private(set) var borderRadius:CGFloat = 0.0
    private(set) var border:CGFloat = 0.0
    private(set) var privateGroupIconBackgroundColor = #colorLiteral(red: 0, green: 0.7843137255, blue: 0.4352941176, alpha: 1)
    private(set) var protectedGroupIconBackgroundColor = #colorLiteral(red: 0.968627451, green: 0.6470588235, blue: 0, alpha: 1)
    //MARK: Variable for internal use
      private(set) var subtitleTextColorForOffline = CometChatTheme.palatte.accent500
   
    @discardableResult
    public func set(backIconTint: UIColor) -> Self {
        self.backIconTint = backIconTint
        return self
    }
    
    @discardableResult
    public func set(detailIconTint: UIColor) -> Self {
        self.detailIconTint = detailIconTint
        return self
    }
    
    @discardableResult
    public func set(typingIndicatorTextColor: UIColor) -> Self {
        self.typingIndicatorTextColor = typingIndicatorTextColor
        return self
    }
    
    @discardableResult
    public func set(typingIndicatorTextFont: UIFont) -> Self {
        self.typingIndicatorTextFont = typingIndicatorTextFont
        return self
    }
        
    @discardableResult
    public func set(borderRadius: CGFloat) -> Self {
        self.borderRadius = borderRadius
        return self
    }
    
    @discardableResult
    public func set(border: CGFloat) -> Self {
        self.border = border
        return self
    }
    
    @discardableResult
    public func set(onlineStatusColor: UIColor) -> Self {
        self.onlineStatusColor = onlineStatusColor
        return self
    }
    
    @discardableResult
    public func set(subtitleTextColor: UIColor) -> Self {
        self.subtitleTextColor = subtitleTextColor
        return self
    }
    
    @discardableResult
    public func set(subtitleTextFont: UIFont) -> Self {
        self.subtitleTextFont = subtitleTextFont
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
    public func set(subtitleTextColorForOffline: UIColor) -> Self {
        self.subtitleTextColorForOffline = subtitleTextColorForOffline
        return self
    }
}
