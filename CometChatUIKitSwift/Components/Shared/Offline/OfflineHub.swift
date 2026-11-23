//
//  OfflineHub.swift
//  CometChatUIKitSwift
//
//  The kit's single bridge from the Chat SDK's offline listeners to the screens that are mounted.
//
//  - Started from `CometChatUIKit` init, once, and never gated on the offline switch at start: the
//    SDK listeners are inert while offline is off, and a cold start with a restored session, an app
//    that calls `CometChat.login` itself and a relaunch after process death must all get outbox and
//    sync events (per-send listeners die with the process).
//  - Registers each SDK listener once, under its OWN id (the SDK keeps one id map for every
//    listener type, so reusing an id would replace the earlier listener).
//  - Never unregistered on logout (SDK registrations survive logout and login). A logout or user
//    switch clears the hub's own bookkeeping and bumps `gen`, so late callbacks from the old
//    session are dropped by every screen.
//  - Fans out to mounted screens through `OfflineHubObserver`, on the main queue, in arrival
//    order, one event at a time (lossless). Screens never register the SDK listeners themselves.
//  - Emits exactly one public event per transition per `localMessageId`: the per-send listener and
//    the outbox listener both report here, and the transitions are forward-only.
//
//  No UIKit imports.
//

import Foundation
import CometChatSDK

// MARK: - Events

internal struct OfflineSendStateEvent {
    let gen: Int
    /// `nil` only for a direct failure of a message the SDK never queued and never stamped.
    let localMessageId: String?
    let message: BaseMessage
    let state: CometChatMessageSendState
    let reason: CometChat.MessageFailureReason?
    /// A failure the outbox does not hold (an error with no prior pending, or a queue-full or
    /// byte-overflow refusal): its Retry is a fresh send.
    let direct: Bool
}

internal struct OfflineMessageSyncEvent {
    let gen: Int
    let messages: [BaseMessage]
    let outcome: CometChat.SyncOutcome
}

internal struct OfflineConversationSyncEvent {
    let gen: Int
    let conversations: [Conversation]
}

internal struct OfflineMessagesUpdatedEvent {
    let gen: Int
    let messages: [BaseMessage]
}

internal struct OfflineSyncFailedEvent {
    enum Phase { case conversation, message }
    let gen: Int
    let phase: Phase
}

internal struct OfflineCacheResetEvent {
    let gen: Int
    let reason: CometChat.OfflineCacheResetReason
    /// `CometChat.offlinePendingCountUnknown` (-1) when the SDK cannot tell.
    let pendingMessagesLost: Int
}

internal struct OfflineMediaReadyEvent {
    let gen: Int
    let messageId: String
    let url: String
    let localPath: String
}

internal enum OfflineNoticeKind: Equatable {
    case unsentMessageRemoved
    case queueFull
    case fileTooLargeOffline
    case messagesNotSent
    case unsentMessagesLost
    case unsentMessagesMaybeLost
    /// Retry or Delete tapped while the SDK is sending the message (`ERROR_OFFLINE_MESSAGE_IN_FLIGHT`):
    /// "Sending... try again in a moment" (R162 / S73). Raised by the list that was tapped.
    case sendInFlight
}

/// A user-facing notice; the message list and conversation list render these.
internal struct OfflineNotice {
    let gen: Int
    let kind: OfflineNoticeKind
    var count: Int = 1
    /// The removed message, for Copy (text only).
    var message: BaseMessage?
    /// No list that shows this message was there to take it: whichever screen is there shows it, so a
    /// message that went is never gone in silence (P5).
    var forAnyScreen = false
}

/// Implemented by screens that mount while the hub runs. Registered through
/// `ListenerChannel.offlineHub`, so registration and removal are symmetric and testable.
internal protocol OfflineHubObserver: AnyObject {
    func offlineSendState(_ event: OfflineSendStateEvent)
    /// The sent copy of a message the user already removed arrived (ENG-57447). Not a send state:
    /// the message stays off screen. A list whose Delete asked for it deletes it on the server.
    func offlineSentAfterDiscard(_ event: OfflineSendStateEvent)
    func offlineMessageSyncCompleted(_ event: OfflineMessageSyncEvent)
    func offlineConversationSyncCompleted(_ event: OfflineConversationSyncEvent)
    func offlineMessagesUpdated(_ event: OfflineMessagesUpdatedEvent)
    func offlineSyncFailed(_ event: OfflineSyncFailedEvent)
    func offlineCacheReset(_ event: OfflineCacheResetEvent)
    func offlineMediaReady(_ event: OfflineMediaReadyEvent)
    /// Returns whether this screen showed the notice. A notice no screen takes waits for the next one.
    func offlineNotice(_ notice: OfflineNotice) -> Bool
    /// Logout, user switch or cache reset: clear and drop every callback older than `gen`.
    func offlineSessionChanged(gen: Int)
    /// A user logged in (the same user after a token refresh, or a new one).
    func offlineSessionStarted(gen: Int)
}

