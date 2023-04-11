//
//  GroupsWithMessagesConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 18/08/22.
//

import UIKit

public class GroupsWithMessagesConfiguration {

    private(set) var style: GroupsWithMessageStyle?
    private(set) var groupsConfiguration: GroupsConfiguration?
    private(set) var messagesConfiguration: MessagesConfiguration?
    // This joinProtectedGroupConfiguration is not matching
    private(set) var joinProtectedGroupConfiguration: JoinProtectedGroupConfiguration?
    
    public init() {}
    @discardableResult
    public func set(style: GroupsWithMessageStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(groupsConfiguration: GroupsConfiguration) -> Self {
        self.groupsConfiguration = groupsConfiguration
        return self
    }
    
    @discardableResult
    public func set(messagesConfiguration: MessagesConfiguration) -> Self {
        self.messagesConfiguration = messagesConfiguration
        return self
    }
    
    @discardableResult
    public func set(joinProtectedGroupConfiguration: JoinProtectedGroupConfiguration) -> Self {
        self.joinProtectedGroupConfiguration = joinProtectedGroupConfiguration
        return self
    }
    
}
