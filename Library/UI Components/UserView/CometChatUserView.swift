//
//  UserView.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class CometChatUserView: UITableViewCell {
    
    @IBOutlet weak var userAvtar: Avtar!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userStatus: UILabel!
    
    @IBOutlet weak var avtarHeight: NSLayoutConstraint!
    @IBOutlet weak var avtarWidth: NSLayoutConstraint!
    
    var user: User! {
        didSet {
            userName.text = user?.name
            userAvtar.set(image: user?.avatar ?? "")
            switch user.status {
            case .online:
                userStatus.text = "Online"
            case .offline:
                userStatus.text = "Offline"
            @unknown default:
                userStatus.text = "Offline"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
