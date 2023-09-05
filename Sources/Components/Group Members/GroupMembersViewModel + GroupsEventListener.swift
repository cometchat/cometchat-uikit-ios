//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 05/02/23.
//

import Foundation
import CometChatSDK

extension GroupMembersViewModel: CometChatGroupEventListener {
    
    public func onOwnershipChange(group: Group?, member: GroupMember?) {
        if group?.guid == self.group.guid {
            if let member = member {
                update(groupMember: member)
            }
        }
        
        print("GroupMembersViewModel - events - onOwnershipChange")
    }
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        if group.guid == self.group.guid {
            for member in members {
                add(groupMember: member)
            }
        }
        
        print("GroupMembersViewModel - events - onGroupMemberAdd")
    }
    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup: Group) {
        if group.guid == self.group.guid {
            let member = GroupMember(UID: joinedUser.uid ?? "", groupMemberScope: .participant)
            member.avatar = joinedUser.avatar
            add(groupMember: member)
        }
        
        print("GroupMembersViewModel - events - onGroupMemberJoin")
    }
    
    public func onGroupDelete(group: Group) {
        
        print("GroupMembersViewModel - events - onGroupDelete")
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup: Group) {
        
        print("GroupMembersViewModel - events - onGroupMemberLeave")
    }
    
    public func onGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        print("GroupMembersViewModel - events - onGroupMemberBan")
    }
    
    public func onGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        print("GroupMembersViewModel - events - onGroupMemberKick")
    }
    
    public func onGroupMemberChangeScope(updatedBy: User, updatedUser: User, scopeChangedTo: CometChat.MemberScope, scopeChangedFrom: CometChat.MemberScope, group: Group) {
        /*
         Do Nothing as per figma
         */
        print("GroupMembersViewModel - events - onGroupMemberChangeScope")
    }
    
    public func onError(group: Group?, error: CometChatException) {
        
        print("GroupMembersViewModel - events - onError")
    }
}

extension GroupMembersViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        
        print("GroupMembersViewModel - sdk - onGroupMemberJoined")
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        
        print("GroupMembersViewModel - sdk - onGroupMemberLeft")
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        
        print("GroupMembersViewModel - sdk - onGroupMemberKicked")
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        
        print("GroupMembersViewModel - sdk - onGroupMemberBanned")
        
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        /*
         Do Nothing.
         */
        
        print("GroupMembersViewModel - sdk - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        
        print("GroupMembersViewModel - sdk - onGroupMemberScopeChanged")
        
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        
        print("GroupMembersViewModel - sdk - onMemberAddedToGroup")
    }
}
