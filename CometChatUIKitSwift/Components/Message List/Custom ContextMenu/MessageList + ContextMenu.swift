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
        
        //Adding this for Context Menu
        cell.onLongPressGestureRecognized = { [weak self, weak cell, weak message] in
            if let self,
               let cell,
               let message,
               let options = viewModel.getTemplate(for: message)?.options?(cell.baseMessage, viewModel.group, controller),
               !options.isEmpty,
               message.deletedAt == 0
            {
                self.contextMenuMessage = message
                self.contextMenuCell = cell
                self.onCellLongPressGestureRecognized(cell: cell, option: options, messageAlignment: cell.alignment)
            }
        }
        
    }
    
    func onCellLongPressGestureRecognized(cell: CometChatMessageBubble, option: [CometChatMessageOption], messageAlignment: MessageBubbleAlignment) {
        
        let popupView = MessagePopupViewController()
        popupView.baseMessage = contextMenuMessage
        popupView.messageOptionDelegate = self
        popupView.messageAlignment = messageAlignment
        popupView.messageSnapShotView = cell.bubbleStackView.snapshotView(afterScreenUpdates: true)
        popupView.messageOptions = option
        if let controller = controller {
            let screenFrame = cell.bubbleStackView.convert(cell.bubbleStackView.bounds, to: controller.view)
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
        popupView.modalPresentationStyle = .overFullScreen
        popupView.transitioningDelegate = self
        controller?.present(popupView, animated: true)
        
    }
    
    func addHapticFeedback() {
        //adding haptic feedback
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
        impactFeedbackGenerator.prepare()
        impactFeedbackGenerator.impactOccurred()

    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        if let presented = presented as? MessagePopupViewController {
            let animationClass = MessagePopupAnimator(messageBubbleView: contextMenuCell!.bubbleStackView, isPresenting: true, originFrame: presented.bubbleFrame)
            return animationClass
        }
        return nil
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        if let dismissed = dismissed as? MessagePopupViewController {
            if let controller = controller {
                let cellCurrentFrame = contextMenuCell!.bubbleStackView.convert(contextMenuCell!.bubbleStackView.bounds, to: controller.view)
                let animationClass = MessagePopupAnimator(messageBubbleView: dismissed.messageSnapShotView, isPresenting: false, originFrame: cellCurrentFrame)
                animationClass.orignalBubbleView = contextMenuCell!.bubbleStackView
                self.contextMenuCell = nil
                self.contextMenuMessage = nil
                return animationClass
            }
        }
        return nil
    }

    
}

