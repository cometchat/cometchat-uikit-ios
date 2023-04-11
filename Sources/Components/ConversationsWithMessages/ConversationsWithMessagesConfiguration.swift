//
//  ConversationsWithMessagesConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 18/08/22.
//

import Foundation
import UIKit

public class ConversationsWithMessagesConfiguration {
    
    private(set) var style: ConversationsWithMessagesStyle?
    private(set) var conversationsConfiguration: ConversationsConfiguration?
    private(set) var messagesConfiguration: MessagesConfiguration?
    
    public init() {}
    
    @discardableResult
    public func set(style: ConversationsWithMessagesStyle) -> ConversationsWithMessagesConfiguration {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(conversationsConfiguration: ConversationsConfiguration) -> ConversationsWithMessagesConfiguration {
        self.conversationsConfiguration = conversationsConfiguration
        return self
    }
    
    @discardableResult
    public func set(messagesConfiguration: MessagesConfiguration) -> ConversationsWithMessagesConfiguration {
        self.messagesConfiguration = messagesConfiguration
        return self
    }
    
    
}
