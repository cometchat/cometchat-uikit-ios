//
//  ActionsCell.swift
//  Heartbeat Messenger
//
//  Created by Pushpsen on 30/04/20.
//  Copyright © 2022 pushpsen airekar. All rights reserved.
//

import UIKit

public class CometChatActionItem: UITableViewCell {
 
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var startIcon: UIImageView!
    @IBOutlet weak var startIconView: UIView!
    @IBOutlet weak var endIcon: UIImageView!
    @IBOutlet weak var endtIconView: UIView!
    
    @discardableResult
    public func set(actionItem: ActionItem) -> CometChatActionItem {
        self.actionItem = actionItem
        return self
    }
    
    var actionItem: ActionItem? {
        didSet {
            if let actionItem = actionItem {
                
                self.name.text = actionItem.text

                if let startIcon = actionItem.startIcon {
                    self.startIcon.isHidden = false
                    self.startIconView.isHidden = false
                    self.startIcon.image = startIcon.withRenderingMode(.alwaysTemplate)
                }else{
                    self.startIcon.isHidden = true
                    self.startIconView.isHidden = true
                }
                
                if let endIcon = actionItem.endIcon {
                    self.endIcon.isHidden = false
                    self.endtIconView.isHidden = false
                    self.endIcon.image = endIcon.withRenderingMode(.alwaysTemplate)
                }else{
                    self.endIcon.isHidden = true
                    self.endtIconView.isHidden = true
                }
                
                if let startIconTint = actionItem.startIconTint {
                    self.startIcon.tintColor = startIconTint
                    
                }
                
                if let endIconTint = actionItem.endIconTint {
                    self.endIcon.tintColor = endIconTint
                }
                
                if let textColor = actionItem.textColor {
                    self.name.textColor = textColor
                }
                
                if let textFont = actionItem.textFont {
                    self.name.font = textFont
                }
            }
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
      
        self.background.backgroundColor = CometChatTheme.palatte?.background
        
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
        // Configure the view for the selected state
    }
    
    func configure(with presentable: ActionPresentable) {
           name.text = presentable.name
        startIcon.image = presentable.icon
    }
    
   
}
