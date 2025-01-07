//
//  CometChatMessageTranslationStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 19/09/24.
//

import Foundation
import UIKit

/// A structure defining the style properties for the message translation bubble,
/// allowing customization of colors, fonts, and other visual elements.
public struct MessageTranslationBubbleStyle: BaseMessageBubbleStyle {
    
    // MARK: - Properties
    
    /// The text font for the thread count in the message translation bubble.
    public var threadedIndicatorTextFont: UIFont?
    
    /// The text color for the thread count in the message translation bubble.
    public var threadedIndicatorTextColor: UIColor?
    
    /// The icon tint for the thread count in the message translation  bubble.
    public var threadedIndicatorImageTint: UIColor?
    
    /// The style for the avatar, if applicable.
    public var avatarStyle: AvatarStyle?
    
    /// The style for the date displayed in the message bubble.
    public var dateStyle: DateStyle?
    
    /// The style for the receipt (e.g., read receipts) in the message bubble.
    public var receiptStyle: ReceiptStyle?
    
    /// The background color of the message bubble.
    public var backgroundColor: UIColor?
    
    /// The background drawable image for the message bubble.
    public var backgroundDrawable: UIImage?
    
    /// The corner radius for the message bubble.
    public var cornerRadius: CometChatCornerStyle? = nil
    
    /// The width of the border around the message bubble.
    public var borderWidth: CGFloat?
    
    /// The color of the border around the message bubble.
    public var borderColor: UIColor?
    
    /// The color of the header text in the message bubble.
    public var headerTextColor: UIColor?
    
    /// The font used for the header text in the message bubble.
    public var headerTextFont: UIFont?
    
    /// The font used for the main text in the message bubble.
    public var textFont: UIFont = CometChatTypography.Body.regular
    
    /// The color of the main text in the message bubble.
    public var textColor: UIColor = CometChatTheme.textColorWhite
    
    /// The color of the URLs displayed in the message bubble.
    public var urlColor: UIColor = #colorLiteral(red: 0.01568627451, green: 0.1965779049, blue: 1, alpha: 1)
    
    /// The color of the email text displayed in the message bubble.
    public var emailTextColor: UIColor = #colorLiteral(red: 0.01568627451, green: 0.1965779049, blue: 1, alpha: 1)
    
    /// The color of the phone text displayed in the message bubble.
    public var phoneTextColor: UIColor = #colorLiteral(red: 0.01568627451, green: 0.1965779049, blue: 1, alpha: 1)
    
    // MARK: - Final Properties
    
    /// The background color of the separator line between messages.
    public var separatorBackgroundColor: UIColor = CometChatTheme.extendedPrimaryColor800
    
    /// The color of the subtitle text in the message bubble.
    public var subtitleTextColor: UIColor = CometChatTheme.textColorWhite
    
    /// The font used for the subtitle text in the message bubble.
    public var subtitleTextFont: UIFont = CometChatTypography.Caption2.regular
    
    /// The reaction style for the reactions displayed in the message bubble
    public var reactionsStyle: ReactionsStyle?
    
    // MARK: - Initializers

    /// Default initializer for `MessageTranslationBubbleStyle`.
    init() {}

    /// Initializes a new instance of `MessageTranslationBubbleStyle` based on the specified bubble style type.
    /// - Parameter styleType: The type of bubble style (incoming or outgoing).
    internal init(styleType: BubbleStyleType) {
        switch styleType {
        case .incoming:
            textColor = CometChatTheme.neutralColor800
            subtitleTextColor = CometChatTheme.neutralColor600
            separatorBackgroundColor = CometChatTheme.neutralColor400
        case .outgoing:
            textColor = CometChatTheme.white
            subtitleTextColor = CometChatTheme.white
            separatorBackgroundColor = CometChatTheme.extendedPrimaryColor800
        }
    }
}
