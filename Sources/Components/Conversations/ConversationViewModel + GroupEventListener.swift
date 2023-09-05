//
//  File.swift
//  
//
//  Created by Abdullah Ansari on 03/02/23.
//

import Foundation
import CometChatSDK

extension ConversationsViewModel: CometChatGroupEventListener {
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        /*
         
         - updateGroup(group)
         - Append to last message.
         
         */
        print("ConversationsViewModel - Events - onGroupMemberAdd")
    }
    
    public func onCreateGroupClick() {
        
        print("ConversationsViewModel - Events - onCreateGroupClick")
    }
    
    public func onGroupCreate(group: Group) {
        
        print("ConversationsViewModel - Events - onGroupCreate")

    }
    
    public func onGroupDelete(group: Group) {
        /*
         
         removeGroup(group)
         
         */
        print("ConversationsViewModel - Events - onGroupCreate")
    }
    
    public func onOwnershipChange(group: Group?, member: GroupMember?) {
        /*
         
         - update group object
         - append last message.
         
         */
        print("ConversationsViewModel - Events - onOwnershipChange")
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup:  Group) {
        
        /*
         remove conversation
         */
        print("ConversationsViewModel - Events - onGroupMemberLeave")
        
    }
    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup:  Group) {
        
        print("ConversationsViewModel - Events - onGroupMemberJoin")
    }
    
    public func onGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        /*
         updateGroup(group)
         Append to last Message.
         */
        print("ConversationsViewModel - Events - onGroupMemberBan")
    }
    
    public func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        /*
         Do Nothing.
         */
        print("ConversationsViewModel - Events - onGroupMemberUnban")
    }
    
    
    public func onGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        /*
         updateGroup(group)
         append to last Message
         */
        print("ConversationsViewModel - Events - onGroupMemberKick")
    }
    
    public func onGroupMemberChangeScope(updatedBy: User , updatedUser: User , scopeChangedTo: CometChat.MemberScope , scopeChangedFrom: CometChat.MemberScope, group: Group) {
        /*
         Do Nothing as per figma
         */
        print("ConversationsViewModel - Events - onGroupMemberChangeScope")
        
    }
}


extension ConversationsViewModel: CometChatGroupDelegate {
    
    func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        newMessageReceived?(action)
        update(lastMessage: action)
        print("ConversationsViewModel - sdk - onGroupMemberJoined")
    }
    
    func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        update(lastMessage: action)
        /*
         remove conversation.
         */
        print("ConversationsViewModel - sdk - onGroupMemberLeft")
    }
    
    func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        newMessageReceived?(action)
        update(lastMessage: action)
        /*
         updateGroup(group)
         append to last Message
         */
        print("ConversationsViewModel - sdk - onGroupMemberKicked")
    }
    
    func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        newMessageReceived?(action)
        update(lastMessage: action)
        print("ConversationsViewModel - sdk - onGroupMemberBanned")
    }
    
    func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        newMessageReceived?(action)
        update(lastMessage: action)
        /*
         Do Nothing
         */
        print("ConversationsViewModel - sdk - onGroupMemberUnbanned")
    }
    
    func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        /*
         update group object
         appned last message.
         */
        newMessageReceived?(action)
        update(lastMessage: action)
        print("ConversationsViewModel - sdk - onGroupMemberScopeChanged")
    }
    
    func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        newMessageReceived?(action)
        /*
         
         - updateGroup(group)
         - Append to last message.
         
         */
        update(lastMessage: action)
        print("ConversationsViewModel - sdk - onMemberAddedToGroup")
    }
}
