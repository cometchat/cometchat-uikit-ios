//
//  MessagePopupAnimator.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 30/09/24.
//

import UIKit
import Foundation

class MessagePopupAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    var orignalBubbleView: UIView?
    var messageBubbleView: UIView
    var isPresenting: Bool
    var originFrame: CGRect
    
    init(messageBubbleView: UIView, isPresenting: Bool, originFrame: CGRect) {
        self.messageBubbleView = messageBubbleView
        self.isPresenting = isPresenting
        self.originFrame = originFrame
    }
    
    // Animation duration
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.15 // Increased duration slightly for smoother effects
    }
    
    // Animate the transition
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
              let toVC = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        if isPresenting {
                        
            // Presenting the popup
            let finalFrame = transitionContext.finalFrame(for: toVC)
            let popupVC = toVC as! MessagePopupViewController
            popupVC.view.frame = finalFrame
            popupVC.view.alpha = 0
            
            // Add the blurred effect view with initial opacity
//            let blurView = popupVC.blurBackgroundView.snapshotView(afterScreenUpdates: true)!
//            blurView.frame = containerView.convert(popupVC.blurBackgroundView.frame, from: popupVC.view)
//            containerView.addSubview(blurView)
//            blurView.alpha = 0
            
            // Snapshot of the messageBubble
            let bubbleSnapshot = messageBubbleView.snapshotView(afterScreenUpdates: true)!
            bubbleSnapshot.frame = containerView.convert(messageBubbleView.frame, from: messageBubbleView.superview)
            containerView.addSubview(bubbleSnapshot)
            containerView.addSubview(popupVC.view)
            
            // Scale down the reaction view and hide it initially
            popupVC.reactionView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            popupVC.reactionView.alpha = 0
            
            popupVC.optionMenuTableView.transform = CGAffineTransform(translationX: 0, y: 30)
            popupVC.optionMenuTableView.alpha = 0
            
            messageBubbleView.alpha = 0

            // Animate the presentation
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                // Animate the blur effect
//                blurView.alpha = 1
                // Animate the message bubble to its final position
                bubbleSnapshot.frame = popupVC.messageSnapShotView.frame

            }, completion: { _ in
                bubbleSnapshot.removeFromSuperview()
//                blurView.removeFromSuperview()
                popupVC.view.alpha = 1
                
                // Animate the reaction view and option menu
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                    // Reaction view grows and fades in
                    popupVC.reactionView.transform = .identity
                    popupVC.reactionView.alpha = 1
                }, completion: nil)
                
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                    // Option menu fades in and slides up slightly
                    popupVC.optionMenuTableView.transform = .identity
                    popupVC.optionMenuTableView.alpha = 1
                }, completion: { _ in
                    transitionContext.completeTransition(true)
                })
            })
            
        } else {
            // Dismissing the popup
            let popupVC = fromVC as! MessagePopupViewController
            let bubbleSnapshot = popupVC.messageSnapShotView.snapshotView(afterScreenUpdates: true)!
            bubbleSnapshot.frame = popupVC.messageSnapShotView.frame
            containerView.addSubview(bubbleSnapshot)
            
            // Animate dismissing the views
            UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
                // Animate the blur view fading out
                popupVC.view.subviews.last!.alpha = 0
                // Animate the bubble snapshot back to the original message bubble position
                bubbleSnapshot.frame = self.originFrame
                popupVC.view.alpha = 0
            }, completion: { _ in
                self.orignalBubbleView?.alpha = 1
                bubbleSnapshot.removeFromSuperview()
                popupVC.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
            
            // Reaction view shrink and fade-out animation
            UIView.animate(withDuration: 0.1, animations: {
                popupVC.reactionView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                popupVC.reactionView.alpha = 0
            }, completion: nil)
            
            // Option menu fade out and slide down animation
            UIView.animate(withDuration: 0.1, delay: 0.1, animations: {
                popupVC.optionMenuTableView.transform = CGAffineTransform(translationX: 0, y: 20)
                popupVC.optionMenuTableView.alpha = 0
            }, completion: nil)
        }
    }
}
