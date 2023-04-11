//
//  MessageListStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public final class MessageListStyle: BaseStyle {

    private(set) var loadingIconTint = CometChatTheme.palatte.accent600
    private(set) var emptyTextColor = CometChatTheme.palatte.accent400
    private(set) var emptyTextFont = CometChatTheme.typography.title1
    private(set) var errorTextFont = CometChatTheme.typography.title1
    private(set) var errorTextColor = CometChatTheme.palatte.accent400
    private(set) var nameTextFont = CometChatTheme.typography.subtitle2
    private(set) var nameTextColor = CometChatTheme.palatte.accent600
    private(set) var threadReplySeperatorColor = CometChatTheme.palatte.accent400
    private(set) var threadReplyTextFont = CometChatTheme.typography.title1
    private(set) var threadReplyTextColor = CometChatTheme.palatte.accent400
    private(set) var timestampTextFont = CometChatTheme.typography.caption2
    private(set) var timestampTextColor = CometChatTheme.palatte.accent500
    
    @discardableResult
    public func set(loadingIconTint: UIColor) -> Self {
        self.loadingIconTint = loadingIconTint
        return self
    }
    
    @discardableResult
    public func set(emptyTextColor: UIColor) -> Self {
        self.emptyTextColor = emptyTextColor
        return self
    }
    
    @discardableResult
    public func set(emptyTextFont: UIFont) -> Self {
        self.emptyTextFont = emptyTextFont
        return self
    }
    
    @discardableResult
    public func set(errorTextFont: UIFont) -> Self {
        self.errorTextFont = errorTextFont
        return self
    }
    
    @discardableResult
    public func set(errorTextColor: UIColor) -> Self {
        self.errorTextColor = errorTextColor
        return self
    }
    
    @discardableResult
    public func set(nameTextFont: UIFont) -> Self {
        self.nameTextFont = nameTextFont
        return self
    }
    
    @discardableResult
    public func set(nameTextColor: UIColor) -> Self {
        self.nameTextColor = nameTextColor
        return self
    }
    
    @discardableResult
    public func set(threadReplyTextFont: UIFont) -> Self {
        self.threadReplyTextFont = threadReplyTextFont
        return self
    }
    
    @discardableResult
    public func set(threadReplyTextColor: UIColor) -> Self {
        self.threadReplyTextColor = threadReplyTextColor
        return self
    }
    
    @discardableResult
    public func set(timestampTextFont: UIFont) -> Self {
        self.timestampTextFont = timestampTextFont
        return self
    }
    
    @discardableResult
    public func set(timestampTextColor: UIColor) -> Self {
        self.timestampTextColor = timestampTextColor
        return self
    }
    
    @discardableResult
    public func set(threadReplySeperatorColor: UIColor) -> Self {
        self.threadReplySeperatorColor = threadReplySeperatorColor
        return self
    }
    
    
}
