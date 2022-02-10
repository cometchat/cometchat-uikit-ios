//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public enum ChatDisplayMode {
   case user
   case group
   case both
}


public class ConversationListConfiguration: CometChatConfiguration {

    var background: [CGColor]?
    var showDeleteConversation : Bool = true
    var chatListMode: ChatDisplayMode  = .both
    var conversationListItemConfiguration :ConversationListItemConfiguration?
    
    public func set(background: [CGColor]) -> ConversationListConfiguration {
        self.background = background
        return self
    }
    
    public func set(chatListMode: ChatDisplayMode) -> ConversationListConfiguration {
        self.chatListMode = chatListMode
        return self
    }
    
    
    public func show(deleteConversation: Bool) -> ConversationListConfiguration {
        self.showDeleteConversation = deleteConversation
        return self
    }
    
    public func set(conversationListItemConfiguration: ConversationListItemConfiguration) -> ConversationListConfiguration {
        self.conversationListItemConfiguration = conversationListItemConfiguration
        return self
    }
    
    public func set(configuration: ConversationListConfiguration) {
        self.background = configuration.background
        self.showDeleteConversation = configuration.showDeleteConversation
        self.conversationListItemConfiguration = configuration.conversationListItemConfiguration
    }
}

