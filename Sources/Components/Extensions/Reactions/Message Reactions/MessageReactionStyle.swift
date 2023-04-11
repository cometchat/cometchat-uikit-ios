//
//  MessageReactionStyle.swift
//  
//
//  Created by Abdullah Ansari on 24/09/22.
//

import UIKit

public final class MessageReactionStyle: BaseStyle {

    private(set) var addReactionIconTint = CometChatTheme.palatte.accent700
    private(set) var addReactionIconbackground = CometChatTheme.palatte.accent100
    private(set) var textColor = CometChatTheme.palatte.accent700
    private(set) var textFont = CometChatTheme.typography.caption2
    
    @discardableResult
    public func set(addReactionIconTint: UIColor) -> Self {
        self.addReactionIconbackground = addReactionIconTint
        return self
    }
    
    @discardableResult
    public func set(addReactionIconbackground: UIColor) -> Self {
        self.addReactionIconbackground = addReactionIconbackground
        return self
    }
    
    @discardableResult
    public func set(textColor: UIColor) -> Self {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    public func set(textFont: UIFont) -> Self {
        self.textFont = textFont
        return self
    }
}
