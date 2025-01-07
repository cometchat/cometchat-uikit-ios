//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 08/03/23.
//

import UIKit

public struct IncomingCallStyle {

    public var overlayBackgroundColor: UIColor = UIColor.dynamicColor(
        lightModeColor: CometChatTheme.black.withAlphaComponent(0.2),
        darkModeColor: CometChatTheme.white.withAlphaComponent(0.2)
    )
    public var acceptButtonBackgroundColor: UIColor = CometChatTheme.successColor
    public var rejectButtonBackgroundColor: UIColor = CometChatTheme.errorColor
    public var acceptButtonCornerRadius: CometChatCornerStyle? = nil
    public var rejectButtonCornerRadius: CometChatCornerStyle? = nil
    public var acceptButtonBorderColor: UIColor = .clear
    public var rejectButtonBorderColor: UIColor = .clear
    public var acceptButtonBorderWidth: CGFloat = 0
    public var rejectButtonBorderWidth: CGFloat = 0
    public var acceptButtonTintColor: UIColor = CometChatTheme.white
    public var rejectButtonTintColor: UIColor = CometChatTheme.white
    public var acceptButtonImage: UIImage = UIImage(systemName: "phone.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var rejectButtonImage: UIImage = UIImage(systemName: "phone.down.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    public var cornerRadius: CometChatCornerStyle?
    public var borderColor: UIColor = .clear
    public var borderWidth: CGFloat = 0
    public var callLabelColor: UIColor = CometChatTheme.textColorSecondary
    public var callLabelFont: UIFont = CometChatTypography.Heading4.regular
    public var nameLabelColor: UIColor = CometChatTheme.textColorPrimary
    public var nameLabelFont: UIFont = CometChatTypography.Heading2.bold
    
    public init() {}
    
    
}
