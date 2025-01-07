//
//  CometChatGroupMembers.swift
 
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatSDK

open class CometChatGroupMembers: CometChatListBase {
    
    // MARK: - Declaration of View Model
    public var viewModel: GroupMembersViewModel = GroupMembersViewModel()
    
    //MARK: GLOBEL STYLE
    public static var style = GroupMembersStyle()
    public static var avatarStyle = CometChatAvatar.style
    public static var statusIndicatorStyle: StatusIndicatorStyle = {
        var statusIndicatorStyle = CometChatStatusIndicator.style
        statusIndicatorStyle.borderColor = CometChatGroupMembers.style.backgroundColor
        statusIndicatorStyle.borderWidth = 2
        return statusIndicatorStyle
    }()
    
    //MARK: LOCAL STYLING
    public var style = CometChatGroupMembers.style
    public var avatarStyle = CometChatGroupMembers.avatarStyle
    public var statusIndicatorStyle = CometChatGroupMembers.statusIndicatorStyle
    
    // MARK: - Declaration of View Properties
    public var disableUserPresence: Bool = false
    public var tailView: ((_ groupMember: GroupMember?) -> UIView)?
    public var subtitle: ((_ groupMember: GroupMember?) -> UIView)?
    public var listItemView: ((_ groupMember: GroupMember?) -> UIView)?
    public var options: ((_ group: Group,_ groupMember: GroupMember?) -> [CometChatGroupMemberOption])?
    public var onItemLongClick: ((_ groupMember: GroupMember, _ indexPath: IndexPath) -> Void)?
    public var onItemClick: ((_ groupMember: GroupMember, _ indexPath: IndexPath) -> Void)?
    public var onError: ((CometChatException) -> Void)?
    public var onSelectedItemProceed: ((_ groupMembers: [GroupMember]) -> ())?
    
    //MARK: - INIT
    public init() {
        super.init(nibName: nil, bundle: nil)
        defaultSetup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func defaultSetup() {
        
        self.prefersLargeTitles = false
        self.showSearch = true
        
        title = "Members"
        
        //setting up loading state view
        let userShimmerView = UsersShimmerView()
        userShimmerView.cellCount = 5
        loadingView = userShimmerView
        
        //setting up error state view
        errorStateTitleText = "Oops!"
        errorStateSubTitleText = "Looks like something went wrong. Please try again."
        
        //setting up empty state view
        emptyStateTitleText = "No Users Available"
        emptyStateSubTitleText = "Add contacts to start conversations and see them listed here."
        
        let barButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(didTapBackButton))
        barButtonItem.tintColor = CometChatTheme.primaryColor
        leftBarButtonItem = [barButtonItem]

    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView(style: .plain)
        tableView.separatorStyle = .none
        registerCells()
        
        if selectionMode != .none {
            addCheckBarButtonItem()
        }
    }
    
