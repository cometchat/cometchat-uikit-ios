//
//  CometChatMessageList.swift
 
//
//  Created by Pushpsen Airekar on 26/12/22.

import UIKit
import Foundation
import CometChatSDK

open class CometChatMessageList: UIView {
    
    // MARK: - UI Components
    lazy var container: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.backgroundColor = UIColor.clear
        return stackView
    }()

    lazy var headerViewContainer: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.isHidden = true
        stackView.backgroundColor = UIColor.clear
        return stackView
    }()

    open lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain).withoutAutoresizingMaskConstraints()
        tableView.alwaysBounceVertical = true
        tableView.backgroundColor = UIColor.clear
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return tableView
    }()

    lazy var footerViewContainer: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.isHidden = true
        stackView.backgroundColor = UIColor.clear
        return stackView
    }()
    
    public lazy var errorStateView: UIView = {
        // Not making this view's type as StateView because user can replace this with any UIView
        let stateView = UIView().withoutAutoresizingMaskConstraints()
        return stateView
    }()
    
    public lazy var emptyStateView: UIView = {
        // Not making this view's type as StateView because user can replace this with any UIView
        let stateView = StateView(title: emptyTitleText, subtitle: emptySubtitleText, image: style.emptyImage).withoutAutoresizingMaskConstraints()
        return stateView
    }()
    
    public lazy var loadingStateView: UIView = {
        // Not making this view's type as CometChatMessageShimmerView because user can replace this with any UIView
        let loadingShimmer = CometChatMessageShimmerView()
        loadingShimmer.transform = CGAffineTransform(scaleX: 1, y: -1)
        return loadingShimmer
    }()
    
    
    // MARK: - Disable Customisation
    public var showAvatar: Bool?
    public var hideHeaderView = false
    public var hideBubbleHeader = false
    public var hideFooterView = false
    public var hideDateSeparator = false
    public var disableReactions = false
    public var scrollToBottomOnNewMessages: Bool = false
    public var hideReceipt: Bool = false
    public var disableSoundForMessages: Bool = false
    public var hideEmptyStateView: Bool = true
    public var hideErrorStateView: Bool = false
    public var hideLoadingStateView: Bool = false
    public var hideNewMessageIndicator = false {
        didSet {
            messageIndicator?.isHidden = hideNewMessageIndicator
        }
    }
    
    //MARK: - Configuration
    public var reactionsConfiguration: ReactionsConfiguration?
    public var reactionListConfiguration: ReactionListConfiguration?
    public var quickReactionsConfiguration: QuickReactionsConfiguration?
    public var messageInformationConfiguration: MessageInformationConfiguration?
    
    //MARK: GLOBEL STYLES
    public static var style = MessageListStyle()
    public static var emojiKeyboardStyle: EmojiKeyboardStyle = CometChatEmojiKeyboard.style
    public static var dateSeparatorStyle = CometChatDate.style
    public static var newMessageIndicatorStyle = CometChatNewMessageIndicator.style
    public static var messageBubbleStyle = CometChatMessageBubble.style
    public static var actionBubbleStyle = CometChatMessageBubble.actionBubbleStyle
    
    //MARK: LOCAL STYLES
    public var style = CometChatMessageList.style
    public var emojiKeyboardStyle: EmojiKeyboardStyle = CometChatMessageList.emojiKeyboardStyle
    public lazy var dateSeparatorStyle = CometChatMessageList.dateSeparatorStyle
    public lazy var newMessageIndicatorStyle = CometChatMessageList.newMessageIndicatorStyle
    public lazy var messageBubbleStyle = CometChatMessageList.messageBubbleStyle {
        didSet {
            viewModel.messageBubbleStyle = messageBubbleStyle
            viewModel.setUpDefaultTemplate()
        }
    }
    public lazy var actionBubbleStyle = CometChatMessageBubble.actionBubbleStyle {
        didSet {
            viewModel.actionBubbleStyle = actionBubbleStyle
            viewModel.setUpDefaultTemplate()
        }
    }
    public lazy var callActionBubbleStyle = CometChatMessageBubble.callActionBubbleStyle {
        didSet {
            viewModel.callActionBubbleStyle = callActionBubbleStyle
            viewModel.setUpDefaultTemplate()
        }
    }
    
    
    //MARK: - Call Backs
    public internal(set) var onThreadRepliesClick: ((_ message: BaseMessage, _ template: CometChatMessageTemplate) -> ())?
    public internal(set) var datePattern: ((_ timestamp: Int?) -> String)?
    public internal(set) var dateSeparatorPattern: ((_ timestamp: Int?) -> String)?
    
    //MARK: Other Customisation
    public var messageAlignment: MessageListAlignment = .standard
    public var customSoundForMessages: URL?
    public var emptyTitleText = "NO_CONVERSATIONS_YET".localize() {
        didSet {
            (emptyStateView as? StateView)?.title = emptyTitleText
        }
    }
    public var emptySubtitleText = "START_A_NEW_CHAT_OR_INVITE_OTHERS_TO_JOIN_THE_CONVERSATION.".localize() {
        didSet {
            (emptyStateView as? StateView)?.subtitle = emptySubtitleText
        }
    }
    public var errorTitleText = "OOPS!".localize() {
        didSet {
            (errorStateView as? StateView)?.title = emptyTitleText
        }
    }
    public var errorSubtitleText = "LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize() {
        didSet {
            (errorStateView as? StateView)?.subtitle = emptySubtitleText
        }
    }


    //MARK: - INTERNAL HELPER VARIABLE
    var newMessageIndicatorScrollOffSet: CGFloat = 150
    var messagesRequestBuilder: MessagesRequest.MessageRequestBuilder? = nil
    var baseMessage: BaseMessage?
    weak var controller: UIViewController?
    var messageIndicator : CometChatNewMessageIndicator?
    var viewModel = MessageListViewModel()
    var lastContentOffset: CGFloat = 0
    lazy var onTapGesture: UITapGestureRecognizer = {
        let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        onTapGesture.cancelsTouchesInView = false
        return onTapGesture
    }()
    var contextMenuCell: CometChatMessageBubble?
    var contextMenuMessage: BaseMessage?
    
    //MARK: - Life Cycle Function
    public override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        buildUI()
        handleThemeModeChange()
        connect()
        setupTableView()
        setupViewModel()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
        connect()
        setupTableView()
        setupViewModel()
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
            if !viewModel.hasFetchedMessagesBefore {
                fetchData()
            }
        }
    }
    
    deinit {
        disconnect()
    }
    
    // ------ END: life cycle functions ---- //
    
    //MARK: Building and styling UI
    open func buildUI() {
        
        embed(container)
        
        // Add subviews to container
        container.addArrangedSubview(headerViewContainer)
        container.addArrangedSubview(tableView)
        container.addArrangedSubview(footerViewContainer)
    }
    
    open func setupStyle() {
        if let backgroundImage = style.backgroundImage {
            tableView.backgroundView = UIImageView(image: style.backgroundImage)
        }
        tableView.backgroundColor = style.backgroundColor
        tableView.borderWith(width: style.borderWidth)
        tableView.borderColor(color: style.borderColor)
        if let cornerRadius = style.cornerRadius { tableView.roundViewCorners(corner: cornerRadius) }
        
        if let emptyStateView = emptyStateView as? StateView {
            emptyStateView.titleLabel.textColor = style.emptyStateTitleColor
            emptyStateView.subtitleLabel.textColor = style.emptyStateSubtitleColor
            emptyStateView.titleLabel.font = style.emptyStateTitleFont
            emptyStateView.subtitleLabel.font = style.emptyStateSubtitleFont
        }
        
        if let errorStateView = errorStateView as? StateView {
            errorStateView.titleLabel.textColor = style.errorStateTitleColor
            errorStateView.subtitleLabel.textColor = style.errorStateSubtitleColor
            errorStateView.titleLabel.font = style.errorStateTitleFont
            errorStateView.subtitleLabel.font = style.errorStateSubtitleFont
        }
        
        if let loadingStateView = loadingStateView as? CometChatMessageShimmerView {
            loadingStateView.isGroupMode = viewModel.group == nil ? false : true
            loadingStateView.colorGradient1 = style.shimmerGradientColor1
            loadingStateView.colorGradient2 = style.shimmerGradientColor2
        }
        
    }
    
    private func setupTableView() {
        tableView.backgroundColor = CometChatTheme.backgroundColor02
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        registerCells()
        showNewMessageIndicator()
    }
    
    open func reload() {
        tableView.reloadData()
    }
    
    private func fetchData() {
        if viewModel.messages.isEmpty {
            showLoadingView()
        }
        viewModel.fetchPreviousMessages()
    }
    
    open func showNewMessageIndicator() {
        if !hideNewMessageIndicator {
            messageIndicator = CometChatNewMessageIndicator().withoutAutoresizingMaskConstraints()
            messageIndicator!.style = newMessageIndicatorStyle
            self.addSubview(messageIndicator!)
            NSLayoutConstraint.activate([
                messageIndicator!.trailingAnchor.pin(equalTo: tableView.trailingAnchor, constant: -8),
                messageIndicator!.bottomAnchor.pin(equalTo: self.tableView.bottomAnchor, constant: -8)
            ])
            
            UIView.transition(with: messageIndicator!, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in
                guard let this = self else { return }
                this.messageIndicator?.reset()
                this.messageIndicator?.isHidden = true
            })
            messageIndicator!.onClick = { [weak self] in
                guard let this = self else { return }
                this.messageIndicator?.reset()
                this.messageIndicator?.isHidden = true
                this.scrollToBottom()
            }
            
        }
    }
    
    //MARK: - State Views
    open func showErrorView() {
        if hideErrorStateView { return }
        addSubview(errorStateView)
        errorStateView.pin(anchors: [.centerX, .centerY], to: self)
    }
    
    open func removeErrorView() {
        if hideErrorStateView { return }
        errorStateView.removeFromSuperview()
    }
    
    open func showEmptyView() {
        if hideEmptyStateView { return }
        addSubview(emptyStateView)
        emptyStateView.pin(anchors: [.centerX, .centerY], to: self)
    }
    
    open func removeEmptyView() {
        if hideEmptyStateView { return }
        emptyStateView.removeFromSuperview()
    }
    
    open func showLoadingView() {
        if hideLoadingStateView { return }
        if let loadingStateView = loadingStateView as? CometChatMessageShimmerView {
            loadingStateView.startShimmer()
        }
        addSubview(loadingStateView)
        embed(loadingStateView)
    }
    
    open func removeLoadingView() {
        if hideLoadingStateView { return }
        if let loadingStateView = loadingStateView as? CometChatMessageShimmerView {
            loadingStateView.stopShimmer()
        }
        loadingStateView.removeFromSuperview()
    }
    
    open func showTopSpinner() {
        tableView.tableFooterView = ActivityIndicator.show()
        tableView.tableFooterView?.isHidden = false
    }
    
    open func hideTopSpinner() {
        ActivityIndicator.hide()
        tableView.tableFooterView?.isHidden = true
        if tableView.contentSize.height < tableView.visibleSize.height || (tableView.contentOffset.y < 5 && !tableView.visibleCells.isEmpty) {
            tableView.beginUpdates()
            ActivityIndicator.activityIndicator.frame = .zero
            tableView.endUpdates()
        }
    }
    
    //MARK: - View Model Set up
    open func setupViewModel() {
        
        viewModel.reload = { [weak self]  in
            DispatchQueue.main.async {
                guard let this = self else { return }
                this.removeLoadingView()
                this.reload()
                                
                if this.viewModel.messages.isEmpty && !this.hideEmptyStateView {
                    this.showEmptyView()
                } else {
                    this.removeEmptyView()
                    this.removeErrorView()
                }
                
                this.hideTopSpinner()
            }
        }
        
        viewModel.appendAtIndex = { [weak self] section , row, message, isNewSectionAdded in
            
            guard let this = self else { return }
            
            var shouldScrollToBottom = false
            if this.scrollToBottomOnNewMessages {
                shouldScrollToBottom = true
            } else {
                if this.tableView.contentOffset.y > 300 {
                    this.messageIndicator?.incrementCount()
                    this.messageIndicator?.isHidden = false
                } else {
                    shouldScrollToBottom = true
                }
            }
            
            //setting animation as to top because our tableView in inverse
            if isNewSectionAdded {
                this.tableView.performBatchUpdates({
                    this.tableView.insertSections([section], with: .top)
                    this.tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .top)
                }, completion: nil)

            } else {
                this.tableView.insertRows(at: [IndexPath(row: row, section: section)], with: .top)
            }
            
            //removing error/empty view if presented
            this.removeEmptyView()
            this.removeErrorView()
            
            if shouldScrollToBottom {
                this.scrollToBottom()
            }
        }
        
        
        viewModel.updateAtIndex = { [weak self] section , row, message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                UIView.performWithoutAnimation {
                    this.tableView.beginUpdates()
                    this.tableView.reloadRows(at: [IndexPath(row: row , section: section)], with: .none)
                    this.tableView.endUpdates()
                }
            }
        }
        
        viewModel.deleteAtIndex = { [weak self] section , row, message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.tableView.beginUpdates()
                this.tableView.deleteRows(at: [IndexPath(row: row - 1, section: section)], with: .automatic)
                this.tableView.endUpdates()
            }
        }
        
        viewModel.newMessageReceived = { [weak self] message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                if !this.disableSoundForMessages {
                    CometChatSoundManager().play(sound: .incomingMessage, customSound: this.customSoundForMessages)
                }
            }
        }
        
        viewModel.failure = { [weak self] error in
            DispatchQueue.main.async {
                guard let this = self else { return }
                this.removeLoadingView()
                this.showErrorView()
            }
        }
        
        viewModel.hideFooterView = { [weak self] hideFooterView  in
            guard let this = self else { return }
            this.clear(footerView: hideFooterView)
        }
        
        viewModel.hideHeaderView = { [weak self] hideHeaderView  in
            guard let this = self else { return }
            this.clear(headerView: hideHeaderView)
        }
        
        viewModel.setFooterView = { [weak self] footerView  in
            guard let this = self else { return }
            if this.hideFooterView == false {
                this.set(footerView: footerView)
            }
        }
        
        viewModel.setHeaderView = { [weak self] headerView  in
            guard let this = self else { return }
            if this.hideReceipt == false {
                this.set(headerView: headerView)
            }
        }
        
    }
    
    open func handleThemeModeChange() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                self.setupStyle()
                self.tableView.reloadData()
            })
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Check if the user interface style has changed
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.setupStyle()
            self.tableView.reloadData()
        }
    }
    
    open func buildMessageFooterView(
        on cell: CometChatMessageBubble,
        for message: BaseMessage,
        messageTypeStyle: BaseMessageBubbleStyle?,
        bubbleStyle: MessageBubbleStyle
    ) {
        MessageUtils.buildStatusInfo(
            from: cell,
            messageTypeStyle: messageTypeStyle,
            bubbleStyle: bubbleStyle,
            message: message,
            hideReceipt: hideReceipt,
            messageAlignment: messageAlignment
        )
    }
    
    open func addThreadedRepliesView(forMessage: BaseMessage, toCell: CometChatMessageBubble, isLoggedInUser: Bool, specificMessageTypeStyle: BaseMessageBubbleStyle?, bubbleStyle: MessageBubbleStyle) {
        if forMessage.replyCount != 0 && forMessage.deletedBy.isEmpty {
            
            let label = UILabel().withoutAutoresizingMaskConstraints()
            label.font = specificMessageTypeStyle?.threadedIndicatorTextFont ?? bubbleStyle.threadedIndicatorTextFont
            label.textColor = specificMessageTypeStyle?.threadedIndicatorTextColor ?? bubbleStyle.threadedIndicatorTextColor
            label.text = forMessage.replyCount > 1 ? "\(forMessage.replyCount)" + " " + "REPLIES_R".localize() : "ONE_REPLY".localize()
            
            let icon = UIImageView().withoutAutoresizingMaskConstraints()
            icon.pin(anchors: [.height, .width], to: 16)
            icon.contentMode = .scaleAspectFit
            icon.image = style.threadedMessageImage
            icon.tintColor = specificMessageTypeStyle?.threadedIndicatorImageTint ?? bubbleStyle.threadedIndicatorImageTint
            
            let containerView = UIView().withoutAutoresizingMaskConstraints()
            containerView.addSubview(label)
            containerView.addSubview(icon)
            
            NSLayoutConstraint.activate([
                icon.trailingAnchor.pin(equalTo: label.leadingAnchor, constant: -CometChatSpacing.Spacing.s1),
                icon.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: CometChatSpacing.Spacing.s1),
                icon.topAnchor.pin(equalTo: containerView.topAnchor, constant: CometChatSpacing.Spacing.s1),
                icon.bottomAnchor.pin(equalTo: containerView.bottomAnchor),
                label.centerYAnchor.pin(equalTo: icon.centerYAnchor, constant: -1),
                label.trailingAnchor.pin(equalTo: containerView.trailingAnchor, constant: -CometChatSpacing.Spacing.s1)
            ])
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didViewRepliesTap(sender:)))
            tapGesture.numberOfTapsRequired = 1
            containerView.addGestureRecognizer(tapGesture)
            toCell.set(viewReply: containerView)
        }
    }

    
    fileprivate func registerCells() {
        tableView.register(CometChatMessageBubble.self, forCellReuseIdentifier: CometChatMessageBubble.identifier)
    }
    
}

