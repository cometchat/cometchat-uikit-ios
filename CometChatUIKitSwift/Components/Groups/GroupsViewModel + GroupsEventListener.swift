//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 03/02/23.
//

import Foundation
import CometChatSDK

extension GroupsViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        
        if joinedGroup.groupType == .private {
            if joinedUser.uid == CometChat.getLoggedInUser()?.uid {
                insert(group: joinedGroup, at: 0)
            }
        } else {
            update(group: joinedGroup)
        }
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        
        if leftGroup.groupType == .private {
            if leftUser.uid == CometChat.getLoggedInUser()?.uid {
                self.remove(group: leftGroup)
            }
        } else {
            update(group: leftGroup)
        }
        
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        update(group: kickedFrom)
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        
        if bannedUser.uid == CometChat.getLoggedInUser()?.uid {
            self.remove(group: bannedFrom)
        } else {
            update(group: bannedFrom)
        }
        
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        
        if unbannedUser.uid == CometChat.getLoggedInUser()?.uid {
            add(group: unbannedFrom)
        } else {
            update(group: unbannedFrom)
        }
        
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        update(group: group)
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        
        if addedTo.groupType == .private {
            if addedUser == CometChat.getLoggedInUser() {
                self.insert(group: addedTo, at: 0)
            }
        } else {
            update(group: addedTo)
        }
        
    }
    
}

//Local Group Event Listener
extension GroupsViewModel: CometChatGroupEventListener {
    
    public func ccGroupCreated(group: Group) {
        insert(group: group, at: 0)
    }
    
    public func ccGroupDeleted(group: Group) {
        remove(group: group)
    }
    
    public func ccGroupMemberJoined(joinedUser: User, joinedGroup: Group) {
        update(group: joinedGroup)
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup:  Group) {
        if leftGroup.groupType == .private {
            remove(group: leftGroup)
        } else {
            leftGroup.hasJoined = false
            update(group: leftGroup)
        }
    }
    
    public func ccOwnershipChanged(group: Group, newOwner: GroupMember) {
        update(group: group)
    }
    
    public func ccGroupLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        update(group: leftGroup)
    }
    
    public func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        update(group: bannedFrom)
    }
    
    public func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        update(group: kickedFrom)
    }
    
}
