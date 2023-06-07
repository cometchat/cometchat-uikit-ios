//
//  CollaborativeDocumentStyle.swift
 
//
//  Created by Abdullah Ansari on 19/05/22.
//

import Foundation
import UIKit

public final class CollaborativeDocumentStyle: BaseStyle {
    
    private(set) var titleFont = CometChatTheme.typography.text2
    private(set) var titleColor = CometChatTheme.palatte.accent900
    private(set) var subTitleFont = CometChatTheme.typography.subtitle2
    private(set) var subTitleColor = CometChatTheme.palatte.accent600
    private(set) var iconTint = CometChatTheme.palatte.accent700
    private(set) var buttonTextFont = CometChatTheme.typography.text1
    private(set) var buttonTextColor = CometChatTheme.palatte.primary
    private(set) var dividerTint = CometChatTheme.palatte.accent100
    //var buttonBackground
    
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
    public func set(subTitleColor: UIColor) -> Self {
        self.subTitleColor = subTitleColor
        return self
    }
    
    @discardableResult
    public func set(subTitleFont: UIFont) -> Self {
        self.subTitleFont = subTitleFont
        return self
    }
    
    @discardableResult
    public func set(iconTint: UIColor) -> Self {
        self.iconTint = iconTint
        return self
    }
    
    @discardableResult
    public func set(buttonTextFont: UIFont) -> Self {
        self.buttonTextFont = buttonTextFont
        return self
    }
    
    @discardableResult
    public func set(buttonTextColor: UIColor) -> Self {
        self.buttonTextColor = buttonTextColor
        return self
    }
    
    @discardableResult
    public func set(dividerTint: UIColor) -> Self {
        self.dividerTint = dividerTint
        return self
    }
}


