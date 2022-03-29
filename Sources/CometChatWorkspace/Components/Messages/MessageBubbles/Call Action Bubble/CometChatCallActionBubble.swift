//
//  CometChatFileBubble.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import CometChatPro


class CometChatCallActionBubble: UITableViewCell {
    
    @IBOutlet weak var alightmentStack: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var topTime: CometChatDate!
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var title: UILabel!
    
    var bubbleType: BubbleType = CometChatThemeOld.messageList.bubbleType
    weak var meetingDelegate: MeetingDelegate?
    
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
    @objc public func set(title: String) -> CometChatCallActionBubble {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatCallActionBubble {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatCallActionBubble {
        self.title.textColor = titleColor
        return self
    }
  
    @discardableResult
    @objc public func set(icon: UIImage) -> CometChatCallActionBubble {
        let image = icon.withRenderingMode(.alwaysTemplate)
        self.icon.image = image
        return self
    }

    @discardableResult
    @objc public func set(iconTintColor: UIColor) -> CometChatCallActionBubble {
        self.icon.tintColor = iconTintColor
        return self
    }
    
    @discardableResult
    @objc public func set(corner: CometChatCorner) -> CometChatCallActionBubble {
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
    public func set(backgroundColor: [Any]?) ->  CometChatCallActionBubble {
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
    @objc func set(borderColor : UIColor) -> CometChatCallActionBubble {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> CometChatCallActionBubble {
        self.background.layer.borderWidth = borderWidth
        return self
    }

    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatCallActionBubble {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> CometChatCallActionBubble {
        if bubbleType == .leftAligned {
            self.name.text = userName
        }else{
            self.name.text = userName + ":"
        }
        
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> CometChatCallActionBubble {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> CometChatCallActionBubble {
        self.name.textColor = userNameColor
        return self
    }
    
  
    
    
    @discardableResult
    @objc public func set(time: CometChatDate) -> CometChatCallActionBubble {
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
    @objc public func set(messageAlignment: MessageAlignment) -> CometChatCallActionBubble {
        switch messageAlignment {
        case .left:
            name.isHidden = false
            alightmentStack.alignment = .leading
            spacer.isHidden = false
            avatar.isHidden = false
           
        case .right:
            alightmentStack.alignment = .trailing
            spacer.isHidden = true
            avatar.isHidden = true
            name.isHidden = true
        }
        return self
    }
    
    @discardableResult
    @objc public func set(messageObject: BaseMessage) -> CometChatCallActionBubble {
        self.callMessage = messageObject
        return self
    }
    
    @discardableResult
    @objc fileprivate func isMyMessage() -> Bool {
        if let message = callMessage {
            if message.sender?.uid == CometChatMessages.loggedInUser?.uid {
                return true
            }else{
                return false
            }
        }
        return false
    }
    
    
    var callMessage: BaseMessage? {
        didSet {
            if let call = callMessage as? Call {
                self.set(borderColor: .clear)
                self.set(borderWidth: 1.0)
                self.set(userName: call.sender?.name ?? "")
                self.topTime.set(time: call.sentAt, forType: .MessageBubbleDate)
                self.time.set(time: call.sentAt, forType: .MessageBubbleDate)
                self.set(avatar: self.avatar.setAvatar(avatarUrl: call.sender?.avatar ?? "", with: call.sender?.name ?? ""))
                
                switch call.callStatus  {
                    
                case .initiated where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? User)?.uid == CometChatMessages.loggedInUser?.uid:
                    self.set(title: "OUTGOING_AUDIO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-outgoing-audio-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .initiated where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? User)?.uid != CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "INCOMING_AUDIO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-incoming-audio-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .initiated where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? User)?.uid != CometChatMessages.loggedInUser?.uid:

                    self.set(title: "INCOMING_AUDIO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-incoming-audio-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .initiated where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? User)?.uid == CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "OUTGOING_AUDIO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-outgoing-audio-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .initiated where call.callType == .video && call.receiverType == .user  && (call.callInitiator as? User)?.uid == CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "OUTGOING_VIDEO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-outgoing-video-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .initiated where call.callType == .video && call.receiverType == .user && (call.callInitiator as? User)?.uid != CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "INCOMING_VIDEO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-incoming-video-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .initiated where call.callType == .video && call.receiverType == .group  && (call.callInitiator as? User)?.uid == CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "OUTGOING_VIDEO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-outgoing-video-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .initiated where call.callType == .video && call.receiverType == .group && (call.callInitiator as? User)?.uid != CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "INCOMING_VIDEO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-incoming-video-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .unanswered where call.callType == .audio && call.receiverType == .user  && (call.callInitiator as? User)?.uid == CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "UNANSWERED_AUDIO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-end-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .unanswered where call.callType == .audio && call.receiverType == .user && (call.callInitiator as? User)?.uid != CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "MISSED_CALL".localize())
                    self.set(icon: UIImage(named: "messages-end-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .unanswered where call.callType == .audio && call.receiverType == .group  && (call.callInitiator as? User)?.uid == CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "UNANSWERED_AUDIO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-end-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .unanswered where call.callType == .audio && call.receiverType == .group && (call.callInitiator as? User)?.uid != CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "MISSED_CALL".localize())
                    self.set(icon: UIImage(named: "messages-end-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                    
                case .unanswered where call.callType == .video && call.receiverType == .user  && (call.callInitiator as? User)?.uid == CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "UNANSWERED_VIDEO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-end-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .unanswered where call.callType == .video && call.receiverType == .user && (call.callInitiator as? User)?.uid != CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "MISSED_CALL".localize())
                    self.set(icon: UIImage(named: "messages-end-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .unanswered where call.callType == .video && call.receiverType == .group  && (call.callInitiator as? User)?.uid == CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "UNANSWERED_VIDEO_CALL".localize())
                    self.set(icon: UIImage(named: "messages-end-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .unanswered where call.callType == .video && call.receiverType == .group && (call.callInitiator as? User)?.uid != CometChatMessages.loggedInUser?.uid:
                    
                    self.set(title: "MISSED_CALL".localize())
                    self.set(icon: UIImage(named: "messages-end-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                    
                case .rejected: self.set(title: "REJECTED_CALL".localize())
                case .busy: self.set(title: "CALL_BUSY".localize())
                case .cancelled: self.set(title: "CALL_CANCELLED".localize())
                case .ended:
                    self.set(title: "CALL_ENDED".localize())
                    self.set(icon: UIImage(named: "messages-end-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                case .initiated: self.set(title: "CALL_INITIATED".localize())
                case .ongoing:
                    self.set(title: "CALL_OUTGOING".localize())
                    self.set(title: "CALL_ENDED".localize())
                    self.set(icon: UIImage(named: "messages-end-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage())
                    self.set(iconTintColor: .white)
                case .unanswered: self.set(title: "CALL_UNANSWERED".localize())
                @unknown default: self.set(title: "CALL_CANCELLED".localize())
                }
                
                set(time: self.time)
                if isMyMessage() {
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .right)
                        self.set(corner: CometChatThemeOld.messageList.rightBubbleCorners)
                        if #available(iOS 13.0, *) {
                            self.set(backgroundColor: [UIColor.systemFill.cgColor])
                            self.set(titleColor: .label)
                            self.set(iconTintColor: .label)
                        } else {
                            self.set(backgroundColor: [UIColor.lightGray.cgColor])
                            self.set(titleColor: .black)
                            self.set(iconTintColor: .black)
                        }
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        if #available(iOS 13.0, *) {
                            self.set(backgroundColor: [UIColor.systemFill.cgColor])
                            self.set(titleColor: .label)
                            self.set(iconTintColor: .label)
                        } else {
                            self.set(backgroundColor: [UIColor.lightGray.cgColor])
                            self.set(titleColor: .black)
                            self.set(iconTintColor: .black)
                        }
                    }
                }else{
                    switch bubbleType {
                    case .standard:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        if #available(iOS 13.0, *) {
                            self.set(backgroundColor: [UIColor.systemFill.cgColor])
                            self.set(titleColor: .label)
                            self.set(iconTintColor: .label)
                        } else {
                            self.set(backgroundColor: [UIColor.lightGray.cgColor])
                            self.set(titleColor: .black)
                            self.set(iconTintColor: .black)
                        }
                    case .leftAligned:
                        self.set(messageAlignment: .left)
                        self.set(corner: CometChatThemeOld.messageList.leftBubbleCorners)
                        self.set(titleColor: CometChatThemeOld.messageList.leftBubbleTextColor)
                        if #available(iOS 13.0, *) {
                            self.set(backgroundColor: [UIColor.systemFill.cgColor])
                            self.set(titleColor: .label)
                            self.set(iconTintColor: .label)
                        } else {
                            self.set(backgroundColor: [UIColor.lightGray.cgColor])
                            self.set(titleColor: .black)
                            self.set(iconTintColor: .black)
                        }
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

    }

}
