//
//  CometChatUsersViewModel.swift
//  
//
//  Created by Abdullah Ansari on 20/11/22.
//

import Foundation
import CometChatSDK

protocol UsersViewModelProtocol {

    var reload: (() -> Void)? { get set }
    var reloadAtIndex: ((IndexPath) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var searchedUsers: [User] { get set }
    var filteredUsers: [User] { get set }
    var isSearching: Bool { get set }
    func fetchUsers()
    func filterUsers(text: String)
    var userRequestBuilder: UsersRequest.UsersRequestBuilder { get set }

}

public class UsersViewModel: UsersViewModelProtocol {
    
    var users: [[User]] = [[User]]()
    var reload: (() -> Void)?
    var reloadAtIndex: ((IndexPath) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var searchedUsers: [User] = []

    var filteredUsers: [User] = [] {
        didSet { reload?() }
    }
    var selectedUsers: [User] = []
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
    private(set) var searchText = ""
    /// Offline ON: why the offline state or error view is showing over nothing. Cleared when the next
    /// read starts.
    var offlineError: OfflineListError = .none
    /// Offline ON (D84 rule 7): a keyword read (the search box, or a list opened with a keyword) could
    /// not reach the server and nothing is shown: "Connect to search", no `onError`. A filter alone is
    /// no keyword (addition B).
    var connectToSearch = false
    /// Offline ON (D84 rule 3): the plain list could not load for want of a connection and nothing is
    /// shown: "Connect to load users" (the app's error view, if it set one), `onError` once.
    var connectToLoad: Bool { return offlineError == .notConnected && !connectToSearch }
    /// Asks whether offline is on for this search (`OfflineGate.isOn`, read once per search). A seam so
    /// a test can force the offline path for this one view model.
    internal var offlineGate: () -> Bool = { OfflineGate.isOn() }
    var userRequestBuilder: UsersRequest.UsersRequestBuilder
    var userRequest: UsersRequest?
    private var filterUserRequest: UsersRequest?
    /// Offline ON: set by `connected()` just before the refetch it triggers, so a failure of that
    /// automatic read stays quiet while rows are on screen. Read and cleared at the start of the next fetch.
    var automaticRefetch = false
    var isFetching = false
    var isFetchedAll = false
    /// Distinct per list, so two mounted lists never evict each other's hub registration.
    let offlineListenerID = UUID().uuidString
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                self.fetchUsers()
            }
        }
    }
    
    /// Seam over the non-hermetic SDK request/response calls. Defaults to the live
    /// SDK-backed implementation so existing callers are unaffected; tests inject a fake.
    internal var service: UsersServicing

    /// Seam over the listener registries, so `connect()`/`disconnect()` symmetry is
    /// assertable without a live SDK. Defaults to the real registrar.
    internal var listeners: ListenerRegistering

    init(userRequestBuilder: UsersRequest.UsersRequestBuilder) {
        self.userRequestBuilder = userRequestBuilder
        self.userRequest = userRequestBuilder.build()
        self.service = LiveUsersService()
        self.listeners = SDKListenerRegistrar.shared
    }

    /// Test/internal seam: inject a custom service.
    internal init(userRequestBuilder: UsersRequest.UsersRequestBuilder,
                  service: UsersServicing,
                  listeners: ListenerRegistering = SDKListenerRegistrar.shared) {
        self.userRequestBuilder = userRequestBuilder
        self.userRequest = userRequestBuilder.build()
        self.service = service
        self.listeners = listeners
    }
    
    public func setRequestBuilder(userRequestBuilder: UsersRequest.UsersRequestBuilder) {
        self.userRequestBuilder = userRequestBuilder
        self.userRequest = self.userRequestBuilder.build()
    }
    
    func fetchUsers() {
        let automatic = automaticRefetch
        automaticRefetch = false
        if isRefresh {
            isFetchedAll = false
            userRequest = userRequestBuilder.build()
        }

        guard let userRequest = userRequest else { return }
        if isFetchedAll { return }

        let alreadyFetching = isFetching
        isFetching =  true

        // Offline ON (read once for this read): two phases, cached then server.
        if offlineGate() {
            // The SDK answers a read made during another on this request with an empty page, which
            // is not the end of the list (BEH-SNAP-14). The read in flight delivers the page.
            if alreadyFetching && !isRefresh { return }
            offlineFetchUsers(request: userRequest, automatic: automatic)
            return
        }

        service.fetchUsers(request: userRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedUsers):
                if fetchedUsers.isEmpty {
                    this.isFetchedAll = true
                } else {
                    if this.isRefresh {
                        this.users.removeAll()
                        this.isRefresh = false
                    }
                    this.isFetchedAll = fetchedUsers.count < userRequest.limit
                }
                this.isFetching = false
                this.groupUsers(users: fetchedUsers)
            case .failure(let error):
                this.failure?(error)
                this.isFetching = false
            }
        }
    }

    
   
    func groupUsers(users: [User]){
        
        var staticUsers: [[User]] = self.users
        for index in 0..<users.count {
            let lastCharter = staticUsers.last?.first?.name?.first
            let user = users[index]
            
            if let lastCharter = lastCharter {
                if user.name?.first?.lowercased() == lastCharter.lowercased() {
                    staticUsers[staticUsers.count - 1].append(user)
                } else {
                    staticUsers.append([user])
                }
            } else {
                staticUsers.append([user])
            }
        }

        DispatchQueue.main.async {
            self.users.removeAll()
            self.users = staticUsers
            self.reload?()
        }
    }
    
    func filterUsers(text: String) {
        self.filterUserRequest = self.userRequestBuilder.set(searchKeyword: text).build()
        guard let filterUserRequest = filterUserRequest else { return }
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
            service.fetchUsersTwoPhase(request: filterUserRequest, onCached: { _ in }, onServer: { [weak self] page in
                guard let this = self, generation == this.searchGeneration else { return }
                this.connectToSearch = false
                this.filteredUsers = page
            }, onError: { [weak self] error in
                guard let this = self, generation == this.searchGeneration else { return }
                let notConnected = OfflineErrors.isNotConnected(code: error?.errorCode)
                // Rows of an older keyword never stand in for a search that could not run.
                let rowsShown = !this.filteredUsers.isEmpty && !(notConnected && keyword)
                let verdict = OfflineReadFailure.evaluate(error, rowsShown: rowsShown, keywordSearch: keyword, kitStarted: false)
                this.searchFailedOffline = true
                this.searchReloadOnConnect = notConnected
                this.connectToSearch = verdict.screen == .connectToSearch
                if notConnected && keyword { this.filteredUsers = [] }
                if verdict.reportsError, let error = error { this.failure?(error) }
            })
            return
        }
        service.fetchFilteredUsers(request: filterUserRequest) { [weak self] result in
            guard let this = self, generation == this.searchGeneration else { return }
            switch result {
            case .success(let filteredUser):
                this.filteredUsers = filteredUser
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    /// Whether a failure just reported leaves nothing on screen, so the error view shows. Offline ON, a
    /// failed search is judged on the search's own rows; otherwise on the list's.
    var failureLeavesNothing: Bool {
        return searchFailedOffline && isSearching ? filteredUsers.isEmpty : users.isEmpty
    }

    /// Offline ON: the reconnect leaves the list alone while its error view is for a non-network error.
    var skipsReconnectReload: Bool {
        return offlineGate() && offlineError.skipsReconnectReload
    }

    func connect() {
        listeners.add(.userSDK, id: UsersListenerConstants.userListener, listener: self)
        listeners.add(.userEvents, id: "user-listener", listener: self)
        listeners.add(.offlineHub, id: "users-offline-hub-listener-\(offlineListenerID)", listener: self as OfflineHubObserver)
    }

    func disconnect() {
        listeners.remove(.userSDK, id: UsersListenerConstants.userListener)
        listeners.remove(.userEvents, id: "user-listener")
        listeners.remove(.offlineHub, id: "users-offline-hub-listener-\(offlineListenerID)")
    }
    
    func getIndexPath(for user: User) -> IndexPath? {
        for (section, users) in users.enumerated() {
            for (row, currentUser) in users.enumerated() {
                if currentUser.uid == user.uid {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }
    
}

extension UsersViewModel {
    
    @discardableResult
    func add(user: User) -> Self {
        if !self.users.contains(obj: user) {
            self.users[0].insert(user, at: 0)
            self.reload?()
        }
        return self
    }
    
    @discardableResult
    func update(user: User) -> Self {

        if let indexPath = getIndexPath(for: user) {
            self.users[indexPath.section][indexPath.row] = user
            self.reloadAtIndex?(indexPath)
        }
        
        return self
    }
    
    @discardableResult
    public func remove(user: User) -> Self {
        if let indexPath = getIndexPath(for: user) {
            self.users[indexPath.section].remove(at: indexPath.row)
            self.reload?()
        }
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        self.users.removeAll()
        self.reload?()
        return self
    }
    
    public func size() -> Int {
        return self.users.count
    }
    
}
