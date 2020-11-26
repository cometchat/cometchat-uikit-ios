//  RightaudioMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class RightAudioMessageBubble: UITableViewCell {

    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    
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
    
    var audioMessage: MediaMessage! {
        didSet {
                self.reactionView.parseMessageReactionForMessage(message: audioMessage) { (success) in
                    if success == true {
                        self.reactionView.isHidden = false
                    }else{
                        self.reactionView.isHidden = true
                    }
                }
                   receiptStack.isHidden = true
                   if audioMessage.sentAt == 0 {
                       timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                       name.text = "Audio File"
                       size.text = NSLocalizedString("calculating...", bundle: UIKitSettings.bundle, comment: "")
                   }else{
                       timeStamp.text = String().setMessageTime(time: audioMessage.sentAt)
                       name.text = "Audio File"
                    if let fileSize = audioMessage.attachment?.fileSize {
                      
                        size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
                    }
                   }
    
                  if audioMessage.readAt > 0 {
                       receipt.image = UIImage(named: "read", in: UIKitSettings.bundle, compatibleWith: nil)
                       timeStamp.text = String().setMessageTime(time: Int(audioMessage?.readAt ?? 0))
                       }else if audioMessage.deliveredAt > 0 {
                       receipt.image = UIImage(named: "delivered", in: UIKitSettings.bundle, compatibleWith: nil)
                       timeStamp.text = String().setMessageTime(time: Int(audioMessage?.deliveredAt ?? 0))
                       }else if audioMessage.sentAt > 0 {
                       receipt.image = UIImage(named: "sent", in: UIKitSettings.bundle, compatibleWith: nil)
                       timeStamp.text = String().setMessageTime(time: Int(audioMessage?.sentAt ?? 0))
                       }else if audioMessage.sentAt == 0 {
                          receipt.image = UIImage(named: "wait", in: UIKitSettings.bundle, compatibleWith: nil)
                          timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                       }
            
            if audioMessage?.replyCount != 0 && UIKitSettings.threadedChats == .enabled {
                replybutton.isHidden = false
                if audioMessage?.replyCount == 1 {
                    replybutton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = audioMessage?.replyCount {
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
    
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        if let message = audioMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
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
    // MARK: - Initialization of required Methods
      
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
