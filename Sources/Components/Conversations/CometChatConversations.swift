//
//  CometChatConversations.swift
//
//
//  Created by Abdullah Ansari on 24/11/22.
//

import Foundation
import CometChatSDK
import UIKit

@MainActor
open class CometChatConversations: CometChatListBase {
    
    // MARK: - Properties
    private var viewModel : ConversationsViewModel
    private var conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder
    
    private var isHideDeletedMessages: Bool
    private let normalSubtitlefont: UIFont
    private let boldSubtitlefont: UIFont
    lazy var searchedText: String = ""
    private let refreshControl = UIRefreshControl()
    override var emptyStateText: String {
        get {
            return "NO_CHATS_FOUND".localize()
        }
        set {
            super.emptyStateText = newValue
        }
    }
    
    private var noChatFound = true
    
    private var conversationsStyle: ConversationsStyle
    private var avatarStyle: AvatarStyle
    private var statusIndicatorStyle: StatusIndicatorStyle
    private var listItemStyle: ListItemStyle
    private var badgeStyle: BadgeStyle
    private var receiptStyle: ReceiptStyle
    private var dateStyle: DateStyle
    private var disableUsersPresence: Bool = false
    private var disableReceipt: Bool = false
    private var disableTyping: Bool = false
    private var disableSoundForMessages: Bool = false
    private var customSoundForMessages: URL?
    private var protectedGroupIcon: UIImage = UIImage(named: "groups-lock", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    private var privateGroupIcon: UIImage = UIImage(named: "groups-shield", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    private var readIcon: UIImage?
    private var deliveredIcon: UIImage?
    private var sentIcon: UIImage?
    private(set) var options: ((_ conversation: Conversation) -> [CometChatConversationOption])?
    private var listItemView: ((_ conversation: Conversation) -> UIView)?
    private var subtitleView: ((_ conversation: Conversation) -> UIView)?
    private let tryAgainText = "TRY_AGAIN".localize()
    private let cancelText = "CANCEL".localize()
    var datePattern: ((_ conversation: Conversation) -> String)?
    var onItemClick: ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)?
    private var onItemLongClick: ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)?
    private var onError: ((_ error: CometChatException) -> Void)?
    var onBack: (() -> Void)?
    var onDidSelect: ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)?
    
    @discardableResult
    public func setOnItemClick(onItemClick: @escaping ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)) -> Self {
        self.onItemClick = onItemClick
        return self
    }
    
    @discardableResult
    public func setOnItemLongClick(onItemLongClick: @escaping ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)) -> Self {
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
    
    // MARK: - Init
    public init(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder = ConversationsBuilder.getDefaultRequestBuilder()) {
        self.conversationRequestBuilder = conversationRequestBuilder
        conversationsStyle = ConversationsStyle()
        avatarStyle = AvatarStyle()
        statusIndicatorStyle = StatusIndicatorStyle()
        listItemStyle = ListItemStyle()
        badgeStyle = BadgeStyle()
        receiptStyle = ReceiptStyle()
        dateStyle = DateStyle()
        normalSubtitlefont = CometChatTheme.typography.subtitle1
        boldSubtitlefont = CometChatTheme.typography.subtitle1
        isHideDeletedMessages = false
        viewModel = ConversationsViewModel(conversationRequestBuilder: conversationRequestBuilder)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK:- ViewController Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView(style: .plain)
        setupAppearance()
        registerCells()
        tableView.refreshControl = refreshControl
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        viewModel.isRefresh = true
        connect()
        reloadData()
       // fetchData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disconnect()
    }
    
    public func connect() {
        CometChat.addConnectionListener("conversations-sdk-listener", self)
        viewModel.connect()
    }
    
    public func disconnect() {
        CometChat.removeConnectionListener("conversations-sdk-listener")
        viewModel.disconnect()
    }
    
    // MARK:- fetch Data
    private func fetchData() {
        viewModel.fetchConversations()
    }
    
    // MARK:- reloadData
    private func reloadData() {
        // reload tableview
        showIndicator()
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            DispatchQueue.main.async {
                if this.viewModel.size() == 0 && this.noChatFound {
                    if let emptyView = this.emptyView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    this.tableView.setEmptyMessage("", color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    if this.viewModel.conversations.count > 0{
                        this.noChatFound = false
                    }
                }
                this.reload()
                this.hideIndicator()
                this.refreshControl.endRefreshing()
            }
        }
        // catch the error
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
                        confirmDialog.set(confirmButtonText: this.tryAgainText)
                        confirmDialog.set(cancelButtonText: this.cancelText)
                        if this.errorStateText.isEmpty {
                            confirmDialog.set(error: CometChatServerError.get(error: error))
                        } else {
                            confirmDialog.set(messageText: this.errorStateText)
                        }
                        confirmDialog.open {
                            this.viewModel.fetchConversations()
                        }
                    }
                }
            }
        }
        
        // sound when new message received.
        viewModel.newMessageReceived = { [weak self] message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                if !this.disableSoundForMessages {
                    CometChatSoundManager().play(sound: .incomingMessageFromOther, customSound: this.customSoundForMessages)
                }
            }
        }
        
        // reload data at particular index.
        viewModel.reloadAtIndex = { row in
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .none)
            }
        }
        
        viewModel.updateStatus = { [weak self] (row, status) in
            guard let strongSelf = self else { return }
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = strongSelf.tableView.cellForRow(at: indexPath) as? CometChatListItem {
                switch status {
                case .online:
                    cell.hide(statusIndicator: false)
                    cell.set(statusIndicatorColor: strongSelf.conversationsStyle.onlineStatusColor)
                case .offline: cell.hide(statusIndicator: true)
                case .available: cell.hide(statusIndicator: true)
                }
                cell.build()
            }
        }
        
        // update typing indicator when user typing.
        viewModel.updateTypingIndicator = { [weak self] (row, uid, isTyping) in
            guard let strongSelf = self else { return }
            guard let cell = strongSelf.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? CometChatListItem else { return }
            // may be improve.
            guard let subTitleStackView = cell.getSubTitle() else { return }
            subTitleStackView.subviews.forEach { subview in
                guard let stackView = subview as? UIStackView else { return }
                stackView.subviews.forEach { innerSubview  in
                    // get the typing indicator
                    if let typingLabel = innerSubview.subviews.last as? UILabel,
                       ((typingLabel.text?.contains("typing")) != nil) {
                        
                        if !isTyping {
                            innerSubview.subviews.forEach { lastMessage in
                                // lastMessage
                                if lastMessage.tag == 4, let lastMessage = lastMessage as? UILabel {
                                    lastMessage.text = ConversationsUtils().getLastMessage(conversation: strongSelf.viewModel.conversations[row], isHideDeletedMessages: strongSelf.isHideDeletedMessages)
                                    
                                    if !isTyping {
                                        lastMessage.isHidden = false
                                    } else {
                                        typingLabel.isHidden = true
                                    }
                                }
                                
                            }
                        } else {
                            innerSubview.subviews.forEach { call_ReceiptView in
                                if call_ReceiptView.tag == 3 || call_ReceiptView.tag == 5 {
                                    call_ReceiptView.isHidden = true
                                }
                            }
                            typingLabel.text = ConversationConstants.typingText
                            typingLabel.isHidden = isTyping ? false : true
                        }
                    }
                    
                }
            }
        }
        
        // called when conversation gets deleted.
        viewModel.onDelete = { [weak self] (section, row) in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: .automatic)
            }
        }
        
        // called when conversation gets deleted.
        viewModel.onDelete = { [weak self] (section, row) in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: .automatic)
            }
        }
    }
    
    // register cell
    fileprivate func registerCells() {
        self.registerCellWith(title: CometChatListItem.identifier)
    }
    
    // set appearance
    private func setupAppearance() {
        self.set(searchPlaceholder: ConversationConstants.searchText)
            .set(title: ConversationConstants.chats, mode: .automatic)
            .hide(search: true)
            .show(backButton: false)
        set(conversationsStyle: ConversationsStyle())
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        setupAppearance()
    }
    
    //
    override func onBackCallback() {
        if let onBack = onBack {
            onBack()
        } else {
            // Default
            self.dismiss(animated: true)
        }
    }
}

