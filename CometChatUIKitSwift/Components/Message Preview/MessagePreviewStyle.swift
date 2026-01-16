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
    internal var _titleTextColor: UIColor?
    public var titleTextColor: UIColor {
        get { _titleTextColor ?? CometChatTheme.textColorHighlight }
        set { _titleTextColor = newValue }
    }
    public var subtitleTextFont = CometChatTypography.Caption1.regular
    public var subtitleTextColor: UIColor = CometChatTheme.textColorSecondary
    public var subtitleImageTintColor: UIColor = CometChatTheme.iconColorSecondary
    internal var _indicatorViewBackgroundColor: UIColor?
    public var indicatorViewBackgroundColor: UIColor {
        get { _indicatorViewBackgroundColor ?? CometChatTheme.borderColorHighlight }
        set { _indicatorViewBackgroundColor = newValue }
    }
    public var previewCloseIcon: UIImage = UIImage(systemName: "xmark")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    public init() {  }
    
}
