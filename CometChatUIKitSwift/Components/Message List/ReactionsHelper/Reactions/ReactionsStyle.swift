//
//  ReactionStyle.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 29/02/24.
//

import Foundation
import UIKit

/// `ReactionsStyle` is a configuration struct that defines the visual appearance of the
/// reactions view in the chat interface. It includes properties for customizing borders,
/// background colors, fonts, and more to ensure a consistent look and feel throughout the app.
public struct ReactionsStyle {
    
    /// The width of the border surrounding the reactions view.
    public var borderWidth: CGFloat = 1.5
    
    /// The color of the border surrounding the reactions view.
    public var borderColor: UIColor = CometChatTheme.backgroundColor02
    
    /// The corner radius for rounding the corners of the reactions view.
    /// If nil, the default corner radius will be used.
    public var cornerRadius: CometChatCornerStyle? = nil
    
    /// The background color of the reactions view.
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    
    /// The font used for displaying the emoji in the reactions view.
    public var emojiTextFont: UIFont = CometChatTypography.Caption1.regular
    
    /// The color of the emoji text in the reactions view.
    public var emojiTextColor: UIColor = CometChatTheme.textColorPrimary
    
    /// The font used for displaying the count of reactions.
    public var countTextFont: UIFont = CometChatTypography.Caption1.regular
    
    /// The color of the count text in the reactions view.
    public var countTextColor: UIColor = CometChatTheme.textColorPrimary
    
    /// The background color of the reactions view when the reaction has been actively chosen by the user.
    public var activeReactionBackgroundColor: UIColor = CometChatTheme.extendedPrimaryColor100
    
    /// The width of the border surrounding the reactions view when an active reaction is present.
    public var activeReactionBorderWidth: CGFloat = 1
    
    /// The color of the border surrounding the reactions view when an active reaction is present.
    public var activeReactionBorderColor: UIColor = CometChatTheme.extendedPrimaryColor300
    
    /// The spacing between the emoji and count labels within the reactions view.
    public var reactionSpacing: Double = CometChatSpacing.Padding.p1
    
    // public var reactionShadow: ShadowStyle?

    /// Initializes a new `ReactionsStyle` with default values.
    public init() {}
}


