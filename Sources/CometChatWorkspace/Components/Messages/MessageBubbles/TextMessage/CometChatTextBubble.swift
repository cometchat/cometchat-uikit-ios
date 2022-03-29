//
//  CometChatTextBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro

protocol TextDelegate: NSObject {
    func didLongPressedOnTextMessage(message: TextMessage,cell: UITableViewCell)
}


class CometChatTextBubble: UITableViewCell {
    
    @IBOutlet weak var alightmentStack: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var sentimentAnalysisView: UIView!
    @IBOutlet weak var message: HyperlinkLabel!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var sentimentAnalysisButton: UIButton!
    @IBOutlet weak var sentimentAnalysisButtonLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var sentimentAnalysisButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var topTime: CometChatDate!
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var leadingReplyButton: UIButton!
    @IBOutlet weak var trailingReplyButton: UIButton!
    @IBOutlet weak var receipt: CometChatMessageReceipt!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var reactions: CometChatMessageReactions!
    
    var bubbleType: BubbleType = CometChatThemeOld.messageList.bubbleType
    weak var textDelegate: TextDelegate?
    var indexPath: IndexPath?
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
    @objc public func set(corner: CometChatCorner) -> CometChatTextBubble {
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
    public func set(backgroundColor: [Any]?) ->  CometChatTextBubble {
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
    @objc public func set(avatar: CometChatAvatar) -> CometChatTextBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatTextBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatTextBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatTextBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(text: String) -> CometChatTextBubble {
        self.message.text = text
        return self
    }
    
    @discardableResult
    @objc public func set(textFont: UIFont) -> CometChatTextBubble {
        self.message.font = textFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(textColor: UIColor) -> CometChatTextBubble {
        self.message.textColor = textColor
        return self
    }
    
    @discardableResult
    @objc func set(borderColor : UIColor) -> CometChatTextBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatTextBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatTextBubble {
        self.receipt = receipt
        return self
    }
    
    @discardableResult
    @objc public func set(reactions forMessage: TextMessage, with alignment: MessageAlignment) -> CometChatTextBubble {
        self.reactions.parseMessageReactionForMessage(message: forMessage) { (success) in
            if success == true {
                if alignment == .right {
                    self.reactions.collectionView.semanticContentAttribute = .forceRightToLeft
                }
                self.reactions.isHidden = false
            }else{
                self.reactions.isHidden = true
            }
        }
        return self
    }

    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatTextBubble {
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
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatTextBubble {
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
    @objc public func set(messageObject: BaseMessage) -> CometChatTextBubble {
        if messageObject.deletedAt > 0.0 {
            self.deletedMessage = messageObject
        }else{
            self.textMessage = messageObject
        }
        return self
    }
    
    @discardableResult
    @objc public func isMyMessage() -> Bool {
        if let message = textMessage {
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
        }
    }
    
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            if let textMessage = textMessage as? TextMessage {
                textDelegate?.didLongPressedOnTextMessage(message: textMessage, cell: self)
            }
        }
    }
    
    
    var textMessage: BaseMessage? {
        didSet {
            if let textMessage = textMessage as? TextMessage {
                self.set(userName: textMessage.sender?.name ?? "")
                self.set(text: textMessage.text)
                self.set(receipt: self.receipt.set(receipt: textMessage))
                self.topTime.set(time: textMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: textMessage.sentAt, forType: .MessageBubbleDate)
                self.set(avatar:self.avatar.setAvatar(avatarUrl: textMessage.sender?.avatar ?? "", with: textMessage.sender?.name ?? ""))
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(reactions: textMessage, with: .right)
                        self.set(textColor: CometChatThemeOld.messageList.rightBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.rightBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.rightBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(reactions: textMessage, with: .left)
                        self.set(textColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(reactions: textMessage, with: .left)
                        self.set(textColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(reactions: textMessage, with: .left)
                        self.set(textColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    }
                }
                self.enableLongPress(bool: true)
            }
        }
    }
    
    weak var deletedMessage: BaseMessage? {
        didSet {
            self.selectionStyle = .none
            self.receiptStack.isHidden = true
            sentimentAnalysisView.isHidden = true
            if let deletedMessage = deletedMessage {
                if let userName = deletedMessage.sender?.name {
                    name.text = userName + ":"
                }
                self.set(userName: deletedMessage.sender?.name ?? "")
                self.set(text: "THIS_MESSAGE_DELETED".localize())
                self.set(receipt: self.receipt.set(receipt: deletedMessage))
                self.topTime.set(time: Int(deletedMessage.deletedAt), forType: .MessageBubbleDate)
                self.time.set(time: Int(deletedMessage.deletedAt), forType: .MessageBubbleDate)
                
                self.set(avatar: self.avatar.setAvatar(avatarUrl: deletedMessage.sender?.avatar ?? "", with: deletedMessage.sender?.name ?? ""))
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(textColor: CometChatThemeOld.messageList.rightBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.rightBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.rightBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(textColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(textColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(textColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    }
                }
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

        // Configure the view for the selected state
    }
    
}
