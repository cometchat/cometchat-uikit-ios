//  CometChatGroupView.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

CometChatGroupView: This component will be the class of UITableViewCell with components such as groupAvatar(Avatar), groupName(UILabel), groupDetails(UILabel).

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatGroupView: UITableViewCell {

     // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var groupAvatar: Avatar!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var groupMember: UILabel!
    @IBOutlet weak var groupType: UIImageView!
    
    // MARK: - Declaration of Variables
    
    weak var group: Group? {
        didSet {
            
            if let currentGroup = group {
                groupName.text = currentGroup.name?.capitalized
                
                switch currentGroup.groupType {
                case .public:
                    groupType.image = UIImage(color: .clear)
                case .private: if #available(iOS 13.0, *) {
                    groupType.image =  UIImage.init(systemName: "shield.lefthalf.fill")
                } else { }
                case .password: if #available(iOS 13.0, *) {
                    groupType.image =  UIImage.init(systemName: "lock.fill")
                } else {
                    if #available(iOS 13.0, *) {
                        groupType.image =  UIImage.init(systemName: "lock.fill")
                    } else {
                        // Fallback on earlier versions
                    }
                    }
                @unknown default:
                    break
                }
                
                if let memberCount = group?.membersCount {
                    if  memberCount == 1 {
                        groupMember.text = "1 Member"
                    }else {
                        groupMember.text = "\(memberCount) Members"
                    }
                    
                }
                groupAvatar.set(image: currentGroup.icon ?? "", with: currentGroup.name ?? "")
            }
            
        }
    }
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
    override func prepareForReuse() {
        group = nil
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
