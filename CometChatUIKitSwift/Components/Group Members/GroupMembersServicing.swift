//
//  GroupMembersServicing.swift
//
//  A thin seam over the non-hermetic SDK calls used by GroupMembersViewModel.
//  Only request/response style calls are abstracted here (fetch / filtered-fetch /
//  changeScope / ban / kick / loggedInUser). Listeners are NOT part of this seam —
//  tests avoid them by not calling `connect()` and invoking handler/mutation methods
//  directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK request/response calls that GroupMembersViewModel depends on.
protocol GroupMembersServicing {

    func fetchGroupMembers(
        request: GroupMembersRequest,
        completion: @escaping (GroupMembersBuilderResult) -> Void
    )

    func fetchFilteredGroupMembers(
        request: GroupMembersRequest,
        completion: @escaping (GroupMembersBuilderResult) -> Void
    )

    /// Offline ON only: the page in two phases, the on-device copy first. The default delivers the
    /// single legacy answer as the server phase.
    func fetchGroupMembersTwoPhase(
        request: GroupMembersRequest,
        onCached: @escaping ([GroupMember]) -> Void,
        onServer: @escaping ([GroupMember]) -> Void,
        onError: @escaping (CometChatException?) -> Void
    )

    func changeScope(
        group: Group,
        member: GroupMember,
        scope: CometChat.MemberScope,
        completion: @escaping (GroupMemberScopeChangeResult) -> Void
    )

    func banGroupMember(
        group: Group,
        member: GroupMember,
        completion: @escaping (KickBanGroupMemberResult) -> Void
    )

    func kickGroupMember(
        group: Group,
        member: GroupMember,
        completion: @escaping (KickBanGroupMemberResult) -> Void
    )

    /// The currently logged-in user, if any.
    func loggedInUser() -> User?
}

extension GroupMembersServicing {

    func fetchGroupMembersTwoPhase(
        request: GroupMembersRequest,
        onCached: @escaping ([GroupMember]) -> Void,
        onServer: @escaping ([GroupMember]) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        fetchGroupMembers(request: request) { result in
            switch result {
            case .success(let members): onServer(members)
            case .failure(let error): onError(error)
            }
        }
    }
}

/// Production implementation backed directly by the existing builder / SDK.
final class LiveGroupMembersService: GroupMembersServicing {

    func fetchGroupMembersTwoPhase(
        request: GroupMembersRequest,
        onCached: @escaping ([GroupMember]) -> Void,
        onServer: @escaping ([GroupMember]) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        request.fetchNext(onCachedGroupMembers: { page in OfflineSnapshotMain.run { onCached(page) } },
                          onServerGroupMembers: { page in OfflineSnapshotMain.run { onServer(page) } },
                          onError: { error in OfflineSnapshotMain.run { onError(error) } })
    }

    func fetchGroupMembers(
        request: GroupMembersRequest,
        completion: @escaping (GroupMembersBuilderResult) -> Void
    ) {
        GroupMembersBuilder.fetchGroupMembers(groupMemberRequest: request, completion: completion)
    }

    func fetchFilteredGroupMembers(
        request: GroupMembersRequest,
        completion: @escaping (GroupMembersBuilderResult) -> Void
    ) {
        GroupMembersBuilder.getfilteredGroupMembers(filterGroupMemberRequest: request, completion: completion)
    }

    func changeScope(
        group: Group,
        member: GroupMember,
        scope: CometChat.MemberScope,
        completion: @escaping (GroupMemberScopeChangeResult) -> Void
    ) {
        GroupMembersBuilder.changeScope(group: group, member: member, scope: scope, completion: completion)
    }

    func banGroupMember(
        group: Group,
        member: GroupMember,
        completion: @escaping (KickBanGroupMemberResult) -> Void
    ) {
        GroupMembersBuilder.banGroupMember(group: group, member: member, completion: completion)
    }

    func kickGroupMember(
        group: Group,
        member: GroupMember,
        completion: @escaping (KickBanGroupMemberResult) -> Void
    ) {
        GroupMembersBuilder.kickGroupMember(group: group, member: member, completion: completion)
    }

    func loggedInUser() -> User? {
        return CometChat.getLoggedInUser()
    }
}
