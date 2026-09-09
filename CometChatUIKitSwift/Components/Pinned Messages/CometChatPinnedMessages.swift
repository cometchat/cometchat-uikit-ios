//
//  CometChatPinnedMessages.swift
//  CometChatUIKitSwift
//

import UIKit
import CometChatSDK

enum PinnedMessagesConstants {
    static let eventListener = "pinned-messages-event-listener"
    static let connectionListener = "pinned-messages-sdk-listener"
}

/// The pinned messages of one conversation, newest pin first.
///
/// Read-only by design (doc §7.7): opening the panel does not mark anything as read,
/// emit receipts, or touch the unread count.
@MainActor
open class CometChatPinnedMessages: CometChatListBase {

    // MARK: - Properties
    public var viewModel: PinnedMessagesViewModel

    /// Row slot overrides. Each maps onto a bubble slot: `subtitle` fills the bubble
    /// content, `titleView` the header, `trailingView` the status info, and
    /// `listItemView` replaces the bubble outright.
    var subtitle: ((_ message: BaseMessage?) -> UIView)?
    var listItemView: ((_ message: BaseMessage?) -> UIView)?
    var titleView: ((_ message: BaseMessage?) -> UIView)?
    var trailingView: ((_ message: BaseMessage?) -> UIView)?

    public static var style = PinnedMessagesStyle()
    public static var avatarStyle: AvatarStyle = CometChatAvatar.style
    public static var dateSeparatorStyle: DateStyle = CometChatDate.style
    public static var messageBubbleStyle = CometChatMessageBubble.style
    public static var actionBubbleStyle = CometChatMessageBubble.actionBubbleStyle
    public static var callActionBubbleStyle = CometChatMessageBubble.callActionBubbleStyle

    public lazy var style = CometChatPinnedMessages.style
    public lazy var avatarStyle: AvatarStyle = CometChatPinnedMessages.avatarStyle
    public lazy var dateSeparatorStyle: DateStyle = CometChatPinnedMessages.dateSeparatorStyle
    public lazy var messageBubbleStyle = CometChatPinnedMessages.messageBubbleStyle
    public lazy var actionBubbleStyle = CometChatPinnedMessages.actionBubbleStyle
    public lazy var callActionBubbleStyle = CometChatPinnedMessages.callActionBubbleStyle

    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    public lazy var dateTimeFormatter: CometChatDateTimeFormatter = CometChatPinnedMessages.dateTimeFormatter

    /// Off by default: every row already carries its own pinned-at timestamp, so the day
    /// header only added a band of empty space above the first bubble. Hosts can opt back
    /// in with `set(hideDateSeparator:)`.
    public var hideDateSeparator = true
    public var hideBubbleHeader = false
    public var hideReceipts = false
    public var hideAvatar: Bool?

    /// Every row sits on the left with its avatar and sender name, the logged-in user's
    /// included — this is an archive of who pinned what, not a conversation, so mirroring
    /// the chat's outgoing-right layout would read as a second chat view.
    public var messageAlignment: MessageListAlignment = .leftAligned
    public var enableMultipleAttachments = true
    /// Off by default, matching `CometChatMessageList`: the host opts in on both surfaces.
    public internal(set) var dateSeparatorPattern: ((_ timestamp: Int?) -> String)?
    public internal(set) var timePattern: ((_ timestamp: Int?) -> String)?

    /// Replayed over the defaults after every `setUpDefaultTemplate()`, which re-runs on
    /// each appearance and would otherwise discard host overrides.
    var customTemplates: [CometChatMessageTemplate] = []

    var textFormatters: [CometChatTextFormatter] = []

    /// Tapping a row jumps the underlying message list to that message.
    public var onMessageClicked: ((_ message: BaseMessage) -> Void)?
    var onError: ((_ error: CometChatException) -> Void)?
    var onEmpty: (() -> Void)?
    var onLoad: (([BaseMessage]) -> Void)?

    /// Hides the per-row unpin control for users who cannot pin here.
    public var hideUnpinOption: Bool = false

    /// Suppresses the long-press menu outright, returning the panel to a read-only list.
    public var hideMessageOptions: Bool = false

