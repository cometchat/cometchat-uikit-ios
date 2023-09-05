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
    private var viewModel : UsersViewModel
    private var subtitle: ((_ user: User?) -> UIView)?
    private var listItemView: ((_ user: User?) -> UIView)?
    private var options: ((_ user: User?) -> [CometChatUserOption])?
    private var hideSeparator: Bool
    private var disableUsersPresence: Bool
    private var usersStyle: UsersStyle
    private var avatarStyle: AvatarStyle
    private var statusIndicatorStyle: StatusIndicatorStyle
    private var listItemStyle: ListItemStyle
    private var showSectionHeader: Bool = true
    override var emptyStateText: String {
        get { return "NO_USERS_FOUND".localize() }
        set { super.emptyStateText = newValue }
    }
    
    var onItemClick: ((_ user: User, _ indexPath: IndexPath) -> Void)?
    var onItemLongClick: ((_ user: User, _ indexPath: IndexPath) -> Void)?
    var onError: ((_ error: CometChatException) -> Void)?
    var onBack: (() -> Void)?
    var onDidSelect: ((_ user: User, _ indexPath: IndexPath) -> Void)?
    
    private (set) var selectionLimit: Int?
    
    
    // MARK: - Init
    public init(usersRequestBuilder: UsersRequest.UsersRequestBuilder? = UsersBuilder.getDefaultRequestBuilder()) {
        viewModel = UsersViewModel(userRequestBuilder: usersRequestBuilder ?? CometChatSDK.UsersRequest.UsersRequestBuilder().set(limit: 30))
        usersStyle = UsersStyle()
        avatarStyle = AvatarStyle()
        statusIndicatorStyle = StatusIndicatorStyle()
        listItemStyle = ListItemStyle()
        hideSeparator = true
        disableUsersPresence = false
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - ViewController Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        CometChat.addConnectionListener("users-sdk-listener", self)
        registerCells()
        selectionMode(mode: selectionMode)
        viewModel.connect()
        reloadData()
        fetchData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CometChat.removeConnectionListener("users-sdk-listener")
        viewModel.disconnect()
    }
    
    // fetch Data
    private func fetchData() {
        showIndicator()
        viewModel.fetchUsers()
    }
    
    // reloadData
    private func reloadData() {
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            this.reload()
            this.hideIndicator()
            switch this.viewModel.isSearching {
            case true:
                if this.viewModel.filteredUsers.isEmpty {
                    if let emptyView = this.emptyView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    this.tableView.restore()
                }
            case false:
                if this.viewModel.users.isEmpty {
                    if let emptyView = this.emptyView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    this.tableView.restore()
                }
            }
        }
        viewModel.failure = { [weak self] error in
            guard let this = self else { return }
            DispatchQueue.main.async {
                // when error occurred, and this callback is for user.onError
                this.onError?(error)
                this.hideIndicator()
                if !this.hideError {
                    if let errorView = this.errorView {
                        this.tableView.set(customView: errorView)
                    } else {
                        let confirmDialog = CometChatDialog()
                        confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                        confirmDialog.set(cancelButtonText: "CANCEL".localize())
                        if this.errorStateText.isEmpty {
                            confirmDialog.set(error: CometChatServerError.get(error: error))
                        } else {
                            confirmDialog.set(messageText: this.errorStateText)
                        }
                        confirmDialog.open {
                            this.viewModel.fetchUsers()
                        }
                    }
                }
            }
        }
        viewModel.reloadAtIndex = { row in
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
    }
    
    // register cell
    func registerCells() {
        self.registerCellWith(title: CometChatListItem.identifier)
    }
    
    // set appearance
    func setupAppearance() {
        self.set(searchPlaceholder: searchPlaceholder)
            .set(title: self.title ?? "USERS".localize(), mode: .automatic)
            .hide(search: false)
            .show(backButton: false)
            .set(usersStyle: usersStyle)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
    }
    
    // on search
    public override func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            viewModel.isSearching = false
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView.reloadData()
            }
        case .filter:
            viewModel.isSearching = true
            viewModel.filterUsers(text: text)
        }
    }
    
    override func onBackCallback() {
        if let onBack = onBack {
            onBack()
        } else {
            // Default
            self.dismiss(animated: true)
        }
    }
    
    @discardableResult
    public func onSelection(_ onSelection: @escaping ([User]) -> Void) -> Self {
        onSelection(viewModel.selectedUsers)
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
    public func show(sectionHeader: Bool) -> Self {
        self.showSectionHeader = sectionHeader
        return self
    }
    
    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func disable(userPresence: Bool) -> Self {
        self.disableUsersPresence = userPresence
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
    public func setOnBack(onBack: @escaping () -> Void) -> Self {
        self.onBack = onBack
        return self
    }
    
    @discardableResult
    public func add(user: User) -> Self {
        self.viewModel.add(user: user)
        return self
    }
    
    @discardableResult
    public func insert(user: User, at: Int) -> Self {
        self.viewModel.insert(user: user, at: at)
        return self
    }
    
    @discardableResult
    public func remove(user: User) -> Self {
        self.viewModel.remove(user: user)
        return self
    }
    
    @discardableResult
    public func update(user: User) -> Self {
        self.viewModel.update(user: user)
        return self
    }
    
    @discardableResult
    public func setSelectionLimit(limit : Int) -> Self {
        self.selectionLimit = limit
        return self
    }
}

extension CometChatUsers {
    
    // MARK: - TableView delegate and datasource method that inherited from the CometChatListBase.
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = indexPath.section as? Int else { return UITableViewCell() }
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem  {
            let user = viewModel.isSearching ? viewModel.filteredUsers[indexPath.row] : viewModel.sectionUsers[safe: section]?[safe: indexPath.row]
            if let name = user?.name {
                listItem.set(title: name.capitalized)
                listItem.set(avatarName: name.capitalized)
            }
            if let avatarURL = user?.avatar {
                listItem.set(avatarURL: avatarURL)
            }
            if let subTitleView = subtitle?(user) {
                listItem.set(subtitle: subTitleView)
            }
            if let customView = listItemView?(user) {
                listItem.set(customView: customView)
            }
            
            if !disableUsersPresence {
                switch user?.status {
                case .offline:
                    listItem.statusIndicator.isHidden = true
                case .online:
                    listItem.statusIndicator.isHidden = false
                    listItem.set(statusIndicatorColor: usersStyle.onlineStatusColor)
                case .available:
                    listItem.statusIndicator.isHidden = true
                @unknown default: listItem.statusIndicator.isHidden = true
                }
            }
            listItem.set(avatarStyle: avatarStyle)
            listItem.set(statusIndicatorStyle: statusIndicatorStyle)
            listItem.set(listItemStyle: listItemStyle)
            switch selectionMode {
            case .single, .multiple: listItem.allow(selection: true)
            case .none:  listItem.allow(selection: false)
            }
            listItem.onItemLongClick = { [weak self] in
                guard let this = self else { return }
                if let user = user {
                    this.onItemLongClick?(user, indexPath)
                }
               
            }
            listItem.build()
            
            if user != nil {
               if let foundUser = viewModel.selectedUsers.firstIndex(of: user!) {
                    listItem.isSelected = true
                    tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                }else {
                    listItem.isSelected = false
                    tableView.deselectRow(at: indexPath, animated: false)
                }
            }
            
            return listItem
        }
        return UITableViewCell()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        if viewModel.isSearching {
            return 1
        }else{
            return viewModel.sectionUsers.count
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching ? viewModel.filteredUsers.count : viewModel.sectionUsers[safe: section]?.count ?? 0
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if showSectionHeader {
            if viewModel.isSearching {
                return  nil
            } else {
                if let title = ((viewModel.sectionUsers[safe: section]?.first?.name?.capitalized ?? "") as? NSString)?.substring(to: 1) {
                    return  title
                }
                return nil
            }
        }
        return nil
    }
    
    public override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        if currentOffset > 0 {
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            if maximumOffset - currentOffset <= 10.0 {
                showIndicator()
                viewModel.fetchUsers()
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let user = viewModel.isSearching ? viewModel.filteredUsers[indexPath.row] : viewModel.sectionUsers[indexPath.section][indexPath.row]
       
        if selectionMode == .none {
            if let onItemClick = onItemClick {
                onItemClick(user, indexPath)
            } else {
                onDidSelect?(user, indexPath)
            }
        } else {
            if !viewModel.selectedUsers.contains(user) && (selectionLimit == nil || (selectionLimit != nil && viewModel.selectedUsers.count <= selectionLimit!)) {
                self.viewModel.selectedUsers.append(user)
            } else {
                tableView.allowsSelection = false
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let user = viewModel.isSearching ? viewModel.filteredUsers[indexPath.row] : viewModel.sectionUsers[indexPath.section][indexPath.row]
        if let foundUser = viewModel.selectedUsers.firstIndex(of: user) {
            viewModel.selectedUsers.remove(at: foundUser)
        }
    }
    
    public func getSelectedUsers() -> [User]{
        return viewModel.selectedUsers
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if selectionLimit != nil && viewModel.selectedUsers.count >= selectionLimit! {
            return nil  // this disables selection beyond the limit
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        tableView.allowsSelection = true  // Enable selection when deselecting an item
        return indexPath
    }
    
}

extension CometChatUsers {
    
    // MARK: -  Set the UsersStyle
    public func set(usersStyle: UsersStyle) {
        set(background: [usersStyle.background.cgColor])
        set(titleColor: usersStyle.titleColor)
        set(titleFont: usersStyle.titleFont)
        set(largeTitleColor: usersStyle.largeTitleColor)
        set(largeTitleFont: usersStyle.largeTitleFont)
        set(backButtonTint: usersStyle.backIconTint)
        set(searchTextFont: usersStyle.searchTextFont)
        set(searchTextColor: usersStyle.searchTextColor)
        set(searchBorderColor: usersStyle.searchBorderColor)
        set(searchBorderWidth: usersStyle.searchBorderWidth)
        set(searchCornerRadius: usersStyle.searchBorderRadius)
        set(searchIconTint: usersStyle.searchIconTint)
        set(searchClearIconTint: usersStyle.searchClearIconTint)
        set(searchCancelButtonTint: usersStyle.searchCancelButtonTint)
        set(searchBackground: usersStyle.searchBackgroundColor)
        set(searchCancelButtonFont: usersStyle.searchCancelButtonFont)
        set(searchCancelButtonTint: usersStyle.searchCancelButtonTint)
        set(searchPlaceholderColor: usersStyle.searchPlaceholderColor)
        set(corner: usersStyle.cornerRadius)
        setupTableView(style: usersStyle.tableViewStyle)
    }
}

extension CometChatUsers: CometChatConnectionDelegate {
    public func connected() {
        reloadData()
        fetchData()
    }
    
    public func connecting() {
        
    }
    
    public func disconnected() {
        
    }
}
