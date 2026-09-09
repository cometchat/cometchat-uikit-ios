//
//  CometChatSavedMessages.swift
//  CometChatUIKitSwift
//

import UIKit
import CometChatSDK

enum SavedMessagesConstants {
    static let eventListener = "saved-messages-event-listener"
    static let connectionListener = "saved-messages-sdk-listener"
}

/// The logged-in user's saved messages, newest save first.
///
/// A **user-level** surface (doc §6.4): saved messages are private to the user and span
/// every conversation, so this is reached from app chrome rather than a conversation
/// header — unlike `CometChatPinnedMessages`, which is scoped to one chat.
///
/// Read-only by design (doc §7.7): opening the screen does not mark anything as read,
/// emit receipts, or touch the unread count.
@MainActor
open class CometChatSavedMessages: CometChatListBase {

    // MARK: - Properties
    public var viewModel: SavedMessagesViewModel

    var subtitle: ((_ message: BaseMessage?) -> UIView)?
    var listItemView: ((_ message: BaseMessage?) -> UIView)?
    var titleView: ((_ message: BaseMessage?) -> UIView)?
    var trailingView: ((_ message: BaseMessage?) -> UIView)?
    var leadingView: ((_ message: BaseMessage?) -> UIView)?

    public static var style = SavedMessagesStyle()
    public static var dateStyle: DateStyle = CometChatDate.style
    public static var avatarStyle: AvatarStyle = CometChatAvatar.style

    public lazy var style = CometChatSavedMessages.style
    public lazy var dateStyle: DateStyle = CometChatSavedMessages.dateStyle
    public lazy var avatarStyle: AvatarStyle = CometChatSavedMessages.avatarStyle

    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    public lazy var dateTimeFormatter: CometChatDateTimeFormatter = CometChatSavedMessages.dateTimeFormatter

    var textFormatters: [CometChatTextFormatter] = []

    /// Resolves each row's source conversation without blocking the row (doc §6.4).
    let sourceResolver = SavedMessagesSourceResolver()

    /// Tapping a row opens the message's own conversation and jumps to it.
    public var onMessageClicked: ((_ message: BaseMessage) -> Void)?
    var onError: ((_ error: CometChatException) -> Void)?
    var onEmpty: (() -> Void)?
    var onLoad: (([BaseMessage]) -> Void)?

    /// Hides the per-row unsave control.
    public var hideUnsaveOption: Bool = false

    // MARK: - Initializer
    public init() {
        viewModel = SavedMessagesViewModel()
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
        setupSourceResolver()
        initialSetup()
    }

