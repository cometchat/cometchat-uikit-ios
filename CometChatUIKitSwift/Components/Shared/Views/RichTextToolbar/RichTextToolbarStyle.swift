//
//  RichTextToolbarStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 29/01/26.
//

import UIKit

/// Style configuration for the rich text toolbar
public struct RichTextToolbarStyle {
    
    // MARK: - Container Styling
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor02
    public var borderColor: UIColor = CometChatTheme.borderColorLight
    public var borderWidth: CGFloat = 1
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    
    // MARK: - Button Styling
    public var buttonSize: CGFloat = 30
    public var buttonSpacing: CGFloat = CometChatSpacing.Spacing.s2
    public var buttonCornerRadius: CGFloat = CometChatSpacing.Radius.r1
    
    // MARK: - Icon Styling
    public var iconSize: CGFloat = 20
    public var iconTintColor: UIColor = CometChatTheme.iconColorSecondary
    public var activeIconTintColor: UIColor = CometChatTheme.neutralColor900
    
    // MARK: - Button Background
    public var buttonBackgroundColor: UIColor = .clear
    public var activeButtonBackgroundColor: UIColor = CometChatTheme.neutralColor300
    
    // MARK: - Separator
    public var separatorColor: UIColor = CometChatTheme.neutralColor400
    public var separatorWidth: CGFloat = 1
    public var separatorHeight: CGFloat = 24
    
    // MARK: - Padding
    public var contentPadding: UIEdgeInsets = UIEdgeInsets(
        top: CometChatSpacing.Padding.p2,
        left: CometChatSpacing.Padding.p3,
        bottom: CometChatSpacing.Padding.p2,
        right: CometChatSpacing.Padding.p3
    )
    
    public init() { }
}
