//
//  File.swift
//  
//
//  Created by nabhodipta on 30/06/23.
//

import UIKit

///  CometChatContactsStyle is a class that allows to customize various properties such as color, font for the components used in the `CometChatContacts`
public class ContactsStyle: BaseStyle {
    
    /// the property `titleTextColor` is used to set the title text color for the `CometChatContacts` Component.
    private(set) var titleTextColor = CometChatTheme.palatte.accent
    
    /// the property `titleTextFont` is used to set the title text font for the `CometChatContacts` Component.
    private(set) var titleTextFont = CometChatTheme.typography.heading
    
    /// the property `tabTitleTextColor` is used to set the tab title text color for the `CometChatContacts` Component.
    private(set) var tabTitleTextColor = CometChatTheme.palatte.accent
    
    /// the property `tabTitleTextFont` is used to set the tab title text font for the `CometChatContacts` Component.
    private(set) var tabTitleTextFont = CometChatTheme.typography.text3
    
    /// the property `tabWidth` is used to set the tab width for the `CometChatContacts` Component.
    private(set) var tabWidth: CGFloat?
    
    /// the property `tabHeight` is used to set the tab height for the `CometChatContacts` Component.
    private(set) var tabHeight : CGFloat?
    
    /// the property `activeTabTitleTextColor` is used to set the active tab title text color for the `CometChatContacts` Component.
    private(set) var activeTabTitleTextColor = CometChatTheme.palatte.accent
    
    /// the property `activeTabBackground` is used to set the active tab background color for the `CometChatContacts` Component.
    private(set) var activeTabBackground = CometChatTheme.palatte.background
    
    /// the property `closeIconTint` is used to set the close icon tint color for the `CometChatContacts` Component.
    private(set) var closeIconTint = CometChatTheme.palatte.primary
    
    /// the property `selectionIconTint` is used to set the selection icon tint color for the `CometChatContacts` Component.
    private(set) var selectionIconTint = CometChatTheme.palatte.primary
    
    /// the property `errorStateTextColor` is used to set the error state text color for the `CometChatContacts` Component.
    private(set) var errorStateTextColor = CometChatTheme.palatte.accent
    
    /// the property `errorStateTextFont` is used to set the error state text font for the `CometChatContacts` Component.
    private(set) var errorStateTextFont = CometChatTheme.typography.text1
    
    /// the property `submitButtonBackground` is used to set the submit button background color for the `CometChatContacts` Component.
    private(set) var submitButtonBackground = CometChatTheme.palatte.secondary
    
    /// the property `submitButtonTextColor` is used to set the submit button text color for the `CometChatContacts` Component.
    private(set) var submitButtonTextColor = CometChatTheme.palatte.primary
    
    /// the property `submitButtonTextFont` is used to set the submit button text font for the `CometChatContacts` Component.
    private(set) var submitButtonTextFont = CometChatTheme.typography.text1
    
    /// the property `tableViewStyle` is used to set the tableView style for the `CometChatContacts` Component. Default value is `insetGrouped`
    private(set) var tableViewStyle : UITableView.Style = .insetGrouped
    
    override public var background: UIColor {
        get {
            return CometChatTheme.palatte.secondary
        }
        set {}
    }
    
    /// This method sets the title text color for `CometChatContacts` Component.
    /// - Parameters:
    ///  - titleTextColor: This takes `UIColor` value.
    @discardableResult
    public func set(titleTextColor: UIColor) -> Self {
        self.titleTextColor = titleTextColor
        return self
    }
    
    /// This method sets the title text font for `CometChatContacts` Component.
    /// - Parameters:
    ///     - titleTextFont: This takes `UIFont` value.
    @discardableResult
    public func set(titleTextFont: UIFont) -> Self {
        self.titleTextFont = titleTextFont
        return self
    }
    
    /// This method sets the tab title text color for `CometChatContacts` Component.
    /// - Parameters:
    ///     - tabTitleTextColor: This takes `UIColor` value.
    @discardableResult
    public func set(tabTitleTextFont: UIFont) -> Self {
        self.tabTitleTextFont = tabTitleTextFont
        return self
    }
    
