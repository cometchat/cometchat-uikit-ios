import Foundation
import UIKit

public struct MessageInformationStyle: ListItemStyle {

    public var titleColor: UIColor?
    public var titleFont: UIFont?
    public var largeTitleColor: UIColor?
    public var largeTitleFont: UIFont? = CometChatTypography.Heading1.bold
    public var navigationBarTintColor: UIColor?
    public var navigationBarItemsTintColor: UIColor?
    /// Not applied: the receipts table hides its separators (`separatorStyle = .none`). Kept for source compatibility.
    public var tableViewSeparator: UIColor = .clear

    /// Defaults to `.label`, the colour the receipt title drew before it was wired to this style.
    public var listItemTitleTextColor: UIColor = .label
    /// Defaults to the 17pt system font the receipt title drew before it was wired to this style.
    public var listItemTitleFont: UIFont = UIFont.systemFont(ofSize: 17)
    public var listItemSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    public var listItemSubTitleFont: UIFont = CometChatTypography.Body.regular
    public var listItemBackground: UIColor = .clear
    public var listItemBorderWidth: CGFloat = 0
    public var listItemBorderColor: UIColor = .clear
    public var listItemCornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    /// Not applied: receipt rows are not selectable, so the selection check is never shown. Kept for source compatibility.
    public var listItemSelectionImageTint: UIColor = .clear
    /// Not applied: receipt rows are not selectable, so no selected background is painted. Kept for source compatibility.
    public var listItemSelectedBackground: UIColor = .clear
    /// Not applied: receipt rows are not selectable, so the selection check is never shown. Kept for source compatibility.
    public var listItemDeSelectedImageTint: UIColor = .clear
    /// Not applied: receipt rows are not selectable, so the selection check is never shown. Kept for source compatibility.
    public var listItemSelectedImage: UIImage = UIImage()
    /// Not applied: receipt rows are not selectable, so the selection check is never shown. Kept for source compatibility.
    public var listItemDeSelectedImage: UIImage = UIImage()

    public var cornerRadius: CometChatCornerStyle?
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01

    public var bubbleContainerBackgroundColor: UIColor = CometChatTheme.backgroundColor02
    public var bubbleContainerBorderWidth: CGFloat = 0
    public var bubbleContainerBorderColor: UIColor = .clear
    public var bubbleContainerCornerRadius: CometChatCornerStyle?

    public var errorStateTextColor: UIColor = CometChatTheme.textColorSecondary
    public var errorStateTextFont: UIFont = CometChatTypography.Body.regular

    public var emptyStateTextColor: UIColor = CometChatTheme.textColorSecondary
    public var emptyStateTextFont: UIFont = CometChatTypography.Body.regular

}
