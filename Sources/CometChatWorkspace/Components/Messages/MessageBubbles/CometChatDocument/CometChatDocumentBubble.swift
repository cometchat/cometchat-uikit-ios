//
//  CometChatFileBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro


protocol CollaborativeDelegate: NSObject {
    func didOpenWhiteboard(forMessage: CustomMessage, cell: UITableViewCell)
    func didOpenDocument(forMessage: CustomMessage, cell: UITableViewCell)
    func didLongPressedOnCollaborativeWhiteboard(message: CustomMessage,cell: UITableViewCell)
    func didLongPressedOnCollaborativeDocument(message: CustomMessage,cell: UITableViewCell)
}

class CometChatDocumentBubble: UITableViewCell {
    
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
    
    var bubbleType: BubbleType = CometChatThemeOld.messageList.bubbleType
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
    @objc public func set(title: String) -> CometChatDocumentBubble {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatDocumentBubble {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatDocumentBubble {
        self.title.textColor = titleColor
        return self
    }
  
    
    @discardableResult
    @objc public func set(thumbnailTintColor: UIColor) -> CometChatDocumentBubble {
        self.icon.image = UIImage(named: "messages-collaborative-document.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        self.icon.tintColor = thumbnailTintColor
        return self
    }
    
    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatDocumentBubble {
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
    public func set(backgroundColor: [Any]?) ->  CometChatDocumentBubble {
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
    @objc func set(borderColor : UIColor) -> CometChatDocumentBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatDocumentBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }

    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatDocumentBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatDocumentBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatDocumentBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatDocumentBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatDocumentBubble {
        self.receipt = receipt
        return self
    }
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatDocumentBubble {
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
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatDocumentBubble {
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
    @objc public func set(messageObject: BaseMessage) -> CometChatDocumentBubble {
        self.documentMessage = messageObject
        return self
    }
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = documentMessage {
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
            if let documentMessage = documentMessage as? CustomMessage {
                collaborativeDelegate?.didLongPressedOnCollaborativeDocument(message: documentMessage, cell: self)
            }
        }
    }
    
    
    var documentMessage: BaseMessage? {
        didSet {
            if let documentMessage = documentMessage as? CustomMessage {
                self.set(borderColor: .clear)
                self.set(borderWidth: 1.0)
                self.set(userName: documentMessage.sender?.name ?? "")
                self.set(receipt: self.receipt.set(receipt: documentMessage))
                self.topTime.set(time: documentMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: documentMessage.sentAt, forType: .MessageBubbleDate)
                self.set(avatar: self.avatar.setAvatar(avatarUrl: documentMessage.sender?.avatar ?? "", with: documentMessage.sender?.name ?? ""))
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(title: "YOU_CREATED_DOCUMENT".localize())
                        self.set(titleColor: CometChatThemeOld.messageList.rightBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatThemeOld.messageList.rightBubbleTextColor)
                        self.set(corner: CometChatThemeOld.messageList.rightBubbleCorners)
                        self.set(backgroundColor: CometChatThemeOld.messageList.rightBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(title: "YOU_CREATED_DOCUMENT".localize())
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(title: "HAS_SHARED_COLLABORATIVE_DOCUMENT".localize())
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(title: "HAS_SHARED_COLLABORATIVE_DOCUMENT".localize())
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(thumbnailTintColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        self.set(backgroundColor: CometChatThemeOld.messageList.leftBubbleBackgroundColor)
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
        if let documentMessage = documentMessage as? CustomMessage {
            collaborativeDelegate?.didOpenDocument(forMessage: documentMessage, cell: self)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
