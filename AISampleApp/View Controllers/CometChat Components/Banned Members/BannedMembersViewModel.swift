//
//  CometChatBannedMembers2ViewModel.swift
//  
//
//  Created by admin on 22/11/22.
//

import Foundation
import CometChatSDK
import CometChatUIKitSwift

protocol BannedMembersViewModelProtocol {
  
    var bannedGroupMembers: [CometChatSDK.GroupMember] { get set }
    var filteredBannedGroupMembers: [CometChatSDK.GroupMember] { get set }
    var bannedGroupMembersRequestBuilder: CometChatSDK.BannedGroupMembersRequest.BannedGroupMembersRequestBuilder? { get set }
    var selectedBannedMembers: [CometChatSDK.GroupMember] { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    var group: CometChatSDK.Group { get set }
    var row: Int { get set }
    
    func fetchBannedGroupMembers()
    func filterBannedGroupMembers(text: String)
    func unbanGroupMember(member: GroupMember)
}

open class BannedMembersViewModel: NSObject, BannedMembersViewModelProtocol {
  
    var group: CometChatSDK.Group
    var isSearching: Bool = false
    var bannedGroupMembersRequestBuilder: CometChatSDK.BannedGroupMembersRequest.BannedGroupMembersRequestBuilder?
    var selectedBannedMembers: [CometChatSDK.GroupMember] = []
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var reloadAtIndex: ((Int) -> Void)?
    var reload: (() -> Void)?
    private var bannedGroupMembersRequest:  BannedGroupMembersRequest?
    private var filterBannedMembersRequest: BannedGroupMembersRequest?
    var row: Int = -1 {
        didSet {
            reloadAtIndex?(row)
        }
    }
    
    var bannedGroupMembers: [CometChatSDK.GroupMember] = [] {
        didSet {
            reload?()
        }
    }
    
    var filteredBannedGroupMembers: [CometChatSDK.GroupMember] = [] {
        didSet {
            reload?()
        }
    }
    
    init(group: Group, bannedGroupMembersRequestBuilder: CometChatSDK.BannedGroupMembersRequest.BannedGroupMembersRequestBuilder?) {
        self.group = group
        self.bannedGroupMembersRequestBuilder = bannedGroupMembersRequestBuilder ?? BannedGroupMembersRequest.BannedGroupMembersRequestBuilder(guid: group.guid).set(limit: 30)
        self.bannedGroupMembersRequest = self.bannedGroupMembersRequestBuilder?.build()
    }
    
    func fetchBannedGroupMembers() {
        guard let bannedMemberRequest = bannedGroupMembersRequest else { return }
        bannedMemberRequest.fetchNext { [weak self] users in
            guard let this = self else { return }
            this.bannedGroupMembers += users
        } onError: { [weak self] error in
            guard let this = self, let error = error else { return }
            this.failure?(error)
        }
    }
    
    func filterBannedGroupMembers(text: String) {
        self.filteredBannedGroupMembers.removeAll()
        self.filterBannedMembersRequest = self.bannedGroupMembersRequestBuilder?.set(searchKeyword: text).build()
        guard let filterBannedMembersRequest = filterBannedMembersRequest else { return }
        
        filterBannedMembersRequest.fetchNext { [weak self] users in
            guard let this = self else { return }
            this.filteredBannedGroupMembers = users
        } onError: { [weak self] error in
            guard let this = self, let error = error else { return }
            this.failure?(error)
        }
    }
    
     func unbanGroupMember(member: GroupMember) {
         guard let uid = member.uid else { return }
         
         CometChat.unbanGroupMember(UID: uid, GUID: group.guid) { [weak self] unbannedSuccess in
             guard let this = self else { return }
             this.remove(groupMember: member)
             if let loggedInUser = CometChat.getLoggedInUser(){
                 
                 let actionMessage = ActionMessage()
                 actionMessage.action = .unbanned
                 actionMessage.conversationId = "group_\(this.group.guid)"
                 actionMessage.message = "\(loggedInUser.name ?? "") unbanned \(member.name ?? "")"
                 actionMessage.muid = "\(NSDate().timeIntervalSince1970)"
                 actionMessage.sender = loggedInUser
                 actionMessage.receiver = this.group
                 actionMessage.actionBy = loggedInUser
                 actionMessage.actionOn = member
                 actionMessage.receiverUid = this.group.guid
                 actionMessage.messageType = .groupMember
                 actionMessage.messageCategory = .action
                 actionMessage.receiverType = .group
                 actionMessage.sentAt = Int(Date().timeIntervalSince1970)
                 
                 CometChatGroupEvents.ccGroupMemberUnbanned(action: actionMessage, unbannedUser: member, unbannedBy: loggedInUser, unbannedFrom: this.group)
             }
         } onError: { [weak self] error in
             guard let this = self, let error = error else { return }
             this.failure?(error)
         }
    }
}

extension BannedMembersViewModel {
    
    @discardableResult
    public func clearList() -> Self {
        self.bannedGroupMembers.removeAll()
        return self
    }
    
    @discardableResult
    public func size() -> Int {
        return  bannedGroupMembers.count
    }
    
    @discardableResult
    public func add(groupMember: GroupMember) -> Self {
        self.bannedGroupMembers.append(groupMember)
        return self
    }
    
    @discardableResult
    public func update(groupMember: GroupMember) -> Self {
        if let index = bannedGroupMembers.firstIndex(of: groupMember) {
            self.bannedGroupMembers[index] = groupMember
        }
        return self
    }
    
    @discardableResult
    public func remove(groupMember: GroupMember) -> Self {
        if let index = bannedGroupMembers.firstIndex(of: groupMember) {
            self.bannedGroupMembers.remove(at: index)
        }
        return self
    }
}
