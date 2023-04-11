//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 05/02/23.
//

import Foundation
import CometChatPro

extension CometChatConversationsWithMessages: CometChatGroupEventListener {
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        /*
         
         - updateGroup(group)
         - Append to last message.
         
         */
        print("CometChatConversationsWithMessages - Events - onGroupMemberAdd")
    }
    
    public func onCreateGroupClick() {
        
        print("CometChatConversationsWithMessages - Events - onCreateGroupClick")
    }
    
    public func onGroupCreate(group: Group) {
        
        print("CometChatConversationsWithMessages - Events - onGroupCreate")

    }
    
    public func onGroupDelete(group: Group) {
        /*
         
         close messages.
         
         */
        print("CometChatConversationsWithMessages - Events - onGroupCreate")
    }
    
    public func onOwnershipChange(group: Group?, member: GroupMember?) {
        /*
         
         update the group object.
         
         */
        print("CometChatConversationsWithMessages - Events - onOwnershipChange")
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup:  Group) {
        
        print("CometChatConversationsWithMessages - Events - onGroupMemberLeave")
        
    }
    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup:  Group) {
        
        print("CometChatConversationsWithMessages - Events - onGroupMemberJoin")
    }
    
    public func onGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        /*
         updateGroup(group)
         upate active group
         */
        print("CometChatConversationsWithMessages - Events - onGroupMemberBan")
    }
    
    public func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        /*
         Do Nothing.
         */
        print("CometChatConversationsWithMessages - Events - onGroupMemberUnban")
    }
    
    
    public func onGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        print("CometChatConversationsWithMessages - Events - onGroupMemberKick")
    }
    
    public func onGroupMemberChangeScope(updatedBy: User , updatedUser: User , scopeChangedTo: CometChat.MemberScope , scopeChangedFrom: CometChat.MemberScope, group: Group) {
        /*
         Do Nothing as per figma
         */
        print("CometChatConversationsWithMessages - Events - onGroupMemberChangeScope")
    }

}



extension CometChatConversationsWithMessages: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatPro.ActionMessage, joinedUser: CometChatPro.User, joinedGroup: CometChatPro.Group) {
    
        print("CometChatConversationsWithMessages - sdk - onGroupMemberJoined")
    }
    
    public func onGroupMemberLeft(action: CometChatPro.ActionMessage, leftUser: CometChatPro.User, leftGroup: CometChatPro.Group) {
     
        print("CometChatConversationsWithMessages - sdk - onGroupMemberLeft")
    }
    
    public func onGroupMemberKicked(action: CometChatPro.ActionMessage, kickedUser: CometChatPro.User, kickedBy: CometChatPro.User, kickedFrom: CometChatPro.Group) {
     
        print("CometChatConversationsWithMessages - sdk - onGroupMemberKicked")
    }
    
    public func onGroupMemberBanned(action: CometChatPro.ActionMessage, bannedUser: CometChatPro.User, bannedBy: CometChatPro.User, bannedFrom: CometChatPro.Group) {
     /*
      updateGroup(group)
      update active group
      */
        print("CometChatConversationsWithMessages - sdk - onGroupMemberBanned")
    }
    
    public func onGroupMemberUnbanned(action: CometChatPro.ActionMessage, unbannedUser: CometChatPro.User, unbannedBy: CometChatPro.User, unbannedFrom: CometChatPro.Group) {
        /*
         Do Nothing.
         */
        print("CometChatConversationsWithMessages - sdk - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatPro.ActionMessage, scopeChangeduser: CometChatPro.User, scopeChangedBy: CometChatPro.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatPro.Group) {
        print("CometChatConversationsWithMessages - sdk - onGroupMemberScopeChanged")
    }
    
    public func onMemberAddedToGroup(action: CometChatPro.ActionMessage, addedBy: CometChatPro.User, addedUser: CometChatPro.User, addedTo: CometChatPro.Group) {
        /*
         
         - updateGroup(group)
         - Append to last message.
         
         */
        print("CometChatConversationsWithMessages - sdk - onMemberAddedToGroup")
    }
    
}
