//
//  CometChatCallDetails.swift
//  
//
//  Created by Ajay Verma on 07/03/23.
//

import Foundation
import CometChatSDK

internal class CometChatCallDetails : CometChatListBase {
    
    //MARK: VARIABLE DECLARATION
    private var closeButtonIconL: UIImage?
    private var showCloseButton: Bool = true
    private var disableUsersPresence: Bool = false
    private var hideProfile: Bool = false
    private var subtitleView: ((_ user: User?, _ group: Group?) -> UIView)?
    private var privateGroupIcon = UIImage(named: "groups-shield", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    private var protectedGroupIcon = UIImage(named: "groups-lock", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    private var customProfileView: UIView?
    private var data: ((_ user: User?, _ group: Group?) -> [CometChatDetailsTemplate])?
    private var onError: ((_ error: CometChatException) -> ())?
    private var avatarStyle = AvatarStyle()
    private var callDetailsStyle = CallDetailsStyle()
    private var statusIndicatorStyle = StatusIndicatorStyle()
    private var listItemStyle = ListItemStyle()
    private var onBack: (() -> Void)?
    private var onClose: (() -> ())?
    private var viewModel: CallDetailsViewModel?
    var templates: [(template: CometChatDetailsTemplate, options: [CometChatDetailsOption])] = []
    private var listItem: CometChatListItem!
    private var containerViewForProfile: UIStackView?
    
    //MARK: VIEWCONTROLLER'S LIFE CYCLE
    public override func viewDidLoad() {
        setupContainerViewForProfile()
        setupTableView(style: .insetGrouped)
        setupAppearance()
        tableView.reloadData()
        set(callDetailsStyle: callDetailsStyle)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        setupProfile()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        disconnect()
    }
        
    override func onBackCallback() {
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
    
    /// set the aapearance.
    func setupAppearance() {
        self.view.backgroundColor =  callDetailsStyle.background
        set(title: "CALL_DETAILS".localize(), mode: .never)
        set(titleColor: CometChatTheme.palatte.accent)
        hide(search: true)
        set(backButtonTitle: DetailConstants.cancelText)
        show(backButton: true)
        set(background: [CometChatTheme.palatte.secondary.cgColor])
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
            fillProfile()
            updateUserStatus()
            updateGroupCount()
        }
    }
    
    ///  Assign data to the profille.
    func fillProfile() {
        if let user = viewModel?.user, let name = user.name {
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
                label.textColor = callDetailsStyle.listItemsubTitleColor
                label.font = callDetailsStyle.listItemsubTitleFont
                listItem.set(subtitle: label)
            }
            listItem.hide(statusIndicator: disableUsersPresence)
            if !disableUsersPresence {
                switch user.status {
                case .online :
                    listItem.hide(statusIndicator: false)
                    listItem.set(statusIndicatorColor: callDetailsStyle.onlineStatusColor)
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
        if let group = viewModel?.group, let name = group.name {
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
                listItem.set(statusIndicatorColor: callDetailsStyle.privateGroupIconBackgroundColor)
            case .password:
                listItem.statusIndicator.isHidden = false
                listItem.set(statusIndicatorIcon: protectedGroupIcon)
                listItem.set(statusIndicatorIconTint: .white)
                listItem.set(statusIndicatorColor: callDetailsStyle.protectedGroupIconBackgroundColor)
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
                label.textColor = callDetailsStyle.listItemsubTitleColor
                label.font = callDetailsStyle.listItemsubTitleFont
                listItem.set(subtitle: label)
            }
        }
        listItemStyle.set(titleFont: callDetailsStyle.listItemTitleFont)
        listItemStyle.set(titleColor: callDetailsStyle.listItemTitleColor)
        listItem.set(listItemStyle: listItemStyle)
        listItem.set(avatarStyle: avatarStyle)
        listItem.set(statusIndicatorStyle: statusIndicatorStyle)
        listItem.build()
    }
    
    func updateUserStatus() {
        viewModel?.updateUserStatus = { [weak self] (status) in
            guard let this = self else { return }
                switch status {
                case true:
                    this.listItem.set(subtitle: this.configureSubTitleView(text: MessageHeaderConstants.online))
                    this.listItem.set(statusIndicatorColor: this.callDetailsStyle.onlineStatusColor)
                    this.listItem.hide(statusIndicator: false)
                case false:
                    this.listItem.set(subtitle: this.configureSubTitleView(text: MessageHeaderConstants.offline))
                    this.listItem.hide(statusIndicator: true)
                }
                this.listItem.build()
        }
    }
    
    private func updateGroupCount() {
        var text: String = ""
        viewModel?.updateGroupCount = { [weak self] (status) in
            guard let this = self else { return }
            if let group = this.viewModel?.group {
                if status {
                    if group.membersCount == 1 {
                        text = "1 " + "MEMBER".localize()
                    } else {
                        text = "\(group.membersCount) " + "MEMBERS".localize()
                    }
                     this.listItem.set(subtitle: this.configureSubTitleView(text: text))
                }
            }
        }
    }

    private func setupData() {
        if data == nil  {
            let templates = CallUtils().getDefaultTemplate(user: viewModel?.user, group: viewModel?.group, controller: self, isFromCallDetail: true)
                set(templates: templates)
        } else {
            set(templates: data?(viewModel?.user, viewModel?.group))
        }
    }
    
    private func configureSubTitleView(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = callDetailsStyle.listItemsubTitleColor
        label.font = callDetailsStyle.listItemsubTitleFont
        return label
    }
    
    private func connect() {
        viewModel?.connect()
    }
    
    private func disconnect() {
        viewModel?.disconnect()
    }
    
}

// TableView's Methods.
extension CometChatCallDetails {
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return templates.count
    }
    
    public override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let options = templates[safe: section]?.options, !options.isEmpty {
            return options.count
        } else {
            return 1
        }
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: CometChatActionItem.identifier, for: indexPath) as? CometChatActionItem {
            cell.selectionStyle = .none
            if let customView = templates[safe: indexPath.section]?.template.customView {
                cell.background.roundViewCorners(corner: CometChatCornerStyle(topLeft: true, topRight: true, bottomLeft: true, bottomRight: true, cornerRadius: 10.0))
                cell.setCustomView(view: customView)
                    cell.setTopViewBackGroundColor(color: UIColor.clear)
            } else if let template = templates[safe: indexPath.section], let option = template.options[safe: indexPath.row] {
                if let customOptionView = option.customView {
                    cell.setCustomView(view: customOptionView)
                } else {
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
                }
            }
            return cell
        }
        return UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: 25))
        return returnedView
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    public func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

extension CometChatCallDetails {
    
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
            self.viewModel = CallDetailsViewModel(user: user)
        }
        setupData()
        connect()
        return self
    }
    
    @discardableResult
    public func set(group: Group?) -> Self {
        if let group = group {
            self.viewModel = CallDetailsViewModel(group: group)
        }
        setupData()
        connect()
        return self
    }
    
    @discardableResult
    public func set(templates: [CometChatDetailsTemplate]?) -> Self {
        if let templates = templates {
            for template in templates {
                if let options = template.options?(viewModel?.user,viewModel?.group) {
                    self.templates.append((template: template, options: options))
                } else {
                    self.templates.append((template: template, options: []))
                }
            }
            DispatchQueue.main.async {
               // self.tableView.reloadData()
            }
        }
        return self
    }
    
    @discardableResult
    public func set(callDetailsStyle: CallDetailsStyle) -> Self {
        self.callDetailsStyle = callDetailsStyle
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
    public func setSubTitleView(subTitleView: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
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
    public func setOnClose(onClose: (() -> ())? ) -> Self {
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
}
