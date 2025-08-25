//
//  ModerationStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 31/07/25.
//

import Foundation

public struct ModerationStyle {
    
    public var moderationBackgroundColor: UIColor? = CometChatTheme.errorColor100
    public var moderationImageTint: UIColor? = CometChatTheme.errorColor
    public var moderationTextColor: UIColor? = CometChatTheme.errorColor
    public var moderationTextFont: UIFont? = CometChatTypography.Body.regular
    
    public init() { }
}
