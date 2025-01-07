//
//  AIConversationSummaryStyle.swift
//
//
//  Created by SuryanshBisen on 21/10/23.
//

import Foundation
import UIKit

public struct AIConversationSummaryStyle: AIParentStyle {
    
    public var errorViewTextFont: UIFont? = CometChatTypography.Body.regular
    public var errorViewTextColor: UIColor? = CometChatTheme.textColorSecondary
    
    public var emptyViewTextFont: UIFont? = CometChatTypography.Body.regular
    public var emptyViewTextColor: UIColor? = CometChatTheme.textColorSecondary
    
    public var cancelButtonImage: UIImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var cancelButtonImageTintColor: UIColor = CometChatTheme.iconColorPrimary

    public var titleTextFont: UIFont = CometChatTypography.Heading4.medium
    public var titleTextColor: UIColor = CometChatTheme.textColorPrimary
    public var summaryTextFont: UIFont = CometChatTypography.Body.regular
    public var summaryTextColor: UIColor = CometChatTheme.textColorPrimary
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    public var cornerRadius: CometChatCornerStyle? = nil
}
