//  CometChatBannedMembers2.swift
//  Created by admin on 22/11/22.
//

import UIKit
import Foundation
import CometChatSDK

@MainActor
open class CometChatBannedMembers: CometChatListBase {
    
    //MARK: - Declaration of View Model
    private var viewModel: BannedMembersViewModel
    
    //MARK: - Declaration of View Properties
    private var options: ((_ group: Group,_ groupMember: GroupMember?) -> [CometChatGroupMemberOption])?
    private var disableUsersPresence: Bool = true
    private var subtitle: ((_ groupMember: GroupMember?) -> UIView)?
    private var listItemView: ((_ groupMember: GroupMember?) -> UIView)?
    private var avatarStyle = AvatarStyle()
    private var bannedMembersStyle = BannedMembersStyle()
    private var statusIndicatorStyle = StatusIndicatorStyle()
    private var hideSeparator: Bool = true
    private var listItemStyle = ListItemStyle()
    override var emptyStateText: String {
        get {
            return "NO_MEMBERS_FOUND".localize()
        }
        set {
            super.emptyStateText = newValue
        }
    }
    private var onItemClick: ((_ bannedMember: GroupMember) -> Void)?
    private var onItemLongClick: ((_ bannedMember: GroupMember) -> Void)?
    private var onError: ((_ error: CometChatException) -> Void)?
    private var onBack: (() -> Void)?
    
    //MARK: - INIT
    public init(group: Group, bannedGroupMembersRequestBuilder: BannedGroupMembersRequest.BannedGroupMembersRequestBuilder? = nil ) {
        viewModel = BannedMembersViewModel(group: group, bannedGroupMembersRequestBuilder: bannedGroupMembersRequestBuilder)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView(style: .insetGrouped)
        registerCell()
        setupAppearance()
        configureOptions()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        CometChat.addConnectionListener("banned-members-sdk-listener", self)
        fetchBannedMembers()
        reloadData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        CometChat.removeConnectionListener("group-members-sdk-listener")
    }
    
    private func fetchBannedMembers() {
        self.showIndicator()
        viewModel.fetchBannedGroupMembers()
    }
    
