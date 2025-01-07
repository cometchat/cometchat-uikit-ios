//
//  Helper Extensions.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 17/06/24.
//

import Foundation
import CometChatSDK

extension CometChat.MemberScope {
    
    public func toString(isLocalised: Bool = true) -> String {
        switch self {
        case .admin:
            return isLocalised ? "ADMIN".localize() : "admin"
        case .moderator:
            return isLocalised ? "MODERATOR".localize() : "moderator"
        case .participant:
            return isLocalised ? "PARTICIPANT".localize() : "participant"
        @unknown default:
            return ""
        }
    }
    
}


extension CometChat.GroupMemberScopeType {
    
    public func toString(isLocalised: Bool = true) -> String {
        switch self {
        case .admin:
            return isLocalised ? "ADMIN".localize() : "admin"
        case .moderator:
            return isLocalised ? "MODERATOR".localize() : "moderator"
        case .participant:
            return isLocalised ? "PARTICIPANT".localize() : "participant"
        @unknown default:
            return ""
        }
    }
    
    static public func from(string: String) -> CometChat.GroupMemberScopeType? {
        switch string {
        case "admin":
            return .admin
        case "moderator":
            return .moderator
        case "participant":
            return .participant
        default:
            return nil
        }
    }
    
}

extension User {
    
    public func toGroupMember(scope: CometChatSDK.CometChat.GroupMemberScopeType = .participant, group: Group? = nil) -> GroupMember {
        let groupMember = GroupMember(UID: self.uid ?? "", groupMemberScope: scope)
        
        // Copying properties from User to GroupMember
        groupMember.name = self.name
        groupMember.avatar = self.avatar
        groupMember.link = self.link
        groupMember.role = self.role
        groupMember.metadata = self.metadata
        groupMember.status = self.status
        groupMember.statusMessage = self.statusMessage
        groupMember.lastActiveAt = self.lastActiveAt
        groupMember.hasBlockedMe = self.hasBlockedMe
        groupMember.blockedByMe = self.blockedByMe
        groupMember.deactivatedAt = self.deactivatedAt
        groupMember.tags = self.tags

        // Update values if group is provided
        if let group = group {
            groupMember.joinedAt = group.joinedAt
            groupMember.scope = group.scope
        }

        return groupMember
    }
}
