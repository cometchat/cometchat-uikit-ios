//
//  OfflineSDK.swift
//  CometChatUIKitSwift
//
//  The only place the offline hub and the send helper reach the Chat SDK's offline surface.
//  A protocol so the hub's dedupe and the send state machine are testable without a live SDK.
//
//  Everything here exists on Chat SDK 4.2.1 and later.
//

import Foundation
import CometChatSDK

/// Which SDK send a message goes through.
internal enum OfflineSendKind {
    case text, media, custom, interactive

    static func of(_ message: BaseMessage) -> OfflineSendKind {
        if message is TextMessage { return .text }
        if message is MediaMessage { return .media }
        if message is InteractiveMessage { return .interactive }
        return .custom
    }
}

internal protocol OfflineSDK: AnyObject {
    // Listener registration (one shared id map on iOS: every listener needs its own id).
    func addOutboxListener(_ id: String, _ listener: OutboxListener)
    func addSyncListener(_ id: String, _ listener: SyncListener)
    func addOfflineCacheResetListener(_ id: String, _ listener: OfflineCacheResetListener)
    func addMediaDownloadListener(_ id: String, _ listener: MediaDownloadListener)
    func addMessageListener(_ id: String, _ listener: CometChatMessageDelegate)
    func addLoginListener(_ id: String, _ listener: CometChatSDK.CometChatLoginDelegate)

    /// The 3-callback send (pending, sent, error). The pending callback may precede a
    /// QUEUE_FULL / BYTE_OVERFLOW refusal on iOS (SDK ask A7).
    func send(_ message: BaseMessage,
              kind: OfflineSendKind,
              onPending: @escaping (BaseMessage) -> Void,
              onSent: @escaping (BaseMessage) -> Void,
              onError: @escaping (CometChatException?) -> Void)

    func retry(localMessageId: String,
               onSuccess: @escaping () -> Void,
               onError: @escaping (CometChatException) -> Void)

    func discard(localMessageId: String,
                 onSuccess: @escaping () -> Void,
                 onError: @escaping (CometChatException) -> Void)

    func markConversationAsRead(conversationWithId: String,
                                receiverType: CometChat.ReceiverType,
                                onSuccess: @escaping () -> Void,
                                onError: @escaping () -> Void)
}

/// The production implementation, forwarding to `CometChat`.
internal final class LiveOfflineSDK: OfflineSDK {

    internal static let shared = LiveOfflineSDK()
    private init() {}

    func addOutboxListener(_ id: String, _ listener: OutboxListener) { CometChat.addOutboxListener(id, listener) }
    func addSyncListener(_ id: String, _ listener: SyncListener) { CometChat.addSyncListener(id, listener) }
    func addOfflineCacheResetListener(_ id: String, _ listener: OfflineCacheResetListener) {
        CometChat.addOfflineCacheResetListener(id, listener)
    }
    func addMediaDownloadListener(_ id: String, _ listener: MediaDownloadListener) {
        CometChat.addMediaDownloadListener(id, listener)
    }
    func addMessageListener(_ id: String, _ listener: CometChatMessageDelegate) { CometChat.addMessageListener(id, listener) }
    func addLoginListener(_ id: String, _ listener: CometChatSDK.CometChatLoginDelegate) { CometChat.addLoginListener(id, listener) }

    func send(_ message: BaseMessage,
              kind: OfflineSendKind,
              onPending: @escaping (BaseMessage) -> Void,
              onSent: @escaping (BaseMessage) -> Void,
              onError: @escaping (CometChatException?) -> Void) {
        switch kind {
        case .text:
            guard let m = message as? TextMessage else { return onError(nil) }
            CometChat.sendTextMessage(message: m, onMessagePending: { onPending($0) },
                                      onMessageSent: { onSent($0) }, onError: onError)
        case .media:
            guard let m = message as? MediaMessage else { return onError(nil) }
            CometChat.sendMediaMessage(message: m, onMessagePending: { onPending($0) },
                                       onMessageSent: { onSent($0) }, onError: onError)
        case .interactive:
            guard let m = message as? InteractiveMessage else { return onError(nil) }
            CometChat.sendInteractiveMessage(message: m, onMessagePending: { onPending($0) },
                                             onMessageSent: { onSent($0) }, onError: onError)
        case .custom:
            guard let m = message as? CustomMessage else { return onError(nil) }
            CometChat.sendCustomMessage(message: m, onMessagePending: { onPending($0) },
                                        onMessageSent: { onSent($0) }, onError: onError)
        }
    }

    func retry(localMessageId: String, onSuccess: @escaping () -> Void, onError: @escaping (CometChatException) -> Void) {
        CometChat.retryMessage(localMessageId, onSuccess: onSuccess, onError: onError)
    }

    func discard(localMessageId: String, onSuccess: @escaping () -> Void, onError: @escaping (CometChatException) -> Void) {
        CometChat.discardLocalMessage(localMessageId, onSuccess: onSuccess, onError: onError)
    }

    func markConversationAsRead(conversationWithId: String,
                                receiverType: CometChat.ReceiverType,
                                onSuccess: @escaping () -> Void,
                                onError: @escaping () -> Void) {
        CometChat.markConversationAsRead(conversationWithId: conversationWithId,
                                         receiverType: receiverType,
                                         onSuccess: { _ in onSuccess() },
                                         onError: { _ in onError() })
    }
}
