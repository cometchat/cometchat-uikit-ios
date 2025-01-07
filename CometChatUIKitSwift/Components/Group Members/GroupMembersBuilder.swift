//
//  GroupMembersBuilder.swift
 
//
//  Created by Pushpsen Airekar on 22/11/22.
//

import Foundation
import CometChatSDK

enum GroupMembersBuilderResult {
    case success([GroupMember])
    case failure(CometChatException)
}

enum GroupMemberScopeChangeResult {
    case success(GroupMember)
    case failure(CometChatException)
}

enum KickBanGroupMemberResult {
    case success(GroupMember)
    case failure(CometChatException)
}

public class GroupMembersBuilder {
    
    static public func getSharedBuilder(for group: Group) -> GroupMembersRequest.GroupMembersRequestBuilder {
        return GroupMembersRequest.GroupMembersRequestBuilder(guid: group.guid).set(limit: 30)
    }
    
    static func fetchGroupMembers(groupMemberRequest: GroupMembersRequest,  completion: @escaping (GroupMembersBuilderResult) -> Void) {
        groupMemberRequest.fetchNext { fetchedGroupMembers in
            completion(.success(fetchedGroupMembers))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func getfilteredGroupMembers(filterGroupMemberRequest: GroupMembersRequest, completion: @escaping (GroupMembersBuilderResult) -> Void) {
        filterGroupMemberRequest.fetchNext { groupMembers in
            completion(.success(groupMembers))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func changeScope(group: Group, member: GroupMember, scope: CometChat.MemberScope, completion: @escaping (GroupMemberScopeChangeResult) -> Void) {
        guard let uid = member.uid else { return }
        CometChat.updateGroupMemberScope(UID: uid, GUID: group.guid, scope: scope) { scopeChangeSuccess in
            var groupMember: GroupMember?
            switch scope {
            case .admin:
                groupMember = GroupMember(UID: uid, groupMemberScope: .admin)
            case .moderator:
                groupMember = GroupMember(UID: uid, groupMemberScope: .moderator)
            case .participant:
                groupMember = GroupMember(UID: uid, groupMemberScope: .participant)
            @unknown default: break
            }
            groupMember?.avatar = member.avatar
            groupMember?.name = member.name
            if let groupMember = groupMember {
                completion(.success(groupMember))
            }
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func banGroupMember(group: Group, member: GroupMember, completion: @escaping (KickBanGroupMemberResult) -> Void) {
        guard let uid = member.uid else { return }
        CometChat.banGroupMember(UID: uid, GUID: group.guid) { bannedSuccess in
            completion(.success(member))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
    
    static func kickGroupMember(group: Group, member: GroupMember, completion: @escaping (KickBanGroupMemberResult) -> Void) {
        guard let uid = member.uid else { return }
        CometChat.kickGroupMember(UID: uid, GUID: group.guid) { kickedSuccess in
            completion(.success(member))
        } onError: { error in
            guard let error = error else { return }
            completion(.failure(error))
        }
    }
}