internal extension OfflineHubObserver {
    func offlineSendState(_ event: OfflineSendStateEvent) {}
    func offlineSentAfterDiscard(_ event: OfflineSendStateEvent) {}
    func offlineMessageSyncCompleted(_ event: OfflineMessageSyncEvent) {}
    func offlineConversationSyncCompleted(_ event: OfflineConversationSyncEvent) {}
    func offlineMessagesUpdated(_ event: OfflineMessagesUpdatedEvent) {}
    func offlineSyncFailed(_ event: OfflineSyncFailedEvent) {}
    func offlineCacheReset(_ event: OfflineCacheResetEvent) {}
    func offlineMediaReady(_ event: OfflineMediaReadyEvent) {}
    func offlineNotice(_ notice: OfflineNotice) -> Bool { return false }
    func offlineSessionChanged(gen: Int) {}
    func offlineSessionStarted(gen: Int) {}
}

// MARK: - Hub

internal final class OfflineHub: NSObject {

    internal static let shared = OfflineHub()

    /// Listener ids. One id per listener: the SDK's id map is shared across listener types.
    internal enum ListenerID {
        static let outbox = "uikit_offline_hub_outbox"
        static let sync = "uikit_offline_hub_sync"
        static let cacheReset = "uikit_offline_hub_cache_reset"
        static let media = "uikit_offline_hub_media"
        static let messagesSynced = "uikit_offline_hub_messages_synced"
        static let login = "uikit_offline_hub_login"
    }

    private static let maxTrackedSends = 500

    private let sdk: OfflineSDK
    /// Runs a block on the UI queue. Replaced by tests with an immediate executor.
    internal var deliver: (@escaping () -> Void) -> Void = { block in DispatchQueue.main.async(execute: block) }
    /// Public event emission; replaced by tests to record what integrators would see.
    internal var publicEvents: OfflinePublicEvents = LiveOfflinePublicEvents()

    private let lock = NSRecursiveLock()
    private var started = false
    private var genValue = 0
    private var sessionUid: String?

    /// Last state per send, keyed by `canonicalKey`. ON path only.
    private var lastState: [String: CometChatMessageSendState] = [:]
    private var lastStateOrder: [String] = []
    /// Own muids routed through the ON-path send helper this session.
    private var trackedMuids: Set<String> = []
    private var localIdByMuid: [String: String] = [:]
    /// Own messages that failed without entering the outbox, keyed by muid, with the reason.
    private var directFailures: Set<String> = []
    private var directFailureOrder: [String] = []
    /// The outbox reason each failed send last reported, keyed by `canonicalKey`. A fallback for a
    /// row object whose `failureReason` the SDK did not carry over (BEH-SEND-35, R95).
    private var failureReasons: [String: CometChat.MessageFailureReason] = [:]
    /// Sends with a user Retry in flight (UIK-SEND-07: further taps are ignored until it answers).
    private var retriesInFlight: Set<String> = []
    /// Whether an operation of this session took the offline (ON) path, so screens may show data the
    /// offline path put there. NOT a cached gate: no decision reads it to choose ON or OFF. It only
    /// decides whether a session change must clear and reload the mounted lists; with offline off a
    /// logout or login leaves every screen exactly as today (P1).
    private var offlineUsedThisSession = false
    /// The ended session had offline data on screen: the next login reloads what was cleared.
    private var reloadOnNextLogin = false
    /// Conversations whose read could not reach the server while offline.
    private var readWhileOffline: [String: (id: String, type: CometChat.ReceiverType)] = [:]

    /// Sends whose caller has not been answered yet. A session end or a cache reset answers each one
    /// once, quietly (`OfflineSend.discardedCode`), so a send that is only queued is never left
    /// without an answer for good. Never rejected while the session is alive.
    private var openSends: [ObjectIdentifier: OpenSend] = [:]

    private struct WeakObserver { weak var value: OfflineHubObserver? }
    private var observers: [String: WeakObserver] = [:]
    private var observerOrder: [String] = []
    /// Notices no screen could show yet: an announcement at launch comes before the first screen.
    /// Bounded; kept until a screen mounts or the session ends.
    private var heldNotices: [OfflineNotice] = []
    private static let maxHeldNotices = 20
    /// Moves when a session ends: a notice queued before it never reaches the next session. A cache
    /// reset moves `gen` but is the same session, so a notice raised just before one still shows.
    private var noticeSession = 0

