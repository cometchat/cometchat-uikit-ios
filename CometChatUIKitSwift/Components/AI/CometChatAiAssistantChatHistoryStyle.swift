//
//  CometChatAiAssistantChatHistoryStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 13/10/25.
//

import Foundation
import UIKit

public struct AiAssistantChatHistoryStyle {
        
    // MARK: - Background & Border
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var borderColor: UIColor = CometChatTheme.neutralColor200
    public var borderWidth: CGFloat = 0
    public var cornerRadius: CometChatCornerStyle?
    
    // MARK: - Empty State
    public var emptyStateTextFont: UIFont = CometChatTypography.Body.regular
    public var emptyStateTextColor: UIColor = CometChatTheme.neutralColor600
    public var emptyStateSubtitleFont: UIFont = CometChatTypography.Caption1.regular
    public var emptyStateSubtitleColor: UIColor = CometChatTheme.neutralColor400
    
    // MARK: - Error State
    public var errorStateTextFont: UIFont = CometChatTypography.Body.medium
    public var errorStateTextColor: UIColor = CometChatTheme.errorColor
    public var errorStateSubtitleFont: UIFont = CometChatTypography.Caption1.regular
    public var errorStateSubtitleColor: UIColor = CometChatTheme.errorColor100
    
    // MARK: - New Chat Section
    public var newChatImageTintColor: UIColor = CometChatTheme.iconColorPrimary
    public var newChatTitleFont: UIFont = CometChatTypography.Button.regular
    public var newChatTextColor: UIColor = CometChatTheme.textColorPrimary
    
    // MARK: - Item (Chat List)
    public var itemTextFont: UIFont = CometChatTypography.Body.regular
    public var itemTextColor: UIColor = CometChatTheme.neutralColor900
    
    // MARK: - Header
    public var headerBackgroundColor: UIColor = CometChatTheme.backgroundColor02
    public var headerTitleFont: UIFont = CometChatTypography.Heading1.regular
    public var headerTitleTextColor: UIColor = CometChatTheme.neutralColor900
    public var closeIconColor: UIColor = CometChatTheme.neutralColor800
    
    public init() { }
}
