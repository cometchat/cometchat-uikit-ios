//
//  File.swift
//  
//
//  Created by nabhodipta on 13/07/23.
//

import UIKit
import CometChatSDK


public class ContactsConfiguration {
    
    /// the property `title` is used to set the title for the `CometChatContacts` Component.
    private (set) var title: String?
    
    /// the property `usersTabTitle` is used to set the users tab title for the `CometChatContacts` Component.
    private (set) var usersTabTitle: String?
    
    /// the property `groupsTabTitle` is used to set the groups tab title for the `CometChatContacts` Component.
    private (set) var groupsTabTitle: String?
    
    /// the property `usersConfiguration` is used to set the configurations for the `CometChatUsers` Component embedded in `CometChatContacts` Component.
    private (set) var usersConfiguration: UsersConfiguration?
    
    /// the property `groupsConfiguration` is used to set the configurations for the `CometChatGroups` Component embedded in `CometChatContacts` Component.
    private (set) var groupsConfiguration: GroupsConfiguration?
    
    /// the property `onItemTap` is used to set the action to be performed when a user or group is tapped in `CometChatContacts` Component.
    private (set) var onItemTap: ((_ controller: UIViewController?, _ user: User?, _ group: Group?) -> Void)?
    
    /// the property `closeIcon` is used to set the close icon for the `CometChatContacts` Component.
    private (set) var closeIcon: UIImage?
    
    /// the property `onClose` is used to set the action to be performed when close icon is tapped in `CometChatContacts` Component.
    private (set) var onClose: (() -> Void)?
    
    /// the property `submitIcon` is used to set the submit icon for the `CometChatContacts` Component.
    private (set) var submitIcon: UIImage?
    
    /// the property `onSubmitIconTap` is used to set the action to be performed when submit icon is tapped in `CometChatContacts` Component.
    private (set) var onSubmitIconTap: ((_ selectedUsers: [User]? ,_ selectedGroups: [Group]?) -> Void)?
    
    /// the property `hideSubmitButton` is used to hide the submit button in `CometChatContacts` Component.
    private (set) var hideSubmitButton: Bool = false
    
    /// the property `selectionLimit` is used to set the selection limit for the `CometChatContacts` Component.
    private (set) var selectionLimit: Int?
    
    /// the property `selectionMode` is used to set the selection mode for the `CometChatContacts` Component.
    private (set) var selectionMode: SelectionMode?
    
    /// the property `contactsStyle` is used to set the style for the `CometChatContacts` Component.
    private (set) var contactsStyle: ContactsStyle = ContactsStyle()
    
    /// the property `tabVisibility` is used to set the tab visibility for the `CometChatContacts` Component. Default value is `usersAndGroups`
    private (set) var tabVisibility: TabVisibility = .usersAndGroups
    
    init(usersTabTitle: String? = nil, groupsTabTitle: String? = nil, usersConfiguration: UsersConfiguration? = nil, groupsConfiguration: GroupsConfiguration? = nil, onItemTap:( (_: UIViewController?, _: User?, _: Group?) -> Void)?, closeIcon: UIImage? = nil, onClose: ( () -> Void)? = nil, submitIcon: UIImage? = nil, onSubmitIconTap: ( (_: [User]?, _: [Group]?) -> Void)? = nil, hideSubmitButton: Bool, selectionLimit: Int? = nil, selectionMode: SelectionMode? = nil, contactsStyle: ContactsStyle, tabVisibility: TabVisibility) {
        self.usersTabTitle = usersTabTitle
        self.groupsTabTitle = groupsTabTitle
        self.usersConfiguration = usersConfiguration
        self.groupsConfiguration = groupsConfiguration
        self.onItemTap = onItemTap
        self.closeIcon = closeIcon
        self.onClose = onClose
        self.submitIcon = submitIcon
        self.onSubmitIconTap = onSubmitIconTap
        self.hideSubmitButton = hideSubmitButton
        self.selectionLimit = selectionLimit
        self.selectionMode = selectionMode
        self.contactsStyle = contactsStyle
        self.tabVisibility = tabVisibility
    }
    
    
    /// This method sets the title for `CometChatContacts` Component.
    /// - Parameters:
    ///     - title: This takes `String` value.
    @discardableResult
    public func setTitle(title: String?) -> Self {
        self.title = title
        return self
    }
    
    /// This method sets the users tab title for `CometChatContacts` Component.
    /// - Parameters:
    ///     - usersTabTitle: This takes `String` value.
    @discardableResult
    public func setUsersTabTitle(usersTabTitle: String?) -> Self {
        self.usersTabTitle = usersTabTitle
        return self
    }
    
    /// This method sets the groups tab title for `CometChatContacts` Component.
    /// - Parameters:
    ///    - groupsTabTitle: This takes `String` value.
    @discardableResult
    public func setGroupsTabTitle(groupsTabTitle: String?) -> Self {
        self.groupsTabTitle = groupsTabTitle
        return self
    }
    
