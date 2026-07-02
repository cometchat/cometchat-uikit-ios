//
//  MessageList + GoToMessage.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 26/11/25.
//

import Foundation
import UIKit

enum UnreadSeparatorMode {
    case markAsUnread
    case navigateFromConversation
}

extension CometChatMessageList {

    public func goToMessage(withId id: Int, highlight: Bool = true) {
        guard id != 0 else { return }

        gotoMessageId = id

        if viewModel.isMessageAlreadyLoaded(id) {

            DispatchQueue.main.async {
                self.scrollToMessage(withId: id, isPagination: !highlight)
            }
            return
        }

        showLoadingView()
        viewModel.goToMessage(messageId: id)
    }

}

extension CometChatMessageList {
    func scrollToMessage(withId id: Int, isPagination: Bool = false, completion: ((Int) -> Void)? = nil) {
        guard id != 0 else { return }

//        guard let indexPath = visibleIndexPath(forMessageId: id) else { return }
        guard let indexPath = tableViewIndexPath(forMessageId: id) else { return }


        if isPagination {
            completion?(id)
            return
        }

        pendingHighlightMessageId = id
        highlightRetryCount = 15     // Try up to 15 frames to stabilize

        // Scroll instantly
        UIView.performWithoutAnimation {
            tableView.scrollToRow(at: indexPath, at: .none, animated: false)
            tableView.layoutIfNeeded()
        }

        // Begin stabilization loop
        attemptHighlight()
    }
    
    private func attemptHighlight() {
        guard let id = pendingHighlightMessageId else { return }

        // Safety stop if too many retries
//        if highlightRetryCount <= 0 {
//            applyHighlight(for: id)
//            pendingHighlightMessageId = nil
//            return
//        }

        highlightRetryCount -= 1

        // Check if the target cell is stable and visible
        guard let indexPath = tableViewIndexPath(forMessageId: id),
              let cell = tableView.cellForRow(at: indexPath),
              cell.window != nil,
              cell.bounds.height > 10 else
        {
            // Try on the next frame
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
                self.attemptHighlight()
            }
            return
        }

        // Cell is ready → highlight it
//        applyHighlight(for: id)
//        applyHighlight(at: indexPath)
//
        runWhenTableViewIsStable { [weak self] in
            self?.applyHighlight(messageId: id)
        }
        pendingHighlightMessageId = nil
    }
    
    func runWhenTableViewIsStable(_ block: @escaping () -> Void) {
        var previousContentSize = CGSize.zero
        var checksRemaining = 10  // ~150ms max

        func check() {
            let current = tableView.contentSize
            if current == previousContentSize && checksRemaining <= 0 {
                block()
                return
            }
            previousContentSize = current
            checksRemaining -= 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.015, execute: check)
        }

        check()
    }

    
    static var currentHighlightedCell: UITableViewCell?
    static var currentHighlightOverlay: UIView?
    static var currentHighlightAnimator: UIViewPropertyAnimator?
    
    func applyHighlight(messageId: Int) {
        var highlightToken = UUID()
        let token = highlightToken

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            guard token == highlightToken else { return }

            guard
                let indexPath = self.tableViewIndexPath(forMessageId: messageId),
                let cell = self.tableView.cellForRow(at: indexPath),
                let rawIP = self.viewModel.indexPathForMessageId(messageId), let msg = self.viewModel.messageAt(indexPath: rawIP),
                msg.id == messageId
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.016) {
                    self.applyHighlight(messageId: messageId)
                }
                return
            }

            highlightToken = UUID() // ✅ consume token
            self.showHighlight(on: cell)
        }
    }
    
    private func showHighlight(on cell: UITableViewCell) {
        // Remove any existing highlight on this cell
        cell.contentView.subviews
            .filter { $0.tag == 9999 }
            .forEach { $0.removeFromSuperview() }

        let overlay = UIView(frame: cell.contentView.bounds)
        overlay.tag = 9999
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.isUserInteractionEnabled = false
        overlay.backgroundColor = CometChatTheme.primaryColor.withAlphaComponent(0)

        cell.contentView.addSubview(overlay)

        let fadeIn = UIViewPropertyAnimator(duration: 0.30, curve: .easeIn) {
            overlay.backgroundColor = CometChatTheme.primaryColor.withAlphaComponent(0.25)
        }

        fadeIn.addCompletion { _ in
            let fadeOut = UIViewPropertyAnimator(duration: 0.45, curve: .easeOut) {
                overlay.backgroundColor = .clear
            }

            fadeOut.addCompletion { _ in
                overlay.removeFromSuperview()
            }

            fadeOut.startAnimation()
        }

        fadeIn.startAnimation()
    }


}

