
//  CometChatSenderImageMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

protocol MediaDelegate: NSObject {
    func didOpenMedia(forMessage: MediaMessage, cell: UITableViewCell)
}


/*  ----------------------------------------------------------------------------------------- */

class CometChatSenderImageMessageBubble: UITableViewCell {
    
     // MARK: - Declaration of IBInspectable
    
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var activityIndicator: CCActivityIndicator!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var imageModerationView: UIView!
    @IBOutlet weak var unsafeContentView: UIImageView!
    @IBOutlet weak var imageContainer: UIView!
    
    
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
    
    var mediaMessage: MediaMessage! {
        didSet {
            imageContainer.layer.cornerRadius = 12
            imageContainer.layer.borderWidth = 1
            if #available(iOS 13.0, *) {
                imageContainer.layer.borderColor = UIColor.systemFill.cgColor
            } else {
                imageContainer.layer.borderColor = UIColor.lightText.cgColor
            }
            imageContainer.clipsToBounds = true
            receiptStack.isHidden = true
            self.reactionView.parseMessageReactionForMessage(message: mediaMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if mediaMessage.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
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
            receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)
            timeStamp.text = String().setMessageTime(time: Int(mediaMessage?.readAt ?? 0))
            }else if mediaMessage.deliveredAt > 0 {
            receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            timeStamp.text = String().setMessageTime(time: Int(mediaMessage?.deliveredAt ?? 0))
            }else if mediaMessage.sentAt > 0 {
            receipt.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            timeStamp.text = String().setMessageTime(time: Int(mediaMessage?.sentAt ?? 0))
            }else if mediaMessage.sentAt == 0 {
               receipt.image = UIImage(named: "messages-wait", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
               timeStamp.text = "SENDING".localized()
            }
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
            FeatureRestriction.isDeliveryReceiptsEnabled { (success) in
                switch success {
                case .enabled: self.receipt.isHidden = false
                case .disabled: self.receipt.isHidden = true
                }
            }
            
            let tapOnImageMessage = UITapGestureRecognizer(target: self, action: #selector(self.didImageMessagePressed(tapGestureRecognizer:)))
            let tapOnImageMessage2 = UITapGestureRecognizer(target: self, action: #selector(self.didImageMessagePressed(tapGestureRecognizer:)))
            let tapOnImageMessage3 = UITapGestureRecognizer(target: self, action: #selector(self.didImageMessagePressed(tapGestureRecognizer:)))
            self.imageMessage.isUserInteractionEnabled = true
            self.imageMessage.addGestureRecognizer(tapOnImageMessage)
            self.imageModerationView.isUserInteractionEnabled = true
            self.imageModerationView.addGestureRecognizer(tapOnImageMessage2)
            self.unsafeContentView.isUserInteractionEnabled = true
            self.unsafeContentView.addGestureRecognizer(tapOnImageMessage3)
        }
    }
    
     // MARK: - Initialization of required Methods
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        
        if let message = mediaMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
        }
    }
    
    @objc func didImageMessagePressed(tapGestureRecognizer: UITapGestureRecognizer)
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
       }
    
    
    /**
    This method used to set the image for CometChatSenderImageMessageBubble class
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
