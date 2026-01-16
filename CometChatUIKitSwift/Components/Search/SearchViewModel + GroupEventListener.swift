//
//  SearchViewModel + GroupEventListener.swift
//  CometChatUIKitSwift
//
//  Created by Prathmesh on 17/12/25.
//

import Foundation
import CometChatSDK

extension SearchViewModel: CometChatGroupEventListener {
    
    public func ccOwnershipChanged(group: Group, newOwner: GroupMember) {
        updateGroup(group: group)
    }
    
    public func ccGroupLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if CometChat.getLoggedInUser()?.uid == leftUser.uid {
            removeConversation(for: leftGroup)
        }
    }
    
    public func ccGroupDeleted(group: Group) {
        removeConversation(for: group)
    }
    
    public func ccGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User) {
        updateGroup(group: groupAddedIn)
    }
    
    public func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if CometChat.getLoggedInUser()?.uid == kickedUser.uid {
            removeConversation(for: kickedFrom)
        }
    }
    
    public func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if CometChat.getLoggedInUser()?.uid == bannedUser.uid {
            removeConversation(for: bannedFrom)
        }
    }
    
    public func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        updateGroup(group: group)
    }
    
    public func ccGroupCreated(group: Group) {
        // No need to add newly created groups to search results
    }
    
    // MARK: - Helper Methods
    
    private func updateGroup(group: Group) {
        if let conversation = filteredConversations.first(where: {
            ($0.conversationWith as? Group)?.guid == group.guid
        }) {
            conversation.conversationWith = group
            update(conversation: conversation)
        }
    }
    
    private func removeConversation(for group: Group) {
        if let index = filteredConversations.firstIndex(where: {
            ($0.conversationWith as? Group)?.guid == group.guid
        }) {
            filteredConversations.remove(at: index)
            reload?()
        }
    }
    
}

extension SearchViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        updateGroup(group: joinedGroup)
    }
    
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if CometChat.getLoggedInUser()?.uid == leftUser.uid {
            removeConversation(for: leftGroup)
        }
    }
    
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if CometChat.getLoggedInUser()?.uid == kickedUser.uid {
            removeConversation(for: kickedFrom)
        }
    }
    
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if CometChat.getLoggedInUser()?.uid == bannedUser.uid {
            removeConversation(for: bannedFrom)
        }
    }
    
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        updateGroup(group: unbannedFrom)
    }
    
    public func onGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        updateGroup(group: group)
    }
    
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        updateGroup(group: addedTo)
    }
    
}
