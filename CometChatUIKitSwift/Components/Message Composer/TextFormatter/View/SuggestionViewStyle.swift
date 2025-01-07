//
//  SuggestionViewStyle.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 20/03/24.
//

import Foundation
import UIKit

public struct SuggestionViewStyle {
    
    public var backgroundColor : UIColor = CometChatTheme.backgroundColor01
    public var borderColor : UIColor = CometChatTheme.borderColorLight
    public var borderWidth : CGFloat = 1
    public var cornerRadius : CometChatCornerStyle? = nil
    public var textFont : UIFont = CometChatTypography.Heading4.medium
    public var textColor : UIColor = CometChatTheme.textColorPrimary
    
    public init() { }
}
