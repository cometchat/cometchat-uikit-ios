//
//  GroupsViewModel.swift
 
//
//  Created by Pushpsen Airekar on 17/11/22.
//

import Foundation
import CometChatSDK

protocol GroupsViewModelProtocol {

    var row: Int { get set }
    var isSearching: Bool { get set }
    var groups: [CometChatSDK.Group] { get set }
    var filteredGroups: [CometChatSDK.Group] { get set }
    var selectedGroups: [CometChatSDK.Group] { get set }
    var groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder { get set }

    var reload: (() -> Void)? { get set }
    var reloadAt: ((Int) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var hasJoined : ((Group) -> Void)?  { get set }

    func fetchGroups()
    func filterGroups(text: String)
    func joinGroup(withGuid: String, name: String, groupType: CometChat.GroupType, password: String, indexPath: IndexPath, completion: @escaping (_ joinedGroup: Group?) -> Void)
}


open class GroupsViewModel: NSObject, GroupsViewModelProtocol {
    /// Seam over the listener registries, so `connect()`/`disconnect()` symmetry is
    /// assertable without a live SDK. Defaults to the real registrar.
    internal var listeners: ListenerRegistering = SDKListenerRegistrar.shared

    
    var row: Int = 0 {
        didSet {
            reloadAt?(row)
        }
    }

    var groups: [Group] = [] {
        didSet {
            reload?()
        }
    }

