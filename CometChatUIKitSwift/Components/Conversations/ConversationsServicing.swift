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

    /// Offline ON only: fetch a page in two phases, the on-device copy first and the server copy
    /// second. The default delivers the single legacy answer as the server phase.
    func fetchConversationsTwoPhase(
        request: ConversationRequest,
        onCached: @escaping ([Conversation]) -> Void,
        onServer: @escaping ([Conversation]) -> Void,
        onError: @escaping (CometChatException?) -> Void)

    /// Fetch one conversation by its peer (a pin event for a chat that is not shown).
    func fetchConversation(
        with id: String,
        type: CometChat.ConversationType,
        onSuccess: @escaping (Conversation) -> Void,
        onError: @escaping (CometChatException?) -> Void)
}

extension ConversationsServicing {

    func fetchConversation(
        with id: String,
        type: CometChat.ConversationType,
        onSuccess: @escaping (Conversation) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        onError(nil)
    }

    func fetchConversationsTwoPhase(
        request: ConversationRequest,
        onCached: @escaping ([Conversation]) -> Void,
        onServer: @escaping ([Conversation]) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        fetchConversations(request: request) { result in
            switch result {
            case .success(let conversations): onServer(conversations)
            case .failure(let error): onError(error)
            }
        }
    }
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

    func fetchConversation(
        with id: String,
        type: CometChat.ConversationType,
        onSuccess: @escaping (Conversation) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        CometChat.getConversation(conversationWith: id, conversationType: type, onSuccess: { conversation in
            guard let conversation = conversation else { onError(nil); return }
            if Thread.isMainThread { onSuccess(conversation) } else { DispatchQueue.main.async { onSuccess(conversation) } }
        }, onError: { error in
            if Thread.isMainThread { onError(error) } else { DispatchQueue.main.async { onError(error) } }
        })
    }

    func fetchConversationsTwoPhase(
        request: ConversationRequest,
        onCached: @escaping ([Conversation]) -> Void,
        onServer: @escaping ([Conversation]) -> Void,
        onError: @escaping (CometChatException?) -> Void
    ) {
        let onMain: (@escaping () -> Void) -> Void = { block in
            if Thread.isMainThread { block() } else { DispatchQueue.main.async(execute: block) }
        }
        request.fetchNext(onCachedConversations: { page in onMain { onCached(page) } },
                          onServerConversations: { page in onMain { onServer(page) } },
                          onError: { error in onMain { onError(error) } })
    }
}
