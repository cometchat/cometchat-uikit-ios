//
//  AISmartRepliesStyle.swift
//  
//
//  Created by SuryanshBisen on 14/09/23.
//

import Foundation
import UIKit

public struct AISmartRepliesStyle: AIParentStyle {
    
    public var errorViewTextFont: UIFont? = CometChatTypography.Body.regular
    public var errorViewTextColor: UIColor? = CometChatTheme.textColorSecondary
    
    public var emptyViewTextFont: UIFont? = CometChatTypography.Body.regular
    public var emptyViewTextColor: UIColor? = CometChatTheme.textColorSecondary
    
    public var cancelButtonImage: UIImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var cancelButtonImageTintColor: UIColor = CometChatTheme.iconColorPrimary

    public var titleTextFont: UIFont = CometChatTypography.Heading4.medium
    public var titleTextColor: UIColor = CometChatTheme.textColorPrimary
    public var repliesTextFont: UIFont = CometChatTypography.Body.regular
    public var repliesTextColor: UIColor = CometChatTheme.textColorPrimary
    public var repliesViewBorderWidth: CGFloat = 1
    public var repliesViewBorderColor: UIColor = CometChatTheme.borderColorLight
    public var repliesViewBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var repliesViewCornerRadius : CometChatCornerStyle? = nil
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    public var cornerRadius: CometChatCornerStyle? = nil
}
