//
//  FirstAnswer.swift
//  CometChatUIKitSwift
//
//  A two-phase point lookup (getConversation, getMessageDetails) acts on its FIRST useful answer:
//  the cached object when there is one, else the server's. Later answers are for refreshing, not
//  for acting twice. No UIKit imports.
//

import Foundation
import CometChatSDK

internal struct FirstAnswer {

    private(set) var taken = false

    /// `true` for the first call only.
    mutating func take() -> Bool {
        if taken { return false }
        taken = true
        return true
    }
}

/// Adapts the SDK's `ConversationDetailsListener` to closures.
internal final class ConversationDetailsBridge: NSObject, ConversationDetailsListener {

    private let cached: (Conversation) -> Void
    private let server: (Conversation?) -> Void
    private let failed: (CometChatException?) -> Void

    init(onCached: @escaping (Conversation) -> Void,
         onServer: @escaping (Conversation?) -> Void,
         onError: @escaping (CometChatException?) -> Void) {
        self.cached = onCached
        self.server = onServer
        self.failed = onError
    }

    func onCachedConversation(_ conversation: Conversation) { cached(conversation) }
    func onServerConversation(_ conversation: Conversation?) { server(conversation) }
    func onError(_ error: CometChatException?) { failed(error) }
}

/// Adapts the SDK's `MessageDetailsListener` to closures.
internal final class MessageDetailsBridge: NSObject, MessageDetailsListener {

    private let cached: (BaseMessage) -> Void
    private let server: (BaseMessage?) -> Void
    private let failed: (CometChatException?) -> Void

    init(onCached: @escaping (BaseMessage) -> Void,
         onServer: @escaping (BaseMessage?) -> Void,
         onError: @escaping (CometChatException?) -> Void) {
        self.cached = onCached
        self.server = onServer
        self.failed = onError
    }

    func onCachedMessage(_ message: BaseMessage) { cached(message) }
    func onServerMessage(_ message: BaseMessage?) { server(message) }
    func onError(_ error: CometChatException?) { failed(error) }
}
