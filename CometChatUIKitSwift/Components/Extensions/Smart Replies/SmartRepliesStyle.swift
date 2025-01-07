//
//  SmartRepliesStyle.swift
//  
//
//  Created by Abdullah Ansari on 26/09/22.
//

import UIKit

public final class SmartRepliesStyle: BaseStyle {

    private(set) var textFont = CometChatTheme_v4.typography.subtitle1
    private(set) var textColor = CometChatTheme_v4.palatte.accent900
    private(set) var textBackground = CometChatTheme_v4.palatte.background
    private(set) var borderRadius = CometChatCornerStyle(cornerRadius: 18.0)
    private(set) var shadowColor = CometChatTheme_v4.palatte.accent300
    // TODO: - Discuss
    // var borderWidth: CGFloat = 12.0 the same property is in BaseStyle.
    // There should be one more property closeIconTint
    
    @discardableResult
    public func set(textFont: UIFont) -> Self {
        self.textFont = textFont
        return self
    }
    
    @discardableResult
    public func set(textColor: UIColor) -> Self {
        self.textColor = textColor
        return self
    }
    
    @discardableResult
    public func set(textBackground: UIColor) -> Self {
        self.textBackground = textBackground
        return self
    }
    
    @discardableResult
    public func set(borderRadius: CometChatCornerStyle) -> Self {
        self.borderRadius = borderRadius
        return self
    }
    
}
