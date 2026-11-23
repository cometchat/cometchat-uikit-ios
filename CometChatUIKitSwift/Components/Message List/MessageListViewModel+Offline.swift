//
//  MessageListViewModel+Offline.swift
//  CometChatUIKitSwift
//
//  The offline (ON) path of the message list: two-phase reads with a windowed reconcile, sorted
//  upsert by identity, the hub's send, sync and session events, and the unsent-row actions.
//
//  Every method here is reached only after the caller read `OfflineGate.isOn()` for its operation,
//  or from a hub event (which the SDK fires only with offline on). With offline off none of this
//  runs and the list behaves exactly as before.
//

import Foundation
import CometChatSDK

extension MessageListViewModel {

    // MARK: - Belonging

    /// Whether `message` belongs to this list. User and group are told apart by receiver type, so a
    /// uid that equals a guid never cross-delivers.
    func offlineBelongsHere(_ message: BaseMessage) -> Bool {
        let me = CometChat.getLoggedInUser()?.uid
        switch message.receiverType {
        case .user:
            guard let user = user, let uid = user.uid else { return false }
            let other = message.senderUid == me ? message.receiverUid : message.senderUid
            guard other == uid else { return false }
        case .group:
            guard let group = group, message.receiverUid == group.guid else { return false }
        @unknown default:
            return false
        }
        return checkThreadedMessageBelongsToThisConversation(message: message)
    }

    // MARK: - Applying rows

    /// Interactive messages are converted to their typed form and AI tool messages are dropped,
    /// exactly as the OFF path does for a page.
    func offlinePrepare(_ page: [BaseMessage]) -> [BaseMessage] {
        let filtered = page.filter { message in
            let name = String(describing: type(of: message))
            return !(name.contains("AIToolArgumentMessage") || name.contains("AIToolResultMessage"))
        }
        var prepared: [BaseMessage] = []
        processMessageList(filtered) { prepared = $0 }
        return prepared
    }

    /// Apply the held receipt of every row that just acquired a server id.
    private func offlineApplyHeldReceipts(for ids: [Int]) {
        for id in ids {
            if let receipt = offline.heldReceipts.take(messageId: id) {
                update(receipt: receipt)
            }
        }
    }

    /// Upsert one message and tell the list what happened to its row. Main queue.
    func offlineUpsertOne(_ message: BaseMessage, insertIfMissing: Bool = true, isSync: Bool = false) {
        let before = MessageRows.locate(message, in: messages, aliases: offline.aliases)
        if before == nil && !insertIfMissing { return }
        let sectionCountBefore = messages.count
        if let before = before, messages[before.section].messages[before.row] === message {
            // The SDK changed the very object the row shows (the composer's message turning PENDING,
            // FAILED or SENDING again on a Retry): nothing moves, but the row must redraw its state.
            // If it just took its server id in place, a receipt held for that id belongs to it now.
            if message.id > 0 { offlineApplyHeldReceipts(for: [message.id]) }
            updateAtIndex?(before.section, before.row, message)
            return
        }
        let result = MessageRows.upsert([message], into: &messages, aliases: &offline.aliases, insertIfMissing: insertIfMissing)
        guard result.changed else { return }
        offlineApplyHeldReceipts(for: result.acquiredServerIds)

        guard let after = MessageRows.locate(message, in: messages, aliases: offline.aliases) else {
            reload?()
            return
        }
        if before == nil {
            if after.section == 0 && after.row == 0 && !isSync {
                appendAtIndex?(after.section, after.row, messages[after.section].messages[after.row], messages.count != sectionCountBefore)
            } else {
                reload?()
            }
        } else if let before = before, before.section == after.section, before.row == after.row {
            updateAtIndex?(after.section, after.row, messages[after.section].messages[after.row])
        } else {
            reload?()
        }
    }

    /// Upsert a page (cached, server, swept). Main queue.
    @discardableResult
    func offlineUpsertPage(_ page: [BaseMessage], insertIfMissing: Bool = true) -> Bool {
        guard !page.isEmpty else { return false }
        let result = MessageRows.upsert(page, into: &messages, aliases: &offline.aliases, insertIfMissing: insertIfMissing)
        offlineApplyHeldReceipts(for: result.acquiredServerIds)
        return result.changed
    }

    /// Replace-only update of a row already shown (an edit, a delete, an ack). Main queue.
    func offlineApplyUpdate(_ message: BaseMessage) {
        offlineUpsertOne(message, insertIfMissing: false)
    }

    /// Remove the row that is `message`. Main queue.
    @discardableResult
    func offlineRemoveRow(_ message: BaseMessage) -> Bool {
        guard let found = MessageRows.locate(message, in: messages, aliases: offline.aliases) else { return false }
        let removed = MessageRows.remove(at: found, from: &messages)
        if let deleteAtIndex = deleteAtIndex {
            deleteAtIndex(found.section, found.row, removed)
        }
        reload?()
        return true
    }

    // MARK: - Two-phase reads

    /// Offline at the end of the saved messages, with the "connect to load more" footer shown: a
    /// scroll does not read older messages again (each read is refused; five scroll-ups made fifteen).
    /// The footer's tap or the reconnect lifts it; once connected a scroll reads again.
    var offlineOlderReadsWaitForConnection: Bool {
        return offline.needsConnectToLoadMore && CometChat.getConnectionStatus != .connected
    }

    /// As `offlineOlderReadsWaitForConnection`, for the newer end: a refused newer-page read is not
    /// repeated on every scroll down (the reads after the footer were these, `affix=append`).
    var offlineNewerReadsWaitForConnection: Bool {
        return offline.newerReadsWaitForConnection && CometChat.getConnectionStatus != .connected
    }

    private func offlineIsNotConnected(_ error: CometChatException?) -> Bool {
        return OfflineErrors.isNotConnected(code: error?.errorCode)
    }

