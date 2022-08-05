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

@objc @IBDesignable class CometChatMessageHeader: UIView  {
    
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
    var backButtonIcon: UIImage = UIImage(named: "messages-back.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var audioCallIcon: UIImage = UIImage(named: "messages-audio-call.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var videoCallIcon: UIImage = UIImage(named: "messages-video-call.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var infoIcon: UIImage = UIImage(named: "messages-info.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var controller: UIViewController?
    var configuration: CometChatConfiguration?
    var configurations: [CometChatConfiguration]?
    var inputData: InputData?
    
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
    @objc public func set(inputData: InputData) -> CometChatMessageHeader {
        self.inputData = inputData
        return self
    }
    
    
    @discardableResult
    @objc public func set(statusIndicator: CometChatStatusIndicator) -> CometChatMessageHeader {
        self.statusIndicator = statusIndicator
        return self
    }
    
    @discardableResult
    public func set(background: [Any]?) ->  CometChatMessageHeader {
        if let backgroundColors = background as? [CGColor] {
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
    
    @discardableResult
    @objc public func hide(avatar: Bool) -> CometChatMessageHeader {
        if avatar == true {
            self.avatar.isHidden =  true
        }
        return self
    }
    
    @discardableResult
    @objc public func hide(title: Bool) -> CometChatMessageHeader {
        self.title.isHidden =  title
        return self
    }
    
    @discardableResult
    @objc public func hide(subtitle: Bool) -> CometChatMessageHeader {
        self.subtitle.isHidden =  subtitle
        return self
    }
    
    @discardableResult
    @objc public func hide(statusIndicator: Bool) -> CometChatMessageHeader {
        self.statusIndicator.isHidden =  statusIndicator
        return self
    }
    
    @discardableResult
    @objc public func hide(backButton: Bool) -> CometChatMessageHeader {
        self.backButton.isHidden =  backButton
        return self
    }
    
    @discardableResult
    @objc public func hide(videoCallButton: Bool) -> CometChatMessageHeader {
        self.videoCall.isHidden =  videoCallButton
        return self
    }
    
    @discardableResult
    @objc public func hide(voiceCallButton: Bool) -> CometChatMessageHeader {
        self.audioCall.isHidden =  voiceCallButton
        return self
    }
    
    @discardableResult
    @objc public func hide(infoButton: Bool) -> CometChatMessageHeader {
        self.info.isHidden =  infoButton
        return self
    }
    
    
    @discardableResult
    @objc public func set(configuration: CometChatConfiguration) -> Self {
        if let configuration = configuration as? MessageHeaderConfiguration {
            self.configuration = configuration
        }
        
        return self
    }
    
    @discardableResult
    public func set(configurations: [CometChatConfiguration]) ->  Self {
        self.configurations = configurations
        return self
    }
    
    
    @discardableResult
    public func set(style: Style) -> CometChatMessageHeader {
        self.set(background: [style.background?.cgColor])
        self.set(titleColor: style.titleColor ?? UIColor.gray)
        self.set(titleFont: style.titleFont ?? UIFont.systemFont(ofSize: 20, weight: .regular))
        self.set(subtitleColor: style.subTitleColor ?? UIColor.gray)
        self.set(subtitleFont:  style.subTitleFont ?? UIFont.systemFont(ofSize: 20, weight: .regular))
        set(avatar:  self.avatar.set(cornerRadius: style.cornerRadius ?? 0.0).set(borderWidth: style.border ?? 0.0).set(backgroundColor: style.subTitleColor ?? .gray))
        return self
    }
    
    
    fileprivate func registerObservers() {
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
            if group.membersCount == 1 {
                set(subtitle: "\(group.membersCount) Member")
            }else{
                set(subtitle: "\(group.membersCount) Members")
            }
            
            switch group.groupType {
            case .public:
                statusIndicator.isHidden = true
                statusIndicator.set(borderWidth: 0)
            case .private:
                statusIndicator.isHidden = false
                statusIndicator.set(borderWidth: 0).set(backgroundColor:   #colorLiteral(red: 0, green: 0.7843137255, blue: 0.4352941176, alpha: 1))
                
                let image = UIImage(named: "groups-shield", in: CometChatUIKit.bundle, compatibleWith: nil)
                
                statusIndicator.set(icon:  image ?? UIImage(), with: .white)
                statusIndicator.set(borderWidth: 0)
            case .password:
                statusIndicator.isHidden = false
                statusIndicator.set(borderWidth: 0).set(backgroundColor: #colorLiteral(red: 0.968627451, green: 0.6470588235, blue: 0, alpha: 1))
                let image = UIImage(named: "groups-lock", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
                statusIndicator.set(icon:  image, with: .white)
            @unknown default:
                break
            }
        }
        
        self.set(backButtonIcon: backButtonIcon)
        self.set(infoIcon: infoIcon)
        self.set(videoCallIcon: videoCallIcon)
        self.set(audioCallIcon: audioCallIcon)
        
        self.set(backButtonIconTint: CometChatTheme.palatte?.primary ?? UIColor.clear)
        self.set(infoIconTint:  CometChatTheme.palatte?.primary  ?? UIColor.clear)
        self.set(videoCallIconTint:  CometChatTheme.palatte?.primary ?? UIColor.clear)
        self.set(audioCallIconTint:  CometChatTheme.palatte?.primary ?? UIColor.clear)
        self.set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])
        
        //  self.filterMessageHeader()
        self.registerObservers()
        self.audioCall.isHidden = true
        self.videoCall.isHidden = true
        self.info.isHidden = true
        
        let style = Style(background: CometChatTheme.palatte?.background, border: nil, cornerRadius: 20, titleColor: CometChatTheme.palatte?.accent, titleFont: CometChatTheme.typography?.Name2, subTitleColor: CometChatTheme.palatte?.accent600, subTitleFont: CometChatTheme.typography?.Subtitle2)
        
        set(style: style)
        
        if let configurations = configurations {
            if let messageHeaderConfiguration = configurations.filter({ $0 is MessageHeaderConfiguration}).last as? MessageHeaderConfiguration {
                
                if let configuration = messageHeaderConfiguration.avatarConfiguration {
                    avatar.set(cornerRadius: configuration.cornerRadius)
                    avatar.set(borderWidth: configuration.borderWidth)
                    if configuration.outerViewWidth != 0 {
                        avatar.set(outerView: true)
                        avatar.set(borderWidth: configuration.outerViewWidth)
                    }
                    self.set(avatar: avatar)
                }
                
                if let configuration = messageHeaderConfiguration.statusIndicatorConfiguration {
                    statusIndicator.set(cornerRadius: configuration.cornerRadius)
                    statusIndicator.set(borderWidth: configuration.borderWidth)
                    statusIndicator.set(status: .online, backgroundColor: configuration.backgroundColorForOnlineState)
                    statusIndicator.set(status: .offline, backgroundColor: configuration.backgroundColorForOfflineState)
                }
                
                if let title = inputData?.title {
                    self.hide(title: !title)
                }
                
                if let status = inputData?.status {
                    self.hide(statusIndicator: !status)
                }
                
                if let thumbnail = inputData?.thumbnail {
                    self.hide(avatar: !thumbnail)
                }
                
                if let currentUser = currentUser {
                    if let subtitle = inputData?.subtitle {
                        if !subtitle(currentUser).isEmpty {
                            self.hide(subtitle: false)
                            self.set(subtitle:  subtitle(currentUser))
                        }else{
                            self.hide(subtitle: true)
                        }
                    }else{
                        self.hide(subtitle: true)
                    }
                }
                
                if let currentGroup = currentGroup {
                    if let subtitle = inputData?.subtitle {
                        if !subtitle(currentGroup).isEmpty {
                            self.hide(subtitle: false)
                            self.set(subtitle:  subtitle(currentGroup))
                        }else{
                            self.hide(subtitle: true)
                        }
                    }else{
                        self.hide(subtitle: true)
                    }
                }
                hide(backButton: messageHeaderConfiguration.hideBackButton)
                hide(videoCallButton: messageHeaderConfiguration.hideVideoCallButton)
                hide(voiceCallButton: messageHeaderConfiguration.hideVoiceCallButton)
                hide(infoButton: messageHeaderConfiguration.hideInfoButton)
            }
        }
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
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configureMessageHeader()
        }
    }
    
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configureMessageHeader()
        }
    }
    
    
    @IBAction func didBackButtonPressed(_ sender: Any) {
        switch controller?.isModal() {
        case true:
            controller?.dismiss(animated: true, completion: nil)
        case false:
            controller?.navigationController?.navigationBar.isHidden = false
            controller?.navigationController?.popViewController(animated: true)
        case .none: break
        case .some(_): break
        }
    }
    
    @IBAction func didAudioCallButtonPressed(_ sender: Any) {
        if let currentUser = currentUser {
            CometChatMessageEvents.emitOnVoiceCall(user: currentUser)
        }
        if let currentGroup = currentGroup {
            CometChatMessageEvents.emitOnVoiceCall(group: currentGroup)
        }
    }
    
    @IBAction func didVideoCallButtonPressed(_ sender: Any) {
        if let currentUser = currentUser {
            CometChatMessageEvents.emitOnVideoCall(user: currentUser)
        }
        if let currentGroup = currentGroup {
            CometChatMessageEvents.emitOnVideoCall(group: currentGroup)
        }
    }
    
    @IBAction func didInfoButtonPressed(_ sender: Any) {
        if let currentUser = currentUser {
            CometChatMessageEvents.emitOnViewInformation(user: currentUser)
        }
        if let currentGroup = currentGroup {
            CometChatMessageEvents.emitOnViewInformation(group: currentGroup)
        }
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


