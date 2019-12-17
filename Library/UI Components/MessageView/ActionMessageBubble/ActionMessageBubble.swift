//
//  ChatActionMessageCell.swift
//  CometChatPro-swift-sampleApp
//
//  Created by Pushpsen Airekar on 06/03/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit

class ActionMessageBubble: UITableViewCell {
    
    @IBOutlet weak var message: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        contentView.isUserInteractionEnabled = false
        
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
