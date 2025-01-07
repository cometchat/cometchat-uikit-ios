//
//  GroupActionBubbleStyle.swift
//  
//
//  Created by Abdullah Ansari on 05/10/22.
//

import Foundation
import UIKit

/// A structure that defines the styling properties for the group action bubble.
public struct GroupActionBubbleStyle {
    
    // MARK: - Properties
    
    /// The background color of the bubble.
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor02
    
    /// An optional image to be used as a drawable background.
    public var backgroundDrawable: UIImage?
    
    /// The width of the bubble's border.
    public var borderWidth: CGFloat = 1
    
    /// The color of the bubble's border.
    public var borderColor: UIColor = CometChatTheme.borderColorDefault
    
    /// The corner radius for rounding the bubble's corners.
    public var cornerRadius: CometChatCornerStyle? = nil
    
    /// The font used for the bubble's text.
    public var bubbleTextFont: UIFont = CometChatTypography.Caption1.regular
    
    /// The color of the bubble's text.
    public var bubbleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    // MARK: - Initializer
    
    /// Creates a new instance of `GroupActionBubbleStyle` with default values.
    public init() { }
}
