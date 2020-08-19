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
    
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var tintedView: UIView!
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
                   receiptStack.isHidden = true
                   if audioMessage.sentAt == 0 {
                       timeStamp.text = NSLocalizedString("SENDING", comment: "")
                       name.text = "Audio File"
                       size.text = NSLocalizedString("calculating...", comment: "")
                   }else{
                       timeStamp.text = String().setMessageTime(time: audioMessage.sentAt)
                       name.text = "Audio File"
                    if let fileSize = audioMessage.attachment?.fileSize {
                        print(Units(bytes: Int64(fileSize)).getReadableUnit())
                        size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
                    }
                   }
    
                       if audioMessage.readAt > 0 && audioMessage.receiverType == .user {
                       receipt.image = #imageLiteral(resourceName: "read")
                       timeStamp.text = String().setMessageTime(time: Int(audioMessage?.readAt ?? 0))
                       }else if audioMessage.deliveredAt > 0 {
                       receipt.image = #imageLiteral(resourceName: "delivered")
                       timeStamp.text = String().setMessageTime(time: Int(audioMessage?.deliveredAt ?? 0))
                       }else if audioMessage.sentAt > 0 {
                       receipt.image = #imageLiteral(resourceName: "sent")
                       timeStamp.text = String().setMessageTime(time: Int(audioMessage?.sentAt ?? 0))
                       }else if audioMessage.sentAt == 0 {
                          receipt.image = #imageLiteral(resourceName: "wait")
                          timeStamp.text = NSLocalizedString("SENDING", comment: "")
                       }
            
            if audioMessage?.replyCount != 0 {
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
    
}

/*  ----------------------------------------------------------------------------------------- */
