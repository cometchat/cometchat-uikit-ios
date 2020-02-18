//  CometChatUserView.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

CometChatUserView: This component will be the class of UITableViewCell with components such as userAvatar(Avatar), userName(UILabel).

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatUserView: UITableViewCell {
    
     // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var userAvatar: Avatar!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userStatus: UILabel!
    @IBOutlet weak var avatarHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarWidth: NSLayoutConstraint!
    
    // MARK: - Declaration of Variables
    
    var user: User! {
        didSet {
            userName.text = user?.name
            userAvatar.set(image: user?.avatar ?? "", with: user?.name ?? "")
            
            if  user.status != nil {
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
    }
    
    // MARK: - Initialization of required Methods
       
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}


/*  ----------------------------------------------------------------------------------------- */
