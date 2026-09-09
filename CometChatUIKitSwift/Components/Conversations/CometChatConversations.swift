//
//  CometChatConversations.swift
//
//
//  Created by Abdullah Ansari on 24/11/22.
//

import Foundation
import CometChatSDK
import UIKit

open class CometChatConversations: CometChatListBase {
    
    // MARK: - Properties
    public static var style = ConversationsStyle()
    public static var avatarStyle: AvatarStyle = CometChatAvatar.style
    public static var statusIndicatorStyle: StatusIndicatorStyle = CometChatStatusIndicator.style
    public static var receiptStyle: ReceiptStyle = {
        var defaultReceiptStyle = CometChatReceipt.style
        defaultReceiptStyle.deliveredImageTintColor = CometChatTheme.iconColorSecondary
        defaultReceiptStyle.sentImageTintColor = CometChatTheme.iconColorSecondary
        defaultReceiptStyle.waitImageTintColor = CometChatTheme.iconColorSecondary
        return defaultReceiptStyle
    }()
    public static var badgeStyle: BadgeStyle = CometChatBadge.style
    public static var dateStyle: DateStyle = CometChatDate.style
    public static var typingIndicatorStyle = CometChatTypingIndicator.style
    
    
    public lazy var style = CometChatConversations.style
    public lazy var avatarStyle: AvatarStyle = CometChatConversations.avatarStyle
    public lazy var statusIndicatorStyle: StatusIndicatorStyle = CometChatConversations.statusIndicatorStyle
    public lazy var receiptStyle: ReceiptStyle = CometChatConversations.receiptStyle
    public lazy var badgeStyle: BadgeStyle = CometChatConversations.badgeStyle
    public lazy var dateStyle: DateStyle = CometChatConversations.dateStyle
    public lazy var typingIndicatorStyle = CometChatConversations.typingIndicatorStyle
    
    //Icons
    public var privateGroupIcon = UIImage(systemName: "shield.fill")?.withRenderingMode(.alwaysTemplate)
    public var protectedGroupIcon = UIImage(systemName: "lock.fill")?.withRenderingMode(.alwaysTemplate)
    
    // Disable Properties
    public var disableTyping: Bool = false
    public var disableSoundForMessages: Bool = false
    public var customSoundForMessages: URL?
    
    //Date Time Formatter
    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    public lazy var dateTimeFormatter: CometChatDateTimeFormatter = CometChatConversations.dateTimeFormatter
   
