//
//  LeftImageMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


/*  ----------------------------------------------------------------------------------------- */

class LeftStickerMessageBubble: UITableViewCell {
    
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var imageMessage: UIImageView!
    
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
    
    var stickerMessage: CustomMessage!{
        didSet {

            if let userName = stickerMessage.sender?.name {
                name.text = userName + ":"
            }
            if stickerMessage.receiverType == .group {
                nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            if let url = URL(string: stickerMessage.customData?["stickerUrl"] as? String ?? "") {
                imageMessage.cf.setImage(with: url, placeholder: UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil))
            }
            self.receiptStack.isHidden = true
            timeStamp.text = String().setMessageTime(time: stickerMessage.sentAt)
            if let avatarURL = stickerMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: stickerMessage.sender?.name ?? "")
            }
           
            if stickerMessage.replyCount != 0 &&  UIKitSettings.threadedChats == .enabled {
                
                replyButton.isHidden = false
                if stickerMessage?.replyCount == 1 {
                    replyButton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = stickerMessage?.replyCount {
                        replyButton.setTitle("\(replies) replies", for: .normal)
                    }
                }
            }else{
                replyButton.isHidden = true
            }
            replyButton.tintColor = UIKitSettings.primaryColor
            self.reactionView.parseMessageReactionForMessage(message: stickerMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
        }
    }
    
    var stickerMessageInThread: CustomMessage! {
        didSet {
            receiptStack.isHidden = true
            if let url = URL(string: stickerMessage.customData?["stickerUrl"] as? String ?? "") {
                imageMessage.cf.setImage(with: url, placeholder: UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil))
            }
            if stickerMessageInThread.sentAt == 0 {
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
            }else{
                timeStamp.text = String().setMessageTime(time: stickerMessageInThread.sentAt)
            }
            nameView.isHidden = false
            if stickerMessageInThread.readAt > 0 {
            timeStamp.text = String().setMessageTime(time: Int(stickerMessageInThread?.readAt ?? 0))
            }else if stickerMessageInThread.deliveredAt > 0 {
            timeStamp.text = String().setMessageTime(time: Int(stickerMessageInThread?.deliveredAt ?? 0))
            }else if stickerMessageInThread.sentAt > 0 {
            timeStamp.text = String().setMessageTime(time: Int(stickerMessageInThread?.sentAt ?? 0))
            }else if stickerMessageInThread.sentAt == 0 {
               timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                 name.text = LoggedInUser.name.capitalized + ":"
            }
            replyButton.isHidden = true
        }
    }
    
    // MARK: - Initialization of required Methods
    @IBAction func didReplyButtonPressed(_ sender: Any) {
             if let message = stickerMessage, let indexpath = indexPath {
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
    
    
     override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
           
       }
    
    /**
     This method used to set the image for LeftImageMessageBubble class
     - Parameter image: This specifies a `URL` for  the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
     func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.cf.setImage(with: url)
    }

    
}

/*  ----------------------------------------------------------------------------------------- */
