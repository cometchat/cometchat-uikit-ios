//
//  CometChatMessageComposerAction.swift
//  
//
//  Created by Ajay Verma on 22/12/22.
//

import Foundation
import UIKit

public class CometChatMessageComposerAction: NSObject {
    
    var id: String?
    var text: String?
    var startIcon: UIImage?
    var endIcon: UIImage?
    var startIconTint: UIColor?
    var endIconTint: UIColor?
    var textColor: UIColor?
    var textFont: UIFont?
    var onActionClick: (() -> ())?
        
    //Initialiser for default options
   public init(id: String?, text: String?, startIcon: UIImage?, endIcon: UIImage? = nil, startIconTint: UIColor? , endIconTint: UIColor? = nil, textColor: UIColor?, textFont: UIFont?,onActionClick: (() -> ())? = nil) {
        self.id = id
        self.text = text
        self.startIcon = startIcon
        self.endIcon = endIcon
        self.startIconTint = startIconTint
        self.endIconTint = endIconTint
        self.textColor = textColor
        self.textFont = textFont
        self.onActionClick = onActionClick
    }
}
