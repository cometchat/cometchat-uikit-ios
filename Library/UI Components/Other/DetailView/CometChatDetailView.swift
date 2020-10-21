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

protocol  DetailViewDelegate : AnyObject  {
    
    func didCallButtonPressed(for: AppEntity)
}


/*  ----------------------------------------------------------------------------------------- */

class CometChatDetailView: UITableViewCell {

     // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var icon: Avatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var call: UIButton!
    
    // MARK: - Declaration of Variables
    weak var detailViewDelegate: DetailViewDelegate?
    weak var user: User? {
       didSet {
        if let currentUser = user {
            name.text = currentUser.name
                switch currentUser.status {
                case .online:
                    detail.text = NSLocalizedString("ONLINE", bundle: UIKitSettings.bundle, comment: "")
                case .offline:
                     detail.text = NSLocalizedString("OFFLINE", bundle: UIKitSettings.bundle, comment: "")
                @unknown default:
                    detail.text = NSLocalizedString("OFFLINE", bundle: UIKitSettings.bundle, comment: "")
                }
            if UIKitSettings.showUserPresence == .disabled {
                detail.isHidden = true
            }else{
                detail.isHidden = false
            }
                 icon.set(image: currentUser.avatar ?? "", with: currentUser.name ?? "")
            if #available(iOS 13.0, *) {
                let callingIcon = UIImage(named: "audioCall.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                call.setImage(callingIcon, for: .normal)
                call.tintColor = UIKitSettings.primaryColor
            } else {}
        }
        
        if UIKitSettings.userVideoCall == .disabled && UIKitSettings.userAudioCall == .disabled {
            call.isHidden = true
        }else{
            call.isHidden = false
        }
    }
    }
    
    weak var group: Group? {
        didSet {
            if let currentGroup = group {
                name.text = currentGroup.name
                switch currentGroup.groupType {
                case .public:
                    detail.text = NSLocalizedString("PUBLIC", bundle: UIKitSettings.bundle, comment: "")
                case .private:
                    detail.text = NSLocalizedString("PRIVATE", bundle: UIKitSettings.bundle, comment: "")
                case .password:
                    detail.text = NSLocalizedString("PASSWORD_PROTECTED", bundle: UIKitSettings.bundle, comment: "")
                @unknown default:
                    break
                }
                icon.set(image: currentGroup.icon ?? "", with: currentGroup.name ?? "")
                if #available(iOS 13.0, *) {
                    let callingIcon = UIImage(named: "audioCall.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    call.setImage(callingIcon, for: .normal)
                    call.tintColor = UIKitSettings.primaryColor
                } else {}
            }
            
            if UIKitSettings.groupVideoCall == .disabled && UIKitSettings.groupAudioCall == .disabled {
                call.isHidden = true
            }else{
                call.isHidden = false
            }
        }
    }
    
    @IBAction func didCallPressed(_ sender: Any) {
        
        if let currentUser = user {
             detailViewDelegate?.didCallButtonPressed(for: currentUser)
        }
        
        if let currentGroup = group {
            detailViewDelegate?.didCallButtonPressed(for: currentGroup)
        }
    }
    
    override func prepareForReuse() {
        group = nil
        user = nil
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
