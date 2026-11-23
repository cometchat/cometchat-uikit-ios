//
//  GroupMembersViewModel.swift
 
//
//  Created by Pushpsen Airekar on 17/11/22.
//

import Foundation
import CometChatSDK

open class GroupMembersViewModel: NSObject {
    /// Seam over the listener registries, so `connect()`/`disconnect()` symmetry is
    /// assertable without a live SDK. Defaults to the real registrar.
    internal var listeners: ListenerRegistering = SDKListenerRegistrar.shared

    
    public var row: Int = 0 {
        didSet {
            reloadAt?(row)
        }
    }
    
    public var groupMembers: [CometChatSDK.GroupMember] = [] {
        didSet {
            reload?()
        }
    }
    
    public var filteredGroupMembers: [CometChatSDK.GroupMember] = [] {
        didSet {
            reload?()
        }
    }
    
    public var group: CometChatSDK.Group!
    /// Moves on every keyword search and when the search is cleared. A search answer that carries an
    /// older value is for a keyword no longer shown, and is dropped (a slow old search replaced the new one).
    internal var searchGeneration = 0
    public var isSearching: Bool = false {
        didSet {
            if !isSearching {
                searchGeneration &+= 1
                // "Connect to search" of the search box goes with the search.
                if searchFailedOffline { connectToSearch = false }
                searchFailedOffline = false
                searchReloadOnConnect = false
            }
        }
    }
    /// Offline ON: the last keyword search failed (any error).
    var searchFailedOffline = false
    /// Offline ON: the last keyword search failed because the SDK is not connected; the reconnect
    /// runs it again, once.
    var searchReloadOnConnect = false
    /// The keyword of the last search, for that one run on reconnect.
    private(set) var searchText = ""
    /// Offline ON: why the offline state or error view is showing over nothing. Cleared when the next
    /// read starts.
    var offlineError: OfflineListError = .none
    /// Offline ON (D84 rule 7): a keyword read could not reach the server and nothing is shown:
    /// "Connect to search", no `onError`. A filter alone (a scope, banned members) is no keyword
    /// (addition B).
    var connectToSearch = false
    /// Offline ON (D84 rule 3): the plain list could not load for want of a connection and nothing is
    /// shown: "Connect to load members" (the app's error view, if it set one), `onError` once.
    var connectToLoad: Bool { return offlineError == .notConnected && !connectToSearch }
    /// Offline ON: the newest read; callbacks of an older read, or of an older session, are dropped.
    var offlineReadToken = 0
    public var selectedGroupMembers: [CometChatSDK.GroupMember] = []
    public var groupMembersRequestBuilder: CometChatSDK.GroupMembersRequest.GroupMembersRequestBuilder!
    
    private var groupsMembersRequest: GroupMembersRequest?
    private var filterGroupMembersRequest: GroupMembersRequest?
    private var filterGroupMembersRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder?
    public var isFetchedAll = false
    public var listenerRandomID = Date().timeIntervalSince1970
    
    public var reload: (() -> Void)?
    public var reloadAt: ((Int) -> Void)?
    public var failure: ((CometChatSDK.CometChatException) -> Void)?
    /// Failures of a ban, kick or scope change. These leave the list untouched, so the
    /// screen reports them without the full-screen error view. Falls back to `failure`
    /// when unset.
    var actionFailure: ((CometChatSDK.CometChatException) -> Void)?
    
    /// True while a page request is in flight, so repeated load-more triggers
    /// (every willDisplay of the last row) do not stack duplicate requests.
    var isFetchingMembers = false
    
    /// Seam over the non-hermetic SDK request/response calls. Defaults to the live
    /// SDK-backed implementation so existing callers are unaffected; tests inject a fake.
    internal var service: GroupMembersServicing

    public override init() {
        self.service = LiveGroupMembersService()
        super.init()
    }

    /// Test/internal seam: inject a custom service.
    internal init(service: GroupMembersServicing) {
        self.service = service
        super.init()
    }
    
    /// Asks whether offline is on for this read (`OfflineGate.isOn`, read once per read). A seam so a
    /// test can force the offline path for this one view model.
    internal var offlineGate: () -> Bool = { OfflineGate.isOn() }