    internal init(sdk: OfflineSDK = LiveOfflineSDK.shared) {
        self.sdk = sdk
        super.init()
    }

    internal var gen: Int { lock.lock(); defer { lock.unlock() }; return genValue }
    internal var isStarted: Bool { lock.lock(); defer { lock.unlock() }; return started }

    // MARK: Start

    /// Register the SDK listeners. Safe from every init entry point and more than once: only the
    /// first call registers. Not gated on the offline switch.
    internal func start() {
        lock.lock()
        if started { lock.unlock(); return }
        started = true
        lock.unlock()

        sdk.addOutboxListener(ListenerID.outbox, self)
        sdk.addSyncListener(ListenerID.sync, self)
        sdk.addOfflineCacheResetListener(ListenerID.cacheReset, self)
        sdk.addMediaDownloadListener(ListenerID.media, self)
        sdk.addMessageListener(ListenerID.messagesSynced, self)
        sdk.addLoginListener(ListenerID.login, self)
        if let uid = CometChat.getLoggedInUser()?.uid {
            lock.lock(); sessionUid = uid; lock.unlock()
        }
    }

    // MARK: Observers

    internal func addObserver(_ id: String, _ observer: OfflineHubObserver) {
        lock.lock(); defer { lock.unlock() }
        if observers[id] == nil { observerOrder.append(id) }
        observers[id] = WeakObserver(value: observer)
        if !heldNotices.isEmpty {
            deliver { [weak self] in self?.showHeldNotices() }
        }
    }

    internal func removeObserver(_ id: String) {
        lock.lock(); defer { lock.unlock() }
        observers.removeValue(forKey: id)
        observerOrder.removeAll { $0 == id }
    }

    private func currentObservers() -> [OfflineHubObserver] {
        lock.lock(); defer { lock.unlock() }
        return observerOrder.compactMap { observers[$0]?.value }
    }

    /// Enqueue a fan-out. Called with the lock held so the queue order equals the decision order.
    private func fanOut(_ body: @escaping ([OfflineHubObserver]) -> Void) {
        deliver { [weak self] in
            guard let self = self else { return }
            body(self.currentObservers())
        }
    }

    // MARK: Session

    /// Record who is signed in; a different uid ends the previous session first.
    internal func sessionStarted(uid: String?) {
        lock.lock()
        let changed = sessionUid != nil && uid != sessionUid
        if changed { endSessionLocked(rejectingOpenSends: true) }
        sessionUid = uid
        lock.unlock()
    }

    /// Logout, user switch or cache reset: forget every per-session mark and bump `gen`.
    ///
    /// `rejectingOpenSends`: a logout or a user switch ends every send still waiting for an answer.
    /// A login clears the same state but ends nothing that is waiting (the same user signing in again
    /// keeps its queued sends).
    internal func endSession(rejectingOpenSends: Bool = true) {
        lock.lock()
        endSessionLocked(rejectingOpenSends: rejectingOpenSends)
        sessionUid = nil
        lock.unlock()
    }

    private func endSessionLocked(rejectingOpenSends: Bool) {
        lastState.removeAll()
        lastStateOrder.removeAll()
        trackedMuids.removeAll()
        localIdByMuid.removeAll()
        directFailures.removeAll()
        directFailureOrder.removeAll()
        failureReasons.removeAll()
        retriesInFlight.removeAll()
        readWhileOffline.removeAll()
        heldNotices.removeAll()
        noticeSession += 1
        genValue += 1
        let gen = genValue
        if rejectingOpenSends { rejectOpenSendsLocked(onlyThoseQueued: false, text: OfflineSend.sessionEndedText) }
        guard offlineUsedThisSession else { return }
        offlineUsedThisSession = false
        reloadOnNextLogin = true
        fanOut { observers in observers.forEach { $0.offlineSessionChanged(gen: gen) } }
    }

    // MARK: Open sends

    /// One send whose caller is still waiting for an answer.
    internal final class OpenSend {
        let gen: Int
        /// The SDK answered with its pending callback: the message is in the outbox store.
        var pendingSeen = false
        /// Answers the caller once, quietly. Set by the send helper.
        var reject: ((_ text: String) -> Void)?
        init(gen: Int) { self.gen = gen }
    }

    /// Start waiting on a send. Call `closeOpenSend` when the caller has its final answer.
    internal func openSend() -> OpenSend {
        lock.lock(); defer { lock.unlock() }
        let open = OpenSend(gen: genValue)
        openSends[ObjectIdentifier(open)] = open
        return open
    }

