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
}
