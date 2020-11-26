//  LeftFileMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class LeftFileMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var fileName: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    
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
            self.reactionView.parseMessageReactionForMessage(message: fileMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            receiptStack.isHidden = true
            if fileMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            if let userName = fileMessage.sender?.name {
                name.text = userName + ":"
            }
            
            timeStamp.text = String().setMessageTime(time: Int(fileMessage?.sentAt ?? 0))
            fileName.text = fileMessage.attachment?.fileName.capitalized
            type.text = fileMessage.attachment?.fileExtension.uppercased()
            if let fileSize = fileMessage.attachment?.fileSize {
                size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
            }
            if let avatarURL = fileMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: fileMessage.sender?.name ?? "")
            }
            
            if fileMessage?.replyCount != 0  &&  UIKitSettings.threadedChats == .enabled {
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
            replybutton.tintColor = UIKitSettings.primaryColor
            
        }
    }
    
    var fileMessageInThread: MediaMessage! {
        didSet {
            receiptStack.isHidden = true
            self.reactionView.parseMessageReactionForMessage(message: fileMessageInThread) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if fileMessageInThread.sentAt == 0 {
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                name.text = NSLocalizedString("---", bundle: UIKitSettings.bundle, comment: "")
                type.text = NSLocalizedString("---", bundle: UIKitSettings.bundle, comment: "")
                size.text = NSLocalizedString("---", bundle: UIKitSettings.bundle, comment: "")
            }else{
                timeStamp.text = String().setMessageTime(time: fileMessageInThread.sentAt)
                name.text = fileMessageInThread.attachment?.fileName.capitalized
                type.text = fileMessageInThread.attachment?.fileExtension.uppercased()
                if let fileSize = fileMessageInThread.attachment?.fileSize {
                    size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
                }
            }
             nameView.isHidden = false
            if fileMessageInThread.readAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(fileMessageInThread?.readAt ?? 0))
            }else if fileMessageInThread.deliveredAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(fileMessageInThread?.deliveredAt ?? 0))
            }else if fileMessageInThread.sentAt > 0 {
                timeStamp.text = String().setMessageTime(time: Int(fileMessageInThread?.sentAt ?? 0))
            }else if fileMessageInThread.sentAt == 0 {
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                 name.text = LoggedInUser.name.capitalized + ":"
            }
            replybutton.isHidden = true
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
