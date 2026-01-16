//
//  AvatarStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public struct AvatarStyle {

    private var _backgroundColor: UIColor?
    public var backgroundColor: UIColor {
        get { return _backgroundColor ?? CometChatTheme.extendedPrimaryColor500 }
        set { _backgroundColor = newValue }
    }
    
    public var borderColor: UIColor = .clear
    public var borderWidth: CGFloat = 0
    public var cornerRadius: CometChatCornerStyle? = nil
    public var textFont = CometChatTypography.Heading2.bold
    
    private var _textColor: UIColor?
    public var textColor: UIColor {
        get { return _textColor ?? CometChatTheme.white }
        set { _textColor = newValue }
    }
    
    public init() {  }
    
}