    //Internal Helper variables
    var listItemView: ((_ conversation: Conversation) -> UIView)?
    var leadingView: ((_ conversation: Conversation) -> UIView)?
    var titleView: ((_ conversation: Conversation) -> UIView)?
    var subtitleView: ((_ conversation: Conversation) -> UIView)?
    var onItemLongClick: ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)?
    var onError: ((_ error: CometChatException) -> Void)?
    var onEmpty: (() -> Void)?
    var onLoad: ((_ conversation: [Conversation]) -> Void)?
    var datePattern: ((_ conversation: Conversation) -> String)?
    var onItemClick: ((_ conversation: Conversation, _ indexPath: IndexPath) -> Void)?
    var onSelection: ((_ conversation: [Conversation]) -> Void)?
    var tailView: ((_ conversation: Conversation) -> UIView)?
    var options: ((_ conversation: Conversation) -> [CometChatConversationOption])?
    var addOptions: ((_ conversation: Conversation) -> [CometChatConversationOption])?
    var textFormatters: [CometChatTextFormatter] = {
        return ChatConfigurator.getDataSource().getTextFormatters()
    }()
    
    var viewModel: ConversationsViewModelProtocol = ConversationsViewModel()
    
    public var hideReceipts: Bool = false
    public var hideDeleteConversationOption: Bool = false
    public var hideUserStatus: Bool = false
    public var hideGroupType: Bool = false

    /// Ships dark: the option is absent until an integrator opts in AND the app has the
    /// feature enabled server-side.
    public var enablePinConversation: Bool = false
    public var hidePinConversationOption: Bool = false
    
    public var onSearchClick : (() -> ())?

    
    deinit {
        disconnect()
    }
    
    // MARK: - Init
    public init() {
        super.init(nibName: nil, bundle: nil)
        defaultSetup()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        self.searchController.isActive = false
        self.searchController.searchBar.resignFirstResponder()
        self.onSearchClick?()
    }
    
    // MARK:- ViewController Life Cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView(style: .plain, withRefreshControl: true)
        registerCells()
        connect()
        setupViewModel()
        viewModel.isRefresh = true
        hideSeparator = true
        if selectionMode == .single{
            tableView.allowsMultipleSelection = false
        }else if selectionMode == .multiple{
            tableView.allowsMultipleSelection = true
        }
        showLoadingView()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        listBaseStyle = style //setting list base style
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        self.searchController.isActive = false
        self.searchController.searchBar.resignFirstResponder()
    }
    
    open override func setupStyle() {
        super.setupStyle()
    }
    
    // setting style
    open func defaultSetup() {
        
        //
        title = "CHATS".localize()
        prefersLargeTitles = true
                
        //shimmer effect
        loadingView = ConversationSimmerView()
        
        // for error
        errorStateTitleText = "OOPS!".localize()
        errorStateSubTitleText = "LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize()
        errorStateImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        
        // for empty
        emptyStateImage = UIImage(named: "empty-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        emptyStateTitleText = "NO_CONVERSATIONS_YET".localize()
        emptyStateSubTitleText = "START_A_NEW_CHAT_OR_INVITE_OTHERS_TO_JOIN_THE_CONVERSATION.".localize()
        
        // for date
        dateStyle.textColor = CometChatTheme.textColorSecondary
        dateStyle.textFont = CometChatTypography.Caption1.regular
        dateStyle.borderWidth = 0
        dateStyle.backgroundColor = .clear
        
        //status Indicator style
        statusIndicatorStyle.borderColor = style.backgroundColor
        statusIndicatorStyle.borderWidth = 2
    }
    
    public func connect() {
        CometChat.addConnectionListener("conversations-sdk-listener-\(viewModel.listenerRandomID)", self)
        viewModel.connect()
    }
    
    public func disconnect() {
        CometChat.removeConnectionListener("conversations-sdk-listener-\(viewModel.listenerRandomID)")
        viewModel.disconnect()
    }
    
    // MARK:- reloadData
    private func setupViewModel() {
        // reload tableview
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            DispatchQueue.main.async {
                
                if this.viewModel.size() == 0 {
                    if let onEmpty = this.onEmpty{
                        onEmpty()
                    }else{
                        this.showEmptyView()
                    }
                } else if this.isEmptyStateVisible {
                    this.removeEmptyView()
                } else if this.isErrorStateVisible {
                    this.removeErrorView()
                }
                if let onLoad = this.onLoad?(this.viewModel.conversations){
                    onLoad
                }
                this.hideFooterIndicator()
                this.reload()
                this.removeLoadingView()
                this.refreshControl.endRefreshing()
            }
        }
        
        // catch the error
        viewModel.failure = { [weak self] error in
            guard let this = self else { return }
            DispatchQueue.main.async {

                this.onError?(error)
                this.removeLoadingView()
                this.refreshControl.endRefreshing()
                
                if this.viewModel.conversations.isEmpty {
                    this.showErrorView()
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
        viewModel.reloadAtIndex = { [weak self] indexPath in
            guard let this = self else { return }
            DispatchQueue.main.async {
                guard let cell = this.tableView.cellForRow(at: indexPath) as? CometChatListItem else { return }
                let conversation = this.viewModel.conversations[indexPath.row]
                
                //updating subtitle View
                if let subtitle = this.subtitleView?(conversation){
                    cell.set(subtitle: subtitle)
                } else {
                    cell.set(subtitle: ConversationsUtils.configureSubtitleView(
                        conversation: conversation,
                        isTypingEnabled: false,
                        receiptStyle: this.receiptStyle,
                        disableReceipt: this.hideReceipts,
                        textFormatter: this.textFormatters,
                        typingIndicator: nil,
                        typingIndicatorStyle: this.typingIndicatorStyle,
                        conversationStyle: this.style
                    ))
                }
                
                //updating tail View
                if let tailView = this.tailView?(conversation){
                    cell.set(tail: tailView)
                }else{
                    cell.set(tail: ConversationsUtils().configureTailView(
                        conversation: conversation,
                        badgeStyle: this.badgeStyle,
                        dateStyle: this.dateStyle,
                        datePattern: this.datePattern?(conversation), dateTimeFormatter: this.dateTimeFormatter
                    ))
                }
            }
        }
        
        viewModel.deleteAtIndex = { [weak self] indexPath in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.tableView.reloadData()
            }
        }
        
        viewModel.moveRow = { [weak self] fromIndexPath, toIndexPath in
            guard let this = self else { return }
            if fromIndexPath == toIndexPath { return }
            DispatchQueue.main.async {
                // `moveRow` relocates the existing cell without calling `cellForRowAt`, so the
                // pin indicator — built in the tail view — would keep its pre-move state.
                // Rebuilding the tail at the destination refreshes it without a full reload.
                this.tableView.moveRow(at: fromIndexPath, to: toIndexPath)
                this.viewModel.reloadAtIndex?(toIndexPath)
            }
        }
        
        viewModel.insertAtIndex = { [weak self] indexPath in
            guard let this = self else { return }
            DispatchQueue.main.async {
                
                if this.isEmptyStateVisible {
                    this.removeEmptyView()
                } else if this.isErrorStateVisible {
                    this.removeErrorView()
                }
                
                this.tableView.beginUpdates()
                this.tableView.insertRows(at: [indexPath], with: .automatic)
                this.tableView.endUpdates()
            }
        }

        viewModel.updateStatus = { [weak self] (row, status) in
            guard let strongSelf = self else { return }
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = strongSelf.tableView.cellForRow(at: indexPath) as? CometChatListItem {
                switch status {
                case .online:
                    cell.hide(statusIndicator: false)
                case .offline: cell.hide(statusIndicator: true)
                case .available: cell.hide(statusIndicator: true)
                }
            }
        }
        
        // update typing indicator when user typing.
        viewModel.updateTypingIndicator = { [weak self] (row, typingIndicator, isTyping) in
            guard let this = self else { return }
            if this.disableTyping { return }
            DispatchQueue.main.async {
                guard let cell = this.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? CometChatListItem else { return }
                let conversation = this.viewModel.conversations[row]
                if !isTyping, let subtitle = this.subtitleView?(conversation){
                    cell.set(subtitle: subtitle)
                } else {
                    cell.set(subtitle: ConversationsUtils.configureSubtitleView(
                        conversation: conversation,
                        isTypingEnabled: isTyping,
                        receiptStyle: this.receiptStyle,
                        disableReceipt: this.hideReceipts,
                        textFormatter: this.textFormatters,
                        typingIndicator: typingIndicator,
                        typingIndicatorStyle: this.typingIndicatorStyle,
                        conversationStyle: this.style
                    ))
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
        
    }
    
    override func onRefreshControlTriggered() {
        viewModel.isRefresh = true
    }
    
    // register cell
    fileprivate func registerCells() {
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
    }
    
}

extension CometChatConversations {
    
    // MARK: - TableView delegate and datasource method that inherited from the CometChatListBase.
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem , let conversation = viewModel.conversations[safe: indexPath.row] {
            
            if let listItemView = listItemView?(conversation) {
                let container = UIStackView()
                container.axis = .vertical
                container.addArrangedSubview(listItemView)
                listItem.set(customView: container)
                
            } else {
                
                listItem.style = style
                listItem.avatar.style = avatarStyle
                listItem.statusIndicator.style = statusIndicatorStyle
                     
                //Custom avatar height and width
                listItem.avatarHeightConstraint.constant = 48
                listItem.avatarWidthConstraint.constant = 48
                
                //Building leading View
                if let leading = leadingView?(conversation){
                    listItem.set(leadingView: leading)
                }
                
                //Building tail View
                if let tailView = tailView?(conversation){
                    listItem.set(tail: tailView)
                }else{
                    if let user = conversation.conversationWith as? User, user.isAgentic{
                        
                    }else {
                        listItem.set(tail: ConversationsUtils().configureTailView(
                            conversation: conversation,
                            badgeStyle: badgeStyle,
                            dateStyle: dateStyle,
                            datePattern: datePattern?(conversation), dateTimeFormatter: dateTimeFormatter
                        ))
                    }
                }
                
                //Building subtitle View
                if let subtitle = subtitleView?(conversation){
                    listItem.set(subtitle: subtitle)
                } else {
                    if let user = conversation.conversationWith as? User, user.isAgentic{
                        
                    }else{
                        listItem.set(subtitle: ConversationsUtils.configureSubtitleView(
                            conversation: conversation,
                            isTypingEnabled: false,
                            receiptStyle: receiptStyle,
                            disableReceipt: hideReceipts,
                            textFormatter: textFormatters,
                            typingIndicatorStyle: typingIndicatorStyle,
                            conversationStyle: style
                        ))
                    }
                }
                
                switch conversation.conversationType {
                case .user:
                    guard let user = conversation.conversationWith as? User else { return UITableViewCell()}
                    if let titleView = titleView?(conversation){
                        listItem.set(titleView: titleView)
                    }else{
                        if let name = user.name {
                            listItem.set(title: name)
                        }
                    }
                    
                    listItem.set(avatarURL: user.avatar ?? "")
                    if !hideUserStatus && user.status == .online {
                        listItem.hide(statusIndicator: false)
                        listItem.statusIndicator.style.backgroundColor = statusIndicatorStyle.backgroundColor
                        listItem.statusIndicator.layoutSubviews()
                    }else{
                        listItem.hide(statusIndicator: true)
                    }
                case .group:
                    guard let group = conversation.conversationWith as? Group else { return UITableViewCell()}
                    if let titleView = titleView?(conversation){
                        listItem.set(titleView: titleView)
                    }else{
                        if let name = group.name {
                            listItem.set(title: name)
                        }
                    }
                    
                    listItem.set(avatarURL: group.icon ?? "")
                    switch group.groupType {
                    case .public:
                        listItem.hide(statusIndicator: true)
                    case .private:
                        listItem.hide(statusIndicator: hideGroupType)
                        listItem.statusIndicator.style.backgroundColor = style.privateGroupImageBackgroundColor
                        listItem.set(statusIndicatorIcon: privateGroupIcon)
                        listItem.set(statusIndicatorIconTint: style.privateGroupImageTintColor)
                        listItem.statusIndicator.layoutSubviews() //this will update background colour
                    case .password:
                        listItem.hide(statusIndicator: hideGroupType)
                        listItem.set(statusIndicatorIcon: protectedGroupIcon)
                        listItem.statusIndicator.style.backgroundColor = style.passwordGroupImageBackgroundColor
                        listItem.set(statusIndicatorIconTint: style.privateGroupImageTintColor)
                        listItem.statusIndicator.layoutSubviews() //this will update background colour
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
            
            manageSelectionState(for: conversation, in: listItem, at: indexPath)
            
            return listItem
        }
        return UITableViewCell()
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.conversations.count
    }
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (viewModel.conversations.count - 1) && !viewModel.isFetchedAll && !viewModel.isFetching {
            showFooterIndicator()
            viewModel.isRefresh = false
            viewModel.fetchConversations()
        }
    }
    
    public func manageSelectionState(for conversation: Conversation, in listItem: CometChatListItem, at indexPath: IndexPath) {
        // Check if the user is selected and update the UI accordingly
        listItem.isSelected = viewModel.selectedConversations.contains(where: { $0.conversationId == conversation.conversationId })
        if listItem.isSelected {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = viewModel.conversations[indexPath.row]
        
        if selectionMode == .none {
            onItemClick?(conversation, indexPath)
        } else {
            if !viewModel.selectedConversations.contains(conversation) {
                self.viewModel.selectedConversations.append(conversation)
                self.onSelection?(self.viewModel.selectedConversations)
            }
        }
    }
    
    open override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let conversation =  viewModel.conversations[indexPath.row]
        if let foundConversation = viewModel.selectedConversations.firstIndex(of: conversation) {
            viewModel.selectedConversations.remove(at: foundConversation)
            self.onSelection?(self.viewModel.selectedConversations)
        }
    }
    
    open override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    open override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        guard let conversation = viewModel.conversations[safe: indexPath.row] else {
            return nil
        }
            
        var actions = [UIContextualAction]()
        if let customOptions = options?(conversation) {
            let customActions = customOptions.map { option -> UIContextualAction in
                let action = UIContextualAction(style: .normal, title: option.title) { (action, sourceView, completionHandler) in
                    option.onClick?(nil, indexPath.section, option, self)
                    completionHandler(true)
                }
                action.backgroundColor = option.backgroundColor
                action.image = option.icon?.withTintColor(option.iconTint ?? .white)
                return action
            }
            actions.append(contentsOf: customActions)
        } else {
            if !hideDeleteConversationOption{
                let delete = UIContextualAction(style: .destructive, title: ConversationConstants.delete) { [weak self] (action, sourceView, completionHandler) in
                    guard let this = self else { return }
                    this.delete(conversation: conversation)
                }
                delete.image = swipeActionImage(
                    named: "messages-delete",
                    caption: ConversationConstants.delete,
                    tint: style.deleteActionIconTint
                )
                delete.backgroundColor = style.deleteActionBackgroundColor
                actions.append(delete)
            }

            if let pin = pinContextualAction(for: conversation) {
                actions.append(pin)
            }
        }
        
        if let addOptions = addOptions?(conversation){
            let customActions = addOptions.map { option -> UIContextualAction in
                let action = UIContextualAction(style: .normal, title: option.title) { (action, sourceView, completionHandler) in
                    option.onClick?(nil, indexPath.section, option, self)
                    completionHandler(true)
                }
                action.backgroundColor = option.backgroundColor
                action.image = option.icon?.withTintColor(option.iconTint ?? .white)
                return action
            }
            actions.append(contentsOf: customActions)
        }
        
        let swipeActionConfig = UISwipeActionsConfiguration(actions: actions)
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
        
    }
    
    // MARK: - Pin conversation

    /// The Pin/Unpin swipe action, or `nil` when the feature is off, hidden, or the row
    /// carries an admin-global pin the user is not permitted to remove.
    private func pinContextualAction(for conversation: Conversation) -> UIContextualAction? {
        // TEMPORARY — REVERT BEFORE MERGE: `CometChat.isPinConversationEnabled()` is ANDed in
        // here normally, but `features.ux.conversations.pinned.enabled` is missing from the
        // server's SDK cache-bust hash, so it never turns true and the swipe action can never
        // appear. Dropped from the guard to allow manual testing; restore it once the backend
        // adds the flag to the hash list.
        guard enablePinConversation,
              !hidePinConversationOption else { return nil }

        let isPinned = viewModel.isPinned(conversation: conversation)

        // An admin-global pin is not the user's to remove — the server rejects it — so don't
        // offer the affordance at all. Note this guard is doing real work today: RBAC is not
        // yet enforced backend-side, so nothing else stops the attempt.
        if isPinned && conversation.pinnedBy == ConversationConstants.systemPinner {
            return nil
        }

        let title = isPinned ? ConversationConstants.unpinConversation
                             : ConversationConstants.pinConversation

        // The conversation is captured here rather than read from the handler's arguments:
        // the swipe handler calls onClick with a nil entity and indexPath.section (always 0),
        // never .row, so an option cannot recover which row invoked it.
        let action = UIContextualAction(style: .normal, title: title) { [weak self] (_, _, completionHandler) in
            completionHandler(true)
            // Pin is one-tap; unpin confirms first.
            if isPinned {
                PinSaveConfirmation.present(.unpinConversation, on: self) {
                    self?.togglePin(for: conversation, shouldPin: false)
                }
            } else {
                self?.togglePin(for: conversation, shouldPin: true)
            }
        }
        action.image = swipeActionImage(
            named: isPinned ? "keep-off" : "keep",
            caption: title,
            tint: style.pinActionIconTint
        )
        action.backgroundColor = style.pinActionBackgroundColor
        return action
    }

    /// The glyph for a swipe action, composited with its caption only where UIKit needs it.
    ///
    /// Pre-iOS 26 UIKit drops a contextual action's own `title` when the image leaves no
    /// vertical room, so the caption has to be baked into the bitmap. iOS 26 renders the
    /// `title` itself and sizes the tile around whatever image it is handed — so passing the
    /// composite there yields both the baked-in and the native caption, and an oversized
    /// bitmap that squeezes out the tile's padding. Handing it the bare glyph fixes both.
    private func swipeActionImage(named name: String, caption: String, tint: UIColor) -> UIImage? {
        let glyph = UIImage(named: name, in: CometChatUIKit.bundle, compatibleWith: nil)?
            .withRenderingMode(.alwaysTemplate)

        if #available(iOS 26, *) {
            return glyph?.withTintColor(tint, renderingMode: .alwaysOriginal)
        }

        // `add(text:)` applies the tint; .alwaysOriginal then stops UIKit re-tinting the composite.
        return glyph?
            .add(text: caption, imageTint: tint)?
            .withRenderingMode(.alwaysOriginal)
    }

    /// Moves the row only once the server confirms.
    ///
    /// The row deliberately does not flip optimistically. The cap is server-owned and not
    /// exposed by the SDK, so a rejection is only knowable after the fact — flipping first
    /// meant a doomed pin animated to the top and back down before the alert. Waiting also
    /// drops a second animation on the success path, where the local `Date()` guess rarely
    /// matched the server's `pinnedAt` and the echo re-sorted the row again.
    private func togglePin(for conversation: Conversation, shouldPin: Bool) {
        // `conversationId` is optional on `Conversation` (unlike on `BaseMessage`/`Group`) and
        // is nil for the same rows that yield no `id` — one with no backing conversation. A
        // `?? ""` fallback would collapse every such row onto one guard key, so a nil bails.
        guard let id = conversation.conversationType == .user
                ? (conversation.conversationWith as? User)?.uid
                : (conversation.conversationWith as? Group)?.guid,
              let toggleId = conversation.conversationId else { return }

        // Serialises repeated swipes so a second tap cannot start while the first is in flight.
        guard MessageActionToggleGuard.shared.begin(action: .pinConversation, id: toggleId) else { return }

        // Non-optional: the pin-conversation verbs follow the ThreadsRequest convention and
        // always hand back a concrete exception, unlike the older optional-error APIs.
        //
        // Nothing was mutated before the call, so there is nothing to roll back — the row has
        // not moved and must not move now.
        let onFailure: (CometChatException) -> Void = { [weak self] error in
            DispatchQueue.main.async {
                MessageActionToggleGuard.shared.end(action: .pinConversation, id: toggleId)
                self?.showPinFailure(error: error, shouldPin: shouldPin)
            }
        }

        // The echoed conversation carries the server's real `pinnedAt`, so this is the only
        // place the row moves.
        let onSuccess: (Conversation) -> Void = { [weak self] updated in
            DispatchQueue.main.async {
                MessageActionToggleGuard.shared.end(action: .pinConversation, id: toggleId)
                self?.viewModel.repositionForPinChange(conversation: updated)
            }
        }

        if shouldPin {
            CometChat.pinConversation(conversationWith: id,
                                      conversationType: conversation.conversationType,
                                      onSuccess: onSuccess,
                                      onError: onFailure)
        } else {
            CometChat.unpinConversation(conversationWith: id,
                                        conversationType: conversation.conversationType,
                                        onSuccess: onSuccess,
                                        onError: onFailure)
        }
    }

    /// Surfaces a pin failure.
    ///
    /// Codes match what the backend actually emits (API reference on ENG-37690). The design
    /// doc's `ERR_ACTION_NOT_ALLOWED` does not exist in the codebase, so matching on it would
    /// silently fall through to the generic message.
    ///
    /// The cap is server-owned and read from `errorParams`, never hard-coded — the default is
    /// 5 but `limits.conversations.pinnedPerUser` is tenant-overridable. Staging does not send
    /// `errorParams` yet, so the cap is recovered from the message text as a fallback; if
    /// neither yields a number the copy degrades to generic rather than rendering a wrong one.
    private func showPinFailure(error: CometChatException, shouldPin: Bool) {
        var message = ConversationConstants.pinConversationFailed

        switch error.errorCode {
        case PinConversationErrorCodes.limitExceeded:
            let limit = (error.errorParams?["limit"] ?? error.errorParams?["limits"]) as? Int
                ?? CometChatMessageList.trailingLimit(in: error.errorDescription)
            if let limit {
                message = String(format: ConversationConstants.pinnedConversationsLimitReached, "\(limit)")
            }
        case PinConversationErrorCodes.notAccessible:
            // No conversation row yet (never messaged) or deleted-for-me. Known backend
            // behaviour, not a transient failure — retrying will not help.
            message = ConversationConstants.pinConversationNotAvailable
        case PinConversationErrorCodes.permissionDenied:
            message = ConversationConstants.pinConversationPermissionDenied
        default:
            break
        }

        CometChatToast.show(message: message, on: self)
    }

    private func delete(conversation: Conversation) {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: ConversationConstants.deleteConversation, message: ConversationConstants.deleteConversationMessage, preferredStyle: .alert)
        
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
        present(actionSheetController, animated: true)
    }
}

extension CometChatConversations: CometChatConnectionDelegate {
    public func connected() {
        // Setting isRefresh already fetches via its didSet — a second explicit fetch here
        // would issue a redundant request for the same reconnect.
        viewModel.isRefresh = true
    }
    
    public func connecting() {}
    
    public func disconnected() {}
}

