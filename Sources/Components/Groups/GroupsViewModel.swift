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
    func joinGroup(withGuid: String, name: String, groupType: CometChat.groupType, password: String, indexPath: IndexPath)
}


open class GroupsViewModel: NSObject, GroupsViewModelProtocol {
    
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
    
    var isSearching: Bool = false
    var selectedGroups: [CometChatSDK.Group] = []
    var groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder
    private var groupsRequest: GroupsRequest?
    private var filterGroupsRequest: GroupsRequest?
    
    var reload: (() -> Void)?
    var reloadAt: ((Int) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var hasJoined: ((CometChatSDK.Group) -> Void)?
    
    init(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder) {
        self.groupsRequestBuilder = groupsRequestBuilder
        self.groupsRequest = groupsRequestBuilder.build()
    }
    
    func fetchGroups() {
        guard let groupsRequest = groupsRequest else { return }
        GroupsBuilder.fetchGroups(groupRequest: groupsRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedGroups):
                this.groups += fetchedGroups
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func filterGroups(text: String) {
        self.filteredGroups.removeAll()
        self.filterGroupsRequest = self.groupsRequestBuilder.set(searchKeyword: text).build()
        guard let filterGroupsRequest = filterGroupsRequest else { return }
        GroupsBuilder.getfilteredGroups(filterGroupRequest: filterGroupsRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let filteredGroups):
                this.filteredGroups = filteredGroups
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    internal func joinGroup(withGuid: String, name: String, groupType: CometChat.groupType, password: String, indexPath: IndexPath) {
        CometChat.joinGroup(GUID: withGuid, groupType: groupType, password: password, onSuccess: { [weak self] (joinedGroup) in
            guard let this = self else { return }
            this.hasJoined?(joinedGroup)
            if let user = CometChat.getLoggedInUser() {
                CometChatGroupEvents.emitOnGroupMemberJoin(joinedUser: user, joinedGroup: joinedGroup)
            }
        }, onError: { [weak self] error in
            guard let error = error, let this = self else { return }
            this.failure?(error)
        })
    }
    
    func connect() {
        // New.
        CometChat.addGroupListener("groups-groups-sdk-listener", self)
        CometChatGroupEvents.addListener("groups-groups-events-listener", self)
    }
    
    func disconnect() {
        CometChat.removeGroupListener("groups-groups-sdk-listener")
        CometChatGroupEvents.removeListener("groups-groups-events-listener")
    }

    @discardableResult
    func add(group: Group) -> Self {
        if !self.groups.contains(obj: group) {
            self.groups.append(group)
        }
        return self
    }
    
    @discardableResult
    func insert(group: Group, at: Int) -> Self {
        if !self.groups.contains(obj: group) {
            self.groups.insert(group, at: at)
        }
        return self
    }
    
    @discardableResult
    func update(group: Group) -> Self {
        if let index = groups.firstIndex(of: group) {
            self.groups[index] = group
        }
        return self
    }
    
    @discardableResult
    func remove(group: Group) -> Self {
        if let index = groups.firstIndex(of: group) {
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
