//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 03/02/23.
//

import Foundation
import CometChatPro

extension GroupsViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatPro.ActionMessage, joinedUser: CometChatPro.User, joinedGroup: CometChatPro.Group) {
        /*
         
         update group
         
         */
        if joinedUser == CometChat.getLoggedInUser() {
            self.insert(group: joinedGroup, at: 0)
        }
        print("GroupsViewModel - sdk - onGroupMemberJoined")
    }
    
    public func onGroupMemberLeft(action: CometChatPro.ActionMessage, leftUser: CometChatPro.User, leftGroup: CometChatPro.Group) {
        /*
         if group is private
                  remove group
         else { change hasJoined to false}
         */
        if leftUser == CometChat.getLoggedInUser() {
            self.remove(group: leftGroup)
        }
        print("GroupsViewModel - sdk - onGroupMemberLeft")
    }
    
    public func onGroupMemberKicked(action: CometChatPro.ActionMessage, kickedUser: CometChatPro.User, kickedBy: CometChatPro.User, kickedFrom: CometChatPro.Group) {
        /*
         updateGroup(group)
         */
        if kickedUser == CometChat.getLoggedInUser() {
            self.remove(group: kickedFrom)
        }
        print("GroupsViewModel - sdk - onGroupMemberKicked")
    }
    
    public func onGroupMemberBanned(action: CometChatPro.ActionMessage, bannedUser: CometChatPro.User, bannedBy: CometChatPro.User, bannedFrom: CometChatPro.Group) {
        /*
         updateGroup(group)
         */
        if bannedUser == CometChat.getLoggedInUser() {
            self.remove(group: bannedFrom)
        }
        print("GroupsViewModel - sdk - onGroupMemberBanned")
    }
    
    public func onGroupMemberUnbanned(action: CometChatPro.ActionMessage, unbannedUser: CometChatPro.User, unbannedBy: CometChatPro.User, unbannedFrom: CometChatPro.Group) {
        /*
         Do Nothing.
         */
        print("GroupsViewModel - sdk - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatPro.ActionMessage, scopeChangeduser: CometChatPro.User, scopeChangedBy: CometChatPro.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatPro.Group) {
        print("GroupsViewModel - sdk - onGroupMemberScopeChanged")
    }
    
    public func onMemberAddedToGroup(action: CometChatPro.ActionMessage, addedBy: CometChatPro.User, addedUser: CometChatPro.User, addedTo: CometChatPro.Group) {
        /*
         
         update Group
         
         */
        if addedUser == CometChat.getLoggedInUser() {
            self.insert(group: addedTo, at: 0)
        }
        print("GroupsViewModel - sdk - onMemberAddedToGroup")
    }
    
}


extension GroupsViewModel: CometChatGroupEventListener {
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        print("MessageHeaderViewModel - Events - onGroupMemberAdd")
    }
    
    public func onCreateGroupClick() {
        
        print("MessageHeaderViewModel - Events - onCreateGroupClick")
    }
    
    public func onGroupCreate(group: Group) {
        
        print("MessageHeaderViewModel - Events - onGroupCreate")
        // when new group create.
        insert(group: group, at: 0)

    }
    
    public func onGroupDelete(group: Group) {
        /*
         Remove Group
         */
        print("MessageHeaderViewModel - Events - onGroupCreate")
        remove(group: group)
    }
    
    public func onOwnershipChange(group: Group?, member: GroupMember?) {
        /*
         update group object.
         */
        print("MessageHeaderViewModel - Events - onOwnershipChange")
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup:  Group) {
        /*
         if group is private
                  remove group
         else { change hasJoined to false}
         */
        print("MessageHeaderViewModel - Events - onGroupMemberLeave")
        if leftGroup.groupType == .private {
            remove(group: leftGroup)
        } else {
            leftGroup.hasJoined = false
        }
    }
    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup:  Group) {
        /*
         
         update group
         
         */
        print("MessageHeaderViewModel - Events - onGroupMemberJoin")
        update(group: joinedGroup)
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
}

/*
extension GroupsViewModel: CometChatGroupEventListener {

    public func onGroupCreate(group: Group) {
        // when new group create.
        insert(group: group, at: 0)
    }
    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup: Group) {
       update(group: joinedGroup)
    }
    
    public func onGroupDelete(group: Group) {
        remove(group: group)
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup: Group) {
        if leftGroup.groupType == .private {
            remove(group: leftGroup)
        } else {
            leftGroup.hasJoined = false
        }
    }
    
    public func onItemClick(group: Group, index: IndexPath?) {
        
    }
    
    public func onOwnershipChange(group: Group?, member: GroupMember?) {
        print("onOwnershipChange")
    }
}
*/
