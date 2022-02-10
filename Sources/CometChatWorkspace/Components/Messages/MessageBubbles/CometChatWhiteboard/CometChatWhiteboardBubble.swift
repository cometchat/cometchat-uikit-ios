//
//  CometChatFileBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro


class CometChatWhiteboardBubble: UITableViewCell {
    
    @IBOutlet weak var alightmentStack: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var topTime: CometChatDate!
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var leadingReplyButton: UIButton!
    @IBOutlet weak var trailingReplyButton: UIButton!
    @IBOutlet weak var receipt: CometChatMessageReceipt!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var join: UIButton!
    
    var bubbleType: BubbleType = CometChatTheme.messageList.bubbleType
    weak var collaborativeDelegate: CollaborativeDelegate?
    
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
    @objc public func set(title: String) -> CometChatWhiteboardBubble {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatWhiteboardBubble {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatWhiteboardBubble {
        self.title.textColor = titleColor
        return self
    }
  
    
    @discardableResult
    @objc public func set(thumbnailTintColor: UIColor) -> CometChatWhiteboardBubble {
        self.icon.image = UIImage(named: "messages-collaborative-whiteboard.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        self.icon.tintColor = thumbnailTintColor
        return self
    }
    
    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatWhiteboardBubble {
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
    public func set(backgroundColor: [Any]?) ->  CometChatWhiteboardBubble {
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
    @objc func set(borderColor : UIColor) -> CometChatWhiteboardBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatWhiteboardBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }

    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatWhiteboardBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatWhiteboardBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatWhiteboardBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatWhiteboardBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatWhiteboardBubble {
        self.receipt = receipt
        return self
    }
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatWhiteboardBubble {
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
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatWhiteboardBubble {
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
    @objc public func set(messageObject: BaseMessage) -> CometChatWhiteboardBubble {
        self.whiteboardMessage = messageObject
        return self
    }
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = whiteboardMessage {
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
            if let whiteboardMessage = whiteboardMessage as? CustomMessage {
                collaborativeDelegate?.didLongPressedOnCollaborativeWhiteboard(message: whiteboardMessage, cell: self)
            }
        }
    }
    
    
    var whiteboardMessage: BaseMessage? {
        didSet {
            if let whiteboardMessage = whiteboardMessage as? CustomMessage {
                self.set(borderColor: .clear)
                self.set(borderWidth: 1.0)
                self.set(userName: whiteboardMessage.sender?.name ?? "")
                self.set(receipt: self.receipt.set(receipt: whiteboardMessage))
                self.topTime.set(time: whiteboardMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: whiteboardMessage.sentAt, forType: .MessageBubbleDate)
                self.set(avatar: self.avatar.setAvatar(avatarUrl: whiteboardMessage.sender?.avatar ?? "", with: whiteboardMessage.sender?.name ?? ""))
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(title: "YOU_CREATED_WHITEBOARD".localize())
                        self.set(titleColor: CometChatTheme.messageList.rightBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatTheme.messageList.rightBubbleTextColor)
                        self.set(corner: CometChatTheme.messageList.rightBubbleCorners)
                        self.set(backgroundColor: CometChatTheme.messageList.rightBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(title: "YOU_CREATED_WHITEBOARD".localize())
                        self.set(corner: CometChatTheme.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatTheme.messageList.leftBubbleBackgroundColor)
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(title: "HAS_SHARED_WHITEBOARD".localize())
                        self.set(corner: CometChatTheme.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatTheme.messageList.leftBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(title: "HAS_SHARED_WHITEBOARD".localize())
                        self.set(corner: CometChatTheme.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatTheme.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatTheme.messageList.leftBubbleBackgroundColor)
                    }
                }
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
    @IBAction func didJoinPressed(_ sender: Any) {
        if let whiteboardMessage = whiteboardMessage as? CustomMessage {
            collaborativeDelegate?.didOpenWhiteboard(forMessage: whiteboardMessage, cell: self)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
