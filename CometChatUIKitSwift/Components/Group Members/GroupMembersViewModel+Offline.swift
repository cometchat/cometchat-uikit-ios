//
//  GroupMembersViewModel+Offline.swift
//  CometChatUIKitSwift
//
//  The offline (ON) read of the members list: cached page first, the server's page replaces the
//  same slice (a member the server no longer lists is removed). A failed read follows D84
//  (`OfflineReadFailure`): rows stay and a not-connected failure reports nothing; nothing on screen is
//  "Connect to load members" (or "Connect to search" for a keyword) when not connected, the error view
//  otherwise. The refresh after a reconnect is the kit's own and stays quiet. Reached only after the
//  caller read `OfflineGate.isOn()` for this read.
//

import Foundation
import CometChatSDK

extension GroupMembersViewModel {

    func offlineFetchMembers(request: GroupMembersRequest) {
        // A page after the first, asked for by scrolling: its failure keeps today's handling.
        let isLoadMore = !groupMembers.isEmpty
        offlineError = .none
        connectToSearch = false
        var cachedKeys = Set<String>()
        let key: (GroupMember) -> String? = { $0.uid }
        // As the conversation list: a late answer of an older read or session never reaches the list.
        offlineReadToken += 1
        let token = offlineReadToken
        let hubGen = OfflineHub.shared.gen
        let isCurrent: (GroupMembersViewModel) -> Bool = { $0.offlineReadToken == token && OfflineHub.shared.gen == hubGen }

        service.fetchGroupMembersTwoPhase(request: request, onCached: { [weak self] page in
            guard let this = self, isCurrent(this), !page.isEmpty else { return }
            cachedKeys = Set(page.compactMap(key))
            this.groupMembers = SnapshotRows.paintCached(current: this.groupMembers, cachedPage: page, key: key)
        }, onServer: { [weak self] page in
            guard let this = self, isCurrent(this) else { return }
            this.isFetchingMembers = false
            if page.isEmpty { this.isFetchedAll = true }
            this.groupMembers = SnapshotRows.reconcile(current: this.groupMembers, cachedKeys: cachedKeys, serverPage: page, key: key)
        }, onError: { [weak self] error in
            guard let this = self, isCurrent(this) else { return }
            this.isFetchingMembers = false
            let rowsShown = !this.groupMembers.isEmpty
            if isLoadMore {
                // Paging waits for the connection quietly; the footer is not this rule's.
                if OfflineErrors.isNotConnected(code: error?.errorCode) { return }
                if let error = error { this.failure?(error) }
                return
            }
            // Rows on screen stay; nothing on screen is the offline state or the error view. Only an
            // online failure of a load the user or app started reaches `onError` over rows.
            let verdict = OfflineReadFailure.evaluate(error, rowsShown: rowsShown,
                                                      keywordSearch: OfflineReadFailure.isKeyword(request.searchKeyword), kitStarted: false)
            this.offlineError = OfflineListError.afterFailure(error, rowsShown: rowsShown)
            this.connectToSearch = verdict.screen == .connectToSearch
            if verdict.reportsError, let error = error {
                this.failure?(error)
            } else {
                // No callback to draw "Connect to search" or end a spinner: redraw.
                this.reload?()
            }
        })
    }

    /// The first page again after a reconnect (README 3.7): the cached page updates the rows it has,
    /// then the server's does. Never blanks the list, and a failed refresh changes nothing. A member
    /// the cached page had and the server's no longer has was removed while away.
    func offlineRefreshMembers(request: GroupMembersRequest) {
        var cachedKeys = Set<String>()
        let key: (GroupMember) -> String? = { $0.uid }
        // As the conversation list: a late answer of an older read or session never reaches the list.
        offlineReadToken += 1
        let token = offlineReadToken
        let hubGen = OfflineHub.shared.gen
        let isCurrent: (GroupMembersViewModel) -> Bool = { $0.offlineReadToken == token && OfflineHub.shared.gen == hubGen }

        service.fetchGroupMembersTwoPhase(request: request, onCached: { [weak self] page in
            guard let this = self, isCurrent(this), !page.isEmpty else { return }
            cachedKeys = Set(page.compactMap(key))
            this.groupMembers = SnapshotRows.mergeInPlace(current: this.groupMembers, page: page, key: key)
        }, onServer: { [weak self] page in
            guard let this = self, isCurrent(this) else { return }
            this.isFetchingMembers = false
            let gone = page.isEmpty ? [] : cachedKeys.subtracting(page.compactMap(key))
            this.groupMembers = SnapshotRows.mergeInPlace(current: this.groupMembers, page: page, gone: gone, key: key)
        }, onError: { [weak self] _ in
            guard let this = self, isCurrent(this) else { return }
            this.isFetchingMembers = false
        })
    }
}

extension GroupMembersViewModel {

    /// Logout, user switch or cache reset: no member of the old session survives.
    func offlineClearForSession() {
        offlineError = .none
        connectToSearch = false
        groupMembers = []
        searchFailedOffline = false
        searchReloadOnConnect = false
        filteredGroupMembers = []
        isFetchingMembers = false
        isFetchedAll = false
    }
}
