//
//  CometChatGroups.swift
 
//
//  Created by Pushpsen Airekar on 17/11/22.
//

import UIKit
import CometChatSDK

@MainActor
internal class CometChatCallsHistory: CometChatListBase {
    
    // MARK: - Declaration of View Model
    private var viewModel: CallHistoryViewModel
   
    // MARK: - Declaration of View Properties
    private var subtitle: ((_ call: BaseMessage?) -> UIView)?
    private var listItemView: ((_ call: BaseMessage?) -> UIView)?
    private var menus: [UIBarButtonItem]?
    private var options: ((_ call: BaseMessage?) -> [CometChatCallOption])?
    private var hideSeparator: Bool = true
    private var callsStyle = CallsStyle()
    private var avatarStyle = AvatarStyle()
    private var statusIndicatorStyle = StatusIndicatorStyle()
    private var listItemStyle = ListItemStyle()
    override var emptyStateText: String {
        get {
            return "NO_CALLS_HISTORY".localize()
        }
        set {
            super.emptyStateText = newValue
        }
    }
    private var privateGroupIcon = UIImage(named: "groups-shield", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    private var protectedGroupIcon = UIImage(named: "groups-lock", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    // MARK:- Created for to check CreateGroup Events.
    var newCallConfiguration: CreateGroupConfiguration?
    var newCallButton: UIBarButtonItem?
    var newCallIcon = UIImage(named: "call-new.png", in: CometChatUIKit.bundle, compatibleWith: nil)
        
    var onItemClick: ((_ call: BaseMessage, _ indexPath: IndexPath) -> Void)?
    private var onItemLongClick: ((_ call: BaseMessage, _ indexPath: IndexPath) -> Void)?
    private var onError: ((_ error: CometChatException) -> Void)?
    var onBack: (() -> Void)?
    var onDidSelect: ((_ call: BaseMessage, _ indexPath: IndexPath) -> Void)?
    
    @discardableResult
    public func setOnItemClick(onItemClick: @escaping ((_ call: BaseMessage, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func setOnItemLongClick(onItemLongClick: @escaping ((_ call: BaseMessage, _ indexPath: IndexPath) -> Void)) -> Self {
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
    public init(callsRequestBuilder: MessagesRequest.MessageRequestBuilder = CallsBuilder.getDefaultRequestBuilder()) {
        viewModel = CallHistoryViewModel(callsRequestBuilder: callsRequestBuilder)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupTableView(style: .plain)
        registerCells()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        viewModel.disconnect()
        viewModel.connect()
        reloadData()
        fetchData()
    }
        
    private func fetchData() {
        showIndicator()
        viewModel.fetchCalls()
    }
    
    private func reloadData() {
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            this.reload()
            this.hideIndicator()
            switch this.viewModel.isSearching {
            case true:
                if this.viewModel.filteredCalls.isEmpty {
                    if let emptyView = this.emptyView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    this.tableView.restore()
                }
            case false:
                if this.viewModel.calls.isEmpty {
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
                            this.viewModel.fetchCalls()
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
    public func set(callsStyle: CallsStyle) -> Self {
        set(background: [callsStyle.background.cgColor])
        set(titleColor: callsStyle.titleColor)
        set(titleFont: callsStyle.titleFont)
        set(largeTitleColor: callsStyle.largeTitleColor)
        set(largeTitleFont: callsStyle.largeTitleFont)
        set(backButtonTint: callsStyle.backIconTint)
        set(searchTextFont: callsStyle.searchTextFont)
        set(searchTextColor: callsStyle.searchTextColor)
        set(searchBorderColor: callsStyle.searchBorderColor)
        set(searchBorderWidth: callsStyle.searchBorderWidth)
        set(searchCornerRadius: callsStyle.searchBorderRadius)
        set(searchIconTint: callsStyle.searchIconTint)
        set(searchClearIconTint: callsStyle.searchClearIconTint)
        set(searchBackground: callsStyle.searchBackgroundColor)
        set(searchCancelButtonFont: callsStyle.searchCancelButtonFont)
        set(searchCancelButtonTint: callsStyle.searchCancelButtonTint)
        set(searchPlaceholderColor: callsStyle.searchPlaceholderColor)
        set(corner: callsStyle.cornerRadius)
        set(avatarStyle: callsStyle.avatarStyle ?? avatarStyle)
        set(listItemStyle: callsStyle.listItemStyle ?? listItemStyle)
        set(statusIndicatorStyle: callsStyle.statusIndicatorStyle ?? statusIndicatorStyle)
        return self
    }
    
    public override func onSearch(state: SearchState, text: String) {
        switch state {
        case .clear:
            viewModel.isSearching = false
            reload()
        case .filter:
            viewModel.isSearching = true
            viewModel.filterCalls(text: text)
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
            .set(title: "CALLS".localize(), mode: .automatic)
            .hide(search: true)
            .set(callsStyle: callsStyle)
            .show(backButton: false)
        newCallButton = UIBarButtonItem(image: newCallIcon, style: .plain, target: self, action: #selector(self.didNewCallPressed))
      //  self.navigationItem.rightBarButtonItem = newCallButton
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
    }
    // MARK:- Created for to check CreateFroup Events.
    @objc func didNewCallPressed(){
//        DispatchQueue.main.async { [weak self] in
//            guard let this = self else { return }
//            CometChatGroupEvents.emitOnCreateGroupClick()
//            let cometChatCreateGroup = CometChatCreateGroup()
//            let naviVC = UINavigationController(rootViewController: cometChatCreateGroup)
//            this.set(createGroup: cometChatCreateGroup, createGroupConfiguration: this.createGroupConfiguration)
//            this.present(naviVC, animated: true)
//        }
    }
}

extension CometChatCallsHistory {
    
    @discardableResult
    public func onSelection(_ onSelection: @escaping ([BaseMessage]?) -> ()) -> Self {
        onSelection(viewModel.selectedCalls)
        return self
    }
    
    @discardableResult
    public func setSubtitleView(subtitle: ((_ call: BaseMessage?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
    }
    
    @discardableResult
    public func setListItemView(listItemView: ((_ call: BaseMessage?) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func setOptions(options: ((_ call: BaseMessage?) -> [CometChatCallOption])?) -> Self {
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
    public func set(emptyStateMessage: String) -> Self {
        self.emptyStateText = emptyStateMessage
        return self
    }
    
    @discardableResult
    public func set(callsRequestBuilder: MessagesRequest.MessageRequestBuilder) -> Self {
        viewModel = CallHistoryViewModel(callsRequestBuilder: callsRequestBuilder)
        return self
    }
    
    @discardableResult
    public func add(call: Call) -> Self {
        viewModel.add(call: call)
        return self
    }
    
    @discardableResult
    public func insert(call: Call, at: Int) -> Self {
        viewModel.insert(call: call, at: at)
        return self
    }
    
    @discardableResult
    public func update(call: Call) -> Self {
        viewModel.update(call: call)
        return self
    }
    
    @discardableResult
    public func remove(call: Call) -> Self {
        viewModel.remove(call: call)
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

extension CometChatCallsHistory {
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem  {
            let call = viewModel.isSearching ? viewModel.filteredCalls.reversed()[indexPath.row] : viewModel.calls.reversed()[indexPath.row]
            
            listItem.set(avatarStyle: avatarStyle)
            listItem.set(statusIndicatorStyle: statusIndicatorStyle)
            listItemStyle.set(titleColor:  callsStyle.titleColor)
            listItem.set(listItemStyle: listItemStyle)
            
            if let call = call as? CustomMessage, call.type == MessageTypeConstants.meeting, let receiver = call.receiver as? Group {
                if let name = receiver.name {
                    listItem.set(title: name.capitalized)
                    listItem.set(avatarName: name.capitalized)
                }
                if let avatarURL = receiver.icon {
                    listItem.set(avatarURL: avatarURL)
                }
                
                switch receiver.groupType {
                case .public: listItem.statusIndicator.isHidden = true
                case .private:
                    listItem.statusIndicator.isHidden = false
                    listItem.set(statusIndicatorIcon:  privateGroupIcon)
                    listItem.set(statusIndicatorIconTint: .white)
                    listItem.set(statusIndicatorColor: callsStyle.privateGroupIconBackgroundColor)
                case .password:
                    listItem.statusIndicator.isHidden = false
                    listItem.set(statusIndicatorIcon: protectedGroupIcon)
                    listItem.set(statusIndicatorIconTint: .white)
                    listItem.set(statusIndicatorColor: callsStyle.protectedGroupIconBackgroundColor)
                @unknown default: listItem.statusIndicator.isHidden = true
                }
            }
            
            if let call = call as? Call {
                let isLoggedInUser: Bool = (call.callInitiator as? User)?.uid == LoggedInUserInformation.getUID()
                switch call.callStatus {
                    
                case .initiated where call.receiverType == .user:
                    if let user = (isLoggedInUser ? call.callReceiver : call.callInitiator) as? User, let name = user.name {
                        listItem.set(title: name.capitalized)
                        listItem.set(avatarName: name.capitalized)
                        if let avatarURL = user.avatar {
                            listItem.set(avatarURL: avatarURL)
                        }
                        listItemStyle.set(titleColor:  callsStyle.titleColor)
                        listItem.set(listItemStyle: listItemStyle)
                    }
                    
                case .unanswered where call.receiverType == .user:
                    if let user = (isLoggedInUser ? call.callReceiver : call.callInitiator) as? User, let name = user.name {
                        listItem.set(title: name.capitalized)
                        listItem.set(avatarName: name.capitalized)
                        if let avatarURL = user.avatar {
                            listItem.set(avatarURL: avatarURL)
                        }
                        
                        listItemStyle.set(titleColor: isLoggedInUser ?  callsStyle.titleColor : callsStyle.missedCallTextColor)
                        listItem.set(listItemStyle: listItemStyle)
                    }
                                        
                case .rejected where call.receiverType == .user:
                    if let user = (isLoggedInUser ? call.callReceiver : call.callInitiator) as? User, let name = user.name {
                        listItem.set(title: name.capitalized)
                        listItem.set(avatarName: name.capitalized)
                        if let avatarURL = user.avatar {
                            listItem.set(avatarURL: avatarURL)
                        }
                        listItemStyle.set(titleColor: isLoggedInUser ?  callsStyle.titleColor : callsStyle.missedCallTextColor)
                        listItem.set(listItemStyle: listItemStyle)
                    }
                    
                case .cancelled where call.receiverType == .user:
                    if let user = (isLoggedInUser ? call.callReceiver : call.callInitiator)as? User, let name = user.name {
                        listItem.set(title: name.capitalized)
                        listItem.set(avatarName: name.capitalized)
                        if let avatarURL = user.avatar {
                            listItem.set(avatarURL: avatarURL)
                        }
                        listItemStyle.set(titleColor: isLoggedInUser ?  callsStyle.titleColor : callsStyle.missedCallTextColor)
                        listItem.set(listItemStyle: listItemStyle)
                    }
                                        
                case .ended where call.receiverType == .user :
                    if let user = (isLoggedInUser ? call.callReceiver : call.callInitiator) as? User, let name = user.name {
                        listItem.set(title: name.capitalized)
                        listItem.set(avatarName: name.capitalized)
                        if let avatarURL = user.avatar {
                            listItem.set(avatarURL: avatarURL)
                        }
                        listItemStyle.set(titleColor:  callsStyle.titleColor)
                        listItem.set(listItemStyle: listItemStyle)
                    }
                                    
                case .ongoing where call.receiverType == .user:
                    if let user = (isLoggedInUser ? call.callReceiver : call.callInitiator) as? User, let name = user.name {
                        listItem.set(title: name.capitalized)
                        listItem.set(avatarName: name.capitalized)
                        if let avatarURL = user.avatar {
                            listItem.set(avatarURL: avatarURL)
                        }
                        listItemStyle.set(titleColor:  callsStyle.titleColor)
                        listItem.set(listItemStyle: listItemStyle)
                    }
                                        
                case .busy where call.receiverType == .user:
                    if let user = (isLoggedInUser ? call.callReceiver : call.callInitiator) as? User, let name = user.name {
                        listItem.set(title: name.capitalized)
                        listItem.set(avatarName: name.capitalized)
                        if let avatarURL = user.avatar {
                            listItem.set(avatarURL: avatarURL)
                        }
                        listItemStyle.set(titleColor:  callsStyle.titleColor)
                        listItem.set(listItemStyle: listItemStyle)
                    }
                    
                @unknown default: break
                    
                }
            }
                        
             if let subTitleView = subtitle?(call) {
                 listItem.set(subtitle: subTitleView)
             } else {
                 if let call = call as? Call {
                     let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
                     let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 25))
                     icon.contentMode = .scaleAspectFit
                     let isLoggedInUser: Bool = (call.callInitiator as? User)?.uid == LoggedInUserInformation.getUID()
                     switch call.callType {
                     case .audio:
                         icon.image = UIImage(named: "VoiceCall", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
                     case .video:
                         icon.image = UIImage(named: "VideoCall", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
                     @unknown default: break
                     }
                     switch call.callStatus {
                         
                     case .initiated where call.receiverType == .user:
                         let callStatus: String = isLoggedInUser ? "OUTGOING_CALL".localize() : "INCOMING_CALL".localize()
                         label.text = callStatus
                         
                     case .unanswered where call.receiverType == .user:
                         let callStatus: String = isLoggedInUser ? "CALL_UNANSWERED".localize() :  "MISSED_CALL".localize()
                         label.text = callStatus
                         
                     case .rejected where call.receiverType == .user:
                         let callStatus: String = isLoggedInUser ? "CALL_REJECTED".localize() : "MISSED_CALL".localize()
                         label.text = callStatus
    
                     case .cancelled where call.receiverType == .user:
                         let callStatus: String = isLoggedInUser ? "CALL_CANCELLED".localize() : "MISSED_CALL".localize()
                         label.text = callStatus
                         
                     case .busy where call.receiverType == .user:
                         let callStatus: String = isLoggedInUser ? "REJECTED_CALL".localize() : "MISSED_CALL".localize()
                         label.text = callStatus

                     case .ended:
                         label.text = "CALL_ENDED".localize()
                         
                     case .ongoing:
                         label.text = "CALL_ACCEPTED".localize()

                     @unknown default: break
                    
                     }
                     
                     icon.tintColor = callsStyle.subtitleColor
                     label.textColor = callsStyle.subtitleColor
                     label.font = callsStyle.subtitleFont
                     let stackView = UIStackView(arrangedSubviews: [icon, label, UIView()])
                     stackView.distribution = .fill
                     stackView.alignment = .leading
                     stackView.spacing = 10
                     listItem.set(subtitle: stackView)
                 }
                 
                 if let call = call as? CustomMessage {
                     let icon = UIImageView(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
                     let label = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 25))
                     icon.contentMode = .scaleAspectFit
                     icon.image = UIImage(named: "VideoCall", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
                     label.text = "Conference call".localize()
                     icon.tintColor = callsStyle.subtitleColor
                     label.textColor = callsStyle.subtitleColor
                     label.font = callsStyle.subtitleFont
                     let stackView = UIStackView(arrangedSubviews: [icon, label, UIView()])
                     stackView.distribution = .fill
                     stackView.alignment = .leading
                     stackView.spacing = 10
                     listItem.set(subtitle: stackView)
                 }
             }
            
            
            let infoButton = UIButton(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
            infoButton.setImage(UIImage(named: "calls-info", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage(), for: .normal)
            infoButton.tintColor = callsStyle.infoIconTint
           
            let label = CometChatDate()
            
            if let call = call as? Call {
                label.set(pattern: .dayDateTime)
                label.set(timestamp: Int(call.initiatedAt))
            }
            if let call = call as? CustomMessage {
                label.set(pattern: .dayDateTime)
                label.set(timestamp: Int(call.sentAt))
            }
            label.textColor = callsStyle.timeColor
            label.font = callsStyle.timeFont
            let stackView = UIStackView(arrangedSubviews: [label, infoButton])
            stackView.distribution = .fill
            stackView.alignment = .center
            stackView.spacing = 10
            listItem.set(tail: stackView)
            
            if let customView = listItemView?(call) {
                listItem.set(customView: customView)
            }
          
            switch selectionMode {
            case .single, .multiple: listItem.allow(selection: true)
            case .none:  listItem.allow(selection: false)
            }
            listItem.onItemLongClick = { [weak self] in
                guard let this = self else { return }
                this.onItemLongClick?(call, indexPath)
            }
            listItem.build()
            return listItem
        }
        return UITableViewCell()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching ? viewModel.filteredCalls.count : viewModel.calls.count
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
                viewModel.fetchCalls()
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let call = viewModel.isSearching ? viewModel.filteredCalls.reversed()[indexPath.row] : viewModel.calls.reversed()[indexPath.row]
        if let onItemClick = onItemClick {
            onItemClick(call, indexPath)
        } else {
            onDidSelect?(call, indexPath)
        }
        if selectionMode == .none {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            if !viewModel.selectedCalls.contains(call) {
                self.viewModel.selectedCalls.append(call)
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let call = viewModel.isSearching ? viewModel.filteredCalls.reversed()[indexPath.row] : viewModel.calls.reversed()[indexPath.row]
        if let foundCall = viewModel.selectedCalls.firstIndex(of: call) {
            viewModel.selectedCalls.remove(at: foundCall)
        }
    }

    public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        let call = viewModel.isSearching ? viewModel.filteredCalls.reversed()[indexPath.row] : viewModel.calls.reversed()[indexPath.row]
        if let options = options?(call) {
            for option in options {
                let action =  UIContextualAction(style: .destructive, title: "", handler: { (action,view, completionHandler ) in
                    option.onClick?(call, indexPath.section, option, self)
                })
                action.image = option.icon
                action.backgroundColor = option.backgroundColor
                actions.append(action)
            }
        }
        return  UISwipeActionsConfiguration(actions: actions)
    }
}

