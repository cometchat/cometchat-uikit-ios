
//  NewMessageIndicatorStyle.swift
//  Created by admin on 15/09/22.
//

import Foundation
import UIKit

public final class NewMessageIndicatorStyle: BaseStyle {
    
    private(set) var textFont: UIFont = .systemFont(ofSize: 33)
    private(set) var textColor: UIColor = .white
    private(set) var iconTint: UIColor = .green
    
    override public var background: UIColor {
        get {
            return CometChatTheme.palatte.primary
        }
        set {}
    }
    
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
    public func set(iconTint: UIColor) -> Self {
        self.iconTint = iconTint
        return self
    }
}