    /// This method sets the configurations for the `CometChatUsers` Component embedded in `CometChatContacts` Component.
    /// - Parameters:
    ///     - usersConfiguration: This takes `UsersConfiguration` value.
    @discardableResult
    public func setUsersConfiguration(usersConfiguration: UsersConfiguration?) -> Self {
        self.usersConfiguration = usersConfiguration
        return self
    }
    
    /// This method sets the configurations for the `CometChatGroups` Component embedded in `CometChatContacts` Component.
    /// - Parameters:
    ///     - groupsConfiguration: This takes `GroupsConfiguration` value.
    @discardableResult
    public func setGroupsConfiguration(groupsConfiguration: GroupsConfiguration?) -> Self {
        self.groupsConfiguration = groupsConfiguration
        return self
    }
    
    /// This method sets the action to be performed when a user or group is tapped in `CometChatContacts` Component.
    /// - Parameters:
    ///    - onItemTap: This takes `(_ controller: UIViewController?, _ user: User?, _ group: Group?) -> Void` value.
    ///     - controller: The function onItemTap takes UIViewController from where the action is performed as an argument.
    ///     - user: The function onItemTap takes User object which is tapped as an argument.
    ///     - group: The function onItemTap takes Group object which is tapped as an argument.
    @discardableResult
    public func setOnItemTap(onItemTap: ((_ controller: UIViewController?, _ user: User?, _ group: Group?) -> Void)?) -> Self {
        self.onItemTap = onItemTap
        return self
    }
    
    /// This method sets the close icon for the `CometChatContacts` Component.
    /// - Parameters:
    ///    - closeIcon: This takes `UIImage` value.
    @discardableResult
    public func setCloseIcon(closeIcon: UIImage?) -> Self {
        self.closeIcon = closeIcon
        return self
    }
    
    /// This method sets the action to be performed when close icon is tapped in `CometChatContacts` Component.
    /// - Parameters:
    ///   - onClose: This takes `() -> Void` value.
    @discardableResult
    public func setonClose(onClose: (() -> Void)?) -> Self {
        self.onClose = onClose
        return self
    }
    
    /// This method sets the submit icon for the `CometChatContacts` Component.
    /// - Parameters:
    ///  - submitIcon: This takes `UIImage` value.
    @discardableResult
    public func setSubmitIcon(submitIcon: UIImage?) -> Self {
        self.submitIcon = submitIcon
        return self
    }
    
    /// This method sets the action to be performed when submit icon is tapped in `CometChatContacts` Component.
    /// - Parameters:
    ///  - onSubmitIconTap: This takes `(_ selectedUsers: [User]? ,_ selectedGroups: [Group]?) -> Void` value.
    ///    - selectedUsers: The function `onSubmitIconTap` takes `selectedUsers` which is a list of User objects as an argument.
    ///    - selectedGroups: The function `onSubmitIconTap` takes `selectedGroups` which is a list of Group objects as an argument.
    @discardableResult
    public func setOnSubmitIconTap(onSubmitIconTap: ((_ selectedUsers: [User]? ,_ selectedGroups: [Group]?) -> Void)?) -> Self {
        self.onSubmitIconTap = onSubmitIconTap
        return self
    }
    
    /// This method hides the submit button in `CometChatContacts` Component.
    /// - Parameters:
    ///     - hideSubmitButton: This takes `Bool` value.
    @discardableResult
    public func setHideSubmitButton(hideSubmitButton: Bool?) -> Self {
        self.hideSubmitButton = hideSubmitButton ?? false
        return self
    }
    
    /// This method sets the selection limit for the `CometChatContacts` Component.
    /// - Parameters:
    ///    - selectionLimit: This takes `Int` value.
    @discardableResult
    public func setSelectionLimit(selectionLimit: Int?) -> Self {
        self.selectionLimit = selectionLimit
        return self
    }
    
    /// This method sets the selection mode for the `CometChatContacts` Component.
    /// - Parameters:
    ///    - selectionMode: This takes `SelectionMode` value.
    @discardableResult
    public func setSelectionMode(selectionMode: SelectionMode) -> Self {
        self.selectionMode = selectionMode
        return self
    }
    
    /// This method sets the tab visibility for the `CometChatContacts` Component.
    /// - Parameters:
    ///     - tabVisibility: This takes `TabVisibility` value.
    @discardableResult
    public func setTabVisibility(tabVisibility: TabVisibility) -> Self {
        self.tabVisibility = tabVisibility
        return self
    }
    
    /// This method sets the style for the `CometChatContacts` Component.
    /// - Parameters:
    ///     - contactsStyle: This takes `ContactsStyle` value.
    @discardableResult
    public func setContactsStyle(contactsStyle: ContactsStyle) -> Self {
        self.contactsStyle = contactsStyle
        return self
    }
    
}