    /// Older page, offline ON: the on-device copy paints first, the server copy replaces the same
    /// slice in place. Never removes a row that has no server id. Callbacks of an older read or
    /// session are dropped.
    func offlineFetchPreviousMessages(request: MessagesRequest, completion: (() -> Void)?) {
        let hubGen = OfflineHub.shared.gen
        if offline.gen != hubGen { offline.reset(toGen: hubGen) }
        let token = offline.beginRead(.older)
        let isInitialRead = messages.isEmpty
        offline.listError = .none
        var cachedKeys = Set<Int>()
        var rawCachedKeys = Set<Int>()
        var paintedKeys = Set<Int>()
        var cachedPainted = false

        service.fetchPreviousMessagesTwoPhase(request: request, onCached: { [weak self] rows in
            guard let this = self else { return }
            guard this.offline.isCurrent(.older, token: token, hubGen: hubGen) else {
                if this.offline.staleReadMustReleaseFlag(.older, token: token, hubGen: hubGen) { this.isUIUpdating = false }
                return
            }
            let page = this.offlinePrepare(rows)
            cachedKeys = MessageRows.cachedKeys(of: page)
            rawCachedKeys = MessageRows.cachedKeys(of: rows)
            paintedKeys = cachedKeys.subtracting(MessageRows.cachedKeys(of: this.messages.flatMap { $0.messages }))
            let changed = this.offlineUpsertPage(page)
            cachedPainted = !page.isEmpty
            // An empty cached page paints nothing: the loader stays until the server answers.
            if changed || cachedPainted { this.reload?() }
        }, onServer: { [weak self] rows in
            guard let this = self else { return }
            guard this.offline.isCurrent(.older, token: token, hubGen: hubGen) else {
                if this.offline.staleReadMustReleaseFlag(.older, token: token, hubGen: hubGen) { this.isUIUpdating = false }
                return
            }
            this.isUIUpdating = false
            this.offline.needsConnectToLoadMore = false
            let page = this.offlinePrepare(rows)
            let result = MessageRows.reconcileServerPage(page, cachedKeys: cachedKeys, into: &this.messages, aliases: &this.offline.aliases)
            this.offlineApplyHeldReceipts(for: result.acquiredServerIds)
            // A stale cached page that does not join the server page is not kept (D13-R2).
            MessageRows.dropUnjoinedCachedPage(paintedKeys: paintedKeys, rawCachedKeys: rawCachedKeys, rawServerPage: rows, end: .older, from: &this.messages)
            // End of history only from an empty server page while online (BEH-READ-09b).
            if rows.isEmpty {
                this.isAllMessagesFetchedInPrevious = true
                this.appendMessagesAtTop?(0, 0)
            }
            this.reload?()
            if MessageRows.shouldMarkNewestRead(isInitialRead ? .initialRead : .olderPage, isAtBottom: this.offlineIsAtBottom?() ?? true) {
                this.offlineMarkNewestIncoming()
            }
            this.sendActiveChatChangeEvent()
            completion?()
        }, onError: { [weak self] error in
            guard let this = self else { return }
            guard this.offline.isCurrent(.older, token: token, hubGen: hubGen) else {
                if this.offline.staleReadMustReleaseFlag(.older, token: token, hubGen: hubGen) { this.isUIUpdating = false }
                return
            }
            this.isUIUpdating = false
            let hasRows = !this.messages.isEmpty
            if hasRows {
                // Saved messages stay and no error view covers them (BEH-READ-05, BEH-READ-06, D83).
                if this.offlineIsNotConnected(error) {
                    // Past the saved messages with no connection: "Connect to load more",
                    // whose tap reads again, and the reconnect reads that page once by itself (D84 rule 9).
                    this.offline.needsConnectToLoadMore = true
                    this.reload?()
                    this.onOfflineNotConnected?()
                } else {
                    CometChatLogger.error("message list read failed: \(error?.errorDescription ?? "")")
                }
                // The first read (opening the chat) is one the user or app started: an online failure is
                // reported once, a not-connected one is not (D84 rules 2 and 5). Paging older history is
                // not (the footer is its answer).
                let verdict = OfflineReadFailure.evaluate(error, rowsShown: true, keywordSearch: false, kitStarted: !isInitialRead)
                if verdict.reportsError, let error = error { this.onOfflineReadFailed?(error) }
            } else {
                // Nothing on screen: the offline state when not connected, the error view otherwise,
                // and `onError` once either way (D84 rules 3 and 4). A not-connected one reads once more
                // by itself when the connection returns.
                this.offline.listError = OfflineListError.afterFailure(error, rowsShown: false)
                if let error = error { this.failure?(error) }
            }
            completion?()
        })
    }

    /// The rows of an incoming page that are not shown yet. Rows already shown are matched once, by
    /// server id (`MessageRows.dropShown`): the newer copy wins, as in the Android kit.
    func offlineDropShownDuplicates(_ incoming: [BaseMessage]) -> [BaseMessage] {
        return MessageRows.dropShown(incoming, from: &messages).kept
    }

    // MARK: - Positioning (jump, start from unread)

    /// Whether a jump or start-from-unread window is being read and scrolled to. Paging and live
    /// auto-scroll wait while it is.
    var offlineIsPositioning: Bool { return offline.positioning }

    /// Start positioning (offline ON; the caller read the gate once for this jump). Capped at 6 s so
    /// a scroll that never settles cannot freeze paging for good.
    func offlineBeginPositioning() {
        let token = offline.beginPositioning()
        let cap = DispatchWorkItem { [weak self] in self?.offline.endPositioning(token: token) }
        offlineAfter(MessageListOfflineState.positioningCap, cap)
    }

    /// The list has scrolled to the anchor, or the read failed or found nothing to scroll to.
    func offlineEndPositioning() {
        offline.endPositioning()
    }

