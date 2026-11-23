//
//  GroupsServicing.swift
//
//  A thin seam over the non-hermetic SDK calls used by GroupsViewModel.
//  Only request/response style calls are abstracted here (fetch / filtered-fetch /
//  join / loggedInUser). Listeners are NOT part of this seam — tests avoid them by
//  simply not calling `connect()` and instead invoking handler/mutation methods directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK request/response calls that GroupsViewModel depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol GroupsServicing {

    /// Fetch the next page for the given request.
    func fetchGroups(request: GroupsRequest,
                     completion: @escaping (GroupsBuilderResult) -> Void)

    /// Offline ON only: the page in two phases, the on-device copy first. The default delivers the
    /// single legacy answer as the server phase.
    func fetchGroupsTwoPhase(request: GroupsRequest,
                             onCached: @escaping ([Group]) -> Void,
                             onServer: @escaping ([Group]) -> Void,
                             onError: @escaping (CometChatException?) -> Void)

    /// Fetch groups matching a search keyword.
    func fetchFilteredGroups(request: GroupsRequest,
                             completion: @escaping (GroupsBuilderResult) -> Void)

    /// Join a group.
    func joinGroup(guid: String,
                   groupType: CometChat.GroupType,
                   password: String,
                   onSuccess: @escaping (Group) -> Void,
                   onError: @escaping (CometChatException?) -> Void)

    /// The currently logged-in user, if any.
    func loggedInUser() -> User?
}

/// Production implementation backed directly by the SDK / existing builder.
extension GroupsServicing {

    func fetchGroupsTwoPhase(request: GroupsRequest,
                             onCached: @escaping ([Group]) -> Void,
                             onServer: @escaping ([Group]) -> Void,
                             onError: @escaping (CometChatException?) -> Void) {
        fetchGroups(request: request) { result in
            switch result {
            case .success(let groups): onServer(groups)
            case .failure(let error): onError(error)
            }
        }
    }
}

final class LiveGroupsService: GroupsServicing {

    func fetchGroupsTwoPhase(request: GroupsRequest,
                             onCached: @escaping ([Group]) -> Void,
                             onServer: @escaping ([Group]) -> Void,
                             onError: @escaping (CometChatException?) -> Void) {
        request.fetchNext(onCachedGroups: { page in OfflineSnapshotMain.run { onCached(page) } },
                          onServerGroups: { page in OfflineSnapshotMain.run { onServer(page) } },
                          onError: { error in OfflineSnapshotMain.run { onError(error) } })
    }

    func fetchGroups(request: GroupsRequest,
                     completion: @escaping (GroupsBuilderResult) -> Void) {
        GroupsBuilder.fetchGroups(groupRequest: request, completion: completion)
    }

    func fetchFilteredGroups(request: GroupsRequest,
                             completion: @escaping (GroupsBuilderResult) -> Void) {
        GroupsBuilder.getfilteredGroups(filterGroupRequest: request, completion: completion)
    }

    func joinGroup(guid: String,
                   groupType: CometChat.GroupType,
                   password: String,
                   onSuccess: @escaping (Group) -> Void,
                   onError: @escaping (CometChatException?) -> Void) {
        CometChat.joinGroup(GUID: guid,
                            groupType: groupType,
                            password: password,
                            onSuccess: onSuccess,
                            onError: onError)
    }

    func loggedInUser() -> User? {
        return CometChat.getLoggedInUser()
    }
}
