//
//  CometChatDetails.swift
//  
//
//  Created by Abdullah Ansari on 24/01/23.
//

import Foundation
import UIKit
import CometChatSDK

public class CometChatDetails: CometChatListBase {
    
    private var containerViewForProfile: UIStackView?
    private var showCloseButton: Bool?
    private var closeButtonIcon: UIImage?
    private var hideProfile: Bool = false
    private var hideSectionHeader: Bool = false
    private var subtitleView: ((_ user: User?, _ group: Group?) -> UIView)?
    private var customProfileView: UIView?
    private var data: ((_ user: User?, _ group: Group?) -> [CometChatDetailsTemplate])?
    var templates: [(template: CometChatDetailsTemplate, options: [CometChatDetailsOption])] = []
    private var disableUsersPresence: Bool = false
    private var privateGroupIcon = UIImage(named: "groups-shield", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    private var protectedGroupIcon = UIImage(named: "groups-lock", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    private var onError: ((_ error: CometChatException) -> ())?
    private var onClose: (() -> ())?
    private var listItemStyle = ListItemStyle()
    private var statusIndicatorStyle = StatusIndicatorStyle()
    private var avatarStyle = AvatarStyle()
    private var detailsStyle = DetailsStyle()
    private var actionSheetStyle = ActionSheetStyle()
    private var listItem: CometChatListItem!
    private let screen = UIScreen.main
    private let viewModel = DetailsViewModel()
    
    private var groupMemberConfiguration: GroupMembersConfiguration?
    private var transferOwnershipConfiguration: TransferOwnershipConfiguration?
    private var bannedMembersConfiguration: BannedMembersConfiguration?
    private var addMembersConfiguration: AddMembersConfiguration?
    private var onBack: (() -> Void)?
    
    // MARK: - ViewController's Life cycle.
    public override func viewDidLoad() {
        setupContainerViewForProfile()
        setupTableView(style: .insetGrouped)
        setupProfile()
        fillProfile()
        setupAppearance()
        tableView.reloadData()
        set(style: detailsStyle)
        reloadView()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        connect()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        disconnect()
    }
    
    private func setupData() {
        if data == nil  {
            let primaryTemplates = DetailsUtils().getPrimaryDetailsTemplate()
            let secondaryTemplates = DetailsUtils().getSecondaryDetailsTeamplate()
            set(templates: [primaryTemplates, secondaryTemplates])
        }else{
            set(templates: data?(viewModel.user, viewModel.group))
        }
    }
    
    /// Setup the Container for profile.
    private func setupContainerViewForProfile() {
        if !hideProfile {
            containerViewForProfile = UIStackView()
            if let containerViewForProfile = containerViewForProfile {
                containerViewForProfile.axis = .vertical
                containerViewForProfile.distribution = .fill
                view.addSubview(containerViewForProfile)
                containerViewForProfile.translatesAutoresizingMaskIntoConstraints = false
                containerViewForProfile.topAnchor.constraint(equalTo: view.topAnchor, constant: 80).isActive = true
                containerViewForProfile.heightAnchor.constraint(equalToConstant: 75).isActive = true
                containerViewForProfile.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16.0).isActive = true
                containerViewForProfile.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16.0).isActive = true
            }
        }
    }
    
    private func connect() {
        viewModel.connect()
        CometChatUserEvents.addListener("details-user-event-listener", self)
    }
    
    private func disconnect() {
        viewModel.disconnect()
        CometChatUserEvents.removeListener("details-user-event-listener")
    }
    
