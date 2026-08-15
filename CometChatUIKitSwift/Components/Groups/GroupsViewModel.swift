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
    func joinGroup(withGuid: String, name: String, groupType: CometChat.groupType, password: String, indexPath: IndexPath, completion: @escaping (_ joinedGroup: Group?) -> Void)
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

    var isFetching = false
    var isFetchedAll = false

    var isSearching: Bool = false
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
        
        if isRefresh {
            isFetchedAll = false
            groupsRequestBuilder = GroupsBuilder.getDefaultRequestBuilder()
            groupsRequest = groupsRequestBuilder.build()
        }
        
        guard let groupsRequest = groupsRequest else { return }
        if isFetchedAll { return }
        
        isFetching =  true
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
        service.fetchFilteredGroups(request: filterGroupsRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let filteredGroups):
                this.filteredGroups = filteredGroups
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func joinGroup(withGuid: String, name: String, groupType: CometChat.groupType, password: String, indexPath: IndexPath, completion: @escaping (_ joinedGroup: Group?) -> Void) {
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
    }
    
    func disconnect() {
        listeners.remove(.groupSDK, id: "groups-groups-sdk-listener")
        listeners.remove(.groupEvents, id: "groups-groups-events-listener")
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
