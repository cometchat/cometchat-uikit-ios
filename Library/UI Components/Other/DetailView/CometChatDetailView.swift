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

protocol  DetailViewDelegate : class  {
    
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
    var user: User! {
       didSet {
        name.text = user.name
        switch user.status {
        case .online:
            detail.text = NSLocalizedString("ONLINE", comment: "")
        case .offline:
             detail.text = NSLocalizedString("OFFLINE", comment: "")
        @unknown default:
            detail.text = NSLocalizedString("OFFLINE", comment: "")
        }
         icon.set(image: user.avatar ?? "", with: user.name ?? "")
    }
    }
    
    var group: Group! {
        didSet {
            name.text = group.name
            switch group.groupType {
            case .public:
                detail.text = NSLocalizedString("PUBLIC", comment: "")
            case .private:
                detail.text = NSLocalizedString("PRIVATE", comment: "")
            case .password:
                detail.text = NSLocalizedString("PASSWORD_PROTECTED", comment: "")
            @unknown default:
                break
            }
            icon.set(image: group.icon ?? "", with: group.name ?? "")
        }
    }
    
    @IBAction func didCallPressed(_ sender: Any) {
        if user != nil {
            detailViewDelegate?.didCallButtonPressed(for: user)
        }
        if group != nil {
            detailViewDelegate?.didCallButtonPressed(for: group)
        }
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
