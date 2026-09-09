//
//  MessageList + ContextMenu.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 29/09/24.
//

import UIKit
import CometChatSDK

extension CometChatMessageList: UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {
    
    func setupContextMenu( for cell: CometChatMessageBubble, message: BaseMessage) {
                
        //Doing this for context Menu
        if contextMenuMessage?.id == message.id {
            contextMenuCell?.bubbleStackView.alpha = 1
            cell.bubbleStackView.alpha = 0
            contextMenuMessage = message
            contextMenuCell = cell
        }

        // Adding this for Context Menu
        // Captured strongly: the view model array is the only strong owner of a
        // BaseMessage, so an action that swaps the element (pin/save) deallocates the
        // old instance and a weak capture here would nil out, silently killing the
        // next long press on this row.
        let boundMessage = message
        cell.onLongPressGestureRecognized = { [weak self, weak cell] in
            guard let self, let cell else { return }
            // Prefer the cell's current message — `updateReceiptAtIndex` re-points it
            // via `set(message:)` without re-running this setup, so the captured copy
            // can be stale.
            let message = cell.baseMessage ?? boundMessage

            let isModerated = MessageUtils.isMessageModerationDisapproved(message: message)
            // Only apply error checks to actual messages, not action messages (like "user added to group")
            let isError = message.metaData?["error"] as? Bool == true && message.messageCategory == .message
            let isRBACError = message.metaData?["rbac_permission_denied"] as? Bool == true && message.messageCategory == .message
            
            // Block context menu for RBAC errors and error messages
            if isRBACError || isError {
                return
            }
            
            if message.deletedAt == 0,
               message.id > 0,
               !isContextMenuActive,
               !isModerated
            {
                self.controller?.view.endEditing(true)
                isContextMenuActive = true
                // Built from the same message the guards above validated. Passing
                // `cell.baseMessage` here instead would let the eligibility checks and the
                // option list disagree whenever the two have diverged — the options would
                // be derived from a message that was never checked.
                let options = viewModel.getTemplate(for: message)?.options?(message, viewModel.group, controller)
                self.contextMenuMessage = message
                self.contextMenuCell = cell
                self.onCellLongPressGestureRecognized(message: message, cell: cell, option: options ?? [], messageAlignment: cell.alignment)
            }
        }
        
    }
    
    func onCellLongPressGestureRecognized(message: BaseMessage, cell: CometChatMessageBubble, option: [CometChatMessageOption], messageAlignment: MessageBubbleAlignment) {
        
        let popupView = MessagePopupViewController()
        popupView.baseMessage = contextMenuMessage
        popupView.messageOptionDelegate = self
        popupView.messageAlignment = messageAlignment
        popupView.messageSnapShotView = cell.bubbleStackView.snapshotView(afterScreenUpdates: true)
        popupView.messageOptions = option
        if let controller = controller {
            var screenFrame = cell.bubbleStackView.convert(cell.bubbleStackView.bounds, to: controller.view)
            if UIDevice.current.userInterfaceIdiom == .pad {
                if let window = cell.bubbleStackView.window {
                    screenFrame = cell.bubbleStackView.convert(cell.bubbleStackView.bounds, to: window)
                }
            }
            popupView.bubbleFrame = screenFrame
        }
        
        //Preparing Emoji Keyboard
        popupView.emojiKeyboard
            .setOnClick { [weak self, weak popupView] emoji in
                guard let self = self else { return }

                //adding haptic feedback
                addHapticFeedback()
                reactToMessage(baseMessage: cell.baseMessage, reaction: emoji.emoji)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    popupView?.dismiss(animated: true)
                })
            }
        
        //Preparing Quick Reaction
        popupView.reactionView
            .set(onAddReactionIconTapped: { [weak self, weak popupView] in
                guard let self = self else { return }
                
                //adding haptic feedback
                addHapticFeedback()
                popupView?.openEmojiKeyboard()
            })
            .set(onReacted: { [weak self, weak popupView] reaction in
                guard let self = self else { return }
                guard let reaction = reaction else { return }
                
                addHapticFeedback()
                self.reactToMessage(baseMessage: cell.baseMessage, reaction: reaction)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                    popupView?.dismiss(animated: true)
                })
            })
            .set(configuration: quickReactionsConfiguration)
        
        
        popupView.buildUI()
        // Only apply error checks to actual messages, not action messages (like "user added to group")
        let isErrorMessage = message.metaData?["error"] as? Bool == true && message.messageCategory == .message
        let isRBACErrorMessage = message.metaData?["rbac_permission_denied"] as? Bool == true && message.messageCategory == .message
        popupView.reactionView.isHidden = (hideReactionOption || MessageUtils.isMessageModerationDisapproved(message: message) || (message is AIAssistantMessage) || isErrorMessage || isRBACErrorMessage)
        popupView.modalPresentationStyle = .overFullScreen
        popupView.transitioningDelegate = self
        popupView.onDismissed = { [weak self] in
            self?.resetContextMenuState()
        }
        controller?.present(popupView, animated: true)

    }

    /// Single owner of the context-menu teardown. Previously this lived inside
    /// `animationController(forDismissed:)`, which is skipped whenever no animator is
    /// returned — leaving `isContextMenuActive` latched and blocking every later long press.
    func resetContextMenuState() {
        // The bubble is hidden while the popup shows its snapshot; restore it here so a
        // cell can never be left invisible if the dismiss animation didn't run.
        contextMenuCell?.bubbleStackView.alpha = 1
        contextMenuCell = nil
        contextMenuMessage = nil
        isContextMenuActive = false
    }
    
    func addHapticFeedback() {
        //adding haptic feedback
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()

    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        guard let presented = presented as? MessagePopupViewController,
              let bubbleStackView = contextMenuCell?.bubbleStackView else { return nil }
        return MessagePopupAnimator(messageBubbleView: bubbleStackView, isPresenting: true, originFrame: presented.bubbleFrame)
    }

    /// Returns nil — falling back to a plain cross-dissolve — when the originating cell is
    /// gone. That happens whenever the chosen option reloaded the row (pin/save), so the
    /// cell must not be force-unwrapped here. State teardown is `resetContextMenuState()`'s
    /// job, not this method's.
    public func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        guard let dismissed = dismissed as? MessagePopupViewController,
              let controller = controller,
              let bubbleStackView = contextMenuCell?.bubbleStackView else { return nil }

        var cellCurrentFrame = bubbleStackView.convert(bubbleStackView.bounds, to: controller.view)
        if UIDevice.current.userInterfaceIdiom == .pad {
            if let window = bubbleStackView.window {
                cellCurrentFrame = bubbleStackView.convert(bubbleStackView.bounds, to: window)
            }
        }

        let animationClass = MessagePopupAnimator(messageBubbleView: dismissed.messageSnapShotView, isPresenting: false, originFrame: cellCurrentFrame)
        animationClass.orignalBubbleView = bubbleStackView
        return animationClass
    }

    
}

