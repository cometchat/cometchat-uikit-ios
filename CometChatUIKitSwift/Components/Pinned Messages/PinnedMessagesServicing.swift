//
//  PinnedMessagesServicing.swift
//
//  A thin seam over the non-hermetic SDK calls used by PinnedMessagesViewModel.
//  Only request/response style calls are abstracted here (fetch / unpin / delete).
//  Listeners are NOT part of this seam — tests avoid them by simply not calling
//  `connect()` and instead invoking handler/mutation methods directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK request/response calls that PinnedMessagesViewModel depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol PinnedMessagesServicing {

    /// Fetch the pinned messages for the given request.
    func fetchPinnedMessages(
        request: MessagesRequest,
        completion: @escaping (PinnedMessagesBuilderResult) -> Void)

    /// Offline ON only: the list in two phases, the on-device copy first. The default delivers the
    /// single legacy answer as the server phase.
    func fetchPinnedMessagesTwoPhase(
        request: MessagesRequest,
        onCached: @escaping ([BaseMessage]) -> Void,
        onServer: @escaping ([BaseMessage]) -> Void,
        onError: @escaping (CometChatException?) -> Void)

    /// Unpin a message.
    func unpinMessage(
        messageId: Int,
        onSuccess: @escaping (BaseMessage) -> Void,
        onError: @escaping (CometChatException) -> Void
    )

    /// Delete a message.
    func deleteMessage(
        messageId: Int,
        onSuccess: @escaping (BaseMessage) -> Void,
        onError: @escaping (CometChatException) -> Void
    )
}

extension PinnedMessagesServicing {

    func fetchPinnedMessagesTwoPhase(
        request: MessagesRequest,
        onCached: @escaping ([BaseMessage]) -> Void,
        onServer: @escaping ([BaseMessage]) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        fetchPinnedMessages(request: request) { result in
            switch result {
            case .success(let messages): onServer(messages)
            case .failure(let error): onError(error)
            }
        }
    }
}

/// Production implementation backed directly by the SDK / existing builder.
final class LivePinnedMessagesService: PinnedMessagesServicing {

    func fetchPinnedMessagesTwoPhase(
        request: MessagesRequest,
        onCached: @escaping ([BaseMessage]) -> Void,
        onServer: @escaping ([BaseMessage]) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        request.fetchPrevious(onCachedMessages: { page in OfflineSnapshotMain.run { onCached(page) } },
                              onServerMessages: { page in OfflineSnapshotMain.run { onServer(page) } },
                              onError: { error in OfflineSnapshotMain.run { onError(error) } })
    }

    func fetchPinnedMessages(
        request: MessagesRequest,
        completion: @escaping (PinnedMessagesBuilderResult) -> Void
    ) {
        PinnedMessagesBuilder.fetchPinnedMessages(request: request, completion: completion)
    }

    func unpinMessage(
        messageId: Int,
        onSuccess: @escaping (BaseMessage) -> Void,
        onError: @escaping (CometChatException) -> Void
    ) {
        CometChat.unpinMessage(messageId: messageId, onSuccess: onSuccess, onError: onError)
    }

    func deleteMessage(
        messageId: Int,
        onSuccess: @escaping (BaseMessage) -> Void,
        onError: @escaping (CometChatException) -> Void
    ) {
        CometChat.deleteMessage(messageId, onSuccess: onSuccess, onError: onError)
    }
}
