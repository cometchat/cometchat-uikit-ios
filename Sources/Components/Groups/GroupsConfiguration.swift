//
//  GroupsConfiguration.swift
 
//
//  Created by Abdullah Ansari on 19/08/22.
//

import UIKit
import CometChatSDK

public class GroupsConfiguration {
    
    private(set) var subtitleView: ((_ group: Group?) -> UIView)?
    private(set) var listItemView: ((_ group: Group?) -> UIView)?
    private(set) var menus: [UIBarButtonItem]?
    private(set) var options: ((_ group: Group?) -> ([CometChatGroupOption]))?
    private(set) var hideSeparator: Bool?
    private(set) var style: GroupsStyle?
    private(set) var searchPlaceholderText: String?
    private(set) var backButton: UIView?
    private(set) var showBackButton: Bool?
    private(set) var selectionMode: SelectionMode = .none
    private(set) var onSelection: (([Group]) -> ())?
    private(set) var searchBoxIcon: UIImage?
    private(set) var hideSearch: Bool?
    private(set) var emptyStateView: UIView?
    private(set) var errorStateView: UIView?
    private(set) var privateGroupIcon: UIImage?
    private(set) var protectedGroupIcon: UIImage?
    private(set) var groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder?
    private(set) var onItemClick: ((_ group: Group, _ indexPath: IndexPath) -> Void)?
    private(set) var onItemLongClick: ((_ group: Group, _ indexPath: IndexPath) -> Void)?
    private(set) var onError: ((_ error: CometChatException) -> Void)?
    private(set) var onBack: (() -> ())?
    private(set) var emptyStateText: String?
    private(set) var errorStateText: String?
    private(set) var title: String?
    private(set) var titleMode: UINavigationItem.LargeTitleDisplayMode = .automatic
    
    public init() {}
    
    @discardableResult
    public func set(title: String, mode: UINavigationItem.LargeTitleDisplayMode) -> Self {
        self.title = title
        self.titleMode = mode
        return self
    }
    
    @discardableResult
    public func set(emptyStateText: String) -> Self {
        self.emptyStateText = emptyStateText
        return self
    }
    
    @discardableResult
    public func set(errorStateText: String) -> Self {
        self.errorStateText = errorStateText
        return self
    }
    
    @discardableResult
    public func setSubtitle(subtitleView: ((_ group: Group?) -> UIView)?) -> Self {
        self.subtitleView = subtitleView
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
    public func set(privateGroupIcon: UIImage) -> Self {
        self.privateGroupIcon = privateGroupIcon
        return self
    }
    
    @discardableResult
    public func set(protectedGroupIcon: UIImage) -> Self {
        self.protectedGroupIcon = protectedGroupIcon
        return self
    }
    
    @discardableResult
    public func onSelection(_ onSelection: @escaping ([Group]?) -> ()) -> Self {
        self.onSelection = onSelection
        return self
    }
    
    @discardableResult
    public func set(menus: [UIBarButtonItem]) -> Self {
        self.menus = menus
        return self
    }
    
    @discardableResult
    public func hide(separator: Bool) -> Self {
        self.hideSeparator = separator
        return self
    }
    
    @discardableResult
    public func hide(search: Bool) -> Self {
        self.hideSearch = search
        return self
    }
    
    @discardableResult
    public func show(backButton: Bool) -> Self {
        self.showBackButton = backButton
        return self
    }
    
    @discardableResult
    public func set(backButton: UIView) -> Self {
        self.backButton = backButton
        return self
    }
    
    @discardableResult
    public func set(emptyStateView: UIView) -> Self {
        self.emptyStateView = emptyStateView
        return self
    }
    
    @discardableResult
    public func set(errorStateView: UIView) -> Self {
        self.errorStateView = errorStateView
        return self
    }
    
    @discardableResult
    public func set(searchBoxIcon: UIImage) -> Self {
        self.searchBoxIcon = searchBoxIcon
        return self
    }
    
    @discardableResult
    public func selectionMode(mode: SelectionMode) -> Self {
        self.selectionMode = mode
        return self
    }
    
    @discardableResult
    public func set(searchPlaceholderText: String) -> Self {
        self.searchPlaceholderText = searchPlaceholderText
        return self
    }
    
    @discardableResult
    public func set(style: GroupsStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder) -> Self {
        self.groupsRequestBuilder = groupsRequestBuilder
        return self
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
    public func setOnBack(onBack: () -> ()) -> Self {
        self.onBack = self.onBack
        return self
    }
    
}
