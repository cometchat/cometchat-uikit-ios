//
//  CometChatCallLogStyle.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 01/12/23.
//

import Foundation

#if canImport(CometChatCallsSDK)

public struct CallLogStyle: ListItemStyle, ListBaseStyle {
    public var listItemTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    public var listItemTitleFont: UIFont = CometChatTypography.Heading4.medium
    
    /// The row subtitle (call date) colour. A colour set on the screen's `dateStyle` takes precedence.
    public var listItemSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    /// The row subtitle (call date) font. A font set on the screen's `dateStyle` takes precedence.
    public var listItemSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    public var listItemBackground: UIColor = CometChatTheme.backgroundColor01
    
    /// Not applied: call-log rows are never selectable, and a list item paints this only in selection mode. Kept for source compatibility.
    public var listItemSelectedBackground: UIColor = CometChatTheme.backgroundColor01
    
    public var listItemBorderWidth: CGFloat = 0
    
    public var listItemBorderColor: UIColor = CometChatTheme.borderColorLight
    
    public var listItemCornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    /// Not applied: call logs have no selection mode, so rows never show a selection check. Kept for source compatibility.
    public var listItemSelectionImageTint: UIColor = .clear
    
    /// Not applied: call logs have no selection mode, so rows never show a selection check. Kept for source compatibility.
    public var listItemDeSelectedImageTint: UIColor = .clear
    
    /// Not applied: call logs have no selection mode, so rows never show a selection check. Kept for source compatibility.
    public var listItemSelectedImage: UIImage = UIImage()
    
    /// Not applied: call logs have no selection mode, so rows never show a selection check. Kept for source compatibility.
    public var listItemDeSelectedImage: UIImage = UIImage()
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    
    public var borderWidth: CGFloat = 0
    
    public var borderColor: UIColor = CometChatTheme.borderColorLight
    
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    public var titleColor: UIColor? = CometChatTheme.textColorPrimary
    
    public var titleFont: UIFont? = CometChatTypography.setFont(size: 17, weight: .bold)
    
    public var largeTitleColor: UIColor? = CometChatTheme.textColorPrimary
    
    public var largeTitleFont: UIFont? = CometChatTypography.setFont(size: 34, weight: .bold)
    
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
    
    /// Not visible: it is set as the table's `separatorColor`, but the call-log table uses `separatorStyle = .none`, so UIKit draws no separator. Kept for source compatibility.
    public var tableViewSeparator: UIColor = .clear
    
    /// Not applied: the call-log screen's back button is the system navigation back button (tinted by `navigationBarItemsTintColor`); replacing its image would change the whole navigation stack. Kept for source compatibility.
    public var backIcon: UIImage?
    
    /// Not applied: the back button is the system navigation back button, tinted by `navigationBarItemsTintColor`. Kept for source compatibility.
    public var backIconTint: UIColor? = CometChatTheme.iconColorPrimary
    
    public var incomingCallIcon: UIImage? = UIImage(systemName: "arrow.down.left")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var incomingCallIconTint: UIColor? = CometChatTheme.successColor
    
    public var outgoingCallIcon: UIImage? = UIImage(systemName: "arrow.up.right")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var outgoingCallIconTint: UIColor? = CometChatTheme.successColor
    
    public var missedCallTitleColor: UIColor? = CometChatTheme.errorColor
    
    /// An app-supplied `missedCall` asset wins; otherwise the Kit's own missed-call icon.
    public var missedCallIcon: UIImage = (UIImage(named: "missedCall")
        ?? UIImage(named: "missed-audio-call", in: CometChatUIKit.bundle, compatibleWith: nil))?
        .withRenderingMode(.alwaysOriginal) ?? UIImage()
    
    public var missedCallIconTint: UIColor? = CometChatTheme.errorColor
    
    public var audioCallIcon: UIImage? = UIImage(systemName: "phone")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var audioCallIconTint: UIColor? = CometChatTheme.iconColorPrimary
    
    public var videoCallIcon: UIImage? = UIImage(systemName: "video")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public  var videoCallIconTint: UIColor? = CometChatTheme.iconColorPrimary
    
    /// Not applied: call-log rows draw no separator (the table's `separatorStyle` is `.none`). Kept for source compatibility.
    public var separatorColor: UIColor? = .clear
    
    
    public init() { }
    
}
#endif
