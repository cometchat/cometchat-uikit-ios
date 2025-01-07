//
//  StickerKeyboardStyle.swift
//  
//
//  Created by Abdullah Ansari on 26/09/22.
//

import UIKit

public struct StickerKeyboardStyle {
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var separatorColor: UIColor = CometChatTheme.borderColorDefault
    public var emptyStateTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    public var emptyStateTitleTextFont: UIFont = CometChatTypography.Heading4.medium
    public var emptyStateSubtitleTextColor: UIColor = CometChatTheme.textColorSecondary
    public var emptyStateSubtitleTextFont: UIFont = CometChatTypography.Body.regular
    public var errorStateTextColor: UIColor = CometChatTheme.textColorSecondary
    public var errorStateTextFont: UIFont = CometChatTypography.Body.regular
    
    public init() { }
 
}
