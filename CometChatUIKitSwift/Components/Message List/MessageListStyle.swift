//
//  MessageListStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public struct MessageListStyle {
    
    public var backgroundColor = UIColor.dynamicColor(
        lightModeColor: CometChatTheme.backgroundColor03.resolvedColor(with: UITraitCollection(userInterfaceStyle: .light)),
        darkModeColor: CometChatTheme.backgroundColor02.resolvedColor(with: UITraitCollection(userInterfaceStyle: .dark))
    )
    public var borderWidth: CGFloat = CGFloat(0)
    public var borderColor: UIColor = .clear
    public var cornerRadius: CometChatCornerStyle?
    public var shimmerGradientColor1: UIColor = CometChatTheme.backgroundColor04
    public var shimmerGradientColor2: UIColor = CometChatTheme.backgroundColor03
    
    public var emptyStateTitleColor: UIColor = CometChatTheme.textColorPrimary
    public var emptyStateTitleFont: UIFont = CometChatTypography.Heading3.bold
    public var emptyStateSubtitleColor: UIColor = CometChatTheme.textColorSecondary
    public var emptyStateSubtitleFont: UIFont = CometChatTypography.Body.regular
    
    public var errorStateTitleColor: UIColor = CometChatTheme.textColorPrimary
    public var errorStateTitleFont: UIFont = CometChatTypography.Heading3.bold
    public var errorStateSubtitleColor: UIColor = CometChatTheme.textColorSecondary
    public var errorStateSubtitleFont: UIFont = CometChatTypography.Body.regular

    public var threadedMessageImage = UIImage(systemName: "arrow.turn.down.right")?.withRenderingMode(.alwaysTemplate)
    public var errorImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    public var emptyImage = UIImage(named: "empty-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
    public var newMessageIndicatorImage: UIImage?
    
    public var backgroundImage: UIImage?

    
    public init() {  }
}
