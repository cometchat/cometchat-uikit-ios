//
//  CometChatGroupMembers + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import Foundation
import CometChatSDK

extension CometChatGroupMembers {
    
    //MARK: Data
    @discardableResult
    public func set(groupMemberRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) -> Self {
        viewModel.set(groupMembersRequestBuilder: groupMemberRequestBuilder)
        return self
    }
    
    @discardableResult
    public func set(group: Group) -> Self {
        viewModel.set(group: group)
        return self
    }
    
    @discardableResult
    public func set(groupMemberSearchRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) -> Self {
        viewModel.set(searchGroupMembersRequestBuilder: groupMemberSearchRequestBuilder)
        return self
    }
    
    public func onSelection(_ onSelection: @escaping ([GroupMember]?) -> ()) {
        onSelection(viewModel.selectedGroupMembers)
    }
    
    
    //MARK: Events
    @discardableResult
    public func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(onLoad: @escaping (([GroupMember]) -> Void)) -> Self {
        self.onLoad = onLoad
        return self
    }
    
    @discardableResult
    public func set(onEmpty: @escaping () -> Void) -> Self {
        self.onEmpty = onEmpty
        return self
    }
    
    @discardableResult
    public func set(onItemClick: @escaping ((_ groupMember: GroupMember, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func set(
        onItemLongClick: @escaping ((_ groupMember: GroupMember, _ indexPath: IndexPath) -> Void)
    ) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }
    
    
    //MARK: Overrides
    @discardableResult
    public func set(
        trailView: ((_ groupMember: GroupMember?) -> UIView)?
    ) -> Self {
        self.trailView = trailView
        return self
    }
    
    @discardableResult
    public func set(
        leadingView: ((_ groupMember: GroupMember?) -> UIView)?
    ) -> Self {
        self.leadingView = leadingView
        return self
    }
    
    @discardableResult
    public func set(
        titleView: ((_ groupMember: GroupMember?) -> UIView)?
    ) -> Self {
        self.titleView = titleView
        return self
    }
    
    @discardableResult
    public func set(
        subtitleView: ((_ groupMember: GroupMember?) -> UIView)?
    ) -> Self {
        self.subtitle = subtitleView
        return self
    }
    
    @discardableResult
    public func set(
        listItemView: ((_ groupMember: GroupMember?) -> UIView)?
    ) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func set(
        options: ((_ group: Group, _ groupMember: GroupMember?) -> [CometChatGroupMemberOption])?
    ) -> Self {
        self.options = options
        return self
    }
    
    @discardableResult
    public func add(
        options: ((_ group: Group, _ groupMember: GroupMember?) -> [CometChatGroupMemberOption])?
    ) -> Self {
        self.addOptions = options
        return self
    }    
    
    
    @discardableResult
    public func add(groupMember: GroupMember) -> Self {
        viewModel.add(groupMember: groupMember)
        return self
    }
    
    @discardableResult
    public func update(groupMember: GroupMember) -> Self {
        viewModel.update(groupMember: groupMember)
        return self
    }
    
    @discardableResult
    public func insert(groupMember: GroupMember, at: Int) -> Self {
        viewModel.insert(groupMember: groupMember, at: at)
        return self
    }
    
    @discardableResult
    public func remove(groupMember: GroupMember) -> Self {
        viewModel.remove(groupMember: groupMember)
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        viewModel.clearList()
        return self
    }
    
    public func size() -> Int {
        viewModel.size()
    }
    
}
