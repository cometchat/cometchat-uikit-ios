//
//  File.swift
//  
//
//  Created by nabhodipta on 23/07/23.
//

import Foundation

class ContactsViewModel {
    
    /// the property `tabVisibility` is used to set the visibility of the tabs in the `UISegmentedControl`. Default value is `TabVisibility.usersAndGroups`
    private (set) var tabVisibility: TabVisibility = .usersAndGroups
    
    /// This method sets the tab visibility for the `CometChatContacts` Component.
    /// - Parameters:
    ///     - tabVisibility: This takes `TabVisibility` value.
    @discardableResult
    public func setTabVisibility(tabVisibility: TabVisibility) -> Self {
        self.tabVisibility = tabVisibility
        return self
    }
    
    public func shouldSetupUsers() -> Bool {
        return tabVisibility == .users || tabVisibility == .usersAndGroups
    }
    
    public func shouldSetupGroups() -> Bool {
        return tabVisibility == .groups || tabVisibility == .usersAndGroups
    }
    
    public func shouldClearUsersSearch(_ selectedSegmentIndex : Int) -> Bool {
        return tabVisibility == .users || ( tabVisibility == .usersAndGroups && selectedSegmentIndex == 0)
    }
    
    public func shouldClearGroupsSearch(_ selectedSegmentIndex : Int) -> Bool {
        return tabVisibility == .groups || ( tabVisibility == .usersAndGroups && selectedSegmentIndex == 1)
    }
}
