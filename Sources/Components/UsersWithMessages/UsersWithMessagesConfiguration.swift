//
//  UsersWithMessagesConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 18/08/22.
//

import UIKit

public class UsersWithMessagesConfiguration {

    private(set) var style: UsersWithMessagesStyle?
    private(set) var usersConfiguration: UsersConfiguration?
    private(set) var messagesConfiguration: MessagesConfiguration?

    public init() {}
    
    @discardableResult
    public func set(usersConfiguration: UsersConfiguration) -> UsersWithMessagesConfiguration {
        self.usersConfiguration = usersConfiguration
        return self
    }

    @discardableResult
    public func set(messagesConfiguration: MessagesConfiguration) -> UsersWithMessagesConfiguration {
        self.messagesConfiguration = messagesConfiguration
        return self
    }

    @discardableResult
    public func set(style: UsersWithMessagesStyle) -> UsersWithMessagesConfiguration {
        self.style = style
        return self
    }

}
