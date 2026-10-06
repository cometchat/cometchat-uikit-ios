//
//  MessageListStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public struct MessageListStyle {
    
    public var backgroundColor = UIColor.dynamicColor(
        lightModeColor: CometChatTheme.backgroundColor03.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
        darkModeColor: CometChatTheme.backgroundColor02.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
    )
    public var borderWidth: CGFloat = CGFloat(0)
    public var borderColor: UIColor = .clear
    public var cornerRadius: CometChatCornerStyle?
    public var shimmerGradientColor1: UIColor = CometChatTheme.backgroundColor04
    public var shimmerGradientColor2: UIColor = CometChatTheme.backgroundColor03
    
    public var emptyStateTitleColor: UIColor = CometChatTheme.textColorPrimary
    public var emptyStateTitleFont: UIFont = CometChatTypography.Heading3.bold
    public var emptyStateSubtitleColor: UIColor = CometChatTheme.textColorSecondary
    public var emptyStateSubtitleFont: UIFont = CometChatTypography.Body.regular
    
    public var errorStateTitleColor: UIColor = CometChatTheme.textColorPrimary
    public var errorStateTitleFont: UIFont = CometChatTypography.Heading3.bold
    public var errorStateSubtitleColor: UIColor = CometChatTheme.textColorSecondary
    public var errorStateSubtitleFont: UIFont = CometChatTypography.Body.regular

    public var threadedMessageImage = UIImage(systemName: "arrow.turn.down.right")?.withRenderingMode(.alwaysTemplate)
    /// Not applied: the default `errorStateView` is a blank view with no image slot, and a view passed to `set(errorView:)` keeps its own image. Kept for source compatibility.
    public var errorImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    public var emptyImage = UIImage(named: "empty-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    /// When set, replaces the icon of the floating new-messages indicator (`NewMessageIndicatorStyle.iconImage`). `nil` keeps that style's icon.
    public var newMessageIndicatorImage: UIImage?
    
    public var backgroundImage: UIImage?

    // MARK: - AI Assistant Suggested Message
    // Read by the AI assistant greeting (AIAssistantIntroductionView). The defaults are the
    // theme values the greeting painted before these fields were wired up.
    public var aiAssistantSuggestedMessageTextFont: UIFont? = CometChatTypography.Body.regular
    
    public var aiAssistantSuggestedMessageTextColor: UIColor? = CometChatTheme.textColorSecondary
    
    public var aiAssistantSuggestedMessageBorderColor: UIColor? = CometChatTheme.borderColorDefault
    
    public var aiAssistantSuggestedMessageBorderWidth: CGFloat? = 1
    
    public var aiAssistantSuggestedMessageCornerRadius: CGFloat? = 20
    
    public var aiAssistantSuggestedMessageBackgroundColor: UIColor? = CometChatTheme.backgroundColor01
    
    public var aiAssistantSuggestedMessageIconColor: UIColor? = CometChatTheme.iconColorSecondary
    
    public var emptyChatGreetingTitleTextColor: UIColor? = CometChatTheme.textColorPrimary
    
    public var emptyChatGreetingTitleTextFont: UIFont? = CometChatTypography.Heading4.medium
    
    public var emptyChatGreetingSubtitleTextColor: UIColor? = CometChatTheme.textColorTertiary
    
    public var emptyChatGreetingSubtitleTextFont: UIFont? = CometChatTypography.Body.regular
    
    public var newMessageIndicatorTextColor: UIColor = CometChatTheme.errorColor
    
    public var newMessageIndicatorBackgroundColor: UIColor = CometChatTheme.errorColor
    
    public var newMessageIndicatorTextFont: UIFont = CometChatTypography.Caption1.medium
            
    public init() {  }
}
