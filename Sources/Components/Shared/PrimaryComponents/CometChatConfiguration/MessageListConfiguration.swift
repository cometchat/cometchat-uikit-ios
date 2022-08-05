//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public class  MessageListConfiguration: CometChatConfiguration {
  
    lazy var limit: Int = 30
    lazy var onlyUnreadMessages: Bool = false
    lazy var hideMessagesFromBlockedUsers: Bool = true
    lazy var hideDeletedMessages: Bool = false
    lazy var hideThreadReplies: Bool = true
    lazy var hideError: Bool = false
    var tags: [String]?
    var messageTypes: [CometChatMessageTemplate]?
    var excludeMessageTypes: [CometChatMessageTemplate]?
    var emptyText: String?
    var errorText: String?
    var emptyView: UIView?
    var scrollToBottomOnNewMessage: Bool = true
    var showEmojiInLargerSize: Bool = true
    var messageBubbleConfiguration: MessageBubbleConfiguration?
    var excludedMessageOptions: [CometChatMessageOption]?
    var messageAlignment: UIKitConstants.MessageListAlignmentConstants = .standard
    var enableSoundForMessages: Bool = true
    
    @discardableResult
    public func set(limit: Int) -> Self {
        self.limit = limit
        return self
    }
    @discardableResult
    public func show(onlyUnreadMessages: Bool) -> Self {
        self.onlyUnreadMessages = onlyUnreadMessages
        return self
    }
    @discardableResult
    public func hide(messagesFromBlockedUsers: Bool) -> Self {
        self.hideMessagesFromBlockedUsers = messagesFromBlockedUsers
        return self
    }
    @discardableResult
    public func hide(deletedMessages: Bool) -> Self {
        self.hideDeletedMessages = deletedMessages
        return self
    }
    @discardableResult
    public func hide(threadedReplies: Bool) -> Self {
        self.hideThreadReplies = threadedReplies
        return self
    }
    @discardableResult
    public func hide(error: Bool) -> Self {
        self.hideError = error
        return self
    }
    @discardableResult
    public func set(tags: [String]) -> Self {
        self.tags = tags
        return self
    }
    @discardableResult
    public func set(messageTypes: [CometChatMessageTemplate]) -> Self {
        self.messageTypes = messageTypes
        return self
    }
    @discardableResult
    public func set(excludeMessageTypes: [CometChatMessageTemplate]) -> Self {
        self.excludeMessageTypes = excludeMessageTypes
        return self
    }
    
    @discardableResult
    public func set(emptyView: UIView?) -> Self {
        self.emptyView = emptyView
        return self
    }
    
    @discardableResult
    public func set(emptyText: String) -> Self {
        self.emptyText = emptyText
        return self
    }
    @discardableResult
    public func set(errorText: String) -> Self {
        self.errorText = errorText
        return self
    }
    
    @discardableResult
    public func scrollToBottomOnNewMessage(bool: Bool) -> Self {
        self.scrollToBottomOnNewMessage = bool
        return self
    }
    @discardableResult
    public func showEmojiInLargerSize(bool: Bool) -> Self {
        self.showEmojiInLargerSize = bool
        return self
    }
    
    @discardableResult
    public func set(messageBubbleConfiguration: MessageBubbleConfiguration) -> Self {
        self.messageBubbleConfiguration = messageBubbleConfiguration
        return self
    }
    @discardableResult
    public func set(excludedMessageOptions: [CometChatMessageOption]) -> Self {
        self.excludedMessageOptions = excludedMessageOptions
        return self
    }
    @discardableResult
    public func set(messageAlignment: UIKitConstants.MessageListAlignmentConstants) -> Self {
        self.messageAlignment = messageAlignment
        return self
    }
    
    @discardableResult
    @objc public func enableSoundForMessages(bool: Bool) -> Self {
        self.enableSoundForMessages = bool
        return self
    }
    
}