    var isContextMenuActive = false
    var contextMenuCell: CometChatMessageBubble?
    var contextMenuMessage: BaseMessage?

    // MARK: - Initializer
    public init(user: User? = nil, group: Group? = nil) {
        viewModel = PinnedMessagesViewModel(user: user, group: group)
        super.init(nibName: nil, bundle: nil)
        self.defaultSetup()
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - ViewController Life Cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView(style: .plain, withRefreshControl: true)
        // Before anything can ask for a cell: `setupTableView` embeds the table with its
        // data source already wired, so a layout pass — or a reload driven by an event
        // arriving before `viewWillAppear` — would dequeue an unregistered identifier.
        registerCells()
        showLoadingView()
        setupViewModel()
        initialSetup()
    }

    func initialSetup() {
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false

        // Bubbles vary far more in height than list rows did, so an estimate keeps the
        // scroll indicator from jumping as cells resolve.
        tableView.estimatedRowHeight = 80
        tableView.estimatedSectionHeaderHeight = 40

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CometChat.addConnectionListener(PinnedMessagesConstants.connectionListener, self)
        registerCells()
        setUpTemplates()
        hideSeparator = true
        viewModel.connect()
        reloadData()
        fetchData()
    }

    /// Resolves the default templates, then replays host overrides on top. Runs on every
    /// appearance so a data-source decorator registered after init is picked up.
    open func setUpTemplates() {
        viewModel.textFormatters = textFormatters
        viewModel.messageBubbleStyle = messageBubbleStyle
        viewModel.actionBubbleStyle = actionBubbleStyle
        viewModel.callActionBubbleStyle = callActionBubbleStyle
        viewModel.enableMultipleAttachments = enableMultipleAttachments
        viewModel.setUpDefaultTemplate()
        customTemplates.forEach { viewModel.templates["\($0.category)_\($0.type)"] = $0 }
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CometChat.removeConnectionListener(PinnedMessagesConstants.connectionListener)
        viewModel.disconnect()
    }