    var filteredGroups: [Group] = [] {
        didSet {
            reload?()
        }
    }

    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                self.fetchGroups()
            }
        }
    }

    /// Offline ON: set by `connected()` just before the refetch it triggers, so a failure of that
    /// automatic read stays quiet while rows are on screen. Read and cleared at the start of the next fetch.
    var automaticRefetch = false
    var isFetching = false
    var isFetchedAll = false
    /// Distinct per list, so two mounted lists never evict each other's hub registration.
    let offlineListenerID = UUID().uuidString

    /// Moves on every keyword search and when the search is cleared. A search answer that carries an
    /// older value is for a keyword no longer shown, and is dropped (a slow old search replaced the new one).
    internal var searchGeneration = 0
    var isSearching: Bool = false {
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
    var searchText: String { return searchingText }
    /// Offline ON: why the offline state or error view is showing over nothing. Cleared when the next
    /// read starts.
    var offlineError: OfflineListError = .none
    /// Offline ON (D84 rule 7): a keyword read could not reach the server and nothing is shown:
    /// "Connect to search", no `onError`. A filter alone is no keyword (addition B).
    var connectToSearch = false
    /// Offline ON (D84 rule 3): the plain list could not load for want of a connection and nothing is
    /// shown: "Connect to load groups" (the app's error view, if it set one), `onError` once.
    var connectToLoad: Bool { return offlineError == .notConnected && !connectToSearch }
    /// Offline ON: the newest read; callbacks of an older read, or of an older session, are dropped.
    var offlineReadToken = 0
    /// Asks whether offline is on for this search (`OfflineGate.isOn`, read once per search). A seam so
    /// a test can force the offline path for this one view model.
    internal var offlineGate: () -> Bool = { OfflineGate.isOn() }
    private var searchingText: String = ""
    var selectedGroups: [CometChatSDK.Group] = []
    var groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder
    private var filterGroupsRequestBuilder: GroupsRequest.GroupsRequestBuilder?
    private var groupsRequest: GroupsRequest?
    private var filterGroupsRequest: GroupsRequest?
    
    var reload: (() -> Void)?
    var reloadAt: ((Int) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var hasJoined: ((CometChatSDK.Group) -> Void)?
    
    /// Seam over the non-hermetic SDK request/response calls. Defaults to the live
    /// SDK-backed implementation so existing callers are unaffected; tests inject a fake.
    internal var service: GroupsServicing

    init(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder) {
        self.groupsRequestBuilder = groupsRequestBuilder
        self.groupsRequest = groupsRequestBuilder.build()
        self.service = LiveGroupsService()
        super.init()
    }

    /// Test/internal seam: inject a custom service.
    internal init(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder,
                  service: GroupsServicing) {
        self.groupsRequestBuilder = groupsRequestBuilder
        self.groupsRequest = groupsRequestBuilder.build()
        self.service = service
        super.init()
    }
    
    func reloadGroups() {
        groupsRequest = groupsRequestBuilder.build()
        groups.removeAll()
        fetchGroups()
    }
    
    public func set(searchRequestBuilder: GroupsRequest.GroupsRequestBuilder) {
        self.filterGroupsRequestBuilder = searchRequestBuilder
        self.filterGroupsRequest = self.filterGroupsRequestBuilder!.build()
    }
    
    func fetchGroups() {
        let automatic = automaticRefetch
        automaticRefetch = false
        if isRefresh {
            isFetchedAll = false
            groupsRequestBuilder = GroupsBuilder.getDefaultRequestBuilder()
            groupsRequest = groupsRequestBuilder.build()
        }
        
        guard let groupsRequest = groupsRequest else { return }
        if isFetchedAll { return }

        let alreadyFetching = isFetching
        isFetching =  true
        // Offline ON (read once for this read): two phases, cached then server.
        if offlineGate() {
            // The SDK answers a read made during another on this request with an empty page, which
            // is not the end of the list (BEH-SNAP-14). The read in flight delivers the page.
            if alreadyFetching && !isRefresh { return }
            offlineFetchGroups(request: groupsRequest, automatic: automatic)
            return
        }
        service.fetchGroups(request: groupsRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedGroups):
                if fetchedGroups.isEmpty {
                    this.isFetchedAll = true
                }
                
                if this.isRefresh {
                    this.groups.removeAll()
                    this.groups = fetchedGroups
                } else {
                    this.groups.append(contentsOf: fetchedGroups)
                }
                this.isFetching = false
                this.reload?()
            case .failure(let error):
                this.failure?(error)
                this.isFetching = false
            }
        }
    }
    
    func filterGroups(text: String) {
        self.searchingText = text
        self.filterGroupsRequest = self.groupsRequestBuilder.set(searchKeyword: text).build()
        guard let filterGroupsRequest = filterGroupsRequest else { return }
        searchGeneration &+= 1
        let generation = searchGeneration
        searchFailedOffline = false
        searchReloadOnConnect = false
        // Offline ON (read once for this search): a keyword has no cache, so only the server's phase
        // counts. Not reaching it is "Connect to search", no `onError` (D84 rule 7), and the search runs
        // again once on reconnect. Any other failure is an error (rows of an older search stay, rule 5).
        if offlineGate() {
            let keyword = OfflineReadFailure.isKeyword(text)
            service.fetchGroupsTwoPhase(request: filterGroupsRequest, onCached: { _ in }, onServer: { [weak self] page in
                guard let this = self, generation == this.searchGeneration else { return }
                this.connectToSearch = false
                this.filteredGroups = page
            }, onError: { [weak self] error in
                guard let this = self, generation == this.searchGeneration else { return }
                let notConnected = OfflineErrors.isNotConnected(code: error?.errorCode)
                // Rows of an older keyword never stand in for a search that could not run.
                let rowsShown = !this.filteredGroups.isEmpty && !(notConnected && keyword)
                let verdict = OfflineReadFailure.evaluate(error, rowsShown: rowsShown, keywordSearch: keyword, kitStarted: false)
                this.searchFailedOffline = true
                this.searchReloadOnConnect = notConnected
                this.connectToSearch = verdict.screen == .connectToSearch
                if notConnected && keyword { this.filteredGroups = [] }
                if verdict.reportsError, let error = error { this.failure?(error) }
            })
            return
        }
        service.fetchFilteredGroups(request: filterGroupsRequest) { [weak self] result in
            guard let this = self, generation == this.searchGeneration else { return }
            switch result {
            case .success(let filteredGroups):
                this.filteredGroups = filteredGroups
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    /// Whether a failure just reported leaves nothing on screen, so the error view shows. Offline ON, a
    /// failed search is judged on the search's own rows; otherwise on the list's.
    var failureLeavesNothing: Bool {
        return searchFailedOffline && isSearching ? filteredGroups.isEmpty : groups.isEmpty
    }

    /// Offline ON: the reconnect leaves the list alone while its error view is for a non-network error.
    var skipsReconnectReload: Bool {
        return offlineGate() && offlineError.skipsReconnectReload
    }

    func joinGroup(withGuid: String, name: String, groupType: CometChat.GroupType, password: String, indexPath: IndexPath, completion: @escaping (_ joinedGroup: Group?) -> Void) {
        service.joinGroup(guid: withGuid, groupType: groupType, password: password, onSuccess: { [weak self] (joinedGroup) in
            guard let this = self else { return }
            this.hasJoined?(joinedGroup)
            if let user = this.service.loggedInUser() {
                CometChatGroupEvents.ccGroupMemberJoined(joinedUser: user, joinedGroup: joinedGroup)
            }
            completion(joinedGroup)
        }, onError: { [weak self] error in
            guard let error = error, let this = self else { return }
            completion(nil)
            this.failure?(error)
        })
    }
    
    func connect() {
        // New.
        listeners.add(.groupSDK, id: "groups-groups-sdk-listener", listener: self)
        listeners.add(.groupEvents, id: "groups-groups-events-listener", listener: self)
        listeners.add(.offlineHub, id: "groups-offline-hub-listener-\(offlineListenerID)", listener: self as OfflineHubObserver)
    }
    
    func disconnect() {
        listeners.remove(.groupSDK, id: "groups-groups-sdk-listener")
        listeners.remove(.groupEvents, id: "groups-groups-events-listener")
        listeners.remove(.offlineHub, id: "groups-offline-hub-listener-\(offlineListenerID)")
    }

    @discardableResult
    func add(group: Group) -> Self {
        if self.groups.firstIndex(where: { $0.guid == group.guid }) == nil {
            self.groups.append(group)
        }
        return self
    }
    
    @discardableResult
    func insert(group: Group, at: Int) -> Self {
        if self.groups.firstIndex(where: { $0.guid == group.guid }) == nil {
            self.groups.insert(group, at: at)
        }
        return self
    }
    
    @discardableResult
    func update(group: Group) -> Self {
        if isSearching{
            if let index = filteredGroups.firstIndex(where: { $0.guid == group.guid }) {
                self.filteredGroups[index] = group
            }
        }else{
            if let index = groups.firstIndex(where: { $0.guid == group.guid }) {
                self.groups[index] = group
            }
        }
        return self
    }
    
    @discardableResult
    func remove(group: Group) -> Self {
        if let index = groups.firstIndex(where: { $0.guid == group.guid }) {
            self.groups.remove(at: index)
        }
        return self
    }
    
    @discardableResult
    func clearList() -> Self {
        self.groups.removeAll()
        return self
    }
    
    func size() -> Int {
        return self.groups.count
    }
}
