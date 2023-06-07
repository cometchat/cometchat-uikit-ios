//
//  DeleteBubbleStyle.swift
 
//
//  Created by Abdullah Ansari on 25/05/22.
//

import Foundation
import UIKit

public final class DeleteBubbleStyle: BaseStyle {
    
    private(set) var titleFont = CometChatTheme.typography.text1
    private(set) var titleColor = CometChatTheme.palatte.accent500
    
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
