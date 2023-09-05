//
//  GroupMembersViewModel.swift
 
//
//  Created by Pushpsen Airekar on 17/11/22.
//

import Foundation
import CometChatSDK

protocol GroupMembersViewModelProtocol {
    
    var row: Int { get set }
    var isSearching: Bool { get set }
    var group: CometChatSDK.Group { get set }
    var groupMembers: [CometChatSDK.GroupMember] { get set }
    var filteredGroupMembers: [CometChatSDK.GroupMember] { get set }
    var selectedGroupMembers: [ CometChatSDK.GroupMember] { get set }
    var groupMembersRequestBuilder: CometChatSDK.GroupMembersRequest.GroupMembersRequestBuilder { get set }
    
    var reload: (() -> Void)? { get set }
    var reloadAt: ((Int) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    
    func fetchGroupsMembers()
    func filterGroupMembers(text: String)
}


open class GroupMembersViewModel: NSObject, GroupMembersViewModelProtocol {
    
    var row: Int = 0 {
        didSet {
            reloadAt?(row)
        }
    }
    
    var groupMembers: [CometChatSDK.GroupMember] = [] {
        didSet {
            reload?()
        }
    }
    
    var filteredGroupMembers: [CometChatSDK.GroupMember] = [] {
        didSet {
            reload?()
        }
    }
    
    var group: CometChatSDK.Group
    var isSearching: Bool = false
    var selectedGroupMembers: [CometChatSDK.GroupMember] = []
    var groupMembersRequestBuilder: CometChatSDK.GroupMembersRequest.GroupMembersRequestBuilder
    
    private var groupsMembersRequest: GroupMembersRequest?
    private var filterGroupMembersRequest: GroupMembersRequest?
    
    var reload: (() -> Void)?
    var reloadAt: ((Int) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    
    init(group: Group, groupMembersRequestBuilder: CometChatSDK.GroupMembersRequest.GroupMembersRequestBuilder?) {
        self.group = group
        self.groupMembersRequestBuilder = groupMembersRequestBuilder ?? GroupMembersBuilder.getSharedBuilder(for: group)
        self.groupsMembersRequest = self.groupMembersRequestBuilder.build()
    }
    
    func fetchGroupsMembers() {
        guard let groupsMembersRequest = groupsMembersRequest else { return }
        GroupMembersBuilder.fetchGroupMembers(groupMemberRequest: groupsMembersRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedGroupMembers):
                this.groupMembers += fetchedGroupMembers
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func filterGroupMembers(text: String) {
        self.filteredGroupMembers.removeAll()
        self.filterGroupMembersRequest = self.groupMembersRequestBuilder.set(searchKeyword: text).build()
        guard let filterGroupMembersRequest = filterGroupMembersRequest else { return }
        GroupMembersBuilder.getfilteredGroupMembers(filterGroupMemberRequest: filterGroupMembersRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let filteredGroupMembers):
                this.filteredGroupMembers = filteredGroupMembers
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func changeScope(for member: GroupMember, scope: CometChat.MemberScope) {
        GroupMembersBuilder.changeScope(group: group, member: member, scope: scope) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let groupMember):
                // broadcasting groupMember's change scope events
                CometChatGroupEvents.emitOnGroupMemberChangeScope(updatedBy: member, updatedUser: groupMember, scopeChangedTo: scope, scopeChangedFrom: scope, group: this.group)
                this.update(groupMember: groupMember)
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func banGroupMember(group: Group, member: GroupMember) {
        GroupMembersBuilder.banGroupMember(group: group, member: member) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let groupMember):
                this.remove(groupMember: groupMember)
                debugPrint("scope of GroupMember", groupMember.scope)
                // broadcasting groupmember's ban event.
                if let loggedInUser = LoggedInUserInformation.getUser() {
                CometChatGroupEvents.emitOnGroupMemberBan(bannedUser: groupMember, bannedGroup: group, bannedBy: loggedInUser)
            }
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func kickGroupMember(group: Group, member: GroupMember) {
        GroupMembersBuilder.kickGroupMember(group: group, member: member) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let groupMember):
                this.remove(groupMember: groupMember)
                // broadcasting groupmember's kick event.
               if let loggedInUser = LoggedInUserInformation.getUser() {
                CometChatGroupEvents.emitOnGroupMemberKick(kickedUser: groupMember, kickedGroup: group, kickedBy: loggedInUser)
                }
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func connect() {
        CometChat.addGroupListener(GroupMembersListenerConstants.groupListener, self)
        CometChatGroupEvents.addListener(GroupMembersListenerConstants.groupListener, self)
    }
    
    func disconnect() {
        CometChat.removeGroupListener(GroupMembersListenerConstants.groupListener)
        CometChatGroupEvents.removeListener(GroupMembersListenerConstants.groupListener)
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
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        self.groupMembers.removeAll()
        return self
    }
    
    public func size() -> Int {
        return self.groupMembers.count
    }
}
