//
//  MessageIdentity.swift
//  CometChatUIKitSwift
//
//  Row identity and send state for the offline (ON) path. Nothing here runs with offline
//  off: the OFF path keeps today's id/muid matching exactly.
//
//  A row is keyed by its server id once it has one, then by the SDK's `localMessageId`,
//  then by the own `muid` (an integrator-set muid still matches).
//
//  No UIKit imports on purpose: this folder is lifted unchanged into the v6 stores.
//

import Foundation
import CometChatSDK

internal enum MessageIdentity {

    /// The server id, or `0` until the server has acked the message.
    static func serverId(_ message: BaseMessage) -> Int {
        return message.id > 0 ? message.id : 0
    }

    /// The SDK's local handle for an own message.
    ///
    /// `BaseMessage.localMessageId` is set on own sends, on sweep deliveries and on cache reads, but
    /// not on realtime or server-phase deliveries (SDK ask A4), so fall back to the raw payload's
    /// `data.localMessageId`.
    static func localId(_ message: BaseMessage) -> String? {
        if let direct = message.localMessageId, !direct.isEmpty { return direct }
        if let data = message.rawMessage?["data"] as? [String: Any],
           let local = data["localMessageId"] as? String, !local.isEmpty {
            return local
        }
        return nil
    }

    /// The developer-visible muid, or `nil` when empty.
    static func muid(_ message: BaseMessage) -> String? {
        return message.muid.isEmpty ? nil : message.muid
    }

    /// Whether the message was delivered by the SDK's catch-up sweep.
    static func isSyncDelivered(_ message: BaseMessage) -> Bool {
        return syncSourceProvider(message)
    }

    /// A seam: `BaseMessage.source` has an SDK-internal setter, so a unit test cannot build a
    /// swept message and replaces this.
    static var syncSourceProvider: (BaseMessage) -> Bool = { $0.source == .sync }

    /// The SDK's derived send state (`messageStatus`). A seam: `BaseMessage`'s send state is
    /// SDK-internal, so a unit test cannot build a PENDING or FAILED message and replaces this.
    static var statusProvider: (BaseMessage) -> CometChat.MessageStatus = { $0.messageStatus }

    static func status(_ message: BaseMessage) -> CometChat.MessageStatus {
        return statusProvider(message)
    }

    /// Why a FAILED message failed (BEH-SEND-35), as the SDK handed it over. `nil` when the SDK does
    /// not know (after a relaunch the reason can be lost, R95). A seam: the SDK's setter is internal.
    static var failureReasonProvider: (BaseMessage) -> CometChat.MessageFailureReason? = { $0.failureReason }

    /// PENDING or SENDING: on its way, shown with the clock.
    static func isSending(_ message: BaseMessage) -> Bool {
        let status = self.status(message)
        return status == .pending || status == .sending
    }

    /// FAILED in the outbox. Derived from the SDK's status, so it survives a restart.
    static func isOutboxFailed(_ message: BaseMessage) -> Bool {
        return status(message) == .failed
    }

    /// Not acked by the server yet: PENDING, SENDING or FAILED, or no server id on an own message
    /// that carries a local handle or muid (the composer's optimistic row).
    static func isUnsent(_ message: BaseMessage) -> Bool {
        if isSending(message) || isOutboxFailed(message) { return true }
        guard serverId(message) == 0 else { return false }
        return message.messageCategory == .message && (localId(message) != nil || muid(message) != nil)
    }

    /// The compose time of an unsent row (seconds), from the muid the composer stamps, else `sentAt`.
    static func composeTime(_ message: BaseMessage) -> Double {
        if let muid = muid(message), let seconds = Double(muid), seconds > 0 { return seconds }
        return Double(message.sentAt)
    }

    /// The list key on the ON path.
    static func rowKey(_ message: BaseMessage) -> String {
        let id = serverId(message)
        if id > 0 { return "s:\(id)" }
        if let local = localId(message) { return "l:\(local)" }
        return "m:\(message.muid)"
    }

    /// The key a cell is rendered under: stable from compose to ack for an own message, so the
    /// bubble does not remount when the ack arrives. Other senders' rows key on the server id only.
    static func renderKey(_ message: BaseMessage, isOwn: Bool) -> String {
        guard isOwn else { return "s:\(message.id)" }
        if let local = localId(message) { return "l:\(local)" }
        if let muid = muid(message) { return "m:\(muid)" }
        return "s:\(message.id)"
    }
}
