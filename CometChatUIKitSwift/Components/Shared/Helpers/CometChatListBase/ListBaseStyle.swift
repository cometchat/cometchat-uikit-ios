//
//  ListBaseStyle.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 27/09/24.
//

import UIKit
import Foundation

public protocol ListBaseStyle {
    var backgroundColor: UIColor { get set }
    var borderWidth: CGFloat { get set }
    var borderColor: UIColor { get set }
    var cornerRadius: CometChatCornerStyle { get set }
    
    var titleColor: UIColor? { get set }
    var titleFont: UIFont? { get set }
    var largeTitleColor: UIColor? { get set }
    var largeTitleFont: UIFont? { get set }
    var navigationBarTintColor: UIColor? { get set }
    var navigationBarItemsTintColor: UIColor? { get set }
    
    var errorTitleTextFont: UIFont { get set }
    var errorTitleTextColor: UIColor { get set }
    var errorSubTitleFont: UIFont { get set }
    var errorSubTitleTextColor: UIColor { get set }
    var retryButtonTextColor: UIColor { get set }
    var retryButtonTextFont: UIFont { get set }
    var retryButtonBackgroundColor: UIColor { get set }
    var retryButtonBorderColor: UIColor { get set }
    var retryButtonBorderWidth:  CGFloat { get set }
    var retryButtonCornerRadius: CometChatCornerStyle { get set }
    var emptyTitleTextFont: UIFont { get set }
    var emptyTitleTextColor: UIColor { get set }
    var emptySubTitleFont: UIFont { get set }
    var emptySubTitleTextColor: UIColor { get set }
    var tableViewSeparator: UIColor { get set }
}

/// The neutral, theme-based style `CometChatListBase` starts with, used until a
/// subclass assigns its own component style.
struct DefaultListBaseStyle: ListBaseStyle {
    var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    var borderWidth: CGFloat = 0
    var borderColor: UIColor = .clear
    var cornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    var titleColor: UIColor? = CometChatTheme.textColorPrimary
    var titleFont: UIFont? = CometChatTypography.setFont(size: 17, weight: .bold)
    var largeTitleColor: UIColor? = CometChatTheme.textColorPrimary
    var largeTitleFont: UIFont? = CometChatTypography.setFont(size: 34, weight: .bold)
    var navigationBarTintColor: UIColor?
    var navigationBarItemsTintColor: UIColor?
    
    var errorTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    var errorTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    var errorSubTitleFont: UIFont = CometChatTypography.Body.regular
    var errorSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    var retryButtonTextColor: UIColor = CometChatTheme.buttonTextColor
    var retryButtonTextFont: UIFont = CometChatTypography.Button.medium
    var retryButtonBackgroundColor: UIColor = CometChatTheme.primaryColor
    var retryButtonBorderColor: UIColor = .clear
    var retryButtonBorderWidth: CGFloat = 0
    var retryButtonCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    var emptyTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    var emptyTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    var emptySubTitleFont: UIFont = CometChatTypography.Body.regular
    var emptySubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    var tableViewSeparator: UIColor = CometChatTheme.borderColorLight
}

public protocol SearchBarStyle {
    
    var searchTintColor: UIColor? { get set }
    var searchBarTintColor: UIColor? { get set }
    var searchBarStyle: UISearchBar.Style { get set }
    var searchBarPlaceholderTextColor: UIColor? { get set }
    var searchBarPlaceholderTextFont: UIFont? { get set }
    var searchBarTextColor: UIColor? { get set }
    var searchBarTextFont: UIFont? { get set }
    var searchBarBackgroundColor: UIColor? { get set }
    var searchBarCancelIconTintColor: UIColor? { get set }
    var searchBarCrossIconTintColor: UIColor? { get set }
    var searchIconTintColor: UIColor? { get set }
    
    
}
