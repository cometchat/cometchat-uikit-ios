//
//  CometChatFileBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro


class CometChatFileBubble: UITableViewCell {
    
    @IBOutlet weak var alightmentStack: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var topTime: CometChatDate!
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var leadingReplyButton: UIButton!
    @IBOutlet weak var trailingReplyButton: UIButton!
    @IBOutlet weak var receipt: CometChatMessageReceipt!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var type: UILabel!
    
    var bubbleType: BubbleType = CometChatTheme.messageList.bubbleType
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
    @objc public func set(title: String) -> CometChatFileBubble {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatFileBubble {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatFileBubble {
        self.title.textColor = titleColor
        return self
    }
    
    @discardableResult
    @objc public func set(subTitle: String) -> CometChatFileBubble {
        self.subtitle.text = subTitle
        return self
    }
    
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> CometChatFileBubble {
        self.subtitle.font = subTitleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> CometChatFileBubble {
        self.subtitle.textColor = subTitleColor
        return self
    }
    
    @discardableResult
    @objc public func set(typeText: String) -> CometChatFileBubble {
        self.type.text = typeText
        return self
    }
    
    @discardableResult
    @objc public func set(typeFont: UIFont) -> CometChatFileBubble {
        self.type.font = typeFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(typeColor: UIColor) -> CometChatFileBubble {
        self.type.textColor = typeColor
        return self
    }
    
    @discardableResult
    @objc public func set(thumbnailTintColor: UIColor) -> CometChatFileBubble {
        self.thumbnail.image = UIImage(named: "messages-file-upload.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        self.thumbnail.tintColor = thumbnailTintColor
        return self
    }
    
    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatFileBubble {
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
        self.background.clipsToBounds = true
        return self
    }
    

    
    @discardableResult
    public func set(backgroundColor: [Any]?) ->  CometChatFileBubble {
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
    @objc func set(borderColor : UIColor) -> CometChatFileBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatFileBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }

    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatFileBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatFileBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatFileBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatFileBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatFileBubble {
        self.receipt = receipt
        return self
    }
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatFileBubble {
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
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatFileBubble {
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
    @objc public func set(messageObject: BaseMessage) -> CometChatFileBubble {
        self.fileMessage = messageObject
        return self
    }
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = fileMessage {
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
            let tapOnThumbnail = UITapGestureRecognizer(target: self, action: #selector(self.didFileMessagePressed(tapGestureRecognizer:)))
            let tapOnBackground = UITapGestureRecognizer(target: self, action: #selector(self.didFileMessagePressed(tapGestureRecognizer:)))
            self.background.isUserInteractionEnabled = true
            self.background.addGestureRecognizer(tapOnBackground)
            self.thumbnail.isUserInteractionEnabled = true
            self.thumbnail.addGestureRecognizer(tapOnThumbnail)
        }
    }
    
    @objc fileprivate func enableLongPress(bool: Bool) {
        if bool == true {
            let longPressOnBackground = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
            self.background.isUserInteractionEnabled = true
            self.background.addGestureRecognizer(longPressOnBackground)
        }
    }
    
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            if let fileMessage = fileMessage as? MediaMessage {
                mediaDelegate?.didLongPressedOnMedia(forMessage: fileMessage, cell: self)
            }
        }
    }
    
    
    
    var fileMessage: BaseMessage? {
        didSet {
            if let fileMessage = fileMessage as? MediaMessage {
                self.set(title: fileMessage.attachment?.fileName.capitalized ?? "")
                self.set(typeText: fileMessage.attachment?.fileExtension.uppercased() ?? "")
                if let fileSize = fileMessage.attachment?.fileSize {
                    set(subTitle: Units(bytes: Int64(fileSize)).getReadableUnit())
                }
                self.set(userName: fileMessage.sender?.name ?? "")
                self.set(receipt: self.receipt.set(receipt: fileMessage))
                self.topTime.set(time: fileMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: fileMessage.sentAt, forType: .MessageBubbleDate)
                self.avatar.setAvatar(avatarUrl: fileMessage.sender?.avatar ?? "", with: fileMessage.sender?.name ?? "")
                self.set(borderColor: .clear)
                self.set(borderWidth: 1.0)
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(titleColor: CometChatTheme.messageList.rightBubbleTextColor)
                        self.set(subTitleColor: CometChatTheme.messageList.rightBubbleTextColor)
                        self.set(typeColor: CometChatTheme.messageList.rightBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatTheme.messageList.rightBubbleTextColor)
                        self.set(corner: CometChatTheme.messageList.rightBubbleCorners)
                        self.set(backgroundColor: CometChatTheme.messageList.rightBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatTheme.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(subTitleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(typeColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatTheme.messageList.leftBubbleBackgroundColor)
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatTheme.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(subTitleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(typeColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatTheme.messageList.leftBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatTheme.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(subTitleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(typeColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatTheme.messageList.leftBubbleBackgroundColor)
                    }
                }
                self.enable(tap: true)
                self.enableLongPress(bool: true)
            }
        }
    }
    
    @objc func didFileMessagePressed(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let fileMessage = fileMessage as? MediaMessage {
            mediaDelegate?.didOpenMedia(forMessage: fileMessage, cell: self)
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
