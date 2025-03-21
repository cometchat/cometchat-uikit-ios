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
    
    var actionSheetStyle = ActionSheetStyle()
    
    var actionItem: ActionItem? {
        didSet {
            set(style: actionSheetStyle)
            if let actionItem = actionItem {
                self.tintView.backgroundColor = CometChatTheme_v4.palatte.background
                self.title.text = actionItem.text
                if let startIcon = actionItem.leadingIcon {
                    self.icon.isHidden = false
                    self.icon.image = startIcon.withRenderingMode(.alwaysTemplate)
                }
                if let leadingIconTint = actionItem.style?.leadingIconTint {
                    self.icon.tintColor = leadingIconTint
                }
                if let titleColor = actionItem.style?.titleColor {
                    self.title.textColor = titleColor
                }
                if let titleFont = actionItem.style?.titleFont {
                    self.title.font = UIFont(name: titleFont.familyName, size: titleFont.pointSize - 3)
                }
            }
        }
    }
    
    private func set(style: ActionSheetStyle) {
        set(listItemIconTint: style.listItemIconTint)
        set(listItemTitleFont: style.listItemTitleFont)
        set(listItemTitleColor: style.listItemTitleColor)
        set(listItemIconBackground: style.listItemIconBackground)
        set(listItemIconBorderRadius: style.listItemIconBorderRadius)
        set(background: style.background)
        set(corner: style.cornerRadius)
        set(borderWidth: style.borderWidth)
        set(borderColor: style.borderColor)
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}

extension GridView {
    
    @discardableResult
    public func set(actionItem: ActionItem) -> GridView {
        self.actionItem = actionItem
        return self
    }
    
    
    @discardableResult
    public func set(listItemIconTint: UIColor) -> Self {
        self.icon.tintColor = listItemIconTint
        return self
    }
    
    @discardableResult
    public func set(listItemTitleFont: UIFont) -> Self {
        self.title.font = listItemTitleFont
        return self
    }
    
    @discardableResult
    public func set(listItemTitleColor: UIColor) -> Self {
        self.title.textColor = listItemTitleColor
        return self
    }
    
    @discardableResult
    public func set(listItemIconBackground: UIColor) -> Self {
        self.backgroundColor = listItemIconBackground
        return self
    }
    
    @discardableResult
    public func set(listItemIconBorderRadius: CGFloat) -> Self {
        self.icon.layer.cornerRadius = listItemIconBorderRadius
        return self
    }
    
    @discardableResult
    public func set(background: UIColor) -> Self {
        self.backgroundColor = background
        return self
    }
    
    @discardableResult
    public func set(corner: CometChatCornerStyle) -> Self {
        self.roundViewCorners(corner: corner)
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        self.layer.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor) -> Self {
        self.layer.borderColor = borderColor.cgColor
        return self
    }
    
}
