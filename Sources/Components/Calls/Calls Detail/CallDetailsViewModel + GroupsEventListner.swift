//
//  File.swift
//  
//
//  Created by Ajay Verma on 13/03/23.
//

import Foundation
import CometChatSDK

extension CallDetailsViewModel: CometChatGroupEventListener {
    
    
    public func onItemClick(group: Group, index: IndexPath?) {
        
        print("MessageHeaderViewModel - Events - onItemClick")
    }
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember]) {
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
    
    public func onGroupMemberBan(bannedUser: User, bannedGroup:  Group) {
        /*
         updateGroup(group)
         */
        print("MessageHeaderViewModel - Events - onGroupMemberBan")
    }
    
    public func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup:  Group) {
        /*
         Do Nothing.
         */
        print("MessageHeaderViewModel - Events - onGroupMemberUnban")
    }
    
    
    public func onGroupMemberKick(kickedUser: User, kickedGroup:  Group) {
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



extension  CallDetailsViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        
        print("MessageHeaderViewModel - SDK - onGroupMemberJoined")
        if joinedGroup.guid == self.group?.guid {
            updateGroupCount?(true)
        }
        
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        
        print("MessageHeaderViewModel - SDK - onGroupMemberLeft")
        if leftGroup.guid == self.group?.guid {
            updateGroupCount?(true)
        }
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        /*
         updateGroup(group)
         */
        print("MessageHeaderViewModel - SDK - onGroupMemberKicked")
        if kickedFrom.guid == self.group?.guid {
            updateGroupCount?(true)
        }
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        /*
         updateGroup(group)
         */
        print("MessageHeaderViewModel - SDK - onGroupMemberBanned")
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        /*
         Do Nothing.
         */
        print("MessageHeaderViewModel - SDK - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        
        print("MessageHeaderViewModel - SDK - onGroupMemberScopeChanged")
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        /*
         
         updateGroup(group)
         
         */
        print("MessageHeaderViewModel - SDK - onMemberAddedToGroup")
        if addedTo.guid == self.group?.guid {
            updateGroupCount?(true)
        }
    }
    
}
