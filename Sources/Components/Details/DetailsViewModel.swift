//
//  Details2ViewModel.swift
//  
//
//  Created by Abdullah Ansari on 24/01/23.
//

import Foundation
import CometChatSDK

class DetailsViewModel {
    
    enum Leave {
        case owner
        case other
    }
    
    var user: User?
    var group: Group?
    
    var onLeaveGroup: ((Leave) -> Void)?
    var onDeleteGroup: (() -> Void)?
    var onLeaveSuccess: (() -> Void)?
    var onDeleteGroupSuccess: (() -> Void)?
    var onError: ((CometChatException) -> Void)?
    
    func updateGroup() {}
    
    /// call when user block the user.
    func blockUser() {
        if let user = user, let uid = user.uid {
            CometChat.blockUsers([uid], onSuccess: { success in
                user.blockedByMe = true
                CometChatUserEvents.emitOnUserBlock(user: user)
            }, onError: { error in
                if let error = error {
                    self.onError?(error)
                }
            })
        }
    }
    
    /// call when user unblock user.
    func unBlockUser() {
        
        if let user = user, let uid = user.uid {
            CometChat.unblockUsers([uid], onSuccess: { sucess in
                user.blockedByMe = false
                CometChatUserEvents.emitOnUserUnblock(user: user)
            }, onError: { error in
                if let error = error {
                    self.onError?(error)
                }
            })
        }
    }
    
    /// call when user delete the group.
    func deleteGroup() {
        onDeleteGroup?()
    }
    
    /// call when user leave group.
    func leaveGroup() {
        if let group = group {
            // if the user is also a owner, then transfer ownership.
            if let owner = group.owner, owner == LoggedInUserInformation.getUID() {
                onLeaveGroup?(.owner)
            } else {
                onLeaveGroup?(.other)
            }
        }
    }
    
    func delete(group: Group) {
        CometChat.deleteGroup(GUID: group.guid, onSuccess: { (success) in
            DispatchQueue.main.async {
                self.onDeleteGroupSuccess?()
                CometChatGroupEvents.emitOnGroupDelete(group: group)
            }
        }) { (error) in
            if let error = error { // Handle Error
                self.onError?(error)
            }
        }
    }
    
    func leave(group: Group) {
        CometChat.leaveGroup(GUID: group.guid, onSuccess: { _ in
            if let user =  LoggedInUserInformation.getUser() {
                self.onLeaveSuccess?()
                CometChatGroupEvents.emitOnGroupMemberLeave(leftUser: user, leftGroup: group)
            }
        }, onError: { error in
            if let error = error { // Handle Error
                self.onError?(error)
            }
        })
    }
    
    /// Connect the listner.
    public func connect() {
        
        // CometChat.addUserListener("conversation-list-users-listner", self)
        // CometChatUserEvents.addListener("details-users-listener", self)
         
        // New
        CometChatGroupEvents.addListener("details-groups-event-listner", self as CometChatGroupEventListener)
        CometChat.addGroupListener("details-groups-sdk-listner", self)
    } 
    
    /// Disconnect the listener.
    public func disconnect() {
        /*
        CometChat.removeUserListener("conversation-list-users-listener")
        CometChat.removeGroupListener("conversation-list-groups-listener")
         */
        CometChat.removeGroupListener("details-groups-sdk-listner")
        CometChatGroupEvents.removeListener("details-groups-listner")
    }
}
