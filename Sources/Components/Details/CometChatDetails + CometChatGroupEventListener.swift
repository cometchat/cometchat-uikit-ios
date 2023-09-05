//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 01/02/23.
//

import Foundation
import CometChatSDK

extension DetailsViewModel: CometChatGroupEventListener {
    
    func onItemClick(group: Group, index: IndexPath?) {
        print("Details2ViewModel - Events - onItemClick")
    }
        
    func onItemLongClick(group: Group, index: IndexPath?) {
        
        print("Details2ViewModel - Events - onItemLongClick")
    }
    
    func onCreateGroupClick() {
        
        print("Details2ViewModel - Events - onCreateGroupClick")
    }
    
    func onGroupCreate(group: Group) {
        
        print("Details2ViewModel - Events - onGroupCreate")
    }
    
    func onGroupDelete(group: Group) {
        
        print("Details2ViewModel - Events - onGroupCreate")
    }
    
    func onOwnershipChange(group: Group?, member: GroupMember?) {
        /*
         
         update group object.
         
         */
        print("Details2ViewModel - Events - onOwnershipChange")
    }
    
    func onGroupMemberLeave(leftUser: User, leftGroup:  Group) {
        
        print("Details2ViewModel - Events - onGroupMemberLeave")
    }
    
    func onGroupMemberJoin(joinedUser: User, joinedGroup:  Group) {
        
        print("Details2ViewModel - Events - onGroupMemberJoin")
    }
        
    func onGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        /*
         update group
         */
        print("Details2ViewModel - Events - onGroupMemberKick")
    }
    
    func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        /*
         
         updateGroup(group)
         
         */
        print("Details2ViewModel - Events - onGroupMemberAdd")
    }
    
    func onGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        /*
         updateGroup(group)
         */
        print("Details2ViewModel - Events - onGroupMemberBan")
    }
    
    func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        /*
         Do Nothing.
         */
        print("Details2ViewModel - Events - onGroupMemberUnban")
    }

    
    func onGroupMemberChangeScope(updatedBy: User , updatedUser: User , scopeChangedTo: CometChat.MemberScope , scopeChangedFrom: CometChat.MemberScope, group: Group) {
        /*
         Do Nothing as per figma
         */
        print("Details2ViewModel - Events - onGroupMemberChangeScope")
    }
    
    func onError(group: Group?, error: CometChatException) {
        
        print("Details2ViewModel - Events - onError")
    }
    
}

extension DetailsViewModel: CometChatGroupDelegate {
    
    func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        
        print("Details - SDK - onGroupMemberJoined")
        
    }
    
    func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        
        print("Details - SDK - onGroupMemberLeft")
    }
    
    func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        /*
          update group
         */
        print("Details - SDK - onGroupMemberKicked")
    }
    
    func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        /*
         update group
         */
        print("Details - SDK - onGroupMemberBanned")
    }
    
    func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        /*
         Do Nothing.
         */
        print("Details - SDK - onGroupMemberUnbanned")
    }
    
    func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
       
        print("Details - SDK - onGroupMemberScopeChanged")
    }
    
    func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        /*
         
         update group
         
         */
        print("Details - SDK - onMemberAddedToGroup")
    }
    
}

