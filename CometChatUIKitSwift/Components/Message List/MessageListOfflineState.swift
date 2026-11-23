//
//  MessageListOfflineState.swift
//  CometChatUIKitSwift
//
//  What one message list remembers for the offline (ON) path. Everything here describes what is on
//  screen; the Chat SDK owns the offline state itself. Cleared on a session change.
//

import Foundation
import CometChatSDK

final class MessageListOfflineState {

    /// The hub `gen` this list's rows belong to. A hub event or read callback from an older `gen`
    /// (logout, user switch, cache reset) is dropped.
    var gen = 0

    /// The kinds of read a list runs. Each has its own token, so one kind superseding another can
    /// never strand the other's busy flag (P6).
    enum ReadKind: Int, CaseIterable {
        /// Older page (`fetchPreviousMessages`): its busy flag is `isUIUpdating`.
        case older
        /// Newer page for pagination: its busy flag is `isFetchingNext`.
        case newer
        /// Newest-window refresh after a partial/failed sync: no busy flag.
        case window
    }

    private var tokens: [ReadKind: Int] = [:]

    /// The message id the list's request builder was configured with (the integrator's anchor, or
    /// `-1` for the latest). The shared builder is re-anchored in place by pagination and jumps;
    /// "the newest window" is read from this anchor, not from wherever the builder was left.
    var baseAnchorMessageId = 0

    /// `localMessageId -> server id`, filled when an ack replaces a pending row.
    var aliases = MessageAliasMap()

    /// Receipts for server ids not shown yet (their ack has not landed).
    var heldReceipts = HeldReceipts()

    /// The last offline read ended with the not-connected error over cached rows.
    var needsConnectToLoadMore = false
    /// Why the offline state or error view is showing over nothing: a first read that failed with no row
    /// on screen. The connection coming back reads once more when it is `notConnected`. Cleared when a
    /// read starts.
    var listError: OfflineListError = .none
    /// D84 rule 3: the first read failed for want of a connection and nothing is on screen: the screen
    /// says "Connect to load messages" (the app's error view, if it set one).
    var connectToLoad: Bool { return listError == .notConnected }
    /// D84 rule 9: the reconnect asked the newer edge to load its page by itself; it waits for the older
    /// edge's read to settle. A tap on the edge's row, or a new window, takes the request back.
    var pendingNewerEdgeLoad = false
    /// Moves when the window on screen is replaced (a jump, a session change). A load that waited for a
    /// read to settle only goes on if the window is still the one it was asked for.
    private(set) var windowEpoch = 0
    /// The last newer-page read ended with the not-connected error: a scroll towards the newest rows
    /// does not read again until the connection is back (each read was refused, with a toast).
    var newerReadsWaitForConnection = false

    /// The newest page of a window refresh that did not overlap the rows shown: held until the user
    /// taps "jump to latest".
    var pendingLatestWindow: [BaseMessage]?

    /// Local ids the user deleted while their send was already on its way (`discardLocalMessage`
    /// answered NOT_FOUND before the ack reached the list): once the sent copy lands, it is deleted
    /// on the server with today's delete, so the device and the server agree.
    var deleteWhenSent: Set<String> = []

    /// Own thread replies already added to their parent's reply count when they were queued
    /// (`m:<muid>` and `l:<local id>`), so the ack does not add them again.
    var countedReplies: Set<String> = []

    /// The session ended and rows were cleared; reload from the cache when the next session starts.
    var reloadWhenSessionStarts = false

    /// The pending check after a conversation-only sweep (`offlineConversationSyncCompleted`).
    var coldSweepCheck: DispatchWorkItem?
    static let coldSweepSettle: TimeInterval = 2

    /// A jump or start-from-unread window is being read and scrolled to. From the start of that read
    /// until the scroll to the anchor settles, the read fails or finds nothing to scroll to, or
    /// `positioningCap` passes: older and newer paging do not read, and a live message does not
    /// scroll the list to the bottom (the list would land at the newest message, not the anchor).
    /// Set only with offline on; with offline off an around read is untouched.
    private(set) var positioning = false
    private var positioningToken = 0
    static let positioningCap: TimeInterval = 6

    /// Start positioning. Returns the token the cap timer must present to end it.
    func beginPositioning() -> Int {
        positioning = true
        positioningToken += 1
        return positioningToken
    }

    /// End positioning. With a `token`, only the positioning that token began (a cap timer of an
    /// earlier jump must not end a later one). Returns whether positioning ended now.
    @discardableResult
    func endPositioning(token: Int? = nil) -> Bool {
        if let token = token, token != positioningToken { return false }
        guard positioning else { return false }
        positioning = false
        positioningToken += 1
        return true
    }

