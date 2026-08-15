//
//  MessageComposerServicing.swift
//
//  A thin seam over the non-hermetic SDK calls used by MessageComposerViewModel.
//  Only request/response style calls are abstracted here (send text / media / edit
//  via MessageComposerBuilder, transient live-reaction send, start/end typing, and
//  the logged-in user stamped onto outgoing messages). Listeners and the static
//  CometChatMessageEvents / CometChatUserEvents buses are NOT part of this seam —
//  tests avoid them by using the `internal init(service:)` (which skips `connect()`)
//  and invoking the public handler / builder methods directly.
//
//  This type is `internal` and reached from tests via `@testable import`.
//

import Foundation
import CometChatSDK

/// Abstraction over the SDK request/response calls that MessageComposerViewModel depends on.
/// Kept intentionally small so a hand-written fake in the test target is trivial.
protocol MessageComposerServicing {

    /// Send a text message.
    func sendTextMessage(message: TextMessage,
                         completion: @escaping (MessageComposerBuilderResult) -> Void)

    /// Send a media message.
    func sendMediaMessage(message: MediaMessage,
                          completion: @escaping (MessageComposerBuilderResult) -> Void)

    /// Edit an existing text message.
    func editMessage(message: TextMessage,
                     completion: @escaping (MessageComposerBuilderResult) -> Void)

    /// Send a transient message (used for live reactions).
    func sendTransientMessage(message: TransientMessage)

    /// Start a typing indicator.
    func startTyping(indicator: TypingIndicator)

    /// End a typing indicator.
    func endTyping(indicator: TypingIndicator)

    /// The currently logged-in user, if any.
    func loggedInUser() -> User?
}

/// Production implementation backed directly by the SDK / MessageComposerBuilder.
final class LiveMessageComposerService: MessageComposerServicing {

    func sendTextMessage(message: TextMessage,
                         completion: @escaping (MessageComposerBuilderResult) -> Void) {
        MessageComposerBuilder.textMessage(message: message, completion: completion)
    }

    func sendMediaMessage(message: MediaMessage,
                          completion: @escaping (MessageComposerBuilderResult) -> Void) {
        MessageComposerBuilder.mediaMessage(message: message, completion: completion)
    }

    func editMessage(message: TextMessage,
                     completion: @escaping (MessageComposerBuilderResult) -> Void) {
        MessageComposerBuilder.editMessage(message: message, completion: completion)
    }

    func sendTransientMessage(message: TransientMessage) {
        CometChat.sendTransientMessage(message: message)
    }

    func startTyping(indicator: TypingIndicator) {
        CometChat.startTyping(indicator: indicator)
    }

    func endTyping(indicator: TypingIndicator) {
        CometChat.endTyping(indicator: indicator)
    }

    func loggedInUser() -> User? {
        return CometChat.getLoggedInUser()
    }
}