    private func reloadData() {
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            switch this.viewModel.isSearching {
            case true:
                if this.viewModel.filteredBannedGroupMembers.isEmpty {
                    if let emptyView = this.emptyView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    this.tableView.restore()
                }
            case false:
                if this.viewModel.bannedGroupMembers.isEmpty {
                    if let emptyView = this.emptyView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    this.tableView.restore()
                }
            }
            
            DispatchQueue.main.async {
                this.tableView.reloadData()
                this.hideIndicator()
            }
        }
        viewModel.failure = { [weak self] error in
            guard let this = self else { return }
            DispatchQueue.main.async {
                // this is error call to the user.
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
                            this.viewModel.fetchBannedGroupMembers()
                        }
                    }
                }
            }
        }
        viewModel.reloadAtIndex = { row in
            self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
        }
    }
    
    private func setupAppearance() {
        self.set(searchPlaceholder: "SEARCH".localize())
            .set(title: "BANNED_MEMBERS".localize(), mode: .never)
            .set(backButtonTitle: "CANCEL".localize())
            .show(backButton: true)
            .set(bannedMembersStyle: bannedMembersStyle)
            
        self.hide(search: false)
    }
    
    public func set(bannedMembersStyle: BannedMembersStyle) {
        set(background: [bannedMembersStyle.background.cgColor])
        set(titleColor: bannedMembersStyle.titleColor)
        set(titleFont: bannedMembersStyle.titleFont)
        set(largeTitleFont: bannedMembersStyle.largeTitleFont)
        set(searchBorderColor: bannedMembersStyle.searchBorderColor)
        set(searchBackground: bannedMembersStyle.searchBackgroundColor)
        set(searchCornerRadius: bannedMembersStyle.searchBorderRadius)
        set(searchTextColor: bannedMembersStyle.searchTextColor)
        set(searchTextFont: bannedMembersStyle.searchTextFont)
        set(searchPlaceholderColor: bannedMembersStyle.searchPlaceholderColor)
        set(background: [bannedMembersStyle.background.cgColor])
        set(corner: bannedMembersStyle.cornerRadius)
        set(borderColor: bannedMembersStyle.borderColor)
        set(borderWidth: bannedMembersStyle.borderWidth)
        set(searchBorderColor: bannedMembersStyle.searchBorderColor)
        set(searchBorderWidth: bannedMembersStyle.searchBorderWidth)
        set(searchIconTint: bannedMembersStyle.searchIconTint)
        set(searchClearIconTint: bannedMembersStyle.searchClearIconTint)
        set(searchCancelButtonFont: bannedMembersStyle.searchCancelButtonFont)
        set(searchCancelButtonTint: bannedMembersStyle.searchCancelButtonTint)
        set(backButtonTint: bannedMembersStyle.backIconTint)
        set(searchBorderWidth: bannedMembersStyle.borderWidth)
    }
    
    private func registerCell() {
        registerCellWith(title: CometChatListItem.identifier)
    }
    
    public override func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            viewModel.isSearching = false
            reload()
        case .filter:
            viewModel.isSearching = true
            viewModel.filterBannedGroupMembers(text: text)
        }
    }
    
    public override func onBackCallback() {
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
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
    }
    
    @discardableResult
    public func setOnItemClick(onItemClick: @escaping ((_ bannedMember: GroupMember) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func setOnItemLongClick(onItemLongClick: @escaping ((_ bannedMember: GroupMember) -> Void)) -> Self {
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
    
    public func onSelection(_ onSelection: @escaping ([GroupMember]) -> ()) {
        onSelection(viewModel.selectedBannedMembers)
    }
    
    @discardableResult
    public func setSubtitle(subtitle: ((_ groupMember: GroupMember?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
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
    public func disable(userPresence: Bool) -> Self {
        self.disableUsersPresence = userPresence
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        viewModel.clearList()
        return self
    }
    
    @discardableResult
    public func size() -> Int {
        viewModel.size()
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
    public func remove(groupMember: GroupMember) -> Self {
        viewModel.remove(groupMember: groupMember)
        return self
    }
    
}

extension CometChatBannedMembers {
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching ? viewModel.filteredBannedGroupMembers.count : viewModel.bannedGroupMembers.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem  {
            let bannedGroupMember = viewModel.isSearching ? viewModel.filteredBannedGroupMembers[indexPath.row] : viewModel.bannedGroupMembers[indexPath.row]
            if let name = bannedGroupMember.name {
                listItem.set(title: name.capitalized)
                listItem.set(avatarName: name.capitalized)
            }
            
            if let subTitleView = subtitle?(bannedGroupMember) {
                listItem.set(subtitle: subTitleView)
            } else {
            }
            
            if let customView = listItemView?(bannedGroupMember) {
                listItem.set(customView: customView)
            }
            
            listItem.set(tail: configureTailView())
            
            if let avatarURL = bannedGroupMember.avatar {
                listItem.set(avatarURL: avatarURL)
            }
            
            if !disableUsersPresence {
                switch bannedGroupMember.status {
                case .offline:
                    listItem.statusIndicator.isHidden = true
                case .online:
                    listItem.statusIndicator.isHidden = false
                    listItem.set(statusIndicatorColor: bannedMembersStyle.onlineStatusColor)
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
                this.onItemLongClick?(bannedGroupMember)
            }
            listItem.build()
            return listItem
        }
        return UITableViewCell()
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public override func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let currentOffset = scrollView.contentOffset.y
        if currentOffset > 0 {
            let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
            if maximumOffset - currentOffset <= 10.0 {
                viewModel.fetchBannedGroupMembers()
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        let bannedMember = viewModel.isSearching ? viewModel.filteredBannedGroupMembers[indexPath.row]  : viewModel.bannedGroupMembers[indexPath.row]
        if let options = options?(viewModel.group, bannedMember) {
            for option in options {
                let action =  UIContextualAction(style: .destructive, title: "", handler: { (action,view, completionHandler ) in
                    if option.id == GroupMemberOptionConstants.unban {
                        self.viewModel.unbanGroupMember(member: bannedMember)
                    } else {
                        option.onClick?(bannedMember,self.viewModel.group, indexPath.section, option, self)
                    }
                })
                action.image = option.icon
                action.backgroundColor = option.backgroundColor
                actions.append(action)
            }
        }
        return  UISwipeActionsConfiguration(actions: actions)
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bannedMember = viewModel.isSearching ? viewModel.filteredBannedGroupMembers[indexPath.row] : viewModel.bannedGroupMembers[indexPath.row]
        if let onItemClick = onItemClick {
            // this is a callback to user.
            onItemClick(bannedMember)
        } else {
            if selectionMode == .none {
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                if !viewModel.selectedBannedMembers.contains(bannedMember) {
                    self.viewModel.selectedBannedMembers.append(bannedMember)
                }
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let group = viewModel.isSearching ? viewModel.filteredBannedGroupMembers[indexPath.row] : viewModel.bannedGroupMembers[indexPath.row]
        if let foundGroup = viewModel.selectedBannedMembers.firstIndex(of: group) {
            viewModel.selectedBannedMembers.remove(at: foundGroup)
        }
    }
}

//MARK:  CONFIGURE TAIL LABEL AND BANNED MEMBERS OPTIONS
extension CometChatBannedMembers {
    
    func configureTailView() -> UILabel {
        let label = UILabel()
        label.text = "BANNED".localize()
        label.font = CometChatTheme.typography.text1
        label.textColor = CometChatTheme.palatte.accent700
        return label
    }
    
    private func configureOptions() {
        if options == nil {
            options = { group , groupMember in
                if let groupMember = groupMember {
                    return GroupMembersUtils().getBannedMemberOptions(group: group, groupMember: groupMember) ?? []
                }
                return []
            }
        }
    }
}

extension CometChatBannedMembers: CometChatConnectionDelegate {
    public func connected() {
        fetchBannedMembers()
        reloadData()
    }
    
    public func connecting() {
        
    }
    
    public func disconnected() {
        
    }
}
