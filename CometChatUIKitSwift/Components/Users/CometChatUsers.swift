//
//  CometChatUsers.swift
//
//
//  Created by Abdullah Ansari on 18/11/22.
//

import UIKit
import CometChatSDK

public enum titleAlignment {
    case left
    case center
}

@MainActor
open class CometChatUsers: CometChatListBase {
    
    // MARK: - Properties
    public var viewModel: UsersViewModel // ViewModel to manage user data and API requests.
    public var subtitle: ((_ user: User?) -> UIView)? // Closure to provide a custom subtitle view for each user.
    public  var listItemView: ((_ user: User?) -> UIView)? // Closure to provide a custom list item view for each user.
    public var options: ((_ user: User?) -> [CometChatUserOption])? // Closure to provide user-specific options for each user.
    public var disableUsersPresence: Bool // Flag to disable the user presence indicator.
    public var showSectionHeader: Bool = true // Flag to determine whether section headers should be shown.

    public static var style = UsersStyle() // Static style to be applied globally for the Users view.
    public static var avatarStyle: AvatarStyle = CometChatAvatar.style
    public static var statusIndicatorStyle: StatusIndicatorStyle = CometChatStatusIndicator.style

    public lazy var style = CometChatUsers.style
    public lazy var avatarStyle: AvatarStyle = CometChatUsers.avatarStyle
    public lazy var statusIndicatorStyle: StatusIndicatorStyle = CometChatUsers.statusIndicatorStyle


    public var onItemClick: ((_ user: User, _ indexPath: IndexPath) -> Void)? // Closure to handle item click events.
    public var onItemLongClick: ((_ user: User, _ indexPath: IndexPath) -> Void)? // Closure to handle long click events.
    public var onError: ((_ error: CometChatException) -> Void)? // Closure to handle errors.
    public var onBack: (() -> Void)? // Closure to handle back navigation.
    public  var onDidSelect: ((_ user: User, _ indexPath: IndexPath) -> Void)? // Closure for user selection events.
    public internal(set) var selectionLimit: Int? // Optional property to limit the number of selectable users.
    
    public var selectedCellCount: Int = 0 {
        didSet {
            updateNavigationBarTitleWithCount() // Update the title when the count changes
        }
    }
    public var onSelectedItemProceed: ((_ user: [User]) -> Void)?

    // MARK: - Initializer
    public init(usersRequestBuilder: UsersRequest.UsersRequestBuilder = UsersBuilder.getDefaultRequestBuilder()) {
        // Initialize the view model with a default or custom user request builder.
        viewModel = UsersViewModel(userRequestBuilder: usersRequestBuilder)
        disableUsersPresence = false
        super.init(nibName: nil, bundle: nil) // Initialize the superclass.
        self.defaultSetup() // Setup default properties.
    }

    required public init?(coder: NSCoder) {
        // Fatal error for unsupported initialization through storyboard or XIB.
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ViewController Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView(style: .grouped, withRefreshControl: true) // Setup the table view.
        showLoadingView() // Display a loading view during data fetch.
        setupViewModel() // Setup the view model observers.
        showSearch = true // Enable the search bar.
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Register a connection listener and refresh UI.
        CometChat.addConnectionListener("users-sdk-listener", self)
        registerCells() // Register reusable cells.
        hideSeparator = true
        viewModel.connect() // Connect the view model.
        reloadData() // Reload the data in the table view.
        fetchData() // Fetch new user data.
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Remove the connection listener and disconnect the view model.
        CometChat.removeConnectionListener("users-sdk-listener")
        viewModel.disconnect()
    }
    
