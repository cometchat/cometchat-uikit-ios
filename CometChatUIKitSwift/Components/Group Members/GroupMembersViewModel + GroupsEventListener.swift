//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 05/02/23.
//

import Foundation
import CometChatSDK

extension GroupMembersViewModel: CometChatGroupEventListener {
    
    public func ccOwnershipChanged(group: Group, newOwner: GroupMember) {
        if group.guid == self.group.guid {
            update(groupMember: newOwner)
        }
    }
    
    public func ccGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User) {
        if groupAddedIn.guid == self.group.guid {
            for member in usersAdded {
                if let groupMember = member as? GroupMember {
                    add(groupMember: groupMember)
                }
            }
        }
    }
    
    public func ccGroupMemberJoined(joinedUser: User, joinedGroup: Group) {
        if joinedGroup.guid == self.group.guid {
            if let groupMember = joinedUser as? GroupMember {
                add(groupMember: groupMember)
            }
        }
    }
    
    public func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        
        if group.guid == self.group.guid {
            
            let groupMember = updatedUser.toGroupMember(scope: CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? .participant)
            update(groupMember: groupMember)
            
            if updatedUser.uid == CometChat.getLoggedInUser()?.uid {
                self.group.scope = CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? group.scope //updating group scope
                self.reload?()
            }
        }
        
    }
    
}

extension GroupMembersViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        if joinedGroup.guid == self.group.guid {
            let groupMember = joinedUser.toGroupMember()
            add(groupMember: groupMember)
        }
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        if leftGroup.guid == self.group.guid {
            let groupMember = leftUser.toGroupMember()
            remove(groupMember: groupMember)
        }
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        if kickedFrom.guid == self.group.guid {
            let groupMember = kickedUser.toGroupMember()
            remove(groupMember: groupMember)
        }
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        if bannedFrom.guid == self.group.guid {
            let groupMember = bannedUser.toGroupMember()
            remove(groupMember: groupMember)
        }
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        
        
        if group.guid == self.group.guid {
            
            let groupMember = scopeChangeduser.toGroupMember(scope: CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? .participant)
            update(groupMember: groupMember)
            
            if scopeChangeduser.uid == CometChat.getLoggedInUser()?.uid {
                self.group.scope = CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? group.scope //updating group scope
                self.reload?()
            }
        }
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        
        if addedTo.guid == self.group.guid {
            let groupMember = addedUser.toGroupMember(scope: .participant)
            add(groupMember: groupMember)
        }
    }
    
}
