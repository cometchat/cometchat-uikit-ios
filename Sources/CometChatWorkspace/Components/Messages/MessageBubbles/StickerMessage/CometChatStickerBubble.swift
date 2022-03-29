//
//  CometChatStickerBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro

protocol StickerDelegate: NSObject {
    
    func didLongPressedOnStickerMessage(message: CustomMessage,cell: UITableViewCell)
}

class CometChatStickerBubble: UITableViewCell {
    
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
    @IBOutlet weak var unsafeContentImage: UIImageView!
    
    var bubbleType: BubbleType = CometChatThemeOld.messageList.bubbleType
    weak var stickerDelegate: StickerDelegate?
    
    
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
    @objc public func set(image forMessage: CustomMessage) -> CometChatStickerBubble {
        if let url = URL(string: forMessage.customData?["sticker_url"] as? String ?? "") {
             imageThumbnail.cf.setImage(with: url, placeholder: UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil))
        }else{
            imageThumbnail.image = UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil)
        }
        return self
    }
    
    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatStickerBubble {
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
    @objc public func set(avatar: CometChatAvatar) -> CometChatStickerBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatStickerBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatStickerBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatStickerBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatStickerBubble {
        self.receipt = receipt
        return self
    }
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatStickerBubble {
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
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatStickerBubble {
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
    @objc public func set(messageObject: BaseMessage) -> CometChatStickerBubble {
        self.stickerMessage = messageObject
        return self
    }
    
    @discardableResult
    @objc public func set(replyCount: Int) -> CometChatStickerBubble {
        self.leadingReplyButton.setTitle(String(replyCount), for: .normal)
        self.trailingReplyButton.setTitle(String(replyCount), for: .normal)
        return self
    }
    
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = stickerMessage {
            if message.sender?.uid == CometChatMessages.loggedInUser?.uid {
                return true
            }else{
                return false
            }
        }
        return false
    }

    private func enableLongPress(bool: Bool) {
        if bool == true {
            let longPressOnMessage = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
            background.addGestureRecognizer(longPressOnMessage)
            let longPressOnThumbnail = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
            imageThumbnail.addGestureRecognizer(longPressOnThumbnail)
            imageThumbnail.isUserInteractionEnabled = true
            background.isUserInteractionEnabled = true
        }
    }
    
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            if let stickerMessage = stickerMessage as? CustomMessage {
                stickerDelegate?.didLongPressedOnStickerMessage(message: stickerMessage, cell: self)
            }
        }
    }

    
    var stickerMessage: BaseMessage? {
        didSet {
            if let stickerMessage = stickerMessage as? CustomMessage {
                
                self.set(image: stickerMessage)
                self.set(userName: stickerMessage.sender?.name ?? "")
                self.set(receipt: self.receipt.set(receipt: stickerMessage))
                self.topTime.set(time: stickerMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: stickerMessage.sentAt, forType: .MessageBubbleDate)
                self.set(avatar: self.avatar.setAvatar(avatarUrl: stickerMessage.sender?.avatar ?? "", with: stickerMessage.sender?.name ?? ""))
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
                background.backgroundColor = .clear
                self.enableLongPress(bool: true)
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
    
    
}
