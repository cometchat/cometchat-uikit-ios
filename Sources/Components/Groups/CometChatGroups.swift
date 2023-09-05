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
    private var viewModel: GroupsViewModel
   
    // MARK: - Declaration of View Properties
    private var subtitle: ((_ group: Group?) -> UIView)?
    private var listItemView: ((_ group: Group?) -> UIView)?
    private var menus: [UIBarButtonItem]?
    private var options: ((_ group: Group?) -> [CometChatGroupOption])?
    private var hideSeparator: Bool = true
    private var groupsStyle = GroupsStyle()
    private var avatarStyle = AvatarStyle()
    private var statusIndicatorStyle = StatusIndicatorStyle()
    private var listItemStyle = ListItemStyle()
    private (set) var selectionLimit: Int?

    override var emptyStateText: String {
        get {
            return "NO_GROUPS_FOUND".localize()
        }
        set {
            super.emptyStateText = newValue
        }
    }
    private var privateGroupIcon = UIImage(named: "groups-shield", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    private var protectedGroupIcon = UIImage(named: "groups-lock", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    // MARK:- Created for to check CreateGroup Events.
    var createGroupConfiguration: CreateGroupConfiguration?
    var createGroupButton: UIBarButtonItem?
    var createGroupIcon = UIImage(named: "groups-create.png", in: CometChatUIKit.bundle, compatibleWith: nil)
        
    var onItemClick: ((_ group: Group, _ indexPath: IndexPath) -> Void)?
    private var onItemLongClick: ((_ group: Group, _ indexPath: IndexPath) -> Void)?
    private var onError: ((_ error: CometChatException) -> Void)?
    var onBack: (() -> Void)?
    var onDidSelect: ((_ group: Group, _ indexPath: IndexPath) -> Void)?
    
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
    public func setOnBack(onBack: @escaping () -> Void) -> Self {
        self.onBack = onBack
        return self
    }
    
    //MARK: - INIT
    public init(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder = GroupsBuilder.getDefaultRequestBuilder()) {
        viewModel = GroupsViewModel(groupsRequestBuilder: groupsRequestBuilder)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        CometChat.addConnectionListener("groups-sdk-listener", self)
        registerCells()
        selectionMode(mode: selectionMode)
        viewModel.connect()
        reloadData()
        fetchData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CometChat.removeConnectionListener("groups-sdk-listener")
        viewModel.disconnect()
    }
    
    private func fetchData() {
        showIndicator()
        viewModel.fetchGroups()
    }
    
    private func reloadData() {
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            this.reload()
            this.hideIndicator()
            switch this.viewModel.isSearching {
            case true:
                if this.viewModel.filteredGroups.isEmpty {
                    if let emptyView = this.emptyView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    this.tableView.restore()
                }
            case false:
                if this.viewModel.groups.isEmpty {
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
                            this.viewModel.fetchGroups()
                        }
                    }
                }
            }
        }
        viewModel.reloadAt = { row in
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
    }
    
    fileprivate func registerCells() {
        self.registerCellWith(title: CometChatListItem.identifier)
    }

    @discardableResult
    public func set(groupsStyle: GroupsStyle) -> Self {
        set(background: [groupsStyle.background.cgColor])
        set(titleColor: groupsStyle.titleColor)
        set(titleFont: groupsStyle.titleFont)
        set(largeTitleColor: groupsStyle.largeTitleColor)
        set(largeTitleFont: groupsStyle.largeTitleFont)
        set(backButtonTint: groupsStyle.backIconTint)
        set(searchTextFont: groupsStyle.searchTextFont)
        set(searchTextColor: groupsStyle.searchTextColor)
        set(searchBorderColor: groupsStyle.searchBorderColor)
        set(searchBorderWidth: groupsStyle.searchBorderWidth)
        set(searchCornerRadius: groupsStyle.searchBorderRadius)
        set(searchIconTint: groupsStyle.searchIconTint)
        set(searchClearIconTint: groupsStyle.searchClearIconTint)
        set(searchBackground: groupsStyle.searchBackgroundColor)
        set(searchCancelButtonFont: groupsStyle.searchCancelButtonFont)
        set(searchCancelButtonTint: groupsStyle.searchCancelButtonTint)
        set(searchPlaceholderColor: groupsStyle.searchPlaceholderColor)
        set(corner: groupsStyle.cornerRadius)
        set(avatarStyle: groupsStyle.avatarStyle ?? avatarStyle)
        set(listItemStyle: groupsStyle.listItemStyle ?? listItemStyle)
        set(statusIndicatorStyle: groupsStyle.statusIndicatorStyle ?? statusIndicatorStyle)
        setupTableView(style: groupsStyle.tableViewStyle)
        return self
    }
    
    public override func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            viewModel.isSearching = false
            reload()
        case .filter:
            viewModel.isSearching = true
            viewModel.filterGroups(text: text)
        }
    }
    
    public override func onBackCallback() {
        if let onBack = onBack {
            onBack()
        } else {
            switch self.isModal() {
            case true:
                self.dismiss(animated: true, completion: nil)
            case false:
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func setupAppearance() {
        self.set(searchPlaceholder: searchPlaceholder)
            .set(title: title ?? "GROUPS".localize(), mode: .automatic)
            .hide(search: false)
            .set(groupsStyle: groupsStyle)
            .show(backButton: false)
        // MARK:- Created for to check CreateFroup Events.
        createGroupButton = UIBarButtonItem(image: createGroupIcon, style: .plain, target: self, action: #selector(self.didCreateGroupPressed))
        self.navigationItem.rightBarButtonItem = createGroupButton
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
    }
    // MARK:- Created for to check CreateFroup Events.
    @objc func didCreateGroupPressed(){
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            CometChatGroupEvents.emitOnCreateGroupClick()
            let cometChatCreateGroup = CometChatCreateGroup()
            let naviVC = UINavigationController(rootViewController: cometChatCreateGroup)
            this.set(createGroup: cometChatCreateGroup, createGroupConfiguration: this.createGroupConfiguration)
            this.present(naviVC, animated: true)
        }
    }
    
    private func set(createGroup: CometChatCreateGroup, createGroupConfiguration: CreateGroupConfiguration?) {
        if let createGroupConfiguration = createGroupConfiguration {
            
//            if let hideCloseButton = createGroupConfiguration.hideCloseButton {
//                createGroup.hide(create: hideCloseButton)
//            }
            
            if let closeButtonIcon = createGroupConfiguration.closeButtonIcon {
                createGroup.set(backButtonIcon: closeButtonIcon)
            }
            
            if let createButtonIcon = createGroupConfiguration.createButtonIcon {
                createGroup.set(createButtonIcon: createButtonIcon)
            }
            
            if let onCreateGroupClick = createGroupConfiguration.onCreateGroupClick {
                createGroup.setOnCreateGroupClick(onCreateGroupClick: onCreateGroupClick)
            }
            
            if let createGroupStyle = createGroupConfiguration.createGroupStyle {
                createGroup.set(createGroupStyle: createGroupStyle)
            }
            
            if let onError = createGroupConfiguration.onError {
                createGroup.setOnError(onError: onError)
            }
            
            if let onBack = createGroupConfiguration.onBack {
                createGroup.setOnBack(onBack: onBack)
            }
        }
    }
    

    @discardableResult
    public func setSelectionLimit(limit : Int) -> Self {
        self.selectionLimit = limit
        return self
    }
    
}

extension CometChatGroups {
    
    @discardableResult
    public func onSelection(_ onSelection: @escaping ([Group]?) -> ()) -> Self {
        onSelection(viewModel.selectedGroups)
        return self
    }
    
    @discardableResult
    public func setSubtitleView(subtitle: ((_ group: Group?) -> UIView)?) -> Self {
        self.subtitle = subtitle
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
    public func set(createGroupConfiguration: CreateGroupConfiguration) -> Self {
        self.createGroupConfiguration = createGroupConfiguration
        return self
    }
    
    @discardableResult
    public func set(emptyStateMessage: String) -> Self {
        self.emptyStateText = emptyStateMessage
        return self
    }
    
    @discardableResult
    public func set(groupsRequestBuilder: GroupsRequest.GroupsRequestBuilder) -> Self {
        viewModel = GroupsViewModel(groupsRequestBuilder: groupsRequestBuilder)
        return self
    }
    
    @discardableResult
    public func add(group: Group) -> Self {
        viewModel.add(group: group)
        return self
    }
    
    @discardableResult
    public func insert(group: Group, at: Int) -> Self {
        viewModel.insert(group: group, at: at)
        return self
    }
    
    @discardableResult
    public func update(group: Group) -> Self {
        viewModel.update(group: group)
        return self
    }
    
    @discardableResult
    public func remove(group: Group) -> Self {
        viewModel.remove(group: group)
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
}


extension CometChatGroups {
    
    public func getSelectedGroups() -> [Group]{
        return viewModel.selectedGroups
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem  {
            let group = viewModel.isSearching ? viewModel.filteredGroups[indexPath.row] : viewModel.groups[indexPath.row]
            
            if let name = group.name {
                listItem.set(title: name.capitalized)
                listItem.set(avatarName: name.capitalized)
            }
            if let avatarURL = group.icon {
                listItem.set(avatarURL: avatarURL)
            }
            if let subTitleView = subtitle?(group) {
                listItem.set(subtitle: subTitleView)
            } else {
                let label = UILabel()
                if group.membersCount <= 1 {
                    label.text = String(group.membersCount) + " " + "MEMBER".localize()
                } else {
                    label.text =  String(group.membersCount) + " " + "MEMBERS".localize()
                }
                label.textColor = groupsStyle.subtitleColor
                label.font = groupsStyle.subtitleFont
                listItem.set(subtitle: label)
            }
            if let customView = listItemView?(group) {
                listItem.set(customView: customView)
            }
            switch group.groupType {
            case .public: listItem.statusIndicator.isHidden = true
            case .private:
                listItem.statusIndicator.isHidden = false
                listItem.set(statusIndicatorIcon:  privateGroupIcon)
                listItem.set(statusIndicatorIconTint: .white)
                listItem.set(statusIndicatorColor: groupsStyle.privateGroupIconBackgroundColor)
            case .password:
                listItem.statusIndicator.isHidden = false
                listItem.set(statusIndicatorIcon: protectedGroupIcon)
                listItem.set(statusIndicatorIconTint: .white)
                listItem.set(statusIndicatorColor: groupsStyle.protectedGroupIconBackgroundColor)
            @unknown default: listItem.statusIndicator.isHidden = true
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
                this.onItemLongClick?(group, indexPath)
            }
            listItem.build()
           
            if group != nil {
                if let foundGroup = viewModel.selectedGroups.firstIndex(of: group) {
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
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching ? viewModel.filteredGroups.count : viewModel.groups.count
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        if currentOffset > 0 {
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            if maximumOffset - currentOffset <= 10.0 {
                showIndicator()
                viewModel.fetchGroups()
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let group = viewModel.isSearching ? viewModel.filteredGroups[indexPath.row] : viewModel.groups[indexPath.row]
        
        if selectionMode == .none {
            if let onItemClick = onItemClick {
                onItemClick(group, indexPath)
            } else {
                onDidSelect?(group, indexPath)
            }
            
            tableView.deselectRow(at: indexPath, animated: true)
            if group.hasJoined == false {
                if group.groupType == .public ||  group.groupType == .private {
                    viewModel.joinGroup(withGuid: group.guid, name: group.name ?? "", groupType: group.groupType, password: "", indexPath: indexPath)
                }
            } else {
                if let user = CometChat.getLoggedInUser() {
                    CometChatGroupEvents.emitOnGroupMemberJoin(joinedUser: user, joinedGroup: group)
                }
            }
        } else {
            if !viewModel.selectedGroups.contains(group) {
                if ( selectionLimit == nil || (selectionLimit != nil && viewModel.selectedGroups.count <= selectionLimit!)) {
                    self.viewModel.selectedGroups.append(group)
                } else {
                    tableView.allowsSelection = false
                }
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let group = viewModel.isSearching ? viewModel.filteredGroups[indexPath.row] : viewModel.groups[indexPath.row]
        if let foundGroup = viewModel.selectedGroups.firstIndex(of: group) {
            viewModel.selectedGroups.remove(at: foundGroup)
        }
    }

    public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        let group = viewModel.isSearching ? viewModel.filteredGroups[indexPath.row] : viewModel.groups[indexPath.row]
        if let options = options?(group) {
            for option in options {
                let action =  UIContextualAction(style: .destructive, title: "", handler: { (action,view, completionHandler ) in
                    option.onClick?(group, indexPath.section, option, self)
                })
                action.image = option.icon
                action.backgroundColor = option.backgroundColor
                actions.append(action)
            }
        }
        return  UISwipeActionsConfiguration(actions: actions)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if selectionLimit != nil && viewModel.selectedGroups.count >= selectionLimit! {
            return nil  // this disables selection beyond the limit
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        tableView.allowsSelection = true  // Enable selection when deselecting an item
        return indexPath
    }

}

extension CometChatGroups: CometChatConnectionDelegate {
    public func connected() {
        reloadData()
        fetchData()
    }
    
    public func connecting() {
        
    }
    
    public func disconnected() {
        
    }
}