    internal func closeOpenSend(_ open: OpenSend) {
        lock.lock(); defer { lock.unlock() }
        openSends.removeValue(forKey: ObjectIdentifier(open))
    }

    internal var openSendCount: Int {
        lock.lock(); defer { lock.unlock() }
        return openSends.count
    }

    /// Take the open sends (those whose pending was seen, for a cache reset) out of the registry and
    /// answer each once. The lock is held by the caller; the answers go out on the UI queue.
    private func rejectOpenSendsLocked(onlyThoseQueued: Bool, text: String) {
        let taken = openSends.filter { !onlyThoseQueued || $0.value.pendingSeen }
        guard !taken.isEmpty else { return }
        taken.keys.forEach { openSends.removeValue(forKey: $0) }
        let rejects = taken.values.compactMap { $0.reject }
        deliver { rejects.forEach { $0(text) } }
    }

    /// Called by `OfflineGate` when an operation takes the offline path (see `offlineUsedThisSession`).
    internal func noteOfflineUsed() {
        lock.lock(); defer { lock.unlock() }
        offlineUsedThisSession = true
    }

    // MARK: Send tracking

    /// Mark an own send as routed through the ON-path helper. The dedupe below is consulted only
    /// for tracked sends, so an OFF send (no local id, never tracked) bypasses it entirely.
    internal func track(_ message: BaseMessage) {
        guard let muid = MessageIdentity.muid(message) else { return }
        lock.lock(); defer { lock.unlock() }
        trackedMuids.insert(muid)
        if trackedMuids.count > Self.maxTrackedSends * 2 {
            trackedMuids.removeAll()
            trackedMuids.insert(muid)
        }
    }

    /// `true` when `message` was routed through the ON-path send helper this session.
    internal func isTracked(_ message: BaseMessage) -> Bool {
        guard let muid = MessageIdentity.muid(message) else { return false }
        lock.lock(); defer { lock.unlock() }
        return trackedMuids.contains(muid)
    }

    /// The key transitions are deduped under: the local id once the SDK stamped one, bridged from
    /// the muid so the composer's optimistic object and the SDK's pending object share a key.
    private func canonicalKeyLocked(_ message: BaseMessage) -> String? {
        let muid = MessageIdentity.muid(message)
        if let local = MessageIdentity.localId(message) {
            if let muid = muid, trackedMuids.contains(muid) { localIdByMuid[muid] = local }
            return "l:\(local)"
        }
        if let muid = muid, trackedMuids.contains(muid) {
            if let local = localIdByMuid[muid] { return "l:\(local)" }
            return "m:\(muid)"
        }
        return nil
    }

    /// Forward-only transitions: `failed -> sending` is a retry; anything may become `sent`.
    internal static func isForward(from: CometChatMessageSendState?, to: CometChatMessageSendState) -> Bool {
        guard let from = from else { return true }
        if from == to { return false }
        if to == .sent { return from != .discarded }
        if from == .sent || from == .discarded { return false }
        if from == .failed { return to == .sending || to == .discarded }
        return true
    }

    internal func stateOf(_ message: BaseMessage) -> CometChatMessageSendState? {
        lock.lock(); defer { lock.unlock() }
        guard let key = canonicalKeyLocked(message) else { return nil }
        return lastState[key]
    }

    private func record(_ key: String, _ state: CometChatMessageSendState) {
        lastState.removeValue(forKey: key)
        lastStateOrder.removeAll { $0 == key }
        lastState[key] = state
        lastStateOrder.append(key)
        if lastStateOrder.count > Self.maxTrackedSends, let oldest = lastStateOrder.first {
            lastStateOrder.removeFirst()
            lastState.removeValue(forKey: oldest)
        }
    }

