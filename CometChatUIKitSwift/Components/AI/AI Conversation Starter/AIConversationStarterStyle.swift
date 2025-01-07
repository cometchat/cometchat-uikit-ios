//
//  AIConversationStarterStyle.swift
//  
//
//  Created by SuryanshBisen on 14/09/23.
//

import Foundation
import UIKit

public struct AIConversationStarterStyle: AIParentStyle{
    
    public var errorViewTextFont: UIFont? = CometChatTypography.Body.regular
    public var errorViewTextColor: UIColor? = CometChatTheme.textColorSecondary
    
    public var emptyViewTextFont: UIFont? = CometChatTypography.Body.regular
    public var emptyViewTextColor: UIColor? = CometChatTheme.textColorSecondary
    
    public var textFont: UIFont = CometChatTypography.Body.regular
    public var textColor: UIColor = CometChatTheme.textColorPrimary
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = CometChatTheme.borderColorLight
    public var cornerRadius: CometChatCornerStyle? = nil
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var repliesTableViewSeparatorStyle: UITableViewCell.SeparatorStyle?
}

