//  CometChatUserView.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

CometChatUserView: This component will be the class of UITableViewCell with components such as userAvatar(Avatar), userName(UILabel).

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */
protocol CometChatUserViewDelegate: NSObject {
    
    func didEditInfoPressed()
}


class CometChatUserView: UITableViewCell {
    
     // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var userAvatar: Avatar!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userStatus: UILabel!
    @IBOutlet weak var avatarHeight: NSLayoutConstraint!
    @IBOutlet weak var avatarWidth: NSLayoutConstraint!
    @IBOutlet weak var editInfo: UIButton!
    
    // MARK: - Declaration of Variables
    
    weak var delegate: CometChatUserViewDelegate?
    
    var user: User? {
        didSet {
            userName.text = user?.name
            userAvatar.set(image: user?.avatar ?? "", with: user?.name ?? "")
            if  user?.status != nil {
                switch user?.status {
                case .online:
                    userStatus.text = NSLocalizedString("ONLINE", bundle: UIKitSettings.bundle, comment: "")
                case .offline:
                    userStatus.text = NSLocalizedString("OFFLINE", bundle: UIKitSettings.bundle, comment: "")
                case .none: break
                @unknown default:
                    userStatus.text = NSLocalizedString("OFFLINE", bundle: UIKitSettings.bundle, comment: "")
                }
            }
            if #available(iOS 13.0, *) {
                let edit = UIImage(named: "editIcon.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
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
    
}


/*  ----------------------------------------------------------------------------------------- */