    /// Consulted by the public `ccMessageSent` dispatcher: `false` when this transition of a tracked
    /// ON-path send was already emitted (by the hub or by an earlier call), so the composer's own
    /// success/error emission never doubles the hub's.
    internal func admitPublicSent(_ message: BaseMessage, status: MessageStatus) -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard let key = canonicalKeyLocked(message) else { return true }
        let state: CometChatMessageSendState = status == .success ? .sent : (status == .inProgress ? .sending : .failed)
        guard Self.isForward(from: lastState[key], to: state) else { return false }
        record(key, state)
        return true
    }

    // MARK: Direct failures

    internal func markDirectFailed(_ message: BaseMessage, reason: CometChat.MessageFailureReason?) {
        guard let muid = MessageIdentity.muid(message) else { return }
        lock.lock(); defer { lock.unlock() }
        if directFailures.insert(muid).inserted { directFailureOrder.append(muid) }
        if directFailureOrder.count > Self.maxTrackedSends, let oldest = directFailureOrder.first {
            directFailureOrder.removeFirst()
            directFailures.remove(oldest)
        }
    }

    /// The kill switch (UIK-LIFE-03): offline was turned off while own sends were queued, and the SDK
    /// dropped its queue without a callback. Every message here that went out on the offline path
    /// (it has a local id), has no server id and is not already failed turns failed (direct), with
    /// the hub's state moved to failed so a Retry's `sending` is a forward transition. Returns the
    /// messages that were turned, so the caller can show one notice for them.
    @discardableResult
    internal func failStranded(_ messages: [BaseMessage]) -> [BaseMessage] {
        let stranded = messages.filter {
            MessageIdentity.serverId($0) == 0 && MessageIdentity.localId($0) != nil && !isDirectFailed($0)
        }
        for message in stranded {
            if !reportSendState(message, .failed, reason: nil, direct: true) {
                markDirectFailed(message, reason: nil)
            }
        }
        return stranded
    }

    internal func clearDirectFailed(_ message: BaseMessage) {
        guard let muid = MessageIdentity.muid(message) else { return }
        lock.lock(); defer { lock.unlock() }
        directFailures.remove(muid)
        directFailureOrder.removeAll { $0 == muid }
    }

    /// `true` when `message` failed direct this session (not in the outbox).
    internal func isDirectFailed(_ message: BaseMessage) -> Bool {
        guard let muid = MessageIdentity.muid(message) else { return false }
        lock.lock(); defer { lock.unlock() }
        return directFailures.contains(muid)
    }

    // MARK: Reporting a send transition

    /// Report one transition of an own message's send. Both the per-send listener and the outbox
    /// listener funnel through here. `announced` marks a `sending` the call site already announced
    /// publicly (the composer emits `inProgress` at compose time), so it is not announced twice.
    /// Returns whether the transition was accepted (it was not a repeat).
    @discardableResult
    internal func reportSendState(_ message: BaseMessage,
                                  _ state: CometChatMessageSendState,
                                  reason: CometChat.MessageFailureReason? = nil,
                                  direct: Bool = false,
                                  announced: Bool = false) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        if state == .failed && direct { markDirectFailedLocked(message, reason: reason) }
        else if state != .failed { clearDirectFailedLocked(message) }

        let key = canonicalKeyLocked(message)
        let local = MessageIdentity.localId(message)
        let gen = genValue

        guard let key = key else {
            // Nothing to dedupe on; a direct failure of a message the SDK never queued still has to
            // reach the screen.
            guard state == .failed else { return false }
            fanOut { observers in
                observers.forEach { $0.offlineSendState(OfflineSendStateEvent(gen: gen, localMessageId: local, message: message, state: state, reason: reason, direct: true)) }
            }
            emitPublic(message, state, reason)
            return true
        }

        let previous = lastState[key]
        guard Self.isForward(from: previous, to: state) else {
            if previous == .discarded, state == .sent, MessageIdentity.serverId(message) > 0 {
                // The user removed it after the SDK answered NOT_FOUND, and it went out after all
                // (ENG-57447). It stays off screen; a list whose Delete asked for it deletes it.
                let event = OfflineSendStateEvent(gen: gen, localMessageId: local, message: message, state: .sent, reason: nil, direct: false)
                fanOut { observers in observers.forEach { $0.offlineSentAfterDiscard(event) } }
            }
            return false
        }
        record(key, state)
        if state == .failed, let reason = reason { failureReasons[key] = reason } else if state != .failed { failureReasons.removeValue(forKey: key) }
        if state != .sending { retriesInFlight.remove(key) }
        let event = OfflineSendStateEvent(gen: gen, localMessageId: local, message: message, state: state, reason: reason, direct: direct)
        fanOut { observers in observers.forEach { $0.offlineSendState(event) } }
        if state == .sending && announced {
            emitStateChanged(message, state, reason)
        } else {
            emitPublic(message, state, reason)
        }
        return true
    }

    /// The SDK removed an unsent message (`QUEUE_OVERFLOW` under DROP_OLDEST, or `DISCARDED`): the
    /// row goes and the "removed" notice shows. The send's own error and the outbox event both
    /// report it; whichever comes first wins, the other is not a forward transition.
    @discardableResult
    internal func reportSDKRemoval(_ message: BaseMessage, reason: CometChat.MessageFailureReason) -> Bool {
        guard reportSendState(message, .discarded, reason: reason) else { return false }
        notify(OfflineNotice(gen: gen, kind: .unsentMessageRemoved, count: 1, message: message))
        return true
    }

    /// The user deleted an unsent row (`discardLocalMessage` succeeded, or a direct failure was
    /// dismissed). The SDK fires no outbox event for it, so the hub tells the mounted lists to drop
    /// the row and integrators get one `ccMessageSendStateChanged(.discarded)`. No `ccMessageSent`
    /// error is emitted: the user removed it, nothing failed.
    internal func reportUserDiscard(_ message: BaseMessage) {
        lock.lock()
        defer { lock.unlock() }
        let gen = genValue
        let local = MessageIdentity.localId(message)
        if let key = canonicalKeyLocked(message) {
            guard Self.isForward(from: lastState[key], to: .discarded) else { return }
            record(key, .discarded)
            failureReasons.removeValue(forKey: key)
            retriesInFlight.remove(key)
        }
        let event = OfflineSendStateEvent(gen: gen, localMessageId: local, message: message, state: .discarded, reason: nil, direct: false)
        fanOut { observers in observers.forEach { $0.offlineSendState(event) } }
        emitStateChanged(message, .discarded, nil)
    }

    private func markDirectFailedLocked(_ message: BaseMessage, reason: CometChat.MessageFailureReason?) {
        markDirectFailed(message, reason: reason)
    }

    private func clearDirectFailedLocked(_ message: BaseMessage) {
        clearDirectFailed(message)
    }

    private func emitPublic(_ message: BaseMessage, _ state: CometChatMessageSendState, _ reason: CometChat.MessageFailureReason?) {
        let status: MessageStatus
        switch state {
        case .sent: status = .success
        case .sending: status = .inProgress
        case .failed: status = .error
        case .discarded:
            // The SDK removed the message (DROP_OLDEST overflow, a purge): a removal, not a send
            // error. As for a user discard, only `ccMessageSendStateChanged(.discarded)`.
            emitStateChanged(message, state, reason)
            return
        }
        let events = publicEvents
        deliver { events.messageSent(message, status) }
        emitStateChanged(message, state, reason)
    }

    private func emitStateChanged(_ message: BaseMessage, _ state: CometChatMessageSendState, _ reason: CometChat.MessageFailureReason?) {
        let events = publicEvents
        deliver { events.sendStateChanged(message, state, reason) }
    }

    // MARK: Failure reason and retry guard

    /// Why `message` failed: the SDK's `failureReason` on the object, else the reason the outbox
    /// reported for it this session, else `nil` (unknown: treated as TRANSIENT, R95).
    internal func failureReason(of message: BaseMessage) -> CometChat.MessageFailureReason? {
        if let reason = MessageIdentity.failureReasonProvider(message) { return reason }
        lock.lock(); defer { lock.unlock() }
        guard let key = canonicalKeyLocked(message) else { return nil }
        return failureReasons[key]
    }

    /// Claim the one user Retry allowed in flight for `message`. `false` while another is running.
    internal func beginRetry(_ message: BaseMessage) -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard let key = canonicalKeyLocked(message) ?? MessageIdentity.localId(message).map({ "l:\($0)" }) else { return true }
        return retriesInFlight.insert(key).inserted
    }

    /// The Retry of `message` answered (accepted, sent, failed or rejected).
    internal func endRetry(_ message: BaseMessage) {
        lock.lock(); defer { lock.unlock() }
        if let key = canonicalKeyLocked(message) ?? MessageIdentity.localId(message).map({ "l:\($0)" }) {
            retriesInFlight.remove(key)
        }
    }

    internal func isRetryInFlight(_ message: BaseMessage) -> Bool {
        lock.lock(); defer { lock.unlock() }
        guard let key = canonicalKeyLocked(message) ?? MessageIdentity.localId(message).map({ "l:\($0)" }) else { return false }
        return retriesInFlight.contains(key)
    }

    // MARK: Reads made offline (AC-7.4)

    internal func rememberReadWhileOffline(id: String, type: CometChat.ReceiverType) {
        guard !id.isEmpty else { return }
        lock.lock(); defer { lock.unlock() }
        readWhileOffline["\(type.rawValue):\(id)"] = (id, type)
    }

    private func flushReadsMadeOffline() {
        lock.lock()
        let pending = Array(readWhileOffline.values)
        readWhileOffline.removeAll()
        lock.unlock()
        for entry in pending {
            sdk.markConversationAsRead(conversationWithId: entry.id, receiverType: entry.type, onSuccess: {}) { [weak self] in
                self?.rememberReadWhileOffline(id: entry.id, type: entry.type)
            }
        }
    }
}

