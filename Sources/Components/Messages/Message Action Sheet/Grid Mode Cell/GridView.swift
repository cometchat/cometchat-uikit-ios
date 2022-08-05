//
//  GridView.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 01/11/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit

class GridView: UICollectionViewCell {

    @IBOutlet weak var tintView: UIView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    
    @discardableResult
    public func set(actionItem: ActionItem) -> GridView {
        self.actionItem = actionItem
        return self
    }
    
    var actionItem: ActionItem? {
        didSet {
            if let actionItem = actionItem {
                
                self.tintView.backgroundColor = CometChatTheme.palatte?.background ?? .systemFill
                
                self.title.text = actionItem.text

                if let startIcon = actionItem.startIcon {
                    self.icon.isHidden = false
                    self.icon.image = startIcon.withRenderingMode(.alwaysTemplate)
                }
                
                if let startIconTint = actionItem.startIconTint {
                    self.icon.tintColor = startIconTint
                    
                }
                
                if let textColor = actionItem.textColor {
                    self.title.textColor = textColor
                }
                
                if let textFont = actionItem.textFont {
                    self.title.font = UIFont(name: textFont.familyName, size: textFont.pointSize - 3)
                }
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
