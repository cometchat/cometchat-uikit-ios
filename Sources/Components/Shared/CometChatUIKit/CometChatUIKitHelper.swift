//
//  CometChatUIKitHelper.swift
//  CometChatUIKitHelper
//
//  Created by Abdullah Ansari on 27/06/22.
//

import Foundation
import CometChatSDK

final public class CometChatUIKitHelper {
    
    public static func onMessageSent(message: BaseMessage, status: MessageStatus) {
        CometChatMessageEvents.emitOnMessageSent(message: message, status: status)
    }
    
    public static func onMessageEdited(message: BaseMessage, status: MessageStatus) {
        CometChatMessageEvents.emitOnMessageEdit(message: message, status: status)
    }

    public static func onMessageDeleted(message: BaseMessage) {
        CometChatMessageEvents.emitOnMessageDelete(message: message)
    }
    
    public static func onMessageRead(message: BaseMessage) {
        CometChatMessageEvents.emitOnMessageRead(message: message)
    }
    
    public static func onLiveReaction(message: TransientMessage) {
        CometChatMessageEvents.emitOnLiveReaction(reaction: message)
    }
    
    ///Methods related to users
    public static func onUserBlocked(user: User) {
        CometChatUserEvents.emitOnUserBlock(user: user)
    }
    
    public static func onUserUnblocked(user: User) {
        CometChatUserEvents.emitOnUserUnblock(user: user)
    }
    
    ///Methods related to conversations
    public static func onConversationDeleted(conversation: Conversation) {
        CometChatConversationEvents.emitConversationDelete(conversation: conversation)
    }
    
    ///Methods related to groups
    public static func onGroupCreated(group: Group) {
        CometChatGroupEvents.emitOnGroupCreate(group: group)
    }
    
    public static func onGroupDeleted(group: Group) {
        CometChatGroupEvents.emitOnGroupDelete(group: group)
    }
    
    public static func onGroupLeft(user: User , group: Group) {
        CometChatGroupEvents.emitOnGroupMemberLeave(leftUser: user, leftGroup: group)
    }
    
    public static func onGroupMemberScopeChanged(updatedBy: User, updatedUser: User, scopeChangedTo: CometChat.MemberScope, scopeChangedFrom: CometChat.MemberScope, group: Group) {
        CometChatGroupEvents.emitOnGroupMemberChangeScope(updatedBy: updatedBy, updatedUser: updatedUser, scopeChangedTo: scopeChangedTo, scopeChangedFrom: scopeChangedFrom, group: group)
    }
    
    public static func onGroupMemberBanned(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        CometChatGroupEvents.emitOnGroupMemberBan(bannedUser: bannedUser, bannedGroup: bannedGroup, bannedBy: bannedBy)
    }
    
    public static func onGroupMemberKicked(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        CometChatGroupEvents.emitOnGroupMemberKick(kickedUser: kickedUser, kickedGroup: kickedGroup, kickedBy: kickedBy)
    }
    
    public static func onGroupMemberUnbanned(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        CometChatGroupEvents.emitOnGroupMemberUnban(unbannedUserUser: unbannedUserUser, unbannedUserGroup: unbannedUserGroup, unbannedBy: unbannedBy)
    }
    
    public static func onGroupMemberJoined(joinedUser: User, joinedGroup: Group) {
        CometChatGroupEvents.emitOnGroupMemberJoin(joinedUser: joinedUser, joinedGroup: joinedGroup)
    }
    
    public static func onGroupMemberAdded(group: Group, members: [GroupMember], addedBy: User) {
        CometChatGroupEvents.emitOnGroupMemberAdd(group: group, members: members, addedBy: addedBy)
    }
    
    public static func onOwnershipChanged(group: Group?, member: GroupMember?) {
        CometChatGroupEvents.emitOnOwnershipChange(group: group, member: member)
    }
    
    //Message ui events
    //=================
    public static func showPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?) {
        CometChatUIEvents.emitShowPanel(id: id, alignment: alignment, view: view)
    }
    
    public static func hidePanel(id: [String:Any]?, alignment: UIAlignment) {
        CometChatUIEvents.emitHidePanel(id: id , alignment: alignment)
    }
    
    public static func onActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?) {
        CometChatUIEvents.emitOnActiveChatChanged(id: id, lastMessage: lastMessage, user: user, group: group)
    }
}
