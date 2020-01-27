
//  MembersView.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class MembersView: UITableViewCell {

    // MARK: - Declaration of IBOutlet
    
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var scope: UILabel!
    
    // MARK: - Declaration of Variables
    
    var member: GroupMember! {
        didSet {
            
            if member.uid == CometChat.getLoggedInUser()?.uid {
                name.text = "You"
                self.selectionStyle = .none
            }else{
                name.text = member.name
            }
            avatar.set(image: member.avatar ?? "")
            switch member.scope {
            case .admin:  scope.text = "Admin"
            case .moderator: scope.text = "Moderator"
            case .participant: scope.text = "Participant"
            @unknown default: break }
         }
    }
    
     // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
