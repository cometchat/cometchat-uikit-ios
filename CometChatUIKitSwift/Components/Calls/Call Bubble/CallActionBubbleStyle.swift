//
//  CallActionBubbleStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 05/11/24.
//

import UIKit
import Foundation

public struct CallActionBubbleStyle {
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor02
    
    /// When set, replaces the per-status call glyph in the call action bubble; `nil` keeps the default glyphs.
    public var callImage: UIImage?
    
    public var callImageTintColor: UIColor = CometChatTheme.iconColorSecondary
    
    public var missedCallImageTintColor: UIColor = CometChatTheme.errorColor
    
    public var borderWidth: CGFloat = 1
    
    public var borderColor: UIColor = CometChatTheme.borderColorDefault
    
    public var cornerRadius: CometChatCornerStyle? = nil
    
    public var callTextFont: UIFont = CometChatTypography.Caption1.regular
    
    public var callTextColor: UIColor = CometChatTheme.textColorSecondary
    
    /// The status text font for a missed (unanswered) call.
    public var missedCallTextFont: UIFont = CometChatTypography.Caption1.regular
    
    public var missedCallTextColor: UIColor = CometChatTheme.errorColor
        
    public init() { }
}
