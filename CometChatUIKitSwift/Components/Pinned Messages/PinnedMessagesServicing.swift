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

/// Production implementation backed directly by the SDK / existing builder.
final class LivePinnedMessagesService: PinnedMessagesServicing {

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
