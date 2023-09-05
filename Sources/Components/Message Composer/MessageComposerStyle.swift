//
//  MessageComposerStyle.swift
//  
//
//  Created by Abdullah Ansari on 07/09/22.
//

import UIKit

public final class MessageComposerStyle: BaseStyle {
    
    private(set) var inputBackground = CometChatTheme.palatte.accent100
    private(set) var textColor = CometChatTheme.palatte.accent
    private(set) var textFont = CometChatTheme.typography.text1
    private(set) var attachmentIconTint = CometChatTheme.palatte.accent700
    private(set) var sendIconTint = CometChatTheme.palatte.primary
    private(set) var dividerTint = CometChatTheme.palatte.accent100
    private(set) var placeHolderTextColor = CometChatTheme.palatte.accent500
    private(set) var placeHolderTextFont = CometChatTheme.typography.text1
    private(set) var inputBorderWidth = 0.0
    private(set) var inputBorderColor = UIColor.clear
    private(set) var actionSheetTitleColor = CometChatTheme.palatte.accent900
    private(set) var actionSheetTitleFont = CometChatTheme.typography.title2
    private(set) var actionSheetLayoutModelIconTint = CometChatTheme.palatte.primary
    private(set) var actionSheetCancelButtonIconTint = CometChatTheme.palatte.primary
    private(set) var actionSheetCancelButtonIconFont = CometChatTheme.typography.text1
    private(set) var inputCornerRadius: CometChatCornerStyle = CometChatCornerStyle(cornerRadius: 18)
  
    @discardableResult
    public func set(inputBackground: UIColor) -> Self {
        self.inputBackground = inputBackground
        return self
    }
    
    @discardableResult
    public func set(inputCornerRadius: CometChatCornerStyle) -> Self {
        self.inputCornerRadius = inputCornerRadius
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
        
    @discardableResult
    public func set(attachmentIconTint: UIColor) -> Self {
        self.attachmentIconTint = attachmentIconTint
        return self
    }
    
    @discardableResult
    public func set(sendIconTint: UIColor) -> Self {
        self.sendIconTint = sendIconTint
        return self
    }
        
    @discardableResult
    public func set(dividerTint: UIColor) -> Self {
        self.dividerTint = dividerTint
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
    public func set(inputBorderWidth: CGFloat) -> Self {
        self.inputBorderWidth = inputBorderWidth
        return self
    }
    
    @discardableResult
    public func set(inputBorderColor: UIColor) -> Self {
        self.inputBorderColor = inputBorderColor
        return self
    }
    
    @discardableResult
    public func set(actionSheetTitleColor: UIColor) -> Self {
        self.actionSheetTitleColor = actionSheetTitleColor
        return self
    }
    
    @discardableResult
    public func set(actionSheetTitleFont: UIFont) -> Self {
        self.actionSheetTitleFont = actionSheetTitleFont
        return self
    }
    
    @discardableResult
    public func set(actionSheetLayoutModelIconTint: UIColor) -> Self {
        self.actionSheetLayoutModelIconTint = actionSheetLayoutModelIconTint
        return self
    }
    
    @discardableResult
    public func set(actionSheetCancelButtonIconTint: UIColor) -> Self {
        self.actionSheetCancelButtonIconTint = actionSheetCancelButtonIconTint
        return self
    }
    
    @discardableResult
    public func set(actionSheetCancelButtonIconFont: UIFont) -> Self {
        self.actionSheetCancelButtonIconFont = actionSheetCancelButtonIconFont
        return self
    }
}
