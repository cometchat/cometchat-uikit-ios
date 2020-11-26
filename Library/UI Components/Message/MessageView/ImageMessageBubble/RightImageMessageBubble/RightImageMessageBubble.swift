
//  RightImageMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class RightImageMessageBubble: UITableViewCell {
    
     // MARK: - Declaration of IBInspectable
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var activityIndicator: CCActivityIndicator!
    @IBOutlet weak var receipt: UIImageView!
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
    
    var mediaMessage: MediaMessage! {
        didSet {
            receiptStack.isHidden = true
            self.reactionView.parseMessageReactionForMessage(message: mediaMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if mediaMessage.sentAt == 0 {
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            }else{
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
                timeStamp.text = String().setMessageTime(time: mediaMessage.sentAt)
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
            if mediaMessage.readAt > 0 {
            receipt.image = UIImage(named: "read", in: UIKitSettings.bundle, compatibleWith: nil)
            timeStamp.text = String().setMessageTime(time: Int(mediaMessage?.readAt ?? 0))
            }else if mediaMessage.deliveredAt > 0 {
            receipt.image = UIImage(named: "delivered", in: UIKitSettings.bundle, compatibleWith: nil)
            timeStamp.text = String().setMessageTime(time: Int(mediaMessage?.deliveredAt ?? 0))
            }else if mediaMessage.sentAt > 0 {
            receipt.image = UIImage(named: "sent", in: UIKitSettings.bundle, compatibleWith: nil)
            timeStamp.text = String().setMessageTime(time: Int(mediaMessage?.sentAt ?? 0))
            }else if mediaMessage.sentAt == 0 {
               receipt.image = UIImage(named: "wait", in: UIKitSettings.bundle, compatibleWith: nil)
               timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
            }
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
            if UIKitSettings.showReadDeliveryReceipts == .disabled {
                receipt.isHidden = true
            }else{
                receipt.isHighlighted = false
            }
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
    This method used to set the image for RightImageMessageBubble class
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
