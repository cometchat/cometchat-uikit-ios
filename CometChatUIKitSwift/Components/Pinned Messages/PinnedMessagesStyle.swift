//
//  PinnedMessagesStyle.swift
//  CometChatUIKitSwift
//

import UIKit

/// Rows render as message bubbles, so bubble appearance comes from
/// `CometChatPinnedMessages.messageBubbleStyle`, not from here. This style covers the
/// screen chrome, the date separator's own `dateSeparatorStyle`, and the unpin action.
public struct PinnedMessagesStyle: ListBaseStyle {

    // Background color for the entire screen or view
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01

    // Border width for the container
    public var borderWidth: CGFloat = 0

    // Color of the border, default is clear
    public var borderColor: UIColor = .clear

    // Corner radius for the container
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)

    // Text color for title elements within the list or navigation bar
    public var titleColor: UIColor? = CometChatTheme.textColorPrimary

    // Font for title text
    public var titleFont: UIFont? = CometChatTypography.setFont(size: 17, weight: .bold)

    // Text color for large titles (i.e., navigation large titles)
    public var largeTitleColor: UIColor? = CometChatTheme.textColorPrimary

    // Font for large titles
    public var largeTitleFont: UIFont? = CometChatTypography.setFont(size: 34, weight: .bold)

    // Tint color for the navigation bar background
    public var navigationBarTintColor: UIColor? = CometChatTheme.backgroundColor01

    // Tint color for navigation bar items (buttons, icons)
    public var navigationBarItemsTintColor: UIColor? = CometChatTheme.iconColorHighlight

    // Font for the error title displayed in UI
    public var errorTitleTextFont: UIFont = CometChatTypography.Heading3.bold

    // Text color for the error title
    public var errorTitleTextColor: UIColor = CometChatTheme.textColorPrimary

    // Font for the subtitle of error messages
    public var errorSubTitleFont: UIFont = CometChatTypography.Body.regular

    // Text color for the subtitle of error messages
    public var errorSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary

    // Text color for the retry button in error states
    public var retryButtonTextColor: UIColor = CometChatTheme.buttonTextColor

    // Font for the retry button text
    public var retryButtonTextFont: UIFont = CometChatTypography.Button.medium

    // Background color for the retry button
    public var retryButtonBackgroundColor: UIColor = CometChatTheme.primaryColor

    // Border color for the retry button
    public var retryButtonBorderColor: UIColor = .clear

    // Border width for the retry button
    public var retryButtonBorderWidth: CGFloat = 0

    // Corner radius for the retry button
    public var retryButtonCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)

    // Font for the empty state title (when no pinned messages are present)
    public var emptyTitleTextFont: UIFont = CometChatTypography.Heading3.bold

    // Text color for the empty state title
    public var emptyTitleTextColor: UIColor = CometChatTheme.textColorPrimary

    // Font for the subtitle in the empty state
    public var emptySubTitleFont: UIFont = CometChatTypography.Body.regular

    // Text color for the subtitle in the empty state
    public var emptySubTitleTextColor: UIColor = CometChatTheme.textColorSecondary

    // Color for the table view separator
    public var tableViewSeparator: UIColor = CometChatTheme.borderColorLight

    // Text color for the bubble header, which carries the sender name. Only used when no
    // template supplies its own header view.
    public var bubbleHeaderTextColor: UIColor = CometChatTheme.primaryColor

    // Font for the bubble header
    public var bubbleHeaderFont: UIFont = CometChatTypography.Caption1.medium

    // Text color for the one-line message preview the banner renders
    public var previewTextColor: UIColor = CometChatTheme.textColorSecondary

    // Font for the one-line message preview
    public var previewFont: UIFont = CometChatTypography.Body.regular

    // Tint for the per-row unpin control
    public var unpinIconTint: UIColor = CometChatTheme.iconColorSecondary

    // Background for the per-row unpin swipe action
    public var unpinActionBackgroundColor: UIColor = CometChatTheme.errorColor

    public init() {}
}
