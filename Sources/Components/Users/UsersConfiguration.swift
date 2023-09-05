//
//  UsersConfiguration.swift
//
//
//  Created by Abdullah Ansari on 18/08/22.
//

import UIKit
import CometChatSDK

public class UsersConfiguration {
    
    private(set) var subtitle: ((_ user: User?) -> UIView)?
    private(set) var listItemView: ((_ user: User?) -> UIView)?
    private(set) var menus: [UIBarButtonItem]?
    private(set) var options: ((_ user: User?) -> [CometChatUserOption])?
    private(set) var hideSeparator: Bool = true
    private(set) var usersStyle: UsersStyle?
    private(set) var avatarStyle: AvatarStyle?
    private(set) var statusIndicatorStyle: StatusIndicatorStyle?
    private(set) var listItemStyle: ListItemStyle?
    private(set) var disableUsersPresence: Bool = false
    private(set) var backButton: UIView?
    private(set) var showBackButton: Bool?
    private(set) var searchBoxIcon: UIImage?
    private(set) var hideSearch: Bool?
    private(set) var emptyStateView: UIView?
    private(set) var errorStateView: UIView?
    private(set) var selectionMode: SelectionMode = .none
    private(set) var onSelection : (([User]?) -> ())?
    private(set) var backButtonTitle: String?
    private(set) var backButtonColor: UIColor?
    private(set) var backButtonFont: UIFont?
    private(set) var backButtonTint: UIColor?
    private(set) var backIcon: UIImage?
    private(set) var onItemClick: ((_ user: User, _ indexPath: IndexPath?) -> Void)?
    private(set) var onItemLongClick: ((_ user: User, _ indexPath: IndexPath) -> Void)?
    private(set) var onError: ((_ error: CometChatException) -> Void)?
    private(set) var usersRequestBuilder: UsersRequest.UsersRequestBuilder?
    private(set) var onBack: (() -> ())?
    private(set) var emptyStateText: String?
    private(set) var errorStateText: String?
    private(set) var title: String?
    private(set) var titleMode: UINavigationItem.LargeTitleDisplayMode = .automatic
    private(set) var showSectionHeader: Bool?
    
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
    public func selectionMode(selectionMode: SelectionMode) -> Self {
        self.selectionMode = selectionMode
        return self
    }
    
    @discardableResult
    public func disable(userPresence: Bool) -> Self {
        self.disableUsersPresence = userPresence
        return self
    }
    
    @discardableResult
    public func set(backButton: UIView) -> Self {
        self.backButton = backButton
        return self
    }
    
    @discardableResult
    public func set(searchBoxIcon: UIImage) -> Self{
        self.searchBoxIcon = searchBoxIcon
        return self
    }
    
    @discardableResult
    public func set(emptyView: UIView) -> Self{
        self.emptyStateView = emptyView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView) -> Self{
        self.errorStateView = errorView
        return self
    }
    
    @discardableResult
    public func set(menus: [UIBarButtonItem]) -> Self {
        self.menus = menus
        return self
    }
    
    @discardableResult
    public func onSelection(_ onSelection: @escaping ([User]?) -> ()) -> Self {
        self.onSelection = onSelection
        return self
    }
    
    @discardableResult
    public func show(backButton: Bool) -> Self {
        self.showBackButton = backButton
        return self
    }
    
    @discardableResult
    public func hide(search: Bool) -> Self {
        self.hideSearch = search
        return self
    }
    
    @discardableResult
    public func hide(separator: Bool) -> Self {
        self.hideSeparator = separator
        return self
    }
    
    @discardableResult
    public func set(usersStyle: UsersStyle) -> Self {
        self.usersStyle = usersStyle
        return self
    }
    
    @discardableResult
    public func setSubtitle(subtitle: ((_ user: User?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
    }
    
    @discardableResult
    public func setListItemView(listItemView: ((_ user: User?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func setOptions(options: ((_ user: User?) -> [CometChatUserOption])?) -> Self {
        self.options = options
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> Self {
        self.statusIndicatorStyle = statusIndicatorStyle
        return self
    }
    
    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(backButtonTitle: String?) ->  Self {
        self.backButtonTitle = backButtonTitle
        return self
    }
    
    @discardableResult
    public func set(backButtonTitleColor: UIColor) ->  Self {
        self.backButtonColor = backButtonTitleColor
        return self
    }
    
    @discardableResult
    public func set(backButtonFont: UIFont?) ->  Self {
        self.backButtonFont = backButtonFont ?? UIFont.systemFont(ofSize: 17, weight: .semibold)
        return self
    }
    
    @discardableResult
    public func set(backButtonTint: UIColor) ->  Self {
        self.backButtonTint = backButtonTint
        return self
    }
    
    @discardableResult
    public func set(backButtonIcon: UIImage) ->  Self {
        self.backIcon = backButtonIcon.withRenderingMode(.alwaysTemplate)
        return self
    }
    
    @discardableResult
    public func setOnItemClick(onItemClick: @escaping ((_ user: User, _ indexPath: IndexPath?) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func setOnItemLongClick(onItemLongClick: @escaping ((_ user: User, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemLongClick = onItemLongClick
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(onBack: () -> ()) -> Self {
        self.onBack = self.onBack
        return self
    }
    
    @discardableResult
    public func show(sectionHeader: Bool) -> Self {
        self.showSectionHeader = sectionHeader
        return self
    }
    
    @discardableResult
    public func setRequestBuilder(usersRequestBuilder: UsersRequest.UsersRequestBuilder) -> Self {
        self.usersRequestBuilder = usersRequestBuilder
        return self
    }
    
}
