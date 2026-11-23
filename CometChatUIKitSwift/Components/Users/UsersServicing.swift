//
//  UsersServicing.swift
//
//  A thin seam over the non-hermetic SDK calls used by UsersViewModel.
//  Only request/response style calls are abstracted here (fetch / filtered-fetch).
//  Listeners are NOT part of this seam — tests avoid them by simply not calling
//  `connect()` and instead invoking handler/mutation methods directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK request/response calls that UsersViewModel depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol UsersServicing {

    /// Fetch the next page for the given request.
    func fetchUsers(request: UsersRequest,
                    completion: @escaping (UsersBuilderResult) -> Void)

    /// Fetch users matching a search keyword.
    func fetchFilteredUsers(request: UsersRequest,
                            completion: @escaping (UsersBuilderResult) -> Void)

    /// Offline ON only: the page in two phases, the on-device copy first. The default delivers the
    /// single legacy answer as the server phase.
    func fetchUsersTwoPhase(request: UsersRequest,
                            onCached: @escaping ([User]) -> Void,
                            onServer: @escaping ([User]) -> Void,
                            onError: @escaping (CometChatException?) -> Void)
}

extension UsersServicing {

    func fetchUsersTwoPhase(request: UsersRequest,
                            onCached: @escaping ([User]) -> Void,
                            onServer: @escaping ([User]) -> Void,
                            onError: @escaping (CometChatException?) -> Void) {
        fetchUsers(request: request) { result in
            switch result {
            case .success(let users): onServer(users)
            case .failure(let error): onError(error)
            }
        }
    }
}

/// Production implementation backed directly by the existing builder.
final class LiveUsersService: UsersServicing {

    func fetchUsers(request: UsersRequest,
                    completion: @escaping (UsersBuilderResult) -> Void) {
        UsersBuilder.fetchUsers(userRequest: request, completion: completion)
    }

    func fetchFilteredUsers(request: UsersRequest,
                            completion: @escaping (UsersBuilderResult) -> Void) {
        UsersBuilder.getfilteredUsers(filterUserRequest: request, completion: completion)
    }

    func fetchUsersTwoPhase(request: UsersRequest,
                            onCached: @escaping ([User]) -> Void,
                            onServer: @escaping ([User]) -> Void,
                            onError: @escaping (CometChatException?) -> Void) {
        request.fetchNext(onCachedUsers: { page in OfflineSnapshotMain.run { onCached(page) } },
                          onServerUsers: { page in OfflineSnapshotMain.run { onServer(page) } },
                          onError: { error in OfflineSnapshotMain.run { onError(error) } })
    }
}
