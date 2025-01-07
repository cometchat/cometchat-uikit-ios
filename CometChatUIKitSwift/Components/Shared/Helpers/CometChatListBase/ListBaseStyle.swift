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
