//
//  MessageActionToggleGuard.swift
//  CometChatUIKitSwift
//

import Foundation

/// Serialises repeated taps on a per-message toggle. Pin and save are independent
/// actions on the same message, so the key carries both the action and the id —
/// otherwise saving a message would silently swallow a pin tap on it.
final class MessageActionToggleGuard {

    enum Action: String {
        case pin
        case save
        case pinConversation
    }

    static let shared = MessageActionToggleGuard()

    private static let debounceInterval: TimeInterval = 0.4

    /// Conversations are keyed by `conversationId` (a String), messages by id, so the
    /// identifier is stringified rather than the type being duplicated per surface.
    private struct Key: Hashable {
        let action: Action
        let id: String
    }

    private var inFlight = Set<Key>()
    private var lastSettled = [Key: TimeInterval]()

    /// Message ids are prefixed so they cannot collide with a numeric `conversationId`:
    /// both surfaces share one key space, and a collision silently swallows a tap.
    private static func messageKey(_ messageId: Int) -> String { "msg:\(messageId)" }

    /// Returns false when this action is already in flight for the message or settled
    /// too recently to be a deliberate second tap.
    func begin(action: Action, messageId: Int) -> Bool {
        return begin(action: action, id: Self.messageKey(messageId))
    }

    func end(action: Action, messageId: Int) {
        end(action: action, id: Self.messageKey(messageId))
    }

    /// Returns false when this action is already in flight for the entity or settled
    /// too recently to be a deliberate second tap.
    func begin(action: Action, id: String) -> Bool {
        let key = Key(action: action, id: id)
        if inFlight.contains(key) { return false }
        if let settled = lastSettled[key],
           Date().timeIntervalSince1970 - settled < Self.debounceInterval {
            return false
        }
        inFlight.insert(key)
        return true
    }

    func end(action: Action, id: String) {
        let key = Key(action: action, id: id)
        inFlight.remove(key)
        lastSettled[key] = Date().timeIntervalSince1970
    }
}
