//
//  CometChatFileBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro


protocol CustomDelegate: NSObject {
    func onClick(forMessage: CustomMessage, cell: UITableViewCell)
    func onLongPress(message: CustomMessage,cell: UITableViewCell)
}

class CometChatCustomBubble: UITableViewCell {
    
    @IBOutlet weak var alightmentStack: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var topTime: CometChatDate!
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var leadingReplyButton: UIButton!
    @IBOutlet weak var trailingReplyButton: UIButton!
    @IBOutlet weak var receipt: CometChatMessageReceipt!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var customView: UIView!
    @IBOutlet weak var customViewHeight: NSLayoutConstraint!
    @IBOutlet weak var customViewWidth: NSLayoutConstraint!
    
    var bubbleType: BubbleType = CometChatThemeOld.messageList.bubbleType
    var templates = [CometChatMessageTemplate]()
    weak var customMessageDelegate: CustomDelegate?
    
    var customViewPlaceholder: UIView?
    
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
    @objc public func set(corner: CometChatCorner) -> CometChatCustomBubble {
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
    public func set(customView: UIView) ->  CometChatCustomBubble {
        self.customView.addSubview(customView)
        return self
    }
    
    @discardableResult
    public func set(customViewWidth: CGFloat) ->  CometChatCustomBubble {
        self.customViewWidth.constant = customViewWidth
        return self
    }
    
    @discardableResult
    public func set(customViewHeight: CGFloat) ->  CometChatCustomBubble {
        self.customViewHeight.constant = customViewHeight
        return self
    }
    
    
    @discardableResult
    public func set(backgroundColor: [Any]?) ->  CometChatCustomBubble {
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
    @objc func set(borderColor : UIColor) -> CometChatCustomBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatCustomBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }

    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatCustomBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatCustomBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatCustomBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatCustomBubble {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatCustomBubble {
        self.receipt = receipt
        return self
    }
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatCustomBubble {
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
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatCustomBubble {
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
    @objc public func set(messageObject: BaseMessage) -> CometChatCustomBubble {
        self.customMessage = messageObject
        return self
    }
    
    @discardableResult
    @objc public func set(templates: [CometChatMessageTemplate]) -> CometChatCustomBubble {
        self.templates = templates
        return self
    }
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = customMessage {
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
            if let customMessage = customMessage as? CustomMessage {
                customMessageDelegate?.onLongPress(message: customMessage, cell: self)
            }
        }
    }
    
    
    var customMessage: BaseMessage? {
        didSet {
            if let customMessage = customMessage as? CustomMessage {
                self.set(borderColor: .clear)
                self.set(borderWidth: 1.0)
                self.set(userName: customMessage.sender?.name ?? "")
                self.set(receipt: self.receipt.set(receipt: customMessage))
                self.topTime.set(time: customMessage.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: customMessage.sentAt, forType: .MessageBubbleDate)
                self.set(avatar: self.avatar.setAvatar(avatarUrl: customMessage.sender?.avatar ?? "", with: customMessage.sender?.name ?? ""))
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
                self.enableLongPress(bool: true)
//
//                let paymentsView = PaymentsView.instantiate()
//                self.customView.addSubview(paymentsView)
                
                self.grabCustomView { view in
                    self.customViewPlaceholder = view
                }
            }
        }
    }
    
    override func layoutSubviews() {
        self.customView.addSubview(customViewPlaceholder!)
    }
    
    private func grabCustomView( handler: @escaping (UIView)-> Void) {
        if let messageTemplates = templates as? [CometChatMessageTemplate], let customMessage = customMessage as? CustomMessage {
            
            let  filteredMessageTemplate = messageTemplates.filter { (template: CometChatMessageTemplate) -> Bool in
                return template.id == customMessage.type
            }
            if let customView = filteredMessageTemplate.first?.customView {
                    handler(customView)
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

      //  grabCustomView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
