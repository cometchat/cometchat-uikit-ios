//
//  CometChatMessageConfiguration.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 07/02/22.
//

import Foundation
import UIKit


public class MessagesConfiguration:  CometChatConfiguration {
    
    var messageHeaderConfiguration: MessageHeaderConfiguration?
    var messageListConfiguration : MessageListConfiguration?
    var messageBubbleConfiguration  : MessageBubbleConfiguration?
    var messageComposerConfiguration  : MessageComposerConfiguration?

    
    @discardableResult
    @objc public func set(messageHeaderConfiguration: MessageHeaderConfiguration) -> Self {
        self.messageHeaderConfiguration = messageHeaderConfiguration
        return self
    }
    
    @discardableResult
    @objc public func set(messageListConfiguration: MessageListConfiguration) -> Self {
        self.messageListConfiguration = messageListConfiguration
        return self
    }
    
    @discardableResult
    @objc public func set(messageBubbleConfiguration: MessageBubbleConfiguration) -> Self {
        self.messageBubbleConfiguration = messageBubbleConfiguration
        return self
    }
    
    @discardableResult
    @objc public func set(messageComposerConfiguration: MessageComposerConfiguration) -> Self {
        self.messageComposerConfiguration = messageComposerConfiguration
        return self
    }
    
}
