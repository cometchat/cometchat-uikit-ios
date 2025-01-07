//
//  ReactionListStyle.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 29/02/24.
//

import UIKit
import Foundation

public struct ReactionListStyle {
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var cornerRadius: CometChatCornerStyle? = nil
    public var borderWidth: CGFloat = 0.0
    public var borderColor: UIColor = CometChatTheme.borderColorLight
    public var titleTextFont : UIFont = CometChatTypography.Body.medium
    public var titleTextColor : UIColor = CometChatTheme.textColorPrimary
    public var reactionTabTextFont : UIFont = CometChatTypography.Body.medium
    public var reactionTabTextColor : UIColor = CometChatTheme.textColorSecondary
    public var reactionActiveTabTextColor : UIColor = CometChatTheme.textColorHighlight
    public var reactionTabBackgroundColor : UIColor = .clear
    public var reactionTabActiveIndicatorColor : UIColor = CometChatTheme.primaryColor
    public var tailViewTextFont : UIFont = CometChatTypography.Heading2.regular
    public var subTitleTextFont : UIFont = CometChatTypography.Caption1.regular
    public var subTitleTextColor : UIColor = CometChatTheme.textColorSecondary
    public var errorTextColor : UIColor = CometChatTheme.textColorSecondary
    public var errorTextFont : UIFont = CometChatTypography.Body.regular
    public var avatarStyle : AvatarStyle = CometChatAvatar.style
        
    public init() { }
}
