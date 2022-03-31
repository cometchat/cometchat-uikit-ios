//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit
import CometChatPro



public class ConversationListConfiguration: CometChatConfiguration {

    var background: [CGColor]?
    var showDeleteConversation : Bool = true
    var conversationType: CometChat.ConversationType  = .none
    var hideError : Bool = false
    var userAndGroupTags : Bool = false
    var searchKeyWord : String = ""
    var tags : [String] = [String]()
    var limit : Int = 30
    var conversationListItemConfiguration :ConversationListItemConfiguration?
    
    public func set(background: [CGColor]) -> ConversationListConfiguration {
        self.background = background
        return self
    }
    
    public func set(conversationType: CometChat.ConversationType) -> ConversationListConfiguration {
        self.conversationType = conversationType
        return self
    }
    
    
    public func show(deleteConversation: Bool) -> ConversationListConfiguration {
        self.showDeleteConversation = deleteConversation
        return self
    }
    
    public func set(limit: Int) -> ConversationListConfiguration {
        self.limit = limit
        return self
    }
    
    public func set(tags: [String]) -> ConversationListConfiguration {
        self.tags = tags
        return self
    }
    
    
    public func set(userAndGroupTags:Bool) -> ConversationListConfiguration {
        self.userAndGroupTags = userAndGroupTags
        return self
    }
    
    public func hide(error: Bool) -> ConversationListConfiguration {
        self.hideError = error
        return self
    }
}

