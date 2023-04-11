//
//  ActionsCell.swift
//  Heartbeat Messenger
//
//  Created by Pushpsen on 30/04/20.
//  Copyright © 2022 pushpsen airekar. All rights reserved.
//

import UIKit

class ActionItemStyle: BaseStyle {
    
    private(set) var titleFont: UIFont = CometChatTheme.typography.text1
    private(set) var titleColor: UIColor = CometChatTheme.palatte.accent900
    private(set) var leadingIconTint: UIColor = CometChatTheme.palatte.accent700
    
   override var cornerRadius: CometChatCornerStyle  {
        get {
            CometChatCornerStyle(cornerRadius: 10)
        }
        set {
            self.cornerRadius = newValue
        }
    }
    public override init() {}
    
    @discardableResult
    public func set(titleFont: UIFont?) -> Self {
        if let titleFont = titleFont {
            self.titleFont = titleFont
        }
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor?) -> Self {
        if let titleColor = titleColor {
            self.titleColor = titleColor
        }
        return self
    }
    
    @discardableResult
    public func set(leadingIconTint: UIColor?) -> Self {
        if let leadingIconTint = leadingIconTint {
            self.leadingIconTint = leadingIconTint
        }
        return self
    }
    
}

public class CometChatActionItem: UITableViewCell {
 
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var leadingIcon: UIImageView!
    @IBOutlet weak var leadingIconView: UIView!
    @IBOutlet weak var trailingView: UIStackView!
    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var trailingIcon: UIImageView!
    static var identifier = "CometChatActionItem"
    var customView: UIView?
    var actionItem: ActionItem? {
        didSet {
            if let actionItem = actionItem {
                self.name.text = actionItem.text
                if let titleColor = actionItem.style?.titleColor {
                    self.name.textColor = titleColor
                }
                if let titleFont = actionItem.style?.titleFont {
                    self.name.font = titleFont
                }
                if let leadingIcon = actionItem.leadingIcon {
                    self.leadingIcon.isHidden = false
                    self.leadingIconView.isHidden = false
                    self.leadingIcon.image = leadingIcon.withRenderingMode(.alwaysTemplate)
                 } else {
                    self.leadingIcon.isHidden = true
                    self.leadingIconView.isHidden = true
                }
                if let leadingIconTint = actionItem.style?.leadingIconTint {
                    self.leadingIcon.tintColor = leadingIconTint
                }
                if let trailingView = actionItem.trailingView {
                    self.trailingView.addArrangedSubview(trailingView)
                } else {
                    self.trailingView.isHidden = true
                }
            }
        }
    }
    
    public func setCustomView(view: UIView) {
        customView = view
        mainStackView.subviews.forEach({ $0.removeFromSuperview() })
        mainStackView.addArrangedSubview(view)
    }

    public  override func prepareForReuse() {
        if let customView = customView {
            mainStackView.subviews.forEach { view in
                if view === customView {
                    view.removeFromSuperview()
                }
            }
        } else {
            trailingView.subviews.forEach({ $0.removeFromSuperview() })
        }
    }
    
    public func set(style: ActionSheetStyle) {
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
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.background.backgroundColor = CometChatTheme.palatte.background
        
    }

    func configure(with presentable: ActionPresentable) {
        name.text = presentable.name
        leadingIcon.image = presentable.icon
    }
    
    public func setTopViewBackGroundColor(color: UIColor) {
        self.background.backgroundColor = color
    }
}

extension CometChatActionItem {

    @discardableResult
    public func set(actionItem: ActionItem) -> CometChatActionItem {
        self.actionItem = actionItem
        return self
    }
    
    @discardableResult
    public func set(listItemIconTint: UIColor) -> Self {
        self.leadingIcon.tintColor = listItemIconTint
        return self
    }
    
    @discardableResult
    public func set(listItemTitleFont: UIFont) -> Self {
        self.name.font = listItemTitleFont
        return self
    }
    
    @discardableResult
    public func set(listItemTitleColor: UIColor) -> Self {
        self.name.textColor = listItemTitleColor
        return self
    }
    
    @discardableResult
    public func set(listItemIconBackground: UIColor) -> Self {
        self.backgroundColor = listItemIconBackground
        return self
    }
    
    @discardableResult
    public func set(listItemIconBorderRadius: CGFloat) -> Self {
        self.leadingIcon.layer.cornerRadius = listItemIconBorderRadius
        return self
    }
    
    @discardableResult
    public func set(background: UIColor) -> Self {
        self.backgroundColor = background
        self.setNeedsLayout()
        return self
    }
    
    @discardableResult
    public func set(corner: CometChatCornerStyle) -> Self {
        background.roundViewCorners(corner: corner)
        self.contentView.roundViewCorners(corner: corner)
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
