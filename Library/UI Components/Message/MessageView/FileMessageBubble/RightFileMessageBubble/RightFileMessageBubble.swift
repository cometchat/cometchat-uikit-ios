//  RightFileMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class RightFileMessageBubble: UITableViewCell {

    // MARK: - Declaration of IBOutlets
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    
     // MARK: - Declaration of Variables
    var indexPath: IndexPath?
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
    
    var fileMessage: MediaMessage! {
        didSet {
            receiptStack.isHidden = true
            if fileMessage.sentAt == 0 {
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                name.text = NSLocalizedString("---", bundle: UIKitSettings.bundle, comment: "")
                type.text = NSLocalizedString("---", bundle: UIKitSettings.bundle, comment: "")
                size.text = NSLocalizedString("---", bundle: UIKitSettings.bundle, comment: "")
            }else{
                timeStamp.text = String().setMessageTime(time: fileMessage.sentAt)
                name.text = fileMessage.attachment?.fileName.capitalized
                type.text = fileMessage.attachment?.fileExtension.uppercased()
                if let fileSize = fileMessage.attachment?.fileSize {
                    size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
                }
            }
                self.reactionView.parseMessageReactionForMessage(message: fileMessage) { (success) in
                    if success == true {
                        self.reactionView.isHidden = false
                    }else{
                        self.reactionView.isHidden = true
                    }
                }
            if fileMessage.readAt > 0 {
                receipt.image = UIImage(named: "read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(fileMessage?.readAt ?? 0))
            }else if fileMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "delivered", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(fileMessage?.deliveredAt ?? 0))
            }else if fileMessage.sentAt > 0 {
                receipt.image = UIImage(named: "sent", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(fileMessage?.sentAt ?? 0))
            }else if fileMessage.sentAt == 0 {
                receipt.image = UIImage(named: "wait", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
            }
            if fileMessage?.replyCount != 0  && UIKitSettings.threadedChats == .enabled {
                replybutton.isHidden = false
                if fileMessage?.replyCount == 1 {
                    replybutton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = fileMessage?.replyCount {
                        replybutton.setTitle("\(replies) replies", for: .normal)
                    }
                }
            }else{
                replybutton.isHidden = true
            }
            if UIKitSettings.showReadDeliveryReceipts == .disabled {
                receipt.isHidden = true
            }else{
                receipt.isHighlighted = false
            }
            messageView.backgroundColor = UIKitSettings.primaryColor
            replybutton.tintColor = UIKitSettings.primaryColor
        }
    }
    
    
    
    
    // MARK: - Initialization of required Methods
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        if let message = fileMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
        }

    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 13.0, *) {
            selectionColor = .systemBackground
        } else {
            selectionColor = .white
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        if #available(iOS 13.0, *) {
            
        } else {
            messageView.backgroundColor =  UIKitSettings.primaryColor
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if #available(iOS 13.0, *) {
            
        } else {
            messageView.backgroundColor =  UIKitSettings.primaryColor
        }
    }
     
}

/*  ----------------------------------------------------------------------------------------- */
