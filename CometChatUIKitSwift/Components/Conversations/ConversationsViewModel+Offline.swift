//
//  ConversationsViewModel+Offline.swift
//  CometChatUIKitSwift
//
//  The offline (ON) path of the conversation list: two-phase reads, the sweep's conversation slice
//  reconciled in place, and the session events. Reached only after the caller read
//  `OfflineGate.isOn()` for its operation, or from a hub event (which the SDK fires only with
//  offline on). With offline off none of this runs.
//

import Foundation
import CometChatSDK

extension ConversationsViewModel {

    // MARK: - Kill switch

    /// Offline turned off while an own send was queued: the preview of that chat would show the
    /// clock forever. Turn such previews failed (UIK-LIFE-03); the message list shows the notice.
    /// Swept kick / ban / leave of the logged-in user: the chat leaves the list, as for a live one.
    func offlineApplySweptGroupActions(_ messages: [BaseMessage]) {
        let me = service.loggedInUserUid()
        for case let action as ActionMessage in messages {
            if let group = ConversationRows.groupLostBy(action, loggedInUid: me) {
                removerConversation(for: group)
            }
        }
    }

    func offlineKillSwitchCheck() {
        guard !OfflineGate.isOn() else { return }
        let previews = conversations.compactMap { $0.lastMessage }
        guard !OfflineHub.shared.failStranded(previews).isEmpty else { return }
        reload?()
    }

    // MARK: - Pin / update events

    /// An update or pin event for a conversation, offline ON.
    func offlineHandleConversationUpdate(_ event: Conversation) {
        switch ConversationRows.pinEventAction(event, rows: conversations, loggedInUid: service.loggedInUserUid(), filtered: requestNarrows) {
        case .ignore:
            return
        case .update(let index):
            let existing = conversations[index]
            // Carry the row's identity so the in-place paths find it whatever the event's id case.
            if let id = existing.conversationId { event.conversationId = id }
            if existing.pinnedAt != event.pinnedAt {
                repositionForPinChange(conversation: event)
            } else {
                update(conversation: event)
            }
        case .fetchAndInsert:
            guard let with = event.conversationWith else { return }
            let id: String
            let type: CometChat.ConversationType
            if let user = with as? User { id = user.uid ?? ""; type = .user }
            else if let group = with as? Group { id = group.guid; type = .group }
            else { return }
            guard !id.isEmpty else { return }
            let hubGen = OfflineHub.shared.gen
            service.fetchConversation(with: id, type: type, onSuccess: { [weak self] conversation in
                guard let this = self, hubGen == OfflineHub.shared.gen else { return }
                // It may have arrived while the fetch ran.
                guard ConversationRows.index(of: conversation, in: this.conversations) == nil else { return }
                this.insert(conversation: conversation)
            }, onError: { _ in })   // ignored on failure
        }
    }

    // MARK: - Own send previews

    /// A pending (or failed) own send puts its chat at the top with that message as the preview.
    func offlineFollowSend(_ message: BaseMessage) {
        guard let target = ConversationRows.index(ofMessage: message, in: conversations) else { return }
        let conversation = conversations[target]
        offlineRememberPreview(conversation.lastMessage, replacedBy: message)
        conversation.lastMessage = message
        let sentAt = Double(message.sentAt)
        if sentAt > conversation.updatedAt { conversation.updatedAt = sentAt }
        moveToTop(conversation: conversation)
        update(conversation: conversation)
    }

    static let maxRememberedPreviews = 50

    private func offlineRememberPreview(_ previous: BaseMessage?, replacedBy message: BaseMessage) {
        // A failed send re-announced keeps the preview it first replaced.
        if let previous = previous, ConversationRows.isSameMessage(previous, message) { return }
        guard !offlinePreviewsBeforeSend.contains(where: { ConversationRows.isSameMessage($0.message, message) }) else { return }
        offlinePreviewsBeforeSend.append((message: message, previous: previous))
        if offlinePreviewsBeforeSend.count > Self.maxRememberedPreviews { offlinePreviewsBeforeSend.removeFirst() }
    }