    open func addCheckBarButtonItem() {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "checkmark"), style: .done, target: self, action: #selector(tickButtonTapped))
        barButtonItem.tintColor = CometChatTheme.primaryColor
        rightBarButtonItem = [barButtonItem]
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.connect()
        reloadData()
        fetchData()
    }
    
    open override func setupStyle() {
        listBaseStyle = style
        super.setupStyle()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        viewModel.disconnect()
    }
    
    @objc open func didTapBackButton() {
        self.dismiss(animated: true)
    }
    
    open func fetchData() {
        showLoadingView()
        viewModel.fetchGroupsMembers()
    }
    
    open func reloadData() {
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            
            DispatchQueue.main.async(execute: {
                this.removeLoadingView()
                this.removeErrorView()
                this.reload()
                
                switch this.viewModel.isSearching {
                case true:
                    if this.viewModel.filteredGroupMembers.isEmpty {
                        if this.viewModel.groupMembers.isEmpty {
                            this.showEmptyView()
                        }
                    }
                case false:
                    if this.viewModel.groupMembers.isEmpty {
                        this.showEmptyView()
                    }
                }
            })
        }
        viewModel.failure = { [weak self] error in
            guard let this = self else { return }
            // this is error callback to the user.
            this.onError?(error)
            DispatchQueue.main.async {
                this.removeLoadingView()
                this.showErrorView()
            }
        }
        
        viewModel.reloadAt = { [weak self] row in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
            }
        }
    }
    
    @objc open func tickButtonTapped() {
        onSelectedItemProceed?(viewModel.selectedGroupMembers)
    }
    
    open func registerCells() {
        self.tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
    }
    
    open override func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            viewModel.isSearching = false
            reload()
        case .filter:
            viewModel.isSearching = true
            viewModel.filterGroupMembers(text: text)
        }
    }
    
    open func configureTailView(groupMember: GroupMember) -> UIButton? {
        let group = viewModel.group!
        
        let button = UIButton()
        switch groupMember.scope {
        case .admin:
            if group.owner == groupMember.uid {
                button.setTitle("OWNER".localize(), for: .normal)
                button.backgroundColor = CometChatTheme.primaryColor
                button.setTitleColor(CometChatTheme.textColorWhite, for: .normal)
            } else {
                button.setTitle("ADMIN".localize(), for: .normal)
                button.backgroundColor = CometChatTheme.extendedPrimaryColor100
                button.setTitleColor(CometChatTheme.primaryColor, for: .normal)
                button.borderWith(width: 1)
                button.borderColor(color: CometChatTheme.primaryColor)
            }
        case .moderator:
            button.setTitle(" " + "MODERATOR".localize(), for: .normal)
            button.backgroundColor = CometChatTheme.extendedPrimaryColor100
            button.setTitleColor(CometChatTheme.primaryColor, for: .normal)
        case .participant:
            break
        @unknown default: break
        }
        button.titleLabel?.font = CometChatTypography.Caption1.regular
        button.isEnabled = true
        button.contentEdgeInsets = UIEdgeInsets(
            top: CometChatSpacing.Padding.p1,
            left: CometChatSpacing.Padding.p3,
            bottom: CometChatSpacing.Padding.p1,
            right: CometChatSpacing.Padding.p3
        )
        button.roundViewCorners(corner: .init(cornerRadius: ((button.titleLabel?.font.lineHeight ?? 0)/2) + CometChatSpacing.Padding.p1))
        
        return button
    }
    
    open func configureMenu(groupMember: GroupMember) -> [UIContextualAction] {
        
        var actions: [UIContextualAction] = []
        
        // - Scope Change Action -
        if GroupMembersUtils.allowScopeChange(group: viewModel.group, groupMember: groupMember) {
            let scopeChangeImage = UIImage(systemName: "arrow.triangle.2.circlepath.circle")?.add(text: "Scope", imageTint: .white)
            let scopeChangeAction = UIContextualAction(
                style: .normal,
                title: "Scope",
                handler: { [weak self] (action, sourceView, completionHandler)  in
                    guard let this = self else { return }
                    DispatchQueue.main.async(execute: {
                        let scopeChangeViewController = CometChatScopeChange()
                        scopeChangeViewController.set(group: this.viewModel.group, groupMember: groupMember)
                        
                        if #available(iOS 15.0, *) {
                            if let presentationController = scopeChangeViewController.presentationController as? UISheetPresentationController {
                                if #available(iOS 16.0, *) {
                                    presentationController.detents = [ .custom(resolver: { context in
                                        return 505
                                    })]
                                    presentationController.prefersGrabberVisible = true
                                    self?.present(scopeChangeViewController, animated: true)
                                } else {
                                    self?.present(scopeChangeViewController, animated: true)
                                }
                            }
                        } else {
                            self?.present(scopeChangeViewController, animated: true)
                        }
                    })
                    completionHandler(false)
                }
            )
            scopeChangeAction.image = scopeChangeImage
            scopeChangeAction.backgroundColor = CometChatTheme.primaryColor
            actions.append(scopeChangeAction)
        }
        
        
        // - Ban Action -
        if GroupMembersUtils.allowKickBanUnbanMember(group: viewModel.group, groupMember: groupMember) {
            let banActionImage = UIImage(systemName: "person.slash.fill")?.add(text: "Ban", imageTint: .white)
            let banAction = UIContextualAction(
                style: .normal,
                title: "Ban",
                handler: { [weak self, weak groupMember] (action, sourceView, completionHandler) in
                    if let groupMember = groupMember {
                        completionHandler(false)
                        self?.onBanMemberSelected(for: groupMember)
                    }
                }
            )
            banAction.image = banActionImage
            banAction.backgroundColor = CometChatTheme.warningColor
            actions.append(banAction)
        }
        
        // - Kick Action -
        if GroupMembersUtils.allowKickBanUnbanMember(group: viewModel.group, groupMember: groupMember) {
            let removeActionImage = UIImage(systemName: "minus.circle")?.add(text: "Remove", imageTint: .white)
            let removeAction = UIContextualAction(
                style: .normal,
                title: "Remove",
                handler: { [weak self, weak groupMember] (action, sourceView, completionHandler)  in
                    if let groupMember = groupMember {
                        completionHandler(false)
                        self?.onRemoveMemberSelected(for: groupMember)
                    }
                }
            )
            removeAction.image = removeActionImage
            removeAction.backgroundColor = CometChatTheme.errorColor
            actions.append(removeAction)
        }
        
        return actions
    }
    
    
    open func onBanMemberSelected(for groupMember: GroupMember) {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(
            title: "Ban \(groupMember.name ?? "")",
            message: "Are you sure you want to ban \(groupMember.name ?? "") from this group ?",
            preferredStyle: .actionSheet
        )
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(
            title: "Yes",
            style: .destructive
        ) { action -> Void in
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.banGroupMember(group: strongSelf.viewModel.group, member: groupMember)
            }
        }
        
        // adding cancel action
        let cancelAction: UIAlertAction = UIAlertAction(
            title: ConversationConstants.cancel,
            style: .cancel
        ) { action -> Void in   }
        
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true)
    }
    
    open func onRemoveMemberSelected(for groupMember: GroupMember) {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: "Remove \(groupMember.name ?? "")", message: "Are you sure you want to Remove \(groupMember.name ?? "") from this group ?", preferredStyle: .actionSheet)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: "Yes", style: .destructive) { action -> Void in
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.kickGroupMember(group: strongSelf.viewModel.group, member: groupMember)
            }
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: ConversationConstants.cancel, style: .cancel) { action -> Void in
        }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true)
    }
        
    open func onScopeChangeSelected(for groupMember: GroupMember, onCancelled: @escaping (() -> Void), onCompleted: @escaping (() -> Void)) {
        
    }
    
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        DispatchQueue.main.async {
            if CometChat.getLoggedInUser()?.uid == bannedUser.uid{
                self.dismiss(animated: true)
            }
        }
    }
}

