//
//  OfflineSend.swift
//  CometChatUIKitSwift
//
//  The one send helper for every own send on the offline (ON) path: composer, compact composer,
//  voice notes, stickers, extension messages, smart replies and the `CometChatUIKit.send*` statics.
//
//  It sends with the SDK's three-callback overloads (the form the SDK queues offline) and reports
//  each transition to the `OfflineHub`, which draws the row and emits the public events exactly
//  once. Callers read the gate themselves when the user taps send and call this only when it said
//  "on"; with offline off they keep today's path untouched.
//
//  State contract:
//    pending                       -> row `sending` (the clock); queued is NOT failed
//    error after pending, queued   -> row stays `sending`; the outbox reports the final state
//    error with no pending         -> `failed (direct)`: not in the outbox, Retry is a fresh send
//    QUEUE_FULL / BYTE_OVERFLOW    -> `failed (direct)` even after a pending callback (SDK ask A7)
//    sent                          -> row replaced in place; one public success
//    session ends / cache resets   -> a send still waiting for an answer is answered once, quietly, with
//                                     ERROR_OFFLINE_MESSAGE_DISCARDED; a send that is only queued while the
//                                     session is alive is never failed
//
//  No UIKit imports.
//

import Foundation
import CometChatSDK

internal enum OfflineSend {

    /// The error a send is answered with when the session ends or the offline cache is reset before it
    /// was sent: the SDK's own code for a removed unsent message (and the Android kit's).
    static let discardedCode = "ERROR_OFFLINE_MESSAGE_DISCARDED"
    static let sessionEndedText = "The session ended before the message was sent."
    static let cacheResetText = "The offline cache was reset before the message was sent."

    /// A rejection the kit never shows as an error: the session ended (logout, user switch) or the unsent
    /// message was removed. The row going away is the only signal. Kit callers (composer, stickers,
    /// smart replies) skip their error handling for it; the public `CometChatUIKit.send*` completions
    /// still receive it once.
    static func isQuietRejection(_ error: CometChatException?) -> Bool {
        guard let code = error?.errorCode else { return false }
        return code == discardedCode || code == "ERROR_USER_NOT_LOGGED_IN"
    }

    /// Longest a caller waits for the first answer of a send before it carries on (seconds).
    static let defaultFirstAnswerTimeout: TimeInterval = 30

    /// How a send stands once the SDK has answered the first time.
    struct Outcome {
        enum State { case sent, queued, failed }
        let state: State
        let message: BaseMessage
        let error: CometChatException?
        /// Failed without entering the outbox; Retry is a fresh send.
        let direct: Bool
    }

    /// Informational fallback for the per-call `onError`, which carries no `MessageFailureReason`.
    /// The authoritative classification is the outbox listener's reason (see `OfflineHub`).
    private static func refusalReason(for error: CometChatException?) -> CometChat.MessageFailureReason? {
        switch error?.errorCode {
        case "ERROR_QUEUE_FULL": return .queueFull
        case "ERROR_OFFLINE_MEDIA_BYTE_OVERFLOW": return .byteOverflow
        default: return nil
        }
    }

    /// The per-call `onError` of a queued message the SDK removed: its final failure, which the
    /// outbox listener reports too (`OfflineHub.reportSDKRemoval`).
    static func removalReason(for error: CometChatException?) -> CometChat.MessageFailureReason? {
        switch error?.errorCode {
        case "ERROR_QUEUE_OVERFLOW": return .queueOverflow
        case "ERROR_OFFLINE_MESSAGE_DISCARDED": return .discarded
        default: return nil
        }
    }

    private static func onMain(_ block: @escaping () -> Void) {
        if Thread.isMainThread { block() } else { DispatchQueue.main.async(execute: block) }
    }

