//
//  ActionsCell.swift
//  Heartbeat Messenger
//
//  Created by Pushpsen on 30/04/20.
//  Copyright © 2022 pushpsen airekar. All rights reserved.
//

import UIKit

class ListModeCell: UITableViewCell {
 
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var icon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    contentView.backgroundColor = CometChatActionSheet.backgroundColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
        // Configure the view for the selected state
    }
    
    func configure(with presentable: ActionPresentable) {
           name.text = presentable.name
           icon.image = presentable.icon
    }
    
   
}
