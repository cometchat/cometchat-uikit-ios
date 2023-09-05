//
//  CometChatGroupEvents.swift
 
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatSDK
import Foundation


@objc public protocol CometChatGroupEventListener {
    
    @objc optional func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User)
    @objc optional func onCreateGroupClick()
    @objc optional func onGroupCreate(group: Group)
    @objc optional func onGroupDelete(group: Group)
    @objc optional func onOwnershipChange(group: Group?, member: GroupMember?)
    @objc optional func onGroupMemberLeave(leftUser: User, leftGroup:  Group)
    @objc optional func onGroupMemberJoin(joinedUser: User, joinedGroup:  Group)
    @objc optional func onGroupMemberBan(bannedUser: User, bannedGroup:  Group, bannedBy: User)
    @objc optional func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup:  Group, unbannedBy: User)
    @objc optional func onGroupMemberKick(kickedUser: User, kickedGroup:  Group, kickedBy: User)
    @objc optional func onGroupMemberChangeScope(updatedBy: User , updatedUser: User , scopeChangedTo: CometChat.MemberScope , scopeChangedFrom: CometChat.MemberScope, group: Group)

}

public class  CometChatGroupEvents {
    
    static private var observer = [String: CometChatGroupEventListener]()
    
    @objc public static func addListener(_ id: String,_ observer: CometChatGroupEventListener) {
        self.observer[id] = observer
    }
    
    @objc public static func removeListener(_ id: String) {
        self.observer.removeValue(forKey: id)
    }
    
    internal static  func emitOnCreateGroupClick() {
        self.observer.forEach({
            (key,observer) in
            observer.onCreateGroupClick?()
        })
    }
    
    internal static  func emitOnGroupCreate(group: Group) {
        self.observer.forEach({
            (key,observer) in
            observer.onGroupCreate?(group: group)
        })
    }
    internal static  func emitOnGroupDelete(group: Group) {
        self.observer.forEach({
            (key,observer) in
            observer.onGroupDelete?(group: group)
        })
    }
    
    internal static  func emitOnOwnershipChange(group: Group?, member: GroupMember?) {
        self.observer.forEach({
            (key,observer) in
            observer.onOwnershipChange?(group: group, member: member)
        })
    }
    
    
    internal static  func emitOnGroupMemberLeave(leftUser: User, leftGroup:  Group) {
        self.observer.forEach({
            (key,observer) in
            observer.onGroupMemberLeave?(leftUser: leftUser, leftGroup: leftGroup)
        })
    }
    internal static  func emitOnGroupMemberJoin(joinedUser: User, joinedGroup:  Group) {
        self.observer.forEach({
            (key,observer) in
            observer.onGroupMemberJoin?(joinedUser: joinedUser, joinedGroup: joinedGroup)
        })
    }
    internal static  func emitOnGroupMemberBan(bannedUser: User, bannedGroup:  Group, bannedBy: User) {
        self.observer.forEach({
            (key,observer) in
            observer.onGroupMemberBan?(bannedUser: bannedUser, bannedGroup: bannedGroup, bannedBy: bannedBy)
        })
    }
    internal static  func emitOnGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup:  Group, unbannedBy: User) {
        self.observer.forEach({
            (key,observer) in
            observer.onGroupMemberUnban?(unbannedUserUser: unbannedUserUser, unbannedUserGroup: unbannedUserGroup, unbannedBy: unbannedBy)
        })
    }
    internal static  func emitOnGroupMemberKick(kickedUser: User, kickedGroup:  Group, kickedBy: User) {
        self.observer.forEach({
            (key,observer) in
            observer.onGroupMemberKick?(kickedUser: kickedUser, kickedGroup: kickedGroup, kickedBy: kickedBy)
        })
    }
    
    internal static  func emitOnGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        self.observer.forEach({
            (key,observer) in
            observer.onGroupMemberAdd?(group: group, members: members, addedBy: addedBy)
        })
    }
    
    
    internal static  func emitOnGroupMemberChangeScope(updatedBy: User , updatedUser: User , scopeChangedTo: CometChat.MemberScope , scopeChangedFrom: CometChat.MemberScope, group: Group) {
        self.observer.forEach({
            (key,observer) in
            observer.onGroupMemberChangeScope?(updatedBy: updatedBy, updatedUser: updatedUser, scopeChangedTo: scopeChangedTo, scopeChangedFrom: scopeChangedFrom, group: group)
        })
    }
    
}
