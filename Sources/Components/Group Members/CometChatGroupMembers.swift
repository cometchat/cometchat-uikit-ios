//
//  CometChatGroupMembers.swift
 
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatSDK

@MainActor
open class CometChatGroupMembers: CometChatListBase {
    
    // MARK: - Declaration of View Model
    var viewModel: GroupMembersViewModel
    
    // MARK: - Declaration of View Properties
    private var tailView: ((_ groupMember: GroupMember?) -> UIView)?
    private var subtitle: ((_ groupMember: GroupMember?) -> UIView)?
    private var disableUserPresence: Bool = false
    private var listItemView: ((_ groupMember: GroupMember?) -> UIView)?
    private var menus: [UIBarButtonItem]?
    private var options: ((_ group: Group,_ groupMember: GroupMember?) -> [CometChatGroupMemberOption])?
    private var unbanIcon: UIImage?
    private var hideSeparator: Bool = true
    private var groupMembersStyle = GroupMembersStyle()
    private var avatarStyle = AvatarStyle()
    private var statusIndicatorStyle = StatusIndicatorStyle()
    private var listItemStyle = ListItemStyle()
    private(set) var onItemLongClick: ((_ groupMember: GroupMember, _ indexPath: IndexPath) -> Void)?
    private(set) var onItemClick: ((_ groupMember: GroupMember, _ indexPath: IndexPath) -> Void)?
    private(set) var onError: ((CometChatException) -> Void)?
    private(set) var onBack: (() -> Void)?
    
    override var emptyStateText: String {
        get {
            return "NO_MEMBERS_FOUND".localize()
        }
        set {
            super.emptyStateText = newValue
        }
    }
    
    //MARK: - INIT
    public init(group: Group, groupMembersRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder? = nil) {
        viewModel = GroupMembersViewModel(group: group, groupMembersRequestBuilder: groupMembersRequestBuilder)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTableView(style: .insetGrouped)
        registerCells()
        configureOptions()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        CometChat.addConnectionListener("group-members-sdk-listener", self)
        viewModel.connect()
        reloadData()
        fetchData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CometChat.removeConnectionListener("group-members-sdk-listener")
        viewModel.disconnect()
    }
    
    private func fetchData() {
        showIndicator()
        viewModel.fetchGroupsMembers()
    }
    
