//
//  SavedMessagesViewModel + EventListener.swift
//  CometChatUIKitSwift
//

import Foundation
import CometChatSDK

extension SavedMessagesViewModel: CometChatMessageEventListener {

    /// Fires for save *and* unsave from this device, so the state is read off the message
    /// rather than inferred from the event.
    ///
    /// Unlike the pinned panel there is no conversation guard: saved messages are a
    /// user-level collection spanning every conversation (doc §6.4), so a save made
    /// anywhere belongs in this list.
    public func ccMessageSaved(message: BaseMessage, status: MessageStatus) {
        guard status == .success else { return }

        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            if MessageUtils.isSaved(message: message) {
                this.add(message: message)
            } else {
                this.remove(messageId: message.id)
            }
        }
    }

    /// Save is private but multi-device, so another device of the same user can add a row
    /// here. Fires only for the saving user (doc §5.5).
    public func onMessageSaved(message: BaseMessage) {
        DispatchQueue.main.async { [weak self] in
            self?.add(message: message)
        }
    }

    public func onMessageUnsaved(message: BaseMessage) {
        DispatchQueue.main.async { [weak self] in
            self?.remove(messageId: message.id)
        }
    }

    /// A deleted message can no longer be saved anywhere, so drop the row.
    public func onMessageDeleted(message: BaseMessage) {
        DispatchQueue.main.async { [weak self] in
            self?.remove(messageId: message.id)
        }
    }
}
