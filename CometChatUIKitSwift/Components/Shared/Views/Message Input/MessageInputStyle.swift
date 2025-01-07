//
//  MessageInputStyle.swift
//  
//
//  Created by Ajay Verma on 16/12/22.
//

import UIKit
public class MessageInputStyle : BaseStyle {
    private(set) var textFont =  CometChatTheme_v4.typography.text1
    private(set) var textColor = CometChatTheme_v4.palatte.accent
    private(set) var placeHolderTextFont = CometChatTheme_v4.typography.text1
    private(set) var placeHolderTextColor = CometChatTheme_v4.palatte.accent500
    private(set) var dividerColor = CometChatTheme_v4.palatte.accent200
    private(set) var inputBackground = CometChatTheme_v4.palatte.accent100
    
    public override init() {
        super.init()
        self.background = .clear
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
    public func set(inputBackgroundColor: UIColor) -> Self {
        self.inputBackground = dividerColor
        return self
    }
    
}