    // MARK: - Point lookups and jumps

    /// `getConversation`, offline ON: acts on the first answer (cached, else server); a later server
    /// answer refreshes `currentConversation` only.
    func offlineGetConversation(conversationWith: String, conversationType: CometChat.ConversationType,
                                completion: @escaping (Conversation?) -> Void) {
        var first = FirstAnswer()
        let bridge = ConversationDetailsBridge(onCached: { [weak self] conversation in
            self?.currentConversation = conversation
            if first.take() { completion(conversation) }
        }, onServer: { [weak self] conversation in
            if let conversation = conversation { self?.currentConversation = conversation }
            if first.take() { completion(conversation) }
        }, onError: { error in
            CometChatLogger.error("Error fetching conversation: \(error?.errorDescription ?? "")")
            if first.take() { completion(nil) }
        })
        // The SDK holds the listener until the read ends.
        CometChat.getConversation(conversationWith: conversationWith, conversationType: conversationType, listener: bridge)
    }

    /// `getMessageDetails`, offline ON: the first answer (cached, else server) starts the jump. A
    /// target that is not cached, with no server answer (offline, or not found), is not an error: the
    /// chat stays on its newest page (`offlineJumpUnavailable`).
    func offlineGoToMessage(messageId: Int) {
        // Anchor first (start from unread with offline on, and every jump): from here until the list has
        // scrolled to it, paging and live auto-scroll wait, so a page read or a live message cannot
        // carry the list to the newest message before it is positioned.
        offlineBeginPositioning()
        var first = FirstAnswer()
        let startJump: (BaseMessage?) -> Void = { [weak self] message in
            guard let this = self, first.take() else { return }
            guard let message = message else {
                // Nothing to anchor on: the newest page, no error, no scroll target.
                this.offlineJumpUnavailable()
                return
            }
            this.gotoMessage = message
            this.fetchSurroundingMessages(goToMessage: message)
        }
        let bridge = MessageDetailsBridge(onCached: { startJump($0) }, onServer: startJump, onError: { [weak self] error in
            guard let this = self, first.take() else { return }
            if this.offlineIsNotConnected(error) {
                // With no row on screen the newest page it reads now reports the failure (offline state
                // and `onError`); with rows on screen they stay and nothing is reported (D84 rule 2).
                this.offlineJumpUnavailable()
                return
            }
            this.offlineEndPositioning()
            this.offlineReportFailure(error)
        })
        // The SDK holds the listener until the read ends.
        offlineMessageDetails(messageId, bridge)
    }

    /// A read the user or app started (a jump) failed with an error other than not-connected. Nothing on
    /// screen: the error view and `onError`; rows on screen: they stay and only `onError` fires (D84).
    func offlineReportFailure(_ error: CometChatException?) {
        guard let error = error else { return }
        if messages.isEmpty {
            offline.listError = OfflineListError.afterFailure(error, rowsShown: false)
            failure?(error)
        } else {
            onOfflineReadFailed?(error)
        }
    }

    /// The connection is back (D84 rule 8). When the offline state is showing because the first read failed
    /// for want of a connection and nothing has arrived since, the newest page is read once more, two-phase.
    func offlineReloadAfterErrorOnConnect() {
        guard offline.listError == .notConnected, messages.isEmpty, !isUIUpdating,
              user != nil || group != nil || parentMessage != nil else { return }
        offline.listError = .none
        onOfflineReloadAfterError?()
        let request = offline.newestWindowRequest(from: messagesRequestBuilder)
        messagesRequest = request
        isAllMessagesFetchedInPrevious = false
        isUIUpdating = true
        hasFetchedMessagesBefore = true
        offlineFetchPreviousMessages(request: request, completion: nil)
    }

    /// The connection is back (D84 rule 9): the page that failed offline at a blocked "Connect to load
    /// more" edge loads once by itself. The older edge goes first; the newer edge waits for that read to
    /// settle, and only goes on if the window on screen is still the one it was asked for (a jump or a
    /// session change replaced it) and nobody tapped the edge meanwhile. With nothing on screen no page
    /// loads here: the empty list reads the newest page instead (`offlineReloadAfterErrorOnConnect`).
    func offlineLoadBlockedEdges(older: Bool, newer: Bool) {
        // The edge flags are only ever set on the offline path, so this does nothing with offline off.
        guard (older || newer), !messages.isEmpty, offline.gen == OfflineHub.shared.gen else { return }
        let epoch = offline.windowEpoch
        let loadNewer: () -> Void = { [weak self] in
            guard let this = self, newer, this.offline.pendingNewerEdgeLoad, this.offline.windowEpoch == epoch,
                  !this.isFetchingNext, !this.isAllMessagesFetchedInNext, !this.offline.positioning else { return }
            this.offline.pendingNewerEdgeLoad = false
            this.onOfflineLoadNewerEdge?()
        }
        if newer { offline.pendingNewerEdgeLoad = true }
        if older, !isUIUpdating, !isAllMessagesFetchedInPrevious, !offline.positioning {
            guard let load = onOfflineLoadOlderEdge else { loadNewer(); return }
            load { loadNewer() }
        } else {
            loadNewer()
        }
    }

    /// The jump target cannot be anchored (README 3.9): clear the jump, and when no rows are on screen
    /// read the newest page, two-phase and un-anchored, so the cache answers at once. Rows already on
    /// screen stay where they are. No error, no scroll target.
    func offlineJumpUnavailable() {
        offlineEndPositioning()
        gotoMessage = nil
        gotoMessageId = 0
        onOfflineJumpUnavailable?()
        guard messages.isEmpty else { return }
        let request = offline.newestWindowRequest(from: messagesRequestBuilder)
        messagesRequest = request
        isAllMessagesFetchedInPrevious = false
        isUIUpdating = true
        hasFetchedMessagesBefore = true
        // The gate was read once for this jump: the newest page is read two-phase, cache first.
        offlineFetchPreviousMessages(request: request, completion: nil)
    }