    func connect() {
        listeners.add(.groupSDK, id: "group-members-groups-sdk-listner-\(listenerRandomID)", listener: self)
        listeners.add(.groupEvents, id: "group-members-groups-event-listner-\(listenerRandomID)", listener: self)
        listeners.add(.offlineHub, id: "group-members-offline-hub-listener-\(listenerRandomID)", listener: self as OfflineHubObserver)
    }

    func disconnect() {
        listeners.remove(.groupSDK, id: "group-members-groups-sdk-listner-\(listenerRandomID)")
        listeners.remove(.groupEvents, id: "group-members-groups-event-listner-\(listenerRandomID)")
        listeners.remove(.offlineHub, id: "group-members-offline-hub-listener-\(listenerRandomID)")
    }
    
    public func set(group: Group) {
        self.group = group
        if self.groupMembersRequestBuilder == nil {
            self.groupMembersRequestBuilder = GroupMembersBuilder.getSharedBuilder(for: group)
            self.groupsMembersRequest = groupMembersRequestBuilder.build()
        }
    }
    
    public func set(groupMembersRequestBuilder: CometChatSDK.GroupMembersRequest.GroupMembersRequestBuilder) {
        self.groupMembersRequestBuilder = groupMembersRequestBuilder
        self.groupsMembersRequest = self.groupMembersRequestBuilder.build()
    }
    
    public func set(searchGroupMembersRequestBuilder: CometChatSDK.GroupMembersRequest.GroupMembersRequestBuilder) {
        self.filterGroupMembersRequestBuilder = searchGroupMembersRequestBuilder
        self.filterGroupMembersRequest = self.filterGroupMembersRequestBuilder!.build()
    }
    
