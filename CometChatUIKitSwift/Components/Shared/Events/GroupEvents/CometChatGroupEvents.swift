//
//  CometChatGroupEvents.swift
 
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatSDK
import Foundation

public class CometChatGroupEvents {
    
    static private var observer = NSMapTable<NSString, AnyObject>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    
    @objc public static func addListener(_ id: String, _ observer: CometChatGroupEventListener) {
        self.observer.setObject(observer, forKey: NSString(string: id))
    }
    
    @objc public static func removeListener(_ id: String) {
        self.observer.removeObject(forKey: NSString(string: id))
    }
    
    // MARK: - New Functions
    public static func ccGroupCreated(group: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.ccGroupCreated?(group: group)
        }
    }
    
    public static func ccGroupDeleted(group: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.ccGroupDeleted?(group: group)
        }
    }
    
    public static func ccGroupLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.ccGroupLeft?(action: action, leftUser: leftUser, leftGroup: leftGroup)
        }
    }
    
    public static func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.ccGroupMemberScopeChanged?(action: action, updatedUser: updatedUser, scopeChangedTo: scopeChangedTo, scopeChangedFrom: scopeChangedFrom, group: group)
        }
    }
    
    public static func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.ccGroupMemberBanned?(action: action, bannedUser: bannedUser, bannedBy: bannedBy, bannedFrom: bannedFrom)
        }
    }
    
    public static func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.ccGroupMemberKicked?(action: action, kickedUser: kickedUser, kickedBy: kickedBy, kickedFrom: kickedFrom)
        }
    }
    
    public static func ccGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.ccGroupMemberUnbanned?(action: action, unbannedUser: unbannedUser, unbannedBy: unbannedBy, unbannedFrom: unbannedFrom)
        }
    }
    
    public static func ccGroupMemberJoined(joinedUser: User, joinedGroup: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.ccGroupMemberJoined?(joinedUser: joinedUser, joinedGroup: joinedGroup)
        }
    }
    
    public static func ccGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.ccGroupMemberAdded?(messages: messages, usersAdded: usersAdded, groupAddedIn: groupAddedIn, addedBy: addedBy)
        }
    }
    
    public static func ccOwnershipChanged(group: Group, newOwner: GroupMember) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.ccOwnershipChanged?(group: group, newOwner: newOwner)
        }
    }
    
    
    // MARK: - Deprecated Functions
    @available(*, deprecated, message: "Use ccGroupCreated(group:) instead")
    public static func emitOnGroupCreate(group: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onGroupCreate?(group: group)
        }
    }
    
    
    @available(*, deprecated)
    public static func emitOnCreateGroupClick() {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onCreateGroupClick?()
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupDeleted(group:) instead")
    public static func emitOnGroupDelete(group: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onGroupDelete?(group: group)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupLeft(action:leftUser:leftGroup:) instead")
    public static func emitOnGroupMemberLeave(leftUser: User, leftGroup: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onGroupMemberLeave?(leftUser: leftUser, leftGroup: leftGroup)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberScopeChanged(action:updatedUser:scopeChangedTo:scopeChangedFrom:group:) instead")
    public static func emitOnGroupMemberChangeScope(updatedBy: User, updatedUser: User, scopeChangedTo: CometChat.MemberScope, scopeChangedFrom: CometChat.MemberScope, group: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onGroupMemberChangeScope?(updatedBy: updatedBy, updatedUser: updatedUser, scopeChangedTo: scopeChangedTo, scopeChangedFrom: scopeChangedFrom, group: group)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberBanned(action:bannedUser:bannedBy:bannedFrom:) instead")
    public static func emitOnGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onGroupMemberBan?(bannedUser: bannedUser, bannedGroup: bannedGroup, bannedBy: bannedBy)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberKicked(action:kickedUser:kickedBy:kickedFrom:) instead")
    public static func emitOnGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onGroupMemberKick?(kickedUser: kickedUser, kickedGroup: kickedGroup, kickedBy: kickedBy)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberUnbanned(action:unbannedUser:unbannedBy:unbannedFrom:) instead")
    public static func emitOnGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onGroupMemberUnban?(unbannedUserUser: unbannedUserUser, unbannedUserGroup: unbannedUserGroup, unbannedBy: unbannedBy)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberJoined(joinedUser:joinedGroup:) instead")
    public static func emitOnGroupMemberJoin(joinedUser: User, joinedGroup: Group) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onGroupMemberJoin?(joinedUser: joinedUser, joinedGroup: joinedGroup)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberAdded(messages:usersAdded:groupAddedIn:addedBy:) instead")
    public static func emitOnGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onGroupMemberAdd?(group: group, members: members, addedBy: addedBy)
        }
    }
    
    @available(*, deprecated, message: "Use ccOwnershipChanged(group:newOwner:) instead")
    public static func emitOnOwnershipChange(group: Group?, member: GroupMember?) {
        
        let objectEnumerator = self.observer.objectEnumerator()
        while let observer = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            observer.onOwnershipChange?(group: group, member: member)
        }
    }
}
