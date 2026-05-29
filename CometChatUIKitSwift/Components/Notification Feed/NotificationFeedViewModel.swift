//
//  NotificationFeedViewModel.swift
//  CometChatUIKitSwift
//
//  Created by CometChat on 14/05/26.
//

import Foundation
import CometChatSDK

protocol NotificationFeedViewModelProtocol {
    var feedItems: [NotificationFeedItem] { get set }
    var groupedItems: [NotificationFeedTimestampGroup] { get set }
    var categories: [NotificationCategory] { get set }
    var activeCategory: String? { get set }
    var totalUnreadCount: Int { get set }
    
    var reload: (() -> Void)? { get set }
    var failure: ((CometChatException) -> Void)? { get set }
    
    func fetchFeedItems()
    func fetchCategories()
    func switchCategory(_ category: String?)
}

// MARK: - Timestamp Group Model
public struct NotificationFeedTimestampGroup {
    public let label: String
    public var items: [NotificationFeedItem]
}

open class NotificationFeedViewModel: NSObject, NotificationFeedViewModelProtocol {
    
    // MARK: - State
    var feedItems: [NotificationFeedItem] = []
    var groupedItems: [NotificationFeedTimestampGroup] = []
    var categories: [NotificationCategory] = []
    var activeCategory: String? = nil
    var totalUnreadCount: Int = 0
    var categoryUnreadCounts: [String: Int] = [:]
    
    // MARK: - Pagination State
    var isFetching = false
    var isFetchedAll = false
    
    // MARK: - Callbacks
    var reload: (() -> Void)?
    var failure: ((CometChatException) -> Void)?
    var onCategoriesLoaded: (() -> Void)?
    var onUnreadCountUpdated: (() -> Void)?
    
    // MARK: - Request Builders
    var feedRequestBuilder: NotificationFeedRequest.NotificationFeedRequestBuilder
    var categoriesRequestBuilder: NotificationCategoriesRequest.NotificationCategoriesRequestBuilder
    private var feedRequest: NotificationFeedRequest?
    private var categoriesRequest: NotificationCategoriesRequest?
    
    // MARK: - Visibility Tracking
    private var readItems: Set<String> = []
    private var deliveredItems: Set<String> = []
    private var visibilityTimers: [String: Timer] = [:]
    
    // MARK: - Unread Count Polling
    private var unreadCountTimer: Timer?
    private let unreadCountPollingInterval: TimeInterval = 30.0
    
    // MARK: - Listener
    var listenerRandomID = Date().timeIntervalSince1970
    
    // MARK: - Refresh
    var isRefresh: Bool = false {
        didSet {
            if isRefresh {
                self.fetchFeedItems()
            }
        }
    }
    
    // MARK: - Init
    init(feedRequestBuilder: NotificationFeedRequest.NotificationFeedRequestBuilder = NotificationFeedBuilder.getDefaultFeedRequestBuilder(),
         categoriesRequestBuilder: NotificationCategoriesRequest.NotificationCategoriesRequestBuilder = NotificationFeedBuilder.getDefaultCategoriesRequestBuilder()) {
        self.feedRequestBuilder = feedRequestBuilder
        self.categoriesRequestBuilder = categoriesRequestBuilder
        super.init()
        self.feedRequest = feedRequestBuilder.build()
        self.categoriesRequest = categoriesRequestBuilder.build()
    }
    
    deinit {
        disconnect()
        stopUnreadCountPolling()
    }
    
    // MARK: - Request Builder Management
    private func rebuildFeedRequest() {
        // When user selects a specific category tab, we need to rebuild with that category.
        // We cannot call set(category:) on the developer's builder because builders are reference types
        // and that would permanently mutate the developer's original settings.
        // When "All" is selected (nil), use the developer's builder directly to preserve their category.
        if let category = activeCategory {
            feedRequest = NotificationFeedRequest.NotificationFeedRequestBuilder()
                .set(category: category)
                .build()
        } else {
            feedRequest = feedRequestBuilder.build()
        }
    }
    