    /// The window around a jump target or the unread anchor, offline ON (README 3.9). Older and newer
    /// are each read in two phases, at once: the cached window paints as soon as both cached phases
    /// answered, and the server's pages replace their slices in place, with no second scroll. If
    /// nothing was cached, the first paint waits for the server; a side the server cannot be reached
    /// for keeps its cached page, so a jump works from the cache.
    func offlineFetchJumpWindow(anchor: BaseMessage, olderRequest: MessagesRequest) {
        let hubGen = OfflineHub.shared.gen
        if offline.gen != hubGen { offline.reset(toGen: hubGen) }
        let token = offline.beginRead(.older)
        let nextRequest = messagesRequestBuilder.set(messageID: anchor.id).build()
        messagesNextRequest = nextRequest
        var read = OfflineJumpRead()

        // `false` for a callback of a superseded read or an older session.
        let current: () -> Bool = { [weak self] in
            guard let this = self else { return false }
            if this.offline.isCurrent(.older, token: token, hubGen: hubGen) { return true }
            if this.offline.staleReadMustReleaseFlag(.older, token: token, hubGen: hubGen) { this.isUIUpdating = false }
            return false
        }
        let advance: () -> Void = { [weak self] in
            guard let this = self else { return }
            switch read.nextStep() {
            case .wait:
                break
            case .paintCached(let older, let newer):
                this.isUIUpdating = false
                // Anchored first, painted second: until the server says the window reaches the chat's
                // newest message, a sweep must not insert past its end.
                this.offline.anchoredWindow = true
                this.prepareProcessedMessageWindow(olderRaw: older, goToMessage: anchor, newerRaw: newer)
            case .paintFinal(let older, let newer):
                this.isUIUpdating = false
                this.offline.anchoredWindow = true
                this.prepareProcessedMessageWindow(olderRaw: older, goToMessage: anchor, newerRaw: newer)
                this.offlineApplyJumpEnds(read, newerLimit: nextRequest.limit)
            case .replaceCached:
                this.isUIUpdating = false
                this.offlineReplaceJumpWindow(read: read, newerLimit: nextRequest.limit)
            case .fail(let error):
                this.isUIUpdating = false
                this.offlineEndPositioning()
                this.offlineReportFailure(error)
            case .done:
                break
            }
        }

        service.fetchPreviousMessagesTwoPhase(request: olderRequest, onCached: { rows in
            guard current() else { return }
            read.cachedOlder = rows
            advance()
        }, onServer: { rows in
            guard current() else { return }
            read.serverOlder = rows
            advance()
        }, onError: { error in
            guard current() else { return }
            read.failed(.older, error: error, notConnected: OfflineErrors.isNotConnected(code: error?.errorCode))
            advance()
        })
        service.fetchNextMessagesTwoPhase(request: nextRequest, onCached: { rows in
            guard current() else { return }
            read.cachedNewer = rows
            advance()
        }, onServer: { rows in
            guard current() else { return }
            read.serverNewer = rows
            advance()
        }, onError: { error in
            guard current() else { return }
            read.failed(.newer, error: error, notConnected: OfflineErrors.isNotConnected(code: error?.errorCode))
            advance()
        })
    }

    /// The server's pages over a cached window already on screen: each replaces its slice in place,
    /// and the paging cursors move to the new edges. The reader's position is left alone.
    private func offlineReplaceJumpWindow(read: OfflineJumpRead, newerLimit: Int) {
        var acquired: [Int] = []
        // The cached window replaced the list when it painted, so every row of a cached side was painted
        // by this read. A side whose cached page does not join its server page is dropped (D13-R2).
        if let page = read.serverOlder {
            let cachedKeys = MessageRows.cachedKeys(of: offlinePrepare(read.cachedOlder ?? []))
            acquired += MessageRows.reconcileServerPage(offlinePrepare(page), cachedKeys: cachedKeys, into: &messages, aliases: &offline.aliases).acquiredServerIds
            MessageRows.dropUnjoinedCachedPage(paintedKeys: cachedKeys, rawCachedKeys: MessageRows.cachedKeys(of: read.cachedOlder ?? []), rawServerPage: page, end: .older, from: &messages)
        }
        if let page = read.serverNewer {
            let cachedKeys = MessageRows.cachedKeys(of: offlinePrepare(read.cachedNewer ?? []))
            acquired += MessageRows.reconcileServerPage(offlinePrepare(page), cachedKeys: cachedKeys, into: &messages, aliases: &offline.aliases).acquiredServerIds
            MessageRows.dropUnjoinedCachedPage(paintedKeys: cachedKeys, rawCachedKeys: MessageRows.cachedKeys(of: read.cachedNewer ?? []), rawServerPage: page, end: .newer, from: &messages)
        }
        offlineApplyHeldReceipts(for: acquired)
        resetCursorsToWindowEdges()
        offlineApplyJumpEnds(read, newerLimit: newerLimit)
        reload?()
    }

    /// End of history only from an empty server page (BEH-READ-09b). A server page after the anchor
    /// that is shorter than a full page means the window reaches the chat's newest message, so it is
    /// no longer an anchored window (a cached page proves nothing).
    private func offlineApplyJumpEnds(_ read: OfflineJumpRead, newerLimit: Int) {
        if read.serverOlder?.isEmpty == true { isAllMessagesFetchedInPrevious = true }
        if read.serverNewer?.isEmpty == true { isAllMessagesFetchedInNext = true }
        if let newer = read.serverNewer, newer.count < newerLimit { offline.anchoredWindow = false }
    }