    // MARK: - Update Navigation Bar Title with Selected Cell Count
    open func updateNavigationBarTitleWithCount() {
        if selectedCellCount == 0{
            navigationItem.rightBarButtonItems = []
            navigationItem.leftBarButtonItems = []
        }else{
            let button = UIButton(type: .custom)
            button.widthAnchor.constraint(equalToConstant: 50).isActive = true
            button.setTitle("\(selectedCellCount)", for: .normal)
            button.setImage(UIImage(systemName: "xmark"), for: .normal)
            button.imageView?.tintColor = CometChatTheme.iconColorPrimary
            button.titleLabel?.font = CometChatTypography.Heading4.bold
            button.setTitleColor(CometChatTheme.textColorPrimary, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            button.addTarget(self, action: #selector(crossButtonTapped), for: .touchUpInside)
            button.sizeToFit()
            let barButtonItem = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = barButtonItem
            rightBarButtonItem = [UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(tickButtonTapped))]
            rightBarButtonItem.first?.tintColor = CometChatTheme.iconColorPrimary
            navigationItem.rightBarButtonItems = rightBarButtonItem
        }
    }

    // MARK: - Tick Button Action
    @objc open func tickButtonTapped() {
        guard let selectedRows = tableView.indexPathsForSelectedRows else { return }
        
        onSelectedItemProceed?(viewModel.selectedUsers)

        for indexPath in selectedRows {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        viewModel.selectedUsers.removeAll()
        selectedCellCount = 0
        tableView.reloadData()
    }
    
    // MARK: - Cancel Selection Button Action
    @objc open func crossButtonTapped() {
        guard let selectedRows = tableView.indexPathsForSelectedRows else { return }

        for indexPath in selectedRows {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        viewModel.selectedUsers.removeAll()
        selectedCellCount = 0
        
        tableView.reloadData()
    }

    // Call this method when a cell is selected or deselected to update the count.
    open func updateSelectedCellCount(isSelected: Bool) {
        if selectionMode != .none{
            if isSelected {
                selectedCellCount += 1
            } else {
                selectedCellCount -= 1
            }
        }
    }

    // MARK: - Setup Methods
    open func defaultSetup() {
        // Setup default styles and error states.
        loadingView = UsersShimmerView() // Display a shimmer view while loading.
        
        title = "USERS".localize() // Localized title for the view.
        prefersLargeTitles = true // Enable large titles.

        // Setup default error and empty states.
        errorStateTitleText = "OOPS!".localize()
        errorStateSubTitleText = "Looks like something went wrong. Please try again."
        errorStateImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        (errorStateView as? StateView)?.retryButton.isHidden = true
        

        emptyStateImage = UIImage(systemName: "person.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        emptyStateTitleText = "No Users Available"
        emptyStateSubTitleText = "Add contacts to start conversations and see them listed here.".localize()
        (emptyStateView as? StateView)?.retryButton.isHidden = true

        // Customize the status indicator with style properties.
        statusIndicatorStyle.borderColor = style.backgroundColor
        statusIndicatorStyle.borderWidth = 2
        avatarStyle.textFont = CometChatTypography.Heading3.bold
    }
    
    override func onRefreshControlTriggered(){
        viewModel.isRefresh = true
    }

    // MARK: - Styling Methods
    open override func setupStyle() {
        listBaseStyle = style
        super.setupStyle()
    }
    
    open override func styleSearchBar() {
        searchStyle = style
        super.styleSearchBar()
    }

    // MARK: - Data Fetching Methods
    open func fetchData() {
        // Trigger fetching of user data through the ViewModel.
        viewModel.fetchUsers()
    }

    // MARK: - Data Reloading
    open func reloadData() {
        // Set up a closure to reload the table view when data is updated in the ViewModel.
        viewModel.reload = { [weak self] in
            // Use 'weak self' to prevent retain cycles.
            guard let this = self else { return }
            // Reload the table view on the main thread to ensure UI updates are smooth.
            DispatchQueue.main.async {
                this.removeErrorView()
                this.reload() // Custom reload logic.

                // Check if there are no users based on whether a search is active.
                let usersEmpty = this.viewModel.isSearching ? this.viewModel.filteredUsers.isEmpty : this.viewModel.users.isEmpty

                // Show or hide the empty view depending on whether the user list is empty.
                usersEmpty ? this.showEmptyView() : this.removeEmptyView()
                if !usersEmpty {
                    // If there are users, restore the table view's default state (e.g., no empty message).
                    this.tableView.restore()
                }
                this.refreshControl.endRefreshing()
                // Hide any loading view (e.g., loading spinner) once the data is loaded.
                this.hideFooterIndicator() // Hide any footer loading indicators.
                this.removeLoadingView()
            }
        }
    }

    // MARK: - ViewModel Setup
    open func setupViewModel() {
        // Set up a closure to handle failures when fetching data from the ViewModel.
        viewModel.failure = { [weak self] error in
            // Use 'weak self' to prevent retain cycles.
            guard let this = self else { return }
            // Handle the error on the main thread, as UI updates need to occur on the main thread.
            DispatchQueue.main.async {
                this.onError?(error) // Call an error handler if one is provided.
                this.removeLoadingView() // Hide the loading view since an error occurred.
                this.refreshControl.endRefreshing() // End any pull-to-refresh indicator.

                // Show an error view if the user list is empty.
                if this.viewModel.users.isEmpty {
                    this.showErrorView()
                }
            }
        }
    }

    // MARK: - Cell Registration
    open func registerCells() {
        // Register a reusable cell for the table view (in this case, a CometChatListItem).
        // This enables the table view to reuse cells for better performance.
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
    }

    // MARK: - Search Handling
    open override func onSearch(state: SearchState, text: String) {
        // Handle different states of search: either clearing or filtering based on search text.
        switch state {
        case .clear:
            // When the search is cleared, set 'isSearching' to false and reload the data.
            viewModel.isSearching = false
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                // Hide the empty view if the user list is not empty.
                if !this.viewModel.users.isEmpty {
                    this.removeEmptyView()
                }
                // Reload the table view to display the unfiltered list.
                this.tableView.reloadData()
                this.tableView.restore() // Restore the table view's default state.
            }
        case .filter:
            // When filtering, set 'isSearching' to true and filter users based on the input text.
            viewModel.isSearching = true
            viewModel.filterUsers(text: text)
        }
    }


    // MARK: - User Management Methods
    // Adds a user to the ViewModel's user list and returns the current instance (self) for chaining.
    @discardableResult
    public func add(user: User) -> Self {
        // Calls the ViewModel's add method to add the user to its list.
        viewModel.add(user: user)
        // Returns the current instance to enable method chaining.
        return self
    }

    // Inserts a user at a specific index in the ViewModel's user list and returns the current instance for chaining.
    @discardableResult
    public func insert(user: User, at: Int) -> Self {
        // Calls the ViewModel's insert method to place the user at the specified index.
        viewModel.insert(user: user, at: at)
        // Returns the current instance to enable method chaining.
        return self
    }

    // Removes a user from the ViewModel's user list and returns the current instance for chaining.
    @discardableResult
    public func remove(user: User) -> Self {
        // Calls the ViewModel's remove method to delete the specified user from its list.
        viewModel.remove(user: user)
        // Returns the current instance to enable method chaining.
        return self
    }

    // Updates the details of a specific user in the ViewModel's user list and returns the current instance for chaining.
    @discardableResult
    public func update(user: User) -> Self {
        // Calls the ViewModel's update method to modify the user's information in its list.
        viewModel.update(user: user)
        // Returns the current instance to enable method chaining.
        return self
    }

    // Sets a closure to handle selection of users and returns the current instance for chaining.
    @discardableResult
    public func onSelection(_ onSelection: @escaping ([User]) -> Void) -> Self {
        // Calls the provided closure with the currently selected users from the ViewModel.
        onSelection(viewModel.selectedUsers)
        // Returns the current instance to enable method chaining.
        return self
    }

}

// MARK: - TableView delegate and datasource method that inherited from the CometChatListBase.
extension CometChatUsers {

    // Provides and configures a cell for the user at the given indexPath
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeues a reusable cell of type CometChatListItem
        guard let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem else {
            return UITableViewCell()
        }

        // Retrieve the user object depending on search mode
        let user = viewModel.isSearching ? viewModel.filteredUsers[safe: indexPath.row] : viewModel.sectionUsers[safe: indexPath.section]?[safe: indexPath.row]

        // Set the user's name and avatar
        listItem.set(title: user?.name ?? "")
        listItem.set(avatarURL: user?.avatar ?? "", with: user?.name)
        
        // If subtitle and custom view are provided, set them
        if let subtitle = subtitle?(user) {
            listItem.set(subtitle: subtitle)
        }
        if let listItemView = listItemView?(user) {
            listItem.set(customView: listItemView)
        }

        // Set avatar size and customize appearance
        listItem.avatarHeightConstraint.constant = 40
        listItem.avatarWidthConstraint.constant = 40

        // Set presence indicator if not disabled
        if !disableUsersPresence {
            listItem.statusIndicator.isHidden = !(user?.status == .online && !(user?.hasBlockedMe ?? true) && !(user?.blockedByMe ?? true))
            listItem.statusIndicator.style = statusIndicatorStyle
        }

        // Apply theming styles to the list item
        listItem.style = style
        // TODO: Add logic for selected/deselected image after merging CometChatGroups branch

        // Enable/disable item selection based on selection mode
        listItem.allow(selection: selectionMode != .none)

        // Handle long click action
        listItem.onItemLongClick = { [weak self] in
            guard let self = self, let user = user else { return }
            self.onItemLongClick?(user, indexPath)
        }

        // Manage the selection state of the list item
        if let user = user {
            manageSelectionState(for: user, in: listItem, at: indexPath)
        }

        return listItem
    }
    
    // Handles the selection state for a user in the list item
    public func manageSelectionState(for user: User, in listItem: CometChatListItem, at indexPath: IndexPath) {
        // Check if the user is selected and update the UI accordingly
        listItem.isSelected = viewModel.selectedUsers.contains(where: { $0.uid == user.uid })
        if listItem.isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    // Returns the number of sections in the table view
    open override func numberOfSections(in tableView: UITableView) -> Int {
        // If searching, there is only one section
        return viewModel.isSearching ? 1 : viewModel.sectionUsers.count
    }

    // Returns the number of rows in a section
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // If searching, return the count of filtered users; otherwise, return the number of users in the section
        return viewModel.isSearching ? viewModel.filteredUsers.count : viewModel.sectionUsers[safe: section]?.count ?? 0
    }

    // Returns the height for a row at a given indexPath (automatic dimension)
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // Provides a custom header view for the section
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // If section headers are disabled or searching, return nil
        guard showSectionHeader, !viewModel.isSearching,
              let title = viewModel.sectionUsers[safe: section]?.first?.name?.prefix(1).uppercased() else { return nil }

        // Create and configure a UILabel for the section header title
        let label = UILabel()
        label.text = String(title)
        label.font = style.headerTitleFont
        label.textColor = style.headerTitleColor
        label.backgroundColor = .clear
        label.frame = CGRect(x: 20, y: 0, width: tableView.frame.width, height: 19)

        // Create and return a header view containing the label
        let headerView = UIView()
        headerView.addSubview(label)
        headerView.backgroundColor = .clear

        return headerView
    }

    // Handles row selection in the table view
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.isSearching ? viewModel.filteredUsers[indexPath.row] : viewModel.sectionUsers[indexPath.section][indexPath.row]

        // Handle selection based on mode and selection limit
        if selectionMode == .none {
            onItemClick?(user, indexPath) ?? onDidSelect?(user, indexPath)
        } else if !viewModel.selectedUsers.contains(user), (selectionLimit == nil || viewModel.selectedUsers.count < selectionLimit!) {
            viewModel.selectedUsers.append(user)
            updateSelectedCellCount(isSelected: true)
        }
    }