    /// Send `message` on the offline path. `onSettled` fires once, on the main thread, when the SDK
    /// has answered the first time (sent, queued or failed). Later transitions of a queued send
    /// arrive through the hub's outbox bridge. Never waits on a result for UI state.
    ///
    /// `onFirstAnswer` is for a caller that holds something (a composer lock, the next item of a
    /// batch) until the send has been answered. It fires once, on the main thread, at the FIRST of:
    /// the pending callback, a sent/error answer, or `firstAnswerTimeout`. Offline the SDK gives a
    /// send queued behind another unsent send of the same chat only the pending callback and no
    /// further one (SDK Outbox R77), so waiting for sent/error would hold the lock forever; the
    /// outbox keeps the chat's order, so releasing at pending is safe.
    static func send(_ message: BaseMessage,
                     announced: Bool = true,
                     hub: OfflineHub = .shared,
                     sdk: OfflineSDK = LiveOfflineSDK.shared,
                     onFirstAnswer: (() -> Void)? = nil,
                     firstAnswerTimeout: TimeInterval = OfflineSend.defaultFirstAnswerTimeout,
                     onSettled: ((Outcome) -> Void)? = nil) {
        hub.track(message)
        var answered = false
        let answer: () -> Void = {
            onMain {
                guard !answered else { return }
                answered = true
                onFirstAnswer?()
            }
        }
        if onFirstAnswer != nil, firstAnswerTimeout > 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + firstAnswerTimeout, execute: answer)
        }
        let kind = OfflineSendKind.of(message)
        var pendingMessage: BaseMessage?
        // The caller hears "queued" at most once and its final answer (sent or failed) at most once; a
        // final answer can follow "queued".
        var queuedReported = false
        var finalAnswered = false
        let open = hub.openSend()
        let settle: (Outcome) -> Void = { outcome in
            answer()
            onMain {
                guard !finalAnswered else { return }
                if outcome.state == .queued {
                    guard !queuedReported else { return }
                    queuedReported = true
                } else {
                    finalAnswered = true
                    hub.closeOpenSend(open)
                }
                onSettled?(outcome)
            }
        }
        // A session end or a cache reset answers the caller once, quietly.
        open.reject = { text in
            settle(Outcome(state: .failed,
                           message: pendingMessage ?? message,
                           error: CometChatException(errorCode: discardedCode, errorDescription: text),
                           direct: false))
        }

        let failDirect: (BaseMessage, CometChatException?, CometChat.MessageFailureReason?) -> Void = { failed, error, reason in
            let accepted = hub.reportSendState(failed, .failed, reason: reason, direct: true)
            if accepted, let reason = reason {
                hub.notify(OfflineNotice(gen: hub.gen,
                                         kind: reason == .queueFull ? .queueFull : .fileTooLargeOffline,
                                         count: 1,
                                         message: failed))
            }
            settle(Outcome(state: .failed, message: failed, error: error, direct: true))
        }

        sdk.send(message, kind: kind,
                 onPending: { pending in
                    pendingMessage = pending
                    open.pendingSeen = true
                    hub.reportSendState(pending, .sending, announced: announced)
                    answer()
                 },
                 onSent: { sent in
                    hub.reportSendState(sent, .sent)
                    settle(Outcome(state: .sent, message: sent, error: nil, direct: false))
                 },
                 onError: { error in
                    let refusal = refusalReason(for: error)
                    guard let pending = pendingMessage else {
                        // No pending callback came first: the SDK never queued it (BEH-SEND-33).
                        failDirect(message, error, refusal)
                        return
                    }
                    if refusal != nil {
                        // iOS fires pending before refusing a full queue (A7).
                        failDirect(pending, error, refusal)
                        return
                    }
                    if let removal = removalReason(for: error) {
                        // The SDK removed the queued message (DROP_OLDEST evicted it, or a purge):
                        // a removal, never a failed row. Neither sent nor failed for the call site.
                        hub.reportSDKRemoval(pending, reason: removal)
                        // A discarded send (a readable cache reset failing each unsent message, or the
                        // user's Delete) is answered once, quietly. An eviction stays "queued" for the call
                        // site, as before.
                        let state: Outcome.State = removal == .discarded ? .failed : .queued
                        settle(Outcome(state: state, message: pending, error: error, direct: false))
                        return
                    }
                    if MessageIdentity.isOutboxFailed(pending) {
                        hub.reportSendState(pending, .failed)
                        settle(Outcome(state: .failed, message: pending, error: error, direct: false))
                        return
                    }
                    // Queued, not failed (BEH-SEND-10): the row keeps the clock and the outbox
                    // reports the final state.
                    settle(Outcome(state: .queued, message: pending, error: error, direct: false))
                 })
    }

    /// For call sites that follow the "inProgress, send, success or error" pattern. The hub emits the
    /// public `ccMessageSent` transitions, so the call site runs only its own extras:
    /// `onSent` once the server acked, `onFailed` once on a direct or final failure. A send that is
    /// merely queued calls neither: it is not a failure, and the outbox reports its final state.
    ///
    /// `quietly`: for the kit's own callers (composer, stickers, smart replies). A quiet rejection (the
    /// session ended, or the message was removed: `isQuietRejection`) reaches neither callback, so no
    /// error is shown for it. The public `CometChatUIKit.send*` completions leave it off and receive
    /// the rejection once, with `ERROR_OFFLINE_MESSAGE_DISCARDED`.
    static func send(_ message: BaseMessage,
                     hub: OfflineHub = .shared,
                     sdk: OfflineSDK = LiveOfflineSDK.shared,
                     onFirstAnswer: (() -> Void)? = nil,
                     quietly: Bool = false,
                     onSent: ((BaseMessage) -> Void)?,
                     onFailed: ((CometChatException) -> Void)?) {
        send(message, hub: hub, sdk: sdk, onFirstAnswer: onFirstAnswer) { outcome in
            switch outcome.state {
            case .sent:
                onSent?(outcome.message)
            case .failed:
                if quietly && isQuietRejection(outcome.error) { break }
                onFailed?(outcome.error ?? CometChatException(errorCode: "ERROR_MESSAGE_NOT_SENT",
                                                              errorDescription: "The message could not be sent."))
            case .queued:
                break
            }
        }
    }

    // MARK: Unsent-row actions (BEH-SEND-36/37, product decision 2026-10-30)

    /// Retry on the user's tap. An outbox row (PENDING, SENDING or FAILED with any reason: R162) is
    /// retried by the SDK (`retryMessage(localMessageId)`), never sent again as a new message; one
    /// whose send is under way is answered `ERROR_OFFLINE_MESSAGE_IN_FLIGHT` (`RetryResult.inFlight`).
    /// A direct failure is sent again as a fresh send through this
    /// helper (the SDK stamps a new `localMessageId`; the row is found again by its muid). The kit
    /// never retries by itself (BEH-SEND-18, UIK-SEND-07), and a tap while a Retry of the same row is
    /// still in flight is ignored. `completion` reports how the Retry was answered.
    static func retry(_ message: BaseMessage,
                      hub: OfflineHub = .shared,
                      sdk: OfflineSDK = LiveOfflineSDK.shared,
                      completion: ((RetryResult) -> Void)? = nil) {
        guard hub.beginRetry(message) else {
            onMain { completion?(.ignored) }
            return
        }
        guard let local = MessageIdentity.localId(message), !hub.isDirectFailed(message) else {
            hub.clearDirectFailed(message)
            var answered = false   // "queued" and then a final answer both reach onSettled; Retry answers once
            send(message, announced: false, hub: hub, sdk: sdk, onFirstAnswer: {
                hub.endRetry(message)
            }, onSettled: { _ in
                guard !answered else { return }
                answered = true
                hub.endRetry(message)
                completion?(.accepted)
            })
            return
        }
        sdk.retry(localMessageId: local, onSuccess: {
            hub.endRetry(message)
            onMain { completion?(.accepted) }
        }, onError: { error in
            hub.endRetry(message)
            let result = RetryResult(error)
            if case .rejected = result {
                CometChatLogger.warning("retryMessage refused: \(error.errorCode)")
            }
            onMain { completion?(result) }
        })
    }

    enum RetryResult: Equatable {
        /// Sent, or accepted and now waiting in the outbox.
        case accepted
        /// A Retry of this row was already in flight; this tap did nothing.
        case ignored
        /// The SDK is sending it right now (`ERROR_OFFLINE_MESSAGE_IN_FLIGHT`): nothing changed. The
        /// caller shows the "Sending... try again in a moment" notice (R162).
        case inFlight
        /// The outbox no longer holds it (`ERROR_OFFLINE_MESSAGE_NOT_FOUND`): it went out or is gone.
        /// The caller removes the row unless it already shows its server id (ENG-57447).
        case notFound
        /// Offline was switched off (`ERROR_OFFLINE_DISABLED`): the kill-switch row path applies.
        case disabled
        /// Any other refusal, or the not-connected notice of a Retry that got no answer.
        case rejected(code: String)

        init(_ error: CometChatException) {
            switch error.errorCode {
            case "ERROR_OFFLINE_MESSAGE_IN_FLIGHT": self = .inFlight
            case "ERROR_OFFLINE_MESSAGE_NOT_FOUND": self = .notFound
            case "ERROR_OFFLINE_DISABLED": self = .disabled
            default: self = .rejected(code: error.errorCode)
            }
        }
    }

    /// How a Delete of an unsent row was answered.
    enum DiscardResult: Equatable {
        /// The row may be removed: the SDK discarded it durably, or it was a direct failure that only
        /// ever lived on screen.
        case removed
        /// `ERROR_OFFLINE_MESSAGE_IN_FLIGHT`: keep the row and show the "Sending... try again in a
        /// moment" notice (R162).
        case inFlight
        /// `ERROR_OFFLINE_MESSAGE_NOT_FOUND`: the message already went out (or is gone). The caller
        /// removes the row at once, or deletes it on the server when the row shows its server id
        /// (ENG-57447).
        case notFound
        /// `ERROR_OFFLINE_DISABLED`: the kill switch flipped. The row is a failed (direct) row now.
        case disabled
        /// Any other refusal (e.g. the store momentarily unavailable): keep the row, show the error.
        case failed(code: String)
    }

    /// Delete an unsent own row (BEH-SEND-36). An outbox row goes through `discardLocalMessage`
    /// (durable, device-only; no outbox event follows a success, so the hub reports the removal).
    /// A direct failure was never stored, so it is removed from the screen only.
    static func discard(_ message: BaseMessage,
                        hub: OfflineHub = .shared,
                        sdk: OfflineSDK = LiveOfflineSDK.shared,
                        completion: @escaping (DiscardResult) -> Void) {
        let removed: () -> Void = {
            hub.clearDirectFailed(message)
            hub.reportUserDiscard(message)
            onMain { completion(.removed) }
        }
        guard let local = MessageIdentity.localId(message), !hub.isDirectFailed(message) else {
            removed()
            return
        }
        sdk.discard(localMessageId: local, onSuccess: removed, onError: { error in
            CometChatLogger.warning("discardLocalMessage refused: \(error.errorCode)")
            let result: DiscardResult
            switch error.errorCode {
            case "ERROR_OFFLINE_MESSAGE_IN_FLIGHT": result = .inFlight
            case "ERROR_OFFLINE_MESSAGE_NOT_FOUND": result = .notFound
            case "ERROR_OFFLINE_DISABLED": result = .disabled
            default: result = .failed(code: error.errorCode)
            }
            onMain { completion(result) }
        })
    }
}

