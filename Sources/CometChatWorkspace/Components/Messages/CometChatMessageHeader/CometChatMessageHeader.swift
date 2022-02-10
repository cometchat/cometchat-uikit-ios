//
//  CometChatMessageHeader.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 08/11/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import CometChatPro


protocol CometChatMessageHeaderDelegate: NSObject {

    func didBackButtonPressed()
    func didAudioCallButtonPressed()
    func didVideoCallButtonPressed()
    func didInfoButtonPressed()
    
}

@objc @IBDesignable class CometChatMessageHeader: UIView , NibLoadable {
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var statusIndicator: CometChatStatusIndicator!
    @IBOutlet weak var audioCall: UIButton!
    @IBOutlet weak var videoCall: UIButton!
    @IBOutlet weak var info: UIButton!
    @IBOutlet weak var background: CometChatGradientView!
    
    var currentUser: User?
    var currentGroup: Group?
    var backButtonIcon: UIImage = UIImage(named: "messages-back.png")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var audioCallIcon: UIImage = UIImage(named: "messages-audio-call.png")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var videoCallIcon: UIImage = UIImage(named: "messages-video-call.png")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var infoIcon: UIImage = UIImage(named: "messages-info.png")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var controller: UIViewController?
    
    weak var messageHeaderDelegate: CometChatMessageHeaderDelegate?
    