    /// An own unsent message the SDK (or the user) removed: its chat's preview goes back to what it
    /// was before that send, in place. The row does not move and its unread count is kept. A send
    /// whose preview is no longer shown (a newer message replaced it) changes nothing on screen.
    func offlineRestorePreview(after removed: BaseMessage) {
        let entry = offlinePreviewsBeforeSend.firstIndex { ConversationRows.isSameMessage($0.message, removed) }
        let previous = entry.flatMap { offlinePreviewsBeforeSend[$0].previous }
        if let entry = entry { offlinePreviewsBeforeSend.remove(at: entry) }
        // A later send that had replaced the removed message falls back to what that one replaced.
        for i in offlinePreviewsBeforeSend.indices {
            if let replaced = offlinePreviewsBeforeSend[i].previous, ConversationRows.isSameMessage(replaced, removed) {
                offlinePreviewsBeforeSend[i].previous = previous
            }
        }
        guard entry != nil, let index = ConversationRows.index(ofMessage: removed, in: conversations) else { return }
        let conversation = conversations[index]
        guard let shown = conversation.lastMessage, ConversationRows.isSameMessage(shown, removed) else { return }
        conversation.lastMessage = previous
        update(conversation: conversation)
    }

    /// The ack of an own send, offline ON. The ack never touches the unread count (it is not a new
    /// message to the reader) and never replaces a newer preview: an ack that lands late, after a
    /// peer's message, left the chat at 0 unread with the older preview. A chat not shown is
    /// handled as before.
    func offlineApplySendAck(_ message: BaseMessage) {
        guard let index = ConversationRows.index(ofMessage: message, in: conversations) else {
            update(lastMessage: message)
            return
        }
        let row = conversations[index]
        offlinePreviewsBeforeSend.removeAll { ConversationRows.isSameMessage($0.message, message) }
        guard ConversationRows.ackReplacesPreview(row.lastMessage, ack: message) else { return }
        row.lastMessage = message
        update(conversation: row)
    }

