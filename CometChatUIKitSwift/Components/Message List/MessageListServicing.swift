//
//  MessageListServicing.swift
//
//  A thin seam over the non-hermetic SDK calls used by MessageListViewModel.
//  Only request/response style calls are abstracted here (fetch-next / fetch-previous
//  pages and the unread-count lookups). Listeners are NOT part of this seam — tests
//  avoid them by simply not calling `connect()` and instead invoking the public
//  handler / mutation methods directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK request/response calls that MessageListViewModel depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol MessageListServicing {

    /// Fetch the previous (older) page for the given request.
    func fetchPreviousMessages(request: MessagesRequest,
                               completion: @escaping (MessagesListBuilderResult) -> Void)

    /// Fetch the next (newer) page for the given request.
    func fetchNextMessages(request: MessagesRequest,
                           completion: @escaping (MessagesListBuilderResult) -> Void)

    /// Unread message count for a 1:1 conversation, keyed by uid.
    func unreadMessageCountForUser(uid: String,
                                   onSuccess: @escaping ([String: Any]) -> Void,
                                   onError: @escaping (CometChatException?) -> Void)

    /// Unread message count for a group conversation, keyed by guid.
    func unreadMessageCountForGroup(guid: String,
                                    onSuccess: @escaping ([String: Any]) -> Void,
                                    onError: @escaping (CometChatException?) -> Void)

    /// The currently logged-in user, if any.
    func loggedInUser() -> User?
}

/// Production implementation backed directly by the SDK / existing builder.
final class LiveMessageListService: MessageListServicing {

    func fetchPreviousMessages(request: MessagesRequest,
                               completion: @escaping (MessagesListBuilderResult) -> Void) {
        MessagesListBuilder.fetchPreviousMessages(messageRequest: request, completion: completion)
    }

    func fetchNextMessages(request: MessagesRequest,
                           completion: @escaping (MessagesListBuilderResult) -> Void) {
        MessagesListBuilder.fetchNextMessages(messageRequest: request, completion: completion)
    }

    func unreadMessageCountForUser(uid: String,
                                   onSuccess: @escaping ([String: Any]) -> Void,
                                   onError: @escaping (CometChatException?) -> Void) {
        CometChat.getUnreadMessageCountForUser(uid, onSuccess: onSuccess, onError: onError)
    }

    func unreadMessageCountForGroup(guid: String,
                                    onSuccess: @escaping ([String: Any]) -> Void,
                                    onError: @escaping (CometChatException?) -> Void) {
        CometChat.getUnreadMessageCountForGroup(guid, onSuccess: onSuccess, onError: onError)
    }

    func loggedInUser() -> User? {
        return CometChat.getLoggedInUser()
    }
}
