//
//  CometChatNotificationFeed.swift
//  CometChatUIKitSwift
//
//  Created by CometChat on 14/05/26.
//

import Foundation
import CometChatSDK
import CometChatCardsSwift
import UIKit

open class CometChatNotificationFeed: CometChatListBase {
    
    // MARK: - Static Styles
    public static var style = NotificationFeedStyle()
    
    // MARK: - Instance Styles
    public lazy var style = CometChatNotificationFeed.style
    
    // MARK: - Configuration
    public var showFilterChips: Bool = true
    public var showBackButton: Bool = true
    public var cardThemeMode: String = "auto"
    
    // MARK: - Callbacks
    var onItemClick: ((_ feedItem: NotificationFeedItem) -> Void)?
    var onActionClick: ((_ feedItem: NotificationFeedItem, _ actionEvent: CometChatCardActionEvent) -> Void)?
    var onError: ((_ error: CometChatException) -> Void)?
    
    // MARK: - Internal
    var viewModel: NotificationFeedViewModel = NotificationFeedViewModel()
    
    private lazy var filterChipsView: NotificationFeedFilterChipsView = {
        let view = NotificationFeedFilterChipsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.style = style
        return view
    }()
    
    deinit {
        disconnect()
    }
    
    // MARK: - Init
    public init() {
        super.init(nibName: nil, bundle: nil)
        defaultSetup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView(style: .plain, withRefreshControl: true)
        registerCells()
        configureTableViewForDynamicHeight()
        if showFilterChips {
            setupFilterChips()
        }
        setupViewModel()
        connect()
        
        showLoadingView()
        loadingStartTime = Date()
        viewModel.fetchCategories()
        viewModel.isRefresh = true
        viewModel.startUnreadCountPolling()
        
        hideSeparator = true
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        listBaseStyle = style
        super.viewWillAppear(animated)
        tableView.reloadData()
        
        // Fixed white header with subtle bottom border (per Figma)
        if let navigationController = navigationController {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = CometChatTheme.backgroundColor01
            appearance.shadowColor = .clear // no shadow — the chips view handles the separation
            
            // Hide the default centered title (we use a custom left-aligned titleView)
            appearance.titleTextAttributes = [
                .foregroundColor: UIColor.clear
            ]
            
            navigationController.navigationBar.standardAppearance = appearance
            navigationController.navigationBar.scrollEdgeAppearance = appearance
            navigationController.navigationBar.compactAppearance = appearance
            
            // Left-aligned title label as leftBarButtonItem
            let titleLabel = UILabel()
            titleLabel.text = "Notifications"
            titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
            titleLabel.textColor = CometChatTheme.textColorPrimary
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: titleLabel)
        }
    }
    
    // MARK: - Default Setup (matching Figma header)
    open func defaultSetup() {
        // Navigation title per Figma: "Notifications", bold, left-aligned
        title = "Notifications"
        prefersLargeTitles = false // Don't use large titles — we want a fixed header
        hideSearch = true
        hideBackButton = !showBackButton
        
        // Loading state: use shimmer view
        loadingView = NotificationFeedShimmerView()
        
        // Error state
        errorStateTitleText = "Oops!"
        errorStateSubTitleText = "Looks like something went wrong. Please try again."
        errorStateImage = UIImage(named: "nothingHere", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        
        // Empty state
        emptyStateImage = UIImage(named: "nothingHere", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        emptyStateTitleText = "Nothing here yet"
        emptyStateSubTitleText = "New activity will appear here when available."
    }
    
    // MARK: - Setup Filter Chips
    private func setupFilterChips() {
        // Chips are FIXED with the header — they don't scroll with content
        filterChipsView.backgroundColor = CometChatTheme.backgroundColor01
        view.addSubview(filterChipsView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        filterChipsView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            filterChipsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            filterChipsView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filterChipsView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            filterChipsView.heightAnchor.constraint(equalToConstant: 50),
            
            tableView.topAnchor.constraint(equalTo: filterChipsView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        filterChipsView.onChipSelected = { [weak self] category in
            guard let self = self else { return }
            self.viewModel.switchCategory(category)
            // Immediately update chip visuals to highlight the selected category
            self.updateFilterChips()
        }
    }
    
    // MARK: - Setup ViewModel
    private var loadingStartTime: Date?
    private let minimumLoadingDuration: TimeInterval = 0.8
    
    private func setupViewModel() {
        
        viewModel.reload = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if self.viewModel.size() == 0 {
                    self.showEmptyView()
                } else if self.isEmptyStateVisible {
                    self.removeEmptyView()
                } else if self.isErrorStateVisible {
                    self.removeErrorView()
                }
                
                self.hideFooterIndicator()
                self.reload()
                self.dismissLoadingAfterMinimumDuration()
                self.refreshControl.endRefreshing()
            }
        }
        
        viewModel.failure = { [weak self] error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.onError?(error)
                self.refreshControl.endRefreshing()
                
                if self.viewModel.feedItems.isEmpty {
                    // Remove loading first, then show error — avoid overlap
                    self.dismissLoadingThenShowError()
                } else {
                    self.dismissLoadingAfterMinimumDuration()
                }
            }
        }
        
        viewModel.onCategoriesLoaded = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateFilterChips()
            }
        }
        
        viewModel.onUnreadCountUpdated = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateFilterChips()
            }
        }
    }
    
    private func updateFilterChips() {
        guard showFilterChips else { return }
        filterChipsView.updateChips(
            categories: viewModel.categories,
            activeCategory: viewModel.activeCategory,
            unreadCounts: viewModel.categoryUnreadCounts,
            totalUnreadCount: viewModel.totalUnreadCount
        )
    }
    
    // MARK: - Connection
    public func connect() {
        viewModel.connect()
    }
    
    public func disconnect() {
        viewModel.disconnect()
        viewModel.stopUnreadCountPolling()
    }
    
    // MARK: - Loading Duration
    private func dismissLoadingAfterMinimumDuration() {
        guard let startTime = loadingStartTime else {
            removeLoadingView()
            return
        }
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = minimumLoadingDuration - elapsed
        
        if remaining <= 0 {
            removeLoadingView()
            loadingStartTime = nil
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + remaining) { [weak self] in
                self?.removeLoadingView()
                self?.loadingStartTime = nil
            }
        }
    }
    
    /// Removes the loading view first, then shows the error view — prevents overlap.
    private func dismissLoadingThenShowError() {
        guard let startTime = loadingStartTime else {
            removeLoadingView()
            showErrorView()
            return
        }
        let elapsed = Date().timeIntervalSince(startTime)
        let remaining = minimumLoadingDuration - elapsed
        
        if remaining <= 0 {
            removeLoadingView()
            loadingStartTime = nil
            showErrorView()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + remaining) { [weak self] in
                self?.removeLoadingView()
                self?.loadingStartTime = nil
                self?.showErrorView()
            }
        }
    }
    
    // MARK: - Refresh
    override func onRefreshControlTriggered() {
        // Refresh everything fresh
        viewModel.fetchCategories()
        viewModel.isRefresh = true
    }
    
    // MARK: - Register Cells
    private func registerCells() {
        tableView.register(NotificationFeedItemCell.self, forCellReuseIdentifier: NotificationFeedItemCell.identifier)
    }
    
    // MARK: - Table View Dynamic Height Configuration
    private func configureTableViewForDynamicHeight() {
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 600
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.backgroundColor = CometChatTheme.backgroundColor02
        view.backgroundColor = CometChatTheme.backgroundColor01 // behind nav bar area
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }
}

