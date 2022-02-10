//
//  File.swift
//  ThingsUI
//
//  Created by Ryan Nystrom on 3/10/18.
//  Copyright © 2018 Ryan Nystrom. All rights reserved.
//

import UIKit

extension CometChatContextMenu {

    class Item {

        let options: Options
        let viewController: ClippedContainerViewController

        weak var sourceView: UIView?
        weak var delegate: CometChatContextMenuDelegate?

        init(
            viewController: UIViewController,
            options: Options,
            sourceView: UIView?,
            delegate: CometChatContextMenuDelegate?
            ) {
            self.viewController = ClippedContainerViewController(options: options, viewController: viewController)
            self.options = options
            self.sourceView = sourceView
            self.delegate = delegate
        }
    }

}
