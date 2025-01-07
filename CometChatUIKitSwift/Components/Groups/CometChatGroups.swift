//
//  CometChatGroups.swift
 
//
//  Created by Pushpsen Airekar on 17/11/22.
//

import UIKit
import CometChatSDK

@MainActor
open class CometChatGroups: CometChatListBase {
    
    // MARK: - Declaration of View Model
    // Internal variable to hold the instance of GroupsViewModel, which manages the data and business logic for groups.
    public var viewModel: GroupsViewModel

    // MARK: - Declaration of View Properties
    // Closure for generating a subtitle view for a given group.
    public var subtitle: ((_ group: Group?) -> UIView)?

    // Closure for generating a list item view for a given group.
    public var listItemView: ((_ group: Group?) -> UIView)?

    // Array to hold menu items for the navigation bar.
    public var menus: [UIBarButtonItem]?

    // Closure to generate options for a given group.
    public var options: ((_ group: Group?) -> [CometChatGroupOption])?

    // Closure called when an item in the list is clicked, providing the group and index path.
    public var onItemClick: ((_ group: Group, _ indexPath: IndexPath) -> Void)?
    
    // Closure called when an proceed clicked after selecting groups, providing the group.
    public var onSelectedItemProceed: ((_ group: [Group]) -> Void)?

    // Closure called when the back button is pressed.
    public var onBack: (() -> Void)?

    // Closure called when a group is selected, providing the group and index path.
    public var onDidSelect: ((_ group: Group, _ indexPath: IndexPath) -> Void)?

    // Closure called on a long click of an item, providing the group and index path.
    public var onItemLongClick: ((_ group: Group, _ indexPath: IndexPath) -> Void)?

    // Closure to handle errors, providing a CometChatException.
    public var onError: ((_ error: CometChatException) -> Void)?

    // Closure called when the create group button is clicked.
    public var joinPasswordProtectedGroup: ((_ group: Group) -> Void)?

    // Public property to limit the number of selections allowed, with internal setter.
    public internal(set) var selectionLimit: Int?

    // Static property to hold the default style for groups.
    public static var style = GroupsStyle()
    public static var avatarStyle: AvatarStyle = CometChatAvatar.style
    public static var statusIndicatorStyle: StatusIndicatorStyle = CometChatStatusIndicator.style


    // Lazy property for styling, set to the style defined in CometChatGroups.
    public lazy var style = CometChatGroups.style
    public lazy var avatar: AvatarStyle = CometChatGroups.avatarStyle
    public lazy var statusIndicatorStyle: StatusIndicatorStyle = CometChatGroups.statusIndicatorStyle

     
    public let groupsRequestBuilder : GroupsRequest.GroupsRequestBuilder = GroupsBuilder.getDefaultRequestBuilder()
    public var tickButton: [UIBarButtonItem]?
    public var joiningGroupAlert: UIAlertController?

    // A variable to track the number of selected cells.
    public var selectedCellCount: Int = 0 {
        didSet {
            updateNavigationBarTitleWithCount() // Update the title when the count changes
        }
    }

    // MARK: - Initialization
    // Initializes the view with an optional GroupsRequestBuilder to configure the GroupsViewModel.
    public init() {
        self.viewModel = GroupsViewModel(groupsRequestBuilder: groupsRequestBuilder)
        super.init(nibName: nil, bundle: nil)
        defaultSetup()
    }

    // Required initializer to support loading from a storyboard or xib, throws a fatal error if called.
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle Methods
    // Overrides the viewDidLoad lifecycle method to perform setup after the view has loaded.
    public override func viewDidLoad() {
        super.viewDidLoad() // Calls the superclass implementation.
        // Sets up the table view with a grouped style and enables refresh control.
        setupTableView(style: .plain, withRefreshControl: true)
        // Enables the search feature in the view.
        showSearch = true
        // Registers custom cells for the table view.
        registerCells()
        // Displays a loading view while data is being fetched.
        showLoadingView()
    
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = true
    }
    
    override func onRefreshControlTriggered() {
        viewModel.isRefresh = true
    }
    
