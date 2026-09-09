//
//  PinnedMessages + ContextMenu.swift
//  CometChatUIKitSwift
//

import UIKit
import CometChatSDK

extension CometChatPinnedMessages: UIViewControllerTransitioningDelegate {

    /// Options this surface offers. Excludes anything that composes a new message.
    ///
    /// Order matches the design: Info, Copy, Unpin, Stop notifications, Delete.
    ///
    /// Deliberately excludes the thread-subscription option. It reads
    /// `message.threadSubscribed`, which is only populated on a *fetched* message: a row
    /// pinned in realtime arrives over the websocket without the flag and reads `false`,
    /// so the control would render the wrong state with no parent held here to correct it
    /// from. Offering a toggle that can silently show "not following" for a followed
    /// thread is worse than not offering it, so this surface omits it entirely.
    static var allowedOptionIds: [String] {
        [
            MessageOptionConstants.messageInformation,
            MessageOptionConstants.copyMessage,
            MessageOptionConstants.unpinMessage,
            MessageOptionConstants.deleteMessage
        ]
    }

    /// Ordered by `allowedOptionIds`, not by producer order.
    func pinnedMessageOptions(for message: BaseMessage) -> [CometChatMessageOption] {
        guard !hideMessageOptions else { return [] }

        let produced = viewModel.getTemplate(for: message)?
            .options?(message, viewModel.group, self) ?? []

        var options = Self.allowedOptionIds.compactMap { id in
            produced.first { $0.id == id }
        }

        // The data source only emits unpin when pin/save is enabled. Slot it by its rank in
        // `allowedOptionIds` — a fixed index drifts whenever an earlier option is absent.
        if !hideUnpinOption, !options.contains(where: { $0.id == MessageOptionConstants.unpinMessage }) {
            let rank = Self.allowedOptionIds.firstIndex(of: MessageOptionConstants.unpinMessage) ?? 0
            let insertion = options.firstIndex { option in
                (Self.allowedOptionIds.firstIndex(of: option.id) ?? .max) > rank
            } ?? options.count
            options.insert(unpinOption(), at: insertion)
        }
        if hideUnpinOption {
            options.removeAll { $0.id == MessageOptionConstants.unpinMessage }
        }
        return options
    }

    private func unpinOption() -> CometChatMessageOption {
        CometChatMessageOption(
            id: MessageOptionConstants.unpinMessage,
            title: "UNPIN_MESSAGE".localize(),
            icon: AssetConstants.unpinMessage
        )
    }

    // MARK: - Long press

    /// `boundMessage` is captured strongly: `cell.baseMessage` is weak, so an action
    /// that swaps the element would nil it and kill the next press.
    func setupContextMenu(for cell: CometChatMessageBubble, message: BaseMessage) {
        // The presenting animator drops the bubble to alpha 0 and never restores it.
        if contextMenuMessage?.id == message.id {
            contextMenuCell?.bubbleStackView.alpha = 1
            cell.bubbleStackView.alpha = 0
            contextMenuMessage = message
            contextMenuCell = cell
        } else {
            // A reused cell can carry the hidden alpha from a previous row.
            cell.bubbleStackView.alpha = 1
        }

        let boundMessage = message
        cell.onLongPressGestureRecognized = { [weak self, weak cell] in
            guard let self, let cell else { return }
            let message = cell.baseMessage ?? boundMessage

            guard message.deletedAt == 0,
                  message.id > 0,
                  !self.isContextMenuActive,
                  !MessageUtils.isMessageModerationDisapproved(message: message) else { return }

            let options = self.pinnedMessageOptions(for: message)
            guard !options.isEmpty else { return }

            self.view.endEditing(true)
            self.isContextMenuActive = true
            self.contextMenuMessage = message
            self.contextMenuCell = cell
            self.presentContextMenu(message: message, cell: cell, options: options)
        }
    }

    private func presentContextMenu(
        message: BaseMessage,
        cell: CometChatMessageBubble,
        options: [CometChatMessageOption]
    ) {

        let popupView = MessagePopupViewController()
        popupView.baseMessage = message
        popupView.messageOptionDelegate = self
        popupView.messageAlignment = cell.alignment
        popupView.messageSnapShotView = cell.bubbleStackView.snapshotView(afterScreenUpdates: true)
        // Unpin is an overflow id; without this it hides behind "More".
        popupView.splitsOverflow = false
        popupView.messageOptions = options

        var screenFrame = cell.bubbleStackView.convert(cell.bubbleStackView.bounds, to: view)
        if UIDevice.current.userInterfaceIdiom == .pad, let window = cell.bubbleStackView.window {
            screenFrame = cell.bubbleStackView.convert(cell.bubbleStackView.bounds, to: window)
        }
        popupView.bubbleFrame = screenFrame

        // Without this the popup presents with no subviews — invisible, but still
        // swallowing every touch.
        popupView.buildUI()

        popupView.reactionView.isHidden = true
        popupView.modalPresentationStyle = .overFullScreen
        popupView.transitioningDelegate = self
        popupView.onDismissed = { [weak self] in
            self?.resetContextMenuState()
        }
        present(popupView, animated: true)
    }

