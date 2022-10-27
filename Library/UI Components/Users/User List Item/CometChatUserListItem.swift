//  CometChatUserListItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

CometChatUserListItem: This component will be the class of UITableViewCell with components such as userAvatar(Avatar), userName(UILabel).

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */
protocol CometChatUserListItemDelegate: NSObject {
    
    func didEditInfoPressed()
}


class CometChatUserListItem: UITableViewCell {
    
     // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var userAvatar: CometChatAvatar!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userStatus: UILabel!
    @IBOutlet weak var avatarHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarWidth: NSLayoutConstraint!
    @IBOutlet weak var editInfo: UIButton!
    
    // MARK: - Declaration of Variables
    weak var delegate: CometChatUserListItemDelegate?
    
    var user: CometChatPro.User? {
        didSet {
            userName.text = user?.name
            /// Set the avatar for user.
            userAvatar.set(image: user?.avatar, with: user?.name)
            if  user?.status != nil {
                switch user?.status {
                case .online:
                    userStatus.text = "ONLINE".localized()
                case .offline:
                    userStatus.text = "OFFLINE".localized()
                case .none: break
                @unknown default:
                    userStatus.text = "OFFLINE".localized()
                }
            }
            if #available(iOS 13.0, *) {
                let edit = UIImage(named: "userprofile-edit.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                 editInfo.setImage(edit, for: .normal)
                editInfo.tintColor = UIKitSettings.primaryColor
            } else {}
            userStatus.textColor = UIKitSettings.primaryColor
        }
    }
    
    // MARK: - Initialization of required Methods
       
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func editInfoPressed(_ sender: Any) {
        delegate?.didEditInfoPressed()
    }
    
    override func prepareForReuse() {
        // Cancel Image Request
        userAvatar.cancel()
    }
    
}


/*  ----------------------------------------------------------------------------------------- */
