
//  MembersView.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


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
                name.text = NSLocalizedString("YOU", comment: "")
                self.selectionStyle = .none
            }else{
                name.text = member.name
            }
            avatar.set(image: member.avatar ?? "", with: member.name ?? "")
            switch member.scope {
            case .admin:  scope.text = NSLocalizedString("ADMIN", comment: "")
            case .moderator: scope.text = NSLocalizedString("MODERATOR", comment: "")
            case .participant: scope.text = NSLocalizedString("PARTICIPANT", comment: "")
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
