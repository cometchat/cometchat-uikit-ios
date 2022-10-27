//  CometChatSenderFileMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatSenderFileMessageBubble: UITableViewCell {

    // MARK: - Declaration of IBOutlets
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var heightReactions: NSLayoutConstraint!
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
                timeStamp.text = "SENDING".localized()
                name.text = "---".localized()
                type.text = "---".localized()
                size.text = "---".localized()
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
                receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(fileMessage?.readAt ?? 0))
            }else if fileMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = String().setMessageTime(time: Int(fileMessage?.deliveredAt ?? 0))
            }else if fileMessage.sentAt > 0 {
                receipt.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = String().setMessageTime(time: Int(fileMessage?.sentAt ?? 0))
            }else if fileMessage.sentAt == 0 {
                receipt.image = UIImage(named: "messages-wait", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = "SENDING".localized()
            }
            FeatureRestriction.isThreadedMessagesEnabled { (success) in
                switch success {
                case .enabled where self.fileMessage.replyCount != 0 :
                    self.replybutton.isHidden = false
                    if self.fileMessage.replyCount == 1 {
                        self.replybutton.setTitle("ONE_REPLY".localized(), for: .normal)
                    }else{
                        if let replies = self.fileMessage.replyCount as? Int {
                            self.replybutton.setTitle("\(replies) replies", for: .normal)
                        }
                    }
                case .disabled, .enabled : self.replybutton.isHidden = true
                }
            }
            FeatureRestriction.isDeliveryReceiptsEnabled { (success) in
                switch success {
                case .enabled: self.receipt.isHidden = false
                case .disabled: self.receipt.isHidden = true
                }
            }
            messageView.backgroundColor = UIKitSettings.primaryColor
            replybutton.tintColor = UIKitSettings.primaryColor
            icon.image = UIImage(named: "messages-file-upload.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            icon.tintColor = .white
            calculateHeightForReactions(reactionView: reactionView, heightReactions: heightReactions)
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
     
    override func prepareForReuse() {
        reactionView.reactions.removeAll()
    }
 
}

/*  ----------------------------------------------------------------------------------------- */