    public func setFeedRequestBuilder(_ builder: NotificationFeedRequest.NotificationFeedRequestBuilder) {
        self.feedRequestBuilder = builder
        self.feedRequest = builder.build()
    }
    
    public func setCategoriesRequestBuilder(_ builder: NotificationCategoriesRequest.NotificationCategoriesRequestBuilder) {
        self.categoriesRequestBuilder = builder
        self.categoriesRequest = builder.build()
    }
    
    // MARK: - Fetch Categories
    func fetchCategories() {
        // Rebuild the request fresh each time (cursor-based, consumed after first use)
        categoriesRequest = categoriesRequestBuilder.build()
        
        guard let request = categoriesRequest else {
            return
        }
        NotificationFeedBuilder.fetchCategories(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let fetchedCategories):
                self.categories = fetchedCategories
                self.onCategoriesLoaded?()
            case .failure(let error):
                self.failure?(error)
            }
        }
    }
    
    // MARK: - Fetch Feed Items
    func fetchFeedItems() {
        if isRefresh {
            isFetchedAll = false
            rebuildFeedRequest()
        }
        
        guard let request = feedRequest else {
            return
        }
        if isFetchedAll { return }
        
        isFetching = true
        NotificationFeedBuilder.fetchFeedItems(request: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let fetchedItems):
                if fetchedItems.isEmpty {
                    self.isFetchedAll = true
                }
                
                if self.isRefresh {
                    self.feedItems = fetchedItems
                } else {
                    self.feedItems.append(contentsOf: fetchedItems)
                }
                
                self.reportDeliveredForItems(fetchedItems)
                self.groupedItems = self.groupByTimestamp(items: self.feedItems)
                
                self.isFetching = false
                self.isRefresh = false
                self.reload?()
                
            case .failure(let error):
                self.isFetching = false
                self.isRefresh = false
                self.failure?(error)
            }
        }
    }
    
    // MARK: - Category Switching
    func switchCategory(_ category: String?) {
        activeCategory = category
        feedItems.removeAll()
        groupedItems.removeAll()
        isFetchedAll = false
        rebuildFeedRequest()
        fetchFeedItems()
    }
    
    // MARK: - Unread Count
    func fetchUnreadCount() {
        CometChat.getNotificationFeedUnreadCount(category: activeCategory, onSuccess: { [weak self] count in
            guard let self = self else { return }
            self.totalUnreadCount = count
            self.onUnreadCountUpdated?()
        }, onError: { error in
        })
    }
    
    func startUnreadCountPolling() {
        fetchUnreadCount()
        unreadCountTimer = Timer.scheduledTimer(withTimeInterval: unreadCountPollingInterval, repeats: true) { [weak self] _ in
            self?.fetchUnreadCount()
        }
    }
    
    func stopUnreadCountPolling() {
        unreadCountTimer?.invalidate()
        unreadCountTimer = nil
    }
    
    // MARK: - Engagement Reporting
    
    private func reportDeliveredForItems(_ items: [NotificationFeedItem]) {
        for item in items {
            guard !deliveredItems.contains(item.id) else { continue }
            deliveredItems.insert(item.id)
            CometChat.markFeedItemAsDelivered(item, onSuccess: {}, onError: { _ in })
        }
    }
    
    func reportEngagement(item: NotificationFeedItem, interaction: String) {
        CometChat.reportFeedEngagement(item, interactionString: interaction, onSuccess: {}, onError: { _ in })
    }
    
    // MARK: - Visibility Tracking (Read after 1s)
    func itemBecameVisible(item: NotificationFeedItem) {
        
        // readAt == 0 means unread
        guard !readItems.contains(item.id), item.readAt == 0 else { return }
        
        let timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.markAsRead(item: item)
        }
        visibilityTimers[item.id] = timer
    }
    
    func itemBecameHidden(item: NotificationFeedItem) {
        visibilityTimers[item.id]?.invalidate()
        visibilityTimers.removeValue(forKey: item.id)
    }
    
    private func markAsRead(item: NotificationFeedItem) {
        guard !readItems.contains(item.id) else { return }
        readItems.insert(item.id)
        
        CometChat.markFeedItemAsRead(item, onSuccess: { [weak self] in
            guard let self = self else { return }
            if self.totalUnreadCount > 0 {
                self.totalUnreadCount -= 1
                self.onUnreadCountUpdated?()
            }
            self.reload?()
        }, onError: { [weak self] _ in
            self?.readItems.remove(item.id)
        })
    }
    
    // MARK: - Real-Time Listener
    func connect() {
        let listenerId = "notification-feed-listener-\(listenerRandomID)"
        CometChat.addNotificationFeedListener(listenerId, self)
    }
    
    func disconnect() {
        let listenerId = "notification-feed-listener-\(listenerRandomID)"
        CometChat.removeNotificationFeedListener(listenerId)
        visibilityTimers.values.forEach { $0.invalidate() }
        visibilityTimers.removeAll()
    }
    
    // MARK: - Grouping
    func groupByTimestamp(items: [NotificationFeedItem]) -> [NotificationFeedTimestampGroup] {
        // When viewing "All", group by category
        // When viewing a specific category, group by timestamp (Today, Yesterday, etc.)
        if activeCategory == nil {
            return groupByCategory(items: items)
        } else {
            return groupByTime(items: items)
        }
    }
    
    private func groupByCategory(items: [NotificationFeedItem]) -> [NotificationFeedTimestampGroup] {
        // No grouping — each item gets its own section with category + timestamp
        return items.map { item in
            let label = item.category.isEmpty ? "" : item.category
            return NotificationFeedTimestampGroup(label: label, items: [item])
        }
    }
    
    private func groupByTime(items: [NotificationFeedItem]) -> [NotificationFeedTimestampGroup] {
        // No category label needed — each item gets its own section with just timestamp
        return items.map { item in
            return NotificationFeedTimestampGroup(label: "", items: [item])
        }
    }
    
    private func timestampLabel(for date: Date, calendar: Calendar) -> String {
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else if isDateInThisWeek(date, calendar: calendar) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
    
    private func isDateInThisWeek(_ date: Date, calendar: Calendar) -> Bool {
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: Date()) else { return false }
        return weekInterval.contains(date)
    }
    
    // MARK: - Helper
    func relativeTimeString(for timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let now = Date()
        var secondsAgo = Int(now.timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let twoDays = 2 * day
        let sevenDays = 7 * day
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: CometChatLocalize.getLocale())
        
        if secondsAgo < day {
            // Today — show time (e.g., "2:35 PM")
            formatter.dateFormat = "h:mm a"
            return formatter.string(from: date)
        } else if secondsAgo < twoDays {
            // Yesterday
            return "YESTERDAY".localize()
        } else if secondsAgo < sevenDays {
            // Within past week — show day name (e.g., "Monday")
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date).capitalized
        } else {
            // Older — show date (e.g., "25/05/2026")
            formatter.dateFormat = "dd/MM/yyyy"
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Data Operations
    @discardableResult
    func insert(item: NotificationFeedItem, at index: Int = 0) -> Self {
        if feedItems.firstIndex(where: { $0.id == item.id }) == nil {
            feedItems.insert(item, at: index)
            groupedItems = groupByTimestamp(items: feedItems)
        }
        return self
    }
    
    @discardableResult
    func remove(itemId: String) -> Self {
        if let index = feedItems.firstIndex(where: { $0.id == itemId }) {
            feedItems.remove(at: index)
            groupedItems = groupByTimestamp(items: feedItems)
        }
        return self
    }
    
    func clearList() {
        feedItems.removeAll()
        groupedItems.removeAll()
        reload?()
    }
    
    func size() -> Int {
        return feedItems.count
    }
}

// MARK: - CometChatNotificationFeedDelegate
extension NotificationFeedViewModel: CometChatNotificationFeedDelegate {
    public func onFeedItemReceived(feedItem: NotificationFeedItem) {
        insert(item: feedItem, at: 0)
        reportDeliveredForItems([feedItem])
        
        // readAt == 0 means unread
        if feedItem.readAt == 0 {
            totalUnreadCount += 1
            onUnreadCountUpdated?()
        }
        
        reload?()
    }
}
