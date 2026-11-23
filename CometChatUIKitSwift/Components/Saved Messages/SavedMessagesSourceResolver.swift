//
//  SavedMessagesSourceResolver.swift
//  CometChatUIKitSwift
//

import Foundation
import CometChatSDK

/// Resolves the conversation a saved message came from.
///
/// Saved messages span conversations (doc §6.4), so every row has to say where it is from.
/// The name comes from the message itself first — its `receiver` (a group, or the user it
/// was sent to) or, for a 1:1 message the user received, its `sender` — as on Android. A
/// lookup by id runs only when the payload has no name, and never blocks a row: the caller
/// renders the raw id and repaints when `onResolved` fires (recipe step 1).
final class SavedMessagesSourceResolver {

    /// Resolved display names, keyed by `cacheKey`. Also the in-flight de-duplicator's
    /// completion target, so N rows of one conversation cost one lookup.
    private var names: [String: String] = [:]

    /// Avatar/icon URLs from the same lookup, keyed the same way. Empty string is a valid
    /// resolved value — it means the conversation has no avatar and the row falls back to
    /// initials.
    private var avatars: [String: String] = [:]
    private var inFlight: Set<String> = []

    /// Called on the main queue when a lazy hydration finishes.
    var onResolved: ((_ cacheKey: String) -> Void)?

    /// One key per source conversation. A 1:1 message the logged-in user received is
    /// addressed to themselves, so its conversation is the sender's: keying it by
    /// `receiverUid` would put every received 1:1 row under one key, and the first sender's
    /// name would label rows from everyone else.
    static func cacheKey(for message: BaseMessage) -> String {
        if message.receiverType == .group {
            return "group:\(message.receiverUid)"
        }
        if isReceivedOneToOne(message), let senderUid = message.sender?.uid, !senderUid.isEmpty {
            return "user:\(senderUid)"
        }
        return "user:\(message.receiverUid)"
    }

    private static func isReceivedOneToOne(_ message: BaseMessage) -> Bool {
        return message.receiverType == .user && LoggedInUserInformation.isLoggedInUser(uid: message.receiverUid)
    }

    /// The source conversation's name and avatar as the message itself carries them, the way
    /// Android's saved row does (`SavedMessagesAdapter`): the group, or for 1:1 the other
    /// party, the receiver if the user sent it, the sender if they received it. A message
    /// read from the offline cache keeps the server's `receiver` and `sender` entities, so
    /// this names the row with no network. `nil` when the payload has no name, such as a
    /// receiver known only by its id.
    static func payloadSource(for message: BaseMessage) -> (name: String, avatar: String)? {
        if message.receiverType == .group {
            guard let group = message.receiver as? Group,
                  let name = group.name, !name.isEmpty else { return nil }
            return (name, group.icon ?? "")
        }
        let peer: User? = isReceivedOneToOne(message) ? message.sender : message.receiver as? User
        guard let name = peer?.name, !name.isEmpty else { return nil }
        return (name, peer?.avatar ?? "")
    }

    /// The conversation name to draw right now — this is the row's title. Returns a resolved
    /// name when known, else the name the message carries, else the raw id while a lookup
    /// runs for next time.
    func label(for message: BaseMessage) -> String {
        let key = SavedMessagesSourceResolver.cacheKey(for: message)

        if let name = names[key] {
            return name
        }

        if let source = SavedMessagesSourceResolver.payloadSource(for: message) {
            names[key] = source.name
            avatars[key] = source.avatar
            return source.name
        }

        hydrate(message: message, key: key)
        return message.receiverUid
    }

    /// The conversation's avatar to draw right now, or `""` until one resolves. Never fetches
    /// on its own — `label(for:)` is called first for every row and owns the hydration.
    func avatar(for message: BaseMessage) -> String {
        let key = SavedMessagesSourceResolver.cacheKey(for: message)

        if let avatar = avatars[key] {
            return avatar
        }

        return SavedMessagesSourceResolver.payloadSource(for: message)?.avatar ?? ""
    }

    private func hydrate(message: BaseMessage, key: String) {
        guard !inFlight.contains(key) else { return }

        // A received 1:1 message resolves to its sender, who already arrived with the
        // payload — no fetch needed, and fetching `receiverUid` would return the
        // logged-in user.
        if SavedMessagesSourceResolver.isReceivedOneToOne(message) {
            return
        }

        inFlight.insert(key)

        let finish: (String?, String?) -> Void = { [weak self] resolvedName, resolvedAvatar in
            DispatchQueue.main.async {
                guard let this = self else { return }
                this.inFlight.remove(key)
                guard let resolvedName = resolvedName, !resolvedName.isEmpty else { return }
                this.names[key] = resolvedName
                this.avatars[key] = resolvedAvatar ?? ""
                this.onResolved?(key)
            }
        }

        if message.receiverType == .group {
            CometChat.getGroup(GUID: message.receiverUid) { group in
                finish(group.name, group.icon)
            } onError: { _ in
                finish(nil, nil)
            }
        } else {
            CometChat.getUser(UID: message.receiverUid) { user in
                finish(user?.name, user?.avatar)
            } onError: { _ in
                finish(nil, nil)
            }
        }
    }
}
