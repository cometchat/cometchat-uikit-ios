//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 17/07/22.
//

import Foundation
import CometChatPro

extension CometChatConversationList : CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        if let conversation = CometChat.getConversationFromMessage(action), (conversationType == .group || conversationType == .none) {
            if enableSoundForConversations {
                CometChatSoundManager().play(sound: .incomingMessageFromOther, customSound: customSoundForConversations)
            }
            self.update(conversation: conversation)
        }
    }
    
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if let conversation = CometChat.getConversationFromMessage(action), (conversationType == .group || conversationType == .none) {
            if enableSoundForConversations {
                CometChatSoundManager().play(sound: .incomingMessageFromOther, customSound: customSoundForConversations)
            }
            self.update(conversation: conversation)
        }
    }
    
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if let conversation = CometChat.getConversationFromMessage(action), (conversationType == .group || conversationType == .none) {
            if enableSoundForConversations {
                CometChatSoundManager().play(sound: .incomingMessageFromOther, customSound: customSoundForConversations)
            }
            self.update(conversation: conversation)
        }
        
    }
    
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if let conversation = CometChat.getConversationFromMessage(action), (conversationType == .group || conversationType == .none) {
            if enableSoundForConversations {
                CometChatSoundManager().play(sound: .incomingMessageFromOther, customSound: customSoundForConversations)
            }
            self.update(conversation: conversation)
        }
        
    }
    
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if let conversation = CometChat.getConversationFromMessage(action), (conversationType == .group || conversationType == .none) {
            if enableSoundForConversations {
                CometChatSoundManager().play(sound: .incomingMessageFromOther, customSound: customSoundForConversations)
            }
            self.update(conversation: conversation)
        }
        
    }
    
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if let conversation = CometChat.getConversationFromMessage(action), (conversationType == .group || conversationType == .none) {
            if enableSoundForConversations {
                CometChatSoundManager().play(sound: .incomingMessageFromOther, customSound: customSoundForConversations)
            }
            self.update(conversation: conversation)
        }
        
    }
    
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if let conversation = CometChat.getConversationFromMessage(action), (conversationType == .group || conversationType == .none) {
            if enableSoundForConversations {
                CometChatSoundManager().play(sound: .incomingMessageFromOther, customSound: customSoundForConversations)
            }
            self.update(conversation: conversation)
        }
        
    }
    


}
