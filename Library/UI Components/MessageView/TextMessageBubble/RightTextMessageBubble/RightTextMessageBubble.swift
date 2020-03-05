
//  RightTextMessageBubble.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class RightTextMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBInspectable
    
    
    @IBOutlet weak var tintedView: UIView!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    
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
            message.text = textMessage.text
            if textMessage.readAt > 0 {
            receipt.image = #imageLiteral(resourceName: "read")
            timeStamp.text = String().setMessageTime(time: Int(textMessage?.readAt ?? 0))
            }else if textMessage.deliveredAt > 0 {
            receipt.image = #imageLiteral(resourceName: "delivered")
            timeStamp.text = String().setMessageTime(time: Int(textMessage?.deliveredAt ?? 0))
            }else if textMessage.sentAt > 0 {
            receipt.image = #imageLiteral(resourceName: "sent")
            timeStamp.text = String().setMessageTime(time: Int(textMessage?.sentAt ?? 0))
            }else if textMessage.sentAt == 0 {
               receipt.image = #imageLiteral(resourceName: "wait")
               timeStamp.text = "Sending..."
            }
           receipt.contentMode = .scaleAspectFit
           message.textColor = .white
           message.font = UIFont (name: "SFProDisplay-Regular", size: 17)
        }
    }
    
    var deletedMessage: BaseMessage? {
        didSet {
            switch deletedMessage?.messageType {
         case .text:  message.text = "⚠️ You deleted this Message"
         case .image: message.text = "⚠️ You deleted this Image"
         case .video: message.text = "⚠️ You deleted this Video"
         case .audio: message.text =  "⚠️ You deleted this Audio"
         case .file:  message.text = "⚠️ You deleted this File"
         case .custom: message.text = "⚠️ You deleted this Custom Message"
         case .groupMember: break
         @unknown default: break }
            message.textColor = .darkGray
            message.font = UIFont (name: "SFProDisplay-RegularItalic", size: 17)
            timeStamp.text = String().setMessageTime(time: Int(deletedMessage?.sentAt ?? 0))
        }
    }
      // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionColor = .white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
            switch isEditing {
            case true:
                switch selected {
                case true:
                    self.tintedView.isHidden = false
                case false:
                    self.tintedView.isHidden = true
                }
            case false: break
            }
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