//MARK: - TABLE VIEW FUNCTIONS
extension CometChatMessageList: UITableViewDelegate, UITableViewDataSource {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.messages.count
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if hideDateSeparator == true { return nil }
        if let date = viewModel.messages[safe: section]?.messages.last?.sentAt {
            let dateHeader = CometChatDate().withoutAutoresizingMaskConstraints()
            if let time = dateSeparatorPattern?(date) {
                dateHeader.text = time
            }
            else {
                if let datePattern = datePattern?(date){
                    let dateNow = Date(timeIntervalSince1970: Double(date))
                    dateHeader.text = dateNow.reduceTo(customFormate: datePattern)
                }else{
                    dateHeader.set(pattern: .dayDate)
                    dateHeader.set(timestamp: date)
                }
            }
            dateHeader.padding = UIEdgeInsets(top: CometChatSpacing.Padding.p1, left: CometChatSpacing.Padding.p2, bottom: CometChatSpacing.Padding.p1, right: CometChatSpacing.Padding.p2)
            dateHeader.style = dateSeparatorStyle
            
            let view = UIView()
            view.addSubview(dateHeader)
            view.backgroundColor = .clear
            view.transform = CGAffineTransform(scaleX: 1, y: -1)
            dateHeader.pin(anchors: [.centerX, .centerY], to: view)
            
            return view
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages[safe: section]?.messages.count ?? 0
    }
        
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = viewModel.messages[safe: indexPath.section]?.messages[safe: indexPath.row] else { return UITableViewCell() }
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
        var bubbleStyle = isLoggedInUser ? messageBubbleStyle.outgoing : messageBubbleStyle.incoming
        let messageTypeStyle = MessageUtils.getSpecificMessageTypeStyle(message: message, from: messageBubbleStyle)
        
