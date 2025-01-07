//
//  PollBubbleStyle.swift
//  CometChatUIKit 
//
//  Created by Suryansh Bisen.
//

import UIKit
import Foundation

/// A structure that defines the visual styling for the poll message bubble in CometChat. This style can be customized for incoming and outgoing message bubbles.
public struct PollBubbleStyle: BaseMessageBubbleStyle {
    
    /// The text font for the thread count in the poll bubble.
    public var threadedIndicatorTextFont: UIFont?
    
    /// The text color for the thread count in the poll bubble.
    public var threadedIndicatorTextColor: UIColor?
    
    /// The icon tint for the thread count in the poll  bubble.
    public var threadedIndicatorImageTint: UIColor?

    /// The background color of the poll bubble.
    public var backgroundColor: UIColor?
    
    /// The background image of the poll bubble.
    public var backgroundDrawable: UIImage?
    
    /// The border width for the poll bubble.
    public var borderWidth: CGFloat?
    
    /// The border color for the poll bubble.
    public var borderColor: UIColor?
    
    /// The corner radius style for the poll bubble.
    public var cornerRadius: CometChatCornerStyle?
    
    /// The style for the avatar within the poll bubble.
    public var avatarStyle: AvatarStyle?
    
    /// The style for the date label in the poll bubble.
    public var dateStyle: DateStyle?
    
    /// The style for the receipt in the poll bubble.
    public var receiptStyle: ReceiptStyle?
    
    /// The text color for the poll's header (the question).
    public var headerTextColor: UIColor?
    
    /// The font used for the poll's header (the question).
    public var headerTextFont: UIFont?
    
    /// The font used for the poll text (question).
    public var pollTextFont: UIFont = CometChatTypography.Heading4.bold
    
    /// The color used for the poll text (question).
    public var pollTextColor: UIColor = CometChatTheme.white
    
    /// The tint color used for non-selected poll option images (such as checkmarks or circles).
    public var nonSelectedPollImageTint: UIColor = CometChatTheme.white
    
    /// The tint color used for selected poll option images.
    public var selectedPollImageTint: UIColor = CometChatTheme.white
    
    /// The font used for the poll option text.
    public var optionTextFont: UIFont = CometChatTypography.Body.regular
    
    /// The color used for the poll option text.
    public var optionTextColor: UIColor = CometChatTheme.white
    
    /// The background color for the progress indicator behind poll options.
    public var optionProgressBackgroundColor: UIColor = CometChatTheme.extendedPrimaryColor700
    
    /// The tint color for the progress bar of a poll option.
    public var optionProgressTintColor: UIColor = CometChatTheme.white
    
    /// The corner radius for the poll option progress bars.
    public var optionProgressCornerRadius: CometChatCornerStyle = .init(cornerRadius: 4)
    
    /// The text color for the poll option count (number of votes).
    public var optionCountTextColor: UIColor = CometChatTheme.white
    
    /// The font used for the poll option count text (number of votes).
    public var optionCountTextFont: UIFont = CometChatTypography.Body.regular
    
    /// The style type for the poll bubble (incoming or outgoing).
    private var styleType: BubbleStyleType = .incoming
    
    /// The reaction style for the reactions displayed on the message bubble
    public var reactionsStyle: ReactionsStyle?
    
    // MARK: - Initializers
    
    /// Default initializer for `PollBubbleStyle`.
    public init() {}
    
    /// Initializes the style based on the bubble type (incoming or outgoing).
    /// This sets default colors and styles based on whether the poll bubble is for an incoming or outgoing message.
    /// - Parameter styleType: A `BubbleStyleType` enum that determines if the bubble is incoming or outgoing.
    internal init(styleType: BubbleStyleType) {
        self.styleType = styleType
        
        switch styleType {
        case .incoming:
            pollTextColor = CometChatTheme.neutralColor900
            nonSelectedPollImageTint = CometChatTheme.neutralColor500
            selectedPollImageTint = CometChatTheme.primaryColor
            optionTextColor = CometChatTheme.neutralColor900
            optionProgressBackgroundColor = CometChatTheme.neutralColor400
            optionProgressTintColor = CometChatTheme.primaryColor
            optionCountTextColor = CometChatTheme.neutralColor900
            
        case .outgoing:
            pollTextColor = CometChatTheme.white
            nonSelectedPollImageTint = CometChatTheme.white
            selectedPollImageTint = CometChatTheme.white
            optionTextColor = CometChatTheme.white
            optionProgressBackgroundColor = CometChatTheme.extendedPrimaryColor700
            optionProgressTintColor = CometChatTheme.white
            optionCountTextColor = CometChatTheme.white
        }
    }
}
