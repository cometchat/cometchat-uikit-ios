//
//  ConversationsServicing.swift
//
//  A thin seam over the non-hermetic SDK calls used by ConversationsViewModel.
//  Only request/response style calls are abstracted here (fetch / markAsDelivered /
//  loggedInUser / delete). Listeners are NOT part of this seam — tests avoid them by
//  simply not calling `connect()` and instead invoking handler/mutation methods directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK request/response calls that ConversationsViewModel depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol ConversationsServicing {

    /// Fetch the next page for the given request.
    func fetchConversations(
        request: ConversationRequest,
        completion: @escaping (ConverstionsBuilderResult) -> Void)

    /// The currently logged-in user's uid, if any.
    func loggedInUserUid() -> String?

    /// Mark a message as delivered.
    func markAsDelivered(message: BaseMessage)

    /// Delete a conversation with the given peer.
    func deleteConversation(
        with id: String,
        type: CometChat.ConversationType,
        onSuccess: @escaping (String) -> Void,
        onError: @escaping (CometChatException?) -> Void
    )
}

/// Production implementation backed directly by the SDK / existing builder.
final class LiveConversationsService: ConversationsServicing {

    func fetchConversations(
        request: ConversationRequest,
        completion: @escaping (ConverstionsBuilderResult) -> Void
    ) {
        ConversationsBuilder.fetchConversation(conversationRequest: request, completion: completion)
    }

    func loggedInUserUid() -> String? {
        return CometChat.getLoggedInUser()?.uid
    }

    func markAsDelivered(message: BaseMessage) {
        CometChat.markAsDelivered(baseMessage: message)
    }

    func deleteConversation(
        with id: String,
        type: CometChat.ConversationType,
        onSuccess: @escaping (String) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        CometChat.deleteConversation(
            conversationWith: id,
            conversationType: type,
            onSuccess: onSuccess,
            onError: onError
        )
    }
}