    /// Single owner of the teardown; the dismiss animator is skipped once a row is removed.
    func resetContextMenuState() {
        contextMenuCell?.bubbleStackView.alpha = 1
        contextMenuCell = nil
        contextMenuMessage = nil
        isContextMenuActive = false
    }

    // MARK: - Transitions

    public func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {

        guard let presented = presented as? MessagePopupViewController,
              let bubbleStackView = contextMenuCell?.bubbleStackView else { return nil }
        return MessagePopupAnimator(messageBubbleView: bubbleStackView, isPresenting: true, originFrame: presented.bubbleFrame)
    }

    /// nil — a cross-dissolve — once the cell is gone, as unpin and delete both leave it.
    public func animationController(
        forDismissed dismissed: UIViewController
    ) -> (any UIViewControllerAnimatedTransitioning)? {

        guard let dismissed = dismissed as? MessagePopupViewController,
              let bubbleStackView = contextMenuCell?.bubbleStackView else { return nil }

        var cellCurrentFrame = bubbleStackView.convert(bubbleStackView.bounds, to: view)
        if UIDevice.current.userInterfaceIdiom == .pad, let window = bubbleStackView.window {
            cellCurrentFrame = bubbleStackView.convert(bubbleStackView.bounds, to: window)
        }

        let animator = MessagePopupAnimator(messageBubbleView: dismissed.messageSnapShotView, isPresenting: false, originFrame: cellCurrentFrame)
        animator.orignalBubbleView = bubbleStackView
        return animator
    }
}

// MARK: - Option handling
extension CometChatPinnedMessages: CometChatMessageOptionDelegate {

    func onItemClick(messageOption: CometChatMessageOption, forMessage: BaseMessage?, indexPath: IndexPath?) {
        guard let message = forMessage else { return }

        // An option carrying its own handler is an app-side takeover; run it instead.
        guard messageOption.onItemClick == nil else {
            messageOption.onItemClick?(message)
            return
        }

        switch messageOption.id {
        case MessageOptionConstants.unpinMessage:
            // The panel's own unpin: removes the row, restores it on failure.
            PinSaveConfirmation.present(.unpinMessage, on: self) { [weak self] in
                self?.viewModel.unpin(message: message)
            }

        case MessageOptionConstants.copyMessage:
            didCopyPressed(message: message)

        case MessageOptionConstants.messageInformation:
            didMessageInformationClicked(message: message)

        case MessageOptionConstants.deleteMessage:
            confirmDelete(message: message)

        default:
            break
        }
    }

    private func didCopyPressed(message: BaseMessage) {
        guard let text = message as? TextMessage else { return }
        let formatted = MessageUtils.processTextFormatter(
            message: text,
            textFormatter: viewModel.textFormatters,
            formattingType: .MESSAGE_BUBBLE
        )
        UIPasteboard.general.string = formatted.string
    }

    private func didMessageInformationClicked(message: BaseMessage) {
        let informationController = CometChatMessageInformation()
        informationController.dateTimeFormatter = dateTimeFormatter
        informationController.set(message: message)

        if let indexPath = viewModel.indexPath(for: message.id),
           let cell = tableView.cellForRow(at: indexPath) as? CometChatMessageBubble {
            informationController.bubbleSnapshotView = cell.bubbleStackView.snapshotView(afterScreenUpdates: true)
        }

        let navigationController = UINavigationController(rootViewController: informationController)
        present(navigationController, animated: true)
    }

    private func confirmDelete(message: BaseMessage) {
        let alert = UIAlertController(
            title: nil,
            message: "DELETE_MESSAGE_SUBTITLE".localize(),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: ConversationConstants.delete, style: .destructive) { [weak self] _ in
            self?.viewModel.delete(message: message)
        })
        alert.addAction(UIAlertAction(title: "CANCEL".localize(), style: .cancel))
        present(alert, animated: true)
    }
}