    func initialSetup() {
        tableView.separatorStyle = .none
        tableView.allowsMultipleSelection = false

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        CometChat.addConnectionListener(SavedMessagesConstants.connectionListener, self)
        registerCells()
        hideSeparator = true
        viewModel.connect()
        reloadData()
        fetchData()
    }

    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        CometChat.removeConnectionListener(SavedMessagesConstants.connectionListener)
        viewModel.disconnect()
    }

    // MARK: - Setup Methods
    open func defaultSetup() {
        loadingView = SavedMessagesShimmerView()

        // No count in the header, so the format's leading slot trims away.
        title = String(format: "SAVED_MESSAGES_TITLE".localize(), "").trimmingCharacters(in: .whitespaces)
        prefersLargeTitles = false
        hideSearch = true

        errorStateTitleText = "OOPS!".localize()
        errorStateSubTitleText = "LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize()
        errorStateImage = UIImage(named: "error-icon", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()

        emptyStateImage = UIImage(named: "bookmark", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        emptyStateTitleText = "SAVED_MESSAGES_EMPTY_TITLE".localize()
        emptyStateSubTitleText = "SAVED_MESSAGES_EMPTY_SUBTITLE".localize()
        (emptyStateView as? StateView)?.retryButton.isHidden = true

        // `DateStyle` defaults to the message list's date *chip* — a bordered, filled pill.
        // A row timestamp is bare text, so flatten it exactly as the conversation list does.
        dateStyle.textColor = CometChatTheme.textColorSecondary
        dateStyle.textFont = CometChatTypography.Caption1.regular
        dateStyle.borderWidth = 0
        dateStyle.backgroundColor = .clear

        // iOS 26 backs every bar item with a glass capsule, which the other screens' bare
        // chevrons don't have; a custom view does not escape it, so `hidesSharedBackground`
        // is the only opt-out. `hideBackButton` must stay true or the stock button renders
        // alongside ours.
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

    /// A late-resolved conversation name repaints only the visible rows that were showing
    /// the raw id.
    func setupSourceResolver() {
        sourceResolver.onResolved = { [weak self] _ in
            guard let this = self else { return }
            guard let visible = this.tableView.indexPathsForVisibleRows, !visible.isEmpty else { return }
            this.tableView.reloadRows(at: visible, with: .none)
        }
    }

    // MARK: - Styling Methods
    open override func setupStyle() {
        listBaseStyle = style
        super.setupStyle()
    }

    /// The design carries no count, so the format's leading slot trims away. Interpolated,
    /// never concatenated — concatenation breaks the RTL layout.
    open func updateTitle() {
        title = String(format: "SAVED_MESSAGES_TITLE".localize(), "").trimmingCharacters(in: .whitespaces)
        navigationItem.title = title
    }

    // MARK: - Data Fetching Methods
    open func fetchData() {
        viewModel.fetchSavedMessages()
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
                this.tableView.deleteRows(at: [indexPath], with: .automatic)
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

        // The row disappearing is the only other feedback, and it slides off under the
        // user's thumb — confirm it the same way the bubble surface does.
        viewModel.unsaveSuccess = { [weak self] in
            guard let this = self else { return }
            DispatchQueue.main.async {
                CometChatToast.show(message: "MESSAGE_UNSAVED_TOAST".localize(), on: this)
            }
        }

        // The row is already back in place; this only reports why.
        viewModel.unsaveFailure = { [weak self] error in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.onError?(error)
                CometChatToast.show(message: this.unsaveErrorMessage(for: error), on: this)
            }
        }
    }

    /// Save carries no SBAC (doc §6.5), so there is no permission case to distinguish.
    open func unsaveErrorMessage(for error: CometChatException) -> String {
        return "SAVE_MESSAGE_FAILED".localize()
    }

    // MARK: - Cell Registration
    open func registerCells() {
        tableView.register(CometChatListItem.self, forCellReuseIdentifier: CometChatListItem.identifier)
    }
}

// MARK: - TableView delegate and datasource methods inherited from CometChatListBase.
extension CometChatSavedMessages {

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.messages.count
    }

    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let listItem = tableView.dequeueReusableCell(withIdentifier: CometChatListItem.identifier, for: indexPath) as? CometChatListItem,
              let message = viewModel.messages[safe: indexPath.row] else {
            return UITableViewCell()
        }

        // The row identifies the conversation the message was saved from, not its sender —
        // the sender leads the preview line instead. Sized to match the conversation list.
        listItem.avatar.style = avatarStyle
        listItem.hide(avatar: false)
        listItem.avatarHeightConstraint.constant = 48
        listItem.avatarWidthConstraint.constant = 48

        // No presence or group-type badge on this surface. `prepareForReuse` clears the
        // indicator's image but not its visibility, so this has to be explicit.
        listItem.hide(statusIndicator: true)

        let sourceName = sourceResolver.label(for: message)
        listItem.set(title: sourceName)
        listItem.set(avatarURL: sourceResolver.avatar(for: message), with: sourceName)

        if let titleView = titleView?(message) {
            listItem.set(titleView: titleView)
        }

        if let subtitle = subtitle?(message) {
            listItem.set(subtitle: subtitle)
        } else {
            listItem.set(subtitle: SavedMessagesUtils.configureSubtitleView(
                message: message,
                style: style,
                textFormatter: textFormatters
            ))
        }

        if let leading = leadingView?(message) {
            listItem.set(leadingView: leading)
        }

        if let trail = trailingView?(message) {
            listItem.set(tail: trail)
        } else {
            listItem.set(tail: SavedMessagesUtils.configureTailView(
                message: message,
                dateStyle: dateStyle,
                dateTimeFormatter: dateTimeFormatter
            ))
        }

        if let listItemView = listItemView?(message) {
            listItem.set(customView: listItemView)
        }

        listItem.style = style
        listItem.allow(selection: false)

        return listItem
    }

    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let message = viewModel.messages[safe: indexPath.row] else { return }
        onMessageClicked?(message)
    }

    open override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard !hideUnsaveOption, let message = viewModel.messages[safe: indexPath.row] else { return nil }

        let action = UIContextualAction(style: .destructive, title: "UNSAVE_MESSAGE".localize()) { [weak self] _, _, completion in
            // `false` closes the swipe without deleting the row: the row leaves only once the
            // unsave is confirmed, and stays put on cancel.
            completion(false)
            PinSaveConfirmation.present(.unsaveMessage, on: self) {
                self?.viewModel.unsave(message: message)
            }
        }
        action.backgroundColor = style.unsaveActionBackgroundColor
        action.image = UIImage(named: "bookmark-add", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        action.accessibilityLabel = "UNSAVE_MESSAGE".localize()

        return UISwipeActionsConfiguration(actions: [action])
    }
}

// MARK: - Connection Listener
extension CometChatSavedMessages: CometChatConnectionDelegate {

    public func connected() {
        viewModel.isRefresh = true
    }

    public func connecting() {}

    public func disconnected() {}
}
