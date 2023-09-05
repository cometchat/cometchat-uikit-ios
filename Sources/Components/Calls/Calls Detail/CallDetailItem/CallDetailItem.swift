//  CometChatCallDetailsLogItem.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatSDK

class CallDetailItem: UITableViewCell {
    
    
    // MARK: - Declaration of IBOutlets
  
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var duration: CometChatDate!
    @IBOutlet weak var callStatusIcon: UIImageView!
    @IBOutlet weak var callStatus: UILabel!
    
    // MARK: - Initialization of required Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = CometChatTheme.palatte.background
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
