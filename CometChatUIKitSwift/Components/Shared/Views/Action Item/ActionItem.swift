//
//  ActionItem.swift
 
//
//  Created by Pushpsen Airekar on 06/05/22.
//

import Foundation
import UIKit
import CometChatSDK

public class ActionItem: NSObject {
    
    public var id: String
    public var text: String?
    public var leadingIcon: UIImage?
    public var trailingView: UIView?
    public var onActionClick: (() -> ())?
    public var style: ActionSheetStyle? = CometChatActionSheet.style

    public init(id: String, text: String?, leadingIcon: UIImage? = nil, trailingView: UIView? = nil, onActionClick: (() -> ())? = nil){
        self.id = id
        self.text = text
        self.leadingIcon = leadingIcon
        self.trailingView = trailingView
        self.onActionClick = onActionClick
    }
}

