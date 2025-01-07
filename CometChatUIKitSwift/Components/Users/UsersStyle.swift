//
//  UsersStyle.swift
//  
//
//  Created by Abdullah Ansari on 24/08/22.
//

import UIKit

public struct UsersStyle: ListBaseStyle, ListItemStyle, SearchBarStyle {
    
    // Check box image when list item is selected
    public var listItemSelectedImage: UIImage = UIImage(systemName: "checkmark.square.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    // Check box image when list item is deselected
    public var listItemDeSelectedImage: UIImage = UIImage(systemName: "square")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    // Tint color for the search icon in the search bar
    public var searchIconTintColor: UIColor?
    
    // Style of the UISearchBar (e.g., default, prominent)
    public var searchBarStyle: UISearchBar.Style = .default
    
    // Tint color for the search bar elements
    public var searchTintColor: UIColor?
    
    // Background color for the search bar (excluding text input area)
    public var searchBarTintColor: UIColor?
    
    // Color of the placeholder text in the search bar
    public var searchBarPlaceholderTextColor: UIColor?
    
    // Font of the placeholder text in the search bar
    public var searchBarPlaceholderTextFont: UIFont?
    
    // Color of the entered text in the search bar
    public var searchBarTextColor: UIColor?
    
    // Font of the entered text in the search bar
    public var searchBarTextFont: UIFont?
    
    // Background color of the search bar's text input area
    public var searchBarBackgroundColor: UIColor?
    
    // Tint color for the cancel button in the search bar
    public var searchBarCancelIconTintColor: UIColor?
    
    // Tint color for the clear (cross) button in the search bar
    public var searchBarCrossIconTintColor: UIColor?
        
    // Background color for the entire screen or view
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    
    // Border width for the search bar or container
    public var borderWidth: CGFloat = 0
    
    // Color of the border, default is clear
    public var borderColor: UIColor = .clear
    
    // Corner radius for search bar or other elements
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    // Text color for title elements within the list or navigation bar
    public var titleColor: UIColor? = CometChatTheme.textColorPrimary
    
    // Font for title text
    public var titleFont: UIFont? 
    
    // Text color for large titles (i.e., navigation large titles)
    public var largeTitleColor: UIColor? = CometChatTheme.textColorPrimary
    
    // Font for large titles
    public var largeTitleFont: UIFont?
    
    // Tint color for the navigation bar background
    public var navigationBarTintColor: UIColor? = CometChatTheme.backgroundColor01
    
    // Tint color for navigation bar items (buttons, icons)
    public var navigationBarItemsTintColor: UIColor? = CometChatTheme.iconColorHighlight
    
    // Font for the error title displayed in UI
    public var errorTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    
    // Text color for the error title
    public var errorTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    // Font for the subtitle of error messages
    public var errorSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    // Text color for the subtitle of error messages
    public var errorSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    // Text color for the retry button in error states
    public var retryButtonTextColor: UIColor = CometChatTheme.buttonTextColor
    
    // Font for the retry button text
    public var retryButtonTextFont: UIFont = CometChatTypography.Button.medium
    
    // Background color for the retry button
    public var retryButtonBackgroundColor: UIColor = CometChatTheme.primaryColor
    
    // Border color for the retry button
    public var retryButtonBorderColor: UIColor = .clear
    
    // Border width for the retry button
    public var retryButtonBorderWidth: CGFloat = 0
    
    // Corner radius for the retry button
    public var retryButtonCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    
    // Font for the empty state title (when no users/items are present)
    public var emptyTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    
    // Text color for the empty state title
    public var emptyTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    // Font for the subtitle in the empty state
    public var emptySubTitleFont: UIFont = CometChatTypography.Body.regular
    
    // Text color for the subtitle in the empty state
    public var emptySubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    // Color for the table view separator
    public var tableViewSeparator: UIColor = .clear
    
    // Text color for list item titles
    public var listItemTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    // Font for list item titles
    public var listItemTitleFont: UIFont = CometChatTypography.Heading4.medium
    
    // Text color for list item subtitles
    public var listItemSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    // Font for list item subtitles
    public var listItemSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    // Background color for individual list items
    public var listItemBackground: UIColor = .clear
    
    // Border width for individual list items
    public var listItemBorderWidth: CGFloat = 0
    
    // Border color for individual list items
    public var listItemBorderColor: UIColor = CometChatTheme.borderColorLight
    
    // Corner radius for list items
    public var listItemCornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    // Tint color for selection indicator in list items
    public var listItemSelectionImageTint: UIColor = CometChatTheme.iconColorHighlight
    
    public var listItemSelectedBackground: UIColor = .clear
    
    public var listItemDeSelectedImageTint: UIColor = CometChatTheme.borderColorDefault
        
    // Text color for section header titles in the list
    public var headerTitleColor: UIColor? = CometChatTheme.textColorHighlight
    
    // Font for section header titles
    public var headerTitleFont: UIFont? = CometChatTypography.Heading4.medium
}

