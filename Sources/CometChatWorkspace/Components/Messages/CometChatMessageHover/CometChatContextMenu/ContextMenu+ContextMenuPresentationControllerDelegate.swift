//
//  ContextMenu+ContextMenuPresentationControllerDelegate.swift
//  ThingsUI
//
//  Created by Ryan Nystrom on 3/10/18.
//  Copyright © 2018 Ryan Nystrom. All rights reserved.
//

import UIKit

extension CometChatContextMenu: CometChatContextMenuPresentationControllerDelegate {

    func willDismiss(presentationController: CometChatContextMenuPresentationController) {
        guard item?.viewController === presentationController.presentedViewController else { return }
        item = nil
    }

}
