//
//  CometChatMessageList.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 26/12/22.
import UIKit
import Foundation
import CometChatPro

@MainActor @IBDesignable open class CometChatMessageList: UIView {
    
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var container: UIStackView!
    @IBOutlet weak var tableView: UITableView!
    
    private (set) var emptyStateText: String = "NO_MESSAGES_FOUND".localize()
    private (set) var emptyStateTextColor: UIColor = CometChatTheme.palatte.accent500
    private (set) var emptyStateTextFont: UIFont = CometChatTheme.typography.largeHeading
    private (set) var errorStateText: String = ""
    private (set) var emptyStateView: UIView?
    private (set) var errorStateView: UIView?
    private (set) var disableReceipt: Bool = false
    private (set) var disableSoundForMessages: Bool = false
    private (set) var customSoundForMessages: URL?
    private (set) var readIcon: UIImage?
    private (set) var deliveredIcon: UIImage?
    private (set) var sentIcon: UIImage?
    private (set) var waitIcon: UIImage?
    private (set) var alignment: MessageListAlignment = .standard
    private (set) var timeAlignment: MessageBubbleTimeAlignment = .bottom
    private (set) var hideDeletedMessages: Bool = false
    private (set) var hideError: Bool = false
    private (set) var showAvatar: Bool = true
    private (set) var islastVisibleCell: Bool?
    private (set) var datePattern: ((_ timestamp: Int?) -> String)?
    private (set) var dateSeparatorPattern: ((_ timestamp: Int?) -> String)?
    private (set) var newMessageIndicatorText: String = ""
    private (set) var newMessageIndicatorStyle: NewMessageIndicatorStyle = NewMessageIndicatorStyle()
    private (set) var scrollToBottomOnNewMessages: Bool = true
    private (set) var onThreadRepliesClick: ((_ message: BaseMessage?, _ messageBubbleView: UIView?) -> ())?
    private (set) var messageListStyle: MessageListStyle = MessageListStyle()
    private (set) var refreshControl: UIRefreshControl!
    private (set) var controller: UIViewController?
    private (set) var messageIndicator : CometChatNewMessageIndicator?
    private (set) var templates: [(type: String, template: CometChatMessageTemplate)]?
    private (set) var messageBubbleStyle = MessageBubbleStyle()
    private (set) var avatarStyle = AvatarStyle()
    private (set) var dateSeperatorStyle = DateStyle()
    private (set) var viewModel: MessageListViewModel?
    private (set) var baseMessage: BaseMessage?
    private (set) var cell: CometChatMessageBubble?
    private (set) var messagesRequestBuilder: MessagesRequest.MessageRequestBuilder? = nil
    