    /// Two-phase read, offline ON. Cached rows paint first; the server page replaces the same
    /// slice. Never blanks cached rows on an error. `merge`: the kit's own re-read of a narrowed
    /// list after a sync; its pages merge into the rows shown (the rows paged in below page one stay).
    func offlineFetchConversations(request: ConversationRequest, wasRefresh: Bool, token: Int, automatic: Bool = false, merge: Bool = false) {
        let hubGen = OfflineHub.shared.gen
        // A page after the first, asked for by scrolling: its failure keeps today's handling.
        let isLoadMore = !wasRefresh && !conversations.isEmpty
        offlineError = .none
        connectToSearch = false
        if wasRefresh {
            // A reload from scratch supersedes a load-more in progress and whatever it closed.
            offlineReadOn = nil
            offlinePagingClosed = false
        } else if offlineReadOn == nil {
            offlineReadOn = (listed: Set(conversations.compactMap { $0.conversationId }), reads: 0)
        }
        var cachedIds = Set<String>()
        if merge { offlineResyncToken = token }

        service.fetchConversationsTwoPhase(request: request, onCached: { [weak self] page in
            guard let this = self, this.offlineIsCurrentRead(token: token, hubGen: hubGen) else { return }
            cachedIds = Set(page.compactMap { $0.conversationId })
            guard !page.isEmpty else { return }
            if merge {
                ConversationRows.mergeFirstServerPage(&this.conversations, cachedIds: [], page: page)
                this.applyPinOrdering()
            } else {
                this.offlineMerge(page, replacing: wasRefresh ? this.conversations.map { $0.conversationId ?? "" }.filter { !cachedIds.contains($0) } : [])
            }
            this.reload?()
        }, onServer: { [weak self] page in
            guard let this = self, this.offlineIsCurrentRead(token: token, hubGen: hubGen) else { return }
            if page.isEmpty { this.isFetchedAll = true }
            // Only a first page proves a row gone. Pages 2 onward only add and update (BEH-SYNC-15,
            // R91): the cached page of a later read can hold rows the server's later page rightly
            // omits, and removing them emptied the list once it overflowed one page.
            if merge {
                // Page one's rows are upserted; only a row this read's cached phase showed, inside
                // the page's range and absent from it, goes. Rows below stay; an empty page changes
                // nothing.
                if this.offlineResyncToken == token { this.offlineResyncToken = nil }
                ConversationRows.mergeFirstServerPage(&this.conversations, cachedIds: cachedIds, page: page)
                this.applyPinOrdering()
            } else {
                if wasRefresh {
                    let serverIds = Set(page.compactMap { $0.conversationId })
                    // Rows the cached page showed that the server no longer has are removed; rows with an
                    // own unsent preview stay (BEH-CONV-06).
                    let omitted = cachedIds.subtracting(serverIds)
                    this.conversations.removeAll { row in
                        guard let id = row.conversationId, omitted.contains(id) else { return false }
                        return !ConversationRows.hasUnsentPreview(row)
                    }
                }
                this.offlineMerge(page, replacing: [])
            }
            for conversation in this.conversations { this.markAsDelivered(conversation: conversation) }
            this.isFetching = false
            this.isRefresh = false
            this.reload?()
            if !wasRefresh { this.offlineReadsOn(after: page) }
        }, onError: { [weak self] error in
            guard let this = self, this.offlineIsCurrentRead(token: token, hubGen: hubGen) else { return }
            this.isFetching = false
            this.isRefresh = false
            this.offlineReadOn = nil
            if this.offlineResyncToken == token { this.offlineResyncToken = nil }
            let notConnected = OfflineErrors.isNotConnected(code: error?.errorCode)
            // A page past the cache that could not be read: paging waits for the connection.
            if notConnected && !wasRefresh { this.offlinePagingClosed = true }
            let rowsShown = !this.conversations.isEmpty
            if isLoadMore {
                // Saved conversations stay; paging waits for the connection quietly.
                this.reload?()
                return
            }
            // Rows on screen stay; nothing on screen is the offline state or the error view. Only an
            // online failure of a load the user or app started reaches `onError` over rows.
            let verdict = OfflineReadFailure.evaluate(error, rowsShown: rowsShown,
                                                      keywordSearch: OfflineReadFailure.isKeyword(request.searchKeyword), kitStarted: automatic)
            this.offlineError = OfflineListError.afterFailure(error, rowsShown: rowsShown)
            this.connectToSearch = verdict.screen == .connectToSearch
            if rowsShown || verdict.screen == .connectToSearch { this.reload?() }
            if verdict.reportsError, let error = error { this.failure?(error) }
        })
    }

    /// Most pages one offline load-more reads while its pages list no new chat.
    static let maxOfflineReadOn = 10

    /// After a server page of a load-more: a page that lists no new chat (the reconnect sync
    /// already listed them) is not the end, so the read goes on, up to `maxOfflineReadOn` pages.
    /// An empty page ends the list; a page with a new chat ends the load.
    private func offlineReadsOn(after page: [Conversation]) {
        guard var state = offlineReadOn else { return }
        state.reads += 1
        let hasNew = page.contains { $0.conversationId.map { !state.listed.contains($0) } ?? false }
        guard !page.isEmpty, !hasNew, state.reads < Self.maxOfflineReadOn, !isFetchedAll else {
            offlineReadOn = nil
            return
        }
        offlineReadOn = state
        fetchConversations()
    }

    /// The connection is back. Offline ON, when a read past the cache had closed paging, that page
    /// is read once now (the user's scroll trigger is spent), reading on as a load-more does. No
    /// other fetch: the SDK's sweep reconciles the list (UIK-SYNC-01). Never while a read is in
    /// flight.
    func offlineReconnected() {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { [weak self] in self?.offlineReconnected() }
            return
        }
        guard offlineGate() else { return }
        // The first page failed for want of a connection and the error view is showing: read it once now.
        if offlineError == .notConnected && conversations.isEmpty && !isFetching {
            automaticRefetch = true
            isRefresh = true
            return
        }
        guard offlinePagingClosed else { return }
        offlinePagingClosed = false
        guard !isFetching else { return }
        isRefresh = false
        fetchConversations()
    }

    private func offlineIsCurrentRead(token: Int, hubGen: Int) -> Bool {
        return token == currentFetchToken && hubGen == OfflineHub.shared.gen
    }

    /// Upsert a page by conversation id, appending new rows, then apply pin order.
    private func offlineMerge(_ page: [Conversation], replacing staleIds: [String]) {
        if !staleIds.isEmpty {
            conversations.removeAll { row in
                guard let id = row.conversationId, staleIds.contains(id) else { return false }
                return !ConversationRows.hasUnsentPreview(row)
            }
        }
        for conversation in page {
            guard let id = conversation.conversationId else { continue }
            if let index = conversations.firstIndex(where: { $0.conversationId == id }) {
                conversations[index] = conversation
            } else {
                conversations.append(conversation)
            }
        }
        applyPinOrdering()
    }
}

