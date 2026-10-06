//
//  NotificationFeedStyle.swift
//  CometChatUIKitSwift
//
//  Created by CometChat on 14/05/26.
//

import UIKit
import CometChatUIKitSwift

public struct NotificationFeedStyle: ListBaseStyle {
    
    // MARK: - ListBaseStyle conformance
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    public var titleFont: UIFont? = UIFont.systemFont(ofSize: 24, weight: .bold)
    public var largeTitleFont: UIFont? = CometChatTypography.Heading3.bold
    public var titleColor: UIColor? = CometChatTheme.textColorPrimary
    public var largeTitleColor: UIColor? = CometChatTheme.textColorPrimary
    
    public var navigationBarTintColor: UIColor?
    public var navigationBarItemsTintColor: UIColor?
    
    public var errorTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    public var errorTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    public var errorSubTitleFont: UIFont = CometChatTypography.Body.regular
    public var errorSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    public var retryButtonTextColor: UIColor = CometChatTheme.buttonTextColor
    public var retryButtonTextFont: UIFont = CometChatTypography.Button.medium
    public var retryButtonBackgroundColor: UIColor = CometChatTheme.primaryColor
    public var retryButtonBorderColor: UIColor = .clear
    public var retryButtonBorderWidth: CGFloat = 0
    public var retryButtonCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    
    public var emptyTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    public var emptyTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    public var emptySubTitleFont: UIFont = CometChatTypography.Body.regular
    public var emptySubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    public var tableViewSeparator: UIColor = .clear
    
    // MARK: - Filter Chips (per Figma: 34px height, full rounded)
    public var chipActiveBackgroundColor: UIColor = CometChatTheme.primaryColor
    public var chipActiveTextColor: UIColor = .white
    public var chipActiveTextFont: UIFont = CometChatTypography.Body.bold
    public var chipInactiveBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var chipInactiveTextColor: UIColor = CometChatTheme.textColorSecondary
    public var chipInactiveTextFont: UIFont = CometChatTypography.Body.bold
    public var chipBorderColor: UIColor = CometChatTheme.borderColorDefault
    public var chipBorderWidth: CGFloat = 1
    public var chipCornerRadius: CGFloat = 17
    
    // MARK: - Badge (inside active chip)
    public var badgeActiveBackgroundColor: UIColor = UIColor(hex: "#F4F3FF")
    public var badgeActiveBorderColor: UIColor = UIColor(hex: "#D9D6FE")
    public var badgeActiveTextColor: UIColor = UIColor(hex: "#5925DC")
    public var badgeInactiveBackgroundColor: UIColor = UIColor(hex: "#535862")
    public var badgeInactiveTextColor: UIColor = .white
    public var badgeTextFont: UIFont = CometChatTypography.Caption1.medium
    
    // MARK: - Timestamp Section Header
    public var timestampHeaderTextColor: UIColor = UIColor(hex: "#414651")
    public var timestampHeaderFont: UIFont = CometChatTypography.Caption1.regular
    public var timestampValueColor: UIColor = UIColor(hex: "#535862")
    public var timestampValueFont: UIFont = CometChatTypography.Caption1.regular
    
    // MARK: - Feed Item Card
    // Applied to the container around the rendered card. The card draws its own
    // chrome from its JSON, so the defaults add nothing on top of it.
    public var cardBackgroundColor: UIColor = .clear
    public var cardBorderColor: UIColor = .clear
    public var cardBorderRadius: CGFloat = 12
    public var cardBorderWidth: CGFloat = 0
    
    // MARK: - Card Content
    public var cardTitleFont: UIFont = CometChatTypography.Heading4.medium
    public var cardTitleColor: UIColor = CometChatTheme.textColorPrimary
    /// Not applied: the card is rendered by the cards SDK, which takes no per-role fonts. Kept for source compatibility.
    public var cardSubtitleFont: UIFont = CometChatTypography.Heading4.bold
    /// Not applied: the card is rendered by the cards SDK, which takes no per-role subtitle colour. Kept for source compatibility.
    public var cardSubtitleColor: UIColor = CometChatTheme.primaryColor
    /// Not applied: the card is rendered by the cards SDK, which takes no per-role fonts. Kept for source compatibility.
    public var cardDescriptionFont: UIFont = CometChatTypography.Caption1.regular
    public var cardDescriptionColor: UIColor = UIColor(hex: "#535862")
    
    // MARK: - Card Buttons (per Figma: 8px radius)
    public var primaryButtonBackgroundColor: UIColor = CometChatTheme.primaryColor
    public var primaryButtonTextColor: UIColor = .white
    /// Not applied: the card is rendered by the cards SDK, which takes no per-role button font. Kept for source compatibility.
    public var primaryButtonFont: UIFont = CometChatTypography.Body.bold
    /// Not applied: the card is rendered by the cards SDK, which takes no per-role button radius. Kept for source compatibility.
    public var primaryButtonCornerRadius: CGFloat = 8
    /// Not applied: the card is rendered by the cards SDK, which takes no per-role secondary-button theme. Kept for source compatibility.
    public var secondaryButtonBackgroundColor: UIColor = UIColor(hex: "#FAFAFA")
    /// Not applied: the card is rendered by the cards SDK, which takes no per-role secondary-button theme. Kept for source compatibility.
    public var secondaryButtonTextColor: UIColor = UIColor(hex: "#252B37")
    /// Not applied: the card is rendered by the cards SDK, which takes no per-role secondary-button theme. Kept for source compatibility.
    public var secondaryButtonBorderColor: UIColor = UIColor(hex: "#D5D7DA")
    /// Not applied: the card is rendered by the cards SDK, which takes no per-role button font. Kept for source compatibility.
    public var secondaryButtonFont: UIFont = CometChatTypography.Body.bold
    /// Not applied: the card is rendered by the cards SDK, which takes no per-role button radius. Kept for source compatibility.
    public var secondaryButtonCornerRadius: CGFloat = 8
    
    // MARK: - Unread Indicator
    /// Not drawn: feed rows have no unread indicator view. Kept for source compatibility.
    public var unreadIndicatorColor: UIColor = CometChatTheme.primaryColor
    
    // MARK: - Header (navigation bar and filter chips strip)
    /// Not applied: the header is the system navigation bar, whose height UIKit controls.
    public var headerHeight: CGFloat = 64
    public var headerBackgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var headerBorderColor: UIColor = .clear
    
    public init() { }
}
