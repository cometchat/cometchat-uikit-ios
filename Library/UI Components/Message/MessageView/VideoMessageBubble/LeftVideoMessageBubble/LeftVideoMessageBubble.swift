//
//  LeftImageMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


/*  ----------------------------------------------------------------------------------------- */

class LeftVideoMessageBubble: UITableViewCell {
    
    
    // MARK: - Declaration of IBInspectable
    
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var tintedView: UIView!
    
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
            }
            parseThumbnailForVideo(forMessage: mediaMessage)
            if mediaMessage?.replyCount != 0 &&  UIKitSettings.threadedChats == .enabled {
                replybutton.isHidden = false
                if mediaMessage?.replyCount == 1 {
                    replybutton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = mediaMessage?.replyCount {
                        replybutton.setTitle("\(replies) replies", for: .normal)
                    }
                }
            }else{
                replybutton.isHidden = true
            }
            replybutton.tintColor = UIKitSettings.primaryColor
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
                  timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
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
                 timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                 name.text = LoggedInUser.name.capitalized + ":"
              }
              parseThumbnailForVideo(forMessage: mediaMessageInThread)
              
             replybutton.isHidden = true
             nameView.isHidden = false
          }
      }
    
    // MARK: - Initialization of required Methods
    @IBAction func didReplyButtonPressed(_ sender: Any) {
           if let message = mediaMessage, let indexpath = indexPath {
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
     This method used to set the image for LeftImageMessageBubble class
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
