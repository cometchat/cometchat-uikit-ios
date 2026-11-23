//
//  CometChatOfflineStyle.swift
//  CometChatUIKitSwift
//
//  Style tokens for the offline messaging states (plan §4). Every token defaults to today's error
//  and secondary-text tokens, so nothing changes unless an integrator sets them, and none of them is
//  used while offline messaging is off.
//

import UIKit

public struct CometChatOfflineStyle {

    /// "Not sent. Tap to retry" under a failed own message (every failed row can be retried: R162).
    public var retryTextColor: UIColor = CometChatTheme.errorColor
    public var retryTextFont: UIFont = CometChatTypography.Caption1.medium

    /// Tint of the failed status icon of an unsent row (`nil`: the receipt style's error tint).
    public var failedIconTint: UIColor?

    /// "Not sent yet", the line under a queued or sending own message.
    public var notSentYetTextColor: UIColor = CometChatTheme.textColorSecondary
    public var notSentYetTextFont: UIFont = CometChatTypography.Caption1.regular

    /// "Available when online", the placeholder for media with no on-device copy.
    public var mediaPlaceholderTextColor: UIColor = CometChatTheme.textColorSecondary
    public var mediaPlaceholderTextFont: UIFont = CometChatTypography.Caption1.regular

    /// "Connect to load more" at the end of the saved messages (both edges of the message list).
    public var footerTextColor: UIColor = CometChatTheme.textColorSecondary
    public var footerTextFont: UIFont = CometChatTypography.Caption1.regular

    /// "Jump to latest", the pill shown when more arrived than one refresh could bridge.
    public var jumpToLatestTextColor: UIColor = CometChatTheme.white
    public var jumpToLatestTextFont: UIFont = CometChatTypography.Caption1.medium
    public var jumpToLatestBackgroundColor: UIColor = CometChatTheme.primaryColor

    public init() {}
}
