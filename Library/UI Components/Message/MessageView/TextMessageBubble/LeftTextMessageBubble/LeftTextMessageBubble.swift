
//  LeftTextMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class LeftTextMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var tintedView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var nameView: UIView!
    
    // MARK: - Declaration of Variables
    var selectionColor: UIColor {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.clear
        }
    }
    
    
    var textMessage: TextMessage! {
        didSet {
            if let userName = textMessage.sender?.name {
                name.text = userName + ":"
            }
            message.text = textMessage.text
            receiptStack.isHidden = true
            if textMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            if let avatarURL = textMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: textMessage.sender?.name ?? "")
            }
            timeStamp.text = String().setMessageTime(time: textMessage.sentAt)
            message.font = UIFont (name: "SFProDisplay-Regular", size: 17)
            if #available(iOS 13.0, *) {
                message.textColor = .label
            } else {
                message.textColor = .black
            }
        }
    }
    
    var deletedMessage: BaseMessage! {
           didSet {
           // self.selectionStyle = .none
            if let userName = deletedMessage.sender?.name {
                name.text = userName + ":"
            }
            if (deletedMessage.sender?.name) != nil {
            switch deletedMessage.messageType {
            case .text:  message.text =  NSLocalizedString("THIS_MESSAGE_DELETED", comment: "")
            case .image: message.text = NSLocalizedString("THIS_IMAGE_DELETED", comment: "")
            case .video: message.text = NSLocalizedString("THIS_VIDEO_DELETED", comment: "")
            case .audio: message.text =  NSLocalizedString("THIS_AUDIO_DELETED", comment: "")
            case .file:  message.text = NSLocalizedString("THIS_FILE_DELETED", comment: "")
            case .custom: message.text = NSLocalizedString("THIS_CUSTOM_MESSAGE_DELETED", comment: "")
            case .groupMember: break
            @unknown default: break }}
               receiptStack.isHidden = true
            if deletedMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
               if let avatarURL = deletedMessage.sender?.avatar  {
                   avatar.set(image: avatarURL, with: deletedMessage.sender?.name ?? "")
               }
            timeStamp.text = String().setMessageTime(time: Int(deletedMessage.sentAt))
            message.textColor = .darkGray
            message.font = UIFont (name: "SFProDisplay-RegularItalic", size: 17)
           }
       }
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if #available(iOS 13.0, *) {
            selectionColor = .systemBackground
        } else {
            selectionColor = .white
        }
    }
    
     override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
           switch isEditing {
           case true:
               switch selected {
               case true: self.tintedView.isHidden = false
               case false: self.tintedView.isHidden = true
               }
           case false: break
           }
       }
    
     /**
        This method used to set the image for LeftTextMessageBubble class
        - Parameter image: This specifies a `URL` for  the Avatar.
        - Author: CometChat Team
        - Copyright:  ©  2020 CometChat Inc.
        */
    public func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.cf.setImage(with: url)
        }
    }
    

/*  ----------------------------------------------------------------------------------------- */


