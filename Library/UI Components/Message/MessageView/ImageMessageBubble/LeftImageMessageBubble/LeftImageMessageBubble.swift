//
//  LeftImageMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro


/*  ----------------------------------------------------------------------------------------- */

class LeftImageMessageBubble: UITableViewCell {
    
    
    // MARK: - Declaration of IBInspectable
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var imageModerationView: UIView!
    @IBOutlet weak var unsafeContentView: UIImageView!
    
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
            if let mediaURL = mediaMessage.metaData, let imageUrl = mediaURL["fileURL"] as? String {
                  let url = URL(string: imageUrl)
                  if (url?.checkFileExist())! {
                      do {
                          let imageData = try Data(contentsOf: url!)
                          let image = UIImage(data: imageData as Data)
                          imageMessage.image = image
                      } catch {
                        
                      }
                  }else{
                      parseThumbnailForImage(forMessage: mediaMessage)
                  }
              }else{
                  parseThumbnailForImage(forMessage: mediaMessage)
              }
              parseImageForModeration(forMessage: mediaMessage)
            if mediaMessage.replyCount != 0 &&  UIKitSettings.threadedChats == .enabled {
                
                replybutton.isHidden = false
                if mediaMessageInThread?.replyCount == 1 {
                    replybutton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = mediaMessageInThread?.replyCount {
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
             nameView.isHidden = false
            if let mediaURL = mediaMessageInThread.metaData, let imageUrl = mediaURL["fileURL"] as? String {
                let url = URL(string: imageUrl)
                if (url?.checkFileExist())! {
                    do {
                        let imageData = try Data(contentsOf: url!)
                        let image = UIImage(data: imageData as Data)
                        imageMessage.image = image
                    } catch {
                     
                    }
                }else{
                    parseThumbnailForImage(forMessage: mediaMessageInThread)
                }
            }else{
                parseThumbnailForImage(forMessage: mediaMessageInThread)
            }
            parseImageForModeration(forMessage: mediaMessageInThread)
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
           replybutton.isHidden = true
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
    
    private func parseThumbnailForImage(forMessage: MediaMessage?) {
         imageMessage.image = nil
         if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let thumbnailGenerationDictionary = cometChatExtension["thumbnail-generation"] as? [String : Any] {
             if let url = URL(string: thumbnailGenerationDictionary["url_medium"] as? String ?? "") {
                 imageMessage.cf.setImage(with: url)
             }
         }else{
             if let url = URL(string: mediaMessage.attachment?.fileUrl ?? "") {
                 imageMessage.cf.setImage(with: url)
             }
         }
     }
     
     private func parseImageForModeration(forMessage: MediaMessage?) {
         if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let imageModerationDictionary = cometChatExtension["image-moderation"] as? [String : Any] {
             if let unsafeContent = imageModerationDictionary["unsafe"] as? String {
                 if unsafeContent == "yes" {
                     imageModerationView.addBlur()
                     imageModerationView.roundViewCorners([.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner], radius: 15)
                     imageModerationView.isHidden = false
                     unsafeContentView.isHidden = false
                 }else{
                     imageModerationView.isHidden = true
                     unsafeContentView.isHidden = true
                 }
                
             }
         }
     }
    
}

/*  ----------------------------------------------------------------------------------------- */
