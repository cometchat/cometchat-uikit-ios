
//  CometChatSenderVideoMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro
import AVFoundation
import AVKit
import CoreMedia

/*  ----------------------------------------------------------------------------------------- */

class CometChatSenderVideoMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBInspectable
    
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var heightReactions: NSLayoutConstraint!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var activityIndicator: CCActivityIndicator!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var videoView: UIView!
    
    
    // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    weak var mediaDelegate: MediaDelegate?
    private var image = UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil)
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
            self.reactionView.parseMessageReactionForMessage(message: mediaMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            receiptStack.isHidden = true
            if mediaMessage.sentAt == 0 {
                timeStamp.text = "SENDING".localized()
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            }else{
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
                timeStamp.text = String().setMessageTime(time: mediaMessage.sentAt)
            }
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
            FeatureRestriction.isDeliveryReceiptsEnabled { (success) in
                switch success {
                case .enabled: self.receipt.isHidden = false
                case .disabled: self.receipt.isHidden = true
                }
            }
            let tapOnVideoMessage = UITapGestureRecognizer(target: self, action: #selector(self.didVideoMessagePressed(tapGestureRecognizer:)))
            self.imageMessage.isUserInteractionEnabled = true
            self.imageMessage.addGestureRecognizer(tapOnVideoMessage)
            self.videoView.isUserInteractionEnabled = true
            self.videoView.addGestureRecognizer(tapOnVideoMessage)
            calculateHeightForReactions(reactionView: reactionView, heightReactions: heightReactions)
        }
    }
    
    // MARK: - Initialization of required Methods
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        
        if let message = mediaMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
        }
        
    }
    
    @IBAction func didPlayButtonPressed(_ sender: Any) {
        mediaDelegate?.didOpenMedia(forMessage: mediaMessage, cell: self)
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
    }
    
    override func prepareForReuse() {
        imageRequest?.cancel()
        imageMessage.image = image
        reactionView.reactions.removeAll()
    }
    
    private func parseThumbnailForVideo(forMessage: MediaMessage?) {
        if let attachment = forMessage?.metaData?["fileURL"] as? String , let fileUrl = URL(string: attachment), fileUrl.checkFileExist() {
            createVideoThumbnail(url: fileUrl, completion: { [weak self]  (image) in
                guard let this = self else { return }
                if let image = image {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                        this.imageMessage.image = image
                    }
                } else {
                    this.imageMessage.image = UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil)
                }
            })
            
        } else {
            
            if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let thumbnailGenerationDictionary = cometChatExtension["thumbnail-generation"] as? [String : Any] {
                if let url = URL(string: thumbnailGenerationDictionary["url_medium"] as? String ?? "") {
                    
                    if let time = forMessage?.sentAt {
                        let date = Date(timeIntervalSince1970: TimeInterval(time))
                        let secondsAgo = Int(Date().timeIntervalSince(date))
                        var timeinterval = 0.0
                        
                        _ = Timer.scheduledTimer(withTimeInterval: timeinterval, repeats: secondsAgo > 5 ? false : true) { [weak self] (timer) in
                            guard let this  = self else { return }
                            this.imageRequest = this.imageService.image(for: url) { [weak self] image in
                                guard let strongSelf = self else { return }
                                if let image = image {
                                    strongSelf.imageMessage.image = image
                                    timer.invalidate()
                                }
                                else {
                                    strongSelf.imageMessage.image = strongSelf.image
                                }
                            }
                            timeinterval = 1.0
                        }
                    }
                }
            } else {
                imageMessage.image = self.image
            }
        }
    }
    
}



