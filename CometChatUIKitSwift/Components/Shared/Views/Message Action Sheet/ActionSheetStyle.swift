//
//  ActionSheetStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public struct ActionSheetStyle{
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    public var cornerRadius: CometChatCornerStyle? = nil
    public var imageTintColor: UIColor = CometChatTheme.iconColorHighlight
    public var textFont: UIFont = CometChatTypography.Heading4.regular
    public var textColor: UIColor = CometChatTheme.textColorPrimary
    
    public init() { }
}
