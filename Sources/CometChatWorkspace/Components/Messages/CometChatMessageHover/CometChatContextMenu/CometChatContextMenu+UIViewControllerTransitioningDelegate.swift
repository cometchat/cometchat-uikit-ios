//
//  ContextMenu+UIViewControllerTransitioningDelegate.swift
//  ThingsUI
//
//  Created by Ryan Nystrom on 3/10/18.
//  Copyright © 2018 Ryan Nystrom. All rights reserved.
//

import UIKit

extension CometChatContextMenu: UIViewControllerTransitioningDelegate {

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let item = self.item else { return nil }
        return CometChatContextMenuDismissing(item: item)
    }

    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let item = self.item else { return nil }
        return CometChatContextMenuPresenting(item: item)
    }

    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        guard let item = self.item else { return nil }
        let controller = CometChatContextMenuPresentationController(presentedViewController: presented, presenting: presenting, item: item)
        controller.contextDelegate = self
        return controller
    }

}