extension CometChatMessageList {
    
    // MARK: - Anchor snapshot helpers for fetchNext pagination
    struct AnchorSnapshot {
        let messageId: Int?
        let oldOffsetY: CGFloat
        let oldContentHeight: CGFloat
        /// distance from tableView.contentOffset.y to the cell origin.y at capture time
        let distanceFromTop: CGFloat?
    }
    
    func captureAnchorBeforeFetchNext() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            let oldOffsetY = self.tableView.contentOffset.y
            let oldContentHeight = self.tableView.contentSize.height

            // Prefer top visible message id as anchor (fallbacks handled later)
            var anchorMessageId: Int? = nil
            if let topVisibleIndexPath = self.tableView.indexPathsForVisibleRows?.first {
                if let msg = self.viewModel.messageAt(indexPath: topVisibleIndexPath) {
                    anchorMessageId = msg.id
                }
            } else {
                // fallback: try VM-provided capture (if exists)
                if let id = self.viewModel.captureAnchorMessageId?() {
                    anchorMessageId = id
                }
            }

            var distanceFromTop: CGFloat? = nil
            if let id = anchorMessageId, let ip = self.tableViewIndexPath(forMessageId: id) {
                let rect = self.tableView.rectForRow(at: ip)
                distanceFromTop = rect.origin.y - oldOffsetY
            }

            self.fetchNextAnchorSnapshot = AnchorSnapshot(
                messageId: anchorMessageId,
                oldOffsetY: oldOffsetY,
                oldContentHeight: oldContentHeight,
                distanceFromTop: distanceFromTop
            )

