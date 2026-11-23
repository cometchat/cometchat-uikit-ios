//
//  UsersViewModel+Offline.swift
//  CometChatUIKitSwift
//
//  The offline (ON) read of the users list: the on-device page paints first, the server's page
//  replaces the same slice. A failed read follows D84 (`OfflineReadFailure`): rows stay and a
//  not-connected failure reports nothing; nothing on screen is "Connect to load users" (or "Connect to
//  search" for a keyword) when not connected, the error view otherwise. Reached only after the caller
//  read `OfflineGate.isOn()` for this read.
//

import Foundation
import CometChatSDK

extension UsersViewModel {

    func offlineFetchUsers(request: UsersRequest, automatic: Bool = false) {
        let wasRefresh = isRefresh
        // A page after the first, asked for by scrolling: its failure keeps today's handling.
        let isLoadMore = !wasRefresh && !users.isEmpty
        offlineError = .none
        connectToSearch = false
        var cachedKeys = Set<String>()
        // The cached rows are applied on a later main-queue turn (`groupUsers`), so the error phase
        // cannot rely on `users` alone to know rows are on screen.
        var cachedShown = false
        let key: (User) -> String? = { $0.uid }

        service.fetchUsersTwoPhase(request: request, onCached: { [weak self] page in
            guard let this = self, !page.isEmpty else { return }
            cachedKeys = Set(page.compactMap(key))
            cachedShown = true
            let flat = this.users.flatMap { $0 }
            let next = wasRefresh ? SnapshotRows.startRefresh(current: flat, cachedPage: page)
                                  : SnapshotRows.paintCached(current: flat, cachedPage: page, key: key)
            this.offlineRegroup(next)
        }, onServer: { [weak self] page in
            guard let this = self else { return }
            // Only an empty server page ends paging (UIK-READ-03): a short page says nothing.
            if page.isEmpty { this.isFetchedAll = true }
            let flat = this.users.flatMap { $0 }
            this.offlineRegroup(SnapshotRows.reconcile(current: flat, cachedKeys: cachedKeys, serverPage: page, key: key))
            if wasRefresh { this.isRefresh = false }
            this.isFetching = false
        }, onError: { [weak self] error in
            guard let this = self else { return }
            this.isFetching = false
            if wasRefresh { this.isRefresh = false }
            let rowsShown = cachedShown || !this.users.isEmpty
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

    /// Replace the list's sections in one step.
    ///
    /// `groupUsers` appends to the sections it finds and commits them on a later main-queue turn, so
    /// emptying `users` first left the list reading as empty while it was still on screen. A read
    /// that failed inside that window was judged "nothing on screen", so a not-connected
    /// pull-to-refresh reported `onError` and drew "Connect to load users" over rows the user could
    /// see, against D84 rule 2. Grouping here and assigning once removes the window; the grouping
    /// itself is what `groupUsers` does from an empty list.
    private func offlineRegroup(_ flat: [User]) {
        users = UsersViewModel.offlineSections(from: flat)
        reload?()
    }

    /// `groupUsers`'s sectioning, as a value: a row joins the last section when its name starts with
    /// the same letter, else it opens a new one (the list is read in name order).
    static func offlineSections(from users: [User]) -> [[User]] {
        var sections: [[User]] = []
        for user in users {
            if let last = sections.last?.first?.name?.first,
               user.name?.first?.lowercased() == last.lowercased() {
                sections[sections.count - 1].append(user)
            } else {
                sections.append([user])
            }
        }
        return sections
    }
}

// MARK: - Hub events

extension UsersViewModel: OfflineHubObserver {

    /// Logout, user switch or cache reset: no row of the old session survives.
    func offlineSessionChanged(gen: Int) {
        users = []
        offlineError = .none
        connectToSearch = false
        searchFailedOffline = false
        searchReloadOnConnect = false
        filteredUsers = []
        isFetching = false
        isFetchedAll = false
        reload?()
    }

    /// The cache was rebuilt: read the first page again, two-phase.
    func offlineCacheReset(_ event: OfflineCacheResetEvent) {
        guard event.gen == OfflineHub.shared.gen else { return }
        // The kit's own reload: it fails quietly over rows on screen.
        automaticRefetch = true
        isRefresh = true
    }

    /// A user logged in (a token refresh keeps the cache): reload what was cleared.
    func offlineSessionStarted(gen: Int) {
        guard users.isEmpty, gen == OfflineHub.shared.gen else { return }
        isRefresh = true
    }
}
