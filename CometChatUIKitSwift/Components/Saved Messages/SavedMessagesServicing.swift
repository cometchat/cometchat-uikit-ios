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

    /// Offline ON only: the list in two phases, the on-device copy first. The default delivers the
    /// single legacy answer as the server phase.
    func fetchSavedMessagesTwoPhase(
        request: MessagesRequest,
        onCached: @escaping ([BaseMessage]) -> Void,
        onServer: @escaping ([BaseMessage]) -> Void,
        onError: @escaping (CometChatException?) -> Void)

    /// Unsave a message.
    func unsaveMessage(
        messageId: Int,
        onSuccess: @escaping (BaseMessage) -> Void,
        onError: @escaping (CometChatException) -> Void
    )
}

extension SavedMessagesServicing {

    func fetchSavedMessagesTwoPhase(
        request: MessagesRequest,
        onCached: @escaping ([BaseMessage]) -> Void,
        onServer: @escaping ([BaseMessage]) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        fetchSavedMessages(request: request) { result in
            switch result {
            case .success(let messages): onServer(messages)
            case .failure(let error): onError(error)
            }
        }
    }
}

/// Production implementation backed directly by the SDK / existing builder.
final class LiveSavedMessagesService: SavedMessagesServicing {

    func fetchSavedMessagesTwoPhase(
        request: MessagesRequest,
        onCached: @escaping ([BaseMessage]) -> Void,
        onServer: @escaping ([BaseMessage]) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        request.fetchPrevious(onCachedMessages: { page in OfflineSnapshotMain.run { onCached(page) } },
                              onServerMessages: { page in OfflineSnapshotMain.run { onServer(page) } },
                              onError: { error in OfflineSnapshotMain.run { onError(error) } })
    }

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
