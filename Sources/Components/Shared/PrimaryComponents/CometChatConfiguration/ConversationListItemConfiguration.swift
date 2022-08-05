//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public class  ConversationListItemConfiguration: CometChatConfiguration {
  
    var background: [CGColor]?
    var hideStatusIndicator: Bool = false
    var hideAvatar: Bool = false
    var hideUnreadCount: Bool = false
    var hideReceipt: Bool = false
    var showTypingIndicator: Bool = true
    var hideThreadIndicator: Bool = false
    var threadIndicatorText: String = "In a thread ⤵"
    var hideGroupActionMessages: Bool = false
    var hideDeletedMessages: Bool = false
    var hideTime: Bool = false
    
    var conversationInputData: ConversationInputData?
    var avatarConfiguration: AvatarConfiguration?
    var statusIndicatorConfiguration: StatusIndicatorConfiguration?
    var badgeCountConfiguration: BadgeCountConfiguration?
    var messageReceiptConfiguration: MessageReceiptConfiguration?

    
    public func set(background: [CGColor]) -> ConversationListItemConfiguration {
        self.background = background
        return self
    }
    
    public func set(avatarConfiguration: AvatarConfiguration) -> ConversationListItemConfiguration {
        self.avatarConfiguration = avatarConfiguration
        return self
    }
    
    public func set(statusIndicatorConfiguration: StatusIndicatorConfiguration) -> ConversationListItemConfiguration {
        self.statusIndicatorConfiguration = statusIndicatorConfiguration
        return self
    }
    
    public func set(badgeCountConfiguration: BadgeCountConfiguration) -> ConversationListItemConfiguration {
        self.badgeCountConfiguration = badgeCountConfiguration
        return self
    }
    
    public func set(messageReceiptConfiguration: MessageReceiptConfiguration) -> ConversationListItemConfiguration {
        self.messageReceiptConfiguration = messageReceiptConfiguration
        return self
    }
    
    public func show(typingIndicator: Bool) -> ConversationListItemConfiguration {
        self.showTypingIndicator = typingIndicator
        return self
    }
    
    public func hide(threadIndicator: Bool) -> ConversationListItemConfiguration {
        self.hideThreadIndicator = threadIndicator
        return self
    }
    
    public func set(threadIndicatorText: String) -> ConversationListItemConfiguration {
        self.threadIndicatorText = threadIndicatorText
        return self
    }
    
    public func hide(groupActionMessages: Bool) -> ConversationListItemConfiguration {
        self.hideGroupActionMessages = groupActionMessages
        return self
    }
    
    public func hide(deletedMessages: Bool) -> ConversationListItemConfiguration {
        self.hideDeletedMessages = deletedMessages
        return self
        
    }
    
    public func set(conversationInputData: ConversationInputData) -> ConversationListItemConfiguration {
        self.conversationInputData = conversationInputData
        return self
    }
    
    
}