extension CometChatConversations {
    
    @discardableResult
    public func insert(conversation: Conversation, at: Int) -> Self {
        viewModel.insert(conversation: conversation, at: at)
        return self
    }
    
    @discardableResult
    func update(conversation: Conversation) -> Self {
        viewModel.update(conversation: conversation)
        return self
    }
    
    @discardableResult
    func remove(conversation: Conversation) -> Self {
        viewModel.remove(conversation: conversation)
        return self
    }
    
    @discardableResult
    func clearList() -> Self {
        viewModel.clearList()
        return self
    }
    
    func size() -> Int {
        return viewModel.size()
    }
    
    @discardableResult
    public func set(conversationsStyle: ConversationsStyle) -> Self{
        set(background: [conversationsStyle.background.cgColor])
        set(titleColor: conversationsStyle.titleColor)
        set(titleFont: conversationsStyle.titleFont)
        set(largeTitleColor: conversationsStyle.largeTitleColor)
        set(largeTitleFont: conversationsStyle.largeTitleFont)
        set(backButtonTint: conversationsStyle.backButtonTint)
        set(corner: conversationsStyle.cornerRadius)
        set(borderColor: conversationsStyle.borderColor)
        set(borderWidth: conversationsStyle.borderWidth)
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
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(badgeStyle: BadgeStyle) -> Self {
        self.badgeStyle = badgeStyle
        return self
    }
    
    @discardableResult
    public func set(dateStyle: DateStyle) -> Self {
        self.dateStyle = dateStyle
        return self
    }
    
    @discardableResult
    public func set(receiptStyle: ReceiptStyle) -> Self {
        self.receiptStyle = receiptStyle
        return self
    }
    
    @discardableResult
    public func disable(userPresence: Bool) -> Self {
        disableUsersPresence = userPresence
        return self
    }
    
    @discardableResult
    public func disable(receipt: Bool) -> Self {
        disableReceipt = receipt
        viewModel.disable(receipt: receipt)
        return self
    }
    
    @discardableResult
    public func disable(typing: Bool) -> Self {
        disableTyping = typing
        return self
    }
    
    @discardableResult
    public func disable(soundForMessages: Bool) -> Self {
        disableSoundForMessages = soundForMessages
        return self
    }
    
    @discardableResult
    public func set(customSoundForMessages: URL) -> Self {
        self.customSoundForMessages = customSoundForMessages
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
    public func set(readIcon: UIImage) -> Self {
        self.readIcon = readIcon
        return self
    }
    
    @discardableResult
    public func set(deliveredIcon: UIImage) -> Self {
        self.deliveredIcon = deliveredIcon
        return self
    }
    
    @discardableResult
    public func set(sentIcon: UIImage) -> Self {
        self.sentIcon = sentIcon
        return self
    }
    
    @discardableResult
    public func setDatePattern(datePattern: @escaping ((_ conversation: Conversation) -> String)) -> Self {
        self.datePattern = datePattern
        return self
    }
    
    @discardableResult
    public func setListItemView(listItemView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func setOptions(options: ((_ conversation: Conversation?) -> [CometChatConversationOption])?) -> Self {
      self.options = options
      return self
    }
    
    @discardableResult
    public func getSelectedConversations() -> [Conversation] {
        return viewModel.selectedConversations
    }
    
    @discardableResult
    public func setSubtitle(subtitleView: @escaping ((_ conversation: Conversation) -> UIView)) -> Self {
        self.subtitleView = subtitleView
        return self
    }
    
    @discardableResult
    public func setRequestBuilder(conversationRequestBuilder: ConversationRequest.ConversationRequestBuilder) -> Self {
        viewModel = ConversationsViewModel(conversationRequestBuilder: conversationRequestBuilder)
        return self
    }
}

extension CometChatConversations {
    
    // MARK: - TableView delegate and datasource method that inherited from the CometChatListBase.
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem , let conversation = viewModel.conversations[safe: indexPath.row] {
            if let listItemView = listItemView?(conversation) {
                let container = UIStackView()
                container.axis = .vertical
                container.addArrangedSubview(listItemView)
                listItem.set(customView: container)
                
            } else {
                listItem.set(tail: ConversationsUtils().configureTailView(conversation: conversation, badgeStyle: badgeStyle,dateStyle: dateStyle, datePattern: datePattern?(conversation)))
                if let subtitle = subtitleView?(conversation){
                    listItem.set(subtitle: subtitle)
                } else {
                    listItem.set(subtitle: ConversationsUtils().configureSubtitleView(conversation: conversation, isTypingEnabled: viewModel.isTyping, isHideDeletedMessages: isHideDeletedMessages,sentIcon: sentIcon , deliveredIcon: deliveredIcon , readIcon: readIcon,receiptStyle: receiptStyle, disableReceipt: disableReceipt))
                }
                
                listItem.set(listItemStyle: listItemStyle)
                listItem.set(avatarStyle: avatarStyle)
                listItem.set(statusIndicatorStyle: statusIndicatorStyle)
                switch conversation.conversationType {
                case .user:
                    guard let user = conversation.conversationWith as? User else { return UITableViewCell()}
                    if let name = user.name?.capitalized {
                        listItem.set(title: name)
                    }
                    listItem.set(avatarURL: user.avatar ?? "")
                    if !disableUsersPresence {
                        switch user.status {
                        case .offline:
                            listItem.hide(statusIndicator: true)
                        case .online:
                            listItem.hide(statusIndicator: false)
                            listItem.set(statusIndicatorColor: conversationsStyle.onlineStatusColor)
                        case .available:
                            listItem.hide(statusIndicator: true)
                        @unknown default: listItem.hide(statusIndicator: true)
                        }
                    }
                case .group:
                    guard let group = conversation.conversationWith as? Group else { return UITableViewCell()}
                    if let name = group.name?.capitalized {
                        listItem.set(title: name)
                    }
                    listItem.set(avatarURL: group.icon ?? "")
                    switch group.groupType {
                    case .public:
                        listItem.hide(statusIndicator: true)
                    case .private:
                        listItem.hide(statusIndicator: false)
                        listItem.set(statusIndicatorIcon: privateGroupIcon)
                        listItem.set(statusIndicatorColor: conversationsStyle.privateGroupIconBackgroundColor)
                        listItem.set(statusIndicatorIconTint: .white)
                        listItem.statusIndicator.set(borderWidth: 2)
                    case .password:
                        listItem.hide(statusIndicator: false)
                        listItem.set(statusIndicatorIcon: protectedGroupIcon)
                        listItem.set(statusIndicatorColor: conversationsStyle.protectedGroupIconBackgroundColor)
                        listItem.set(statusIndicatorIconTint: .white)
                        listItem.statusIndicator.set(borderWidth: 2)
                    @unknown default: listItem.hide(statusIndicator: true)
                        break
                    }
                case .none: break
                    
                @unknown default: break
                    
                }
                switch selectionMode {
                case .single, .multiple: listItem.allow(selection: true)
                case .none:  listItem.allow(selection: false)
                }
            }
            listItem.onItemLongClick = { [weak self] in
                guard let this = self else { return }
                this.onItemLongClick?(conversation, indexPath)
            }
            listItem.build()
            return listItem
        }
        return UITableViewCell()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.conversations.count
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
                viewModel.isRefresh = false
                viewModel.fetchConversations()
            }
        } else if currentOffset < -250 {
            showIndicator()
            viewModel.isRefresh = true
        } else {
            viewModel.isRefresh = false
        }
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = viewModel.conversations[indexPath.row]
        if let onItemClick = onItemClick {
            onItemClick(conversation, indexPath)
        } else {
            onDidSelect?(conversation, indexPath)
        }
        
        if selectionMode == .none {
            tableView.deselectRow(at: indexPath, animated: true)
        } else {
            if !viewModel.selectedConversations.contains(conversation) {
                self.viewModel.selectedConversations.append(conversation)
            }
        }
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let conversation =  viewModel.conversations[indexPath.row]
        if let foundConversation = viewModel.selectedConversations.firstIndex(of: conversation) {
            viewModel.selectedConversations.remove(at: foundConversation)
        }
    }
    
    public override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // call when click on delete icon.
        }
    }
    
    public override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: ConversationConstants.delete) { (action, sourceView, completionHandler) in
            if let conversation = self.viewModel.conversations[safe: indexPath.row] {
                self.delete(conversation: conversation)
            }
        }
        delete.image = UIImage(named: "messages-delete", in: CometChatUIKit.bundle, with: nil)?.withTintColor(.white)
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [delete])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }
    
    private func delete(conversation: Conversation) {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: ConversationConstants.deleteConversationMessage, preferredStyle: .actionSheet)
        
        // create an action
        let firstAction: UIAlertAction = UIAlertAction(title: ConversationConstants.delete, style: .destructive) { action -> Void in
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.viewModel.delete(conversation: conversation)
            }
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: ConversationConstants.cancel, style: .cancel) { action -> Void in }
        actionSheetController.addAction(firstAction)
        actionSheetController.addAction(cancelAction)
        present(actionSheetController, animated: true) {
        }
    }
}

extension CometChatConversations: CometChatConnectionDelegate {
    public func connected() {
        viewModel.isRefresh = true
        reloadData()
        fetchData()
    }
    
    public func connecting() {
        
    }
    
    public func disconnected() {
        
    }
}

