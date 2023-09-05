//
//  ActionItem.swift
 
//
//  Created by Pushpsen Airekar on 06/05/22.
//

import Foundation
import UIKit
import CometChatSDK

public class ActionItem: NSObject {
    
    var id: String
    var text: String?
    var leadingIcon: UIImage?
    var trailingView: UIView?
    var onActionClick: (() -> ())?
    var style: ActionItemStyle?

    init(id: String, text: String?, leadingIcon: UIImage?, trailingView: UIView? = nil, style: ActionItemStyle? = ActionItemStyle(), onActionClick: (() -> ())? = nil){
        self.id = id
        self.text = text
        self.leadingIcon = leadingIcon
        self.trailingView = trailingView
        self.style = style
        self.onActionClick = onActionClick
    }
}

