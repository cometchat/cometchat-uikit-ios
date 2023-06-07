//
//  TextBubbleStyle.swift
 
//
//  Created by Abdullah Ansari on 20/05/22.
//

import Foundation
import UIKit

public class TextBubbleStyle: BaseStyle {
    
    var titleFont: UIFont = CometChatTheme.typography.text1
    var titleColor: UIColor = CometChatTheme.palatte.accent900
    override var background: UIColor {
        get {
            return .clear
        }
        set {
            super.background = newValue
        }
    }
   
    @discardableResult
    public func set(titleFont: UIFont) -> Self {
        self.titleFont = titleFont
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        self.titleColor = titleColor
        return self
    }
    
   
}