    // MARK: - Setup Methods
    open func defaultSetup() {
        loadingView = PinnedMessagesShimmerView()

        // No count in the header, so the format's leading slot trims away.
        title = String(format: "PINNED_MESSAGES_TITLE".localize(), "").trimmingCharacters(in: .whitespaces)
        prefersLargeTitles = false
        hideSearch = true

        errorStateTitleText = "OOPS!".localize()
        errorStateSubTitleText = "LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize()
        errorStateImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()

        // Illustration-scale art, separate from the icon-scale `keep` the banner button uses.
        emptyStateImage = UIImage(named: "pinned-empty-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
        emptyStateTitleText = "PINNED_MESSAGES_EMPTY_TITLE".localize()
        emptyStateSubTitleText = "PINNED_MESSAGES_EMPTY_SUBTITLE".localize()
        (emptyStateView as? StateView)?.retryButton.isHidden = true

        // `DateStyle` ships a filled, bordered box with no corner radius. The divider reads
        // as a pill, so round it — `cornerRadius` defaults to nil and would stay square.
        dateSeparatorStyle.textFont = CometChatTypography.Caption1.medium
        dateSeparatorStyle.textColor = CometChatTheme.textColorSecondary
        dateSeparatorStyle.cornerRadius = .init(cornerRadius: CometChatSpacing.Radius.rMax)

        // The panel opens from the message list, whose header draws a bare chevron. iOS 26
        // backs every bar item with a glass capsule, which a custom view does not escape —
        // `hidesSharedBackground` is the only opt-out. `hideBackButton` must stay true or
        // the stock button renders alongside ours.
        hideBackButton = true
        leftBarButtonItem = [makeBackItem()]

        // Our button routes through `addBackPress` → `onBack`, which is an unset optional by
        // default — the stock button used to pop for free, so without this it does nothing.
        // A host's `set(onBack:)` still replaces this.
        onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }

    /// `hidesSharedBackground` drops the iOS 26 glass capsule, leaving the bare chevron the
    /// message header draws. A no-op on earlier versions, which never draw the capsule.
    func makeBackItem() -> UIBarButtonItem {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysTemplate),
            style: .plain,
            target: self,
            action: #selector(addBackPress)
        )
        item.tintColor = CometChatTheme.iconColorPrimary
        if #available(iOS 26.0, *) {
            item.hidesSharedBackground = true
        }
        return item
    }

    override func onRefreshControlTriggered() {
        viewModel.isRefresh = true
    }

    // MARK: - Styling Methods
    open override func setupStyle() {
        listBaseStyle = style
        super.setupStyle()
    }

    /// The header is a static label — the count lives on the banner, not here.
    /// Interpolated, never concatenated — concatenation breaks the RTL layout.
    open func updateTitle() {
        title = String(format: "PINNED_MESSAGES_TITLE".localize(), "").trimmingCharacters(in: .whitespaces)
        navigationItem.title = title
    }

    // MARK: - Data Fetching Methods
    open func fetchData() {
        viewModel.fetchPinnedMessages()
    }

    // MARK: - Data Reloading
    open func reloadData() {
        viewModel.reload = { [weak self] in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.removeErrorView()
                this.reload()
                this.updateTitle()

                let isEmpty = this.viewModel.messages.isEmpty
                if isEmpty {
                    this.showEmptyView()
                    this.onEmpty?()
                } else {
                    this.removeEmptyView()
                    this.tableView.restore()
                }

                this.refreshControl.endRefreshing()
                this.hideFooterIndicator()
                this.removeLoadingView()
                this.onLoad?(this.viewModel.messages)
            }
        }

        viewModel.removeAtIndex = { [weak self] indexPath in
            guard let this = self else { return }
            DispatchQueue.main.async {
                // Unpinning the last row of a day retires its date separator too, so a
                // row-only delete would leave the table's section count ahead of the data
                // source and throw. The list caps at 100 rows, so a full reload is cheap
                // and removes the whole desync hazard.
                this.tableView.reloadData()
                this.updateTitle()
            }
        }
    }

    // MARK: - ViewModel Setup
    open func setupViewModel() {
        viewModel.failure = { [weak self] error in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.onError?(error)
                this.removeLoadingView()
                this.refreshControl.endRefreshing()

                if this.viewModel.messages.isEmpty {
                    this.showErrorView()
                }
            }
        }

        // The row is already back in place; this only reports why.
        viewModel.unpinFailure = { [weak self] error in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.onError?(error)
                CometChatToast.show(message: this.unpinErrorMessage(for: error), on: this)
            }
        }
    }

    /// Mirrors the bubble surface: prefer the server's own copy, fall back to ours.
    open func unpinErrorMessage(for error: CometChatException) -> String {
        if PinSaveErrorCodes.permissionCodes.contains(error.errorCode) {
            return "PIN_MESSAGE_PERMISSION_DENIED".localize()
        }
        return "PIN_MESSAGE_FAILED".localize()
    }

    // MARK: - Cell Registration

    /// `set(bubbleView:)` tears the bubble's own stacks out of the container and
    /// `prepareForReuse` never puts them back, so a cell that once carried a custom bubble
    /// can never render a normal one again. Keeping the two populations on separate reuse
    /// identifiers avoids that without touching the shared bubble.
    static let customBubbleIdentifier = "CometChatPinnedMessageCustomBubble"

    open func registerCells() {
        tableView.register(CometChatMessageBubble.self, forCellReuseIdentifier: CometChatMessageBubble.identifier)
        tableView.register(CometChatMessageBubble.self, forCellReuseIdentifier: Self.customBubbleIdentifier)
    }
}

