//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 15/11/22.
//

import Foundation
import UIKit

public class ListItemOption: CometChatOption {
    
}


public final class ListItemStyle: BaseStyle {

    private(set) var titleColor = CometChatTheme.palatte.accent900
    private(set) var titleFont = CometChatTheme.typography.title2
    private(set) var selectionIconTint = CometChatTheme.palatte.primary
    
  
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
    public func set(selectionIconTint: UIColor) -> Self {
        self.selectionIconTint = selectionIconTint
        return self
    }
}
