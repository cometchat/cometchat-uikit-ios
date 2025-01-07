//
//  MessageHeaderStyle.swift
//
//
//  Created by Abdullah Ansari on 25/08/22.
//

import UIKit

public struct MessageHeaderStyle {
    
    public var titleTextColor = CometChatTheme.textColorPrimary
    public var titleTextFont = CometChatTypography.Heading4.bold
    public var subtitleTextColor = CometChatTheme.textColorSecondary
    public var subtitleTextFont:UIFont = CometChatTypography.Caption1.regular
    public var backButtonImageTintColor = CometChatTheme.iconColorPrimary
    public var privateGroupBadgeImageTintColor : UIColor = CometChatTheme.backgroundColor01
    public var passwordProtectedGroupBadgeImageTintColor : UIColor = CometChatTheme.backgroundColor01
    public var passwordGroupImageBackgroundColor: UIColor = CometChatTheme.warningColor
    public var privateGroupImageBackgroundColor: UIColor = CometChatTheme.successColor
    public var groupImageBackgroundColor : UIColor = .clear
    public var avatarStyle : AvatarStyle = CometChatAvatar.style
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var cornerRadius: CometChatCornerStyle? = nil
    public var borderWidth: CGFloat = 0
    public var borderColor: UIColor = .clear
    public var backButtonIcon = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate)
    public var privateGroupIcon = UIImage(systemName: "shield.fill")?.withRenderingMode(.alwaysTemplate)
    public var protectedGroupIcon = UIImage(systemName: "lock.fill")?.withRenderingMode(.alwaysTemplate)
    public var backgroundImage: UIImage?
  
    public init() {}
}
