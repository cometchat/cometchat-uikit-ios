//  RightFileMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

enum CollaborativeType {
    case whiteboard
    case writeboard
}
protocol  CollaborativeDelegate: NSObject {
    
    func didJoinPressed(forMessage: CustomMessage)
}

/*  ----------------------------------------------------------------------------------------- */

class RightCollaborativeMessageBubble: UITableViewCell {

    // MARK: - Declaration of IBOutlets
    @IBOutlet weak var reactionView: ReactionView!
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
    var collaborativeType: CollaborativeType = .whiteboard
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
            print("whiteboardMessage is: \(whiteboardMessage.stringValue())")
            
            title.text = "You’ve created a new collaborative whiteboard."
            joinButton.setTitle("Launch", for: .normal)
            icon.image = UIImage(named: "whiteboard", in: UIKitSettings.bundle, compatibleWith: nil)
            
            if whiteboardMessage.sentAt == 0 {
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
            
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
                receipt.image = UIImage(named: "read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessage?.readAt ?? 0))
            }else if whiteboardMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "delivered", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessage?.deliveredAt ?? 0))
            }else if whiteboardMessage.sentAt > 0 {
                receipt.image = UIImage(named: "sent", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessage?.sentAt ?? 0))
            }else if whiteboardMessage.sentAt == 0 {
                receipt.image = UIImage(named: "wait", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
            }
            if whiteboardMessage?.replyCount != 0  && UIKitSettings.threadedChats == .enabled {
                replybutton.isHidden = false
                if whiteboardMessage?.replyCount == 1 {
                    replybutton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = whiteboardMessage?.replyCount {
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
    
    var writeboardMessage: CustomMessage! {
        didSet {
            
            print("Writeboard is: \(writeboardMessage.stringValue())")
            title.text = "You’ve created a new collaborative document."
            joinButton.setTitle("Launch", for: .normal)
            icon.image = UIImage(named: "writeboard", in: UIKitSettings.bundle, compatibleWith: nil)
            receiptStack.isHidden = true
            if writeboardMessage.sentAt == 0 {
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
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
                receipt.image = UIImage(named: "read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(writeboardMessage?.readAt ?? 0))
            }else if writeboardMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "delivered", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(writeboardMessage?.deliveredAt ?? 0))
            }else if writeboardMessage.sentAt > 0 {
                receipt.image = UIImage(named: "sent", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(writeboardMessage?.sentAt ?? 0))
            }else if writeboardMessage.sentAt == 0 {
                receipt.image = UIImage(named: "wait", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
            }
            if writeboardMessage?.replyCount != 0  && UIKitSettings.threadedChats == .enabled {
                replybutton.isHidden = false
                if whiteboardMessage?.replyCount == 1 {
                    replybutton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = whiteboardMessage?.replyCount {
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
     
}

/*  ----------------------------------------------------------------------------------------- */
