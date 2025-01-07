//
//  GroupsStyle.swift
 
//
//  Created by Abdullah Ansari on 30/08/22.
//

import UIKit

// A structure defining the styling options for the Groups feature, conforming to ListBaseStyle, ListItemStyle, and SearchBarStyle protocols.
public struct GroupsStyle: ListBaseStyle, ListItemStyle, SearchBarStyle {
    
    // Check box image when list item is selected
    public var listItemSelectedImage: UIImage = UIImage(systemName: "checkmark.square.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    // Check box image when list item is deselected
    public var listItemDeSelectedImage: UIImage = UIImage(systemName: "square")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    // Color for the search icon's tint, defaults to the secondary icon color from CometChatTheme.
    public var searchIconTintColor: UIColor? = nil
    
    // The style of the search bar, defaulting to the standard style.
    public var searchBarStyle: UISearchBar.Style = .default
    
    // Tint color for the search bar, defaults to the primary color from CometChatTheme.
    public var searchTintColor: UIColor? = nil
    
    // Background color of the search bar, defaulting to clear.
    public var searchBarTintColor: UIColor? = nil
    
    // Placeholder text color for the search bar, defaults to the tertiary text color from CometChatTheme.
    public var searchBarPlaceholderTextColor: UIColor? = nil
    
    // Font used for the placeholder text in the search bar, defaults to regular body font.
    public var searchBarPlaceholderTextFont: UIFont? = nil
    
    // Color of the text entered in the search bar, defaults to the primary text color from CometChatTheme.
    public var searchBarTextColor: UIColor? = nil
    
    // Font used for the text in the search bar, defaults to regular body font.
    public var searchBarTextFont: UIFont? = nil
    
    // Background color of the search bar, defaults to a specific background color from CometChatTheme.
    public var searchBarBackgroundColor: UIColor? = nil
    
    // Tint color for the cancel icon in the search bar, defaults to the primary color from CometChatTheme.
    public var searchBarCancelIconTintColor: UIColor? = nil
    
    // Tint color for the cross icon in the search bar, defaults to the secondary icon color from CometChatTheme.
    public var searchBarCrossIconTintColor: UIColor? = nil
    
    // Background color of the overall view, defaults to a specific background color from CometChatTheme.
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor01
    
    // Width of the border around the view, defaults to 0 (no border).
    public var borderWidth: CGFloat = 0
    
    // Color of the border around the view, defaults to clear.
    public var borderColor: UIColor = .clear
    
    // Corner radius settings for the view, defaults to no corner radius.
    public var cornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    // Color for the title text, defaults to the primary text color from CometChatTheme.
    public var titleColor: UIColor? = CometChatTheme.textColorPrimary
    
    // Font used for the title text, defaults to nil (not set).
    public var titleFont: UIFont?
    
    // Color for the large title text, defaults to the primary text color from CometChatTheme.
    public var largeTitleColor: UIColor? = CometChatTheme.textColorPrimary
    
    // Font used for the large title text, defaults to nil (not set).
    public var largeTitleFont: UIFont?
    
    // Background color of the navigation bar, defaults to a specific background color from CometChatTheme.
    public var navigationBarTintColor: UIColor? = CometChatTheme.backgroundColor01
    
    // Tint color for items in the navigation bar, defaults to the highlight color from CometChatTheme.
    public var navigationBarItemsTintColor: UIColor? = CometChatTheme.iconColorHighlight
    
    // Font used for the error title text, defaults to a bold heading 3 font from CometChatTypography.
    public var errorTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    
    // Color of the error title text, defaults to the primary text color from CometChatTheme.
    public var errorTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    // Font used for the error subtitle text, defaults to regular body font.
    public var errorSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    // Color of the error subtitle text, defaults to the secondary text color from CometChatTheme.
    public var errorSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    // Color for the retry button text, defaults to button text color from CometChatTheme.
    public var retryButtonTextColor: UIColor = CometChatTheme.buttonTextColor
    
    // Font used for the retry button text, defaults to medium button font from CometChatTypography.
    public var retryButtonTextFont: UIFont = CometChatTypography.Button.medium
    
    // Background color for the retry button, defaults to the primary color from CometChatTheme.
    public var retryButtonBackgroundColor: UIColor = CometChatTheme.primaryColor
    
    // Border color for the retry button, defaults to clear.
    public var retryButtonBorderColor: UIColor = .clear
    
    // Width of the border around the retry button, defaults to 0 (no border).
    public var retryButtonBorderWidth: CGFloat = 0
    
    // Corner radius settings for the retry button, defaults to a specific corner radius from CometChatSpacing.
    public var retryButtonCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    
    // Font used for the empty state title text, defaults to a bold heading 3 font from CometChatTypography.
    public var emptyTitleTextFont: UIFont = CometChatTypography.Heading3.bold
    
    // Color of the empty state title text, defaults to the primary text color from CometChatTheme.
    public var emptyTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    // Font used for the empty state subtitle text, defaults to regular body font.
    public var emptySubTitleFont: UIFont = CometChatTypography.Body.regular
    
    // Color of the empty state subtitle text, defaults to the secondary text color from CometChatTheme.
    public var emptySubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    // Color of the table view separator, defaults to clear.
    public var tableViewSeparator: UIColor = .clear
    
    // Color of the title text in list items, defaults to the primary text color from CometChatTheme.
    public var listItemTitleTextColor: UIColor = CometChatTheme.textColorPrimary
    
    // Font used for the title text in list items, defaults to medium heading 4 font from CometChatTypography.
    public var listItemTitleFont: UIFont = CometChatTypography.Heading4.medium
    
    // Color of the subtitle text in list items, defaults to the secondary text color from CometChatTheme.
    public var listItemSubTitleTextColor: UIColor = CometChatTheme.textColorSecondary
    
    // Font used for the subtitle text in list items, defaults to regular body font.
    public var listItemSubTitleFont: UIFont = CometChatTypography.Body.regular
    
    // Background color for list items, defaults to clear.
    public var listItemBackground: UIColor = .clear
    
    // Background color for list items if selected, defaults to clear
    public var listItemSelectedBackground: UIColor = CometChatTheme.backgroundColor04
    
    // Width of the border around list items, defaults to 0 (no border).
    public var listItemBorderWidth: CGFloat = 0
    
    // Color of the border around list items, defaults to the light border color from CometChatTheme.
    public var listItemBorderColor: UIColor = CometChatTheme.borderColorLight
    
    // Corner radius settings for list items, defaults to no corner radius.
    public var listItemCornerRadius: CometChatCornerStyle = .init(cornerRadius: 0)
    
    // Tint color for the selection image in list items, defaults to the highlight color from CometChatTheme.
    public var listItemSelectionImageTint: UIColor = CometChatTheme.iconColorHighlight
    
    // Tint color for the deselected image in list items.
    public var listItemDeSelectedImageTint: UIColor = CometChatTheme.borderColorDefault
        
    // Tint color for the password group image, defaults to the background color from CometChatTheme.
    public var passwordGroupImageTintColor: UIColor = CometChatTheme.backgroundColor01
    
    // Background color for the password group image, defaults to the warning color from CometChatTheme.
    public var passwordGroupImageBackgroundColor: UIColor = CometChatTheme.warningColor

    // Tint color for the private group image, defaults to the background color from CometChatTheme.
    public var privateGroupImageTintColor: UIColor = CometChatTheme.backgroundColor01
    
    // Background color for the private group image, defaults to the success color from CometChatTheme.
    public var privateGroupImageBackgroundColor: UIColor = CometChatTheme.successColor
    
    // Image for a private group icon
    public var privateGroupIcon: UIImage = UIImage(systemName: "shield.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()

    // Image for a protected group icon
    public var protectedGroupIcon: UIImage = UIImage(systemName: "lock.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
}