// MARK: - Public event seam

/// What integrators see. A seam so tests can assert "exactly one public event per transition".
internal protocol OfflinePublicEvents {
    func messageSent(_ message: BaseMessage, _ status: MessageStatus)
    func sendStateChanged(_ message: BaseMessage, _ state: CometChatMessageSendState, _ reason: CometChat.MessageFailureReason?)
    func cacheReset(_ reason: CometChat.OfflineCacheResetReason, _ pendingMessagesLost: Int)
}

internal struct LiveOfflinePublicEvents: OfflinePublicEvents {
    func messageSent(_ message: BaseMessage, _ status: MessageStatus) {
        CometChatMessageEvents.dispatchMessageSent(message: message, status: status)
    }
    func sendStateChanged(_ message: BaseMessage, _ state: CometChatMessageSendState, _ reason: CometChat.MessageFailureReason?) {
        CometChatMessageEvents.ccMessageSendStateChanged(message: message, state: state, reason: reason)
    }
    func cacheReset(_ reason: CometChat.OfflineCacheResetReason, _ pendingMessagesLost: Int) {
        CometChatMessageEvents.ccOfflineCacheReset(reason: reason, pendingMessagesLost: pendingMessagesLost)
    }
}

// MARK: - SDK listeners

extension OfflineHub: OutboxListener {

