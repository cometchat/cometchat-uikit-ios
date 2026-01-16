//
//  BadgeCountStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public struct BadgeStyle {
    
    private var _backgroundColor: UIColor?
    public var backgroundColor: UIColor {
        get { return _backgroundColor ?? CometChatTheme.primaryColor }
        set { _backgroundColor = newValue }
    }
    
    private var _textColor: UIColor?
    public var textColor: UIColor {
        get { return _textColor ?? CometChatTheme.buttonIconColor }
        set { _textColor = newValue }
    }
    
    public var textFont: UIFont = CometChatTypography.Caption1.regular
    public var cornerRadius : CometChatCornerStyle? = nil
    public var borderWidth : CGFloat = 0.5
    public var borderColor : CGColor = UIColor.clear.cgColor

    public init() {}
}

