
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
    @IBOutlet weak var status: StatusIndicator!
    
    // MARK: - Declaration of Variables
    
    weak var member: GroupMember? {
        didSet {
            if let currentMember = member {
                if currentMember.uid == LoggedInUser.uid {
                    name.text = NSLocalizedString("YOU", bundle: UIKitSettings.bundle, comment: "")
                    self.selectionStyle = .none
                }else{
                    name.text = currentMember.name
                }
                status.set(status: currentMember.status)
                avatar.set(image: currentMember.avatar ?? "", with: currentMember.name ?? "")
                switch currentMember.scope {
                case .admin:  scope.text = NSLocalizedString("ADMIN", bundle: UIKitSettings.bundle, comment: "")
                case .moderator: scope.text = NSLocalizedString("MODERATOR", bundle: UIKitSettings.bundle, comment: "")
                case .participant: scope.text = NSLocalizedString("PARTICIPANT", bundle: UIKitSettings.bundle, comment: "")
                @unknown default: break }
                
                
            }
         }
    }
    
    deinit {
     
    }
    
    override func prepareForReuse() {
        member = nil
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
