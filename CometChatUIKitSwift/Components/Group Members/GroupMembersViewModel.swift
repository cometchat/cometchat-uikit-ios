//
//  GroupMembersViewModel.swift
 
//
//  Created by Pushpsen Airekar on 17/11/22.
//

import Foundation
import CometChatSDK

open class GroupMembersViewModel: NSObject {
    
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
    public var isSearching: Bool = false
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
    
    public override init() {
        super.init()
    }
    
    func connect() {
        CometChat.addGroupListener("group-members-groups-sdk-listner-\(listenerRandomID)", self)
        CometChatGroupEvents.addListener("group-members-groups-event-listner-\(listenerRandomID)", self)
    }
    
    func disconnect() {
        CometChat.removeGroupListener("group-members-groups-sdk-listner-\(listenerRandomID)")
        CometChatGroupEvents.removeListener("group-members-groups-event-listner-\(listenerRandomID)")
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
        guard let groupsMembersRequest = groupsMembersRequest else { return }
        GroupMembersBuilder.fetchGroupMembers(groupMemberRequest: groupsMembersRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedGroupMembers):
                if fetchedGroupMembers.isEmpty { this.isFetchedAll = true }
                this.groupMembers += fetchedGroupMembers
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    public func filterGroupMembers(text: String) {
        self.filterGroupMembersRequest = (self.filterGroupMembersRequestBuilder ?? self.groupMembersRequestBuilder)?.set(searchKeyword: text).build()
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
                this.failure?(error)
            }
        }
    }
    
    func banGroupMember(group: Group, member: GroupMember) {
        GroupMembersBuilder.banGroupMember(group: group, member: member) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let groupMember):
                group.membersCount = group.membersCount - 1
                this.remove(groupMember: groupMember)
                debugPrint("scope of GroupMember", groupMember.scope)
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
                this.failure?(error)
            }
        }
    }
    
    func kickGroupMember(group: Group, member: GroupMember) {
        GroupMembersBuilder.kickGroupMember(group: group, member: member) { [weak self] result in
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
                this.failure?(error)
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


