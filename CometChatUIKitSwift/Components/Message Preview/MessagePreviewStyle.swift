//
//  MessagePreviewStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 17/11/25.
//

import Foundation

public struct MessagePreviewStyle {

    public var backgroundColor: UIColor = CometChatTheme.backgroundColor03
    public var borderColor: UIColor = .clear
    public var borderWidth: CGFloat = 0
    public var cornerRadius: CometChatCornerStyle? = nil
    public var titleTextFont = CometChatTypography.Caption1.medium
    public var titleTextColor: UIColor = CometChatTheme.textColorHighlight
    public var subtitleTextFont = CometChatTypography.Caption1.regular
    public var subtitleTextColor: UIColor = CometChatTheme.textColorSecondary
    public var subtitleImageTintColor: UIColor = CometChatTheme.iconColorSecondary
    public var indicatorViewBackgroundColor: UIColor = CometChatTheme.borderColorHighlight
    public var previewCloseIcon: UIImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public init() {  }
    
}