    public override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = self.bounds
            self.addSubview(contentView)
        }
    }
    
    @discardableResult
    public func set(user: User, parentMessage: BaseMessage? = nil) -> Self {
        self.viewModel = MessageListViewModel(user: user, messagesRequestBuilder: self.messagesRequestBuilder, parentMessage: parentMessage)
        build()
        connect()
        return self
    }
    
    @discardableResult
    public func set(group: Group, parentMessage: BaseMessage? = nil) -> Self {
        self.viewModel = MessageListViewModel(group: group, messagesRequestBuilder: self.messagesRequestBuilder, parentMessage: parentMessage)
        build()
        connect()
        return self
    }
    
    @discardableResult
    public func set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder) -> Self {
        self.messagesRequestBuilder = messagesRequestBuilder
        return self
    }
    
    @discardableResult
    public func set(templates: [(type: String, template: CometChatMessageTemplate)]? = nil) -> Self {
        self.templates = templates
        return self
    }


    private func setupTableView() {
        tableView.backgroundColor = messageListStyle.background
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        registerCells()
        setupMessageIndicator()
    }
    
    private func setupMessageIndicator() {
        messageIndicator = CometChatNewMessageIndicator()
        if let messageIndicator = messageIndicator {
            self.addSubview(messageIndicator)
            messageIndicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                messageIndicator.centerXAnchor.constraint(equalTo: self.tableView.centerXAnchor, constant: 0),
                messageIndicator.centerYAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 25)
            ])
            messageIndicator.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: 14))
            messageIndicator.set(style: newMessageIndicatorStyle)
            UIView.transition(with: messageIndicator, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.messageIndicator?.reset()
            })
            messageIndicator.onClick = {
                self.messageIndicator?.reset()
                self.scrollToBottom()
            }
        }
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadPrevious), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }
    
    public func reload() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.tableView.reloadData()
        }
    }
    
    private func build() {
        setupTableView()
        setupRefreshControl()
        reloadData()
        fetchData()
    }
    
    private func fetchData() {
        guard let viewModel = viewModel else { return }
        if viewModel.messages.isEmpty {
            showIndicator()
        }
        viewModel.fetchPreviousMessages()
    }
    
    @objc func loadPrevious(_ sender: Any) {
        viewModel?.fetchPreviousMessages()
    }
    
    func showIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.tableView.tableFooterView =  ActivityIndicator.show()
            this.tableView.tableFooterView?.isHidden = false
        }
    }
    
    func hideIndicator() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            ActivityIndicator.hide()
            this.tableView.tableFooterView?.isHidden = true
        }
    }
    
    private func reloadData() {
        guard let viewModel = viewModel else { return }
        viewModel.refresh = { [weak self]  in
            guard let this = self else { return }
            this.hideIndicator()
            this.reload()
            DispatchQueue.main.async {
                this.refreshControl?.endRefreshing()
                if viewModel.messages.isEmpty {
                    if let emptyView = this.emptyStateView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    var id = [String:Any]()
                    if let user = viewModel.user {
                        id["uid"] = user.uid
                    }
                    if let group = viewModel.group {
                        id["guid"] = group.guid
                    }
                    if viewModel.parentMessage?.id != 0 {
                        id["parentMessageId"] = id
                    }
                    CometChatUIEvents.emitOnActiveChatChanged(id: id, lastMessage: viewModel.messages.last?.messages.last, user: viewModel.user, group: viewModel.group)
                    this.tableView.restore()
                }
            }
            this.scrollToBottom()
        }
        
        viewModel.reload = { [weak self]  in
            guard let this = self else { return }
            this.hideIndicator()
            this.reload()
            DispatchQueue.main.async {
                this.refreshControl?.endRefreshing()
                if viewModel.messages.isEmpty {
                    if let emptyView = this.emptyStateView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    this.tableView.restore()
                }
            }
        }
        
        viewModel.appendAtIndex = { [weak self] section , row, message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.tableView.beginUpdates()
                if section == 0 {
                    if row == 1 {
                        this.tableView.insertSections([0], with: .top)
                        this.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    } else {
                        this.tableView.insertRows(at: [IndexPath(row: row - 1, section: 0)], with: .automatic)
                    }
                } else {
                    if row == 1 {
                        this.tableView.insertSections([section - 1], with: .top)
                        this.tableView.insertRows(at: [IndexPath(row: row - 1, section: section - 1)], with: .automatic)
                    } else {
                        this.tableView.insertRows(at: [IndexPath(row: row - 1, section: section)], with: .automatic)
                    }
                }
                this.tableView.endUpdates()
                
                if viewModel.messages.isEmpty {
                    if let emptyView = this.emptyStateView {
                        this.tableView.set(customView: emptyView)
                    } else {
                        this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                    }
                } else {
                    this.tableView.restore()
                }
                
                if this.scrollToBottomOnNewMessages {
                    this.scrollToBottom()
                }
            }
        }
        
        viewModel.updateAtIndex = { [weak self] section , row, message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.tableView.beginUpdates()
                this.tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
                this.tableView.endUpdates()
            }
        }
        
        viewModel.deleteAtIndex = { [weak self] section , row, message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.tableView.beginUpdates()
                this.tableView.deleteRows(at: [IndexPath(row: row, section: section)], with: .automatic)
                this.tableView.endUpdates()
            }
        }
        
        viewModel.newMessageReceived = { [weak self] message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                if !this.disableSoundForMessages {
                    CometChatSoundManager().play(sound: .incomingMessage, customSound: this.customSoundForMessages)
                }
                if !this.scrollToBottomOnNewMessages {
                    this.messageIndicator?.incrementCount()
                }
            }
        }
        
        viewModel.failure = { [weak self] error in
            guard let this = self else { return }
            DispatchQueue.main.async {
                if !this.hideError {
                    if let errorView = this.errorStateView {
                        this.tableView.set(customView: errorView)
                    } else {
                        if ((this.viewModel?.messages.isEmpty) != nil) {
                            if let emptyView = this.emptyStateView {
                                this.tableView.set(customView: emptyView)
                            } else {
                                this.tableView.setEmptyMessage(this.emptyStateText, color: this.emptyStateTextColor, font: this.emptyStateTextFont)
                            }
                        } else {
                            this.tableView.restore()
                        }
                        let confirmDialog = CometChatDialog()
                        confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                        confirmDialog.set(cancelButtonText: "CANCEL".localize())
                        if this.errorStateText.isEmpty {
                            confirmDialog.set(error: CometChatServerError.get(error: error))
                        } else {
                            confirmDialog.set(messageText: this.errorStateText)
                        }
                        confirmDialog.open {
                            this.viewModel?.fetchPreviousMessages()
                        }
                    }
                }
            }
        }
    }
    
    fileprivate func registerCells() {
        self.registerCellWith(title: CometChatMessageBubble.identifier)
        self.registerCellWith(title: CometChatGroupActionBubble.identifier)
    }
    
    fileprivate func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: CometChatUIKit.bundle)
        self.tableView.register(cell, forCellReuseIdentifier: title)
    }
    
}