    public func fetchGroupsMembers() {
        guard let groupsMembersRequest = groupsMembersRequest, !isFetchingMembers else { return }
        isFetchingMembers = true
        // Offline ON (read once for this read): two phases, cached then server.
        if offlineGate() {
            offlineFetchMembers(request: groupsMembersRequest)
            return
        }
        service.fetchGroupMembers(request: groupsMembersRequest) { [weak self] result in
            guard let this = self else { return }
            this.isFetchingMembers = false
            switch result {
            case .success(let fetchedGroupMembers):
                if fetchedGroupMembers.isEmpty { this.isFetchedAll = true }
                // A repeated page must not list a member twice.
                var knownUids = Set(this.groupMembers.compactMap { $0.uid })
                let newMembers = fetchedGroupMembers.filter { member in
                    guard let uid = member.uid else { return true }
                    return knownUids.insert(uid).inserted
                }
                this.groupMembers += newMembers
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    /// Re-reads the first page after a reconnect and merges it into the members already shown, by uid.
    /// Never clears the list; members not in the page are left as they are.
    func refreshAfterReconnect() {
        guard let builder = groupMembersRequestBuilder, !isFetchingMembers else { return }
        isFetchingMembers = true
        // Offline ON (read once for this refresh): two phases, in place.
        if offlineGate() {
            offlineRefreshMembers(request: builder.build())
            return
        }
        service.fetchGroupMembers(request: builder.build()) { [weak self] result in
            guard let this = self else { return }
            this.isFetchingMembers = false
            guard case .success(let page) = result else { return }
            var merged = this.groupMembers
            for member in page {
                if let uid = member.uid, let index = merged.firstIndex(where: { $0.uid == uid }) {
                    merged[index] = member
                } else {
                    merged.append(member)
                }
            }
            this.groupMembers = merged
        }
    }

    /// Whether a failure just reported leaves nothing on screen, so the error view shows (the visible
    /// rows are the search's while it is on screen).
    var failureLeavesNothing: Bool {
        return (isSearching ? filteredGroupMembers : groupMembers).isEmpty
    }

    /// Offline ON: the reconnect leaves the list alone while its error view is for a non-network error.
    var skipsReconnectReload: Bool {
        return offlineGate() && offlineError.skipsReconnectReload
    }

    public func filterGroupMembers(text: String) {
        self.filterGroupMembersRequest = (self.filterGroupMembersRequestBuilder ?? self.groupMembersRequestBuilder)?.set(searchKeyword: text).build()
        guard let filterGroupMembersRequest = filterGroupMembersRequest else { return }
        searchGeneration &+= 1
        let generation = searchGeneration
        searchText = text
        searchFailedOffline = false
        searchReloadOnConnect = false
        // Offline ON (read once for this search): a keyword has no cache, so only the server's phase
        // counts. Not reaching it is "Connect to search", no `onError` (D84 rule 7), and the search runs
        // again once on reconnect. Any other failure is an error (rows of an older search stay, rule 5).
        if offlineGate() {
            let keyword = OfflineReadFailure.isKeyword(text)
            service.fetchGroupMembersTwoPhase(request: filterGroupMembersRequest, onCached: { _ in }, onServer: { [weak self] page in
                guard let this = self, generation == this.searchGeneration else { return }
                this.connectToSearch = false
                this.filteredGroupMembers = page
            }, onError: { [weak self] error in
                guard let this = self, generation == this.searchGeneration else { return }
                let notConnected = OfflineErrors.isNotConnected(code: error?.errorCode)
                // Rows of an older keyword never stand in for a search that could not run.
                let rowsShown = !this.filteredGroupMembers.isEmpty && !(notConnected && keyword)
                let verdict = OfflineReadFailure.evaluate(error, rowsShown: rowsShown, keywordSearch: keyword, kitStarted: false)
                this.searchFailedOffline = true
                this.searchReloadOnConnect = notConnected
                this.connectToSearch = verdict.screen == .connectToSearch
                if notConnected && keyword { this.filteredGroupMembers = [] }
                if verdict.reportsError, let error = error { this.failure?(error) }
            })
            return
        }
        service.fetchFilteredGroupMembers(request: filterGroupMembersRequest) { [weak self] result in
            guard let this = self, generation == this.searchGeneration else { return }
            switch result {
            case .success(let filteredGroupMembers):
                this.filteredGroupMembers = filteredGroupMembers
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func changeScope(for member: GroupMember, scope: CometChat.MemberScope) {
        service.changeScope(group: group, member: member, scope: scope) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let groupMember):
                // broadcasting groupMember's change scope events

                if let loggedInUser = CometChat.getLoggedInUser() {
                    let actionMessage = ActionMessage()
                    actionMessage.action = .scopeChanged
                    actionMessage.conversationId = "group_\(this.group.guid)"
                    actionMessage.message = "\(loggedInUser.name ?? "") made \(member.name ?? "") \(scope.toString())"
                    actionMessage.muid = "\(NSDate().timeIntervalSince1970)"
                    actionMessage.sender = loggedInUser
                    actionMessage.receiver = this.group
                    actionMessage.actionBy = loggedInUser
                    actionMessage.actionOn = member
                    actionMessage.receiverUid = this.group.guid
                    actionMessage.messageType = .groupMember
                    actionMessage.messageCategory = .action
                    actionMessage.receiverType = .group
                    actionMessage.newScope = groupMember.scope
                    actionMessage.sentAt = Int(Date().timeIntervalSince1970)
                    
                    CometChatGroupEvents.ccGroupMemberScopeChanged(action: actionMessage, updatedUser: groupMember, scopeChangedTo: scope.toString(), scopeChangedFrom: member.scope.toString(), group: this.group)
                }
                this.update(groupMember: groupMember)
            case .failure(let error):
                (this.actionFailure ?? this.failure)?(error)
            }
        }
    }
    
    func banGroupMember(group: Group, member: GroupMember) {
        service.banGroupMember(group: group, member: member) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let groupMember):
                group.membersCount = group.membersCount - 1
                this.remove(groupMember: groupMember)
                CometChatLogger.debug("scope of GroupMember \(groupMember.scope)")
                // broadcasting groupmember's ban event.
                if let loggedInUser = LoggedInUserInformation.getUser() {

                    let actionMessage = ActionMessage()
                    actionMessage.action = .banned
                    actionMessage.conversationId = "group_\(this.group.guid)"
                    actionMessage.message = "\(loggedInUser.name ?? "") banned \(member.name ?? "")"
                    actionMessage.muid = "\(NSDate().timeIntervalSince1970)"
                    actionMessage.sender = loggedInUser
                    actionMessage.receiver = this.group
                    actionMessage.receiverUid = this.group.guid
                    actionMessage.messageType = .groupMember
                    actionMessage.actionBy = loggedInUser
                    actionMessage.actionOn = member
                    actionMessage.messageCategory = .action
                    actionMessage.receiverType = .group
                    actionMessage.sentAt = Int(Date().timeIntervalSince1970)
                    
                    CometChatGroupEvents.ccGroupMemberBanned(action: actionMessage, bannedUser: groupMember, bannedBy: loggedInUser, bannedFrom: group)
                    
            }
            case .failure(let error):
                (this.actionFailure ?? this.failure)?(error)
            }
        }
    }
    
