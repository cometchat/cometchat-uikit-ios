//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 03/02/23.
//

import Foundation
import CometChatSDK

extension ConversationsViewModel: CometChatGroupEventListener {
    
    func ccOwnershipChanged(group: Group, newOwner: GroupMember) {
        update(group: group)
    }
    
    func ccGroupLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        removerConversation(for: leftGroup)
    }
    
    func ccGroupDeleted(group: Group) {
        removerConversation(for: group)
    }
    
    func ccGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User) {
        if checkForConversationUpdate() {
            if let lastActionMessage = messages.last {
                update(group: groupAddedIn)
                update(lastMessage: lastActionMessage, updateCount: false)
            }
        }
    }
    
    func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if checkForConversationUpdate(action: action) {
            if CometChat.getLoggedInUser()?.uid == kickedUser.uid {
                removerConversation(for: kickedFrom)
            } else {
                newMessageReceived?(action)
                update(lastMessage: action, updateCount: false)
            }
        }
    }
    
    func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if checkForConversationUpdate(action: action) {
            if CometChat.getLoggedInUser()?.uid == bannedUser.uid {
                removerConversation(for: bannedFrom)
            } else {
                newMessageReceived?(action)
                update(lastMessage: action, updateCount: false)
            }
        }
    }
    
    func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if checkForConversationUpdate(action: action) {
            update(lastMessage: action, updateCount: false)
        }
    }
    
    func ccGroupCreated(group: Group) {
        
        /// creating new group's conversation object
        let newGroupConversation = Conversation()
        newGroupConversation.updatedAt = Date().timeIntervalSince1970
        newGroupConversation.conversationWith = group
        newGroupConversation.conversationType = .group
        newGroupConversation.conversationId = "group_\(group.guid)"
        
        update(conversation: newGroupConversation)
    }
    
}


extension ConversationsViewModel: CometChatGroupDelegate {
    
    func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        if checkForConversationUpdate(action: action) {
            newMessageReceived?(action)
            update(lastMessage: action, updateCount: false)
        }
    }
    
    func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if checkForConversationUpdate(action: action) {
            if CometChat.getLoggedInUser()?.uid == leftUser.uid {
                removerConversation(for: leftGroup)
            } else {
                update(lastMessage: action, updateCount: false)
            }
        }
    }
    
    func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if checkForConversationUpdate(action: action) {
            if CometChat.getLoggedInUser()?.uid == kickedUser.uid {
                removerConversation(for: kickedFrom)
            } else {
                newMessageReceived?(action)
                update(lastMessage: action, updateCount: false)
            }
        }
    }
    
    func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if checkForConversationUpdate(action: action) {
            if CometChat.getLoggedInUser()?.uid == bannedUser.uid {
                removerConversation(for: bannedFrom)
            } else {
                newMessageReceived?(action)
                update(lastMessage: action, updateCount: false)
            }
        }
    }
    
    func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if checkForConversationUpdate(action: action) {
            newMessageReceived?(action)
            update(lastMessage: action, updateCount: false)
        }
    }
    
    func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        /*
         update group object
         appned last message.
         */
        if checkForConversationUpdate(action: action) {
            newMessageReceived?(action)
            
            //THIS NEED TO BE FIXED FROM THE BACKEND
            if scopeChangeduser.uid == CometChat.getLoggedInUser()?.uid {
                group.scope = CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? group.scope
                action.receiver = group
            }
            
            update(lastMessage: action, updateCount: false)
        }
    }
    
    func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        newMessageReceived?(action)
        /*
         
         - updateGroup(group)
         - Append to last message.
         
         */
        if checkForConversationUpdate(action: action) {
            newMessageReceived?(action)
            update(lastMessage: action, updateCount: false)
        }
    }
}
