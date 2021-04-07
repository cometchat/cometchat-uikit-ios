
//  CometChatMembersItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatMembersItem: UITableViewCell {

    // MARK: - Declaration of IBOutlet
    
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var scope: UILabel!
    @IBOutlet weak var status: CometChatStatusIndicator!
    
    // MARK: - Declaration of Variables
    var group: Group?
    weak var member: GroupMember? {
        didSet {
            if let currentMember = member {
                if currentMember.uid == LoggedInUser.uid {
                    name.text = "YOU".localized()
                    self.selectionStyle = .none
                }else{
                    name.text = currentMember.name
                }
                status.set(status: currentMember.status)
                avatar.set(image: currentMember.avatar ?? "", with: currentMember.name ?? "")
                switch currentMember.scope {
                case .admin:
                    if let group = group {
                        if group.owner == currentMember.uid {
                            scope.text = "OWNER".localized()
                        }else{
                            scope.text = "ADMIN".localized()
                        }
                    }else{
                        scope.text = "ADMIN".localized()
                    }
                case .moderator: scope.text = "MODERATOR".localized()
                case .participant: scope.text = "PARTICIPANT".localized()
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
