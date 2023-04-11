//
//  BadgeCountStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public final class BadgeStyle: BaseStyle {

    private(set) var textColor = CometChatTheme.palatte.background
    private(set) var textFont: UIFont = CometChatTheme.typography.text2
    
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