    @discardableResult
    @objc public func set(user: User) -> CometChatMessageHeader {
        self.currentUser = user
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configureMessageHeader()
        }
        return self
    }
    
    @discardableResult
    @objc public func set(group: Group) -> CometChatMessageHeader {
        self.currentGroup = group
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configureMessageHeader()
        }
        return self
    }
    
    @discardableResult
    @objc public func set(statusIndicator: CometChatStatusIndicator) -> CometChatMessageHeader {
        self.statusIndicator
        return self
    }
    

    
    @discardableResult
    public func set(background: [Any]?) ->  CometChatMessageHeader {
        if let backgroundColors = backgroundColor as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: backgroundColors)
            }
        }
        return self
    }
    
    @discardableResult
    @objc public func set(controller: UIViewController) -> CometChatMessageHeader {
        self.controller = controller
        return self
    }
    
    @discardableResult
    @objc public func set(backButtonIcon: UIImage) -> CometChatMessageHeader {
        let image = backButtonIcon.withRenderingMode(.alwaysTemplate)
        self.backButton.setImage(image, for: .normal)
        return self
    }
    
    @discardableResult
    @objc public func set(audioCallIcon: UIImage) -> CometChatMessageHeader {
        let image = audioCallIcon.withRenderingMode(.alwaysTemplate)
        self.audioCall.setImage(image, for: .normal)
        return self
    }
    
    @discardableResult
    @objc public func set(videoCallIcon: UIImage) -> CometChatMessageHeader {
        let image = videoCallIcon.withRenderingMode(.alwaysTemplate)
        self.videoCall.setImage(image, for: .normal)
        return self
    }
    
    
    @discardableResult
    @objc public func set(infoIcon: UIImage) -> CometChatMessageHeader {
        let image = infoIcon.withRenderingMode(.alwaysTemplate)
        self.info.setImage(image, for: .normal)
        return self
    }
    
    @discardableResult
    @objc public func set(backButtonIconTint: UIColor) -> CometChatMessageHeader {
        self.backButton.tintColor = backButtonIconTint
        return self
    }
    
    @discardableResult
    @objc public func set(audioCallIconTint: UIColor) -> CometChatMessageHeader {
        self.audioCall.tintColor = audioCallIconTint
        return self
    }
    
    @discardableResult
    @objc public func set(videoCallIconTint: UIColor) -> CometChatMessageHeader {
        self.videoCall.tintColor = videoCallIconTint
        return self
    }
    
    
    @discardableResult
    @objc public func set(infoIconTint: UIColor) -> CometChatMessageHeader {
        self.info.tintColor = infoIconTint
        return self
    }

    
    
    @discardableResult
    @objc public func set(title: String) -> CometChatMessageHeader {
        self.title.text = title
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatMessageHeader {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatMessageHeader {
        self.title.textColor = titleColor
        return self
    }
    
    @discardableResult
    @objc public func set(subtitle: String) -> CometChatMessageHeader {
        self.subtitle.text = subtitle
        return self
    }
    
    @discardableResult
    @objc public func set(subtitleFont: UIFont) -> CometChatMessageHeader {
        self.subtitle.font = subtitleFont
        return self
    }
    
    @discardableResult
    @objc public func set(subtitleColor: UIColor) -> CometChatMessageHeader {
        self.subtitle.textColor = subtitleColor
        return self
    }
    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatMessageHeader {
        self.avatar = avatar
        return self
    }
    

    fileprivate func registerObservers() {
      //  CometChat.messagedelegate = self
        CometChat.userdelegate = self
    }
    
    fileprivate func configureMessageHeader() {
        if let user = currentUser {
            set(title: user.name?.capitalized ?? "")
            set(avatar: self.avatar.setAvatar(user: user))
            self.statusIndicator.isHidden = false
            self.set(statusIndicator:  self.statusIndicator.set(status: user.status))
            switch user.status {
            case .online:
                set(subtitle: "Online")
            case .offline:
                set(subtitle: "Offline")
            case .available:
                set(subtitle: "Available")
            @unknown default: set(subtitle: "Available")
            }
        }
        
        if let group = currentGroup {
            set(title: group.name?.capitalized ?? "")
            set(avatar: self.avatar.setAvatar(group: group))
            if group.membersCount < 1 {
                set(subtitle: "\(group.membersCount) Member")
            }else{
                set(subtitle: "\(group.membersCount) Members")
            }
        }
        self.set(backButtonIcon: backButtonIcon)
        self.set(infoIcon: infoIcon)
        self.set(videoCallIcon: videoCallIcon)
        self.set(audioCallIcon: audioCallIcon)
        
        self.set(backButtonIconTint: CometChatTheme.style.primaryIconColor)
        self.set(infoIconTint: CometChatTheme.style.primaryIconColor)
        self.set(videoCallIconTint: CometChatTheme.style.primaryIconColor)
        self.set(audioCallIconTint: CometChatTheme.style.primaryIconColor)
        self.set(background: [CometChatTheme.style.primaryBackgroundColor.cgColor])
        
      //  self.filterMessageHeader()
        self.registerObservers()
        self.audioCall.isHidden = true
        self.videoCall.isHidden = true
        self.info.isHidden = true
    }
    
    
    // MARK: - Initialization of required Methods
    
    override init(frame: CGRect) {
      super.init(frame: UIScreen.main.bounds)
      commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      commonInit()
    }
    
    override func reloadInputViews() {
        configureMessageHeader()
    }
    
    private func commonInit() {
      Bundle.module.loadNibNamed("CometChatMessageHeader", owner: self, options: nil)
      addSubview(contentView)
      contentView.frame = bounds
      contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
      configureMessageHeader()
    }

    
//
//    private func filterMessageHeader() {
//        if let messageTemplates = CometChatConfiguration.getMessageFilterList() {
//            for template in messageTemplates {
//                if template.id == "call" && currentUser != nil {
//                    self.audioCall.isHidden = false
//                    self.videoCall.isHidden = false
//                }else if template.id == "meeting" && currentGroup != nil {
//                    self.audioCall.isHidden = true
//                    self.videoCall.isHidden = false
//                }
//            }
//        }else{
//             self.audioCall.isHidden = false
//             self.videoCall.isHidden = false
//        }
//    }
    
    @IBAction func didBackButtonPressed(_ sender: Any) {
        
        switch controller?.isModal() {
        case true:
            controller?.dismiss(animated: true, completion: nil)
        case false:
            controller?.navigationController?.popViewController(animated: true)
        case .none: break
        case .some(_): break
        }
        messageHeaderDelegate?.didBackButtonPressed()
    }
    
    @IBAction func didAudioCallButtonPressed(_ sender: Any) {
        messageHeaderDelegate?.didAudioCallButtonPressed()
        
    }
    
    @IBAction func didVideoCallButtonPressed(_ sender: Any) {
        
        messageHeaderDelegate?.didVideoCallButtonPressed()
    }
    
    @IBAction func didInfoButtonPressed(_ sender: Any) {
        
        messageHeaderDelegate?.didInfoButtonPressed()
        
    }
    
}

extension CometChatMessageHeader: CometChatMessageDelegate {
    
    func onTypingStarted(_ typingDetails: TypingIndicator) {
        switch typingDetails.receiverType {
        case .user:
            if typingDetails.sender?.uid == currentUser?.uid {
                self.set(subtitle: "TYPING".localize())
            }
        case .group:
            if typingDetails.receiverID == currentGroup?.guid {
                if let user = typingDetails.sender?.name {
                    self.set(subtitle: "\(String(describing: user)) " + "IS_TYPING".localize())
                }
            }
        @unknown default: break
        }
    }
    
    func onTypingEnded(_ typingDetails: TypingIndicator) {
        switch typingDetails.receiverType {
        case .user:
            if typingDetails.sender?.uid == currentUser?.uid {
                self.set(subtitle: "ONLINE".localize())
            }
        case .group:
            if let group = currentGroup {
            if typingDetails.receiverID == group.guid {
                if group.membersCount == 1 {
                    self.set(subtitle: "1 " + "MEMBER".localize())
                }else {
                    self.set(subtitle: "\(group.membersCount) " + "MEMBERS".localize())
                }
            }
            }
        @unknown default: break
        }
    }
}

extension CometChatMessageHeader: CometChatUserDelegate {
    
    func onUserOnline(user: User) {
        if user.uid == currentUser?.uid {
            self.set(subtitle: "ONLINE".localize())
            self.set(statusIndicator:  self.statusIndicator.set(status: user.status))
        }
    }
    
    func onUserOffline(user: User) {
        if user.uid == currentUser?.uid {
            self.set(subtitle: "OFFLINE".localize())
            self.set(statusIndicator:  self.statusIndicator.set(status: user.status))
        }
    }
}
