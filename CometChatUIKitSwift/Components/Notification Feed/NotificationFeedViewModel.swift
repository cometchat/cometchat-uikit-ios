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
    /// Seam over the listener registries, so `connect()`/`disconnect()` symmetry is
    /// assertable without a live SDK. Defaults to the real registrar.
    internal var listeners: ListenerRegistering = SDKListenerRegistrar.shared

    /// Seams over the network fetches the screen makes on load (feed page, categories,
    /// unread count), so the screen can be loaded without a live SDK. Default to the SDK.
    internal var fetchFeedPage: (_ request: NotificationFeedRequest, _ completion: @escaping (NotificationFeedBuilderResult) -> Void) -> Void = { request, completion in
        NotificationFeedBuilder.fetchFeedItems(request: request, completion: completion)
    }
    /// Offline ON only: the feed page in two phases (cached, then server).
    internal var fetchFeedPageTwoPhase: (_ request: NotificationFeedRequest,
                                         _ onCached: @escaping ([NotificationFeedItem]) -> Void,
                                         _ onServer: @escaping ([NotificationFeedItem]) -> Void,
                                         _ onError: @escaping (CometChatException?) -> Void) -> Void = { request, onCached, onServer, onError in
        request.fetchNext(onCachedNotificationFeedItems: { page in OfflineSnapshotMain.run { onCached(page) } },
                          onServerNotificationFeedItems: { page in OfflineSnapshotMain.run { onServer(page) } },
                          onError: { error in OfflineSnapshotMain.run { onError(error) } })
    }
    internal var fetchCategoryPage: (_ request: NotificationCategoriesRequest, _ completion: @escaping (NotificationCategoriesBuilderResult) -> Void) -> Void = { request, completion in
        NotificationFeedBuilder.fetchCategories(request: request, completion: completion)
    }
    internal var fetchUnreadCountRequest: (_ category: String?, _ completion: @escaping (Int) -> Void) -> Void = { category, completion in
        CometChat.getNotificationFeedUnreadCount(category: category, onSuccess: completion, onError: { _ in })
    }
    
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
    /// Asks whether offline is on for this read (`OfflineGate.isOn`, read once per read). A seam so a
    /// test can drive the offline path of this one instance without a live SDK.
    internal var offlineGate: () -> Bool = { OfflineGate.isOn() }
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

    /// Test seams: the read-after-visible tracker is otherwise unobservable
    /// (its only effect is an SDK call). Read-only, internal.
    var itemsAwaitingRead: Set<String> { Set(visibilityTimers.filter { $0.value.isValid }.keys) }
    var itemsMarkedRead: Set<String> { readItems }
    var itemsReportedDelivered: Set<String> { deliveredItems }
    
    // MARK: - Unread Count Polling
    private var unreadCountTimer: Timer?
    private let unreadCountPollingInterval: TimeInterval = 30.0
    
    // MARK: - Listener
    var listenerRandomID = Date().timeIntervalSince1970
    
    // MARK: - Refresh
    /// Offline ON: set by `connected()` just before the refetch it triggers, so a failure of that
    /// automatic read stays quiet while rows are on screen. Read and cleared at the start of the next fetch.
    var automaticRefetch = false
    /// Offline ON: why the offline state or error view is showing over nothing. Cleared when the next
    /// read starts.
    var offlineError: OfflineListError = .none
    /// Offline ON (D84 rule 3): the feed could not load for want of a connection and shows nothing:
    /// "Connect to load notifications" (the app's error view, if it set one), `onError` once.
    var connectToLoad: Bool { return offlineError == .notConnected }
    /// Offline ON: a reconnect leaves the list alone while its error view is for a non-network error.
    var skipsReconnectReload: Bool { return offlineGate() && offlineError.skipsReconnectReload }
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
        fetchCategoryPage(request) { [weak self] result in
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
        let automatic = automaticRefetch
        automaticRefetch = false
        if isRefresh {
            isFetchedAll = false
            rebuildFeedRequest()
        }
        
        guard let request = feedRequest else {
            return
        }
        if isFetchedAll { return }
        
        isFetching = true
        // Offline ON (read once for this read): two phases, cached then server.
        if offlineGate() {
            offlineFetchFeedItems(request: request, automatic: automatic)
            return
        }
        fetchFeedPage(request) { [weak self] result in
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
    
    /// Offline ON: the cached page paints, the server's replaces the same slice (deduped by id, so a
    /// re-delivery past the last page never repeats an item). A failed read follows D84
    /// (`OfflineReadFailure`): rows stay and a not-connected failure reports nothing; nothing on screen
    /// is "Connect to load notifications" when not connected, the error view otherwise.
    private func offlineFetchFeedItems(request: NotificationFeedRequest, automatic: Bool = false) {
        let hubGen = OfflineHub.shared.gen
        // Each phase merges into what is shown NOW, not a copy taken when the read began: an item
        // that arrived while the read ran (a live delivery) is kept. Dropped: for a refresh, the rows
        // shown before it; for the server phase, the cached page it replaces. Deduped by id (the SDK
        // can re-deliver past the end).
        let key: (NotificationFeedItem) -> String? = { $0.id }
        let wasRefresh = isRefresh
        let shownAtStart = Set(feedItems.compactMap(key))
        // A page after the first, asked for by scrolling: its failure keeps today's handling.
        let isLoadMore = !wasRefresh && !shownAtStart.isEmpty
        offlineError = .none
        let replaced = wasRefresh ? shownAtStart : Set<String>()
        var cachedKeys = Set<String>()
        let apply: ([NotificationFeedItem]) -> Void = { [weak self] rows in
            guard let self = self else { return }
            self.feedItems = rows
            self.groupedItems = self.groupByTimestamp(items: rows)
            self.reload?()
        }
        fetchFeedPageTwoPhase(request, { [weak self] page in
            guard let self = self, !page.isEmpty, hubGen == OfflineHub.shared.gen else { return }
            // A cached row already shown before this page read is not this page's to drop.
            cachedKeys = Set(page.compactMap(key)).subtracting(wasRefresh ? [] : shownAtStart)
            apply(SnapshotRows.reconcile(current: self.feedItems, cachedKeys: replaced, serverPage: page, key: key))
        }, { [weak self] page in
            guard let self = self, hubGen == OfflineHub.shared.gen else { return }
            if page.isEmpty { self.isFetchedAll = true }
            self.reportDeliveredForItems(page)
            apply(SnapshotRows.reconcile(current: self.feedItems, cachedKeys: replaced.union(cachedKeys), serverPage: page, key: key))
            self.isFetching = false
            self.isRefresh = false
        }, { [weak self] error in
            guard let self = self, hubGen == OfflineHub.shared.gen else { return }
            self.isFetching = false
            self.isRefresh = false
            let rowsShown = !self.feedItems.isEmpty
            if isLoadMore {
                // Paging waits for the connection quietly.
                if OfflineErrors.isNotConnected(code: error?.errorCode), rowsShown { return }
                if automatic && rowsShown { return }
                if let error = error { self.failure?(error) }
                return
            }
            // Rows on screen stay; nothing on screen is the offline state or the error view. Only an
            // online failure of a load the user or app started reaches `onError` over rows.
            let verdict = OfflineReadFailure.evaluate(error, rowsShown: rowsShown, keywordSearch: false, kitStarted: automatic)
            self.offlineError = OfflineListError.afterFailure(error, rowsShown: rowsShown)
            if verdict.reportsError, let error = error {
                self.failure?(error)
            } else {
                // No callback to end a pull-to-refresh: redraw.
                self.reload?()
            }
        })
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
        fetchUnreadCountRequest(activeCategory) { [weak self] count in
            guard let self = self else { return }
            self.totalUnreadCount = count
            self.onUnreadCountUpdated?()
        }
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
        listeners.add(.notificationFeedSDK, id: listenerId, listener: self)
        listeners.add(.offlineHub, id: "notification-feed-offline-hub-listener-\(listenerRandomID)", listener: self as OfflineHubObserver)
    }
    
    func disconnect() {
        let listenerId = "notification-feed-listener-\(listenerRandomID)"
        listeners.remove(.notificationFeedSDK, id: listenerId)
        listeners.remove(.offlineHub, id: "notification-feed-offline-hub-listener-\(listenerRandomID)")
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

// MARK: - Offline hub

extension NotificationFeedViewModel: OfflineHubObserver {

    /// Logout, user switch or cache reset: no item of the old session survives.
    func offlineSessionChanged(gen: Int) {
        feedItems = []
        groupedItems = []
        offlineError = .none
        isFetching = false
        isFetchedAll = false
        reload?()
    }

    /// The cache was rebuilt: read the first page again, two-phase.
    func offlineCacheReset(_ event: OfflineCacheResetEvent) {
        guard event.gen == OfflineHub.shared.gen else { return }
        // The kit's own reload: it fails quietly over rows on screen.
        automaticRefetch = true
        isRefresh = true
    }

    /// A user logged in (a token refresh keeps the cache): reload what was cleared.
    func offlineSessionStarted(gen: Int) {
        guard feedItems.isEmpty, gen == OfflineHub.shared.gen else { return }
        isRefresh = true
    }
}
