//
//  OfflineNotices.swift
//  CometChatUIKitSwift
//
//  Localized text for the offline notices and the unsent-row labels. Counted strings use a
//  singular and a plural key (`_ONE` / `_OTHER`) chosen by the count.
//

import Foundation

internal enum OfflineText {

    static func notice(_ notice: OfflineNotice) -> String {
        switch notice.kind {
        case .unsentMessageRemoved: return "UNSENT_MESSAGE_REMOVED".localize()
        case .queueFull: return "OFFLINE_QUEUE_FULL".localize()
        case .fileTooLargeOffline: return "OFFLINE_FILE_TOO_LARGE".localize()
        case .messagesNotSent: return counted("MESSAGES_NOT_SENT", notice.count)
        case .unsentMessagesLost: return counted("UNSENT_MESSAGES_LOST", notice.count)
        case .unsentMessagesMaybeLost: return "UNSENT_MESSAGES_MAYBE_LOST".localize()
        case .sendInFlight: return "SEND_IN_FLIGHT".localize()
        }
    }

    /// How long a notice stays on screen (seconds). The in-flight notice is a short hint that the
    /// user tapped too early, so it goes after 4 s (R162); the others keep the toast's default.
    static func duration(of notice: OfflineNotice) -> TimeInterval {
        switch notice.kind {
        case .sendInFlight: return sendInFlightDuration
        default: return 3
        }
    }

    static let sendInFlightDuration: TimeInterval = 4

    /// The string key of a notice, for its state-contract identifier.
    static func noticeKey(_ notice: OfflineNotice) -> String {
        switch notice.kind {
        case .unsentMessageRemoved: return "UNSENT_MESSAGE_REMOVED"
        case .queueFull: return "OFFLINE_QUEUE_FULL"
        case .fileTooLargeOffline: return "OFFLINE_FILE_TOO_LARGE"
        case .messagesNotSent: return notice.count == 1 ? "MESSAGES_NOT_SENT_ONE" : "MESSAGES_NOT_SENT_OTHER"
        case .unsentMessagesLost: return notice.count == 1 ? "UNSENT_MESSAGES_LOST_ONE" : "UNSENT_MESSAGES_LOST_OTHER"
        case .unsentMessagesMaybeLost: return "UNSENT_MESSAGES_MAYBE_LOST"
        case .sendInFlight: return "SEND_IN_FLIGHT"
        }
    }

    static func counted(_ baseKey: String, _ count: Int) -> String {
        let key = count == 1 ? "\(baseKey)_ONE" : "\(baseKey)_OTHER"
        let format = key.localize()
        return format.contains("%d") ? String(format: format, count) : format
    }

    /// The status text key of an unsent row: queued -> "Not sent yet"; failed -> "Not sent. Tap to
    /// retry". Every failed row can be retried (R162), so there is no "Not sent" line without Retry.
    static func unsentStatusKey(failed: Bool) -> String {
        return failed ? "MESSAGE_NOT_SENT_TAP_TO_RETRY" : "MESSAGE_NOT_SENT_YET"
    }

    /// Spoken label of the status icon of an unsent row.
    static func accessibilityLabel(for status: ReceiptStatus) -> String? {
        switch status {
        case .inProgress: return "MESSAGE_NOT_SENT_YET".localize()
        case .failed: return "MESSAGE_NOT_SENT_TAP_TO_RETRY".localize()
        default: return nil
        }
    }
}
