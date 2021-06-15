//
//  CometChatReceiverImageMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


/*  ----------------------------------------------------------------------------------------- */

class CometChatReceiverStickerMessageBubble: UITableViewCell {
    
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var avatar: CometChatAvatar!
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
            print("stickerMessage: \(stickerMessage.stringValue())")
            if let url = URL(string: stickerMessage.customData?["sticker_url"] as? String ?? "") {
                imageMessage.cf.setImage(with: url, placeholder: UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil))
            }else{
                imageMessage.image = UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil)
            }
            self.receiptStack.isHidden = true
            timeStamp.text = String().setMessageTime(time: stickerMessage.sentAt)
       
            if let avatarURL = stickerMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: stickerMessage.sender?.name ?? "")
            }else{
                avatar.set(image: "", with: stickerMessage.sender?.name ?? "")
            }
           
            FeatureRestriction.isThreadedMessagesEnabled { (success) in
                switch success {
                case .enabled where self.stickerMessage.replyCount != 0 :
                    self.replyButton.isHidden = false
                    if self.stickerMessage.replyCount == 1 {
                        self.replyButton.setTitle("ONE_REPLY".localized(), for: .normal)
                    }else{
                        if let replies = self.stickerMessage.replyCount as? Int {
                            self.replyButton.setTitle("\(replies) replies", for: .normal)
                        }
                    }
                case .disabled, .enabled : self.replyButton.isHidden = true
                }
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
            if let url = URL(string: stickerMessage.customData?["sticker_url"] as? String ?? "") {
                imageMessage.cf.setImage(with: url, placeholder: UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil))
            }
            if stickerMessageInThread.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
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
               timeStamp.text = "SENDING".localized()
                 name.text = LoggedInUser.name.capitalized + ":"
            }
            replyButton.isHidden = true
            if let avatarURL = stickerMessageInThread.sender?.avatar  {
                avatar.set(image: avatarURL, with: stickerMessageInThread.sender?.name ?? "")
            }else{
                avatar.set(image: "", with: stickerMessageInThread.sender?.name ?? "")
            }
           
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
     This method used to set the image for CometChatReceiverImageMessageBubble class
     - Parameter image: This specifies a `URL` for  the CometChatAvatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
     func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.cf.setImage(with: url)
    }

    
}

/*  ----------------------------------------------------------------------------------------- */