    func kickGroupMember(group: Group, member: GroupMember) {
        service.kickGroupMember(group: group, member: member) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let groupMember):
                group.membersCount = group.membersCount - 1
                this.remove(groupMember: groupMember)

                if let loggedInUser = LoggedInUserInformation.getUser() {

                   let actionMessage = ActionMessage()
                   actionMessage.action = .kicked
                   actionMessage.conversationId = "group_\(this.group.guid)"
                   actionMessage.message = "\(loggedInUser.name ?? "") Kicked \(member.name ?? "")"
                   actionMessage.muid = "\(NSDate().timeIntervalSince1970)"
                   actionMessage.sender = loggedInUser
                   actionMessage.receiver = this.group
                   actionMessage.receiverUid = this.group.guid
                   actionMessage.messageType = .groupMember
                   actionMessage.messageCategory = .action
                   actionMessage.actionBy = loggedInUser
                   actionMessage.actionOn = member
                   actionMessage.receiverType = .group
                   actionMessage.sentAt = Int(Date().timeIntervalSince1970)
                                      
                   CometChatGroupEvents.ccGroupMemberKicked(action: actionMessage, kickedUser: member, kickedBy: loggedInUser, kickedFrom: group)
                }
            case .failure(let error):
                (this.actionFailure ?? this.failure)?(error)
            }
        }
    }
    
    @discardableResult
    public func add(groupMember: GroupMember) -> Self {
        self.groupMembers.append(groupMember)
        return self
    }
    
    @discardableResult
    public func update(groupMember: GroupMember) -> Self {
        if let row = self.groupMembers.firstIndex(where: {$0.uid == groupMember.uid}) {
            self.groupMembers[row] = groupMember
        }
        return self
    }
    
    @discardableResult
    public func insert(groupMember: GroupMember, at: Int) -> Self {
        self.groupMembers.insert(groupMember, at: at)
        return self
    }
    
    @discardableResult
    public func remove(groupMember: GroupMember) -> Self {
        if let index = groupMembers.firstIndex(of: groupMember) {
            self.groupMembers.remove(at: index)
        }
        // A member no longer in the list must not stay selected.
        selectedGroupMembers.removeAll(where: { $0 === groupMember || ($0.uid != nil && $0.uid == groupMember.uid) })
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        self.groupMembers.removeAll()
        self.selectedGroupMembers.removeAll()
        return self
    }
    
    public func size() -> Int {
        return self.groupMembers.count
    }
}

// MARK: - Offline hub

extension GroupMembersViewModel: OfflineHubObserver {

    /// A swept kick / ban / leave / join of this group runs the live handlers (UIT-SYNC-13).
    func offlineMessageSyncCompleted(_ event: OfflineMessageSyncEvent) {
        guard event.gen == OfflineHub.shared.gen else { return }
        SweptGroupAction.replay(event.messages, forGroup: group?.guid, to: self)
    }

    func offlineSessionChanged(gen: Int) {
        offlineClearForSession()
    }

    /// The cache was rebuilt: read the members again from the first page, two-phase.
    func offlineCacheReset(_ event: OfflineCacheResetEvent) {
        guard event.gen == OfflineHub.shared.gen, let builder = groupMembersRequestBuilder else { return }
        offlineClearForSession()
        groupsMembersRequest = builder.build()
        fetchGroupsMembers()
    }
}
