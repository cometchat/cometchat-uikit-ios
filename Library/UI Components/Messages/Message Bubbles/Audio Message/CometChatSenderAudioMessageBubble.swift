//  CometChatSenderAudioMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatSenderAudioMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var heightReactions: NSLayoutConstraint!
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
            
            icon.image = UIImage(named: "messages-audio-file.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            icon.tintColor = .white
            receiptStack.isHidden = true
            if audioMessage.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
                name.text = "Audio File"
                size.text = "calculating...".localized()
            }else{
                timeStamp.text = String().setMessageTime(time: audioMessage.sentAt)
                name.text = "Audio File"
                if let fileSize = audioMessage.attachment?.fileSize {
                    
                    size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
                }
            }
            
            if audioMessage.readAt > 0 {
                receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(audioMessage?.readAt ?? 0))
            }else if audioMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = String().setMessageTime(time: Int(audioMessage?.deliveredAt ?? 0))
            }else if audioMessage.sentAt > 0 {
                receipt.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = String().setMessageTime(time: Int(audioMessage?.sentAt ?? 0))
            }else if audioMessage.sentAt == 0 {
                receipt.image = UIImage(named: "messages-wait", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = "SENDING".localized()
            }
            
            FeatureRestriction.isThreadedMessagesEnabled { (success) in
                switch success {
                case .enabled where self.audioMessage.replyCount != 0 :
                    self.replybutton.isHidden = false
                    if self.audioMessage.replyCount == 1 {
                        self.replybutton.setTitle("ONE_REPLY".localized(), for: .normal)
                    }else{
                        if let replies = self.audioMessage.replyCount as? Int {
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
            calculateHeightForReactions(reactionView: reactionView, heightReactions: heightReactions)
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
    
    override func prepareForReuse() {
        reactionView.reactions.removeAll()
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