    func onOutboxMessagePending(_ message: BaseMessage) {
        // A retry turns a failed row back into a sending one and is announced; a fresh send was
        // already announced by its call site.
        let wasFailed = stateOf(message) == .failed
        reportSendState(message, .sending, announced: !wasFailed)
    }

    func onOutboxMessageSent(_ message: BaseMessage) {
        reportSendState(message, .sent)
    }

    func onOutboxMessageFailed(_ message: BaseMessage, _ reason: CometChat.MessageFailureReason) {
        switch reason {
        case .discarded, .queueOverflow:
            // The row goes; no retry is offered (R14, R49).
            reportSDKRemoval(message, reason: reason)
        case .queueFull, .byteOverflow:
            // iOS fires pending BEFORE the refusal (SDK ask A7): treat it as failed (direct) whatever
            // came before. Retry is a fresh send.
            if reportSendState(message, .failed, reason: reason, direct: true) {
                notify(OfflineNotice(gen: gen, kind: reason == .queueFull ? .queueFull : .fileTooLargeOffline, count: 1, message: message))
            }
        case .transient, .permanent:
            reportSendState(message, .failed, reason: reason)
        @unknown default:
            reportSendState(message, .failed, reason: reason)
        }
    }

    /// Show a notice on the screens that are there: first those it belongs to, then any. With no
    /// screen yet it waits for the first one.
    internal func notify(_ notice: OfflineNotice) {
        lock.lock(); defer { lock.unlock() }
        let session = noticeSession
        deliver { [weak self] in
            guard let self = self else { return }
            self.lock.lock()
            let current = session == self.noticeSession
            let gen = self.genValue
            self.lock.unlock()
            guard current else { return }
            var fresh = notice
            fresh = OfflineNotice(gen: gen, kind: notice.kind, count: notice.count, message: notice.message)
            let screens = self.currentObservers()
            if Self.show(fresh, on: screens) { return }
            fresh.forAnyScreen = true
            if Self.show(fresh, on: screens) { return }
            self.lock.lock(); defer { self.lock.unlock() }
            guard self.heldNotices.count < Self.maxHeldNotices else { return }
            self.heldNotices.append(fresh)
        }
    }

    private static func show(_ notice: OfflineNotice, on screens: [OfflineHubObserver]) -> Bool {
        // Every screen is asked: the one on top shows it, whichever that is.
        return screens.map { $0.offlineNotice(notice) }.contains(true)
    }

    private func showHeldNotices() {
        lock.lock()
        let held = heldNotices
        heldNotices.removeAll()
        let gen = genValue
        lock.unlock()
        let screens = currentObservers()
        for var notice in held {
            notice = OfflineNotice(gen: gen, kind: notice.kind, count: notice.count, message: notice.message, forAnyScreen: true)
            if !Self.show(notice, on: screens) {
                lock.lock(); heldNotices.append(notice); lock.unlock()
            }
        }
    }
}

extension OfflineHub: SyncListener {

    func onConversationSyncCompleted(_ conversations: [Conversation]) {
        lock.lock(); defer { lock.unlock() }
        let event = OfflineConversationSyncEvent(gen: genValue, conversations: conversations)
        fanOut { observers in observers.forEach { $0.offlineConversationSyncCompleted(event) } }
    }

