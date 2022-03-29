//
//  CometChatVideoBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro


class CometChatVideoBubble: UITableViewCell {
    
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var alightmentStack: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var topTime: CometChatDate!
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var videoThumbnail: UIImageView!
    @IBOutlet weak var leadingReplyButton: UIButton!
    @IBOutlet weak var trailingReplyButton: UIButton!
    @IBOutlet weak var receipt: CometChatMessageReceipt!
    @IBOutlet weak var playButton: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    
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
    @objc public func set(image forMessage: MediaMessage) -> CometChatVideoBubble {
        parseThumbnailForImage(forMessage: forMessage)
        return self
    }
    
    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatVideoBubble {
        switch corner.corner {
        case .leftTop:
            self.background.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .rightTop:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
    
        case .leftBottom:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .rightBottom:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner], radius: corner.radius)
        case .none:
            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        }
        return self
    }
    
    @discardableResult
    @objc func set(borderColor : UIColor) -> CometChatVideoBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatVideoBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }
    

    @discardableResult
    public func set(backgroundColor: [Any]?) ->  CometChatVideoBubble {
        if let backgroundColors = backgroundColor as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: backgroundColor)
            }
        }
        return self
    }

    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatVideoBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatVideoBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatVideoBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatVideoBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatVideoBubble {
        self.receipt = receipt
        return self
    }
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatVideoBubble {
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
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatVideoBubble {
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
    @objc public func set(messageObject: BaseMessage) -> CometChatVideoBubble {
      self.videoMessage = messageObject
        return self
    }
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = videoMessage {
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
            let tapOnImageThumbnail = UITapGestureRecognizer(target: self, action: #selector(self.didVideoMessagePressed(tapGestureRecognizer:)))
            self.videoThumbnail.isUserInteractionEnabled = true
            self.videoThumbnail.addGestureRecognizer(tapOnImageThumbnail)
            let tapOnPlayButton = UITapGestureRecognizer(target: self, action: #selector(self.didVideoMessagePressed(tapGestureRecognizer:)))
            self.playButton.isUserInteractionEnabled = true
            self.playButton.addGestureRecognizer(tapOnPlayButton)
        }
    }
    
    
    @objc fileprivate func enableLongPress(bool: Bool) {
        if bool == true {
            let longPressOnImageThumbnail = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
            let longPressOnPlayButton = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))

            self.videoThumbnail.isUserInteractionEnabled = true
            self.videoThumbnail.addGestureRecognizer(longPressOnImageThumbnail)
            self.playButton.isUserInteractionEnabled = true
            self.playButton.addGestureRecognizer(longPressOnPlayButton)
        }
    }
    
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            if let videoMessage = videoMessage as? MediaMessage {
                mediaDelegate?.didLongPressedOnMedia(forMessage: videoMessage, cell: self)
            }
        }
    }
    
    var videoMessage: BaseMessage? {
        didSet {
            if let videoMessage = videoMessage as? MediaMessage {
                self.set(image: videoMessage)
                self.set(userName: videoMessage.sender?.name ?? "")
                self.set(receipt: self.receipt.set(receipt: videoMessage))
                self.topTime.set(time: videoMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: videoMessage.sentAt, forType: .MessageBubbleDate)
                self.set(avatar: self.avatar.setAvatar(avatarUrl: videoMessage.sender?.avatar ?? "", with: videoMessage.sender?.name ?? ""))
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(corner: CometChatThemeOld.messageList.rightBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.rightBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    }
                }
                self.enable(tap: true)
                self.enableLongPress(bool: true)
                if #available(iOS 13.0, *) {
                    self.set(borderColor: .systemFill)
                } else {
                    self.set(borderColor: .lightGray)
                }
                self.set(borderWidth: 1.0)
            }
        }
    }
    
    @objc func didVideoMessagePressed(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let videoMessage = videoMessage as? MediaMessage {
            mediaDelegate?.didOpenMedia(forMessage: videoMessage, cell: self)
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
        videoThumbnail.image = nil
        if let metaData = forMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let thumbnailGenerationDictionary = cometChatExtension["thumbnail-generation"] as? [String : Any] {
            if let url = URL(string: thumbnailGenerationDictionary["url_medium"] as? String ?? "") {
                videoThumbnail.cf.setImage(with: url)
            }
        }else{
            if let url = URL(string: (videoMessage as? MediaMessage)?.attachment?.fileUrl ?? "") {
                videoThumbnail.cf.setImage(with: url)
            }
        }
    }
}
