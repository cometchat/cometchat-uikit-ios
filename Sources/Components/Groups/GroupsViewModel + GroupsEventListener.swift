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
        /*
         
         update group
         
         */
        if joinedUser == CometChat.getLoggedInUser() {
            self.insert(group: joinedGroup, at: 0)
        }
        print("GroupsViewModel - sdk - onGroupMemberJoined")
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
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
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        /*
         updateGroup(group)
         */
        if kickedUser == CometChat.getLoggedInUser() {
            self.remove(group: kickedFrom)
        }
        print("GroupsViewModel - sdk - onGroupMemberKicked")
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        /*
         updateGroup(group)
         */
        if bannedUser == CometChat.getLoggedInUser() {
            self.remove(group: bannedFrom)
        }
        print("GroupsViewModel - sdk - onGroupMemberBanned")
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        /*
         Do Nothing.
         */
        print("GroupsViewModel - sdk - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        print("GroupsViewModel - sdk - onGroupMemberScopeChanged")
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
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
