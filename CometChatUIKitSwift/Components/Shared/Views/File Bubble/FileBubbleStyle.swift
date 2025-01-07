//
//  FileBubbleStyle.swift
 
//
//  Created by CometChat on 23/05/22.
//

import Foundation
import UIKit

/// A structure representing the style configuration for the file bubble in CometChat messages.
public struct FileBubbleStyle: BaseMessageBubbleStyle {
    
    /// The text font for the thread count in the file bubble.
    public var threadedIndicatorTextFont: UIFont?
    
    /// The text color for the thread count in the file bubble.
    public var threadedIndicatorTextColor: UIColor?
    
    /// The icon tint for the thread count in the file bubble.
    public var threadedIndicatorImageTint: UIColor?
    
    public var headerTextColor: UIColor?
    
    public var headerTextFont: UIFont?

    /// The background color of the file bubble.
    public var backgroundColor: UIColor?
    
    /// The background image (drawable) for the file bubble.
    public var backgroundDrawable: UIImage?
    
    /// The width of the border around the file bubble.
    public var borderWidth: CGFloat?
    
    /// The color of the border around the file bubble.
    public var borderColor: UIColor?
    
    /// The corner radius style for the file bubble, determining how rounded the corners should be.
    public var cornerRadius: CometChatCornerStyle?
    
    /// The style applied to the avatar displayed in the file bubble.
    public var avatarStyle: AvatarStyle?
    
    /// The style applied to the date label in the file bubble.
    public var dateStyle: DateStyle?
    
    /// The style applied to the message receipt (delivered, read) indicators in the file bubble.
    public var receiptStyle: ReceiptStyle?
    
    /// The color of the title text in the file bubble (e.g., file name).
    public var titleColor = CometChatTheme.neutralColor900
    
    /// The font used for the title text in the file bubble.
    public var titleFont = CometChatTypography.Body.medium
    
    /// The color of the subtitle text in the file bubble (e.g., file size).
    public var subtitleColor = CometChatTheme.neutralColor600
    
    /// The font used for the subtitle text in the file bubble.
    public var subtitleFont = CometChatTypography.Caption2.regular
    
    /// The tint color used for download-related icons in the file bubble.
    public var downloadTintColor = CometChatTheme.primaryColor
    
    /// The style type of the file bubble, either incoming or outgoing.
    /// - `.incoming`: Represents messages received by the user.
    /// - `.outgoing`: Represents messages sent by the user.
    private var styleType: BubbleStyleType = .incoming
    
    /// The reaction style for the reactions displayed on the message bubble
    public var reactionsStyle: ReactionsStyle?

    /// Default initializer for `FileBubbleStyle`.
    public init() { }

    /// Initializes the style of the file bubble based on the type (incoming or outgoing).
    /// - Parameter styleType: The type of the file bubble, used to set default values for colors and styles.
    internal init(styleType: BubbleStyleType) {
        self.styleType = styleType
        
        // Set default styles based on the type of the bubble (incoming or outgoing).
        switch styleType {
        case .incoming:
            titleColor = CometChatTheme.neutralColor900
            subtitleColor = CometChatTheme.neutralColor600
            downloadTintColor = CometChatTheme.primaryColor
        case .outgoing:
            titleColor = CometChatTheme.white
            subtitleColor = CometChatTheme.white
            downloadTintColor = CometChatTheme.white
        }
    }
}
