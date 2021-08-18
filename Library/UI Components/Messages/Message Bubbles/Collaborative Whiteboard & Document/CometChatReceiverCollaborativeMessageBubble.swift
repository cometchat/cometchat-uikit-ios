//  CometChatReceiverFileMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatReceiverCollaborativeMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    
    // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    var collaborativeURL : String?
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
    var collaborativeType: WebViewType = .whiteboard
    weak var collaborativeDelegate: CollaborativeDelegate?
    var whiteboardMessage: CustomMessage? {
        didSet {
            if let whiteboardMessage = whiteboardMessage {
            self.reactionView.parseMessageReactionForMessage(message: whiteboardMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            receiptStack.isHidden = true
            if whiteboardMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            joinButton.setTitle("JOIN".localized(), for: .normal)
            joinButton.tintColor = UIKitSettings.primaryColor
            if let userName = whiteboardMessage.sender?.name {
                name.text = userName + ":"
                title.text = "\(userName) " + "HAS_SHARED_WHITEBOARD".localized()
                if #available(iOS 13.0, *) {
                    icon.image = UIImage(named: "messages-collaborative-whiteboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.systemGray)
                } else {
                    icon.image = UIImage(named: "messages-collaborative-whiteboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }
            }
            icon.tintColor = UIKitSettings.primaryColor
            joinButton.tintColor = UIKitSettings.primaryColor
            
            timeStamp.text = String().setMessageTime(time: Int(whiteboardMessage.sentAt ?? 0))
            
            if let avatarURL = whiteboardMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: whiteboardMessage.sender?.name ?? "")
            }
                
                FeatureRestriction.isThreadedMessagesEnabled { (success) in
                    switch success {
                    case .enabled where whiteboardMessage.replyCount != 0 :
                        self.replybutton.isHidden = false
                        if whiteboardMessage.replyCount == 1 {
                            self.replybutton.setTitle("ONE_REPLY".localized(), for: .normal)
                        }else{
                            if let replies = whiteboardMessage.replyCount as? Int {
                                self.replybutton.setTitle("\(replies) replies", for: .normal)
                            }
                        }
                    case .disabled, .enabled : self.replybutton.isHidden = true
                    }
                }

            replybutton.tintColor = UIKitSettings.primaryColor
                if let avatarURL = whiteboardMessage.sender?.avatar  {
                    avatar.set(image: avatarURL, with: whiteboardMessage.sender?.name ?? "")
                }else{
                    avatar.set(image: "", with: whiteboardMessage.sender?.name ?? "")
                }
            }
        }
    }
    
    var writeboardMessage: CustomMessage? {
        didSet {
            if let writeboardMessage = writeboardMessage {
          
            self.reactionView.parseMessageReactionForMessage(message: writeboardMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            receiptStack.isHidden = true
            if writeboardMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            joinButton.setTitle("JOIN".localized(), for: .normal)
            joinButton.tintColor = UIKitSettings.primaryColor
            if let userName = writeboardMessage.sender?.name {
                name.text = userName + ":"
                title.text = "\(userName) " +  "HAS_SHARED_COLLABORATIVE_DOCUMENT".localized()
                if #available(iOS 13.0, *) {
                    icon.image = UIImage(named: "messages-collaborative-document", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.systemGray)
                } else {
                    icon.image = UIImage(named: "messages-collaborative-document", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }
            }
            icon.tintColor = UIKitSettings.primaryColor
            joinButton.tintColor = UIKitSettings.primaryColor
                timeStamp.text = String().setMessageTime(time: Int(writeboardMessage.sentAt))
            
          
                if let avatarURL = writeboardMessage.sender?.avatar  {
                    avatar.set(image: avatarURL, with: writeboardMessage.sender?.name ?? "")
                }else{
                    avatar.set(image: "", with: writeboardMessage.sender?.name ?? "")
                }
            
                FeatureRestriction.isThreadedMessagesEnabled { (success) in
                    switch success {
                    case .enabled where writeboardMessage.replyCount != 0 :
                        self.replybutton.isHidden = false
                        if writeboardMessage.replyCount == 1 {
                            self.replybutton.setTitle("ONE_REPLY".localized(), for: .normal)
                        }else{
                            if let replies = writeboardMessage.replyCount as? Int {
                                self.replybutton.setTitle("\(replies) replies", for: .normal)
                            }
                        }
                    case .disabled, .enabled : self.replybutton.isHidden = true
                    }
                }
            replybutton.tintColor = UIKitSettings.primaryColor
            }
        }
    }
    
    var whiteboardMessageInThread: CustomMessage? {
        didSet {
            receiptStack.isHidden = true
            if let whiteboardMessageInThread = whiteboardMessageInThread {
                
            self.reactionView.parseMessageReactionForMessage(message: whiteboardMessageInThread) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if let userName = whiteboardMessageInThread.sender?.name {
                name.text = userName + ":"
                title.text = "\(userName) " + "HAS_SHARED_WHITEBOARD".localized()
                if #available(iOS 13.0, *) {
                    icon.image = UIImage(named: "messages-collaborative-whiteboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                } else {
                    icon.image = UIImage(named: "messages-collaborative-whiteboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }
                
            }
            icon.tintColor = UIKitSettings.primaryColor
            joinButton.tintColor = UIKitSettings.primaryColor
            if whiteboardMessageInThread.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
                name.text = "---".localized()
            }else{
                timeStamp.text = String().setMessageTime(time: whiteboardMessageInThread.sentAt)
            }
             nameView.isHidden = false
            if whiteboardMessageInThread.readAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessageInThread.readAt))
            }else if whiteboardMessageInThread.deliveredAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessageInThread.deliveredAt))
            }else if whiteboardMessageInThread.sentAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessageInThread.sentAt))
            }else if whiteboardMessageInThread.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
                 name.text = LoggedInUser.name.capitalized + ":"
            }
            replybutton.isHidden = true
                
                if let avatarURL = whiteboardMessageInThread.sender?.avatar  {
                    avatar.set(image: avatarURL, with: whiteboardMessageInThread.sender?.name ?? "")
                }else{
                    avatar.set(image: "", with: whiteboardMessageInThread.sender?.name ?? "")
                }
            }
        }
    }
    
    var writeboardMessageInThread: CustomMessage? {
        didSet {
            receiptStack.isHidden = true
            if let whiteboardMessageInThread = whiteboardMessageInThread {
            self.reactionView.parseMessageReactionForMessage(message: whiteboardMessageInThread) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if let userName = whiteboardMessageInThread.sender?.name {
                name.text = userName + ":"
                title.text = "\(userName) " + "HAS_SHARED_COLLABORATIVE_DOCUMENT".localized()
                icon.image = UIImage(named: "messages-collaborative-document", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                icon.tintColor = UIKitSettings.primaryColor
            }
                if let avatarURL = writeboardMessageInThread?.sender?.avatar  {
                    avatar.set(image: avatarURL, with: writeboardMessageInThread?.sender?.name ?? "")
                }else{
                    avatar.set(image: "", with: whiteboardMessageInThread.sender?.name ?? "")
                }
            icon.tintColor = UIKitSettings.primaryColor
            joinButton.tintColor = UIKitSettings.primaryColor
            if whiteboardMessageInThread.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
                name.text = "---".localized()
            }else{
                timeStamp.text = String().setMessageTime(time: whiteboardMessageInThread.sentAt)
            }
             nameView.isHidden = false
            if whiteboardMessageInThread.readAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessageInThread.readAt))
            }else if whiteboardMessageInThread.deliveredAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessageInThread.deliveredAt))
            }else if whiteboardMessageInThread.sentAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(whiteboardMessageInThread.sentAt))
            }else if whiteboardMessageInThread.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
                 name.text = LoggedInUser.name.capitalized + ":"
            }
            replybutton.isHidden = true
            }
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
            if let message = whiteboardMessage {
                collaborativeDelegate?.didJoinPressed(forMessage: message)
            }
        }else if  writeboardMessage != nil {
         
            if let message = writeboardMessage {
                collaborativeDelegate?.didJoinPressed(forMessage: message)
            }
        }else if writeboardMessageInThread != nil {
            if let message = writeboardMessageInThread {
                collaborativeDelegate?.didJoinPressed(forMessage: message)
            }
        }else if whiteboardMessageInThread != nil {
          
            if let message = whiteboardMessageInThread {
                collaborativeDelegate?.didJoinPressed(forMessage: message)
            }
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
            messageView.backgroundColor =  .lightGray
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if #available(iOS 13.0, *) {
            
        } else {
            messageView.backgroundColor =  .lightGray
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */
