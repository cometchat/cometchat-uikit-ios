//
//  ConversationsStyle.swift
//
//
//  Created by Abdullah Ansari on 23/09/22.
//

import UIKit

public struct ConversationsStyle: ListBaseStyle, ListItemStyle {
    
    public var listItemSelectedImage: UIImage = UIImage()
    
    public var listItemDeSelectedImage: UIImage = UIImage()
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    
    public var borderWidth: CGFloat = 0
    
    public var borderColor: UIColor = .clear
    
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    public var titleFont: UIFont?
    
    public var largeTitleFont: UIFont?
    
    public var titleColor: UIColor?
    
    public var largeTitleColor: UIColor?
    
    public var navigationBarTintColor: UIColor? 
    
    public var navigationBarItemsTintColor: UIColor?
    
    public var errorTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    
    public var errorTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    public var errorSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    public var errorSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    public var retryButtonTextColor: UIColor = CometChatTheme.buttonTextColor
    
    public var retryButtonTextFont: UIFont = CometChatTypography.Button.medium
    
    public var retryButtonBackgroundColor: UIColor = CometChatTheme.primaryColor
    
    public var retryButtonBorderColor: UIColor = .clear
    
    public var retryButtonBorderWidth: CGFloat = 0
    
    public var retryButtonCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    
    public var emptyTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    
    public var emptyTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    public var emptySubTitleFont: UIFont = CometChatTypography.Body.regular
    
    public var emptySubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    public var tableViewSeparator: UIColor = .clear
    
    public var listItemTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    public var listItemTitleFont: UIFont = CometChatTypography.Heading4.medium
    
    public var listItemSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    public var listItemSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    public var listItemBackground: UIColor = .clear
    
    public var listItemSelectedBackground: UIColor = .clear
    
    public var listItemBorderWidth: CGFloat = 0
    
    public var listItemBorderColor: UIColor = .clear
    
    public var listItemSelectionImageTint: UIColor = CometChatTheme.backgroundColor03
    
    public var listItemDeSelectedImageTint: UIColor = CometChatTheme.borderColorDefault
    
    public var listItemCornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    public var messageTypeImageTint: UIColor = CometChatTheme.iconColorSecondary
    
    public var passwordGroupImageTintColor: UIColor = CometChatTheme.backgroundColor01
    
    public var passwordGroupImageBackgroundColor: UIColor = CometChatTheme.warningColor

    public var privateGroupImageTintColor: UIColor = CometChatTheme.backgroundColor01
    
    public var privateGroupImageBackgroundColor: UIColor = CometChatTheme.successColor
    
    public var shimmerColor1: UIColor?
    
    public var shimmerColor2: UIColor?
    
}