    /// The window on screen is anchored on an older message (a jump or start-from-unread) and does not
    /// end at the chat's newest message: its newest row is not the chat's. A sweep then updates the
    /// rows shown and inserts nothing, because a newer message put past the window's end would leave
    /// a hole that "load newer" (it anchors on the newest row shown) skips.
    var anchoredWindow = false

    /// Start a read of `kind`; any earlier read of the same kind becomes stale.
    func beginRead(_ kind: ReadKind) -> Int {
        let next = (tokens[kind] ?? 0) + 1
        tokens[kind] = next
        return next
    }

    func isCurrent(_ kind: ReadKind, token: Int, hubGen: Int) -> Bool {
        return token == (tokens[kind] ?? 0) && hubGen == gen
    }

    /// Whether a callback that found itself stale must still clear its busy flag. A read replaced
    /// by a newer read of its own kind leaves the flag to that read; a read orphaned by a session
    /// change has no successor, so it clears the flag itself.
    func staleReadMustReleaseFlag(_ kind: ReadKind, token: Int, hubGen: Int) -> Bool {
        return token != (tokens[kind] ?? 0) ? hubGen != gen : true
    }

    /// A request for the list's newest window: the builder put back at its base anchor, so a
    /// forward page or a jump that moved it cannot skew the read (UIT-SYNC-04).
    func newestWindowRequest(from builder: MessagesRequest.MessageRequestBuilder) -> MessagesRequest {
        return builder.set(messageID: baseAnchorMessageId).build()
    }

    /// A jump replaces the window: reads made for the window being left no longer match any token.
    func supersedeReadsForJump() {
        for kind in ReadKind.allCases { tokens[kind] = (tokens[kind] ?? 0) + 1 }
        windowEpoch &+= 1
        pendingNewerEdgeLoad = false
    }

    func reset(toGen newGen: Int) {
        gen = newGen
        for kind in ReadKind.allCases { tokens[kind] = (tokens[kind] ?? 0) + 1 }
        aliases.removeAll()
        heldReceipts.removeAll()
        needsConnectToLoadMore = false
        listError = .none
        newerReadsWaitForConnection = false
        pendingNewerEdgeLoad = false
        windowEpoch &+= 1
        pendingLatestWindow = nil
        deleteWhenSent.removeAll()
        countedReplies.removeAll()
        anchoredWindow = false
    }
}

/// One read of a jump or unread-anchor window (README 3.9): an older and a newer read, each answering
/// with a cached page and then a server page or an error. Decides what the list does next, once per
/// answer. Holds no UI and no SDK.
struct OfflineJumpRead {

    enum Side { case older, newer }

    enum Step {
        case wait
        /// First paint from the device; the server's pages are still to come.
        case paintCached(older: [BaseMessage], newer: [BaseMessage])
        /// Both sides ended and nothing has been painted yet.
        case paintFinal(older: [BaseMessage], newer: [BaseMessage])
        /// Both sides ended over a cached paint.
        case replaceCached
        case fail(CometChatException)
        case done
    }

    var cachedOlder: [BaseMessage]?
    var cachedNewer: [BaseMessage]?
    var serverOlder: [BaseMessage]?
    var serverNewer: [BaseMessage]?

    private var olderEnded = false
    private var newerEnded = false
    private var painted = false
    private var finished = false
    /// The first failure that is not "not connected": nothing to fall back on makes it the answer.
    private var failure: CometChatException?

    mutating func failed(_ side: Side, error: CometChatException?, notConnected: Bool) {
        switch side {
        case .older: olderEnded = true
        case .newer: newerEnded = true
        }
        if !notConnected, failure == nil { failure = error }
    }

    mutating func nextStep() -> Step {
        if finished { return .done }
        let older = serverOlder ?? cachedOlder ?? []
        let newer = serverNewer ?? cachedNewer ?? []
        if (olderEnded || serverOlder != nil) && (newerEnded || serverNewer != nil) {
            finished = true
            if painted { return .replaceCached }
            if let failure = failure, older.isEmpty && newer.isEmpty { return .fail(failure) }
            painted = true
            return .paintFinal(older: older, newer: newer)
        }
        if !painted, let cachedOlder = cachedOlder, let cachedNewer = cachedNewer, !(cachedOlder.isEmpty && cachedNewer.isEmpty) {
            painted = true
            return .paintCached(older: cachedOlder, newer: cachedNewer)
        }
        return .wait
    }
}