            // UI lock while fetching to avoid user interaction interfering
            self.showBottomSpinner()
            self.tableView.isScrollEnabled = false
        }
    }

    func restoreAnchorAfterFetchNext(oldOffsetY: CGFloat, oldContentHeight: CGFloat) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            // Ensure table has rebuilt layout before computing rects
            UIView.performWithoutAnimation {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
            }

            // If we captured a snapshot with an anchor id, prefer that method:
            if let snap = self.fetchNextAnchorSnapshot, let anchorId = snap.messageId, anchorId > 0 {
                if let newIndexPath = self.tableViewIndexPath(forMessageId: anchorId) {
                    // anchor still exists — compute rect and restore original distance
                    let newRect = self.tableView.rectForRow(at: newIndexPath)
                    if let distance = snap.distanceFromTop {
                        var targetOffsetY = newRect.origin.y - distance

                        // clamp
                        let minOffsetY: CGFloat = -self.tableView.adjustedContentInset.top
                        let maxOffsetY: CGFloat = max(0, self.tableView.contentSize.height - self.tableView.bounds.height + self.tableView.adjustedContentInset.bottom)
                        if targetOffsetY < minOffsetY { targetOffsetY = minOffsetY }
                        if targetOffsetY > maxOffsetY { targetOffsetY = maxOffsetY }

                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        UIView.performWithoutAnimation {
                            self.tableView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: false)
                            self.tableView.layer.removeAllAnimations()
                        }
                        CATransaction.commit()

                        self.hideBottomSpinner()
                        self.tableView.isScrollEnabled = true
                        self.fetchNextAnchorSnapshot = nil
                        return
                    }
                    // if distance is nil, fall through to delta fallback
                }

                // anchor not found / changed — fallback to contentHeight delta
                let delta = self.tableView.contentSize.height - snap.oldContentHeight
                var targetOffsetY = snap.oldOffsetY + delta

                let minOffsetY: CGFloat = -self.tableView.adjustedContentInset.top
                let maxOffsetY: CGFloat = max(0, self.tableView.contentSize.height - self.tableView.bounds.height + self.tableView.adjustedContentInset.bottom)
                if targetOffsetY < minOffsetY { targetOffsetY = minOffsetY }
                if targetOffsetY > maxOffsetY { targetOffsetY = maxOffsetY }

                CATransaction.begin()
                CATransaction.setDisableActions(true)
                UIView.performWithoutAnimation {
                    self.tableView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: false)
                    self.tableView.layer.removeAllAnimations()
                }
                CATransaction.commit()

                self.hideBottomSpinner()
                self.tableView.isScrollEnabled = true
                self.fetchNextAnchorSnapshot = nil
                return
            }

            // No snapshot at all — fallback to the metrics passed in (contentHeight delta)
            let delta = self.tableView.contentSize.height - oldContentHeight
            var targetOffsetY = oldOffsetY + delta

            let minOffsetY: CGFloat = -self.tableView.adjustedContentInset.top
            let maxOffsetY: CGFloat = max(0, self.tableView.contentSize.height - self.tableView.bounds.height + self.tableView.adjustedContentInset.bottom)
            if targetOffsetY < minOffsetY { targetOffsetY = minOffsetY }
            if targetOffsetY > maxOffsetY { targetOffsetY = maxOffsetY }

            CATransaction.begin()
            CATransaction.setDisableActions(true)
            UIView.performWithoutAnimation {
                self.tableView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: false)
                self.tableView.layer.removeAllAnimations()
            }
            CATransaction.commit()

            self.hideBottomSpinner()
            self.tableView.isScrollEnabled = true
            self.fetchNextAnchorSnapshot = nil
        }
    }
    
    /// Restore to messageId without visible blink. Centers the cell in the table view.
    func restoreAnchorWithoutBlink(messageId: Int) {
        // 1) reload and force layout synchronously so we get correct rects
        UIView.performWithoutAnimation {
            self.tableView.reloadData()
            self.tableView.layoutIfNeeded()
        }

        // 2) find index path for message
        guard let indexPath = tableViewIndexPath(forMessageId: messageId) else { return }

        // 3) get cell rect (in table's coordinate space)
        let rowRect = tableView.rectForRow(at: indexPath)

        // 4) compute desired offset to place cell in the middle of visible bounds
        //    desiredOffsetY = rowRect.midY - (tableView.bounds.height / 2)
        var desiredOffsetY = rowRect.midY - (tableView.bounds.height * 0.5)

        // 5) clamp to valid contentOffset range so we don't overshoot
        let minOffsetY: CGFloat = -tableView.contentInset.top
        let maxOffsetY: CGFloat = tableView.contentSize.height - tableView.bounds.height + tableView.contentInset.bottom

        if desiredOffsetY < minOffsetY { desiredOffsetY = minOffsetY }
        if desiredOffsetY > maxOffsetY { desiredOffsetY = maxOffsetY }

        // 6) set without animation and without layer actions — this prevents any blink
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        UIView.performWithoutAnimation {
            self.tableView.setContentOffset(CGPoint(x: 0, y: desiredOffsetY), animated: false)
            // defensive: remove any lingering animations on the layer
            self.tableView.layer.removeAllAnimations()
        }
        CATransaction.commit()
//        hideBottomSpinner()
//        tableView.isScrollEnabled = true
    }

    
    func getTopVisibleMessageId() -> Int? {
        guard let visible = tableView.indexPathsForVisibleRows,
              !visible.isEmpty else { return nil }

        // In an inverted UITableView, the visually "top" cell is the one
        // with the *highest contentOffset relative position*, which corresponds
        // to the smallest section, then smallest row.
        //
        // Example:
        // Section 0, Row 0  → newest
        // Section N, Row M  → oldest
        //
        // Visually top = Section0/Row0, not the lowest section.
        
        let topIndexPath = visible.min { a, b in
            if a.section != b.section { return a.section < b.section }
            return a.row < b.row
        }

        guard let ip = topIndexPath else { return nil }

        // Retrieve the message from your view model
        return viewModel.messageAt(indexPath: ip)?.id
    }

}


// Swift
extension CometChatMessageList {

    // Safe highlight: add non-interactive overlay inside the cell's contentView and animate its alpha.
    func applyHighlightSafely(to cell: CometChatMessageBubble, color: UIColor = UIColor.systemYellow.withAlphaComponent(0.35), duration: TimeInterval = 1.2) {
        DispatchQueue.main.async {
            // Remove any previous highlight overlay
            let overlayTag = 0xF00D_BABE
            cell.contentView.viewWithTag(overlayTag)?.removeFromSuperview()

            // Create overlay
            let overlay = UIView()
            overlay.tag = overlayTag
            overlay.isUserInteractionEnabled = false
            overlay.backgroundColor = color
            overlay.alpha = 0.0
            overlay.translatesAutoresizingMaskIntoConstraints = false
            overlay.layer.masksToBounds = true

            // Corner radius should match bubble shape if needed; keep small radius to avoid layout changes
            overlay.layer.cornerRadius = 8

            cell.contentView.addSubview(overlay)
            NSLayoutConstraint.activate([
                overlay.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
                overlay.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
                overlay.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                overlay.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])

            // Animate only alpha to avoid mutating transforms/constraints
            UIView.animate(withDuration: 0.12, animations: {
                overlay.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: duration, delay: 0.4, options: [], animations: {
                    overlay.alpha = 0.0
                }, completion: { _ in
                    overlay.removeFromSuperview()
                })
            })
        }
    }
}