        if let template = viewModel.getTemplate(for: message) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CometChatMessageBubble.identifier , for: indexPath) as? CometChatMessageBubble {
                
                cell.transform = CGAffineTransform(scaleX: 1, y: -1) //doing this because our tableView is also transformed
                cell.set(message: message)
                cell.set(style: bubbleStyle, specificMessageTypeStyle: messageTypeStyle)
                
                //Overriding whole bubble
                if let bubbleView = template.bubbleView?(message, cell.alignment, controller) {
                    cell.set(bubbleView: bubbleView)
                    return cell
                }
                
                //For action messages
                if message.messageCategory == .action || message.messageCategory == .call {
                    cell.set(bubbleAlignment: .center)
                    if let contentView = template.contentView?(message, cell.alignment, controller) {
                        cell.set(contentView: contentView)
                        cell.set(backgroundColor: .clear)
                        if message.messageCategory == .action{
                            cell.set(actionStyle: actionBubbleStyle)
                        }else{
                            cell.set(callActionStyle: callActionBubbleStyle)
                        }
                    }
                    return cell
                }
                
                switch messageAlignment {
                case .standard:
                    if isLoggedInUser {
                        cell.set(bubbleAlignment: .right)
                    } else {
                        cell.set(bubbleAlignment: .left)
                    }
                case .leftAligned:
                    cell.set(bubbleAlignment: .left)
                }
                
                
                if let headerView = template.headerView?(message, cell.alignment, controller) {
                    cell.set(headerView: headerView)
                } else {
                    if !hideBubbleHeader {
                        let nameLabel = UILabel()
                        nameLabel.numberOfLines = 1
                        nameLabel.text = isLoggedInUser ? "YOU".localize() : message.sender?.name ?? ""
                        nameLabel.font = messageTypeStyle?.headerTextFont ?? bubbleStyle.headerTextFont
                        nameLabel.textColor = messageTypeStyle?.headerTextColor ?? bubbleStyle.headerTextColor
                        
                        cell.set(headerView: nameLabel)
                    }
                }
                
                if let contentView = template.contentView?(message, cell.alignment, controller) {
                    cell.set(contentView: contentView)
                }
                
                if let bottomView = template.bottomView?(message, cell.alignment, controller) {
                    cell.set(bottomView: bottomView)
                }
                
                //adding date and read receipt
                if let statusInfoView = template.statusInfoView?(message, cell.alignment, controller) {
                    cell.set(statusInfoView: statusInfoView)
                } else {
                    buildMessageFooterView(on: cell, for: message, messageTypeStyle: messageTypeStyle, bubbleStyle: bubbleStyle)
                }
                
                if let footerView = template.footerView?(message, cell.alignment, controller) {
                    cell.set(footerView: footerView)
                } else {
                    if message.deletedAt == 0 {
                        buildReactionsView(
                            forMessage: message,
                            cell: cell,
                            alignment: (messageAlignment == .leftAligned ? .left : (isLoggedInUser ? .right : .left)),
                            reactionStlye : messageTypeStyle?.reactionsStyle ?? bubbleStyle.reactionsStyle
                        )
                    }
                }
                
                if message.deletedAt == 0 {
                    addThreadedRepliesView(forMessage: message, toCell: cell, isLoggedInUser: isLoggedInUser, specificMessageTypeStyle: messageTypeStyle, bubbleStyle: bubbleStyle)
                }
                
                //setting up avatar view
                if let user = message.sender {
                    cell.set(avatarURL: user.avatar, avatarName: user.name)
                    
                    //setting header View
                    switch message.receiverType {
                    case .user:
                        cell.hide(headerView: true)
                        if cell.alignment == .left {
                            if let showAvatar {
                                cell.hide(avatar: !showAvatar)
                            } else {
                                cell.hide(avatar: true)
                            }
                        }
                    case .group:
                        if cell.alignment == .left {
                            if let showAvatar {
                                cell.hide(avatar: !showAvatar)
                            } else {
                                cell.hide(avatar: false)
                            }
                            cell.hide(headerView: false)
                        } else {
                            cell.hide(headerView: true)
                        }
                    @unknown default:
                        break
                    }
                }
                
                //Setting up Context Menu
                setupContextMenu(for: cell, message: message)
                
                return cell
            }
        } else {
            
            //building not supported bubble
            if let cell = tableView.dequeueReusableCell(withIdentifier: CometChatMessageBubble.identifier , for: indexPath) as? CometChatMessageBubble {
                switch messageAlignment {
                case .standard:
                    if isLoggedInUser {
                        cell.set(bubbleAlignment: .right)
                        cell.set(style: bubbleStyle, specificMessageTypeStyle: messageBubbleStyle.outgoing.deleteBubbleStyle)
                    } else {
                        cell.set(bubbleAlignment: .left)
                        cell.set(style: bubbleStyle, specificMessageTypeStyle: messageBubbleStyle.incoming.deleteBubbleStyle)
                    }
                case .leftAligned:
                    cell.set(bubbleAlignment: .left)
                }
                
                let noSupportedBubble = CometChatDeleteBubble()
                noSupportedBubble.messageText = "This message type is not supported"
                cell.set(contentView: noSupportedBubble)
                return cell
            }
        }
        
        return UITableViewCell()
    }
    
    public  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = tableView.contentOffset.y
        
        if (scrollView.isDragging || scrollView.isDecelerating) && yOffset > lastContentOffset && yOffset >= 400 {
            self.messageIndicator?.isHidden = false
        }
        
        if viewModel.isUIUpdating == false && (scrollView.isDragging || scrollView.isDecelerating) && viewModel.isAllMessagesFetchedInPrevious == false {
            if yOffset > lastContentOffset && shouldLoadMoreData(scrollView: scrollView) {
                showTopSpinner()
                viewModel.fetchPreviousMessages()
            }
        }
        
        lastContentOffset = yOffset
        
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let messageIndicator = self.messageIndicator else { return }
        if indexPath.section == 0 && indexPath.row == 0  {
            self.messageIndicator?.reset()
            self.messageIndicator?.isHidden = true
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return hideDateSeparator == false ? 40 : 0
    }
    
    public  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {}
    
    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) { }
    
    public func shouldLoadMoreData(scrollView: UIScrollView) -> Bool {
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.frame.size.height
        let offsetY = scrollView.contentOffset.y
        
        let contentToVisibleRatio = contentHeight / visibleHeight
        
        let thresholdFactor: CGFloat = (0.85 - ((contentToVisibleRatio - 1.5) / (8.0 - 1.5)) * (0.85 - 0.20))
        
        // Calculate the threshold scroll position to trigger the API
        let threshold = contentHeight * thresholdFactor
        
        // Trigger the API call if the user has scrolled beyond the threshold
        return offsetY > contentHeight - visibleHeight - threshold
    }

    
}

