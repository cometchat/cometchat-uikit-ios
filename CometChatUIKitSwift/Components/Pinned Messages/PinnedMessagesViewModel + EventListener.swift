//
//  PinnedMessagesViewModel + EventListener.swift
//  CometChatUIKitSwift
//

import Foundation
import CometChatSDK

extension PinnedMessagesViewModel: CometChatMessageEventListener {

    /// Fires for pin *and* unpin from this device, so the state is read off the message
    /// rather than inferred from the event.
    public func ccMessagePinned(message: BaseMessage, status: MessageStatus) {
        guard status == .success, belongsToThisConversation(message) else { return }

        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            if MessageUtils.isPinned(message: message) {
                this.add(message: message)
            } else {
                this.remove(messageId: message.id)
            }
        }
    }

    /// Someone else pinned a message in this conversation, or the logged-in user pinned it
    /// from another device. Pin is conversation-wide, so this is the common case rather than
    /// an edge one — without it an open panel silently misses every pin it did not make.
    ///
    /// Safe alongside `ccMessagePinned`: the acting device receives both, and `add(message:)`
    /// ignores an id it already holds.
    public func onMessagePinned(message: BaseMessage) {
        guard belongsToThisConversation(message) else { return }

        DispatchQueue.main.async { [weak self] in
            self?.add(message: message)
        }
    }

    /// No conversation guard: the row is addressed by id, so an unpin from elsewhere simply
    /// finds nothing to remove.
    public func onMessageUnpinned(message: BaseMessage) {
        DispatchQueue.main.async { [weak self] in
            self?.remove(messageId: message.id)
        }
    }

    /// A deleted message can no longer be pinned anywhere, so drop the row.
    public func onMessageDeleted(message: BaseMessage) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.remove(messageId: message.id)
        }
    }

    /// The panel is scoped to one channel; a pin in another conversation must not leak in.
    private func belongsToThisConversation(_ message: BaseMessage) -> Bool {
        if let guid = group?.guid, !guid.isEmpty {
            return message.receiverType == .group && message.receiverUid == guid
        }
        if let uid = user?.uid, !uid.isEmpty {
            // A 1:1 message matches whether the logged-in user sent or received it.
            return message.receiverType == .user && (message.receiverUid == uid || message.senderUid == uid)
        }
        return false
    }
}
