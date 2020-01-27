
//  LeftTextMessageBubble.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class LeftTextMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var message: ChattingBubble!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    // MARK: - Declaration of Variables
    
    var textMessage: TextMessage! {
        didSet {
            self.selectionStyle = .none
            message.text = textMessage.text
            timeStamp.isHidden = true
            heightConstraint.constant = 0
            if let avatarURL = textMessage.sender?.avatar  {
                avatar.set(image: avatarURL)
            }
            timeStamp.text = String().setMessageTime(time: textMessage.sentAt)
            message.font = UIFont (name: "SFProDisplay-Regular", size: 17)
            message.textColor = .black
        }
    }
    
    var deletedMessage: BaseMessage! {
           didSet {
               self.selectionStyle = .none
            if let user = deletedMessage.sender?.name {
            switch deletedMessage.messageType {
            case .text:  message.text = "⚠️ This message is deleted"
            case .image: message.text = "⚠️ This image is deleted"
            case .video: message.text = "⚠️ This video is deleted"
            case .audio: message.text =  "⚠️ This audio is deleted"
            case .file:  message.text = "⚠️ This file is deleted"
            case .custom: message.text = "⚠️ This custom message is deleted"
            case .groupMember: break
            @unknown default: break }}
               timeStamp.isHidden = true
               heightConstraint.constant = 0
               if let avatarURL = deletedMessage.sender?.avatar  {
                   avatar.set(image: avatarURL)
               }
            timeStamp.text = String().setMessageTime(time: Int(deletedMessage.sentAt))
            message.textColor = .darkGray
            message.font = UIFont (name: "SFProDisplay-RegularItalic", size: 17)
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
        This method used to set the image for LeftTextMessageBubble class
        - Parameter image: This specifies a `URL` for  the Avatar.
        - Author: CometChat Team
        - Copyright:  ©  2019 CometChat Inc.
        */
    public func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.kf.setImage(with: url)
        }
    }
    

/*  ----------------------------------------------------------------------------------------- */


