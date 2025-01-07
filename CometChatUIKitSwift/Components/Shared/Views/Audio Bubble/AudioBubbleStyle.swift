//
//  AudioBubbleStyle.swift
//
//
//  Created by Abdullah Ansari on 31/08/22.
//

import UIKit

/// A style configuration struct for customizing the appearance of an audio message bubble in CometChat.
public struct AudioBubbleStyle: BaseMessageBubbleStyle {
    
    /// The text font for the thread count in the audio bubble.
    public var threadedIndicatorTextFont: UIFont?
    
    /// The text color for the thread count in the audio bubble.
    public var threadedIndicatorTextColor: UIColor?
    
    /// The icon tint for the thread count in the audio bubble.
    public var threadedIndicatorImageTint: UIColor?
    
    /// The text color for the header in the audio bubble.
    public var headerTextColor: UIColor?
    
    /// The font used for the header text in the audio bubble.
    public var headerTextFont: UIFont?
    
    /// The background color of the audio message bubble.
    public var backgroundColor: UIColor?
    
    /// An optional background image or drawable for the audio bubble.
    public var backgroundDrawable: UIImage?
    
    /// The border width of the audio bubble.
    public var borderWidth: CGFloat?
    
    /// The border color of the audio bubble.
    public var borderColor: UIColor?
    
    /// The corner radius style for the audio bubble, defined by `CometChatCornerStyle`.
    public var cornerRadius: CometChatCornerStyle?
    
    /// The style configuration for the avatar displayed in the audio bubble.
    public var avatarStyle: AvatarStyle?
    
    /// The style configuration for the date label shown in the audio bubble.
    public var dateStyle: DateStyle?
    
    /// The style configuration for the receipt (like delivery/read receipts) in the audio bubble.
    public var receiptStyle: ReceiptStyle?
    
    /// The type of bubble (incoming or outgoing), used to set default styles based on the type.
    private var styleType: BubbleStyleType = .incoming
    
    // MARK: - Audio Player Specific Styling
    
    /// The tint color for the play button image in the audio bubble.
    public var playImageTintColor: UIColor = CometChatTheme.primaryColor
    
    /// The background color for the play button in the audio bubble.
    public var playImageBackgroundColor: UIColor = CometChatTheme.neutralColor50
    
    /// The tint color for the audio waveform icon inside the audio bubble.
    public var audioWaveFormTintIcon: UIColor = CometChatTheme.primaryColor
    
    /// The font used for the audio timeline label in the audio bubble.
    public var audioTimeLineFont: UIFont = CometChatTypography.Caption1.regular
    
    /// The text color of the audio timeline label.
    public var audioTimeLineTextColor: UIColor = CometChatTheme.neutralColor600
    
    /// The reaction style for the reactions displayed on the message bubble
    public var reactionsStyle: ReactionsStyle?

    // MARK: - Initializers
    
    /// Default initializer for creating an `AudioBubbleStyle` with customizable properties.
    public init() { }
    
    /// Internal initializer for setting default styles based on the bubble type (incoming or outgoing).
    /// - Parameter styleType: The type of the message bubble, which sets specific default styles.
    internal init(styleType: BubbleStyleType) {
        self.styleType = styleType
        
        // Set default styles based on the bubble type (incoming or outgoing)
        switch styleType {
        case .incoming:
            playImageTintColor = CometChatTheme.primaryColor
            playImageBackgroundColor = CometChatTheme.neutralColor50
            audioWaveFormTintIcon = CometChatTheme.primaryColor
            audioTimeLineTextColor = CometChatTheme.neutralColor600
        case .outgoing:
            playImageTintColor = CometChatTheme.primaryColor
            playImageBackgroundColor = CometChatTheme.white
            audioWaveFormTintIcon = CometChatTheme.white
            audioTimeLineTextColor = CometChatTheme.white
        }
    }
}