// MARK: - UITableView DataSource & Delegate
extension CometChatNotificationFeed {
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.groupedItems.count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard section < viewModel.groupedItems.count else { return 0 }
        return viewModel.groupedItems[section].items.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NotificationFeedItemCell.identifier, for: indexPath) as? NotificationFeedItemCell,
              indexPath.section < viewModel.groupedItems.count,
              indexPath.row < viewModel.groupedItems[indexPath.section].items.count else {
            return UITableViewCell()
        }
        
        let item = viewModel.groupedItems[indexPath.section].items[indexPath.row]
        let relativeTime = viewModel.relativeTimeString(for: item.sentAt)
        
        cell.configure(with: item, relativeTime: relativeTime, style: style)
        
        cell.onCardAction = { [weak self] actionEvent in
            guard let self = self else { return }
            self.onActionClick?(item, actionEvent)
        }
        
        // When the framework's accordion toggles, it:
        // 1. Posts contentSizeDidChangeNotification (observed by the cell)
        // 2. Calls invalidateIntrinsicContentSize on the card view
        // 3. Calls findTableView()?.beginUpdates()/endUpdates()
        //
        // Step 3 triggers heightForRowAt. We need the cached height cleared
        // BEFORE that happens, so heightForRowAt returns automaticDimension
        // and the table view uses systemLayoutSizeFitting (which now works
        // because the framework invalidated intrinsicContentSize in step 2).
        cell.onContentSizeChanged = { [weak self, weak cell] in
            guard let self = self, let cell = cell,
                  let _ = self.tableView.indexPath(for: cell) else { return }
            // The framework already called beginUpdates/endUpdates on the table view
            // and invalidated intrinsicContentSize. The table view will re-query
            // heightForRowAt (which returns automaticDimension) and call
            // systemLayoutSizeFitting to get the new correct height.
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// Section header: Category/time label on left, most recent timestamp on right
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section < viewModel.groupedItems.count else { return nil }
        
        let group = viewModel.groupedItems[section]
        
        let headerView = UIView()
        headerView.backgroundColor = style.backgroundColor
        
        // Left label (category or time label)
        let leftLabel = UILabel()
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        leftLabel.text = group.label
        leftLabel.font = style.timestampHeaderFont
        leftLabel.textColor = style.timestampHeaderTextColor
        
        // Right label (relative timestamp of most recent item in this group)
        let rightLabel = UILabel()
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        if let mostRecentItem = group.items.first {
            rightLabel.text = viewModel.relativeTimeString(for: mostRecentItem.sentAt)
        } else {
            rightLabel.text = ""
        }
        rightLabel.font = style.timestampValueFont
        rightLabel.textColor = style.timestampValueColor
        rightLabel.textAlignment = .right
        
        headerView.addSubview(leftLabel)
        headerView.addSubview(rightLabel)
        
        NSLayoutConstraint.activate([
            leftLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            leftLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            rightLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            rightLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            
            leftLabel.trailingAnchor.constraint(lessThanOrEqualTo: rightLabel.leadingAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section < viewModel.groupedItems.count,
              indexPath.row < viewModel.groupedItems[indexPath.section].items.count else { return }
        
        let item = viewModel.groupedItems[indexPath.section].items[indexPath.row]
        onItemClick?(item)
    }
    
    // MARK: - Disable Swipe Actions
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - Pagination
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSection = viewModel.groupedItems.count - 1
        guard lastSection >= 0 else { return }
        
        if indexPath.section == lastSection {
            let lastRow = viewModel.groupedItems[lastSection].items.count - 1
            if indexPath.row == lastRow && !viewModel.isFetchedAll && !viewModel.isFetching {
                showFooterIndicator()
                viewModel.isRefresh = false
                viewModel.fetchFeedItems()
            }
        }
        
        // Visibility tracking
        if indexPath.section < viewModel.groupedItems.count,
           indexPath.row < viewModel.groupedItems[indexPath.section].items.count {
            let item = viewModel.groupedItems[indexPath.section].items[indexPath.row]
            viewModel.itemBecameVisible(item: item)
        }
    }
    
    open func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.section < viewModel.groupedItems.count,
              indexPath.row < viewModel.groupedItems[indexPath.section].items.count else { return }
        let item = viewModel.groupedItems[indexPath.section].items[indexPath.row]
        viewModel.itemBecameHidden(item: item)
    }
}

// MARK: - CometChatConnectionDelegate
extension CometChatNotificationFeed: CometChatConnectionDelegate {
    public func connected() {
        viewModel.isRefresh = true
    }
    public func connecting() {}
    public func disconnected() {}
}
