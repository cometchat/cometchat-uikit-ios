//
//  GroupsViewModel+Offline.swift
//  CometChatUIKitSwift
//
//  The offline (ON) read of the groups list: cached page first, the server's page replaces the
//  same slice. A failed read follows D84 (`OfflineReadFailure`): rows stay and a not-connected failure
//  reports nothing; nothing on screen is "Connect to load groups" (or "Connect to search" for a
//  keyword) when not connected, the error view otherwise. Reached only after the caller read
//  `OfflineGate.isOn()` for this read.
//

import Foundation
import CometChatSDK

extension GroupsViewModel {

    func offlineFetchGroups(request: GroupsRequest, automatic: Bool = false) {
        let wasRefresh = isRefresh
        // A page after the first, asked for by scrolling: its failure keeps today's handling.
        let isLoadMore = !wasRefresh && !groups.isEmpty
        offlineError = .none
        connectToSearch = false
        var cachedKeys = Set<String>()
        let key: (Group) -> String? = { $0.guid }
        // As the conversation list: a late answer of an older read or session never reaches the list.
        offlineReadToken += 1
        let token = offlineReadToken
        let hubGen = OfflineHub.shared.gen
        let isCurrent: (GroupsViewModel) -> Bool = { $0.offlineReadToken == token && OfflineHub.shared.gen == hubGen }

        service.fetchGroupsTwoPhase(request: request, onCached: { [weak self] page in
            guard let this = self, isCurrent(this), !page.isEmpty else { return }
            cachedKeys = Set(page.compactMap(key))
            this.groups = wasRefresh ? SnapshotRows.startRefresh(current: this.groups, cachedPage: page)
                                     : SnapshotRows.paintCached(current: this.groups, cachedPage: page, key: key)
        }, onServer: { [weak self] page in
            guard let this = self, isCurrent(this) else { return }
            if page.isEmpty { this.isFetchedAll = true }
            this.groups = SnapshotRows.reconcile(current: this.groups, cachedKeys: cachedKeys, serverPage: page, key: key)
            this.isFetching = false
        }, onError: { [weak self] error in
            guard let this = self, isCurrent(this) else { return }
            this.isFetching = false
            let rowsShown = !this.groups.isEmpty
            if isLoadMore {
                // Paging waits for the connection quietly; the footer is not this rule's.
                if OfflineErrors.isNotConnected(code: error?.errorCode) { return }
                if automatic && rowsShown { return }
                if let error = error { this.failure?(error) }
                return
            }
            // Rows on screen stay; nothing on screen is the offline state or the error view. Only an
            // online failure of a load the user or app started reaches `onError` over rows.
            let verdict = OfflineReadFailure.evaluate(error, rowsShown: rowsShown,
                                                      keywordSearch: OfflineReadFailure.isKeyword(request.searchKeyword), kitStarted: automatic)
            this.offlineError = OfflineListError.afterFailure(error, rowsShown: rowsShown)
            this.connectToSearch = verdict.screen == .connectToSearch
            if verdict.reportsError, let error = error {
                this.failure?(error)
            } else {
                // No callback to end a pull-to-refresh or draw "Connect to search": redraw.
                this.reload?()
            }
        })
    }
}

// MARK: - Hub events

extension GroupsViewModel: OfflineHubObserver {

    /// A kick, ban, leave or join the SDK's catch-up delivered while the device was offline runs the
    /// handlers a live one would reach (UIT-SYNC-13). The sweep fires no group listener callback, so
    /// without this a group the user lost stays in the list until the next full reload.
    func offlineMessageSyncCompleted(_ event: OfflineMessageSyncEvent) {
        guard event.gen == OfflineHub.shared.gen else { return }
        SweptGroupAction.replayAll(event.messages, to: self)
    }

    func offlineSessionChanged(gen: Int) {
        groups = []
        offlineError = .none
        connectToSearch = false
        searchFailedOffline = false
        searchReloadOnConnect = false
        filteredGroups = []
        isFetching = false
        isFetchedAll = false
    }

    func offlineCacheReset(_ event: OfflineCacheResetEvent) {
        guard event.gen == OfflineHub.shared.gen else { return }
        // The kit's own reload: it fails quietly over rows on screen.
        automaticRefetch = true
        isRefresh = true
    }

    func offlineSessionStarted(gen: Int) {
        guard groups.isEmpty, gen == OfflineHub.shared.gen else { return }
        isRefresh = true
    }
}
