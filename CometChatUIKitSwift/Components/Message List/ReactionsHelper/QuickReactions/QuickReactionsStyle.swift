//
//  QuickReactionStyle .swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 29/02/24.
//

import UIKit
import Foundation

/// `QuickReactionsStyle` struct allows customization of the appearance and style
/// for the `CometChatQuickReactions` component. It provides properties for
/// modifying the look of reaction buttons, the plus icon, and the container's overall styling.
public struct QuickReactionsStyle {

    /// Background color for the "plus" icon that allows users to add more reactions.
    public var plusIconBackgroundColor: UIColor = CometChatTheme.backgroundColor03

    /// Tint color for the "plus" icon (applied to the symbol, typically).
    public var plusIconTintColor: UIColor = CometChatTheme.iconColorSecondary

    /// Corner radius for the "plus" icon's background, enabling rounded corners for a custom look.
    public var plusIconCornerRadius: CometChatCornerStyle? = nil

    /// Background color for each individual reaction button.
    public var reactionsBackgroundColor: UIColor = .clear

    /// Font style used for displaying the emoji inside the reaction buttons.
    public var reactionFont: UIFont = CometChatTypography.Heading2.regular

    /// Corner radius for the reaction buttons, allowing for rounded button corners.
    public var reactionCornerRadius: CometChatCornerStyle = CometChatCornerStyle(cornerRadius: 0)

    /// Boolean to determine whether the "add reaction" icon (plus button) should be hidden.
    public var hideAddReactionsIcon: Bool = false

    /// Background color of the entire `CometChatQuickReactions` view.
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01

    /// Width of the border around the `CometChatQuickReactions` view, applied globally.
    public var borderWidth: CGFloat = 1

    /// Color of the border surrounding the `CometChatQuickReactions` view.
    public var borderColor: UIColor = CometChatTheme.borderColorLight

    /// Corner radius for the overall `CometChatQuickReactions` container, enabling rounded corners.
    public var cornerRadius: CometChatCornerStyle? = nil

    /// Default initializer for `QuickReactionsStyle`, providing default styles.
    public init() { }
}