    /// This method sets the tab title text color for `CometChatContacts` Component.
    /// - Parameters:
    ///     - tabTitleTextColor: This takes `UIColor` value.
    @discardableResult
    public func set(tabTitleTextColor: UIColor) -> Self {
        self.tabTitleTextColor = tabTitleTextColor
        return self
    }
    
    /// This method sets the active tab title text color for `CometChatContacts` Component.
    /// - Parameters:
    ///     - activeTabTitleTextColor: This takes `UIColor` value.
    @discardableResult
    public func set(activeTabTitleTextColor: UIColor) -> Self {
        self.activeTabTitleTextColor = activeTabTitleTextColor
        return self
    }
    
    /// This method sets the tab width for `CometChatContacts` Component.
    /// - Parameters:
    ///     - tabWidth: This takes `CGFloat` value.
    @discardableResult
    public func set(tabWidth : CGFloat) -> Self {
        self.tabWidth = tabWidth
        return self
    }
    
    /// This method sets the tab height for `CometChatContacts` Component.
    /// - Parameters:
    ///    - tabHeight: This takes `CGFloat` value.
    @discardableResult
    public func set(tabHeight : CGFloat) -> Self {
        self.tabHeight = tabHeight
        return self
    }
    
    /// This method sets the active tab background color for `CometChatContacts` Component.
    /// - Parameters:
    ///    - activeTabBackground: This takes `UIColor` value.
    @discardableResult
    public func set(activeTabBackground: UIColor) -> Self {
        self.activeTabBackground = activeTabBackground
        return self
    }
    
    /// This method sets the close icon tint color for `CometChatContacts` Component.
    /// - Parameters:
    ///    - closeIconTint: This takes `UIColor` value.
    @discardableResult
    public func set(closeIconTint: UIColor) -> Self {
        self.closeIconTint = closeIconTint
        return self
    }
    
    /// This method sets the selection icon tint color for `CometChatContacts` Component.
    /// - Parameters:
    ///     - selectionIconTint: This takes `UIColor` value.
    @discardableResult
    public func set(selectionIconTint: UIColor) -> Self {
        self.selectionIconTint = selectionIconTint
        return self
    }
    
    /// This method sets the error state text color for `CometChatContacts` Component.
    /// - Parameters:
    ///    - errorStateTextColor: This takes `UIColor` value.
    @discardableResult
    public func set(errorStateTextColor: UIColor) -> Self {
        self.errorStateTextColor = errorStateTextColor
        return self
    }
    
    /// This method sets the error state text font for `CometChatContacts` Component.
    /// - Parameters:
    ///    - errorStateTextFont: This takes `UIFont` value.
    @discardableResult
    public func set(errorStateTextFont: UIFont) -> Self {
        self.errorStateTextFont = errorStateTextFont
        return self
    }
    
    /// This method sets the submit button background color for `CometChatContacts` Component.
    /// - Parameters:
    ///    - submitButtonBackground: This takes `UIColor` value.
    @discardableResult
    public func set(submitButtonBackground: UIColor) -> Self {
        self.submitButtonBackground = submitButtonBackground
        return self
    }
    
    /// This method sets the submit button text color for `CometChatContacts` Component.
    /// - Parameters:
    ///     - submitButtonTextFont: This takes `UIFont` value.
    @discardableResult
    public func set(submitButtonTextFont: UIFont) -> Self {
        self.submitButtonTextFont = submitButtonTextFont
        return self
    }
    
    /// This method sets the submit button text color for `CometChatContacts` Component.
    /// - Parameters:
    ///     - submitButtonTextColor: This takes `UIColor` value.
    @discardableResult
    public func set(submitButtonTextColor: UIColor) -> Self {
        self.submitButtonTextColor = submitButtonTextColor
        return self
    }
    
    /// This method sets the tableView style for `CometChatContacts` Component.
    /// - Parameters:
    ///     - tableViewStyle: This takes `UITableView.Style` value.
    @discardableResult
    public func set(tableViewStyle: UITableView.Style) -> Self {
        self.tableViewStyle = tableViewStyle
        return self
    }

}
