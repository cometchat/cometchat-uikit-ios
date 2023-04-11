//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 05/02/23.
//

import Foundation
import CometChatPro

extension MessageHeaderViewModel: CometChatGroupEventListener {
    
    
    public func onItemClick(group: Group, index: IndexPath?) {
        
        print("MessageHeaderViewModel - Events - onItemClick")
    }
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        /*
         
         update group
         
         */
        print("MessageHeaderViewModel - Events - onGroupMemberAdd")
    }
    
    public func onItemLongClick(group: Group, index: IndexPath?) {
        
        print("MessageHeaderViewModel - Events - onItemLongClick")
    }
    
    public func onCreateGroupClick() {
        
        print("MessageHeaderViewModel - Events - onCreateGroupClick")
    }
    
    public func onGroupCreate(group: Group) {
        
        print("MessageHeaderViewModel - Events - onGroupCreate")
    }
    
    public func onGroupDelete(group: Group) {
        
        print("MessageHeaderViewModel - Events - onGroupCreate")
    }
    
    public func onOwnershipChange(group: Group?, member: GroupMember?) {
        /*
         update message
         */
        print("MessageHeaderViewModel - Events - onOwnershipChange")
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup:  Group) {
        
        print("MessageHeaderViewModel - Events - onGroupMemberLeave")
    }
    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup:  Group) {
        
        print("MessageHeaderViewModel - Events - onGroupMemberJoin")
    }
        
    public func onGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        /*
         updateGroup(group)
         */
        print("MessageHeaderViewModel - Events - onGroupMemberBan")
    }
        
    public func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        /*
         Do Nothing.
         */
        print("MessageHeaderViewModel - Events - onGroupMemberUnban")
    }
        
    public func onGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        /*
         updateGroup(group)
         */
        print("MessageHeaderViewModel - Events - onGroupMemberKick")
    }
    
    public func onGroupMemberChangeScope(updatedBy: User , updatedUser: User , scopeChangedTo: CometChat.MemberScope , scopeChangedFrom: CometChat.MemberScope, group: Group) {
        /*
         Do Nothing as per figma
         */
        print("MessageHeaderViewModel - Events - onGroupMemberChangeScope")
    }
    
    public func onError(group: Group?, error: CometChatException) {
        
        print("MessageHeaderViewModel - Events - onError")
    }
    
}


extension  MessageHeaderViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatPro.ActionMessage, joinedUser: CometChatPro.User, joinedGroup: CometChatPro.Group) {
        
        print("MessageHeaderViewModel - SDK - onGroupMemberJoined")
        if joinedGroup.guid == self.group?.guid {
            updateGroupCount?(true)
        }
        
    }
    
    public func onGroupMemberLeft(action: CometChatPro.ActionMessage, leftUser: CometChatPro.User, leftGroup: CometChatPro.Group) {
        
        print("MessageHeaderViewModel - SDK - onGroupMemberLeft")
        if leftGroup.guid == self.group?.guid {
            updateGroupCount?(true)
        }
    }
    
    public func onGroupMemberKicked(action: CometChatPro.ActionMessage, kickedUser: CometChatPro.User, kickedBy: CometChatPro.User, kickedFrom: CometChatPro.Group) {
        /*
         updateGroup(group)
         */
        print("MessageHeaderViewModel - SDK - onGroupMemberKicked")
        if kickedFrom.guid == self.group?.guid {
            updateGroupCount?(true)
        }
    }
    
    public func onGroupMemberBanned(action: CometChatPro.ActionMessage, bannedUser: CometChatPro.User, bannedBy: CometChatPro.User, bannedFrom: CometChatPro.Group) {
        /*
         updateGroup(group)
         */
        print("MessageHeaderViewModel - SDK - onGroupMemberBanned")
    }
    
    public func onGroupMemberUnbanned(action: CometChatPro.ActionMessage, unbannedUser: CometChatPro.User, unbannedBy: CometChatPro.User, unbannedFrom: CometChatPro.Group) {
        /*
         Do Nothing.
         */
        print("MessageHeaderViewModel - SDK - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatPro.ActionMessage, scopeChangeduser: CometChatPro.User, scopeChangedBy: CometChatPro.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatPro.Group) {
        
        print("MessageHeaderViewModel - SDK - onGroupMemberScopeChanged")
    }
    
    public func onMemberAddedToGroup(action: CometChatPro.ActionMessage, addedBy: CometChatPro.User, addedUser: CometChatPro.User, addedTo: CometChatPro.Group) {
        /*
         
         updateGroup(group)
         
         */
        print("MessageHeaderViewModel - SDK - onMemberAddedToGroup")
        if addedTo.guid == self.group?.guid {
            updateGroupCount?(true)
        }
    }
//    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
//
//    }
    
//    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
//        if leftGroup.guid == self.group?.guid {
//            updateGroupCount?(true)
//        }
//    }
    
//    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
//        if kickedFrom.guid == self.group?.guid {
//            updateGroupCount?(true)
//        }
//    }
//
//    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {}
//
//    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {}
//
//    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
//
//        print("onGroupMemberScopeChanged")
//
//    }
    
//    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
//        if addedTo.guid == self.group?.guid {
//            updateGroupCount?(true)
//        }
//    }
    
}
