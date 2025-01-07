//
//  File.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 16/06/24.
//

import Foundation
import CometChatSDK

@objc public protocol CometChatGroupEventListener {
    
    // MARK: - New Functions
    
    ///This will get triggered when a group is created successfully
    @objc optional func ccGroupCreated(group: Group)
    
    ///This will get triggered when a group is deleted successfully
    @objc optional func ccGroupDeleted(group: Group)
    
    ///This will get triggered when logged in user leaves the group
    @objc optional func ccGroupLeft(action: ActionMessage, leftUser: User, leftGroup: Group)
    
    ///This will get triggered when group member's scope is changed by logged in user
    @objc optional func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group)
    
    ///This will get triggered when group member is banned from the group by logged in user
    @objc optional func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group)
    
    ///This will get triggered when group member is kicked from the group by logged in user
    @objc optional func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group)
    
    ///This will get triggered when a banned group member is unbanned from group by logged in user
    @objc optional func ccGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group)
    
    ///This will get triggered when logged in user is joined successfully
    @objc optional func ccGroupMemberJoined(joinedUser: User, joinedGroup: Group)
    
    ///This will get triggered when a member is added by logged in user
    @objc optional func ccGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User)
    
    ///This will get triggered when ownership is changed by logged in user
    @objc optional func ccOwnershipChanged(group: Group, newOwner: GroupMember)
    
    // MARK: - Deprecated Functions
    
    ///This will get triggered when a group is created successfully
    @available(*, deprecated, message: "Use ccGroupCreated(group:) instead")
    @objc optional func onGroupCreate(group: Group)
    
    ///This will get triggered when a group is deleted successfully
    @available(*, deprecated, message: "Use ccGroupDeleted(group:) instead")
    @objc optional func onGroupDelete(group: Group)
    
    ///This will get triggered when logged in user leaves the group
    @available(*, deprecated, message: "Use ccGroupLeft(action:leftUser:leftGroup:) instead")
    @objc optional func onGroupMemberLeave(leftUser: User, leftGroup: Group)
    
    ///This will get triggered when group member's scope is changed by logged in user
    @available(*, deprecated, message: "Use ccGroupMemberScopeChanged(action:updatedUser:scopeChangedTo:scopeChangedFrom:group:) instead")
    @objc optional func onGroupMemberChangeScope(updatedBy: User, updatedUser: User, scopeChangedTo: CometChat.MemberScope, scopeChangedFrom: CometChat.MemberScope, group: Group)
    
    ///This will get triggered when group member is banned from the group by logged in user
    @available(*, deprecated, message: "Use ccGroupMemberBanned(action:bannedUser:bannedBy:bannedFrom:) instead")
    @objc optional func onGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User)
    
    ///This will get triggered when group member is kicked from the group by logged in user
    @available(*, deprecated, message: "Use ccGroupMemberKicked(action:kickedUser:kickedBy:kickedFrom:) instead")
    @objc optional func onGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User)
    
    ///This will get triggered when a banned group member is unbanned from group by logged in user
    @available(*, deprecated, message: "Use ccGroupMemberUnbanned(action:unbannedUser:unbannedBy:unbannedFrom:) instead")
    @objc optional func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User)
    
    ///This will get triggered when logged in user is joined successfully
    @available(*, deprecated, message: "Use ccGroupMemberJoined(joinedUser:joinedGroup:) instead")
    @objc optional func onGroupMemberJoin(joinedUser: User, joinedGroup: Group)
    
    ///This will get triggered when a member is added by logged in user
    @available(*, deprecated, message: "Use ccGroupMemberAdded(messages:usersAdded:groupAddedIn:addedBy:) instead")
    @objc optional func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User)
    
    ///This will get triggered when ownership is changed by logged in user
    @available(*, deprecated, message: "Use ccOwnershipChanged(group:newOwner:) instead")
    @objc optional func onOwnershipChange(group: Group?, member: GroupMember?)
    
    // Unchanged Function
    @available(*, deprecated, message: "This function is now deprecated")
    @objc optional func onCreateGroupClick()
}
