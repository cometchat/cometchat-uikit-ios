//  CometChatSenderFileMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


protocol  CollaborativeDelegate: NSObject {
    
    func didJoinPressed(forMessage: CustomMessage)
}

/*  ----------------------------------------------------------------------------------------- */

class CometChatSenderCollaborativeMessageBubble: UITableViewCell {

    // MARK: - Declaration of IBOutlets
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var heightReactions: NSLayoutConstraint!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var joinButton: UIButton!
    
     // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    var collaborativeType: WebViewType = .whiteboard
    weak var collaborativeDelegate: CollaborativeDelegate?
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
    
    var whiteboardMessage: CustomMessage! {
        didSet {
            receiptStack.isHidden = true
            
            title.text = "YOU_CREATED_WHITEBOARD".localized()
            joinButton.setTitle("LAUNCH".localized(), for: .normal)
            joinButton.tintColor = UIKitSettings.primaryColor
            icon.image = UIImage(named: "messages-collaborative-whiteboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            icon.tintColor = .white
            if whiteboardMessage.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
            
            }else{
                timeStamp.text = String().setMessageTime(time: whiteboardMessage.sentAt)
            }
                self.reactionView.parseMessageReactionForMessage(message: whiteboardMessage) { (success) in
                    if success == true {
                        self.reactionView.isHidden = false
                    }else{
                        self.reactionView.isHidden = true
                    }
                }
            if whiteboardMessage.readAt > 0 {
                receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessage?.readAt ?? 0))
            }else if whiteboardMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessage?.deliveredAt ?? 0))
            }else if whiteboardMessage.sentAt > 0 {
                receipt.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessage?.sentAt ?? 0))
            }else if whiteboardMessage.sentAt == 0 {
                receipt.image = UIImage(named: "messages-wait", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = "SENDING".localized()
            }
            FeatureRestriction.isThreadedMessagesEnabled { (success) in
                switch success {
                case .enabled where self.whiteboardMessage.replyCount != 0 :
                    self.replybutton.isHidden = false
                    if self.whiteboardMessage.replyCount == 1 {
                        self.replybutton.setTitle("ONE_REPLY".localized(), for: .normal)
                    }else{
                        if let replies = self.whiteboardMessage.replyCount as? Int {
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
    
    var writeboardMessage: CustomMessage! {
        didSet {
            
            title.text = "YOU_CREATED_DOCUMENT".localized()
            joinButton.setTitle("LAUNCH".localized(), for: .normal)
            joinButton.tintColor = UIKitSettings.primaryColor
            icon.image = UIImage(named: "messages-collaborative-document", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            icon.tintColor = .white
            receiptStack.isHidden = true
            if writeboardMessage.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
            }else{
                timeStamp.text = String().setMessageTime(time: writeboardMessage.sentAt)
            }
                self.reactionView.parseMessageReactionForMessage(message: writeboardMessage) { (success) in
                    if success == true {
                        self.reactionView.isHidden = false
                    }else{
                        self.reactionView.isHidden = true
                    }
                }
            if writeboardMessage.readAt > 0 {
                receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(writeboardMessage?.readAt ?? 0))
            }else if writeboardMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = String().setMessageTime(time: Int(writeboardMessage?.deliveredAt ?? 0))
            }else if writeboardMessage.sentAt > 0 {
                receipt.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = String().setMessageTime(time: Int(writeboardMessage?.sentAt ?? 0))
            }else if writeboardMessage.sentAt == 0 {
                receipt.image = UIImage(named: "messages-wait", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                timeStamp.text = "SENDING".localized()
            }
            FeatureRestriction.isThreadedMessagesEnabled { (success) in
                switch success {
                case .enabled where self.writeboardMessage.replyCount != 0 :
                    self.replybutton.isHidden = false
                    if self.writeboardMessage.replyCount == 1 {
                        self.replybutton.setTitle("ONE_REPLY".localized(), for: .normal)
                    }else{
                        if let replies = self.writeboardMessage.replyCount as? Int {
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
    
    
    // MARK: - Initialization of required Methods
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        if let message = whiteboardMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
        }
        if let message = writeboardMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
        }
    }
    
    
    @IBAction func didJoinButtonPressed(_ sender: Any) {
        if  whiteboardMessage != nil {
            collaborativeDelegate?.didJoinPressed(forMessage: whiteboardMessage)
            
        }else if  writeboardMessage != nil {
            collaborativeDelegate?.didJoinPressed(forMessage: writeboardMessage)
        }
    }
    
    func parseCollaborative(forMessage: CustomMessage){
        collaborativeDelegate?.didJoinPressed(forMessage: forMessage)
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
