//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 05/02/23.
//

import Foundation
import CometChatSDK

extension MessageHeaderViewModel: CometChatGroupEventListener {
    
    public func ccGroupMemberJoined(joinedUser: User, joinedGroup: Group) {
        if joinedGroup.guid == self.group?.guid {
            updateGroupCount?(joinedGroup)
        }
    }
    
    public func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if bannedFrom.guid == self.group?.guid {
            updateGroupCount?(bannedFrom)
        }
    }
    
    public func ccGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User) {
        if groupAddedIn.guid == self.group?.guid {
            updateGroupCount?(groupAddedIn)
        }
    }
    
    public func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if kickedFrom.guid == self.group?.guid {
            updateGroupCount?(kickedFrom)
        }
    }
    
    public func ccOwnershipChanged(group: Group, newOwner: GroupMember) {
        if group.guid == self.group?.guid {
            self.group = group
        }
    }
    
}


extension  MessageHeaderViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        
        print("MessageHeaderViewModel - SDK - onGroupMemberJoined")
        if joinedGroup.guid == self.group?.guid {
            self.group = joinedGroup
            updateGroupCount?(joinedGroup)
        }
        
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        
        print("MessageHeaderViewModel - SDK - onGroupMemberLeft")
        if leftGroup.guid == self.group?.guid {
            self.group = leftGroup
            updateGroupCount?(leftGroup)
        }
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        /*
         updateGroup(group)
         */
        print("MessageHeaderViewModel - SDK - onGroupMemberKicked")
        if kickedFrom.guid == self.group?.guid {
            self.group = kickedFrom
            updateGroupCount?(kickedFrom)
        }
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        
        if bannedFrom.guid == self.group?.guid {
            self.group = bannedFrom
            updateGroupCount?(bannedFrom)
        }
        print("MessageHeaderViewModel - SDK - onGroupMemberBanned")
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        
        if unbannedFrom.guid == self.group?.guid {
            self.group = unbannedFrom
            updateGroupCount?(unbannedFrom)
        }
        print("MessageHeaderViewModel - SDK - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        
        if scopeChangeduser.uid == CometChat.getLoggedInUser()?.uid {
            group.scope = CometChat.GroupMemberScopeType.from(string: scopeChangedTo) ?? group.scope
            action.receiver = group
            self.group = group
        }
        
        print("MessageHeaderViewModel - SDK - onGroupMemberScopeChanged")
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {

        print("MessageHeaderViewModel - SDK - onMemberAddedToGroup")
        if addedTo.guid == self.group?.guid {
            self.group = addedTo
            updateGroupCount?(addedTo)
        }
    }
    
}