    /// Newer page for pagination, offline ON. Same two phases and reconcile.
    func offlineFetchNextMessagesForPagination(request: MessagesRequest,
                                               oldMetrics: (oldOffsetY: CGFloat, oldContentHeight: CGFloat),
                                               anchorMessageId: BaseMessage?,
                                               completion: ((Int) -> Void)?) {
        let hubGen = OfflineHub.shared.gen
        if offline.gen != hubGen { offline.reset(toGen: hubGen) }
        let token = offline.beginRead(.newer)
        var cachedKeys = Set<Int>()
        var rawCachedKeys = Set<Int>()
        var paintedKeys = Set<Int>()

        service.fetchNextMessagesTwoPhase(request: request, onCached: { [weak self] rows in
            guard let this = self else { return }
            guard this.offline.isCurrent(.newer, token: token, hubGen: hubGen) else {
                if this.offline.staleReadMustReleaseFlag(.newer, token: token, hubGen: hubGen) { this.isFetchingNext = false }
                return
            }
            let page = this.offlinePrepare(rows)
            cachedKeys = MessageRows.cachedKeys(of: page)
            rawCachedKeys = MessageRows.cachedKeys(of: rows)
            paintedKeys = cachedKeys.subtracting(MessageRows.cachedKeys(of: this.messages.flatMap { $0.messages }))
            if this.offlineUpsertPage(page) { this.reload?() }
        }, onServer: { [weak self] rows in
            guard let this = self else { return }
            guard this.offline.isCurrent(.newer, token: token, hubGen: hubGen) else {
                if this.offline.staleReadMustReleaseFlag(.newer, token: token, hubGen: hubGen) { this.isFetchingNext = false }
                return
            }
            this.offline.newerReadsWaitForConnection = false
            guard !rows.isEmpty else {
                this.isFetchingNext = false
                this.isAllMessagesFetchedInNext = true
                this.offline.anchoredWindow = false   // the window now ends at the chat's newest message
                this.hideBottomSpinner?()
                return
            }
            let page = this.offlinePrepare(rows)
            let result = MessageRows.reconcileServerPage(page, cachedKeys: cachedKeys, into: &this.messages, aliases: &this.offline.aliases)
            this.offlineApplyHeldReceipts(for: result.acquiredServerIds)
            // A stale cached page that does not join the server page is not kept (D13-R2).
            MessageRows.dropUnjoinedCachedPage(paintedKeys: paintedKeys, rawCachedKeys: rawCachedKeys, rawServerPage: rows, end: .newer, from: &this.messages)
            this.reload?()
            this.isFetchingNext = false
            this.didCompleteFetchNextWithMetrics?(oldMetrics.oldOffsetY, oldMetrics.oldContentHeight)
            if let anchor = anchorMessageId { this.scrollToMessageId?(anchor.id, true) }
            completion?(anchorMessageId?.id ?? 0)
        }, onError: { [weak self] error in
            guard let this = self else { return }
            guard this.offline.isCurrent(.newer, token: token, hubGen: hubGen) else {
                if this.offline.staleReadMustReleaseFlag(.newer, token: token, hubGen: hubGen) { this.isFetchingNext = false }
                return
            }
            this.isFetchingNext = false
            if this.offlineIsNotConnected(error) {
                this.offline.newerReadsWaitForConnection = true
                this.hideBottomSpinner?()
                this.onOfflineNotConnected?()
            } else if let error = error, this.messages.isEmpty {
                this.failure?(error)
            }
        })
    }

    /// After a sync reported PARTIAL (or failed): refresh the newest window of the open chat with a
    /// fresh two-phase read. If the server page overlaps the rows shown it is merged in place; if
    /// not, the list stays and "jump to latest" is offered (see `offlineApplyLatestWindow`).
    func offlineRefreshNewestWindow() {
        guard user != nil || group != nil else { return }
        // Anchored on an older message: the newest window is not what is shown, and "load newer"
        // reads it. Refreshing here would replace the window the reader jumped to.
        guard !offline.anchoredWindow else { return }
        let hubGen = OfflineHub.shared.gen
        let token = offline.beginRead(.window)
        let request = offline.newestWindowRequest(from: messagesRequestBuilder)
        var cachedKeys = Set<Int>()
        service.fetchPreviousMessagesTwoPhase(request: request, onCached: { _ in }, onServer: { [weak self] rows in
            guard let this = self, this.offline.isCurrent(.window, token: token, hubGen: hubGen) else { return }
            let page = this.offlinePrepare(rows)
            guard !page.isEmpty else { return }
            cachedKeys = MessageRows.cachedKeys(of: this.messages.flatMap { $0.messages })
            let shownNewest = MessageListCursors.newestServerId(this.messages)
            let pageOldest = page.map { $0.id }.filter { $0 > 0 }.min() ?? 0
            switch MessageRows.windowRefreshPlan(shownNewest: shownNewest, pageOldest: pageOldest) {
            case .offerJumpToLatest:
                // More was missed than one page. Do not rebuild the list under the reader.
                this.offline.pendingLatestWindow = page
                this.onOfflineJumpToLatest?()
                return
            case .merge:
                let result = MessageRows.reconcileServerPage(page, cachedKeys: cachedKeys.intersection(Set(page.map { $0.id })), into: &this.messages, aliases: &this.offline.aliases)
                this.offlineApplyHeldReceipts(for: result.acquiredServerIds)
            }
            this.reload?()
        }, onError: { _ in })
    }

    /// The user tapped "jump to latest": reset the list to the newest window, keeping unsent rows.
    func offlineApplyLatestWindow() {
        guard let page = offline.pendingLatestWindow else { return }
        offline.pendingLatestWindow = nil
        offline.anchoredWindow = false
        var kept: MessageSections = []
        var aliases = MessageAliasMap()
        let unsent = messages.flatMap { $0.messages }.filter { $0.id <= 0 }
        _ = MessageRows.upsert(unsent, into: &kept, aliases: &aliases)
        _ = MessageRows.upsert(page, into: &kept, aliases: &aliases)
        messages = kept
        offline.aliases = aliases
        isAllMessagesFetchedInNext = false
        reload?()
    }

