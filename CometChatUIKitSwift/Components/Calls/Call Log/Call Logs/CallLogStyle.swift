//
//  CometChatCallLogStyle.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 01/12/23.
//

import Foundation

#if canImport(CometChatCallsSDK)
import CometChatCallsSDK

public struct CallLogStyle: ListItemStyle, ListBaseStyle {
    public var listItemTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    public var listItemTitleFont: UIFont = CometChatTypography.Heading4.medium
    
    public var listItemSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    public var listItemSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    public var listItemBackground: UIColor = CometChatTheme.backgroundColor01
    
    public var listItemSelectedBackground: UIColor = CometChatTheme.backgroundColor01
    
    public var listItemBorderWidth: CGFloat = 0
    
    public var listItemBorderColor: UIColor = CometChatTheme.borderColorLight
    
    public var listItemCornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    public var listItemSelectionImageTint: UIColor = .clear
    
    public var listItemDeSelectedImageTint: UIColor = .clear
    
    public var listItemSelectedImage: UIImage = UIImage()
    
    public var listItemDeSelectedImage: UIImage = UIImage()
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    
    public var borderWidth: CGFloat = 0
    
    public var borderColor: UIColor = CometChatTheme.borderColorLight
    
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    public var titleColor: UIColor? = CometChatTheme.textColorPrimary
    
    public var titleFont: UIFont? = CometChatTypography.Heading4.bold
    
    public var largeTitleColor: UIColor? = CometChatTheme.textColorPrimary
    
    public var largeTitleFont: UIFont?
    
    public var navigationBarTintColor: UIColor? = CometChatTheme.backgroundColor01
    
    public var navigationBarItemsTintColor: UIColor? = CometChatTheme.iconColorPrimary
    
    public var errorTitleTextFont: UIFont = CometChatTypography.Heading4.bold
    
    public var errorTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    public var errorSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    public var errorSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    public var retryButtonTextColor: UIColor = CometChatTheme.white
    
    public var retryButtonTextFont: UIFont = CometChatTypography.Button.medium
    
    public var retryButtonBackgroundColor: UIColor = CometChatTheme.primaryColor
    
    public var retryButtonBorderColor: UIColor = .clear
    
    public var retryButtonBorderWidth: CGFloat = 0
    
    public var retryButtonCornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    public var emptyTitleTextFont: UIFont = CometChatTypography.Heading4.bold
    
    public var emptyTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    public var emptySubTitleFont: UIFont = CometChatTypography.Body.regular
    
    public var emptySubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    public var tableViewSeparator: UIColor = .clear
    
    public var backIcon: UIImage?
    
    public var backIconTint: UIColor? = CometChatTheme.iconColorPrimary
    
    public var incomingCallIcon: UIImage? = UIImage(systemName: "arrow.down.left")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var incomingCallIconTint: UIColor? = CometChatTheme.errorColor
    
    public var outgoingCallIcon: UIImage? = UIImage(systemName: "arrow.up.right")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var outgoingCallIconTint: UIColor? = CometChatTheme.successColor
    
    public var missedCallTitleColor: UIColor? = CometChatTheme.errorColor
    
    public var missedCallIcon: UIImage?
    
    public var missedCallIconTint: UIColor? = CometChatTheme.errorColor
    
    public var audioCallIcon: UIImage? = UIImage(systemName: "phone")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var audioCallIconTint: UIColor? = CometChatTheme.iconColorPrimary
    
    public var videoCallIcon: UIImage? = UIImage(systemName: "video")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public  var videoCallIconTint: UIColor? = CometChatTheme.iconColorPrimary
    
    public var separatorColor: UIColor? = .clear
    
}
#endif
