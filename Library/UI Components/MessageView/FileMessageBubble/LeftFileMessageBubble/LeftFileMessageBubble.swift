//  LeftFileMessageBubble.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class LeftFileMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Declaration of Variables
    
    var fileMessage: MediaMessage! {
        didSet {
            self.selectionStyle = .none
            timeStamp.isHidden = true
            heightConstraint.constant = 0
            timeStamp.text = String().setMessageTime(time: Int(fileMessage?.sentAt ?? 0))
            name.text = fileMessage.attachment?.fileName.capitalized
            type.text = fileMessage.attachment?.fileExtension.uppercased()
            if let fileSize = fileMessage.attachment?.fileSize {
                print(Units(bytes: Int64(fileSize)).getReadableUnit())
                size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
            }
            avatar.kf.setImage(with: URL(string: fileMessage.sender?.avatar ?? ""))
        }
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
