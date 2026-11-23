//
//  AttachmentRestore.swift
//  CometChatUIKitSwift
//
//  Pure rules for restoring the composer's upload tray after the app was killed (BEH-UPLOAD-14,
//  UIK-UPLOAD-01). The SDK keeps the batch on disk; the kit redraws tiles from `getItems()` and
//  never uploads anything by itself.
//

import Foundation
import CometChatSDK

internal enum AttachmentRestore {

    /// The settled `(receiver, type, parent)` a batch belongs to. Restore runs once per triple.
    static func tripleKey(receiverId: String, receiverType: CometChat.ReceiverType, parentMessageId: Int?) -> String {
        return "\(receiverType.rawValue):\(receiverId):\(parentMessageId ?? 0)"
    }

    /// `UPLOADED -> done`, `REJECTED -> rejected`, anything else `failed` with Retry.
    static func tileStatus(for state: UploadFileState) -> AttachmentTileStatus {
        switch state {
        case .uploaded: return .done
        case .rejected: return .rejected
        case .queued, .uploading, .failed: return .failed
        @unknown default: return .failed
        }
    }

    /// Whether a restore should run now: nothing is staged, and this triple was not restored yet.
    static func shouldRestore(hasRequest: Bool, hasTiles: Bool, lastRestoredKey: String?, key: String, receiverId: String) -> Bool {
        return !hasRequest && !hasTiles && !receiverId.isEmpty && lastRestoredKey != key
    }
}
