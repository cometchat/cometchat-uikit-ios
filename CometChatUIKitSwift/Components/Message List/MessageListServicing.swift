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

    /// Offline ON only: fetch the previous (older) page in two phases, the on-device copy first and
    /// the server copy second. A default implementation delivers the single legacy answer as the
    /// server phase, so existing conformers (and test fakes) need no change.
    func fetchPreviousMessagesTwoPhase(request: MessagesRequest,
                                       onCached: @escaping ([BaseMessage]) -> Void,
                                       onServer: @escaping ([BaseMessage]) -> Void,
                                       onError: @escaping (CometChatException?) -> Void)

    /// Offline ON only: the two-phase form of `fetchNextMessages`.
    func fetchNextMessagesTwoPhase(request: MessagesRequest,
                                   onCached: @escaping ([BaseMessage]) -> Void,
                                   onServer: @escaping ([BaseMessage]) -> Void,
                                   onError: @escaping (CometChatException?) -> Void)

    /// Offline ON only: today's delete of a sent message, used when the user deleted an unsent row
    /// that turned out to be sent already (`discardLocalMessage` answered NOT_FOUND).
    func deleteSentMessage(id: Int,
                           onSuccess: @escaping (BaseMessage) -> Void,
                           onError: @escaping (CometChatException) -> Void)
}

extension MessageListServicing {

    func deleteSentMessage(id: Int,
                           onSuccess: @escaping (BaseMessage) -> Void,
                           onError: @escaping (CometChatException) -> Void) {
        CometChat.deleteMessage(id, onSuccess: { message in
            DispatchQueue.main.async { onSuccess(message) }
        }, onError: { error in
            DispatchQueue.main.async { onError(error) }
        })
    }

    func fetchPreviousMessagesTwoPhase(request: MessagesRequest,
                                       onCached: @escaping ([BaseMessage]) -> Void,
                                       onServer: @escaping ([BaseMessage]) -> Void,
                                       onError: @escaping (CometChatException?) -> Void) {
        fetchPreviousMessages(request: request) { result in
            switch result {
            case .success(let messages): onServer(messages)
            case .failure(let error): onError(error)
            }
        }
    }

    func fetchNextMessagesTwoPhase(request: MessagesRequest,
                                   onCached: @escaping ([BaseMessage]) -> Void,
                                   onServer: @escaping ([BaseMessage]) -> Void,
                                   onError: @escaping (CometChatException?) -> Void) {
        fetchNextMessages(request: request) { result in
            switch result {
            case .success(let messages): onServer(messages)
            case .failure(let error): onError(error)
            }
        }
    }
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

    func fetchPreviousMessagesTwoPhase(request: MessagesRequest,
                                       onCached: @escaping ([BaseMessage]) -> Void,
                                       onServer: @escaping ([BaseMessage]) -> Void,
                                       onError: @escaping (CometChatException?) -> Void) {
        request.fetchPrevious(onCachedMessages: { messages in Self.onMain { onCached(messages) } },
                              onServerMessages: { messages in Self.onMain { onServer(messages) } },
                              onError: { error in Self.onMain { onError(error) } })
    }

    func fetchNextMessagesTwoPhase(request: MessagesRequest,
                                   onCached: @escaping ([BaseMessage]) -> Void,
                                   onServer: @escaping ([BaseMessage]) -> Void,
                                   onError: @escaping (CometChatException?) -> Void) {
        request.fetchNext(onCachedMessages: { messages in Self.onMain { onCached(messages) } },
                          onServerMessages: { messages in Self.onMain { onServer(messages) } },
                          onError: { error in Self.onMain { onError(error) } })
    }

    private static func onMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else { DispatchQueue.main.async(execute: block) }
    }
}