// MARK: - TableView delegate and datasource methods inherited from CometChatListBase.
extension CometChatPinnedMessages {

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[safe: section]?.messages.count ?? 0
    }

    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    // Not an override — `CometChatListBase` declares no section-header methods.
    open func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard !hideDateSeparator, let date = viewModel.sections[safe: section]?.date else { return nil }

        let dateHeader = CometChatDate().withoutAutoresizingMaskConstraints()
        dateHeader.dateTimeFormatter = dateTimeFormatter
        if let pattern = dateSeparatorPattern?(date) {
            dateHeader.text = pattern
        } else {
            dateHeader.set(pattern: .dayDate)
            dateHeader.set(timestamp: date)
        }
        dateHeader.padding = UIEdgeInsets(
            top: CometChatSpacing.Padding.p1,
            left: CometChatSpacing.Padding.p2,
            bottom: CometChatSpacing.Padding.p1,
            right: CometChatSpacing.Padding.p2
        )
        dateHeader.style = dateSeparatorStyle

        let container = UIView()
        container.backgroundColor = .clear
        container.addSubview(dateHeader)
        dateHeader.pin(anchors: [.centerX, .centerY], to: container)
        return container
    }

    open func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return hideDateSeparator ? 0 : 40
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let message = viewModel.message(at: indexPath) else { return UITableViewCell() }
        return createPinnedMessageCell(for: message, at: indexPath, in: tableView)
    }

    /// A trimmed `CometChatMessageList.createMessageCell`. What a pinned row *shows* matches
    /// the chat — quoted parent, reactions — while what it *composes* is dropped:
    /// no swipe-to-reply, no threaded replies, no batch grouping or unread separator, and no
    /// inversion transform, because unlike the message list this table is not flipped. The
    /// long-press menu is offered, but only the options in `allowedOptionIds`.
    open func createPinnedMessageCell(
        for message: BaseMessage,
        at indexPath: IndexPath,
        in tableView: UITableView
    ) -> UITableViewCell {

        let template = viewModel.getTemplate(for: message)
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
        let bubbleStyle = isLoggedInUser ? messageBubbleStyle.outgoing : messageBubbleStyle.incoming
        let messageTypeStyle = MessageUtils.getSpecificMessageTypeStyle(message: message, from: messageBubbleStyle)

        // Computed up front rather than read back off the cell: every template closure is
        // handed this value, and the custom-bubble probe below runs before dequeue.
        let isCentered = (message.messageCategory == .action || message.messageCategory == .call)
        let alignment: MessageBubbleAlignment
        if isCentered {
            alignment = .center
        } else if messageAlignment == .leftAligned {
            alignment = .left
        } else {
            alignment = isLoggedInUser ? .right : .left
        }

        // Resolved before dequeue so custom bubbles land on their own reuse identifier.
        let customBubble = listItemView?(message) ?? template?.bubbleView?(message, alignment, self)
        let identifier = customBubble == nil ? CometChatMessageBubble.identifier : Self.customBubbleIdentifier

        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? CometChatMessageBubble else {
            return UITableViewCell()
        }

        cell.set(message: message)
        // Cleared here; `applyQuotedMessage` below refills it when there is a parent.
        cell.set(replyView: nil)
        cell.set(bottomView: nil)
        cell.set(style: bubbleStyle, specificMessageTypeStyle: messageTypeStyle)

        // Long press opens the option menu; swipe-to-reply stays off — this surface
        // does not compose messages.
        if hideMessageOptions {
            cell.onLongPressGestureRecognized = nil
            cell.firstLongPressForAnimation?.isEnabled = false
            cell.secondLongPressForAction?.isEnabled = false
        } else {
            // Re-enable explicitly: a cell reused from a `hideMessageOptions` pass keeps
            // the disabled recognizers, and `prepareForReuse` does not restore them.
            cell.firstLongPressForAnimation?.isEnabled = true
            cell.secondLongPressForAction?.isEnabled = true
            setupContextMenu(for: cell, message: message)
        }
        cell.disableSwipeToReply = true
        // Still called: its first act is stripping a stale recognizer off a reused cell,
        // and `disableSwipeToReply` makes it return before installing a new one.
        cell.setupSwipeGestures(message: message)

        // Applied before any template closure runs — those closures receive `cell.alignment`,
        // and on a reused cell it would otherwise still be the previous row's.
        cell.set(bubbleAlignment: alignment)

        if let customBubble = customBubble {
            cell.set(bubbleView: customBubble)
            return cell
        }

        guard let template = template else {
            return buildUnsupportedCell(cell, message: message, isLoggedInUser: isLoggedInUser)
        }

        if isCentered {
            if let content = template.contentView?(message, cell.alignment, self) {
                cell.set(contentView: content)
                cell.set(backgroundColor: .clear)
                if message.messageCategory == .action {
                    cell.set(actionStyle: actionBubbleStyle)
                } else {
                    cell.set(callActionStyle: callActionBubbleStyle)
                }
            }
            cell.hide(headerView: true)
            cell.hide(avatar: true)
            return cell
        }

        // Fills the header; `applyAvatar` below owns whether it is shown.
        if let header = titleView?(message) ?? template.headerView?(message, cell.alignment, self) {
            cell.set(headerView: header)
        } else {
            cell.set(headerView: senderNameLabel(for: message, isLoggedInUser: isLoggedInUser))
        }

        if let content = subtitle?(message) ?? template.contentView?(message, cell.alignment, self) {
            cell.set(contentView: content)
        }

        // The in-bubble timestamp is the send time; the pin time is carried by the date
        // separator this row sits under.
        if let statusInfo = trailingView?(message) ?? template.statusInfoView?(message, cell.alignment, self) {
            cell.set(statusInfoView: statusInfo)
        } else {
            MessageUtils.buildStatusInfo(
                from: cell,
                messageTypeStyle: messageTypeStyle,
                bubbleStyle: bubbleStyle,
                message: message,
                hideReceipt: hideReceipts,
                messageAlignment: messageAlignment,
                timePattern: timePattern,
                dateTimeFormatter: dateTimeFormatter,
                isModerated: MessageUtils.isMessageModerationDisapproved(message: message)
            )
        }

        applyQuotedMessage(
            on: cell,
            message: message,
            template: template,
            bubbleStyle: bubbleStyle,
            messageTypeStyle: messageTypeStyle
        )
        applyReactions(on: cell, message: message, bubbleStyle: bubbleStyle, messageTypeStyle: messageTypeStyle)
        applyAvatar(on: cell, message: message)
        return cell
    }

    /// Shows the parent a pinned reply quotes.
    ///
    /// Display only: the message list makes the preview tappable to jump to the parent,
    /// which may not itself be pinned. Here the whole row already jumps to the message,
    /// so the preview stays inert rather than offering a second, different destination.
    private func applyQuotedMessage(
        on cell: CometChatMessageBubble,
        message: BaseMessage,
        template: CometChatMessageTemplate,
        bubbleStyle: MessageBubbleStyle,
        messageTypeStyle: BaseMessageBubbleStyle?
    ) {
        // Mirrors the message list: the SDK leaves `quotedMessage` nil for some categories
        // even when the raw payload carries it. Parsed once, then cached on the message.
        if message.quotedMessage == nil,
           let rawQuoted = message.rawMessage?["quotedMessage"] as? [String: Any] {
            message.quotedMessage = MessageUtils.resolveQuotedMessage(from: rawQuoted)
        }

        guard let quotedMessage = message.quotedMessage,
              message.deletedAt <= 0,
              !MessageUtils.isMessageModerationDisapproved(message: message) else { return }

        // A template-supplied reply view wins, exactly as on the message list.
        if let customReplyView = template.replyView?(message, cell.alignment, self) {
            cell.set(replyView: customReplyView)
            return
        }

        let preview = CometChatMessagePreview.makePreview(
            for: quotedMessage,
            isLoggedInUser: LoggedInUserInformation.isLoggedInUser(uid: quotedMessage.senderUid),
            textFormatters: viewModel.textFormatters,
            formattingType: .MESSAGE_BUBBLE,
            style: messageTypeStyle?.messagePreviewStyle ?? bubbleStyle.messagePreviewStyle,
            onPreviewClicked: nil,
            onCrossClicked: nil,
            hideCloseButton: true
        )
        preview.isUserInteractionEnabled = false

        cell.set(replyView: preview)
        preview.setNeedsLayout()
        preview.layoutIfNeeded()
    }

    /// Shows the reactions a pinned message already carries.
    ///
    /// Display only: the message list's footer also wires tap-to-toggle and a long-press
    /// reaction list, and neither is set here, so the row reports reactions without
    /// becoming a place to make them.
    private func applyReactions(
        on cell: CometChatMessageBubble,
        message: BaseMessage,
        bubbleStyle: MessageBubbleStyle,
        messageTypeStyle: BaseMessageBubbleStyle?
    ) {
        // Cleared every pass: `set(footerView:)` embeds without replacing, and a cell
        // reused inside one reload cycle would otherwise stack the previous row's view.
        cell.footerView.subviews.forEach { $0.removeFromSuperview() }

        guard !message.reactions.isEmpty else { return }
        // The message list excludes these too — there is nothing to react to on them.
        guard message.deletedAt == 0,
              message.metaData?["error"] as? Bool != true,
              !MessageUtils.isMessageModerationDisapproved(message: message) else { return }

        // `buildUI` reads the bubble's width to decide how many reactions fit.
        cell.bubbleStackView.layoutIfNeeded()

        let reactions = CometChatReactions()
            .set(message: message)
            .set(width: cell.bubbleStackView.bounds.width)
            .set(reactionAlignment: cell.alignment)
        reactions.isLayoutMarginsRelativeArrangement = true
        reactions.layoutMargins = UIEdgeInsets(top: -6, left: 3, bottom: 0, right: 3)
        // Taps belong to the row, which jumps to the message.
        reactions.isUserInteractionEnabled = false
        // Assigned last: `style`'s `didSet` is what calls `buildUI()`, so setting it
        // earlier would render before the message and width are in place.
        reactions.style = messageTypeStyle?.reactionsStyle ?? bubbleStyle.reactionsStyle

        cell.set(footerView: reactions)
    }

    private func senderNameLabel(for message: BaseMessage, isLoggedInUser: Bool) -> UILabel {
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 1
        nameLabel.text = isLoggedInUser ? "YOU".localize() : (message.sender?.name ?? "")
        nameLabel.font = style.bubbleHeaderFont
        nameLabel.textColor = style.bubbleHeaderTextColor
        return nameLabel
    }

    /// Every row shows its sender's avatar and name, in 1-1 chats as much as in groups.
    /// The message list can drop them because left-vs-right already identifies the sender;
    /// here every bubble is left-aligned, so the row would otherwise be unattributed.
    /// Set both explicitly — `prepareForReuse` restores neither.
    private func applyAvatar(on cell: CometChatMessageBubble, message: BaseMessage) {
        // Set before the sender check: a reused cell keeps the previous row's visibility,
        // so a senderless message would otherwise inherit someone else's avatar slot.
        cell.hide(avatar: hideAvatar ?? false)
        cell.hide(headerView: hideBubbleHeader)

        guard let sender = message.sender else { return }
        cell.set(avatarURL: sender.avatar, avatarName: sender.name)
        cell.avatar.style = avatarStyle
    }

    /// No template matched the message type — mirrors the message list's fallback.
    private func buildUnsupportedCell(
        _ cell: CometChatMessageBubble,
        message: BaseMessage,
        isLoggedInUser: Bool
    ) -> UITableViewCell {

        cell.set(headerView: senderNameLabel(for: message, isLoggedInUser: isLoggedInUser))

        let unsupported = CometChatDeleteBubble()
        unsupported.messageText = "MESSAGE_TYPE_NOT_SUPPORTED".localize()
        cell.set(contentView: unsupported)

        applyAvatar(on: cell, message: message)
        return cell
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let message = viewModel.message(at: indexPath) else { return }
        onMessageClicked?(message)
    }

    open override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !hideUnpinOption, let message = viewModel.message(at: indexPath) else { return nil }

        let action = UIContextualAction(style: .destructive, title: "UNPIN_MESSAGE".localize()) { [weak self] _, _, completion in
            // `false` closes the swipe without deleting the row: the row leaves only once the
            // unpin is confirmed, and stays put on cancel.
            completion(false)
            PinSaveConfirmation.present(.unpinMessage, on: self) {
                self?.viewModel.unpin(message: message)
            }
        }
        action.backgroundColor = style.unpinActionBackgroundColor
        action.image = UIImage(named: "keep-off", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        action.accessibilityLabel = "UNPIN_MESSAGE".localize()

        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: - Connection Listener
extension CometChatPinnedMessages: CometChatConnectionDelegate {

    public func connected() {
        viewModel.isRefresh = true
    }

    public func connecting() {}

    public func disconnected() {}
}
