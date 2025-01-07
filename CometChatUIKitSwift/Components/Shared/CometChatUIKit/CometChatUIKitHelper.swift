//
//  CometChatUIKitHelper.swift
//  CometChatUIKitHelper
//
//  Created by Abdullah Ansari on 27/06/22.
//

import Foundation
import CometChatSDK

//TODO: CC
final public class CometChatUIKitHelper {
    
    public static func onMessageSent(message: BaseMessage, status: MessageStatus) {
        CometChatMessageEvents.ccMessageSent(message: message, status: status)
    }
    
    public static func onMessageEdited(message: BaseMessage, status: MessageStatus) {
        CometChatMessageEvents.ccMessageEdited(message: message, status: status)
    }

    public static func onMessageDeleted(message: BaseMessage) {
        CometChatMessageEvents.onMessageDeleted(message: message)
    }
    
    public static func onMessageRead(message: BaseMessage) {
        CometChatMessageEvents.ccMessageRead(message: message)
    }
    
    public static func onLiveReaction(message: TransientMessage) {
        CometChatMessageEvents.ccLiveReaction(reaction: message)
    }
    
    ///Methods related to users
    public static func onUserBlocked(user: User) {
        CometChatUserEvents.ccUserBlocked(user: user)
    }
    
    public static func onUserUnblocked(user: User) {
        CometChatUserEvents.ccUserUnblocked(user: user)
    }
    
    ///Methods related to conversations
    public static func onConversationDeleted(conversation: Conversation) {
        CometChatConversationEvents.ccConversationDeleted(conversation: conversation)
    }
    
    ///Methods related to groups
    public static func onGroupCreated(group: Group) {
        CometChatGroupEvents.ccGroupCreated(group: group)
    }
    
    public static func onGroupDeleted(group: Group) {
        CometChatGroupEvents.ccGroupDeleted(group: group)
    }
    
    public static func onGroupLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        CometChatGroupEvents.ccGroupLeft(action: action, leftUser: leftUser, leftGroup: leftGroup)
    }
    
    public static func onGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        CometChatGroupEvents.ccGroupMemberScopeChanged(action: action, updatedUser: updatedUser, scopeChangedTo: scopeChangedTo, scopeChangedFrom: scopeChangedFrom, group: group)
    }
    
    public static func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        CometChatGroupEvents.ccGroupMemberBanned(action: action, bannedUser: bannedUser, bannedBy: bannedBy, bannedFrom: bannedFrom)
    }
    
    public static func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        CometChatGroupEvents.ccGroupMemberKicked(action: action, kickedUser: kickedUser, kickedBy: kickedBy, kickedFrom: kickedFrom)
    }
    
    public static func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        CometChatGroupEvents.ccGroupMemberUnbanned(action: action, unbannedUser: unbannedUser, unbannedBy: unbannedBy, unbannedFrom: unbannedFrom)
    }
    
    public static func onGroupMemberJoined(joinedUser: User, joinedGroup: Group) {
        CometChatGroupEvents.ccGroupMemberJoined(joinedUser: joinedUser, joinedGroup: joinedGroup)
    }
    
    public static func onGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User) {
        CometChatGroupEvents.ccGroupMemberAdded(messages: messages, usersAdded: usersAdded, groupAddedIn: groupAddedIn, addedBy: addedBy)
    }
    
    public static func onOwnershipChanged(group: Group, newOwner: GroupMember) {
        CometChatGroupEvents.ccOwnershipChanged(group: group, newOwner: newOwner)
    }
    
    //Message ui events
    //=================
    public static func showPanel(id: [String:Any]?, alignment: UIAlignment, view: UIView?) {
        CometChatUIEvents.showPanel(id: id, alignment: alignment, view: view)
    }
    
    public static func hidePanel(id: [String:Any]?, alignment: UIAlignment) {
        CometChatUIEvents.hidePanel(id: id , alignment: alignment)
    }
    
    public static func onActiveChatChanged(id: [String:Any]?, lastMessage: BaseMessage?, user: User?, group: Group?) {
        CometChatUIEvents.ccActiveChatChanged(id: id, lastMessage: lastMessage, user: user, group: group)
    }
}


//MARK: Deprecated Functions
extension CometChatUIKitHelper {
    
    @available(*, deprecated, message: "Use onGroupLeft(action: ActionMessage, leftUser: User, leftGroup: Group) instead")
    public static func onGroupLeft(user: User , group: Group) {
        CometChatGroupEvents.emitOnGroupMemberLeave(leftUser: user, leftGroup: group)
    }
    
    @available(*, deprecated, message: "Use onGroupMemberAdded(group: Group, newOwner: GroupMember) instead")
    public static func onOwnershipChanged(group: Group?, member: GroupMember?) {
        CometChatGroupEvents.emitOnOwnershipChange(group: group, member: member)
    }
    
    @available(*, deprecated, message: "Use onGroupMemberAdded(group: Group, members: [GroupMember], addedBy: User) instead")
    public static func onGroupMemberAdded(group: Group, members: [GroupMember], addedBy: User) {
        CometChatGroupEvents.emitOnGroupMemberAdd(group: group, members: members, addedBy: addedBy)
    }
    
    @available(*, deprecated, message: "Use onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) instead")
    public static func onGroupMemberUnbanned(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        CometChatGroupEvents.emitOnGroupMemberUnban(unbannedUserUser: unbannedUserUser, unbannedUserGroup: unbannedUserGroup, unbannedBy: unbannedBy)
    }
    
    
    @available(*, deprecated, message: "Use onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) instead")
    public static func onGroupMemberKicked(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        CometChatGroupEvents.emitOnGroupMemberKick(kickedUser: kickedUser, kickedGroup: kickedGroup, kickedBy: kickedBy)
    }
    
    
    @available(*, deprecated, message: "Use onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) instead")
    public static func onGroupMemberBanned(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        CometChatGroupEvents.emitOnGroupMemberBan(bannedUser: bannedUser, bannedGroup: bannedGroup, bannedBy: bannedBy)
    }
    
    @available(*, deprecated, message: "Use onGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) instead")
    public static func onGroupMemberScopeChanged(updatedBy: User, updatedUser: User, scopeChangedTo: CometChat.MemberScope, scopeChangedFrom: CometChat.MemberScope, group: Group) {
        CometChatGroupEvents.emitOnGroupMemberChangeScope(updatedBy: updatedBy, updatedUser: updatedUser, scopeChangedTo: scopeChangedTo, scopeChangedFrom: scopeChangedFrom, group: group)
    }
}
