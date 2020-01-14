//
//  MembersView.swift
//  ios-chat-uikit-app
//
//  Created by Pushpsen Airekar on 30/12/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class MembersView: UITableViewCell {

    @IBOutlet weak var avtar: Avtar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var scope: UILabel!
    var member: GroupMember! {
        didSet {
            
            if member.uid == CometChat.getLoggedInUser()?.uid {
                name.text = "You"
                self.selectionStyle = .none
            }else{
                name.text = member.name
            }
            avtar.set(image: member.avatar ?? "")
            switch member.scope {
            case .admin:  scope.text = "Admin"
            case .moderator: scope.text = "Moderator"
            case .participant: scope.text = "Participant"
            @unknown default: break }
         }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
