//
//  CometChatReceiverImageMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


/*  ----------------------------------------------------------------------------------------- */

class CometChatReceiverVideoMessageBubble: UITableViewCell {
    
    
    // MARK: - Declaration of IBInspectable
    
    
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var tintedView: UIView!
    
    // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    weak var mediaDelegate: MediaDelegate?
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
    
    var mediaMessage: MediaMessage!{
        didSet {
            self.reactionView.parseMessageReactionForMessage(message: mediaMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if let userName = mediaMessage.sender?.name {
                name.text = userName + ":"
            }
            if mediaMessage.receiverType == .group {
                nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            self.receiptStack.isHidden = true
            timeStamp.text = String().setMessageTime(time: mediaMessage.sentAt)
            if let avatarURL = mediaMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: mediaMessage.sender?.name ?? "")
            }else{
                avatar.set(image: "", with: mediaMessage.sender?.name ?? "")
            }
            parseThumbnailForVideo(forMessage: mediaMessage)
            FeatureRestriction.isThreadedMessagesEnabled { (success) in
                switch success {
                case .enabled where self.mediaMessage.replyCount != 0 :
                    self.replybutton.isHidden = false
                    if self.mediaMessage.replyCount == 1 {
                        self.replybutton.setTitle("ONE_REPLY".localized(), for: .normal)
                    }else{
                        if let replies = self.mediaMessage.replyCount as? Int {
                            self.replybutton.setTitle("\(replies) replies", for: .normal)
                        }
                    }
                case .disabled, .enabled : self.replybutton.isHidden = true
                }
            }
            replybutton.tintColor = UIKitSettings.primaryColor
            let tapOnVideoMessage = UITapGestureRecognizer(target: self, action: #selector(self.didVideoMessagePressed(tapGestureRecognizer:)))
            self.imageMessage.isUserInteractionEnabled = true
            self.imageMessage.addGestureRecognizer(tapOnVideoMessage)
        }
    }
    
    var mediaMessageInThread: MediaMessage! {
          didSet {
              receiptStack.isHidden = true
            self.reactionView.parseMessageReactionForMessage(message: mediaMessageInThread) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
              if mediaMessageInThread.sentAt == 0 {
                  timeStamp.text = "SENDING".localized()
              }else{
               
                  timeStamp.text = String().setMessageTime(time: mediaMessageInThread.sentAt)
              }
              if mediaMessageInThread.readAt > 0 {
              timeStamp.text = String().setMessageTime(time: Int(mediaMessageInThread?.readAt ?? 0))
              }else if mediaMessageInThread.deliveredAt > 0 {
              timeStamp.text = String().setMessageTime(time: Int(mediaMessageInThread?.deliveredAt ?? 0))
              }else if mediaMessageInThread.sentAt > 0 {
              timeStamp.text = String().setMessageTime(time: Int(mediaMessageInThread?.sentAt ?? 0))
              }else if mediaMessageInThread.sentAt == 0 {
                 timeStamp.text = "SENDING".localized()
                 name.text = LoggedInUser.name.capitalized + ":"
              }
              parseThumbnailForVideo(forMessage: mediaMessageInThread)
            if let avatarURL = mediaMessageInThread.sender?.avatar  {
                avatar.set(image: avatarURL, with: mediaMessageInThread.sender?.name ?? "")
            }else{
                avatar.set(image: "", with: mediaMessageInThread.sender?.name ?? "")
            }
             replybutton.isHidden = true
             nameView.isHidden = false
          }
      }
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        if let message = mediaMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
        }
       }

     
    @objc func didVideoMessagePressed(tapGestureRecognizer: UITapGestureRecognizer)
    {
        mediaDelegate?.didOpenMedia(forMessage: mediaMessage, cell: self)
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
           switch isEditing {
           case true:
               switch selected {
               case true: self.tintedView.isHidden = false
               case false: self.tintedView.isHidden = true
               }
           case false: break
           }
       }
    
    
    /**
     This method used to set the image for CometChatReceiverImageMessageBubble class
     - Parameter image: This specifies a `URL` for  the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     */
    
     func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.cf.setImage(with: url)
    }
    
    private func parseThumbnailForVideo(forMessage: MediaMessage?) {
        imageMessage.image = nil
        if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let thumbnailGenerationDictionary = cometChatExtension["thumbnail-generation"] as? [String : Any] {
            if let url = URL(string: thumbnailGenerationDictionary["url_medium"] as? String ?? "") {
             self.imageMessage.cf.setImage(with: url)
            }
        }else{
         imageMessage.image = UIImage(color: #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
        }
    }
}