    /// set the profile
    func setupProfile() {
        if let customProfileView = customProfileView {
            containerViewForProfile?.addArrangedSubview(customProfileView)
        } else {
            listItem = Bundle.module.loadNibNamed(CometChatListItem.identifier, owner: self, options: nil)![0] as? CometChatListItem
            listItem.set(listItemStyle: listItemStyle)
            containerViewForProfile?.addArrangedSubview(listItem)
            listItem.translatesAutoresizingMaskIntoConstraints = false
            listItem.tailViewWidth.constant = 0
            listItem.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: 10))
            listItem.heightAnchor.constraint(equalToConstant: 72).isActive = true
        }
    }
    
    ///  Assign data to the profille.
    func fillProfile() {
        if let user = viewModel.user, let name = user.name {
            listItem.set(title: name)
            listItem.set(avatarName: name.capitalized)
            // subtitle for user.
            if let subtitleView = subtitleView?(user, nil) {
                listItem.set(subtitle: subtitleView)
            } else {
                let label = UILabel()
                switch user.status {
                case .online:
                    label.text = DetailConstants.onlineText
                case .offline:
                    label.text = DetailConstants.offlineText
                default:
                    label.text = DetailConstants.offlineText
                    break
                }
                label.textColor = detailsStyle.listItemsubTitleColor
                label.font = detailsStyle.listItemsubTitleFont
                listItem.set(subtitle: label)
            }
            listItem.hide(statusIndicator: disableUsersPresence)
            if !disableUsersPresence {
                switch user.status {
                case .online :
                    listItem.hide(statusIndicator: false)
                    listItem.set(statusIndicatorColor: detailsStyle.onlineStatusColor)
                case .offline:
                    listItem.hide(statusIndicator: true)
                case .available:
                    listItem.hide(statusIndicator: true)
                @unknown default:
                    listItem.hide(statusIndicator: true)
                }
            }
            if let avatarURL = user.avatar {
                listItem.set(avatarURL: avatarURL)
            }
        }
        if let group = viewModel.group, let name = group.name {
            listItem.set(title: name)
            listItem.set(avatarName: name.capitalized)
            if let icon = group.icon {
                listItem.set(avatarURL: icon)
            }
            switch group.groupType {
            case .public: listItem.statusIndicator.isHidden = true
            case .private:
                listItem.statusIndicator.isHidden = false
                listItem.set(statusIndicatorIcon:  privateGroupIcon)
                listItem.set(statusIndicatorIconTint: .white)
                listItem.set(statusIndicatorColor: detailsStyle.privateGroupIconBackgroundColor)
            case .password:
                listItem.statusIndicator.isHidden = false
                listItem.set(statusIndicatorIcon: protectedGroupIcon)
                listItem.set(statusIndicatorIconTint: .white)
                listItem.set(statusIndicatorColor: detailsStyle.protectedGroupIconBackgroundColor)
            @unknown default: listItem.statusIndicator.isHidden = true
            }
            if let subTitleView = subtitleView?(nil, group) {
                listItem.set(subtitle: subTitleView)
            } else {
                let label = UILabel()
                if group.membersCount <= 1 {
                    label.text = String(group.membersCount) + " " + "MEMBER".localize()
                } else {
                    label.text =  String(group.membersCount) + " " + "MEMBERS".localize()
                }
                label.textColor = detailsStyle.listItemsubTitleColor
                label.font = detailsStyle.listItemsubTitleFont
                listItem.set(subtitle: label)
            }
        }
        listItemStyle.set(titleFont: detailsStyle.listItemTitleFont)
        listItemStyle.set(titleColor: detailsStyle.listItemTitleColor)
        listItem.set(listItemStyle: listItemStyle)
        listItem.set(avatarStyle: avatarStyle)
        listItem.set(statusIndicatorStyle: statusIndicatorStyle)
        listItem.build()
    }
    
    /// setup the tableview.
    override func setupTableView(style: UITableView.Style) {
        tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .clear
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: containerViewForProfile?.bottomAnchor ?? view.topAnchor, constant: 0).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.heightAnchor.constraint(equalTo: view.heightAnchor, constant:  -80).isActive = true
        tableView.register(UINib(nibName: CometChatActionItem.identifier, bundle: CometChatUIKit.bundle), forCellReuseIdentifier: CometChatActionItem.identifier)
    }
    
    /// set the aapearance.
    func setupAppearance() {
        self.view.backgroundColor = detailsStyle.background
        set(title: DetailConstants.detailsText, mode: .never)
        set(titleColor: CometChatTheme.palatte.accent)
        hide(search: true)
        set(backButtonTitle: DetailConstants.cancelText)
        show(backButton: true)
        set(background: [CometChatTheme.palatte.secondary.cgColor])
    }
    
    /// reloade view while performing action.
    private func reloadView() {
        // When leave group.
        viewModel.onLeaveGroup = { [weak self] leave in
            guard let this = self else { return }
            let alert = UIAlertController(title: "", message: leave == .owner ? DetailConstants.transferOwnershipMessageText : DetailConstants.userLeaveGroupWarningText, preferredStyle: .alert)
            let okAction = UIAlertAction(title: leave == .owner ?  DetailConstants.transferOwnershipText : DetailConstants.leaveText, style: .default) { action in
                guard let group = this.viewModel.group else { return }
                switch leave {
                case .owner:
                    let transferOwnership = CometChatTransferOwnership(group: group,groupMembersRequestBuilder: this.transferOwnershipConfiguration?.groupMemberRequestBuilder)
                    this.set(transferOwnership: transferOwnership, transferOwnershipConfiguration: this.transferOwnershipConfiguration)
                    let navigationController = UINavigationController(rootViewController: transferOwnership)
                    this.present(navigationController, animated: true)
                case .other:
                    if let group = this.viewModel.group {
                        this.viewModel.leave(group: group)
                    }
                }
            }
            let cancelAction = UIAlertAction(title: DetailConstants.cancelText, style: .cancel) { action in
                // when user click on cancel action.
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            this.present(alert, animated: true)
        }
        
        viewModel.onLeaveSuccess = {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        
        // when delete group.
        viewModel.onDeleteGroup = { [weak self] in
            guard let this = self else { return }
            let alert = UIAlertController(title: "", message: DetailConstants.userDeleteGroupWarningText, preferredStyle: .alert)
            let okAction = UIAlertAction(title: DetailConstants.deleteText, style: .default) { _ in
                if let group = this.viewModel.group {
                    this.viewModel.delete(group: group)
                }
            }
            let cancelAction = UIAlertAction(title: DetailConstants.cancelText, style: .cancel) { action in
                // when user click on cancel action.
            }
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            alert.view.tintColor = CometChatTheme.palatte.primary
            this.present(alert, animated: true, completion: nil)
        }
        
        viewModel.onDeleteGroupSuccess = {
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
    }
    
    @discardableResult
    public func hide(profile: Bool) -> Self {
        self.hideProfile = profile
        return self
    }
    
    @discardableResult
    public func set(user: User?) -> Self {
        if let user = user {
            self.viewModel.user = user
        }
        setupData()
        return self
    }
    
    @discardableResult
    public func set(group: Group?) -> Self {
        if let group = group {
            self.viewModel.group = group
        }
        setupData()
        return self
    }
    
    @discardableResult
    public func update(user: User?) -> Self {
        if user?.uid == viewModel.user?.uid {
            self.viewModel.user = user
        }
        self.templates.removeAll()
        setupData()
        return self
    }
    
    @discardableResult
    public func update(group: Group?) -> Self {
        if group?.guid == viewModel.group?.guid {
            self.viewModel.group = group
        }
        self.templates.removeAll()
        setupData()
        return self
    }
    
    @discardableResult
    public func set(detailsStyle: DetailsStyle) -> Self {
        self.detailsStyle = detailsStyle
        return self
    }
    
    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> Self {
        self.statusIndicatorStyle = statusIndicatorStyle
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
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
    public func disable(userPreference: Bool) -> Self {
        self.disableUsersPresence = userPreference
        return self
    }
    
    @discardableResult
    public func setData(data: ((_ user: User?, _ group: Group?) -> [CometChatDetailsTemplate])?) -> Self {
        self.data = data
        return self
    }
    
    @discardableResult
    public func set(customProfileView: UIView) -> Self {
        self.customProfileView = customProfileView
        return self
    }
    
    @discardableResult
    public func set(subTitleView: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
        self.subtitleView = subTitleView
        return self
    }
    
    @discardableResult
    public func set(closeButtonIcon: UIImage) -> Self {
        set(backButtonIcon: closeButtonIcon)
        return self
    }
    
    @discardableResult
    public func show(closeButton: Bool) -> Self {
        show(backButton: closeButton)
        return self
    }
    
    @discardableResult
    public func set(onClose: (() -> ())? ) -> Self {
        self.onClose = onClose
        return self
    }
    
    @discardableResult
    public func setOnError(onError: ((_ error: CometChatException) -> ())? ) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func setOnBack(onBack: @escaping (() -> Void)) -> Self {
        self.onBack = onBack
        return self
    }
    
    @discardableResult
    public func set(groupMemberConfiguration: GroupMembersConfiguration) -> Self {
        self.groupMemberConfiguration = groupMemberConfiguration
        return self
    }
    
    @discardableResult
    public func set(transferOwnershipConfiguration: TransferOwnershipConfiguration) -> Self {
        self.transferOwnershipConfiguration = transferOwnershipConfiguration
        return self
    }
    
    @discardableResult
    public func set(bannedMembersConfiguration: BannedMembersConfiguration) -> Self {
        self.bannedMembersConfiguration = bannedMembersConfiguration
        return self
    }
    
    @discardableResult
    public func set(addMembersConfiguration: AddMembersConfiguration) -> Self {
        self.addMembersConfiguration = addMembersConfiguration
        return self
    }
    
    @discardableResult
    public func remove(option: CometChatDetailsOption, templateID: String) -> Self {
        if let index = templates.firstIndex(where: {$0.template.id == templateID}), let optionIndex = templates[index].options.firstIndex(where: {$0.id == option.id }) {
            templates[index].options.remove(at: optionIndex)
            self.tableView.reloadSections([index], with: .automatic)
        }
        return self
    }
    
    @discardableResult
    public func add(option: CometChatDetailsOption, templateID: String) -> Self {
        if let index = templates.firstIndex(where: {$0.template.id == templateID}) {
            templates[index].options.append(option)
            self.tableView.reloadSections([index], with: .automatic)
        }
        return self
    }
    
    @discardableResult
    public func update(oldOption: CometChatDetailsOption, newOption: CometChatDetailsOption, templateID: String) -> Self {
        if let index = templates.firstIndex(where: {$0.template.id == templateID}), let optionIndex = templates[index].options.firstIndex(where: {$0.id == oldOption.id }) {
            templates[index].options[optionIndex] = newOption
            self.tableView.reloadSections([index], with: .automatic)
        }
        return self
    }
    
    @discardableResult
    public func set(templates: [CometChatDetailsTemplate]?) -> Self {
        if let templates = templates {
            for template in templates {
                if let options = template.options?(viewModel.user,viewModel.group) {
                    self.templates.append((template: template, options: options))
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        return self
    }
    
    private func set(style: DetailsStyle) {
        set(titleColor: style.titleColor)
        set(titleFont: style.titleFont)
        set(backButtonTint: style.backIconTint)
        set(background: [style.background.cgColor])
        set(corner: style.cornerRadius)
        set(borderWidth: style.borderWidth)
        set(borderColor: style.borderColor)
    }
    
    override func onBackCallback() {
        if let onBack = onBack {
            onBack()
        } else {
            dismiss(animated: true)
        }
    }
    
}

// TableView's Methods.
extension CometChatDetails {
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return templates.count
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !hideSectionHeader {
            let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: 25))
            let sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: returnedView.frame.size.width, height: 25))
            sectionTitle.text = templates[safe: section]?.template.title ?? ""
            if #available(iOS 13.0, *) {
                sectionTitle.textColor = detailsStyle.headerTextColor
                sectionTitle.font = detailsStyle.headerTextFont
                returnedView.backgroundColor = detailsStyle.headerBackground
            } else {}
            returnedView.addSubview(sectionTitle)
            return returnedView
        }
        return nil
    }
    
    public  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let template = templates[safe: indexPath.section],  let option = template.options[safe: indexPath.row], let height = template.options.isEmpty ? 0 : option.height {
            return height
        }
        return UITableView.automaticDimension
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let template = templates[safe: section] {
            return template.options.count
        }
        return 0
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let template = templates[safe: indexPath.section], let option = template.options[safe: indexPath.row] {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CometChatActionItem.identifier, for: indexPath) as? CometChatActionItem {
                cell.selectionStyle = .none
                cell.name.text = option.title
                cell.name.textColor = option.titleColor
                cell.name.font = option.titleFont
                cell.trailingView.isHidden = false
                cell.leadingIcon.isHidden = true
                cell.leadingIconView.isHidden = true
                if template.options.count == 1 {
                    cell.background.roundViewCorners(corner: CometChatCornerStyle(topLeft: true, topRight: true, bottomLeft: true, bottomRight: true, cornerRadius: 10.0))
                } else {
                    if indexPath.row == 0 {
                        cell.background.roundViewCorners(corner: CometChatCornerStyle(topLeft: true, topRight: true, bottomLeft: false, bottomRight: false, cornerRadius: 10.0))
                    } else if indexPath.row == template.options.count - 1 {
                        cell.background.roundViewCorners(corner: CometChatCornerStyle(topLeft: false, topRight: false, bottomLeft: true, bottomRight: true, cornerRadius: 10.0))
                    }
                }
                return cell
            }
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let template = templates[safe: indexPath.section], let option = template.options[safe: indexPath.row] {
            
            switch option.id {
            case UserOptionConstants.viewProfile:
                if let link = viewModel.user?.link, !link.isEmpty {
                    guard let url = URL(string: link) else { return }
                    UIApplication.shared.open(url)
                }
            case GroupOptionConstants.viewMembers:
                if let group = viewModel.group {
                    let cometChatGroupMembers = CometChatGroupMembers(group: group,groupMembersRequestBuilder: groupMemberConfiguration?.groupMemberRequestBuilder)
                    set(groupMembers: cometChatGroupMembers, groupMembersConfiguration: groupMemberConfiguration)
                    self.navigationController?.pushViewController(cometChatGroupMembers, animated: true)
                }
            case GroupOptionConstants.addMembers:
                if let group = viewModel.group {
                    let cometChatAddMembers = CometChatAddMembers(group: group, userRequestBuilder: addMembersConfiguration?.usersRequestBuilder)
                    set(addMembers: cometChatAddMembers, addMembersConfiguration: addMembersConfiguration)
                    self.navigationController?.pushViewController(cometChatAddMembers, animated: true)
                }
            case GroupOptionConstants.bannedMembers:
                if let group = viewModel.group {
                    let cometChatBannedMembers = CometChatBannedMembers(group: group,bannedGroupMembersRequestBuilder: bannedMembersConfiguration?.bannedMembersRequestBuilder)
                    set(bannedMembers: cometChatBannedMembers, bannedMembersConfiguration: bannedMembersConfiguration)
                    self.navigationController?.pushViewController(cometChatBannedMembers, animated: true)
                }
            case UserOptionConstants.block:
                viewModel.blockUser()
            case UserOptionConstants.unblock:
                viewModel.unBlockUser()
            case GroupOptionConstants.leave:
                viewModel.leaveGroup()
            case GroupOptionConstants.delete:
                viewModel.deleteGroup()
            default:
                option.onClick?(viewModel.user, viewModel.group, indexPath.section , option, self)
            }
        }
    }
    
    
    private func set(addMembers: CometChatAddMembers, addMembersConfiguration: AddMembersConfiguration?) {
        
        if let addMembersConfiguration = addMembersConfiguration {
            
            if let subtitleView = addMembersConfiguration.subtitleView {
                addMembers.setSubtitle(subtitle: subtitleView)
            }
            
            if let disableUsersPresence = addMembersConfiguration.disableUsersPresence {
                addMembers.disable(userPresence: disableUsersPresence)
            }
            
            if let title = addMembersConfiguration.title {
                set(title: title, mode: addMembersConfiguration.titleMode)
            }
            if let emptyStateText = addMembersConfiguration.emptyStateText {
                set(emptyStateText: emptyStateText)
            }
            if let errorStateText = addMembersConfiguration.errorStateText {
                set(errorStateText: errorStateText)
            }
            
            if let listItemView = addMembersConfiguration.listItemView {
                addMembers.setListItemView(listItemView: listItemView)
            }
            
            if let menus = addMembersConfiguration.menus {
                addMembers.set(menus: menus)
            }
            
            if let options = addMembersConfiguration.options {
                addMembers.setOptions(options: options)
            }
            
            if let hideSeparator = addMembersConfiguration.hideSeparator {
                addMembers.hide(separator: hideSeparator)
            }
            
            if let searchPlaceholder = addMembersConfiguration.searchPlaceholder {
                addMembers.set(searchPlaceholder: searchPlaceholder)
            }
            
            if let backButton = addMembersConfiguration.backButton {
                addMembers.set(backButtonIcon: backButton)
            }
            
            if let showBackButton = addMembersConfiguration.showBackButton {
                addMembers.show(backButton: showBackButton)
            }
            if let selectionMode = addMembersConfiguration.selectionMode {
                addMembers.selectionMode(mode: selectionMode)
            }
            
            if let onSelect = addMembersConfiguration.onSelection {
                addMembers.onSelection(onSelect)
            }
            
            if let searchBoxIcon = addMembersConfiguration.searchBoxIcon {
                addMembers.set(searchIcon: searchBoxIcon)
            }
            
            if let hideSearch = addMembersConfiguration.hideSearch {
                addMembers.hide(search: hideSearch)
            }
            
            if let emptyView = addMembersConfiguration.emptyStateView {
                addMembers.set(emptyView: emptyView)
            }
            
            if let errorView = addMembersConfiguration.errorStateView {
                addMembers.set(errorView: errorView)
            }
          
            if let onItemClick = addMembersConfiguration.onItemClick {
                addMembers.setOnItemClick(onItemClick: onItemClick)
            }
            
            if let onItemLongClick = addMembersConfiguration.onItemLongClick {
                addMembers.setOnItemLongClick(onItemLongClick: onItemLongClick)
            }
            
            if let onError = addMembersConfiguration.onError {
                addMembers.setOnError(onError: onError)
            }
            
            if let statusIndicatorStyle = addMembersConfiguration.statusIndicatorStyle {
                addMembers.set(statusIndicatorStyle: statusIndicatorStyle)
            }
    
            if let listItemStyle = addMembersConfiguration.listItemStyle {
                addMembers.set(listItemStyle: listItemStyle)
            }
            
            if let onBack = addMembersConfiguration.onBack {
                addMembers.setOnBack(onBack: onBack)
            }
        
        }
    }
    
    private func set(groupMembers: CometChatGroupMembers, groupMembersConfiguration: GroupMembersConfiguration?) {
        
        if let groupMemberConfiguration = groupMembersConfiguration {
            
            if let title = groupMemberConfiguration.title {
                set(title: title, mode: groupMemberConfiguration.titleMode)
            }
            if let emptyStateText = groupMemberConfiguration.emptyStateText {
                set(emptyStateText: emptyStateText)
            }
            if let errorStateText = groupMemberConfiguration.errorStateText {
                set(errorStateText: errorStateText)
            }
            
            if let menus = groupMemberConfiguration.menus {
                groupMembers.set(menus: menus)
            }
            
            if let hideSeparator = groupMemberConfiguration.hideSeparator {
                groupMembers.hide(separator: hideSeparator)
            }
            
            if let searchPlaceholder = groupMemberConfiguration.searchPlaceholder {
                groupMembers.set(searchPlaceholder: searchPlaceholder)
            }
            
            if let backButton = groupMemberConfiguration.backButton {
                groupMembers.set(backButtonIcon: backButton)
            }
            
            if let showBackButton = groupMemberConfiguration.showBackButton {
                groupMembers.show(backButton: showBackButton)
            }
            if let selectionMode = groupMemberConfiguration.selectionMode {
                groupMembers.selectionMode(mode: selectionMode)
            }
            
            if let searchBoxIcon = groupMemberConfiguration.searchBoxIcon {
                groupMembers.set(searchIcon: searchBoxIcon)
            }
            
            if let hideSearch = groupMemberConfiguration.hideSearch {
                groupMembers.hide(search: hideSearch)
            }
            
            if let emptyView = groupMemberConfiguration.emptyStateView {
                groupMembers.set(emptyView: emptyView)
            }
            
            if let errorView = groupMemberConfiguration.errorStateView {
                groupMembers.set(errorView: errorView)
            }
            
            if let subtitleView = groupMemberConfiguration.subtitleView {
                groupMembers.setSubtitleView(subtitleView: subtitleView)
            }
            
            if let disableUsersPresence = groupMemberConfiguration.disableUsersPresence {
                groupMembers.disable(usersPresence: disableUsersPresence)
            }
            
            if let listItemView = groupMemberConfiguration.listItemView {
                groupMembers.setListItemView(listItemView: listItemView)
            }
            
            if let options = groupMemberConfiguration.options {
                groupMembers.setOptions(options: options)
            }
            
            if let onSelect = groupMemberConfiguration.onSelection {
                // TODO: - check
                groupMembers.onSelection(onSelect)
            }
            
            if let unbanIcon = groupMemberConfiguration.unbanIcon {
                groupMembers.set(unbanIcon: unbanIcon)
            }
            
            if let tailView = groupMemberConfiguration.tailView {
                groupMembers.setTailView(tailView: tailView)
            }
            
            if let onItemLongClick = groupMemberConfiguration.onItemLongClick {
                groupMembers.setOnItemLongClick(onItemLongClick: onItemLongClick)
            }
            
            if let onItemClick = groupMemberConfiguration.onItemClick {
                groupMembers.setOnItemClick(onItemClick: onItemClick)
            }
            
            if let onError = groupMemberConfiguration.onError {
                groupMembers.setOnError(onError: onError)
            }
            
            if let onBack = groupMemberConfiguration.onBack {
                groupMembers.setOnBack(onBack: onBack)
            }
            
            if let statusIndicatorStyle = groupMemberConfiguration.statusIndicatorStyle {
                groupMembers.set(statusIndicatorStyle: statusIndicatorStyle)
            }
            
            if let avatarStyle = groupMemberConfiguration.avatarStyle {
                groupMembers.set(avatarStyle: avatarStyle)
            }
            
            if let listItemStyle = groupMemberConfiguration.listItemStyle {
                groupMembers.set(listItemStyle: listItemStyle)
            }
            
            if let groupMembersStyle = groupMemberConfiguration.groupMembersStyle {
                groupMembers.set(groupMembersStyle: groupMembersStyle)
            }
            
            if let groupMembersRequestBuilder = groupMembersConfiguration?.groupMemberRequestBuilder {
                groupMembers.set(groupMemberRequestBuilder: groupMembersRequestBuilder)
            }
            
            if let groupMembersSearchRequestBuilder = groupMemberConfiguration.groupMemberSearchRequestBuilder {
                groupMembers.set(groupMemberSearchRequestBuilder: groupMembersSearchRequestBuilder)
            }
            
        }
    }
    
    private func set(bannedMembers: CometChatBannedMembers, bannedMembersConfiguration: BannedMembersConfiguration?) {
        
        if let bannedMembersConfiguration = bannedMembersConfiguration {
            
            if let subtitleView = bannedMembersConfiguration.subtitleView {
                bannedMembers.setSubtitle(subtitle: subtitleView)
            }
            
            if let disableUsersPresence = bannedMembersConfiguration.disableUsersPresence {
                bannedMembers.disable(userPresence: disableUsersPresence)
            }
            
            if let title = bannedMembersConfiguration.title {
                set(title: title, mode: bannedMembersConfiguration.titleMode)
            }
            if let emptyStateText = bannedMembersConfiguration.emptyStateText {
                set(emptyStateText: emptyStateText)
            }
            if let errorStateText = bannedMembersConfiguration.errorStateText {
                set(errorStateText: errorStateText)
            }
            
            if let listItemView = bannedMembersConfiguration.listItemView {
                bannedMembers.setListItemView(listItemView: listItemView)
            }
            
            if let menus = bannedMembersConfiguration.menus {
                bannedMembers.set(menus: menus)
            }
            
            if let options = bannedMembersConfiguration.options {
                bannedMembers.setOptions(options: options)
            }
            
            if let hideSeparator = bannedMembersConfiguration.hideSeparator {
                bannedMembers.hide(separator: hideSeparator)
            }
            
            if let searchPlaceholder = bannedMembersConfiguration.searchPlaceholder {
                bannedMembers.set(searchPlaceholder: searchPlaceholder)
            }
            
            if let backButtonIcon = bannedMembersConfiguration.backButtonIcon {
                bannedMembers.set(backButtonIcon: backButtonIcon)
            }
            
            if let showBackButton = bannedMembersConfiguration.showBackButton {
                bannedMembers.show(backButton: showBackButton)
            }
            
            if let selectionMode = bannedMembersConfiguration.selectionMode {
                bannedMembers.selectionMode(mode: selectionMode)
            }
            
            if let onSelect = bannedMembersConfiguration.onSelection {
                bannedMembers.onSelection(onSelect)
            }
            
            if let searchBoxIcon = bannedMembersConfiguration.searchBoxIcon {
                bannedMembers.set(searchIcon: searchBoxIcon)
            }
            
            if let hideSearch = bannedMembersConfiguration.hideSearch {
                bannedMembers.hide(search: hideSearch)
            }
            
            if let emptyView = bannedMembersConfiguration.emptyStateView {
                bannedMembers.set(emptyView: emptyView)
            }
            
            if let errorView = bannedMembersConfiguration.errorStateView {
                bannedMembers.set(errorView: errorView)
            }
            
            if let onItemLongClick = bannedMembersConfiguration.onItemLongClick {
                bannedMembers.setOnItemLongClick(onItemLongClick: onItemLongClick)
            }
            
            if let onItemClick = bannedMembersConfiguration.onItemClick {
                bannedMembers.setOnItemClick(onItemClick: onItemClick)
            }
            
            if let onError = bannedMembersConfiguration.onError {
                bannedMembers.setOnError(onError: onError)
            }
            
            if let onBack = bannedMembersConfiguration.onBack {
                bannedMembers.setOnBack(onBack: onBack)
            }
            
            if let statusIndicatorStyle = bannedMembersConfiguration.statusIndicatorStyle {
                bannedMembers.set(statusIndicatorStyle: statusIndicatorStyle)
            }
            
            if let avatarStyle = bannedMembersConfiguration.avatarStyle {
                bannedMembers.set(avatarStyle: avatarStyle)
            }
            
            if let bannedMembersStyle = bannedMembersConfiguration.bannedMembersStyle {
                bannedMembers.set(bannedMembersStyle: bannedMembersStyle)
            }
            
            if let listItemStyle = bannedMembersConfiguration.listItemStyle {
                bannedMembers.set(listItemStyle: listItemStyle)
            }
        }
    }
    
    private func set(transferOwnership: CometChatTransferOwnership, transferOwnershipConfiguration: TransferOwnershipConfiguration?) {
        
        guard let transferOwnershipConfiguration = transferOwnershipConfiguration else { return }
        if let onTransferOwnership = transferOwnershipConfiguration.onTransferOwnership {
            transferOwnership.setOnTransferOwnership(onTransferOwnership: onTransferOwnership)
        }
        
        if let submitIcon = transferOwnershipConfiguration.submitIcon {
            transferOwnership.set(submitIcon: submitIcon)
        }
        
        if let selectIcon = transferOwnershipConfiguration.selectIcon {
            transferOwnership.set(selectIcon: selectIcon)
        }
        
        if let transferOwnershipStyle = transferOwnershipConfiguration.transferOwnershipStyle {
            transferOwnership.set(transferOwnerShipStyle: transferOwnershipStyle)
        }
        
        if let menus = transferOwnershipConfiguration.menus {
            transferOwnership.set(menus: menus)
        }
        
        if let hideSeparator = transferOwnershipConfiguration.hideSeparator {
            transferOwnership.hide(separator: hideSeparator)
        }
        
        if let searchPlaceholder = transferOwnershipConfiguration.searchPlaceholder {
            transferOwnership.set(searchPlaceholder: searchPlaceholder)
        }
        
        if let backButton = transferOwnershipConfiguration.backButton {
            transferOwnership.set(backButtonIcon: backButton)
        }
        
        if let showBackButton = transferOwnershipConfiguration.showBackButton {
            transferOwnership.show(backButton: showBackButton)
        }
        if let selectionMode = transferOwnershipConfiguration.selectionMode {
            transferOwnership.selectionMode(mode: selectionMode)
        }
        
        if let searchBoxIcon = transferOwnershipConfiguration.searchBoxIcon {
            transferOwnership.set(searchIcon: searchBoxIcon)
        }
        
        if let hideSearch = transferOwnershipConfiguration.hideSearch {
            transferOwnership.hide(search: hideSearch)
        }
        
        if let emptyView = transferOwnershipConfiguration.emptyStateView {
            transferOwnership.set(emptyView: emptyView)
        }
        
        if let errorView = transferOwnershipConfiguration.errorStateView {
            transferOwnership.set(errorView: errorView)
        }
        
        if let subtitleView = transferOwnershipConfiguration.subtitleView {
            transferOwnership.setSubtitleView(subtitleView: subtitleView)
        }
        
        if let disableUsersPresence = transferOwnershipConfiguration.disableUsersPresence {
            transferOwnership.disable(usersPresence: disableUsersPresence)
        }
        
        if let listItemView = transferOwnershipConfiguration.listItemView {
            transferOwnership.setListItemView(listItemView: listItemView)
        }
        
        if let options = transferOwnershipConfiguration.options {
            transferOwnership.setOptions(options: options)
        }
        
        if let onSelection = transferOwnershipConfiguration.onSelection {
            transferOwnership.onSelection(onSelection)
        }
        
        if let unbanIcon = transferOwnershipConfiguration.unbanIcon {
            transferOwnership.set(unbanIcon: unbanIcon)
        }
        
        if let tailView = transferOwnershipConfiguration.tailView {
            transferOwnership.setTailView(tailView: tailView)
        }
        
        if let onItemLongClick = transferOwnershipConfiguration.onItemLongClick {
            transferOwnership.setOnItemLongClick(onItemLongClick: onItemLongClick)
        }
        
        if let onItemClick = transferOwnershipConfiguration.onItemClick {
            transferOwnership.setOnItemClick(onItemClick: onItemClick)
        }
        
        if let onError = transferOwnershipConfiguration.onError {
            transferOwnership.setOnError(onError: onError)
        }
        
        if let onBack = transferOwnershipConfiguration.onBack {
            transferOwnership.setOnBack(onBack: onBack)
        }
        
        if let statusIndicatorStyle = transferOwnershipConfiguration.statusIndicatorStyle {
            transferOwnership.set(statusIndicatorStyle: statusIndicatorStyle)
        }
        
        if let avatarStyle = transferOwnershipConfiguration.avatarStyle {
            transferOwnership.set(avatarStyle: avatarStyle)
        }
        
        if let listItemStyle = transferOwnershipConfiguration.listItemStyle {
            transferOwnership.set(listItemStyle: listItemStyle)
        }
        
        if let groupMembersStyle = transferOwnershipConfiguration.groupMembersStyle {
            transferOwnership.set(groupMembersStyle: groupMembersStyle)
        }
    }
}