    /// One cumulative read receipt for the newest incoming message of the open chat. A conversation
    /// read that could not reach the server is remembered by `markConversationAsRead` and sent by the
    /// hub after the next sync (AC-7.4).
    func offlineMarkNewestIncoming() {
        guard let newest = messages.flatMap({ $0.messages }).first(where: { $0.id > 0 && !LoggedInUserInformation.isLoggedInUser(uid: $0.senderUid) }) else { return }
        if newest.readAt == 0 { markAsRead(message: newest) }
    }

    // MARK: - Kill switch

    /// Offline turned off while unsent rows were shown: the SDK dropped its queue silently and tells
    /// nobody. Rows that were sent on the offline path (they carry a local id) and have no server id
    /// turn failed (direct), and one notice says how many. The list is not reloaded.
    func offlineHandleKillSwitch() {
        let turned = OfflineHub.shared.failStranded(messages.flatMap { $0.messages })
        guard !turned.isEmpty else { return }
        reload?()
        onOfflineNotice?(OfflineNotice(gen: OfflineHub.shared.gen, kind: .messagesNotSent, count: turned.count))
    }

    /// Long enough for a warm sweep's message phase, which follows at once, to land first.
    private func offlineColdSweepSchedule(_ check: DispatchWorkItem) {
        offlineAfter(MessageListOfflineState.coldSweepSettle, check)
    }

    /// The kill-switch check for the next operation or connection event: runs only with offline
    /// off (the gate is read here, once).
    func offlineKillSwitchCheck() {
        if !OfflineGate.isOn() { offlineHandleKillSwitch() }
    }

    // MARK: - Unsent-row actions

    /// Retry an unsent row on the user's tap (R162: any PENDING, SENDING or FAILED row):
    /// `retryMessage(localMessageId)` for an outbox row, never a fresh send, which would duplicate
    /// it; a fresh send only for a direct failure. When the SDK answers
    /// `ERROR_OFFLINE_MESSAGE_IN_FLIGHT` the row is being sent right now, nothing changed, and the
    /// "Sending... try again in a moment" notice shows. Taps while a Retry is in flight are ignored.
    func offlineRetry(message: BaseMessage) {
        OfflineSend.retry(message, sdk: offlineSDK) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .disabled:
                // The kill switch flipped: the SDK dropped its queue. The row turns failed (direct).
                this.offlineHandleKillSwitch()
            case .inFlight:
                this.offlineNoticeSendInFlight(message)
            case .notFound:
                // The SDK no longer holds it (ENG-57447): the row goes, as on Android. A row that
                // already shows its sent copy stays.
                this.offlineDropRowTheSDKNoLongerHolds(message, deleteOnceSent: false)
            case .accepted, .ignored, .rejected:
                // Accepted: the outbox reports the row's new state. A rejection with no answer (not
                // connected) leaves the row PENDING, which is what it shows: silent.
                break
            }
        }
    }

    /// The SDK answered `ERROR_OFFLINE_MESSAGE_IN_FLIGHT` to a Retry or Delete of `message`: its send
    /// is under way and nothing changed (R162 / S73). Tell the user, on the list they tapped in.
    func offlineNoticeSendInFlight(_ message: BaseMessage) {
        onOfflineNotice?(OfflineNotice(gen: OfflineHub.shared.gen, kind: .sendInFlight, count: 1, message: message))
    }

    /// Delete an unsent row (BEH-SEND-36, R162).
    /// - success: the row goes (the SDK repairs the conversation preview itself)
    /// - in flight: the row stays; the "Sending... try again in a moment" notice
    /// - not found: the SDK no longer holds it (it went out, or a purge such as BEH-SYNC-17 removed
    ///   it). A row that shows its server id is deleted on the server through today's delete (offline
    ///   that ends in today's not-connected error and the row stays). Without one the row goes from
    ///   the screen at once (ENG-57447, as on Android), and if a sent copy still arrives it is deleted
    ///   on the server and not shown. Never a ghost row.
    /// - offline disabled: the kill-switch path; the row is a failed (direct) row and is removed from
    ///   the screen only
    func offlineDiscard(message: BaseMessage, completion: ((OfflineSend.DiscardResult) -> Void)? = nil) {
        OfflineSend.discard(message, sdk: offlineSDK) { [weak self] result in
            guard let this = self else { completion?(result); return }
            switch result {
            case .removed:
                this.offlineRemoveRow(message)
            case .inFlight:
                this.offlineNoticeSendInFlight(message)
            case .notFound:
                this.offlineDropRowTheSDKNoLongerHolds(message, deleteOnceSent: true)
            case .disabled:
                OfflineHub.shared.failStranded([message])
                OfflineHub.shared.clearDirectFailed(message)
                OfflineHub.shared.reportUserDiscard(message)
                this.offlineRemoveRow(message)
            case .failed(let code):
                this.onOfflineActionError?(CometChatException(errorCode: code, errorDescription: code))
            }
            completion?(result)
        }
    }

    /// A Delete or Retry of `message` was answered `ERROR_OFFLINE_MESSAGE_NOT_FOUND`: the SDK no longer
    /// holds an unsent copy (it went out, or a purge removed it, e.g. BEH-SYNC-17 after the user left
    /// or was removed from the group). ENG-57447, as on Android (NOT_FOUND removes the row):
    /// - the row already shows its server id: it is a sent message. A Delete deletes it on the server
    ///   (today's delete); a Retry leaves it.
    /// - otherwise the row goes from the screen at once and is reported as the user's discard, as a
    ///   successful Delete is, so the conversation preview and a parent's reply count follow. After a
    ///   Delete, a sent copy that still arrives (it went out just before) is deleted on the server and
    ///   not shown (`offlineSentAfterDiscard`).
    func offlineDropRowTheSDKNoLongerHolds(_ message: BaseMessage, deleteOnceSent: Bool) {
        if let found = MessageRows.locate(message, in: messages, aliases: offline.aliases) {
            let shown = messages[found.section].messages[found.row]
            if shown.id > 0 {
                if deleteOnceSent { offlineServerDelete(shown) }
                return
            }
        }
        if deleteOnceSent, let local = MessageIdentity.localId(message) {
            offline.deleteWhenSent.insert(local)
        }
        OfflineHub.shared.clearDirectFailed(message)
        OfflineHub.shared.reportUserDiscard(message)
        offlineRemoveRow(message)
    }

    /// Today's delete of a sent message (`CometChat.deleteMessage`). Offline it ends in today's
    /// not-connected error with nothing changed on screen (UIK-MUT-01).
    func offlineServerDelete(_ message: BaseMessage) {
        service.deleteSentMessage(id: message.id, onSuccess: { deleted in
            CometChatMessageEvents.onMessageDeleted(message: deleted)
        }, onError: { [weak self] error in
            self?.onOfflineActionError?(error)
        })
    }
}