    // Called just before the view appears on the screen
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CometChat.addConnectionListener("groups-sdk-listener", self)
        // Connect the view model to the CometChat server
        viewModel.connect()
        setupViewModel() // Setup the view model
        fetchData() // Fetch data for display
    }
    
    // Called when the view is about to disappear, used for cleanup tasks.
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated) // Calls the superclass implementation.
        // Removes the connection listener for the groups SDK to avoid memory leaks.
        CometChat.removeConnectionListener("groups-sdk-listener")
        // Disconnects the view model to clean up resources.
        viewModel.disconnect()
    }

    // MARK: - Styling Methods
    // Overrides the setupStyle method to apply styles to various components.
    open override func setupStyle() {
        listBaseStyle = style
        super.setupStyle()
    }
    
    open override func styleSearchBar() {
        searchStyle = style
        super.styleSearchBar()
    }
    
    // MARK: - Update Navigation Bar Title with Selected Cell Count
    open func updateNavigationBarTitleWithCount() {
        // Update the title to show "Groups (X)" where X is the selected cell count.
        if selectedCellCount == 0{
            navigationItem.rightBarButtonItems = rightBarButtonItem
            navigationItem.leftBarButtonItems = leftBarButtonItem
        }else{
            let button = UIButton(type: .custom)
            button.widthAnchor.constraint(equalToConstant: 50).isActive = true
            button.setTitle("\(selectedCellCount)", for: .normal)
            button.setImage(UIImage(systemName: "xmark"), for: .normal)
            button.imageView?.tintColor = CometChatTheme.iconColorPrimary
            button.titleLabel?.font = CometChatTypography.Heading1.regular
            button.setTitleColor(CometChatTheme.textColorPrimary, for: .normal)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)
            button.addTarget(self, action: #selector(crossButtonTapped), for: .touchUpInside)
            button.sizeToFit()
            let barButtonItem = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = barButtonItem
            tickButton = [UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(tickButtonTapped))]
            tickButton?.first?.tintColor = CometChatTheme.iconColorPrimary
            navigationItem.rightBarButtonItems = tickButton
        }
    }

    // MARK: - Tick Button Action
    @objc open func tickButtonTapped() {
        guard let selectedRows = tableView.indexPathsForSelectedRows else { return }
        
        onSelectedItemProceed?(viewModel.selectedGroups)

        for indexPath in selectedRows {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        // Clear the selected groups from viewModel
        viewModel.selectedGroups.removeAll()
        selectedCellCount = 0
        selectionMode = .none
        
        // Reload the table to apply changes visually if necessary
        tableView.reloadData()
    }
    
    @objc open func crossButtonTapped() {
        guard let selectedRows = tableView.indexPathsForSelectedRows else { return }

        for indexPath in selectedRows {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        // Clear the selected groups from viewModel
        viewModel.selectedGroups.removeAll()
        selectedCellCount = 0
        selectionMode = .none
        
        // Reload the table to apply changes visually if necessary
        tableView.reloadData()
        onBack?()
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

    // Fetches group data from the view model.
    public func fetchData() {
        // Triggers the fetching of groups from the view model.
        viewModel.fetchGroups()
    }

    // Sets up the view model's callbacks for updating the UI.
    public func setupViewModel() {
        // Reload closure that gets called when the view model updates.
        viewModel.reload = { [weak self] in
            guard let this = self else { return } // Prevents strong reference cycles.
            DispatchQueue.main.async {
                this.removeErrorView()
                // Reloads the UI to reflect new data.
                this.reload()
                // Hides the footer loading indicator.
                this.hideFooterIndicator()
                
                // Checks if the view model is currently searching for groups.
                switch this.viewModel.isSearching {
                case true:
                    // If searching and no filtered groups, show empty view.
                    if this.viewModel.filteredGroups.isEmpty {
                        this.showEmptyView()
                    } else {
                        // Otherwise, hide the empty view and restore the table view.
                        this.removeEmptyView()
                        this.tableView.restore()
                    }
                case false:
                    // If not searching and no groups, show empty view.
                    if this.viewModel.groups.isEmpty {
                        this.showEmptyView()
                    } else {
                        // Otherwise, hide the empty view and restore the table view.
                        this.removeEmptyView()
                        this.tableView.restore()
                    }
                }
                // Hides the loading view once data has been processed.
                this.removeLoadingView()
                this.refreshControl.endRefreshing()
            }
        }
        
        // Failure closure that gets called when an error occurs.
        viewModel.failure = { [weak self] error in
            guard let this = self else { return } // Prevents strong reference cycles.
            DispatchQueue.main.async {
                // Calls the onError closure to handle the error.
                this.onError?(error)
                // Hides the footer loading indicator and refresh control.
                this.hideFooterIndicator()
                this.refreshControl.endRefreshing()
                this.removeLoadingView()
                this.refreshControl.endRefreshing()
                
                // If there are no groups, show the error view.
                if this.viewModel.groups.isEmpty {
                    this.showErrorView()
                }
            }
        }
        
        // Closure to reload a specific row in the table view.
        viewModel.reloadAt = { row in
            // Reloads the specified row in the table view without animation.
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
    }

    // Registers the custom cell class for use in the table view.
    public func registerCells() {
        // Registers CometChatListItem for reuse with its identifier.
        self.tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
    }

    // Handles search functionality based on the current search state and text.
    open override func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            // Resets the search state and reloads the table view.
            viewModel.isSearching = false
            reload()
            tableView.restore()
            // Hides the empty view if there are groups present.
            if !viewModel.groups.isEmpty {
                self.removeEmptyView()
            }
        case .filter:
            // Sets the search state to true and filters groups based on the search text.
            viewModel.isSearching = true
            viewModel.filterGroups(text: text)
        }
    }

    // Performs the default setup for the view controller.
    open func defaultSetup() {
        // Sets the title of the view controller and enables large title preference.
        title = "GROUPS".localize() // Localizes the title string.
        prefersLargeTitles = true
        
        // Initializes the loading view with a shimmer effect.
        loadingView = GroupsShimmerView()
        
        // Configures text and image for the error state view.
        errorStateTitleText = "OOPS!".localize() // Localizes the error title.
        errorStateSubTitleText = "LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize() // Localizes the error subtitle.
        errorStateImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        (errorStateView as? StateView)?.retryButton.isHidden = true
        
        // Configures text and image for the empty state view.
        emptyStateImage = UIImage(systemName: "person.2.fill") ?? UIImage()
        emptyStateTitleText = "No Groups Found".localize()  // Localizes the empty state title (TODO: add to localize files).
        emptyStateSubTitleText = "Create or join groups to see them listed here and start collaborating..".localize() // Localizes the empty state subtitle (TODO: add to localize files).
        (emptyStateView as? StateView)?.retryButton.isHidden = true
        
        // Configures the status indicator style.
        statusIndicatorStyle.borderColor = style.backgroundColor // Sets the border color for the status indicator.
        statusIndicatorStyle.borderWidth = 2 // Sets the border width for the status indicator.
        avatar.textFont = CometChatTypography.Heading3.bold
    }
    
    @objc func cancelSelection(){
        selectionMode = .none
        tableView.reloadData()
    }
    
    public func showJoiningGroupAlert(for group: Group) {
        joiningGroupAlert = UIAlertController(title: nil, message: "Joining Group", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 30, y: 7, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.color = CometChatTheme.iconColorSecondary
        loadingIndicator.startAnimating()
        joiningGroupAlert!.view.addSubview(loadingIndicator)
        self.present(joiningGroupAlert!, animated: true, completion: nil)
    }
    
    public func hideJoiningGroupAlert(completion: @escaping (() -> Void)) {
        joiningGroupAlert?.dismiss(animated: true, completion: completion)
    }
}

//MARK: TABLE VIEW DELEGATES
extension CometChatGroups {

    // Function that returns a configured UITableViewCell for a given indexPath
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem else {
            return UITableViewCell()
        }

        // Determine the group based on whether the user is searching or not
        let group = viewModel.isSearching ? viewModel.filteredGroups[indexPath.row] : viewModel.groups[indexPath.row]
        
        // Custom view setup for the listItem
        if let customView = listItemView?(group) {
            listItem.set(customView: customView)
            return listItem
        }
        
        // Set the title for the group in the listItem
        if let name = group.name {
            listItem.set(title: name)
        }
        
        // Set the avatar for the group using the group icon or name
        listItem.set(avatarURL: group.icon ?? "", with: group.name)

        // Set the subtitle for the group, either using a custom subtitle or member count
        if let subTitleView = subtitle?(group) {
            listItem.set(subtitle: subTitleView)
        } else {
            let label = UILabel()
            label.text = group.membersCount <= 1
                ? "\(group.membersCount) \("MEMBER".localize())"
                : "\(group.membersCount) \("MEMBERS".localize())"
            label.textColor = style.listItemSubTitleTextColor
            label.font = style.listItemSubTitleFont
            listItem.set(subtitle: label)
        }
        
        // Set up the status indicator based on the group type
        setupStatusIndicator(for: group, in: listItem)

        // Apply custom styles to the listItem
        listItem.style = style
        
        // Manage selection based on the current selection mode
        switch selectionMode {
        case .single, .multiple: listItem.allow(selection: true)
        case .none: listItem.allow(selection: false)
        }

        // Handle long click events
        listItem.onItemLongClick = { [weak self] in
            self?.onItemLongClick?(group, indexPath)
        }

        // Manage the selection state of the group (selected or not)
        manageSelectionState(for: group, in: listItem, at: indexPath)

        return listItem
    }
    
    // Function to configure the status indicator based on the group type
    private func setupStatusIndicator(for group: Group, in listItem: CometChatListItem) {
        switch group.groupType {
        case .public:
            listItem.statusIndicator.isHidden = true
        case .private:
            configureStatusIndicator(for: listItem, icon: style.privateGroupIcon, tintColor: style.privateGroupImageTintColor, backgroundColor: style.privateGroupImageBackgroundColor)
        case .password:
            configureStatusIndicator(for: listItem, icon: style.protectedGroupIcon, tintColor: .white, backgroundColor: style.passwordGroupImageBackgroundColor)
        @unknown default:
            listItem.statusIndicator.isHidden = true
        }
    }
    
    // Function to configure the status indicator's icon, tint, and background color
    private func configureStatusIndicator(for listItem: CometChatListItem, icon: UIImage?, tintColor: UIColor, backgroundColor: UIColor) {
        listItem.statusIndicator.style = statusIndicatorStyle
        listItem.statusIndicator.isHidden = false
        listItem.set(statusIndicatorIcon: icon)
        listItem.set(statusIndicatorIconTint: tintColor)
        listItem.statusIndicator.style.backgroundColor = backgroundColor
        listItem.statusIndicator.layoutSubviews()
    }
    
    // Function to manage the selection state of a group in the listItem
    private func manageSelectionState(for group: Group, in listItem: CometChatListItem, at indexPath: IndexPath) {
        listItem.isSelected = viewModel.selectedGroups.contains(group)
        if listItem.isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }

    // Returns the number of rows in the given section based on whether the user is searching
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching ? viewModel.filteredGroups.count : viewModel.groups.count
    }

    // Returns the automatic height for each row in the tableView
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // Handles selection of a group at the given indexPath
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = viewModel.isSearching ? viewModel.filteredGroups[indexPath.row] : viewModel.groups[indexPath.row]
        handleSelection(for: group, at: indexPath)
        updateSelectedCellCount(isSelected: true)
    }

    // Function to handle the selection of a group based on the current selection mode
    func handleSelection(for group: Group, at indexPath: IndexPath) {
        if selectionMode == .none {
            if let onItemClick = onItemClick, group.hasJoined {
                onItemClick(group, indexPath)
            } else if let onDidSelect = onDidSelect {
                onDidSelect(group, indexPath)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            if !group.hasJoined, group.groupType == .public {
                showJoiningGroupAlert(for: group)
                viewModel.joinGroup(withGuid: group.guid, name: group.name ?? "", groupType: group.groupType, password: "", indexPath: indexPath, completion: {  [weak self] joinedGroup in
                    guard let this = self, let joinedGroup = joinedGroup else { return }
                    DispatchQueue.main.async {
                        group.hasJoined = true
                        this.hideJoiningGroupAlert(completion: {
                            this.onItemClick?(joinedGroup, indexPath)
                        })
                    }
                })
            } else if !group.hasJoined, group.groupType == .password {
                joinPasswordProtectedGroup?(group)
            } else {
                if let user = CometChat.getLoggedInUser() {
                    CometChatGroupEvents.ccGroupMemberJoined(joinedUser: user, joinedGroup: group)
                }
            }
        } else {
            if viewModel.selectedGroups.contains(group) {
                tableView.deselectRow(at: indexPath, animated: true)
                deselectGroup(group)
            } else {
                selectGroup(group, at: indexPath)
            }
        }
    }

    // Selects a group and adds it to the selectedGroups array, if within selection limit
    private func selectGroup(_ group: Group, at indexPath: IndexPath) {
        if selectionLimit == nil || viewModel.selectedGroups.count < selectionLimit! {
            viewModel.selectedGroups.append(group)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        } else {
            print("Selection limit reached.")
        }
    }

    // Deselects a group and removes it from the selectedGroups array
    private func deselectGroup(_ group: Group) {
        if let index = viewModel.selectedGroups.firstIndex(of: group) {
            viewModel.selectedGroups.remove(at: index)
        }
    }

    // Handles the deselection of a group at the given indexPath
    open override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let group = viewModel.isSearching ? viewModel.filteredGroups[indexPath.row] : viewModel.groups[indexPath.row]
        deselectGroup(group)
        updateSelectedCellCount(isSelected: false)
    }

    // Provides swipe actions for each row (e.g., delete, options)
    open override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let group = viewModel.isSearching ? viewModel.filteredGroups[indexPath.row] : viewModel.groups[indexPath.row]
        var actions = [UIContextualAction]()
        
        // Add contextual actions for each option in the group
        if let options = options?(group) {
            for option in options {
                let action = UIContextualAction(style: .destructive, title: "", handler: { (_, _, completionHandler) in
                    option.onClick?(group, indexPath.section, option, self)
                    completionHandler(true)
                })
                action.image = option.icon
                action.backgroundColor = option.backgroundColor
                actions.append(action)
            }
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    // Called when a cell is about to be displayed. Handles pagination by fetching more groups when needed
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (viewModel.groups.count - 1) && !viewModel.isFetchedAll && !viewModel.isFetching {
            showFooterIndicator()
            viewModel.isRefresh = false
            viewModel.fetchGroups()
        }else{
            hideFooterIndicator()
        }
    }
}


//MARK: Connection Listener
extension CometChatGroups: CometChatConnectionDelegate {
    public func connected() {
        setupViewModel()
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
        viewModel.isRefresh = true
    }
    
    public func connecting() {}
    
    public func disconnected() {}
}
