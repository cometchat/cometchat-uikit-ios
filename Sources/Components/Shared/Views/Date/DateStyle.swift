//
//  DateStyle.swift
//
//
//  Created by Abdullah Ansari on 05/09/22.
//

import Foundation
import UIKit

public final class DateStyle: BaseStyle {
    
    private(set) var titleColor = CometChatTheme.palatte.accent400
    private(set) var titleFont = CometChatTheme.typography.subtitle1
    
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
}
