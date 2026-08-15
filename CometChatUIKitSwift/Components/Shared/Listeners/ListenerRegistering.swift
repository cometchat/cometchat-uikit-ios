//
//  ListenerRegistering.swift
//  CometChatUIKitSwift
//
//  Seam over the SDK and event-bus listener registries so view models can be
//  tested for registration/removal symmetry without a live SDK.
//

import Foundation
import CometChatSDK

/// The registry a listener is attached to.
///
/// The channel is part of the identity of a registration: the same id registered
/// on `.messageEvents` and removed from `.messageSDK` is *not* a matched pair, and
/// leaves a live listener behind.
internal enum ListenerChannel: String, Hashable, CaseIterable {
    case userSDK
    case groupSDK
    case callSDK
    case messageSDK
    case connectionSDK
    case aiAssistantSDK
    case notificationFeedSDK
    case userEvents
    case groupEvents
    case callEvents
    case messageEvents
    case conversationEvents
    case uiEvents
}

/// Registers and removes listeners on behalf of a view model.
///
/// View models depend on this instead of calling `CometChat.*` / `CometChat*Events`
/// statics directly, so tests can assert that everything `connect()` registers is
/// removed by `disconnect()` — on the same channel and under the same id.
internal protocol ListenerRegistering: AnyObject {
    func add(_ channel: ListenerChannel, id: String, listener: Any)
    func remove(_ channel: ListenerChannel, id: String)
}

/// Production implementation forwarding to the real registries.
///
/// Intentionally untested: it is a pass-through to the SDK boundary, mirroring how
/// the Android UI Kit leaves `CallLogsDataSourceImpl` / `CallButtonsDataSourceImpl`
/// untested. The tested surface is the view-model side of this protocol.
internal final class SDKListenerRegistrar: ListenerRegistering {

    internal static let shared = SDKListenerRegistrar()

    internal init() {}

    /// Message for a listener that does not conform to its channel's delegate.
    ///
    /// The protocol takes `Any` so one seam can span 13 registries with unrelated
    /// delegate types. That trades the compiler's per-call-site type check for a
    /// runtime one: a listener that stops conforming would otherwise be dropped
    /// here and simply never fire. Debug builds trap instead.
    private static func mismatch(_ channel: ListenerChannel,
                                 _ expected: Any.Type,
                                 _ listener: Any) -> String {
        """
        Listener for channel .\(channel.rawValue) does not conform to \(expected). \
        Got \(type(of: listener)). The registration was dropped and this listener \
        will never fire.
        """
    }

    internal func add(_ channel: ListenerChannel, id: String, listener: Any) {
        switch channel {
        case .userSDK:
            if let listener = listener as? CometChatUserDelegate {
                CometChat.addUserListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatUserDelegate.self, listener))
            }
        case .groupSDK:
            if let listener = listener as? CometChatGroupDelegate {
                CometChat.addGroupListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatGroupDelegate.self, listener))
            }
        case .callSDK:
            if let listener = listener as? CometChatCallDelegate {
                CometChat.addCallListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatCallDelegate.self, listener))
            }
        case .messageSDK:
            if let listener = listener as? CometChatMessageDelegate {
                CometChat.addMessageListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatMessageDelegate.self, listener))
            }
        case .connectionSDK:
            if let listener = listener as? CometChatConnectionDelegate {
                CometChat.addConnectionListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatConnectionDelegate.self, listener))
            }
        case .aiAssistantSDK:
            if let listener = listener as? AIAssistantEventsDelegate {
                CometChat.addAIAssistantListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, AIAssistantEventsDelegate.self, listener))
            }
        case .notificationFeedSDK:
            if let listener = listener as? CometChatNotificationFeedDelegate {
                CometChat.addNotificationFeedListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatNotificationFeedDelegate.self, listener))
            }
        case .userEvents:
            if let listener = listener as? CometChatUserEventListener {
                CometChatUserEvents.addListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatUserEventListener.self, listener))
            }
        case .groupEvents:
            if let listener = listener as? CometChatGroupEventListener {
                CometChatGroupEvents.addListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatGroupEventListener.self, listener))
            }
        case .callEvents:
            if let listener = listener as? CometChatCallEventListener {
                CometChatCallEvents.addListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatCallEventListener.self, listener))
            }
        case .messageEvents:
            if let listener = listener as? CometChatMessageEventListener {
                CometChatMessageEvents.addListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatMessageEventListener.self, listener))
            }
        case .conversationEvents:
            if let listener = listener as? CometChatConversationEventListener {
                CometChatConversationEvents.addListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatConversationEventListener.self, listener))
            }
        case .uiEvents:
            if let listener = listener as? CometChatUIEventListener {
                CometChatUIEvents.addListener(id, listener)
            } else {
                assertionFailure(Self.mismatch(channel, CometChatUIEventListener.self, listener))
            }
        }
    }

    internal func remove(_ channel: ListenerChannel, id: String) {
        switch channel {
        case .userSDK: CometChat.removeUserListener(id)
        case .groupSDK: CometChat.removeGroupListener(id)
        case .callSDK: CometChat.removeCallListener(id)
        case .messageSDK: CometChat.removeMessageListener(id)
        case .connectionSDK: CometChat.removeConnectionListener(id)
        case .aiAssistantSDK: CometChat.removeAIAssistantListener(id)
        case .notificationFeedSDK: CometChat.removeNotificationFeedListener(id)
        case .userEvents: CometChatUserEvents.removeListener(id)
        case .groupEvents: CometChatGroupEvents.removeListener(id)
        case .callEvents: CometChatCallEvents.removeListener(id)
        case .messageEvents: CometChatMessageEvents.removeListener(id)
        case .conversationEvents: CometChatConversationEvents.removeListener(id)
        case .uiEvents: CometChatUIEvents.removeListener(id)
        }
    }
}
