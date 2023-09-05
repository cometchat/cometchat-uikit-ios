//
//  CometChatMessageConfiguration.swift
 
//
//  Created by Pushpsen Airekar on 07/02/22.
//

import Foundation
import UIKit
import CometChatSDK

public class MessagesConfiguration {

    private(set) var hideMessageComposer: Bool?
    private(set) var disableSoundForMessages: Bool?
    private(set) var enablesoundForCalls: Bool?
    private(set) var customSoundForIncomingMessages: URL?
    private(set) var customSoundForOutgoingMessages: URL?
    private(set) var disableTyping: Bool?
    private(set) var messagesStyle: MessagesStyle?
    private(set) var messageHeaderConfiguration: MessageHeaderConfiguration?
    private(set) var messageListConfiguration : MessageListConfiguration?
    private(set) var messageComposerConfiguration  : MessageComposerConfiguration?
    private(set) var detailsConfiguration: DetailsConfiguration?
    private(set) var threadedMessageConfiguration: ThreadedMessageConfiguration?
    private(set) var hideMessageHeader: Bool?
    private(set) var messageHeaderView: ((_ user: User?, _ group: Group? ) -> UIView)?
    private(set) var messageComposerView: ((_ user: User?, _ group: Group? ) -> UIView)?
    private(set) var messageListView: ((_ user: User?, _ group: Group? ) -> UIView)?
    private(set) var auxiliaryMenu: ((_ user: User?, _ group: Group?, _ id: [String: Any]?) -> UIStackView)?
    private(set) var hideDetails = false

    public init() {}
    

    @discardableResult
    public func hide(messageComposer: Bool) -> Self {
        self.hideMessageComposer = messageComposer
        return self
    }
    
    @discardableResult
    public func hide(messageHeader: Bool) -> Self {
        self.hideMessageHeader = messageHeader
        return self
    }
    
    @discardableResult
    public func setMessageComposerView(messageComposerView: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
        self.messageComposerView = messageComposerView
        return self
    }
    
    @discardableResult
    public func setMessageHeaderView(messageHeaderView: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
        self.messageHeaderView = messageHeaderView
        return self
    }
    
    @discardableResult
    public func setMessageListView(messageListView: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
        self.messageListView = messageListView
        return self
    }
    
    @discardableResult
    public func disable(soundForMessages: Bool) -> Self {
        self.disableSoundForMessages = soundForMessages
        return self
    }
    
    @discardableResult
    public func enable(soundForCalls: Bool) -> Self {
        self.enablesoundForCalls = soundForCalls
        return self
    }
    
    @discardableResult
    public func set(customSoundForIncomingMessages: URL) -> Self {
        self.customSoundForIncomingMessages = customSoundForIncomingMessages
        return self
    }
    
    @discardableResult
    public func set(customSoundForOutgoingMessages: URL) -> Self {
        self.customSoundForOutgoingMessages = customSoundForOutgoingMessages
        return self
    }
    
    @discardableResult
    public func disable(disableTyping: Bool) -> Self {
        self.disableTyping = disableTyping
        return self
    }
    
    @discardableResult
    public func set(messagesStyle: MessagesStyle) -> Self {
        self.messagesStyle = messagesStyle
        return self
    }
    
    @discardableResult
    public func set(messageHeaderConfiguration: MessageHeaderConfiguration) -> Self {
        self.messageHeaderConfiguration = messageHeaderConfiguration
        return self
    }
    
    @discardableResult
    public func set(messageListConfiguration: MessageListConfiguration) -> Self {
        self.messageListConfiguration = messageListConfiguration
        return self
    }
    
    @discardableResult
    public func set(messageComposerConfiguration: MessageComposerConfiguration) -> Self {
        self.messageComposerConfiguration = messageComposerConfiguration
        return self
    }
    
    @discardableResult
    public func set(detailsConfiguration: DetailsConfiguration) -> Self {
        self.detailsConfiguration = detailsConfiguration
        return self
    }
    
    @discardableResult
    public func set(threadedMessageConfiguration: ThreadedMessageConfiguration) -> Self {
        self.threadedMessageConfiguration = threadedMessageConfiguration
        return self
    }
    
    @discardableResult
    public func setAuxiliaryMenu(auxiliaryMenu: ((_ user: User?, _ group: Group?, _ id: [String: Any]?) -> UIStackView)?) -> Self {
        self.auxiliaryMenu = auxiliaryMenu
        return self
    }
    
    @discardableResult
    @objc public func hide(details: Bool) -> Self {
        self.hideDetails = details
        return self
    }
    
}
