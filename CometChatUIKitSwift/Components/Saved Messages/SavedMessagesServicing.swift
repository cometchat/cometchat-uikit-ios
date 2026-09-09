//
//  SavedMessagesServicing.swift
//
//  A thin seam over the non-hermetic SDK calls used by SavedMessagesViewModel.
//  Only request/response style calls are abstracted here (fetch / unsave).
//  Listeners are NOT part of this seam — tests avoid them by simply not calling
//  `connect()` and instead invoking handler/mutation methods directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK request/response calls that SavedMessagesViewModel depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol SavedMessagesServicing {

    /// Fetch the saved messages for the given request.
    func fetchSavedMessages(
        request: MessagesRequest,
        completion: @escaping (SavedMessagesBuilderResult) -> Void)

    /// Unsave a message.
    func unsaveMessage(
        messageId: Int,
        onSuccess: @escaping (BaseMessage) -> Void,
        onError: @escaping (CometChatException) -> Void
    )
}

/// Production implementation backed directly by the SDK / existing builder.
final class LiveSavedMessagesService: SavedMessagesServicing {

    func fetchSavedMessages(
        request: MessagesRequest,
        completion: @escaping (SavedMessagesBuilderResult) -> Void
    ) {
        SavedMessagesBuilder.fetchSavedMessages(request: request, completion: completion)
    }

    func unsaveMessage(
        messageId: Int,
        onSuccess: @escaping (BaseMessage) -> Void,
        onError: @escaping (CometChatException) -> Void
    ) {
        CometChat.unsaveMessage(messageId: messageId, onSuccess: onSuccess, onError: onError)
    }
}
