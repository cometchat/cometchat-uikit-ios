//  CometChatAddMemberItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatAddMemberItem: UITableViewCell {

    @IBOutlet weak var addIcon: UIImageView!
    // MARK: - Initialization of required Methods
    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        label.text = "ADD_MEMBERS".localized()
         addIcon.tintColor = UIKitSettings.primaryColor
        if #available(iOS 13.0, *) {
        }else{
           addIcon.image = UIImage(named: "addIcon", in: UIKitSettings.bundle, compatibleWith: nil)
           
        }
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
/*  ----------------------------------------------------------------------------------------- */