    // Handles row deselection in the table view
    open override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let user = viewModel.isSearching ? viewModel.filteredUsers[indexPath.row] : viewModel.sectionUsers[indexPath.section][indexPath.row]

        // Remove the user from the selected list
        if let foundUser = viewModel.selectedUsers.firstIndex(where: { $0.uid == user.uid }) {
            viewModel.selectedUsers.remove(at: foundUser)
            updateSelectedCellCount(isSelected: false)
        }
    }
    // Handles table view scrolling and triggers fetching more users if at the end
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Check if we're in the last section
        let lastSection = viewModel.sectionUsers.count - 1

        // Safely get the number of rows in the last section
        if let lastRow = viewModel.sectionUsers[safe: lastSection]?.count, indexPath.section == lastSection && indexPath.row == lastRow - 1 {
            // If it's the last row of the last section, trigger the fetch for more users
            if !viewModel.isFetchedAll && !viewModel.isFetching {
                showFooterIndicator()
                viewModel.isRefresh = false
                viewModel.fetchUsers()
            }
        } else {
            hideFooterIndicator()
        }
    }
    
    open override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration()
    }

    // Returns the list of currently selected users
    public func getSelectedUsers() -> [User] {
        return viewModel.selectedUsers
    }
}


//MARK: Connection Listener
extension CometChatUsers: CometChatConnectionDelegate {
    public func connected() {
        reloadData()
        fetchData()
    }
    
    public func connecting() {}
    
    public func disconnected() {}
}