/// What an own unsent row's options menu offers: Retry and Delete (ruling R162 / S73, 2026-11-03,
/// which rewrote BEH-SEND-37 and supersedes UIK-SEND-05 / BEH-SEND-37 as first written). Nothing
/// that needs a server id. Copy is not offered on an unsent row.
internal enum OfflineUnsentAction: Equatable {
    case retry, delete
}

internal enum OfflineUnsentActions {

    /// R162: Retry and Delete on every own message the server has not acked, whatever the SDK says
    /// about it: PENDING, SENDING, FAILED for any reason, and a direct failure kept in memory
    /// (BEH-SEND-33, queue full, byte overflow, kill switch).
    ///
    /// The SDK decides what a tap can do. On a message whose send is under way it answers
    /// `ERROR_OFFLINE_MESSAGE_IN_FLIGHT` and changes nothing, and the kit then shows the
    /// "Sending... try again in a moment" notice. The kit keeps no in-flight list of its own.
    static func actions(for message: BaseMessage, hub: OfflineHub = .shared) -> [OfflineUnsentAction] {
        if hub.isDirectFailed(message) { return [.retry, .delete] }
        guard MessageIdentity.serverId(message) == 0 else { return [] }
        switch MessageIdentity.status(message) {
        case .pending, .sending:
            // No local handle yet: the composer's own object before `onMessagePending`. There is
            // nothing to hand the SDK's retry, and a fresh send would duplicate it.
            return MessageIdentity.localId(message) == nil ? [] : [.retry, .delete]
        case .failed:
            return [.retry, .delete]
        default:
            return []
        }
    }

    /// Whether a tap on the row's status icon retries it, and a failed row shows its "Tap to retry"
    /// line. Everything the menu retries, except a row the SDK is sending right now: its clock stays
    /// a plain clock (its Retry is in the menu and the VoiceOver actions), because a stray tap there
    /// could only answer "in flight".
    static func statusTapRetries(_ message: BaseMessage, hub: OfflineHub = .shared) -> Bool {
        guard actions(for: message, hub: hub).contains(.retry) else { return false }
        return hub.isDirectFailed(message) || MessageIdentity.isOutboxFailed(message) || MessageIdentity.status(message) != .sending
    }
}
