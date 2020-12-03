//  LeftFileMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class LeftCollaborativeMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var avatar: Avatar!
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
    var collaborativeType: CollaborativeType = .whiteboard
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
            if let userName = whiteboardMessage.sender?.name {
                name.text = userName + ":"
                title.text = "\(userName) has shared a collaborative whiteboard."
                if #available(iOS 13.0, *) {
                    icon.image = UIImage(named: "whiteboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.systemGray)
                } else {
                    icon.image = UIImage(named: "whiteboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }
            }
            icon.tintColor = UIKitSettings.primaryColor
            joinButton.tintColor = UIKitSettings.primaryColor
            
            timeStamp.text = String().setMessageTime(time: Int(whiteboardMessage.sentAt ?? 0))
            
            if let avatarURL = whiteboardMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: whiteboardMessage.sender?.name ?? "")
            }
            
            if whiteboardMessage.replyCount != 0  &&  UIKitSettings.threadedChats == .enabled {
                replybutton.isHidden = false
                if whiteboardMessage.replyCount == 1 {
                    replybutton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = whiteboardMessage.replyCount as? Int {
                        replybutton.setTitle("\(replies) replies", for: .normal)
                    }
                }
            }else{
                replybutton.isHidden = true
            }
            replybutton.tintColor = UIKitSettings.primaryColor
            }
        }
    }
    
    var writeboardMessage: CustomMessage? {
        didSet {
            if let writeboardMessage = writeboardMessage {
            print("writeboardMessage is: \(writeboardMessage.stringValue())")
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
            if let userName = writeboardMessage.sender?.name {
                name.text = userName + ":"
                title.text = "\(userName) has shared a collaborative document."
                if #available(iOS 13.0, *) {
                    icon.image = UIImage(named: "writeboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.systemGray)
                } else {
                    icon.image = UIImage(named: "writeboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }
            }
            icon.tintColor = UIKitSettings.primaryColor
            joinButton.tintColor = UIKitSettings.primaryColor
                timeStamp.text = String().setMessageTime(time: Int(writeboardMessage.sentAt))
            
            if let avatarURL = writeboardMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: writeboardMessage.sender?.name ?? "")
            }
            
            if writeboardMessage.replyCount != 0  &&  UIKitSettings.threadedChats == .enabled {
                replybutton.isHidden = false
                if writeboardMessage.replyCount == 1 {
                    replybutton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = writeboardMessage.replyCount as? Int{
                        replybutton.setTitle("\(replies) replies", for: .normal)
                    }
                }
            }else{
                replybutton.isHidden = true
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
                title.text = "\(userName) has shared a collaborative whiteboard."
                if #available(iOS 13.0, *) {
                    icon.image = UIImage(named: "whiteboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.systemGray)
                } else {
                    icon.image = UIImage(named: "whiteboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }
            }
            icon.tintColor = UIKitSettings.primaryColor
            joinButton.tintColor = UIKitSettings.primaryColor
            if whiteboardMessageInThread.sentAt == 0 {
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                name.text = NSLocalizedString("---", bundle: UIKitSettings.bundle, comment: "")
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
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                 name.text = LoggedInUser.name.capitalized + ":"
            }
            replybutton.isHidden = true
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
                title.text = "\(userName) has shared a collaborative document."
                if #available(iOS 13.0, *) {
                    icon.image = UIImage(named: "writeboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate).withTintColor(.systemGray)
                } else {
                    icon.image = UIImage(named: "writeboard", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                }
            }
            icon.tintColor = UIKitSettings.primaryColor
            joinButton.tintColor = UIKitSettings.primaryColor
            if whiteboardMessageInThread.sentAt == 0 {
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                name.text = NSLocalizedString("---", bundle: UIKitSettings.bundle, comment: "")
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
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
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
            print("2")
            if let message = writeboardMessage {
                collaborativeDelegate?.didJoinPressed(forMessage: message)
            }
        }else if writeboardMessageInThread != nil {
            if let message = writeboardMessageInThread {
                collaborativeDelegate?.didJoinPressed(forMessage: message)
            }
        }else if whiteboardMessageInThread != nil {
            print("4")
            
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
