//
//  DeleteBubbleStyle.swift
 
//
//  Created by Abdullah Ansari on 25/05/22.
//

import Foundation
import UIKit

/// A struct representing the style configuration for a deleted message bubble.
/// It allows customization of various appearance attributes such as background color, border, and text styling for both incoming and outgoing message bubbles.
public struct DeleteBubbleStyle: BaseMessageBubbleStyle {
    
    // MARK: - Background and Border Styling
    
    /// The background color of the delete bubble.
    public var backgroundColor: UIColor?
    
    /// The background image or drawable for the delete bubble.
    public var backgroundDrawable: UIImage?
    
    /// The width of the border around the delete bubble.
    public var borderWidth: CGFloat?
    
    /// The color of the border around the delete bubble.
    public var borderColor: UIColor?
    
    /// The corner radius to apply to the delete bubble's corners.
    public var cornerRadius: CometChatCornerStyle?
    
    // MARK: - Additional Styles
    
    /// The style for the avatar associated with the deleted message bubble (if applicable).
    public var avatarStyle: AvatarStyle?
    
    /// The style for the date shown in the message bubble (if applicable).
    public var dateStyle: DateStyle?
    
    /// The style for the message receipt shown in the message bubble (if applicable).
    public var receiptStyle: ReceiptStyle?
    
    /// The color of the header text, if the bubble includes a header (such as a timestamp or sender's name).
    public var headerTextColor: UIColor?
    
    /// The font for the header text, if the bubble includes a header.
    public var headerTextFont: UIFont?
    
    /// The text font for the thread count in the delete bubble.
    public var threadedIndicatorTextFont: UIFont?
    
    /// The text color for the thread count in the delete bubble.
    public var threadedIndicatorTextColor: UIColor?
    
    /// The icon tint for the thread count in the delete bubble.
    public var threadedIndicatorImageTint: UIColor?
    
    // MARK: - Delete Bubble Specific Styles
    
    /// The color of the text shown in the delete bubble, indicating that the message was deleted.
    public var textColor: UIColor?
    
    /// The font for the text shown in the delete bubble.
    public var textFont: UIFont = CometChatTypography.Body.regular
    
    /// The tint color for the delete image icon shown in the delete bubble.
    public var deleteImageTintColor: UIColor?
    
    public var reactionsStyle: ReactionsStyle?
    
    // MARK: - Initializers
    
    /// Initializes a `DeleteBubbleStyle` instance with default values.
    public init() {}
    
    /// Initializes a `DeleteBubbleStyle` with default values based on the message bubble type (incoming or outgoing).
    /// - Parameter styleType: The type of the bubble, either `.incoming` or `.outgoing`. This sets default colors for the text and delete image.
    internal init(styleType: BubbleStyleType) {
        switch styleType {
        case .incoming:
            textColor = CometChatTheme.neutralColor600
            deleteImageTintColor = CometChatTheme.neutralColor600
        case .outgoing:
            textColor = CometChatTheme.textColorWhite
            deleteImageTintColor = CometChatTheme.textColorWhite
        }
    }
}
