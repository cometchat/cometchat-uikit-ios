//
//  CometChatAudioBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro


class CometChatAudioBubble: UITableViewCell {
    
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
    @objc public func set(title: String) -> CometChatAudioBubble {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatAudioBubble {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatAudioBubble {
        self.title.textColor = titleColor
        return self
    }
    
    @discardableResult
    @objc public func set(subTitle: String) -> CometChatAudioBubble {
        self.subtitle.text = subTitle
        return self
    }
    
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> CometChatAudioBubble {
        self.subtitle.font = subTitleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> CometChatAudioBubble {
        self.subtitle.textColor = subTitleColor
        return self
    }
    
    @discardableResult
    @objc public func set(typeText: String) -> CometChatAudioBubble {
        self.type.text = typeText
        return self
    }
    
    @discardableResult
    @objc public func set(typeFont: UIFont) -> CometChatAudioBubble {
        self.type.font = typeFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(typeColor: UIColor) -> CometChatAudioBubble {
        self.type.textColor = typeColor
        return self
    }
    
    @discardableResult
    @objc public func set(iconTintColor: UIColor) -> CometChatAudioBubble {
        self.thumbnail.image = UIImage(named: "messages-audio-file.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        self.thumbnail.tintColor = iconTintColor
        return self
    }
    
    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatAudioBubble {
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
    public func set(backgroundColor: [Any]?) ->  CometChatAudioBubble {
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
    @objc func set(borderColor : UIColor) -> CometChatAudioBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatAudioBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }

    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatAudioBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatAudioBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatAudioBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatAudioBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatAudioBubble {
        self.receipt = receipt
        return self
    }
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatAudioBubble {
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
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatAudioBubble {
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
    @objc public func set(messageObject: BaseMessage) -> CometChatAudioBubble {
        self.audioMessage = messageObject
        return self
    }
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = audioMessage {
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
            let tapOnThumbnail = UITapGestureRecognizer(target: self, action: #selector(self.didAudioMessagePressed(tapGestureRecognizer:)))
            let tapOnBackground = UITapGestureRecognizer(target: self, action: #selector(self.didAudioMessagePressed(tapGestureRecognizer:)))
            self.background.isUserInteractionEnabled = true
            self.background.addGestureRecognizer(tapOnBackground)
            self.thumbnail.isUserInteractionEnabled = true
            self.thumbnail.addGestureRecognizer(tapOnThumbnail)
        }
    }
    
    
    var audioMessage: BaseMessage? {
        didSet {
            if let audioMessage = audioMessage as? MediaMessage {
                self.set(title: audioMessage.attachment?.fileName.capitalized ?? "")
                self.set(typeText: audioMessage.attachment?.fileExtension.uppercased() ?? "")
                if let fileSize = audioMessage.attachment?.fileSize {
                    set(subTitle: Units(bytes: Int64(fileSize)).getReadableUnit())
                }
                self.set(userName: audioMessage.sender?.name ?? "")
                self.set(receipt: self.receipt.set(receipt: audioMessage))
                self.topTime.set(time: audioMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: audioMessage.sentAt, forType: .MessageBubbleDate)
                self.set(avatar: self.avatar.setAvatar(avatarUrl: audioMessage.sender?.avatar ?? "", with: audioMessage.sender?.name ?? ""))
                self.set(borderColor: .clear)
                self.set(borderWidth: 1.0)
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(titleColor: CometChatThemeOld.messageList.rightBubbleTextColor)
                        self.set(subTitleColor: CometChatThemeOld.messageList.rightBubbleTextColor)
                        self.set(typeColor: CometChatThemeOld.messageList.rightBubbleTextColor)
                       // self.set(thumbnailTintColor: CometChatThemeOld.messageList.rightBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.rightBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.rightBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(subTitleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(typeColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                     //   self.set(thumbnailTintColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(subTitleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(typeColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                       // self.set(thumbnailTintColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(subTitleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(typeColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                      //  self.set(thumbnailTintColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    }
                }
                self.enable(tap: true)
                self.enableLongPress(bool: true)
            }
        }
    }
    
    @objc func didAudioMessagePressed(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if let audioMessage = audioMessage as? MediaMessage {
            mediaDelegate?.didOpenMedia(forMessage: audioMessage, cell: self)
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
            if let audioMessage = audioMessage as? MediaMessage {
                mediaDelegate?.didLongPressedOnMedia(forMessage: audioMessage, cell: self)
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