    private func reloadData() {
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            
            this.reload()
            this.hideIndicator()
            
            switch this.viewModel.isSearching {
            case true:
                if this.viewModel.filteredGroupMembers.isEmpty {
                    if let emptyView = this.emptyView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    this.tableView.restore()
                }
            case false:
                if this.viewModel.groupMembers.isEmpty {
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
            // this is error callback to the user.
            this.onError?(error)
            DispatchQueue.main.async {
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
                            this.viewModel.fetchGroupsMembers()
                        }
                    }
                }
            }
        }
        viewModel.reloadAt = { row in
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
    }
    
    func registerCells() {
        self.registerCellWith(title: CometChatListItem.identifier)
    }
    
    public override func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            viewModel.isSearching = false
            reload()
        case .filter:
            viewModel.isSearching = true
            viewModel.filterGroupMembers(text: text)
        }
    }
   
    override func onBackCallback() {
        if let onBack = onBack {
            onBack()
        } else {
            if self.navigationController != nil {
                if self.navigationController?.viewControllers.first == self {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
               
            }else{
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func setupAppearance() {
        self.set(searchPlaceholder: "SEARCH".localize())
            .set(title: "MEMBERS".localize(), mode: .never)
            .hide(search: false)
            .set(backButtonTitle: "CANCEL".localize())
            .show(backButton: true)
            .set(groupMembersStyle: groupMembersStyle)
        
        self.set(listItemStyle: listItemStyle)
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
    }
    
    @discardableResult
    public func setTailView(tailView: ((_ groupMember: GroupMember?) -> UIView)?) -> Self {
        self.tailView = tailView
        return self
    }
    
    @discardableResult
    public func setSubtitleView(subtitleView: ((_ groupMember: GroupMember?) -> UIView)?) -> Self {
        self.subtitle = subtitleView
        return self
    }
    
    @discardableResult
    public func disable(usersPresence: Bool) -> Self {
        self.disableUserPresence = usersPresence
        return self
    }
    
    public func onSelection(_ onSelection: @escaping ([GroupMember]?) -> ()) {
        onSelection(viewModel.selectedGroupMembers)
    }
    
    @discardableResult
    public func setListItemView(listItemView: ((_ groupMember: GroupMember?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func setOptions(options: ((_ group: Group, _ groupMember: GroupMember?) -> [CometChatGroupMemberOption])?) -> Self {
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
    public func set(unbanIcon: UIImage) -> Self {
        self.unbanIcon = unbanIcon
        return self
    }
    
    @discardableResult
    public func setOnItemClick(onItemClick: @escaping ((_ groupMember: GroupMember, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func setOnItemLongClick(onItemLongClick: @escaping ((_ groupMember: GroupMember, _ indexPath: IndexPath) -> Void)) -> Self {
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
    public func set(groupMemberRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) -> Self {
        viewModel.groupMembersRequestBuilder = groupMemberRequestBuilder
        return self
    }
    
    @discardableResult
    public func set(groupMemberSearchRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) -> Self {
       // if it neccessary, assign the valuel.
        return self
    }
    
    @discardableResult
    public func set(groupMembersStyle: GroupMembersStyle) -> Self {
        set(titleColor: groupMembersStyle.titleColor)
        set(titleFont: groupMembersStyle.titleFont)
        set(largeTitleFont: groupMembersStyle.largeTitleFont)
        set(searchBorderColor: groupMembersStyle.searchBorderColor)
        set(searchBackground: groupMembersStyle.searchBackgroundColor)
        set(searchCornerRadius: groupMembersStyle.searchBorderRadius)
        set(searchTextColor: groupMembersStyle.searchTextColor)
        set(searchTextFont: groupMembersStyle.searchTextFont)
        set(searchPlaceholderColor: groupMembersStyle.searchPlaceholderColor)
        set(background: [groupMembersStyle.background.cgColor])
        set(corner: groupMembersStyle.cornerRadius)
        set(borderColor: groupMembersStyle.borderColor)
        set(borderWidth: groupMembersStyle.borderWidth)
        set(searchBorderColor: groupMembersStyle.searchBorderColor)
        set(searchBorderWidth: groupMembersStyle.searchBorderWidth)
        set(searchIconTint: groupMembersStyle.searchIconTint)
        set(searchClearIconTint: groupMembersStyle.searchClearIconTint)
        set(searchCancelButtonFont: groupMembersStyle.searchCancelButtonFont)
        set(searchCancelButtonTint: groupMembersStyle.searchCancelButtonTint)
        return self
    }
    
    @discardableResult
    public func add(groupMember: GroupMember) -> Self {
        viewModel.add(groupMember: groupMember)
        return self
    }
    
    @discardableResult
    public func update(groupMember: GroupMember) -> Self {
        viewModel.update(groupMember: groupMember)
        return self
    }
    
    @discardableResult
    public func insert(groupMember: GroupMember, at: Int) -> Self {
        viewModel.insert(groupMember: groupMember, at: at)
        return self
    }
    
    @discardableResult
    public func remove(groupMember: GroupMember) -> Self {
        viewModel.remove(groupMember: groupMember)
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        viewModel.clearList()
        return self
    }
    
    public func size() -> Int {
        viewModel.size()
    }
}

extension CometChatGroupMembers {
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: "CometChatListItem", for: indexPath) as? CometChatListItem  {
            let groupMember = viewModel.isSearching ? viewModel.filteredGroupMembers[indexPath.row] : viewModel.groupMembers[indexPath.row]
            if let name = groupMember.name, let uid = CometChat.getLoggedInUser()?.uid {
                if uid == groupMember.uid {
                    listItem.set(title: "YOU".localize())
                } else {
                    listItem.set(title: name.capitalized)
                }
                listItem.set(avatarName: name.capitalized)
            }
            if let avatarURL = groupMember.avatar {
                listItem.set(avatarURL: avatarURL)
            }
            if let subTitleView = subtitle?(groupMember) {
                listItem.set(subtitle: subTitleView)
            }
            if let tailView = tailView?(groupMember) {
                listItem.set(tail: tailView)
            } else {
                listItem.set(tail: configureTailView(group: viewModel.group, groupMember: groupMember))
            }
            
            if let customView = listItemView?(groupMember) {
                listItem.set(customView: customView)
            }
            switch groupMember.status {
            case .offline:
                listItem.statusIndicator.isHidden = true
            case .online:
                listItem.statusIndicator.isHidden = false
                listItem.set(statusIndicatorColor: groupMembersStyle.onlineStatusColor)
            case .available:
                listItem.statusIndicator.isHidden = true
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
                // this is onItemLongClick callback to the user.
                this.onItemLongClick?(groupMember, indexPath)
            }
            listItem.build()
            return listItem
        }
        return UITableViewCell()
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching ? viewModel.filteredGroupMembers.count : viewModel.groupMembers.count
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        if currentOffset > 0 {
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            if maximumOffset - currentOffset <= 10.0 {
                viewModel.fetchGroupsMembers()
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let groupMember = viewModel.isSearching ? viewModel.filteredGroupMembers[indexPath.row] : viewModel.groupMembers[indexPath.row]
        if let onItemClick = onItemClick {
            onItemClick(groupMember, indexPath)
        } else {
            if selectionMode == .none {
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                if !viewModel.selectedGroupMembers.contains(groupMember) {
                    self.viewModel.selectedGroupMembers.append(groupMember)
                }
            }
        }
       
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let group = viewModel.isSearching ? viewModel.filteredGroupMembers[indexPath.row] : viewModel.groupMembers[indexPath.row]
        if let foundGroup = viewModel.selectedGroupMembers.firstIndex(of: group) {
            viewModel.selectedGroupMembers.remove(at: foundGroup)
        }
    }
    
    public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        let groupMember = viewModel.isSearching ? viewModel.filteredGroupMembers[indexPath.row] : viewModel.groupMembers[indexPath.row]
        if let options = options?(viewModel.group,groupMember) {
            for option in options {
                let action =  UIContextualAction(style: .destructive, title: "", handler: { (action,view, completionHandler ) in
                    if option.id == GroupMemberOptionConstants.ban {
                        self.viewModel.banGroupMember(group: self.viewModel.group, member: groupMember)
                    } else if option.id == GroupMemberOptionConstants.kick {
                        self.viewModel.kickGroupMember(group: self.viewModel.group, member: groupMember)
                    } else {
                        option.onClick?(groupMember, self.viewModel.group ,indexPath.section, option, self)
                    }
                })
                action.image = option.icon
                action.title = option.title
                action.backgroundColor = option.backgroundColor
                actions.append(action)
            }
        }
        return  UISwipeActionsConfiguration(actions: actions)
    }
}


extension CometChatGroupMembers {
    
    func configureOptions() {
        if options == nil {
            options = { group , groupMember in
                if let groupMember = groupMember {
                    return GroupMembersUtils().getViewMemberOptions(group: group, groupMember: groupMember) ?? []
                }
                return []
            }
        }
    }
    
    private func configureTailView(group: Group ,groupMember: GroupMember) -> UIView {
        switch GroupMembersUtils.allowScopeChange(group: group, groupMember: groupMember) {
        case true:
            let button = UIButton()
            switch groupMember.scope {
            case .admin:
                if group.owner == groupMember.uid {
                    button.setTitle("OWNER".localize()  + "  " , for: .normal)
                } else {
                    button.setTitle("ADMIN".localize()  + "  " , for: .normal)
                }
            case .moderator:
                button.setTitle("MODERATOR".localize()  + "  " , for: .normal)
            case .participant:
                button.setTitle("PARTICIPANT".localize()  + "  ", for: .normal)
            @unknown default: break
            }
            button.titleLabel?.font = CometChatTheme.typography.subtitle1
            button.setTitleColor(CometChatTheme.palatte.primary, for: .normal)
            button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
            button.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.titleLabel?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.imageView?.transform = CGAffineTransform(scaleX: -1.0, y: 1.0)
            button.isEnabled = true
            if #available(iOS 14.0, *) {
                button.menu = configureMenu(group: group, groupMember: groupMember)
                button.showsMenuAsPrimaryAction = true
            }
            return button
        case false:
            let label = UILabel()
            switch groupMember.scope {
            case .admin:
                if group.owner == groupMember.uid {
                    label.text = "OWNER".localize()  + "  "
                } else {
                    label.text = "ADMIN".localize()  + "  "
                }
            case .moderator:
                label.text = "MODERATOR".localize()  + "  "
            case .participant:
                label.text = "PARTICIPANT".localize()  + "  "
            @unknown default: break
            }
            label.font = CometChatTheme.typography.subtitle1
            label.textColor = CometChatTheme.palatte.accent600
            return label
        }
    }
    
    private func configureMenu(group: Group, groupMember: GroupMember) -> UIMenu {
        switch group.scope {
        case .admin:
            let menuItems = [
                UIAction(title: "ADMIN".localize(), image: nil, handler: { (_) in
                    self.viewModel.changeScope(for: groupMember, scope: .admin)
                }),
                UIAction(title: "PARTICIPANT".localize(), image: nil, handler: { (_) in
                    self.viewModel.changeScope(for: groupMember, scope: .participant)
                }),
                UIAction(title: "MODERATOR".localize(), image:nil, handler: { (_) in
                    self.viewModel.changeScope(for: groupMember, scope: .moderator)
                })
            ]
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        case .moderator:
            let menuItems = [ UIAction(title: "MODERATOR".localize(), image:nil, handler: { (_) in
                self.viewModel.changeScope(for: groupMember, scope: .moderator)
            })]
            return UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
        case .participant: break
        @unknown default: break
        }
        return UIMenu()
    }
}

extension CometChatGroupMembers: CometChatConnectionDelegate {
    public func connected() {
        reloadData()
        fetchData()
    }
    
    public func connecting() {
        
    }
    
    public func disconnected() {
        
    }
}
