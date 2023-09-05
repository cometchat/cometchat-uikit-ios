//
//  AddMembersConfiguration.swift
//
//
//  Created by Pushpsen Airekar on 29/09/22.
//

import Foundation
import UIKit
import CometChatSDK

public class AddMembersConfiguration {
    
    private(set) var subtitleView: ((_ user: User?) -> UIView)?
    private(set) var disableUsersPresence: Bool?
    private(set) var listItemView: ((_ user: User?) -> UIView)?
    private(set) var menus: [UIBarButtonItem]?
    private(set) var options: ((_ user: User?) -> [CometChatUserOption])?
    private(set) var hideSeparator: Bool?
    private(set) var searchPlaceholder: String?
    private(set) var backButton: UIImage?
    private(set) var showBackButton: Bool?
    private(set) var selectionMode: SelectionMode?
    private(set) var onSelection : (([User]) -> Void)?
    private(set) var searchBoxIcon: UIImage?
    private(set) var hideSearch: Bool?
    private(set) var emptyStateView: UIView?
    private(set) var errorStateView: UIView?
    private(set) var unbanIcon: UIImage?
    private(set) var onItemLongClick: ((_ user: User, _ indexPath: IndexPath) -> Void)?
    private(set) var onItemClick: ((_ user: User, _ indexPath: IndexPath?) -> Void)?
    private(set) var onError: ((_ error: CometChatException) -> Void)?
    private(set) var onBack: (() -> Void)?
    private(set) var usersRequestBuilder: UsersRequest.UsersRequestBuilder?
    private(set) var statusIndicatorStyle: StatusIndicatorStyle?
    private(set) var avatarStyle: AvatarStyle = AvatarStyle()
    private(set) var bannedMembersStyle: BannedMembersStyle?
    private(set) var listItemStyle: ListItemStyle?
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
    public func set(subtitleView: @escaping ((_ user: User?) -> UIView)) -> Self {
        self.subtitleView = subtitleView
        return self
    }

    @discardableResult
    public func disable(usersPresence: Bool) -> Self {
        self.disableUsersPresence = usersPresence
        return self
    }
    
    @discardableResult
    public func setListItemView(listItemView: @escaping ((_ user: User?) -> UIView)) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func set(menus: [UIBarButtonItem]) -> Self {
        self.menus = menus
        return self
    }
    
    @discardableResult
    public func setOptions(options: @escaping ((_ user: User?) -> [CometChatUserOption])) -> Self {
        self.options = options
        return self
    }
    
    @discardableResult
    public func hide(separator: Bool) -> Self {
        self.hideSeparator = separator
        return self
    }
    
    @discardableResult
    public func set(searchPlaceholder: String) -> Self {
        self.searchPlaceholder = searchPlaceholder
        return self
    }
    
    @discardableResult
    public func set(backButton: UIImage) -> Self {
        self.backButton = backButton
        return self
    }
    
    @discardableResult
    public func show(backButton: Bool) -> Self {
        self.showBackButton = backButton
        return self
    }
    
    @discardableResult
    public func set(selectionMode: SelectionMode) -> Self {
        self.selectionMode = selectionMode
        return self
    }
    
    @discardableResult
    public func setOnSelection(onSelection : @escaping (([User]) -> Void)) -> Self {
        self.onSelection = onSelection
        return self
    }
    
    @discardableResult
    public func set(searchBoxIcon: UIImage) -> Self {
        self.searchBoxIcon = searchBoxIcon
        return self
    }
    
    @discardableResult
    public func hide(search: Bool) -> Self {
        self.hideSearch = search
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
    public func set(unbanIcon: UIImage) -> Self {
        self.unbanIcon = unbanIcon
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func setOnBack(onBack: @escaping (() -> Void)) -> Self {
        self.onBack = onBack
        return self
    }
    
    
    @discardableResult
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> Self {
        self.statusIndicatorStyle = statusIndicatorStyle
        return self
    }
    
    @discardableResult
    public func set(bannedMembersStyle: BannedMembersStyle) -> Self {
        self.bannedMembersStyle = bannedMembersStyle
        return self
    }
    
    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func setOnItemLongClick(onItemLongClick: @escaping ((_ user: User, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }
    
    @discardableResult
    public func setOnItemClick(onItemClick: @escaping ((_ user: User, _ indexPath: IndexPath?) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func setRequestBuilder(usersRequestBuilder: UsersRequest.UsersRequestBuilder) -> Self {
        self.usersRequestBuilder = usersRequestBuilder
        return self
    }
    
}

