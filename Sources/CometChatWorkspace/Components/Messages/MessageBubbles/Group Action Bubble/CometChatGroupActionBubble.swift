//  CometChatActionMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatGroupActionBubble: UITableViewCell {
    
    // MARK: - Declaration of IBInspectable
    
    @IBOutlet weak var message: UILabel!
    
    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatGroupActionBubble {
        switch corner.corner {
        case .leftTop:
            self.message.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .rightTop:
            self.message.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .leftBottom:
            self.message.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        case .rightBottom:
            self.message.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner], radius: corner.radius)
        case .none:
            self.message.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
        }
        self.message.clipsToBounds = true
        return self
    }
    

    
    @discardableResult
    public func set(backgroundColor: UIColor) ->  CometChatGroupActionBubble {
    
                self.message.backgroundColor = backgroundColor
        return self
    }
    
    
    @discardableResult
    @objc func set(borderColor : UIColor) -> CometChatGroupActionBubble {
        self.message.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatGroupActionBubble {
        self.message.layer.borderWidth = borderWidth
        return self
    }
    @discardableResult
    @objc public func set(messageObject: BaseMessage) -> CometChatGroupActionBubble {
        self.actionMessage = messageObject
        return self
    }
    
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
    
    var actionMessage: BaseMessage? {
        didSet {
            if let actionMessage = actionMessage as? ActionMessage {
            if let action = actionMessage.action {
                switch action {
                case .joined:
                    if let user = (actionMessage.actionBy as? User)?.name {
                        message.text = user + " " + "JOINED".localize()
                    }
                case .left:
                    if let user = (actionMessage.actionBy as? User)?.name {
                        message.text = user + " " + "LEFT".localize()
                    }
                case .kicked:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,let actionOn = (actionMessage.actionOn as? User)?.name  {
                        message.text = actionBy + " " + "KICKED".localize() +  " " + actionOn
                    }
                case .banned:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,let actionOn = (actionMessage.actionOn as? User)?.name  {
                        message.text = actionBy + " " + "BANNED".localize() +  " " + actionOn
                    }
                case .unbanned:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,let actionOn = (actionMessage.actionOn as? User)?.name  {
                        message.text = actionBy + " " + "UNBANNED".localize() +  " " + actionOn
                    }
                case .scopeChanged:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,let actionOn = (actionMessage.actionOn as? User)?.name{
                        
                        switch actionMessage.newScope {
                        
                        case .admin:
                            let admin = "ADMIN".localize()
                            message.text = actionBy + " " + "MADE".localize() + " \(actionOn) \(admin)"
                        case .moderator:
                            let moderator = "MODERATOR".localize()
                            message.text = actionBy + " " + "MADE".localize() + " \(actionOn) \(moderator)"
                        case .participant:
                            let participant = "PARTICIPANT".localize()
                            message.text = actionBy + " " + "MADE".localize() + " \(actionOn) \(participant)"
                        @unknown default:
                            break
                        }
                        
                    }
                case .messageEdited:
                    message.text = actionMessage.message
                case .messageDeleted:
                    message.text = actionMessage.message
                case .added:
                    if let actionBy = (actionMessage.actionBy as? User)?.name,let actionOn = (actionMessage.actionOn as? User)?.name  {
                        message.text = actionBy + " " + "ADDED".localize() +  " " + actionOn
                    }
                @unknown default:
                    message.text = "ACTION_MESSAGE".localize()
                }
            }
        }
        }
    }
        
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        contentView.isUserInteractionEnabled = false
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

/*  ----------------------------------------------------------------------------------------- */
