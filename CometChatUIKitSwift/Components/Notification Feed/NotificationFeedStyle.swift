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
    
    public var titleFont: UIFont? = CometChatTypography.Heading3.bold
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
    public var chipInactiveBackgroundColor: UIColor = UIColor(hex: "#FAFAFA")
    public var chipInactiveTextColor: UIColor = UIColor(hex: "#717680")
    public var chipInactiveTextFont: UIFont = CometChatTypography.Body.bold
    public var chipBorderColor: UIColor = UIColor(hex: "#E9EAEB")
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
    
    // MARK: - Feed Item Card (per Figma: 12px radius, 1px border)
    public var cardBackgroundColor: UIColor = .white
    public var cardBorderColor: UIColor = UIColor(hex: "#E9EAEB")
    public var cardBorderRadius: CGFloat = 12
    public var cardBorderWidth: CGFloat = 1
    
    // MARK: - Card Content
    public var cardTitleFont: UIFont = CometChatTypography.Heading4.medium
    public var cardTitleColor: UIColor = CometChatTheme.textColorPrimary
    public var cardSubtitleFont: UIFont = CometChatTypography.Heading4.bold
    public var cardSubtitleColor: UIColor = CometChatTheme.primaryColor
    public var cardDescriptionFont: UIFont = CometChatTypography.Caption1.regular
    public var cardDescriptionColor: UIColor = UIColor(hex: "#535862")
    
    // MARK: - Card Buttons (per Figma: 8px radius)
    public var primaryButtonBackgroundColor: UIColor = CometChatTheme.primaryColor
    public var primaryButtonTextColor: UIColor = .white
    public var primaryButtonFont: UIFont = CometChatTypography.Body.bold
    public var primaryButtonCornerRadius: CGFloat = 8
    public var secondaryButtonBackgroundColor: UIColor = UIColor(hex: "#FAFAFA")
    public var secondaryButtonTextColor: UIColor = UIColor(hex: "#252B37")
    public var secondaryButtonBorderColor: UIColor = UIColor(hex: "#D5D7DA")
    public var secondaryButtonFont: UIFont = CometChatTypography.Body.bold
    public var secondaryButtonCornerRadius: CGFloat = 8
    
    // MARK: - Unread Indicator
    public var unreadIndicatorColor: UIColor = CometChatTheme.primaryColor
    
    // MARK: - Header (per Figma: 64px, border-bottom)
    public var headerHeight: CGFloat = 64
    public var headerBackgroundColor: UIColor = .white
    public var headerBorderColor: UIColor = UIColor(hex: "#F5F5F5")
    
    public init() { }
}
