//
//  CometChatGroups + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 19/06/24.
//

import Foundation
import CometChatSDK

extension CometChatGroups {
    
    @discardableResult
    public func onSelection(_ onSelection: @escaping ([Group]?) -> ()) -> Self {
        onSelection(viewModel.selectedGroups)
        return self
    }
    
    @discardableResult
    public func setSubtitleView(subtitle: ((_ group: Group?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
    }
    
    @discardableResult
    public func setListItemView(listItemView: ((_ group: Group?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func setOptions(options: ((_ group: Group?) -> [CometChatGroupOption])?) -> Self {
        self.options = options
        return self
    }
    
    @discardableResult
    public func set(emptyStateMessage: String) -> Self {
        self.emptyStateTitleText = emptyStateMessage
        return self
    }
    
    @discardableResult
    public func set(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder) -> Self {
        viewModel = GroupsViewModel(groupsRequestBuilder: groupsRequestBuilder)
        return self
    }
    
    @discardableResult
    public func add(group: Group) -> Self {
        viewModel.add(group: group)
        return self
    }
    
    @discardableResult
    public func insert(group: Group, at: Int) -> Self {
        viewModel.insert(group: group, at: at)
        return self
    }
    
    @discardableResult
    public func update(group: Group) -> Self {
        viewModel.update(group: group)
        return self
    }
    
    @discardableResult
    public func remove(group: Group) -> Self {
        viewModel.remove(group: group)
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        viewModel.clearList()
        return self
    }
    
    public func size() -> Int {
        return viewModel.size()
    }
    
    @discardableResult
    public func setOnItemClick(onItemClick: @escaping ((_ group: Group, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func setOnItemLongClick(onItemLongClick: @escaping ((_ group: Group, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func setOnBack(onBack: @escaping () -> Void) -> Self {
        self.onBack = onBack
        return self
    }
    
    @discardableResult
    public func set(title:String) -> Self {
        self.title = title
        return self
    }
    
    @discardableResult
    public func setSelectionLimit(limit : Int) -> Self {
        self.selectionLimit = limit
        return self
    }
}
