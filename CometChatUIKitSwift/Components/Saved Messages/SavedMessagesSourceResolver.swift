//
//  SavedMessagesSourceResolver.swift
//  CometChatUIKitSwift
//

import Foundation
import CometChatSDK

/// Resolves the conversation a saved message came from.
///
/// Saved messages span conversations (doc §6.4), so every row has to say where it is from.
/// The message payload carries `receiverUid`/`receiverType` but only the raw id, so the
/// display name is resolved here: cache first, network only on a miss. Never blocks a row —
/// the caller renders the raw id and repaints when `onResolved` fires (recipe step 1).
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

    static func cacheKey(for message: BaseMessage) -> String {
        return "\(message.receiverType == .group ? "group" : "user"):\(message.receiverUid)"
    }

    /// The conversation name to draw right now — this is the row's title. Returns a resolved
    /// name when known, otherwise the raw id, and kicks off a hydration for next time.
    func label(for message: BaseMessage) -> String {
        let key = SavedMessagesSourceResolver.cacheKey(for: message)

        if let name = names[key] {
            return name
        }

        hydrate(message: message, key: key)

        // A 1:1 message the logged-in user sent is addressed TO the other party, but one
        // they received is addressed to themselves — show the sender instead, or the row
        // would read as the user's own name.
        if message.receiverType == .user,
           LoggedInUserInformation.isLoggedInUser(uid: message.receiverUid),
           let senderName = message.sender?.name, !senderName.isEmpty {
            return senderName
        }

        return message.receiverUid
    }

    /// The conversation's avatar to draw right now, or `""` until one resolves. Never fetches
    /// on its own — `label(for:)` is called first for every row and owns the hydration.
    func avatar(for message: BaseMessage) -> String {
        let key = SavedMessagesSourceResolver.cacheKey(for: message)

        if let avatar = avatars[key] {
            return avatar
        }

        // Mirrors `label(for:)`: a received 1:1 message resolves to its sender, so the avatar
        // has to follow the name to the same party or the row pairs one person's picture with
        // another's name on first render.
        if message.receiverType == .user,
           LoggedInUserInformation.isLoggedInUser(uid: message.receiverUid),
           let senderAvatar = message.sender?.avatar {
            return senderAvatar
        }

        return ""
    }

    private func hydrate(message: BaseMessage, key: String) {
        guard !inFlight.contains(key) else { return }

        // A received 1:1 message resolves to its sender, who already arrived with the
        // payload — no fetch needed, and fetching `receiverUid` would return the
        // logged-in user.
        if message.receiverType == .user, LoggedInUserInformation.isLoggedInUser(uid: message.receiverUid) {
            if let senderName = message.sender?.name, !senderName.isEmpty {
                names[key] = senderName
                avatars[key] = message.sender?.avatar ?? ""
            }
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