//Exposing Scroll Events
extension CometChatMessageList {
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {  }
    
    // called on start of dragging (may require some time and or distance to move)
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) { }
    
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
    
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { }
    
    // called when scroll view grinds to a halt
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}

    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}

    // return a view that will be scaled. if delegate returns nil, nothing happens
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? { return nil }

    // called before the scroll view begins zooming its content
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {}

    // scale between minimum and maximum. called after any 'bounce' animations
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {}

    // return a yes if you want to scroll to the top. if not defined, assumes YES
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { return true }

    // called when scrolling animation finished. may be called immediately if already at top
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {}
    
    /* Also see -[UIScrollView adjustedContentInsetDidChange]
     */
    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {}
}


extension CometChatMessageList {
    
    internal func configureMessageInformation(configuration: MessageInformationConfiguration, messageInformation: CometChatMessageInformation) {
        //TODO: FIX THIS
    }
    
    @objc func didViewRepliesTap(sender: UITapGestureRecognizer) {
        guard let indexPath = self.tableView.indexPathForRow(at: sender.location(in: self.tableView)), let message = viewModel.messages[safe: indexPath.section]?.messages[safe: indexPath.row], let template = viewModel.getTemplate(for: message) else {
            print("Error: indexPath)")
            return
        }
        self.onThreadRepliesClick?(message, template)
    }
}

