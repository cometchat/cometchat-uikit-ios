//
//  MessageInputStyle.swift
//  
//
//  Created by Ajay Verma on 16/12/22.
//

import UIKit
public class MessageInputStyle : BaseStyle {
    private(set) var textFont =  CometChatTheme.typography.text1
    private(set) var textColor = CometChatTheme.palatte.accent
    private(set) var placeHolderTextFont = CometChatTheme.typography.text1
    private(set) var placeHolderTextColor = CometChatTheme.palatte.accent500
    private(set) var dividerColor = CometChatTheme.palatte.accent200
    private(set) var topViewBackgroundColor = CometChatTheme.palatte.accent100
    private(set) var bottomViewBackgroundColor = CometChatTheme.palatte.accent100
    
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
    
    @discardableResult
    public func set(placeHolderTextFont: UIFont) -> Self {
        self.placeHolderTextFont = placeHolderTextFont
        return self
    }
    
    @discardableResult
    public func set(placeHolderTextColor: UIColor) -> Self {
        self.placeHolderTextColor = placeHolderTextColor
        return self
    }
    
    @discardableResult
    public func set(dividerColor: UIColor) -> Self {
        self.dividerColor = dividerColor
        return self
    }
    
    @discardableResult
    public func set(topViewBackgroundColor: UIColor) -> Self {
        self.topViewBackgroundColor = topViewBackgroundColor
        return self
    }
    
    @discardableResult
    public func set(bottomViewBackgroundColor: UIColor) -> Self {
        self.bottomViewBackgroundColor = bottomViewBackgroundColor
        return self
    }
    
}
