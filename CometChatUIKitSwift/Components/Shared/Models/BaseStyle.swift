//
//  BaseStyle.swift
//  
//
//  Created by Abdullah Ansari on 21/09/22.
//

import UIKit

public class BaseStyle {
    
    var background: UIColor = CometChatTheme_v4.palatte.background
    var cornerRadius: CometChatCornerStyle = CometChatCornerStyle(cornerRadius: 0)
    var borderWidth: CGFloat = 0
    private(set) var borderColor: UIColor = .systemFill
    
    public init() {}
    
    @discardableResult
    public func set(background: UIColor) -> Self {
        self.background = background
        return self
    }
    
    @discardableResult
    public func set(cornerRadius: CometChatCornerStyle) -> Self {
        self.cornerRadius = cornerRadius
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        self.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor) -> Self {
        self.borderColor = borderColor
        return self
    }
    
}
