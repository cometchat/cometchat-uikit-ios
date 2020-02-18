//
//  LeftImageMessageBubble.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


/*  ----------------------------------------------------------------------------------------- */

class LeftImageMessageBubble: UITableViewCell {
    
    
    // MARK: - Declaration of IBInspectable
    
    
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var receiptStack: UIStackView!
    
    // MARK: - Declaration of Variables
    
    var mediaMessage: MediaMessage!{
        didSet {
            self.selectionStyle = .none
            if let userName = mediaMessage.sender?.name {
                name.text = userName + ":"
            }
            if mediaMessage.receiverType == .group {
                nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            self.receiptStack.isHidden = true
            timeStamp.text = String().setMessageTime(time: mediaMessage.sentAt)
            imageMessage.kf.setImage(with: URL(string: mediaMessage.attachment?.fileUrl ?? ""))
            if let avatarURL = mediaMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: mediaMessage.sender?.name ?? "")
            }
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
    
    
    /**
     This method used to set the image for LeftImageMessageBubble class
     - Parameter image: This specifies a `URL` for  the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     */
    
    public func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.kf.setImage(with: url)
    }
    
}