//MARK: TABLE VIEW DELEGATES
extension CometChatGroupMembers {
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: "CometChatListItem", for: indexPath) as? CometChatListItem  {
            
            let groupMember = viewModel.isSearching ? viewModel.filteredGroupMembers[indexPath.row] : viewModel.groupMembers[indexPath.row]
            
            //setting styles
            listItem.style = style
            listItem.avatar.style = avatarStyle
            
            //setting custom view
            if let customView = listItemView?(groupMember) {
                listItem.set(customView: customView)
                return listItem
            }
            
            //setting long press
            listItem.onItemLongClick = { [weak self] in
                guard let this = self else { return }
                // this is onItemLongClick callback to the user.
                this.onItemLongClick?(groupMember, indexPath)
            }
            
            //Setting Title Label
            if let name = groupMember.name, let uid = CometChat.getLoggedInUser()?.uid {
                if uid == groupMember.uid {
                    listItem.set(title: "YOU".localize())
                } else {
                    listItem.set(title: name)
                }
            }
            
            //setting avatar
            listItem.set(avatarURL: groupMember.avatar ?? "", with: groupMember.name ?? "")
            
            //setting subtitle if passed from outside
            if let subTitleView = subtitle?(groupMember) {
                listItem.set(subtitle: subTitleView)
            }
            
            //setting tailView
            if let tailView = tailView?(groupMember) {
                listItem.set(tail: tailView)
            } else if let tailView = configureTailView(groupMember: groupMember) {
                listItem.set(tail: tailView)
            }
            
            //configuring status indicator
            listItem.statusIndicator.heightAnchor.pin(equalToConstant: 12).with(priority: .defaultHigh).isActive = true
            listItem.statusIndicator.widthAnchor.pin(equalToConstant: 12).with(priority: .defaultHigh).isActive = true
            switch groupMember.status {
            case .offline:
                listItem.statusIndicator.isHidden = true
            case .online:
                listItem.statusIndicator.isHidden = false
            case .available:
                listItem.statusIndicator.isHidden = true
            @unknown default: listItem.statusIndicator.isHidden = true
            }
            listItem.statusIndicator.style = statusIndicatorStyle
            
            //selecting mode
            switch selectionMode {
            case .single, .multiple: listItem.allow(selection: true)
            case .none:  listItem.allow(selection: false)
            }
            
            return listItem
        }
        return UITableViewCell()
    }
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching ? viewModel.filteredGroupMembers.count : viewModel.groupMembers.count
    }
    
    open  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (viewModel.groupMembers.count - 1) && !viewModel.isFetchedAll { viewModel.fetchGroupsMembers()
        }
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
    
    open override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let group = viewModel.isSearching ? viewModel.filteredGroupMembers[indexPath.row] : viewModel.groupMembers[indexPath.row]
        if let foundGroup = viewModel.selectedGroupMembers.firstIndex(of: group) {
            viewModel.selectedGroupMembers.remove(at: foundGroup)
        }
    }
    
    open override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        let groupMember = viewModel.isSearching ? viewModel.filteredGroupMembers[indexPath.row] : viewModel.groupMembers[indexPath.row]
        
        if let options = options?(viewModel.group,groupMember), !options.isEmpty {
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
        } else {
            actions.append(contentsOf: configureMenu(groupMember: groupMember))
        }
        
        return  UISwipeActionsConfiguration(actions: actions)
    }
}

