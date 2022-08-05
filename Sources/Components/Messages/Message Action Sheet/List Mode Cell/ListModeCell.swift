//
//  ActionsCell.swift
//  Heartbeat Messenger
//
//  Created by Pushpsen on 30/04/20.
//  Copyright © 2022 pushpsen airekar. All rights reserved.
//

import UIKit

public class ListModeCell: UITableViewCell {
 
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var icon: UIImageView!
    
    
    @discardableResult
    public func set(actionItem: ActionItem) -> ListModeCell {
        self.actionItem = actionItem
        return self
    }
    
    var actionItem: ActionItem? {
        didSet {
            if let actionItem = actionItem {
                self.name.text = actionItem.text
                
                if let icon = actionItem.startIcon {
                    self.icon.isHidden = false
                    self.iconView.isHidden = false
                    self.icon.image = icon
                }else{
                    self.icon.isHidden = true
                    self.iconView.isHidden = true
                }
            }
        }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
      
    contentView.backgroundColor = CometChatActionSheet.backgroundColor
    }

    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
        // Configure the view for the selected state
    }
    
    func configure(with presentable: ActionPresentable) {
           name.text = presentable.name
           icon.image = presentable.icon
    }
    
   
}