// MARK: - Hub events

extension MessageListViewModel: OfflineHubObserver {

    private func offlineIsCurrent(gen: Int) -> Bool {
        return gen == OfflineHub.shared.gen
    }

    func offlineSendState(_ event: OfflineSendStateEvent) {
        // A thread reply belongs to its thread, not to this list, but this list shows the parent's count.
        if offlineIsCurrent(gen: event.gen) { offlineCountReply(event) }
        guard offlineIsCurrent(gen: event.gen), offlineBelongsHere(event.message) else { return }
        if offline.gen != event.gen { offline.reset(toGen: event.gen) }
        switch event.state {
        case .discarded:
            offlineRemoveRow(event.message)
        case .sending, .sent, .failed:
            offlineUpsertOne(event.message)
            if event.state == .sent, let local = event.localMessageId,
               offline.deleteWhenSent.remove(local) != nil, event.message.id > 0 {
                offlineServerDelete(event.message)
            }
        }
    }

    /// A message removed after the SDK answered NOT_FOUND went out after all (ENG-57447). The hub keeps
    /// it off every screen (`.discarded` never becomes `.sent`); if this list's Delete asked for it to
    /// go, it is deleted on the server now. Nothing is inserted.
    func offlineSentAfterDiscard(_ event: OfflineSendStateEvent) {
        guard offlineIsCurrent(gen: event.gen), event.message.id > 0,
              let local = event.localMessageId ?? MessageIdentity.localId(event.message),
              offline.deleteWhenSent.remove(local) != nil else { return }
        offlineServerDelete(event.message)
    }

    // MARK: - Reply count of a parent (ENG-38017)

    /// The identities an own reply can be told apart by: its muid and its local id.
    private func offlineReplyKeys(_ message: BaseMessage) -> [String] {
        var keys: [String] = []
        if let muid = MessageIdentity.muid(message) { keys.append("m:\(muid)") }
        if let local = MessageIdentity.localId(message) { keys.append("l:\(local)") }
        return keys
    }

    /// Add `delta` to the reply count of the parent row shown. Returns whether a parent row was found.
    @discardableResult
    private func offlineAdjustParentReplyCount(of reply: BaseMessage, by delta: Int) -> Bool {
        for (sectionIndex, section) in messages.enumerated() {
            for (rowIndex, row) in section.messages.enumerated() where row.id == reply.parentMessageId {
                row.replyCount = max(0, row.replyCount + delta)
                updateAtIndex?(sectionIndex, rowIndex, row)
                return true
            }
        }
        return false
    }

    /// An own reply to a message shown in this list counts as soon as it is queued, once, and is taken
    /// back if the reply is discarded. Its ack does not count it again (`offlineTakeCountedReply`).
    private func offlineCountReply(_ event: OfflineSendStateEvent) {
        let reply = event.message
        guard reply.parentMessageId > 0, parentMessage == nil,
              LoggedInUserInformation.isLoggedInUser(uid: reply.senderUid) else { return }
        let keys = offlineReplyKeys(reply)
        guard !keys.isEmpty else { return }
        switch event.state {
        case .sending:
            guard !keys.contains(where: { offline.countedReplies.contains($0) }) else { return }
            if offlineAdjustParentReplyCount(of: reply, by: 1) { offline.countedReplies.formUnion(keys) }
        case .discarded:
            guard keys.contains(where: { offline.countedReplies.contains($0) }) else { return }
            offline.countedReplies.subtract(keys)
            offlineAdjustParentReplyCount(of: reply, by: -1)
        case .sent, .failed:
            break
        }
    }

    /// Whether the parent's count already includes this reply because it was counted when queued. The
    /// ack then adds nothing. Empty (so always `false`) unless an offline send was counted.
    func offlineTakeCountedReply(_ reply: BaseMessage) -> Bool {
        guard !offline.countedReplies.isEmpty else { return false }
        let keys = offlineReplyKeys(reply)
        guard keys.contains(where: { offline.countedReplies.contains($0) }) else { return false }
        offline.countedReplies.subtract(keys)
        return true
    }

    /// Whether a swept row would show in this list: the same template check a live insert makes
    /// (`add(message:)`), and never the server's `action`/`message` record of an edit or delete
    /// (BEH-SYNC-25/31). The edited or deleted original, a normal message, still updates in place.
    func offlineAcceptsSweptRow(_ message: BaseMessage) -> Bool {
        if let action = message as? ActionMessage, action.action == .messageEdited || action.action == .messageDeleted {
            return false
        }
        return getTemplate(for: message) != nil
    }

