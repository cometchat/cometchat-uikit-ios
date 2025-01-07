//
//  LinkPreviewBubbleStyle.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 18/09/24.
//

import UIKit
import Foundation

/// A structure that defines the styling properties for the CometChatLinkPreviewBubble.
///
/// This struct conforms to `BaseMessageBubbleStyle` and provides customizable
/// visual properties for link preview bubbles in chat messages.
public struct LinkPreviewBubbleStyle: BaseMessageBubbleStyle {
    
    /// The text font for the thread count in the link preview bubble.
    public var threadedIndicatorTextFont: UIFont?
    
    /// The text color for the thread count in the link preview bubble.
    public var threadedIndicatorTextColor: UIColor?
    
    /// The icon tint for the thread count in the link preview  bubble.
    public var threadedIndicatorImageTint: UIColor?
    
    /// The background color of the bubble.
    public var backgroundColor: UIColor?
    
    /// An optional drawable image for the bubble's background.
    public var backgroundDrawable: UIImage?
    
    /// The width of the bubble's border.
    public var borderWidth: CGFloat?
    
    /// The color of the bubble's border.
    public var borderColor: UIColor?
    
    /// The corner radius style of the bubble.
    public var cornerRadius: CometChatCornerStyle?
    
    /// Style properties for the avatar displayed in the bubble.
    public var avatarStyle: AvatarStyle?
    
    /// Style properties for the date displayed in the bubble.
    public var dateStyle: DateStyle?
    
    /// Style properties for the receipt displayed in the bubble.
    public var receiptStyle: ReceiptStyle?
    
    /// The text color for the header in the bubble.
    public var headerTextColor: UIColor?
    
    /// The font used for the header text in the bubble.
    public var headerTextFont: UIFont?
    
    /// The corner radius for the link preview container.
    public var previewCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r3)
    
    /// The background color for the link preview container.
    public var previewBackgroundColor: UIColor = CometChatTheme.extendedPrimaryColor900
    
    /// The font used for the message text in the bubble.
    public var messageTextFont: UIFont = CometChatTypography.Body.regular
    
    /// The text color for the message in the bubble.
    public var messageTextColor: UIColor = CometChatTheme.textColorWhite
    
    /// The text color for the title in the link preview.
    public var titleTextColor: UIColor = CometChatTheme.neutralColor900
    
    /// The font used for the title text in the link preview.
    public var titleTextFont: UIFont = CometChatTypography.Body.bold
    
    /// The text color for the subtitle in the link preview.
    public var subtitleTextColor: UIColor = CometChatTheme.neutralColor900
    
    /// The font used for the subtitle text in the link preview.
    public var subtitleTextFont: UIFont = CometChatTypography.Caption1.regular
    
    /// The text color for the link in the link preview.
    public var linkTextColor: UIColor = CometChatTheme.neutralColor900.withAlphaComponent(0.6)
    
    /// The font used for the link text in the link preview.
    public var linkTextFont: UIFont = CometChatTypography.Caption1.regular
    
    /// The corner radius style for the link icon image.
    public var linkIconImageCornerRadios: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r1)
    
    /// The color used to highlight text links in the bubble.
    public var textHighlightColor: UIColor = #colorLiteral(red: 0.01568627451, green: 0.1965779049, blue: 1, alpha: 1)
    
    /// The reaction style for the reactions displayed in the bubble.
    public var reactionsStyle: ReactionsStyle?
    
    /// Initializes a new instance of `LinkPreviewBubbleStyle` with default values.
    public init() { }
    
    /// Initializes a new instance of `LinkPreviewBubbleStyle` with default values based on the bubble type.
    ///
    /// - Parameter styleType: The type of bubble style (incoming or outgoing).
    internal init(styleType: BubbleStyleType) {
        switch styleType {
        case .incoming:
            titleTextColor = CometChatTheme.neutralColor900
            subtitleTextColor = CometChatTheme.neutralColor900
            linkTextColor = CometChatTheme.neutralColor900.withAlphaComponent(0.6)
            previewBackgroundColor = CometChatTheme.neutralColor400
            messageTextColor = CometChatTheme.neutralColor800
            textHighlightColor = CometChatTheme.infoColor
        case .outgoing:
            titleTextColor = CometChatTheme.white
            subtitleTextColor = CometChatTheme.white
            linkTextColor = CometChatTheme.white.withAlphaComponent(0.6)
            previewBackgroundColor = CometChatTheme.extendedPrimaryColor900
            messageTextColor = CometChatTheme.white
            textHighlightColor = CometChatTheme.white
        }
    }
}
