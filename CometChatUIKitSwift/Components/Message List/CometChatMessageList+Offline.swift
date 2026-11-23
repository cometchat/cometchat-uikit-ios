//
//  CometChatMessageList+Offline.swift
//  CometChatUIKitSwift
//
//  The offline (ON) parts of the message list view: the menu of an unsent row, offline notices and
//  the state-contract identifier of each row. Nothing here is reached with offline off, except the
//  identifier, which is an additive automation id.
//

import UIKit
import CometChatSDK

extension CometChatMessageList {

    // MARK: - Unsent rows

    /// `true` when `message` is an own row the server has not acked, and offline is on. Such a row
    /// offers Retry and Delete (ruling R162 / S73), never anything that needs a server id, and no Copy.
    func offlineIsUnsentRow(_ message: BaseMessage) -> Bool {
        guard message.messageCategory == .message else { return false }
        // A row that failed direct stays actionable even if the switch flipped off since.
        if OfflineHub.shared.isDirectFailed(message) { return true }
        return OfflineGate.isOn() && MessageIdentity.isUnsent(message)
    }

    /// The menu of an unsent row (ruling R162 / S73, 2026-11-03): Retry and Delete on every own
    /// PENDING, SENDING and FAILED row (any failure reason), and on a failed (direct) one (Retry is a
    /// fresh send there, Delete removes it from the screen only). On a row the SDK is sending right
    /// now, the SDK answers `ERROR_OFFLINE_MESSAGE_IN_FLIGHT` and the list shows "Sending... try again
    /// in a moment" (see `bindOfflineViewModel`).
    func offlineMenuOptions(for message: BaseMessage) -> [CometChatMessageOption] {
        return OfflineUnsentActions.actions(for: message).map { action in
            switch action {
            case .retry:
                return CometChatMessageOption(id: MessageOptionConstants.offlineRetry,
                                              title: "RETRY".localize(),
                                              icon: UIImage(systemName: "arrow.clockwise")?.withRenderingMode(.alwaysTemplate),
                                              onItemClick: { [weak self] message in
                    guard let message = message else { return }
                    (self?.viewModel as? MessageListViewModel)?.offlineRetry(message: message)
                })
            case .delete:
                var delete = CometChatMessageOption(id: MessageOptionConstants.offlineDelete,
                                                    title: "DELETE".localize(),
                                                    icon: AssetConstants.delete,
                                                    onItemClick: { [weak self] message in
                    guard let message = message else { return }
                    (self?.viewModel as? MessageListViewModel)?.offlineDiscard(message: message)
                })
                var style = MessageOptionStyle()
                style.titleColor = CometChatTheme.errorColor
                style.imageTintColor = CometChatTheme.errorColor
                delete.style = style
                return delete
            }
        }
    }

    /// VoiceOver custom actions for an unsent row (the same options as its menu). Cells are reused,
    /// so actions this list added earlier are removed from a row that no longer needs them.
    func offlineApplyAccessibilityActions(to cell: UITableViewCell, message: BaseMessage) {
        let ours: Set<String> = ["RETRY".localize(), "DELETE".localize()]
        var actions = (cell.accessibilityCustomActions ?? []).filter { !ours.contains($0.name) }
        if offlineIsUnsentRow(message) {
            for option in offlineMenuOptions(for: message) {
                actions.append(UIAccessibilityCustomAction(name: option.title) { [weak self] _ in
                    guard let model = self?.viewModel as? MessageListViewModel else { return false }
                    if option.id == MessageOptionConstants.offlineRetry { model.offlineRetry(message: message) }
                    else { model.offlineDiscard(message: message) }
                    return true
                })
            }
        }
        if actions.isEmpty && cell.accessibilityCustomActions == nil { return }
        cell.accessibilityCustomActions = actions.isEmpty ? nil : actions
    }

