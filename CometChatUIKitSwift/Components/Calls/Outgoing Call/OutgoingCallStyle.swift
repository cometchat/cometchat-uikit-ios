//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 08/03/23.
//

import UIKit

public struct OutgoingCallStyle {
    public var backgroundColor = CometChatTheme.backgroundColor03
    public var borderColor: UIColor = .clear
    public var borderWidth: CGFloat = 0
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    public var nameTextColor = CometChatTheme.textColorPrimary
    public var nameTextFont = CometChatTypography.Heading1.bold
    public var callTextColor = CometChatTheme.textColorSecondary
    public var callTextFont = CometChatTypography.Body.regular
    public var declineButtonBackgroundColor = CometChatTheme.errorColor
    public var declineButtonIconTint = CometChatTheme.white
    public var declineButtonIcon = UIImage(systemName: "phone.down.fill")
    public var declineButtonCornerRadius: CometChatCornerStyle? = nil
    public var declineButtonBorderWidth: CGFloat = 0
    public var declineButtonBorderColor: UIColor = .clear
}
