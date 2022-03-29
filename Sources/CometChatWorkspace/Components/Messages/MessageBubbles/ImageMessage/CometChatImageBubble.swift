//
//  CometChatImageBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro

protocol MediaDelegate: NSObject {
    func didOpenMedia(forMessage: MediaMessage, cell: UITableViewCell)
    func didLongPressedOnMedia(forMessage: MediaMessage, cell: UITableViewCell)
}


class CometChatImageBubble: UITableViewCell {
    
    @IBOutlet weak var alightmentStack: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var topTime: CometChatDate!
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var imageThumbnail: UIImageView!
    @IBOutlet weak var leadingReplyButton: UIButton!
    @IBOutlet weak var trailingReplyButton: UIButton!
    @IBOutlet weak var receipt: CometChatMessageReceipt!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var imageModerationView: UIView!
    @IBOutlet weak var unsafeContentImage: UIImageView!
    
    var bubbleType: BubbleType = CometChatThemeOld.messageList.bubbleType
    weak var mediaDelegate: MediaDelegate?
    
    unowned var selectionColor: UIColor {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.white
        }
    }
    
    @discardableResult
    @objc public func set(image forMessage: MediaMessage) -> CometChatImageBubble {
        if let mediaURL = forMessage.metaData, let imageUrl = mediaURL["fileURL"] as? String {
            let url = URL(string: imageUrl)
            if (url?.checkFileExist())! {
                do {
                    let imageData = try Data(contentsOf: url!)
                    let image = UIImage(data: imageData as Data)
                    imageThumbnail.image = image
                } catch {
                  
                }
            }else{
                parseThumbnailForImage(forMessage: forMessage)
            }
        }else{
            parseThumbnailForImage(forMessage: forMessage)
        }
        parseImageForModeration(forMessage: forMessage)
        return self
    }
    
    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatImageBubble {
        switch corner.corner {
        case .leftTop:
            self.background.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
            self.imageModerationView.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .rightTop:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
            self.imageModerationView.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .leftBottom:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
            self.imageModerationView.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .rightBottom:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner], radius: corner.radius)
            self.imageModerationView.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner], radius: corner.radius)
        case .none:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
            self.imageModerationView.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        }
        return self
    }
    
    @discardableResult
    @objc func set(borderColor : UIColor) -> CometChatImageBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatImageBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }

    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatImageBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatImageBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatImageBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatImageBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatImageBubble {
        self.receipt = receipt
        return self
    }
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatImageBubble {
        switch  bubbleType {
        case .standard:
            self.topTime.isHidden = true
            self.time.isHidden = false
            self.topTime = time
            self.time = time
        case .leftAligned:
            self.topTime.isHidden = false
            self.time.isHidden = true
            self.topTime = time
            self.time = time
        }
        return self
    }
    
    @discardableResult
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatImageBubble {
        switch messageAlignment {
        case .left:
            name.isHidden = false
            alightmentStack.alignment = .leading
            spacer.isHidden = false
            avatar.isHidden = false
            receipt.isHidden = true
            leadingReplyButton.isHidden = true
            trailingReplyButton.isHidden = true
            
        case .right:
            alightmentStack.alignment = .trailing
            spacer.isHidden = true
            avatar.isHidden = true
            name.isHidden = true
            receipt.isHidden = false
            leadingReplyButton.isHidden = true
            trailingReplyButton.isHidden = true
        }
        return self
    }
    
    @discardableResult
    @objc public func set(messageObject: BaseMessage) -> CometChatImageBubble {
        self.imageMessage = messageObject
        return self
    }
    
    @discardableResult
    @objc public func set(replyCount: Int) -> CometChatImageBubble {
        self.leadingReplyButton.setTitle(String(replyCount), for: .normal)
        self.trailingReplyButton.setTitle(String(replyCount), for: .normal)
        return self
    }
    
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = imageMessage {
            if message.sender?.uid == CometChatMessages.loggedInUser?.uid {
                return true
            }else{
                return false
            }
        }
        return false
    }

    @objc fileprivate func enable(tap: Bool) {
        if tap == true {
            let tapOnImageThumbnail = UITapGestureRecognizer(target: self, action: #selector(self.didImageMessagePressed(tapGestureRecognizer:)))
            let tapOnImageModerationView = UITapGestureRecognizer(target: self, action: #selector(self.didImageMessagePressed(tapGestureRecognizer:)))
            let tapOnImageUnsafeContentImage = UITapGestureRecognizer(target: self, action: #selector(self.didImageMessagePressed(tapGestureRecognizer:)))
            tapOnImageThumbnail.numberOfTapsRequired = 1
            tapOnImageModerationView.numberOfTapsRequired = 1
            tapOnImageModerationView.numberOfTapsRequired = 1
            self.imageThumbnail.isUserInteractionEnabled = true
            self.imageThumbnail.addGestureRecognizer(tapOnImageThumbnail)
            self.imageModerationView.isUserInteractionEnabled = true
            self.imageModerationView.addGestureRecognizer(tapOnImageModerationView)
            self.unsafeContentImage.isUserInteractionEnabled = true
            self.unsafeContentImage.addGestureRecognizer(tapOnImageUnsafeContentImage)
        }
    }
    
    @objc fileprivate func enableLongPress(bool: Bool) {
        if bool == true {
            let longPressOnImageThumbnail = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
            let longPressOnImageModerationView = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
            let longPressOnImageUnsafeContentImage = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
            self.imageThumbnail.isUserInteractionEnabled = true
            self.imageThumbnail.addGestureRecognizer(longPressOnImageThumbnail)
            self.imageModerationView.isUserInteractionEnabled = true
            self.imageModerationView.addGestureRecognizer(longPressOnImageModerationView)
            self.unsafeContentImage.isUserInteractionEnabled = true
            self.unsafeContentImage.addGestureRecognizer(longPressOnImageUnsafeContentImage)
        }
    }
    
    
    var imageMessage: BaseMessage? {
        didSet {
            if let imageMessage = imageMessage as? MediaMessage {
                self.set(image: imageMessage)
                self.set(userName: imageMessage.sender?.name ?? "")
                self.set(receipt: self.receipt.set(receipt: imageMessage))
                self.topTime.set(time: imageMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: imageMessage.sentAt, forType: .MessageBubbleDate)
                self.set(avatar: self.avatar.setAvatar(avatarUrl: imageMessage.sender?.avatar ?? "", with: imageMessage.sender?.name ?? ""))
                if #available(iOS 13.0, *) {
                    self.set(borderColor: .systemFill)
                } else {
                    self.set(borderColor: .lightGray)
                }
                self.set(borderWidth: 1.0)
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(corner: CometChatThemeOld.messageList.rightBubbleCorners)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                    }
                }
                self.enable(tap: true)
                self.enableLongPress(bool: true)
            }
        }
    }
    
    @objc func didImageMessagePressed(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let imageMessage = imageMessage as? MediaMessage {
            mediaDelegate?.didOpenMedia(forMessage: imageMessage, cell: self)
        }
    }
    
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            if let imageMessage = imageMessage as? MediaMessage {
                mediaDelegate?.didLongPressedOnMedia(forMessage: imageMessage, cell: self)
            }
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
    
    private func parseThumbnailForImage(forMessage: MediaMessage?) {
        imageThumbnail.image = nil
        if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let thumbnailGenerationDictionary = cometChatExtension["thumbnail-generation"] as? [String : Any] {
            if let url = URL(string: thumbnailGenerationDictionary["url_medium"] as? String ?? "") {
                imageThumbnail.cf.setImage(with: url)
            }
        }else{
            if let url = URL(string: (imageMessage as? MediaMessage)?.attachment?.fileUrl ?? "") {
                imageThumbnail.cf.setImage(with: url)
            }
        }
    }
    
    private func parseImageForModeration(forMessage: MediaMessage?) {
        if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let imageModerationDictionary = cometChatExtension["image-moderation"] as? [String : Any] {
            if let unsafeContent = imageModerationDictionary["unsafe"] as? String {
                if unsafeContent == "yes" {
                    imageModerationView.addBlur()
                    imageModerationView.isHidden = false
                    unsafeContentImage.isHidden = false
                }else{
                    imageModerationView.isHidden = true
                    unsafeContentImage.isHidden = true
                }
            }else{
                parseThumbnailForImage(forMessage: forMessage)
            }
        }else{
            parseThumbnailForImage(forMessage: forMessage)
        }
    }
}