//MARK: Connection Delegate
extension CometChatGroupMembers: CometChatConnectionDelegate {
    public func connected() {
        reloadData()
        fetchData()
    }
    
    public func connecting() {}
    
    public func disconnected() {}
}

//MARK: PROPERTIES
extension CometChatGroupMembers {
    
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
    public func set(groupMemberRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) -> Self {
        viewModel.set(groupMembersRequestBuilder: groupMemberRequestBuilder)
        return self
    }
    
    @discardableResult
    public func set(group: Group) -> Self {
        viewModel.set(group: group)
        return self
    }
    
    @discardableResult
    public func set(groupMemberSearchRequestBuilder: GroupMembersRequest.GroupMembersRequestBuilder) -> Self {
        viewModel.set(searchGroupMembersRequestBuilder: groupMemberSearchRequestBuilder)
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

extension UIImage {
    public func add(text: String, imageTint: UIColor) -> UIImage? {
        
        let label = UILabel()
        label.text = text
        label.font = CometChatTypography.Caption1.medium
        label.textColor = CometChatTheme.white
        
        let tempView = UIStackView(frame: CGRect(x: 0, y: 0, width: 48, height: 40))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        imageView.tintColor = imageTint
        imageView.contentMode = .scaleAspectFill
        
        tempView.axis = .vertical
        tempView.alignment = .center
        tempView.spacing = 4
        imageView.image = self
        tempView.addArrangedSubview(imageView)
        tempView.addArrangedSubview(label)
        let renderer = UIGraphicsImageRenderer(bounds: tempView.bounds)
        let image = renderer.image { rendererContext in
            tempView.layer.render(in: rendererContext.cgContext)
        }
        return image
    }
}
