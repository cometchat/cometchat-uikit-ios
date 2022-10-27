//  CometChatGroupListItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

CometChatGroupListItem: This component will be the class of UITableViewCell with components such as groupAvatar(Avatar), groupName(UILabel), groupDetails(UILabel).

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatGroupListItem: UITableViewCell {

     // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var groupAvatar: CometChatAvatar!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var groupMember: UILabel!
    @IBOutlet weak var groupType: UIImageView!
    
    // MARK: - Declaration of Variables
    
    weak var group: CometChatPro.Group? {
        didSet {
            
            if let currentGroup = group {
                groupName.text = currentGroup.name?.capitalized
                
                switch currentGroup.groupType {
                case .public:
                    groupType.image = UIImage(color: .clear)
                case .private: if #available(iOS 13.0, *) {
                    groupType.image =  UIImage(named: "private-group.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                } else { }
                case .password: if #available(iOS 13.0, *) {
                    groupType.image =  UIImage(named: "password-protected-group.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                } else {
                    if #available(iOS 13.0, *) {
                        groupType.image = UIImage(named: "password-protected-group.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    } else {
                        // Fallback on earlier versions
                    }
                    }
                @unknown default:
                    break
                }
                
                if let memberCount = group?.membersCount {
                    if  memberCount == 1 {
                        groupMember.text = "1 " + "MEMBERS".localized()
                    }else {
                        groupMember.text = "\(memberCount) " + "MEMBERS".localized()
                    }
                    
                }
                /// Set the  avatar for group
                groupAvatar.set(image: currentGroup.icon, with: group?.name)
            }
            
        }
    }
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    override func prepareForReuse() {
        group = nil
        // Cancel Image Request
        groupAvatar.cancel()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