    /// The status of an unsent own row (matching the Android kit, with R162 applied):
    /// - a tap on its status icon retries it (PENDING, FAILED, failed direct), and VoiceOver reads
    ///   the hint "Retry". A row the SDK is sending right now (SENDING) keeps a plain clock: a stray
    ///   tap there would only raise the "Sending..." notice, and its menu and VoiceOver actions still
    ///   offer Retry;
    /// - a queued or sending row shows "Not sent yet" under the bubble (`notSentYetText*`);
    /// - a failed row shows a line under the bubble, "Not sent. Tap to retry" (a button). Every
    ///   failed row can be retried (R162), so there is no "Not sent" line without Retry.
    /// A line is added only where the bubble has no bottom view of its own. Rows that are not
    /// unsent, and every row with offline off, are left exactly as today.
    func offlineDecorateStatus(of cell: CometChatMessageBubble, message: BaseMessage) {
        guard offlineIsUnsentRow(message) else { return }
        let failed = OfflineHub.shared.isDirectFailed(message) || MessageIdentity.isOutboxFailed(message)
        offlineDecorateUnsentStatus(of: cell, message: message, failed: failed,
                                    canRetry: OfflineUnsentActions.statusTapRetries(message))
    }

    /// The decoration of an unsent row, once its state is known (`offlineDecorateStatus`).
    func offlineDecorateUnsentStatus(of cell: CometChatMessageBubble, message: BaseMessage, failed: Bool, canRetry: Bool) {
        let label = OfflineText.unsentStatusKey(failed: failed).localize()

        if let receipt = Self.firstReceipt(in: cell.statusInfoView) {
            receipt.accessibilityLabel = label
            if failed, let tint = Self.offlineStyle.failedIconTint { receipt.tintColor = tint }
            if canRetry {
                receipt.isUserInteractionEnabled = true
                receipt.accessibilityTraits.insert(.button)
                receipt.accessibilityHint = "RETRY".localize()
                receipt.accessibilityIdentifier = StateContract.retryControl
                receipt.addGestureRecognizer(OfflineRetryTap(target: self, action: #selector(offlineRetryTapped(_:)), message: message))
            }
        }

        guard cell.bottomView.subviews.isEmpty else { return }
        let style = Self.offlineStyle
        if !failed {
            let caption = UILabel()
            caption.text = label
            caption.font = style.notSentYetTextFont
            caption.textColor = style.notSentYetTextColor
            caption.adjustsFontForContentSizeCategory = true
            caption.numberOfLines = 0
            caption.textAlignment = UIView.userInterfaceLayoutDirection(for: caption.semanticContentAttribute) == .rightToLeft ? .left : .right
            cell.set(bottomView: caption)
            return
        }
        guard canRetry else { return }
        let button = UIButton(type: .system)
        button.setTitle(label, for: .normal)
        button.titleLabel?.font = style.retryTextFont
        button.setTitleColor(style.retryTextColor, for: .normal)
        button.contentHorizontalAlignment = .trailing
        button.accessibilityIdentifier = StateContract.retryControl
        button.accessibilityHint = "RETRY".localize()
        button.addGestureRecognizer(OfflineRetryTap(target: self, action: #selector(offlineRetryTapped(_:)), message: message))
        cell.set(bottomView: button)
    }

    @objc func offlineRetryTapped(_ tap: OfflineRetryTap) {
        guard let message = tap.message, let model = viewModel as? MessageListViewModel else { return }
        model.offlineRetry(message: message)
    }

    private static func firstReceipt(in view: UIView) -> CometChatReceipt? {
        if let receipt = view as? CometChatReceipt { return receipt }
        for sub in view.subviews { if let found = firstReceipt(in: sub) { return found } }
        return nil
    }

    // MARK: - Positioning

    /// Offline ON: a jump or start-from-unread window is painted but not yet scrolled to its anchor.
    /// Paging and live auto-scroll wait until it is (the list would land at the newest message).
    var isOfflinePositioning: Bool {
        return (viewModel as? MessageListViewModel)?.offlineIsPositioning ?? false
    }

    /// The list has scrolled to its anchor, or has none to scroll to. Ignored for a pagination
    /// anchor restore (`isPagination`), which is not a positioning step.
    func offlineEndPositioning(unlessPagination isPagination: Bool = false) {
        guard !isPagination else { return }
        (viewModel as? MessageListViewModel)?.offlineEndPositioning()
    }

    /// A jump or start-from-unread target is not cached and the server cannot answer. The chat
    /// stays on its newest page: no scroll target, no loading view waiting for one, and no unread
    /// separator or count pointing at a message that is not shown.
    func offlineDropJump() {
        gotoMessageId = 0
        startFromUnreadMessages = false
        scrolledToUnread = false
        unreadSeparatorMessageId = nil
        unreadSeparatorMode = nil
        unreadMessageCount = 0
        messageIndicator?.isHidden = true
        removeLoadingView()
    }

    // MARK: - Notices

    func bindOfflineViewModel() {
        guard let model = viewModel as? MessageListViewModel else { return }
        model.onOfflineNotice = { [weak self] notice in
            self?.showOfflineNotice(notice)
        }
        model.onOfflineJumpUnavailable = { [weak self] in
            self?.offlineDropJump()
        }
        // A read the user or app started failed online over rows on screen: the rows stay, `onError`
        // fires (D84 rule 5). A not-connected failure over rows reports nothing (rule 2).
        model.onOfflineReadFailed = { [weak self] error in
            DispatchQueue.main.async { self?.onError?(error) }
        }
        // The connection is back and the offline state reads once more (D84 rule 8).
        model.onOfflineReloadAfterError = { [weak self] in
            DispatchQueue.main.async {
                self?.removeErrorView()
                self?.showLoadingView()
            }
        }
        model.onOfflineNotConnected = { [weak self] in
            guard let self = self, !self.hideOfflineNotices else { return }
            // Past the saved messages with no connection: a "Connect to load more" row at that edge,
            // which loads the page on tap and by itself on reconnect (D84 rule 9). Not an error and not
            // a toast (BEH-READ-05). A chat with nothing saved has no row: it shows "Connect to load
            // messages" (D84 rule 3).
            var shown = false
            if model.offline.needsConnectToLoadMore {
                self.removeLoadingView()
                self.showConnectToLoadMoreFooter()
                shown = true
            }
            if model.offline.newerReadsWaitForConnection {
                self.showConnectToLoadMoreNewerRow()
                shown = true
            }
            if !shown, !self.viewModel.messages.isEmpty {
                CometChatToast.show(message: "CONNECT_TO_LOAD_MORE".localize(), on: self.controller,
                                    contractIdentifier: StateContract.notice("CONNECT_TO_LOAD_MORE"))
            }
        }
        // The connection is back: each blocked edge loads its page once by itself, as a tap on it does.
        model.onOfflineLoadOlderEdge = { [weak self] settled in
            DispatchQueue.main.async {
                guard let self = self, let model = self.viewModel as? MessageListViewModel, !model.isUIUpdating else { settled(); return }
                self.showTopSpinner()
                model.fetchPreviousMessages(completion: { DispatchQueue.main.async { settled() } })
            }
        }
        model.onOfflineLoadNewerEdge = { [weak self] in
            DispatchQueue.main.async { self?.loadNewerEdge() }
        }
        // The list is inverted: the bottom is offset 0.
        model.offlineIsAtBottom = { [weak self] in
            guard let self = self else { return true }
            return self.tableView.contentOffset.y <= 80
        }
        model.onOfflineJumpToLatest = { [weak self] in
            self?.showJumpToLatest()
        }
        // A Delete or Retry the SDK refused: today's error notice; the row is left as it was.
        model.onOfflineActionError = { [weak self] error in
            guard let self = self else { return }
            let text: String
            if OfflineErrors.isNotConnected(code: error.errorCode) {
                text = "ERROR_INTERNET_UNAVAILABLE".localize()
            } else {
                text = "SOMETHING_WENT_WRONG_ERROR".localize()
            }
            CometChatToast.show(message: text, on: self.controller,
                                contractIdentifier: StateContract.notice(OfflineErrors.isNotConnected(code: error.errorCode) ? "ERROR_INTERNET_UNAVAILABLE" : "SOMETHING_WENT_WRONG_ERROR"))
        }
    }

    // MARK: - Footer and pill

    /// "Connect to load more" at the end of the saved messages (the older edge). Tapping it reads again,
    /// and the reconnect reads that page once by itself (D84 rule 9).
    func showConnectToLoadMoreFooter() {
        let button = UIButton(type: .system)
        button.setTitle("CONNECT_TO_LOAD_MORE".localize(), for: .normal)
        button.titleLabel?.font = Self.offlineStyle.footerTextFont
        button.setTitleColor(Self.offlineStyle.footerTextColor, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        button.accessibilityIdentifier = StateContract.listFooter(.connectToLoadMore)
        button.addTarget(self, action: #selector(retryLoadMoreTapped), for: .touchUpInside)
        // The table is drawn upside down (inverted list), so its footer, which sits at the top of the
        // screen, is flipped back like the rows are.
        button.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.tableFooterView = button
    }

    @objc func retryLoadMoreTapped() {
        guard let model = viewModel as? MessageListViewModel, !model.isUIUpdating else { return }
        model.offline.needsConnectToLoadMore = false
        showTopSpinner()
        model.fetchPreviousMessages()
    }

    /// "Connect to load more" at the newest end of the saved messages (the newer edge, at the bottom of
    /// the list). Tapping it reads the newer page again, and the reconnect reads it once by itself.
    func showConnectToLoadMoreNewerRow() {
        let button = UIButton(type: .system)
        button.setTitle("CONNECT_TO_LOAD_MORE".localize(), for: .normal)
        button.titleLabel?.font = Self.offlineStyle.footerTextFont
        button.setTitleColor(Self.offlineStyle.footerTextColor, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        button.accessibilityIdentifier = StateContract.newerEdgeConnectToLoadMore
        button.addTarget(self, action: #selector(retryLoadMoreNewerTapped), for: .touchUpInside)
        // The table is drawn upside down (inverted list), so its header, which sits at the bottom of the
        // screen, is flipped back like the rows are.
        button.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.tableHeaderView = button
    }

    @objc func retryLoadMoreNewerTapped() {
        guard let model = viewModel as? MessageListViewModel, !model.isFetchingNext else { return }
        model.offline.newerReadsWaitForConnection = false
        model.offline.pendingNewerEdgeLoad = false
        loadNewerEdge()
    }

    /// Reads the newer page of a blocked newer edge, as a scroll to the bottom does.
    func loadNewerEdge() {
        guard let model = viewModel as? MessageListViewModel, !model.isFetchingNext else { return }
        if tableView.tableHeaderView?.accessibilityIdentifier == StateContract.newerEdgeConnectToLoadMore {
            tableView.tableHeaderView = nil
        }
        // Capture the scroll position before fetching, as the scroll trigger does.
        oldContentHeight = tableView.contentSize.height
        oldContentOffset = tableView.contentOffset
        oldDistanceFromTop = oldContentOffset.y
        model.fetchNextMessagesForPagination()
    }

    // MARK: - "Connect to load messages" (nothing on screen)

    /// Opened offline with nothing saved (D84 rule 3): an icon and "Connect to load messages", no Retry.
    /// The app's own error view, if it set one, shows instead. The list reads once by itself on reconnect.
    func showConnectToLoadMessages() {
        removeOfflineState()
        if hasCustomErrorStateView {
            showErrorView()
            return
        }
        if hideErrorView { return }
        let icon = UIImage(systemName: "wifi.slash")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        let stateView = StateView(title: "CONNECT_TO_LOAD_MESSAGES".localize(), subtitle: "", image: icon).withoutAutoresizingMaskConstraints()
        stateView.titleLabel.textColor = style.errorStateTitleColor
        stateView.titleLabel.font = style.errorStateTitleFont
        stateView.titleLabel.adjustsFontForContentSizeCategory = true
        stateView.imageView.tintColor = CometChatTheme.neutralColor300
        stateView.accessibilityIdentifier = StateContract.empty("connect-to-load-messages")
        addSubview(stateView)
        stateView.pin(anchors: [.centerX, .centerY], to: self)
        offlineStateView = stateView
    }

    func removeOfflineState() {
        offlineStateView?.removeFromSuperview()
        offlineStateView = nil
    }

    /// "Jump to latest": more arrived than one refresh could bridge. The reader's place is kept
    /// until they tap.
    func showJumpToLatest() {
        guard !hideOfflineNotices, offlineJumpPill == nil else { return }
        let pill = UIButton(type: .system).withoutAutoresizingMaskConstraints()
        pill.setTitle("JUMP_TO_LATEST".localize(), for: .normal)
        pill.titleLabel?.font = Self.offlineStyle.jumpToLatestTextFont
        pill.setTitleColor(Self.offlineStyle.jumpToLatestTextColor, for: .normal)
        pill.backgroundColor = Self.offlineStyle.jumpToLatestBackgroundColor
        pill.layer.cornerRadius = 16
        pill.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)
        pill.accessibilityIdentifier = StateContract.jumpToLatest
        pill.addTarget(self, action: #selector(jumpToLatestTapped), for: .touchUpInside)
        addSubview(pill)
        NSLayoutConstraint.activate([
            pill.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            pill.bottomAnchor.constraint(equalTo: tableView.bottomAnchor, constant: -12)
        ])
        offlineJumpPill = pill
    }

    @objc func jumpToLatestTapped() {
        offlineJumpPill?.removeFromSuperview()
        offlineJumpPill = nil
        (viewModel as? MessageListViewModel)?.offlineApplyLatestWindow()
        scrollToBottom()
    }

    func showOfflineNotice(_ notice: OfflineNotice) {
        guard !hideOfflineNotices else { return }
        CometChatToast.show(message: OfflineText.notice(notice), on: controller,
                            duration: OfflineText.duration(of: notice),
                            contractIdentifier: StateContract.notice(OfflineText.noticeKey(notice)))
    }

    // MARK: - State contract

    /// The contract state of a row: `sending|sent|delivered|read|failed`.
    static func contractState(for message: BaseMessage) -> String {
        switch MessageReceiptUtils.get(receiptStatus: message) {
        case .inProgress: return "sending"
        case .sent: return "sent"
        case .delivered: return "delivered"
        case .read: return "read"
        case .failed: return "failed"
        }
    }

    /// Automation identifier of a row: `cc.message.<renderKey>.<state>`. Never contains message text.
    func contractIdentifier(for message: BaseMessage, isOwn: Bool) -> String {
        let state: String
        switch MessageReceiptUtils.get(receiptStatus: message) {
        case .inProgress: state = "sending"
        case .sent: state = "sent"
        case .delivered: state = "delivered"
        case .read: state = "read"
        case .failed: state = "failed"
        }
        return StateContract.messageRow(renderKey: MessageIdentity.renderKey(message, isOwn: isOwn), state: state)
    }
}

/// A tap that carries the unsent message it retries.
final class OfflineRetryTap: UITapGestureRecognizer {
    weak var message: BaseMessage?
    init(target: Any?, action: Selector?, message: BaseMessage) {
        self.message = message
        super.init(target: target, action: action)
    }
}
