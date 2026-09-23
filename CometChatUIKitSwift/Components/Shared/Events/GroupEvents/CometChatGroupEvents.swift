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

    // Concurrency. This table is process-wide: components register and unregister from
    // SDK callback threads while broadcasts iterate on main. NSMapTable is not
    // thread-safe, and mutating one while another thread enumerates it is undefined
    // behaviour, not merely a stale read. The observed symptoms were an event delivered
    // twice and a listener silently dropped from the table.
    //
    // A lock ALONE would not fix this, for two reasons unrelated to other threads:
    //   1. values are `.weakMemory`, so ARC can zero an entry DURING an enumeration;
    //   2. callbacks used to run inside the enumeration loop, so a listener that called
    //      removeListener (directly, or by releasing the last strong ref to another
    //      listener) mutated the table on the SAME thread. A plain lock deadlocks there;
    //      a recursive lock lets the mutation through and corrupts the enumerator anyway.
    //
    // Hence snapshot-then-dispatch: copy into strong references under the lock, release
    // it, then call the listeners. Callbacks therefore run with no lock held, so a
    // listener may freely add or remove listeners during delivery.
    private static let lock = NSLock()

    private static func listeners() -> [CometChatGroupEventListener] {
        lock.lock()
        defer { lock.unlock() }
        var snapshot: [CometChatGroupEventListener] = []
        let objectEnumerator = self.observer.objectEnumerator()
        while let value = objectEnumerator?.nextObject() as? CometChatGroupEventListener {
            snapshot.append(value)
        }
        return snapshot
    }
    
    @objc public static func addListener(_ id: String, _ observer: CometChatGroupEventListener) {
        lock.lock()
        defer { lock.unlock() }
        self.observer.setObject(observer, forKey: NSString(string: id))
    }
    
    @objc public static func removeListener(_ id: String) {
        lock.lock()
        defer { lock.unlock() }
        self.observer.removeObject(forKey: NSString(string: id))
    }
    
    // MARK: - New Functions
    public static func ccGroupCreated(group: Group) {
        
        for observer in listeners() {
            observer.ccGroupCreated?(group: group)
        }
    }
    
    public static func ccGroupDeleted(group: Group) {
        
        for observer in listeners() {
            observer.ccGroupDeleted?(group: group)
        }
    }
    
    public static func ccGroupLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        
        for observer in listeners() {
            observer.ccGroupLeft?(action: action, leftUser: leftUser, leftGroup: leftGroup)
        }
    }
    
    public static func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        
        for observer in listeners() {
            observer.ccGroupMemberScopeChanged?(action: action, updatedUser: updatedUser, scopeChangedTo: scopeChangedTo, scopeChangedFrom: scopeChangedFrom, group: group)
        }
    }
    
    public static func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        
        for observer in listeners() {
            observer.ccGroupMemberBanned?(action: action, bannedUser: bannedUser, bannedBy: bannedBy, bannedFrom: bannedFrom)
        }
    }
    
    public static func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        
        for observer in listeners() {
            observer.ccGroupMemberKicked?(action: action, kickedUser: kickedUser, kickedBy: kickedBy, kickedFrom: kickedFrom)
        }
    }
    
    public static func ccGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        
        for observer in listeners() {
            observer.ccGroupMemberUnbanned?(action: action, unbannedUser: unbannedUser, unbannedBy: unbannedBy, unbannedFrom: unbannedFrom)
        }
    }
    
    public static func ccGroupMemberJoined(joinedUser: User, joinedGroup: Group) {
        
        for observer in listeners() {
            observer.ccGroupMemberJoined?(joinedUser: joinedUser, joinedGroup: joinedGroup)
        }
    }
    
    public static func ccGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User) {
        
        for observer in listeners() {
            observer.ccGroupMemberAdded?(messages: messages, usersAdded: usersAdded, groupAddedIn: groupAddedIn, addedBy: addedBy)
        }
    }
    
    public static func ccOwnershipChanged(group: Group, newOwner: GroupMember) {
        
        for observer in listeners() {
            observer.ccOwnershipChanged?(group: group, newOwner: newOwner)
        }
    }
    
    
    // MARK: - Deprecated Functions
    @available(*, deprecated, message: "Use ccGroupCreated(group:) instead")
    public static func emitOnGroupCreate(group: Group) {
        
        for observer in listeners() {
            observer.onGroupCreate?(group: group)
        }
    }
    
    
    @available(*, deprecated)
    public static func emitOnCreateGroupClick() {
        
        for observer in listeners() {
            observer.onCreateGroupClick?()
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupDeleted(group:) instead")
    public static func emitOnGroupDelete(group: Group) {
        
        for observer in listeners() {
            observer.onGroupDelete?(group: group)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupLeft(action:leftUser:leftGroup:) instead")
    public static func emitOnGroupMemberLeave(leftUser: User, leftGroup: Group) {
        
        for observer in listeners() {
            observer.onGroupMemberLeave?(leftUser: leftUser, leftGroup: leftGroup)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberScopeChanged(action:updatedUser:scopeChangedTo:scopeChangedFrom:group:) instead")
    public static func emitOnGroupMemberChangeScope(updatedBy: User, updatedUser: User, scopeChangedTo: CometChat.MemberScope, scopeChangedFrom: CometChat.MemberScope, group: Group) {
        
        for observer in listeners() {
            observer.onGroupMemberChangeScope?(updatedBy: updatedBy, updatedUser: updatedUser, scopeChangedTo: scopeChangedTo, scopeChangedFrom: scopeChangedFrom, group: group)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberBanned(action:bannedUser:bannedBy:bannedFrom:) instead")
    public static func emitOnGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        
        for observer in listeners() {
            observer.onGroupMemberBan?(bannedUser: bannedUser, bannedGroup: bannedGroup, bannedBy: bannedBy)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberKicked(action:kickedUser:kickedBy:kickedFrom:) instead")
    public static func emitOnGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        
        for observer in listeners() {
            observer.onGroupMemberKick?(kickedUser: kickedUser, kickedGroup: kickedGroup, kickedBy: kickedBy)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberUnbanned(action:unbannedUser:unbannedBy:unbannedFrom:) instead")
    public static func emitOnGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        
        for observer in listeners() {
            observer.onGroupMemberUnban?(unbannedUserUser: unbannedUserUser, unbannedUserGroup: unbannedUserGroup, unbannedBy: unbannedBy)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberJoined(joinedUser:joinedGroup:) instead")
    public static func emitOnGroupMemberJoin(joinedUser: User, joinedGroup: Group) {
        
        for observer in listeners() {
            observer.onGroupMemberJoin?(joinedUser: joinedUser, joinedGroup: joinedGroup)
        }
    }
    
    @available(*, deprecated, message: "Use ccGroupMemberAdded(messages:usersAdded:groupAddedIn:addedBy:) instead")
    public static func emitOnGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        
        for observer in listeners() {
            observer.onGroupMemberAdd?(group: group, members: members, addedBy: addedBy)
        }
    }
    
    @available(*, deprecated, message: "Use ccOwnershipChanged(group:newOwner:) instead")
    public static func emitOnOwnershipChange(group: Group?, member: GroupMember?) {
        
        for observer in listeners() {
            observer.onOwnershipChange?(group: group, member: member)
        }
    }
}
