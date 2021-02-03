//  CometChatSettingsItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatSettingsItem: UITableViewCell {
    
    // MARK: - Declaration of IBOutlet
    
    @IBOutlet weak var settingsName: UILabel!
    @IBOutlet weak var settingsIcon: UIImageView!
        
    
     // MARK: - Initialization of required Methods
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
}

/*  ----------------------------------------------------------------------------------------- */


