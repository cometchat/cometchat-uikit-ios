//
//  CallButtonStyle.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 10/11/24.
//

import UIKit

public struct CallButtonStyle {
    
    public var videoCallIconTint = CometChatTheme.iconColorPrimary
    public var videoCallTextFont = CometChatTypography.Body.regular
    public var videoCallTextColor = CometChatTheme.iconColorPrimary
    public var videoCallButtonBackground: UIColor = .clear
    public var videoCallButtonCornerRadius: CometChatCornerStyle?
    public var videoCallButtonBorder: CGFloat?
    public var videoCallButtonBorderColor: UIColor?
    public var videoCallIcon = UIImage(systemName: "video")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public var audioCallIconTint = CometChatTheme.iconColorPrimary
    public var audioCallTextFont = CometChatTypography.Body.regular
    public var audioCallTextColor = CometChatTheme.iconColorPrimary
    public var audioCallButtonBackground: UIColor = .clear
    public var audioCallButtonCornerRadius: CometChatCornerStyle?
    public var audioCallButtonBorder: CGFloat?
    public var audioCallButtonBorderColor: UIColor?
    public var audioCallIcon = UIImage(systemName: "phone")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
}
