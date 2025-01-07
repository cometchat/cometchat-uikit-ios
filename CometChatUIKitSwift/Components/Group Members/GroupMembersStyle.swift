//
//  GroupMembersStyle.swift
 
//
//  Created by Pushpsen Airekar on 22/11/22.
//
import Foundation
import UIKit
import CometChatSDK

public struct GroupMembersStyle: ListBaseStyle, ListItemStyle {
    public var retryButtonTextColor: UIColor = CometChatTheme.buttonTextColor
    
    public var retryButtonTextFont: UIFont = CometChatTypography.Button.medium
    
    public var retryButtonBackgroundColor: UIColor = CometChatTheme.primaryColor
    
    public var retryButtonBorderColor: UIColor = .clear
    
    public var retryButtonBorderWidth: CGFloat = 0
    
    public var retryButtonCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    
    public var listItemSelectedBackground: UIColor = CometChatTheme.backgroundColor04
    
    public var listItemDeSelectedImageTint: UIColor = CometChatTheme.borderColorDefault
    
    public var listItemSelectionImageTint: UIColor = CometChatTheme.primaryColor
    
    public var listItemSelectedImage: UIImage = UIImage(systemName: "checkmark.square.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var listItemDeSelectedImage: UIImage = UIImage(systemName: "square")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    
    public var borderWidth: CGFloat = 0
    
    public var borderColor: UIColor = .clear
    
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    public var titleFont: UIFont?
    
    public var largeTitleFont: UIFont?
    
    public var titleColor: UIColor?
    
    public var largeTitleColor: UIColor?
    
    public var navigationBarTintColor: UIColor? = CometChatTheme.backgroundColor01
    
    public var navigationBarItemsTintColor: UIColor?
    
    public var errorTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    
    public var errorTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    public var errorSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    public var errorSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
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
    
    public var listItemBorderWidth: CGFloat = 0
    
    public var listItemBorderColor: UIColor = .clear
    
    public var listItemCornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    public var messageTypeImageTint: UIColor = CometChatTheme.iconColorSecondary
    
    public var passwordGroupImageTintColor: UIColor = CometChatTheme.backgroundColor01
    
    public var passwordGroupImageBackgroundColor: UIColor = CometChatTheme.warningColor

    public var privateGroupImageTintColor: UIColor = CometChatTheme.backgroundColor01
    
    public var privateGroupImageBackgroundColor: UIColor = CometChatTheme.successColor
    
}

