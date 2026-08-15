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

    /// Fetch groups matching a search keyword.
    func fetchFilteredGroups(request: GroupsRequest,
                             completion: @escaping (GroupsBuilderResult) -> Void)

    /// Join a group.
    func joinGroup(guid: String,
                   groupType: CometChat.groupType,
                   password: String,
                   onSuccess: @escaping (Group) -> Void,
                   onError: @escaping (CometChatException?) -> Void)

    /// The currently logged-in user, if any.
    func loggedInUser() -> User?
}

/// Production implementation backed directly by the SDK / existing builder.
final class LiveGroupsService: GroupsServicing {

    func fetchGroups(request: GroupsRequest,
                     completion: @escaping (GroupsBuilderResult) -> Void) {
        GroupsBuilder.fetchGroups(groupRequest: request, completion: completion)
    }

    func fetchFilteredGroups(request: GroupsRequest,
                             completion: @escaping (GroupsBuilderResult) -> Void) {
        GroupsBuilder.getfilteredGroups(filterGroupRequest: request, completion: completion)
    }

    func joinGroup(guid: String,
                   groupType: CometChat.groupType,
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
