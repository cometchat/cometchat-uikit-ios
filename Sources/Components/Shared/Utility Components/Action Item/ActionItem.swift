//
//  ActionItem.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 06/05/22.
//

import Foundation
import UIKit

public class ActionItem: NSObject {
    
    var id: String?
    var text: String?
    var startIcon: UIImage?
    var endIcon: UIImage?
    var startIconTint: UIColor?
    var endIconTint: UIColor?
    var textColor: UIColor?
    var textFont: UIFont?
    
    init(id: String?, text: String?, icon: UIImage?, textColor: UIColor?, textFont: UIFont?, startIconTint: UIColor?) {
        self.id = id
        self.text = text
        self.startIcon = icon
        self.startIconTint = startIconTint
        self.textColor = textColor
        self.textFont = textFont
    }
    
    init(id: String?, text: String?, startIcon: UIImage?, endIcon: UIImage?, startIconTint: UIColor?, endIconTint: UIColor?, textColor: UIColor?, textFont: UIFont?) {
        self.id = id
        self.text = text
        self.startIcon = startIcon
        self.endIcon = endIcon
        self.startIconTint = startIconTint
        self.endIconTint = endIconTint
        self.textColor = textColor
        self.textFont = textFont
    }
}