extension CometChatMessageList: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel?.messages.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let date = viewModel?.messages[safe: section]?.date {
            let timestamp = Int(date.timeIntervalSince1970)
            let dateHeader = CometChatMessageDateHeader()
            if let time = dateSeparatorPattern?(timestamp) {
                dateHeader.text = time
            } else {
                dateHeader.set(pattern: .dayDate)
                dateHeader.set(timestamp: timestamp)
            }
            let view = UIView()
            view.addSubview(dateHeader)
            view.backgroundColor = messageListStyle.background
            dateHeader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            dateHeader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            return view
        }
        return nil
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.messages[safe: section]?.messages.count ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = viewModel?.messages[safe: indexPath.section]?.messages[safe: indexPath.row] else { return UITableViewCell() }
        guard let sender = message.sender, let uid = sender.uid else { return UITableViewCell() }
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: uid)
        if let template = templates?.filter({$0.template.type == MessageUtils.getDefaultMessageTypes(message: message) && $0.template.category == MessageUtils.getDefaultMessageCategories(message: message) }).first?.template {
            
            if let cell = tableView.dequeueReusableCell(withIdentifier: CometChatMessageBubble.identifier , for: indexPath) as? CometChatMessageBubble {
                if message.messageCategory == .action || message.messageCategory == .call {
                    cell.set(bubbleAlignment: .center)
                    cell.hide(avatar: true)
                    if let contentView = template.contentView?(message, cell.alignment, controller) {
                        cell.containerView.addArrangedSubview(contentView)
                        cell.background.backgroundColor = UIColor.clear
                    }
                    
                } else {
                    if alignment == .standard && isLoggedInUser {
                        cell.set(bubbleAlignment: .right)
                        if message.messageType == .text {
                            if message.deletedAt == 0 {
                                cell.background.backgroundColor = CometChatTheme.palatte.primary
                            }else {
                                
                                cell.background.backgroundColor = (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme.palatte.accent100 : CometChatTheme.palatte.secondary
                            }
                        } else {
                            
                            cell.background.backgroundColor = (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme.palatte.accent100 : CometChatTheme.palatte.secondary
                        }
                    } else {
                        
                        cell.set(bubbleAlignment: .left)
                        cell.background.backgroundColor = (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme.palatte.accent100 : CometChatTheme.palatte.secondary
                    }
                    if let bubbleView = template.bubbleView?(message, cell.alignment, controller) {
                        let bubbleContainer = UIStackView()
                        bubbleContainer.axis = .vertical
                        bubbleContainer.addArrangedSubview(bubbleView)
                        cell.set(bubbleView: bubbleContainer)
                    } else {
                        if let headerView = template.headerView?(message, cell.alignment, controller) {
                            cell.headerView.addArrangedSubview(headerView)
                            cell.topStackView.translatesAutoresizingMaskIntoConstraints = false
                            cell.topStackView.heightAnchor.constraint(equalToConstant: headerView.frame.height).isActive = true
                        } else {
                            
                            let nameLabel = UILabel()
                            nameLabel.textColor = messageListStyle.nameTextColor
                            nameLabel.numberOfLines = 1
                            nameLabel.text = message.sender?.name?.capitalized ?? ""
                            
                            if(message.receiverType == .group && isLoggedInUser) {
                                nameLabel.textColor = .clear
                                nameLabel.translatesAutoresizingMaskIntoConstraints = false
                                nameLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
                            } else {
                                nameLabel.font = messageListStyle.nameTextFont
                                nameLabel.textColor = messageListStyle.nameTextColor
                                nameLabel.translatesAutoresizingMaskIntoConstraints = false
                                nameLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
                            }
                            
                            let date = CometChatDate()
                            if let time = datePattern?(message.sentAt) {
                                date.text = time
                            } else {
                                date.set(pattern: .time)
                                date.text = date.setTime(for: message.sentAt)
                            }
                            date.set(timeFont: messageListStyle.timestampTextFont).set(timeColor: messageListStyle.timestampTextColor)
                            if timeAlignment == .top {
                                cell.headerView.addArrangedSubview(date)
                            }
                            cell.headerView.addArrangedSubview(nameLabel)
                        }
                        
                        if let footerView = template.footerView?(message, cell.alignment, controller) {
                            cell.footerView.addArrangedSubview(footerView)
                        } else {
                            let footerStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
                            
                            let reciept = CometChatReceipt(image: UIImage(named: "messages-delivered" ,in: CometChatUIKit.bundle, with: nil))
                            reciept.set(messageReadIcon: readIcon).set(messageSentIcon: sentIcon).set(messageDeliveredIcon: deliveredIcon)
                            
                            reciept.heightAnchor.constraint(equalToConstant: 20).isActive = true
                            reciept.widthAnchor.constraint(equalToConstant: 20).isActive = true
                            reciept.set(receipt: MessageReceiptUtils.get(receiptStatus: message))
                            let date = CometChatDate()
                            if let time = datePattern?(message.sentAt) {
                                date.text = time
                            } else {
                                date.set(pattern: .time)
                                date.text = date.setTime(for: message.sentAt)
                            }
                            date.set(timeFont: messageListStyle.timestampTextFont).set(timeColor: messageListStyle.timestampTextColor)
                            if timeAlignment == .bottom {
                                footerStackView.addArrangedSubview(date)
                            }
                            if (alignment == .standard && isLoggedInUser) && !disableReceipt {
                                footerStackView.addArrangedSubview(reciept)
                            }
                            cell.footerView.addArrangedSubview(footerStackView)
                            cell.bottomStackView.translatesAutoresizingMaskIntoConstraints = false
                            cell.bottomStackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                        }
                        
                        if let contentView = template.contentView?(message, cell.alignment, controller) {
                            
                            cell.containerView.addArrangedSubview(contentView)
                            self.getRepliesView(forMessage: message, cell: cell, isLoggedInUser: isLoggedInUser)
                        }
                        if let bottomView = template.bottomView?(message, cell.alignment, controller) {
                            cell.containerView.addArrangedSubview(bottomView)
                        }
                        
                        if message.deletedAt > 0 {
                            cell.replyView.isHidden = true
                            cell.viewReplies.isHidden = true
                        } else {
                            cell.replyView.isHidden = false
                            cell.viewReplies.isHidden = false
                        }
                        
                        if let user = message.sender , let name = user.name?.capitalized {
                            cell.set(avatarName: name)
                            cell.set(avatarURL: user.avatar ?? "")
                            cell.set(avatarStyle: avatarStyle)
                            
                            switch message.receiverType {
                            case .user where alignment == .standard:
                                if !isLoggedInUser && showAvatar {
                                    cell.hide(avatar: false)
                                } else {
                                    cell.hide(headerView: true)
                                }
                            case .user where alignment == .leftAligned, .group where alignment == .leftAligned:
                                if showAvatar {
                                    cell.hide(avatar: false)
                                }
                            case .group, .user:
                                if showAvatar {
                                    cell.hide(avatar: false)
                                }
                            @unknown default: break
                            }
                        }
                    }
                }
                if let controller = controller {
                    cell.set(controller: controller)
                }
                cell.build()
                return cell
            }
        }
    
        return UITableViewCell()
      }
    
    public  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let messageIndicator = self.messageIndicator else { return }
            //TODO:- Needs to be address.
            let intTotalrow = tableView.numberOfRows(inSection: (self.viewModel?.messages.count ?? 0) - 1)
            if indexPath.row == intTotalrow - 1 {
                UIView.transition(with: messageIndicator, duration: 0.4,
                                  options: .transitionCrossDissolve,
                                  animations: {
                    messageIndicator.isHidden = true
                })
                self.islastVisibleCell = true
                self.messageIndicator?.reset()
            } else {
                self.islastVisibleCell = false
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        footerView.backgroundColor = messageListStyle.background
        return footerView
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    public  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {}
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) { }
    
}

extension CometChatMessageList {
    
    @discardableResult
    public func set(emptyStateText: String) -> Self {
        self.emptyStateText = emptyStateText
        return self
    }
    
    @discardableResult
    public func set(errorStateText: String) -> Self {
        self.errorStateText = errorStateText
        return self
    }
    
    @discardableResult
    public func set(emptyStateView: UIView?) -> Self {
        self.emptyStateView = emptyStateView
        return self
    }
    
    @discardableResult
    public func set(errorStateView: UIView?) -> Self {
        self.errorStateView = errorStateView
        return self
    }
    
    @discardableResult
    public func disable(receipt: Bool) -> Self {
        self.disableReceipt = receipt
        viewModel?.disable(receipt: receipt)
        return self
    }
    
    @discardableResult
    public func disable(soundForMessages: Bool) -> Self {
        self.disableSoundForMessages = soundForMessages
        return self
    }
    
    @discardableResult
    public func set(customSoundForMessages: URL) -> Self {
        self.customSoundForMessages = customSoundForMessages
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
    public func set(waitIcon: UIImage) -> Self {
        self.waitIcon = waitIcon
        return self
    }
    
    @discardableResult
    public func set(alignment: MessageListAlignment) -> Self {
        self.alignment = alignment
        return self
    }
    
    
    @discardableResult
    public func set(timeAlignment: MessageBubbleTimeAlignment) -> Self {
        self.timeAlignment = timeAlignment
        return self
    }
    
    @discardableResult
    public func hide(error: Bool) -> Self {
        self.hideError = error
        return self
    }
    
    @discardableResult
    public func show(avatar: Bool) -> Self {
        self.showAvatar = avatar
        return self
    }
    
    @discardableResult
    public func setDatePattern(datePattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.datePattern = datePattern
        return self
    }
    
    @discardableResult
    public func setDateSeparatorPattern(dateSeparatorPattern: ((_ timestamp: Int?) -> String)?) -> Self {
        self.dateSeparatorPattern = dateSeparatorPattern
        return self
    }
        
    @discardableResult
    public func set(newMessageIndicatorText: String) -> Self {
        self.newMessageIndicatorText = newMessageIndicatorText
        return self
    }
    
    @discardableResult
    public func set(newMessageIndicatorStyle: NewMessageIndicatorStyle) -> Self {
        self.newMessageIndicatorStyle = newMessageIndicatorStyle
        return self
    }
    
    @discardableResult
    public func scrollToBottomOnNewMessages(_ bool: Bool) -> Self {
        self.scrollToBottomOnNewMessages = scrollToBottomOnNewMessages
        return self
    }
    
    @discardableResult
    public func setOnThreadRepliesClick(onThreadRepliesClick: ((_ message: BaseMessage?, _ messageBubbleView: UIView?) -> ())?) -> Self {
        self.onThreadRepliesClick = onThreadRepliesClick
        return self
    }
    
    @discardableResult
    public func set(messageListStyle: MessageListStyle) -> Self {
        self.messageListStyle = messageListStyle
        return self
    }
    
    @discardableResult
    public func set(headerView: UIView) -> Self {
        self.container.insertArrangedSubview(headerView, at: 0)
        return self
    }
    
    @discardableResult
    public func set(footerView: UIView) -> Self {
        self.container.insertArrangedSubview(footerView, at: container.subviews.count - 1)
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func connect() -> Self {
        viewModel?.connect()
        return self
    }
    
    @discardableResult
    public func disconnect() -> Self {
        viewModel?.disconnect()
        return self
    }
    
    @discardableResult
    public func add(message: BaseMessage) -> Self {
        viewModel?.add(message: message)
        return self
    }

    @discardableResult
    public func update(message: BaseMessage) -> Self {
        viewModel?.update(message: message)
        return self
    }

    @discardableResult
    public func remove(message: BaseMessage) -> Self {
        viewModel?.remove(message: message)
        return self
    }
    
    @discardableResult
    public func delete(message: BaseMessage) -> Self {
        viewModel?.delete(message: message)
        return self
    }

    @discardableResult
    public func clearList() -> Self {
        viewModel?.clearList()
        return self
    }
    
    @discardableResult
    public func scrollToBottom() -> Self {
        if scrollToBottomOnNewMessages {
            self.tableView.scrollToBottomRow()
        }
        return self
    }
    
    @discardableResult
    public func isEmpty() -> Bool {
        if let viewModel = viewModel {
            return  viewModel.messages.isEmpty ? true : false
        }
        return false
    }
    
    public func scrollToLastVisibleCell() {
        if let lastCell =  self.tableView.indexPathsForVisibleRows, let lastIndex = lastCell.last {
            self.tableView.scrollToLastVisibleCell(lastIndex: lastIndex)
        }
    }
    
}

extension CometChatMessageList {
    
     func configureParentView(template: CometChatMessageTemplate, message: BaseMessage) -> UIView? {
        if let cell =  Bundle.module.loadNibNamed(CometChatMessageBubble.identifier, owner: self, options: nil)![0]  as? CometChatMessageBubble {
            guard let sender = message.sender, let uid = sender.uid else { return nil }
            let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: uid)
            if self.alignment == .standard && isLoggedInUser {
                cell.set(bubbleAlignment: .right)
                if message.messageType == .text {
                    cell.background.backgroundColor = CometChatTheme.palatte.primary
                } else {
                    cell.background.backgroundColor = CometChatTheme.palatte.secondary
                }
                
            } else {
                cell.set(bubbleAlignment: .left)
                cell.background.backgroundColor = CometChatTheme.palatte.secondary
            }
            if let bubbleView = template.bubbleView?(message, cell.alignment, self.controller) {
                let bubbleContainer = UIStackView()
                bubbleContainer.axis = .vertical
                bubbleContainer.addArrangedSubview(bubbleView)
                cell.set(bubbleView: bubbleContainer)
            } else {
                if let headerView = template.headerView?(message, cell.alignment, self.controller) {
                    cell.headerView.addArrangedSubview(headerView)
                    cell.topStackView.translatesAutoresizingMaskIntoConstraints = false
                    cell.topStackView.heightAnchor.constraint(equalToConstant: headerView.frame.height).isActive = true
                } else {
                    
                    let nameLabel = UILabel()
                    nameLabel.textColor = self.messageListStyle.nameTextColor
                    nameLabel.numberOfLines = 1
                    nameLabel.text = message.sender?.name?.capitalized ?? ""
                    
                    if(message.receiverType == .group && isLoggedInUser) {
                        nameLabel.textColor = .clear
                        nameLabel.translatesAutoresizingMaskIntoConstraints = false
                        nameLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
                    } else {
                        nameLabel.font = self.messageListStyle.nameTextFont
                        nameLabel.textColor = self.messageListStyle.nameTextColor
                        nameLabel.translatesAutoresizingMaskIntoConstraints = false
                        nameLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
                    }
                    let date = CometChatDate()
                    if let time = self.datePattern?(message.sentAt) {
                        date.text = time
                    } else {
                        date.set(pattern: .time)
                        date.text = date.setTime(for: message.sentAt)
                    }
                    date.set(timeFont: self.messageListStyle.timestampTextFont).set(timeColor: self.messageListStyle.timestampTextColor)
                    if self.timeAlignment == .top {
                        cell.headerView.addArrangedSubview(date)
                    }
                    cell.headerView.addArrangedSubview(nameLabel)
                }
                if let footerView = template.footerView?(message, cell.alignment, self.controller) {
                    cell.footerView.addArrangedSubview(footerView)
                } else {
                    let footerStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: 200, height: 25))
                    let reciept = CometChatReceipt(image: UIImage(named: "messages-delivered" ,in: CometChatUIKit.bundle, with: nil))
                    reciept.set(messageReadIcon: self.readIcon).set(messageSentIcon: self.sentIcon).set(messageDeliveredIcon: self.deliveredIcon)
                    
                    reciept.heightAnchor.constraint(equalToConstant: 20).isActive = true
                    reciept.widthAnchor.constraint(equalToConstant: 20).isActive = true
                    reciept.set(receipt: MessageReceiptUtils.get(receiptStatus: message))
                    let date = CometChatDate()
                    if let time = self.datePattern?(message.sentAt) {
                        date.text = time
                    } else {
                        date.set(pattern: .time)
                        date.text = date.setTime(for: message.sentAt)
                    }
                    date.set(timeFont: self.messageListStyle.timestampTextFont).set(timeColor: self.messageListStyle.timestampTextColor)
                    if self.timeAlignment == .bottom {
                        footerStackView.addArrangedSubview(date)
                    }
                    if (self.alignment == .standard && isLoggedInUser) && !self.disableReceipt {
                        footerStackView.addArrangedSubview(reciept)
                    }
                    cell.footerView.addArrangedSubview(footerStackView)
                    cell.bottomStackView.translatesAutoresizingMaskIntoConstraints = false
                    cell.bottomStackView.heightAnchor.constraint(equalToConstant: 20).isActive = true
                }
                if message.deletedAt == 0 {
                    if let contentView = template.contentView?(message, cell.alignment, self.controller) {
                        cell.containerView.addArrangedSubview(contentView)
                    }
                    cell.viewReplies.isHidden = false
                    cell.replyView.isHidden = false
                } else {
                    let deleteBubble = CometChatDeleteBubble()
                    deleteBubble.backgroundColor(color: self.messageListStyle.background)
                    cell.containerView.addArrangedSubview(deleteBubble)
                    cell.viewReplies.isHidden = true
                    cell.replyView.isHidden = true
                }
                cell.replyView.isHidden = true
                switch message.receiverType {
                case .user where self.alignment == .standard:
                    if !isLoggedInUser && self.showAvatar {
                        cell.hide(avatar: false)
                    } else {
                        cell.hide(headerView: true)
                    }
                case .user where self.alignment == .leftAligned, .group where self.alignment == .leftAligned:
                    if self.showAvatar {
                        cell.hide(avatar: false)
                    }
                case .group, .user:
                    if self.showAvatar {
                        cell.hide(avatar: false)
                    }
                @unknown default: break
                }
            }
            if let controller = self.controller {
                cell.set(controller: controller)
            }
            cell.build()
            return cell
        }
        return nil
    }

    private func getRepliesView(forMessage: BaseMessage, cell: CometChatMessageBubble, isLoggedInUser: Bool) {
        if forMessage.replyCount != 0 {
            let stackView = UIStackView()
            stackView.spacing = 5
            stackView.distribution = .fill
            stackView.axis = .vertical
            stackView.alignment = .fill
            stackView.layoutMargins = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 8)
            stackView.isLayoutMarginsRelativeArrangement = true
            
            let labelContainer = UIStackView()
            labelContainer.axis = .horizontal
            labelContainer.alignment = .center
            
            let label = UILabel()
            label.text = "View \(forMessage.replyCount) Replies"
            label.font = CometChatTheme.typography.caption1
            let arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 2, height: 2))
            arrow.image = UIImage(named: "arrow-forward-1", in: CometChatUIKit.bundle, compatibleWith: nil)
            arrow.contentMode = .scaleAspectFit
            
            let arrowView = UIStackView()
            arrowView.alignment = .trailing
            arrowView.addArrangedSubview(arrow)
            arrowView.layoutMargins = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
            arrowView.isLayoutMarginsRelativeArrangement = true
            
            let seperator = UIView()
            seperator.translatesAutoresizingMaskIntoConstraints = false
            seperator.heightAnchor.constraint(equalToConstant: 1).isActive = true
            seperator.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            seperator.backgroundColor = CometChatTheme.palatte.accent100
            
            if isLoggedInUser && alignment == .standard && forMessage.messageType == .text {
                label.textColor = .white
                arrow.tintColor = .white
            }else {
                label.textColor = CometChatTheme.palatte.primary
                arrow.tintColor = CometChatTheme.palatte.accent700
            }
            
            labelContainer.addArrangedSubview(label)
            labelContainer.addArrangedSubview(arrowView)
            stackView.addArrangedSubview(labelContainer)
            cell.viewReplies.addArrangedSubview(seperator)
            cell.viewReplies.addArrangedSubview(stackView)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didViewRepliesTap(sender:)))
            cell.viewReplies.isUserInteractionEnabled = true
            tapGesture.numberOfTapsRequired = 1
            cell.viewReplies.addGestureRecognizer(tapGesture)
            
        }
    }
    
    @objc func didViewRepliesTap(sender: UITapGestureRecognizer) {
        guard let indexPath = self.tableView.indexPathForRow(at: sender.location(in: self.tableView)), let message = viewModel?.messages[safe: indexPath.section]?.messages[safe: indexPath.row] else {
            print("Error: indexPath)")
            return
        }
        if let messageTemplates = templates {
            for template in messageTemplates {
                if template.type == MessageUtils.getDefaultMessageTypes(message: message) {
                    if let parentMessageView = self.configureParentView(template: template.template, message: message) {
                        self.onThreadRepliesClick?(message, parentMessageView)
                    }
                }
            }
        }
    }
    
}