//MARK: Message Options
extension CometChatMessageList: CometChatMessageOptionDelegate {
    
    func onItemClick(messageOption: CometChatMessageOption, forMessage: BaseMessage?, indexPath: IndexPath?) {
        if let message = forMessage {
            switch messageOption.id {
            case MessageOptionConstants.editMessage :
                if messageOption.onItemClick == nil {
                    if let forMessage = forMessage {
                        CometChatMessageEvents.ccMessageEdited(message: forMessage, status: .inProgress)
                    }
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.deleteMessage :
                if messageOption.onItemClick == nil {
                    
                    // Presenting Delete message action
                    let actionSheetController: UIAlertController = UIAlertController(title: nil, message: "Are you sure you want to delete this message? This action cannot be undone.", preferredStyle: .actionSheet)
                    
                    // create an action
                    let firstAction: UIAlertAction = UIAlertAction(title: ConversationConstants.delete, style: .destructive) { [weak self] action -> Void in
                        DispatchQueue.main.async {
                            guard let strongSelf = self else { return }
                            strongSelf.delete(message: message)
                        }
                    }
                    
                    let cancelAction: UIAlertAction = UIAlertAction(title: ConversationConstants.cancel, style: .cancel) { action -> Void in }
                    actionSheetController.addAction(firstAction)
                    actionSheetController.addAction(cancelAction)
                    controller?.present(actionSheetController, animated: true)
                    
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.shareMessage :
                if messageOption.onItemClick == nil {
                    didMessageSharePressed(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.copyMessage :
                if messageOption.onItemClick == nil {
                    didCopyPressed(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.messagePrivately :
                if messageOption.onItemClick == nil {
                    if let user = message.sender {
                        DispatchQueue.main.async {
                            CometChatUIEvents.openChat(user: user, group: nil)
                        }
                    }
                    
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.forwardMessage: break
            case MessageOptionConstants.replyInThread : 
                if let baseMessage = forMessage, let template = viewModel.getTemplate(for: message) {
                    self.onThreadRepliesClick?(baseMessage, template)
                }
            case MessageOptionConstants.messageInformation :
                if messageOption.onItemClick == nil {
                    didMessageInformationClicked(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            default:
                if let forMessage = forMessage {
                    messageOption.onItemClick?(forMessage)
                }
            }
        }
    }
    
    private func didCopyPressed(message: BaseMessage?) {
        if let message = message as? TextMessage {
            let textFormatter = viewModel.textFormatters
            let formattedText = MessageUtils.processTextFormatter(message: message, textFormatter: textFormatter, formattingType: .MESSAGE_BUBBLE)
            UIPasteboard.general.string = formattedText.string
        }
    }
    
    private func didMessageSharePressed(message: BaseMessage?) {
        if let message = message {
            if message.messageType == .text {
                
                if let message = (message as? TextMessage) {
                    let textFormatter = viewModel.textFormatters
                    let formattedText = MessageUtils.processTextFormatter(message: message, textFormatter: textFormatter, formattingType: .MESSAGE_BUBBLE)
                    copyMedia(formattedText.string)
                }
                
            } else if message.messageType == .audio ||  message.messageType == .file ||  message.messageType == .image || message.messageType == .video {
                
                if let fileUrlString = (message as? MediaMessage)?.attachment?.fileUrl, let fileUrl = URL(string: fileUrlString) {
                    downloadMediaMessage(url: fileUrl, completion: { [weak self] fileLocation in
                        guard let this = self else { return }
                        if let fileLocation = fileLocation {
                            this.copyMedia(fileLocation)
                        }
                    })
                }
            }
        }
    }
    
    func copyMedia(_ item: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            let activityViewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = this
            activityViewController.excludedActivityTypes = [.airDrop]
            this.controller?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func downloadMediaMessage(url: URL, completion: @escaping (_ fileLocation: URL?) -> Void){
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(destinationUrl)
        } else {
            URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(destinationUrl)
                } catch _ as NSError {
                    completion(nil)
                }
            }).resume()
        }
    }
}

//Keyboard Management
extension CometChatMessageList {
    func addKeyboardDismissGesture() {
        self.addGestureRecognizer(onTapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
        controller?.view.endEditing(true)
    }
    
    func removeKeyboardDismissGesture() {
        self.removeGestureRecognizer(onTapGesture)
    }
}
