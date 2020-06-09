
//  RightTextMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


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
    weak var selectionColor: UIColor? {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.clear
        }
    }
    
    weak var textMessage: TextMessage? {
        didSet {
            if let textmessage  = textMessage {
                message.text = textmessage.text
                if textmessage.readAt > 0 {
                    receipt.image = #imageLiteral(resourceName: "read")
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.readAt ?? 0))
                }else if textmessage.deliveredAt > 0 {
                    receipt.image = #imageLiteral(resourceName: "delivered")
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.deliveredAt ?? 0))
                }else if textmessage.sentAt > 0 {
                    receipt.image = #imageLiteral(resourceName: "sent")
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.sentAt ?? 0))
                }else if textmessage.sentAt == 0 {
                    receipt.image = #imageLiteral(resourceName: "wait")
                    timeStamp.text = NSLocalizedString("SENDING", comment: "")
                }
            }
            
           receipt.contentMode = .scaleAspectFit
           message.textColor = .white
           message.font = UIFont (name: "SFProDisplay-Regular", size: 17)
        }
    }
    
    weak var deletedMessage: BaseMessage? {
       didSet {
         switch deletedMessage?.messageType {
         case .text:  message.text = NSLocalizedString("YOU_DELETED_THIS_MESSAGE", comment: "")
         case .image: message.text = NSLocalizedString("YOU_DELETED_THIS_IMAGE", comment: "")
         case .video: message.text = NSLocalizedString("YOU_DELETED_THIS_VIDEO", comment: "")
         case .audio: message.text =  NSLocalizedString("YOU_DELETED_THIS_AUDIO", comment: "")
         case .file:  message.text = NSLocalizedString("YOU_DELETED_THIS_FILE", comment: "")
         case .custom: message.text = NSLocalizedString("YOU_DELETED_THIS_CUSTOM_MESSAGE", comment: "")
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
