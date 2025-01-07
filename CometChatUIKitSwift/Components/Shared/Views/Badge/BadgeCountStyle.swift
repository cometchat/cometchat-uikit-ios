//
//  BadgeCountStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public struct BadgeStyle {
        
    public var textColor: UIColor = CometChatTheme.buttonIconColor
    public var textFont: UIFont = CometChatTypography.Caption1.regular
    public var cornerRadius : CometChatCornerStyle? = nil
    public var backgroundColor : UIColor = CometChatTheme.primaryColor
    public var borderWidth : CGFloat = 0.5
    public var borderColor : CGColor = UIColor.clear.cgColor

    public init() {}
}

