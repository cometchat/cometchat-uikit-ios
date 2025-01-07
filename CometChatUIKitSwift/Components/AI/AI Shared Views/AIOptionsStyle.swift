//
//  AIOptionsStyle.swift
//
//
//  Created by SuryanshBisen on 25/10/23.
//

import Foundation
import UIKit

public struct AIOptionsStyle: AIParentStyle {    
    public var errorViewTextFont: UIFont?
    public var errorViewTextColor: UIColor?
    
    public var emptyViewTextFont: UIFont?
    public var emptyViewTextColor: UIColor?
    
    public var aiImageTintColor: UIColor = CometChatTheme.iconColorHighlight
    public var textColor: UIColor = CometChatTheme.textColorPrimary
    public var textFont: UIFont = CometChatTypography.Heading4.regular
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    public var cornerRadius: CometChatCornerStyle? = nil
    
    public init(){ }
    
}