// MARK: - Hub events

extension ConversationsViewModel: OfflineHubObserver {

    func offlineSendState(_ event: OfflineSendStateEvent) {
        guard event.gen == OfflineHub.shared.gen, event.state == .discarded else { return }
        offlineRestorePreview(after: event.message)
    }

    func offlineMessageSyncCompleted(_ event: OfflineMessageSyncEvent) {
        guard event.gen == OfflineHub.shared.gen else { return }
        offlineApplySweptGroupActions(event.messages)
    }

    func offlineConversationSyncCompleted(_ event: OfflineConversationSyncEvent) {
        guard event.gen == OfflineHub.shared.gen else { return }
        if requestNarrows {
            // A list whose request narrows it (type, tags, search, unread, pinned-by, agentic) is not
            // the sync page's slice: it re-reads its own request once, quietly, and merges the answer
            // into the rows shown. A sync page that lands while that runs starts no second one.
            if let running = offlineResyncToken, running == currentFetchToken { return }
            automaticRefetch = true
            mergeRefetch = true
            isRefresh = true
            return
        }
        if ConversationRows.reconcileSlice(&conversations, with: event.conversations) {
            applyPinOrdering()
            reload?()
        }
    }

    func offlineCacheReset(_ event: OfflineCacheResetEvent) {
        guard event.gen == OfflineHub.shared.gen else { return }
        // The kit's own reload: it fails quietly over rows on screen.
        automaticRefetch = true
        isRefresh = true
    }

    func offlineSessionChanged(gen: Int) {
        offlinePreviewsBeforeSend.removeAll()
        offlineResyncToken = nil
        conversations.removeAll()
        isFetchedAll = false
        offlineReadOn = nil
        offlinePagingClosed = false
        offlineError = .none
        connectToSearch = false
        reload?()
    }

    @discardableResult
    func offlineNotice(_ notice: OfflineNotice) -> Bool {
        // A notice about a single message belongs to the list that shows it; the conversation list
        // shows the ones about the whole cache, and any notice no such list was there to take.
        guard notice.message == nil || notice.forAnyScreen, let show = onOfflineNotice,
              offlineCanShowNotice?() ?? true else { return false }
        show(notice)
        return true
    }
}

// MARK: - State contract

extension CometChatConversations {

    /// `cc.conversation.<user|group>.<with>.<previewState>.<unread>.<pinned>`: `previewState` is the
    /// state of an own last message (`sending`, `failed`, `sent`, `delivered`, `read`), else `none`.
    /// `cc.conversation.<user|group>.<with>` of a row identifier: which chat a cell is drawn for.
    static func contractSubject(_ identifier: String) -> String {
        return identifier.split(separator: ".", maxSplits: 4, omittingEmptySubsequences: false).prefix(4).joined(separator: ".")
    }

    static func contractIdentifier(for conversation: Conversation) -> String {
        let isGroup = conversation.conversationType == .group
        let with = (conversation.conversationWith as? User)?.uid ?? (conversation.conversationWith as? Group)?.guid ?? ""
        var previewState = "none"
        if let last = conversation.lastMessage, LoggedInUserInformation.isLoggedInUser(uid: last.senderUid) {
            previewState = CometChatMessageList.contractState(for: last)
        }
        return StateContract.conversationRow(isGroup: isGroup, with: with, previewState: previewState,
                                             unread: conversation.unreadMessageCount, pinned: conversation.pinnedAt > 0)
    }
}
