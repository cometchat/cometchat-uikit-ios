//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 05/02/23.
//

import Foundation
import CometChatSDK

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
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
    
        print("CometChatConversationsWithMessages - sdk - onGroupMemberJoined")
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
     
        print("CometChatConversationsWithMessages - sdk - onGroupMemberLeft")
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
     
        print("CometChatConversationsWithMessages - sdk - onGroupMemberKicked")
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
     /*
      updateGroup(group)
      update active group
      */
        print("CometChatConversationsWithMessages - sdk - onGroupMemberBanned")
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        /*
         Do Nothing.
         */
        print("CometChatConversationsWithMessages - sdk - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        print("CometChatConversationsWithMessages - sdk - onGroupMemberScopeChanged")
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        /*
         
         - updateGroup(group)
         - Append to last message.
         
         */
        print("CometChatConversationsWithMessages - sdk - onMemberAddedToGroup")
    }
    
}