    func onConversationSyncError(_ error: CometChatException) {
        lock.lock(); defer { lock.unlock() }
        let event = OfflineSyncFailedEvent(gen: genValue, phase: .conversation)
        fanOut { observers in observers.forEach { $0.offlineSyncFailed(event) } }
    }

    func onMessageSyncCompleted(_ messages: [BaseMessage], _ outcome: CometChat.SyncOutcome) {
        lock.lock()
        let event = OfflineMessageSyncEvent(gen: genValue, messages: messages, outcome: outcome)
        fanOut { observers in observers.forEach { $0.offlineMessageSyncCompleted(event) } }
        lock.unlock()
        flushReadsMadeOffline()
    }

    func onMessageSyncError(_ error: CometChatException) {
        lock.lock(); defer { lock.unlock() }
        let event = OfflineSyncFailedEvent(gen: genValue, phase: .message)
        fanOut { observers in observers.forEach { $0.offlineSyncFailed(event) } }
    }
}

extension OfflineHub: OfflineCacheResetListener {

    func onOfflineCacheReset(_ reason: CometChat.OfflineCacheResetReason, _ pendingMessagesLost: Int) {
        lock.lock()
        defer { lock.unlock() }
        // Everything on screen came from the old cache: every list reloads.
        lastState.removeAll()
        lastStateOrder.removeAll()
        directFailures.removeAll()
        directFailureOrder.removeAll()
        failureReasons.removeAll()
        retriesInFlight.removeAll()
        genValue += 1
        let gen = genValue
        // A reset rebuilds the store without its unsent messages. A readable one already answered each
        // through the SDK's per-call `onError` (DISCARDED); a wipe says nothing per call, so every send
        // whose queued copy was in the dropped store is answered now. A send the SDK never queued is a
        // direct send on the wire, which still answers itself.
        rejectOpenSendsLocked(onlyThoseQueued: true, text: OfflineSend.cacheResetText)
        fanOut { observers in observers.forEach { $0.offlineSessionChanged(gen: gen) } }
        let event = OfflineCacheResetEvent(gen: gen, reason: reason, pendingMessagesLost: pendingMessagesLost)
        fanOut { observers in observers.forEach { $0.offlineCacheReset(event) } }
        let events = publicEvents
        deliver { events.cacheReset(reason, pendingMessagesLost) }

        // ENCRYPTION_CHANGED already reported each lost send as DISCARDED (BEH-ENC-16): no extra notice.
        guard reason != .encryptionChanged else { return }
        if pendingMessagesLost > 0 {
            notify(OfflineNotice(gen: gen, kind: .unsentMessagesLost, count: pendingMessagesLost))
        } else if pendingMessagesLost < 0 {
            notify(OfflineNotice(gen: gen, kind: .unsentMessagesMaybeLost))
        }
    }
}

extension OfflineHub: MediaDownloadListener {

    func onMediaDownloaded(_ messageId: String, _ url: String, _ localPath: String) {
        lock.lock(); defer { lock.unlock() }
        let event = OfflineMediaReadyEvent(gen: genValue, messageId: messageId, url: url, localPath: localPath)
        fanOut { observers in observers.forEach { $0.offlineMediaReady(event) } }
    }

    /// A download the user asked for (`OfflineMediaDownload`) finished.
    func mediaDownloaded(url: String, localPath: String) {
        onMediaDownloaded("", url, localPath)
    }
}

extension OfflineHub: CometChatMessageDelegate {

    /// A sweep delivers already-cached message changes here: lists update rows they show, never insert.
    func onMessagesSynced(_ messages: [BaseMessage]) {
        lock.lock(); defer { lock.unlock() }
        let event = OfflineMessagesUpdatedEvent(gen: genValue, messages: messages)
        fanOut { observers in observers.forEach { $0.offlineMessagesUpdated(event) } }
    }
}

extension OfflineHub: CometChatSDK.CometChatLoginDelegate {

    func onLoginSuccess(user: User) {
        sessionStarted(uid: user.uid)
        // Offline is already on by the time login observers run (SDK contract). Read once here.
        let offlineNow = OfflineGate.isOn()
        lock.lock(); defer { lock.unlock() }
        // With offline off and no offline session before it, a login changes nothing on screen (P1).
        guard reloadOnNextLogin || offlineNow else { return }
        reloadOnNextLogin = false
        let gen = genValue
        fanOut { observers in observers.forEach { $0.offlineSessionStarted(gen: gen) } }
    }

    func onLogoutSuccess() {
        endSession()
    }
}
