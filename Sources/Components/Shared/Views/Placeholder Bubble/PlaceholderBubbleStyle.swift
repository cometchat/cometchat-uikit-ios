//
//  PlaceholderBubbleStyle.swift
//  
//
//  Created by Abdullah Ansari on 31/08/22.
//

import UIKit

public final class PlaceholderBubbleStyle: BaseStyle {

    private(set) var textColor = CometChatTheme.palatte.accent
    private(set) var textFont = CometChatTheme.typography.text1
    
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
