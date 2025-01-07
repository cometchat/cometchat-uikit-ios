import Foundation
import UIKit

public struct MessageInformationStyle: ListItemStyle {
    
    public var titleColor: UIColor?
    public var titleFont: UIFont?
    public var largeTitleColor: UIColor?
    public var largeTitleFont: UIFont? = CometChatTypography.Heading1.bold
    public var navigationBarTintColor: UIColor?
    public var navigationBarItemsTintColor: UIColor?
    public var tableViewSeparator: UIColor = .clear
    
    public var listItemTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    public var listItemTitleFont: UIFont = CometChatTypography.Heading2.bold
    public var listItemSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    public var listItemSubTitleFont: UIFont = CometChatTypography.Body.regular
    public var listItemBackground: UIColor = .clear
    public var listItemBorderWidth: CGFloat = 0
    public var listItemBorderColor: UIColor = .clear
    public var listItemCornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    public var listItemSelectionImageTint: UIColor = .clear
    public var listItemSelectedBackground: UIColor = .clear
    public var listItemDeSelectedImageTint: UIColor = .clear
    public var listItemSelectedImage: UIImage = UIImage()
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
