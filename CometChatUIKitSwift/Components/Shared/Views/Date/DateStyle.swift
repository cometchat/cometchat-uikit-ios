//
//  DateStyle.swift
//
//
//  Created by Abdullah Ansari on 05/09/22.
//

import Foundation
import UIKit

public struct DateStyle {
    
    public var textColor = CometChatTheme.textColorPrimary
    public var textFont = CometChatTypography.Caption1.medium
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor02
    public var cornerRadius: CometChatCornerStyle? = nil
    public var borderWidth: CGFloat = 1
    public var borderColor: UIColor = CometChatTheme.borderColorDark
    
    public init() {}
}
