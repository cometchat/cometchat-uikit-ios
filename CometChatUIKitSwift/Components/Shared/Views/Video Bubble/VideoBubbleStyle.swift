//
//  VideoBubbleStyle.swift
 
//
//  Created by Abdullah Ansari on 23/05/22.
//

import Foundation
import UIKit

public struct VideoBubbleStyle: BaseMessageBubbleStyle {
    public var threadedIndicatorTextFont: UIFont?
    
    public var threadedIndicatorTextColor: UIColor?
    
    public var threadedIndicatorImageTint: UIColor?
    
    
    public var headerTextColor: UIColor?
    
    public var headerTextFont: UIFont?

    /// The background color of the video bubble.
    public var backgroundColor: UIColor?

    /// The background image or drawable for the video bubble.
    public var backgroundDrawable: UIImage?

    /// The width of the border around the video bubble.
    public var borderWidth: CGFloat?

    /// The color of the border around the video bubble.
    public var borderColor: UIColor?

    /// The corner radius style for the video bubble.
    public var cornerRadius: CometChatCornerStyle?

    /// The avatar style for the avatar displayed in the video bubble.
    public var avatarStyle: AvatarStyle?

    /// The style applied to the date label in the video bubble.
    public var dateStyle: DateStyle?

    /// The style applied to the receipt status (sent, delivered, read) in the video bubble.
    public var receiptStyle: ReceiptStyle?

    /// Tint color for the play icon overlay on the video thumbnail.
    public var playButtonTint: UIColor = CometChatTheme.white

    /// Background color for the play icon overlay on the video thumbnail.
    public var playButtonBackgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.08, alpha: 0.60)

    /// Stroke width for the border around the video thumbnail.
    public var videoBorderWidth: CGFloat = 0

    /// Corner radius for the video thumbnail's border.
    public var videoCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)

    /// Internal storage for the video stroke color.
    public var videoBorderColor: UIColor = .clear

    /// Defines whether the video bubble is incoming or outgoing.
    private var styleType: BubbleStyleType = .incoming
    
    /// The reaction style for the reactions displayed in the video bubble.
    public var reactionsStyle: ReactionsStyle?

    /// Initializes the video bubble style with default values.
    public init() { }

    /// Internal initializer to set default values based on the bubble's style type (incoming or outgoing).
    internal init(styleType: BubbleStyleType) {
        self.styleType = styleType
    }
}

