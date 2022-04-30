
//  CometChatSenderImageMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatSenderStickerMessageBubble: UITableViewCell {
    
     // MARK: - Declaration of IBInspectable
    
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    
    
    // MARK: - Declaration of Variables
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
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
    
    var stickerMessage: CustomMessage! {
        didSet {
            receiptStack.isHidden = true
            if let url = URL(string: stickerMessage.customData?["sticker_url"] as? String ?? "") {
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    // Update Thumbnail Image View
                    if let image = image {
                        strongSelf.imageMessage.image = image
                    }else{
                        strongSelf.imageMessage.image = UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil)
                    }
                }
            }else{
                imageMessage.image = UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil)
            }
            self.reactionView.parseMessageReactionForMessage(message: stickerMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if stickerMessage.readAt > 0 {
            receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)
            timeStamp.text = String().setMessageTime(time: Int(stickerMessage?.readAt ?? 0))
            }else if stickerMessage.deliveredAt > 0 {
            receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            timeStamp.text = String().setMessageTime(time: Int(stickerMessage?.deliveredAt ?? 0))
            }else if stickerMessage.sentAt > 0 {
            receipt.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            timeStamp.text = String().setMessageTime(time: Int(stickerMessage?.sentAt ?? 0))
            }else if stickerMessage.sentAt == 0 {
               receipt.image = UIImage(named: "messages-wait", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
               timeStamp.text = "SENDING".localized()
            }
            FeatureRestriction.isThreadedMessagesEnabled { (success) in
                switch success {
                case .enabled where self.stickerMessage.replyCount != 0 :
                    self.replybutton.isHidden = false
                    if self.stickerMessage.replyCount == 1 {
                        self.replybutton.setTitle("ONE_REPLY".localized(), for: .normal)
                    }else{
                        if let replies = self.stickerMessage.replyCount as? Int {
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
    
    
    override func prepareForReuse() {
        imageRequest?.cancel()
    }
  
   
}