    func offlineMessageSyncCompleted(_ event: OfflineMessageSyncEvent) {
        guard offlineIsCurrent(gen: event.gen) else { return }
        // Upsert every swept message of this conversation into its sorted place. This is the only
        // path for `action` and `call` rows (BEH-SYNC-25).
        let anchored = offline.anchoredWindow
        var mine = offlinePrepare(event.messages.filter { offlineBelongsHere($0) && !(parentMessage != nil && $0.messageCategory == .action) })
            .filter { offlineAcceptsSweptRow($0) }
        // Anchored on an older message (a jump, start from unread): the sweep updates the rows shown
        // and inserts nothing. A newer message put past the window's end leaves a hole, and "load
        // newer" anchors on the newest row shown, so it would skip everything in it. The messages
        // are in the SDK's store: scrolling to the end, or "jump to latest", reads them.
        if anchored { mine = mine.filter { MessageRows.locate($0, in: messages, aliases: offline.aliases) != nil } }
        // A sweep ends the wait only for receipts held past the bound: a media ack can land after the
        // sweep and must still find its receipt (ENG-41193; README 3.6).
        offline.heldReceipts.removeExpired()
        if offlineUpsertPage(mine) { reload?() }
        if !anchored, MessageRows.shouldMarkNewestRead(.syncCompleted, isAtBottom: offlineIsAtBottom?() ?? true) {
            offlineMarkNewestIncoming()
        }
        if event.outcome == .partial, !anchored { offlineRefreshNewestWindow() }
    }

    /// A sweep with no watermark yet is conversation-only (BEH-SYNC-32): the open chat's newer message
    /// comes only on its conversation, and nothing inserts it. If no message phase brings it shortly,
    /// refresh the newest window once, the same single read a PARTIAL sweep gets.
    func offlineConversationSyncCompleted(_ event: OfflineConversationSyncEvent) {
        // Anchored on an older message: the newest window is not what is shown ("load newer" reads it).
        guard offlineIsCurrent(gen: event.gen), parentMessage == nil, !offline.anchoredWindow else { return }
        let last = event.conversations.compactMap { $0.lastMessage }.first {
            $0.id > 0 && $0.parentMessageId == 0 && offlineBelongsHere($0)
        }
        guard let lastId = last?.id, lastId > MessageListCursors.newestServerId(messages) else { return }
        offline.coldSweepCheck?.cancel()
        let check = DispatchWorkItem { [weak self] in
            guard let this = self, this.offlineIsCurrent(gen: event.gen), !this.offline.anchoredWindow else { return }
            if MessageListCursors.newestServerId(this.messages) >= lastId { return }
            this.offlineRefreshNewestWindow()
        }
        offline.coldSweepCheck = check
        offlineColdSweepSchedule(check)
    }

    func offlineSyncFailed(_ event: OfflineSyncFailedEvent) {
        guard offlineIsCurrent(gen: event.gen), event.phase == .message else { return }
        offlineRefreshNewestWindow()
    }

    func offlineMessagesUpdated(_ event: OfflineMessagesUpdatedEvent) {
        guard offlineIsCurrent(gen: event.gen) else { return }
        // Update rows already shown; never insert (BEH-INV-11).
        for message in offlinePrepare(event.messages.filter { offlineBelongsHere($0) }) {
            offlineUpsertOne(message, insertIfMissing: false)
        }
    }

    func offlineSessionChanged(gen: Int) {
        // Logout, user switch or cache reset: no frame of the old session's data.
        offline.reset(toGen: gen)
        offline.endPositioning()
        offline.reloadWhenSessionStarts = true
        messages.removeAll()
        isAllMessagesFetchedInPrevious = false
        isAllMessagesFetchedInNext = false
        hasFetchedMessagesBefore = false
        reload?()
    }

    func offlineCacheReset(_ event: OfflineCacheResetEvent) {
        // Every mounted list reloads from the new cache, two-phase.
        guard offlineIsCurrent(gen: event.gen) else { return }
        offline.reloadWhenSessionStarts = false
        guard messagesRequest != nil else { return }
        messagesRequest = offline.newestWindowRequest(from: messagesRequestBuilder)
        fetchPreviousMessages()
    }

    func offlineSessionStarted(gen: Int) {
        // A token refresh logs out and in again with the cache kept: reload what was cleared.
        guard offline.reloadWhenSessionStarts, offlineIsCurrent(gen: gen), messagesRequest != nil else { return }
        offline.reloadWhenSessionStarts = false
        messagesRequest = offline.newestWindowRequest(from: messagesRequestBuilder)
        fetchPreviousMessages()
    }

    /// Back online: a placeholder drawn while offline can now load from its URL (AC-12.3).
    func offlineRedrawMediaRowsAfterConnect() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self, this.messages.contains(where: { $0.messages.contains { $0 is MediaMessage } }) else { return }
            this.reload?()
        }
    }

    func offlineMediaReady(_ event: OfflineMediaReadyEvent) {
        guard offlineIsCurrent(gen: event.gen) else { return }
        // A media file finished downloading: redraw the rows that show it so they re-resolve their
        // source (local path first, then the URL).
        let shown = messages.contains { section in
            section.messages.contains { ($0 as? MediaMessage)?.attachment?.fileUrl == event.url }
        }
        if shown { reload?() }
    }

    @discardableResult
    func offlineNotice(_ notice: OfflineNotice) -> Bool {
        guard offlineIsCurrent(gen: notice.gen), let show = onOfflineNotice else { return false }
        // A notice about one message belongs to the list that shows it, unless no such list is there.
        if let message = notice.message, !notice.forAnyScreen, !offlineBelongsHere(message) { return false }
        show(notice)
        return true
    }
}
