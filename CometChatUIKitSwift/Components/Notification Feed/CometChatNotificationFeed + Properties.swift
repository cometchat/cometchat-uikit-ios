//
//  CometChatNotificationFeed + Properties.swift
//  CometChatUIKitSwift
//
//  Created by CometChat on 14/05/26.
//

import Foundation
import CometChatSDK
import CometChatCardsSwift

extension CometChatNotificationFeed {
    
    // MARK: - Events
    
    @discardableResult
    public func set(onItemClick: @escaping ((_ feedItem: NotificationFeedItem) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func set(onActionClick: @escaping ((_ feedItem: NotificationFeedItem, _ actionEvent: CometChatCardActionEvent) -> Void)) -> Self {
        self.onActionClick = onActionClick
        return self
    }
    
    @discardableResult
    public func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    // MARK: - Configuration
    
    @discardableResult
    public func set(notificationFeedRequestBuilder: NotificationFeedRequest.NotificationFeedRequestBuilder) -> Self {
        viewModel.setFeedRequestBuilder(notificationFeedRequestBuilder)
        return self
    }
    
    @discardableResult
    public func set(notificationCategoriesRequestBuilder: NotificationCategoriesRequest.NotificationCategoriesRequestBuilder) -> Self {
        viewModel.setCategoriesRequestBuilder(notificationCategoriesRequestBuilder)
        return self
    }
    
    @discardableResult
    public func set(showFilterChips: Bool) -> Self {
        self.showFilterChips = showFilterChips
        return self
    }
    
    @discardableResult
    public func set(showBackButton: Bool) -> Self {
        self.showBackButton = showBackButton
        self.hideBackButton = !showBackButton
        return self
    }
    
    @discardableResult
    public func set(cardThemeMode: String) -> Self {
        self.cardThemeMode = cardThemeMode
        return self
    }
    
    @discardableResult
    public func set(title: String) -> Self {
        self.title = title
        return self
    }
    
    // MARK: - Data Operations
    
    @discardableResult
    public func insert(feedItem: NotificationFeedItem, at index: Int = 0) -> Self {
        viewModel.insert(item: feedItem, at: index)
        return self
    }
    
    @discardableResult
    public func remove(feedItemId: String) -> Self {
        viewModel.remove(itemId: feedItemId)
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
    
    public func getFeedItems() -> [NotificationFeedItem] {
        return viewModel.feedItems
    }
    
    public func getUnreadCount() -> Int {
        return viewModel.totalUnreadCount
    }
    
    public func refresh() {
        viewModel.isRefresh = true
    }
}
