//
//  CometChatMessageHeader.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 08/11/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import CometChatSDK

@objc @IBDesignable public class CometChatMessageHeader: UIView  {
    
    // MARK: Declaration of Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var backIcon: UIButton!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var listItemContainer: UIView!
    
    //MARK: Declaration of variables
    private var subtitle: ((_ user: User?, _ group: Group?) -> UIView)?
    private var menus: ((_ user: User?, _ group: Group?) -> UIView)?
    private var disableTyping: Bool = false
    private var hideBackIcon: Bool = false
    private var disableUsersPresence: Bool = false
    private var controller: UIViewController?
    private var listItemView = CometChatListItem()
    private var avatarStyle = AvatarStyle()
    private var listItemStyle = ListItemStyle()
    private var messageHeaderStyle = MessageHeaderStyle()
    private var statusIndicatorStyle = StatusIndicatorStyle()
    private var backButtonIcon: UIImage = UIImage(named: "messages-back.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private var privateGroupIcon = UIImage(named: "groups-shield", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    private var protectedGroupIcon = UIImage(named: "groups-lock", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
    //MARK: Declaration of view model
    var viewModel : MessageHeaderViewModel?
    //TODO:- Created to check details Events.
    var infoCallBack: (() -> Void)?
    
    // MARK: - Initialization of required Methods
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = self.bounds
            self.addSubview(contentView)
        }
    }
    
    public override func awakeFromNib() {
        setupListItemView()
        configureMessageHeader()
    }
    
    func setupListItemView() {
        listItemView = Bundle.module.loadNibNamed(CometChatListItem.identifier, owner: self, options: nil)![0] as! CometChatListItem
        let contentView = listItemView
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.frame = listItemContainer.bounds
        listItemContainer.addSubview(contentView)
    }
    
    @objc func onInfoClick(_ sender: UIButton) {
        infoCallBack?()
    }
    
    fileprivate func configureMessageHeader() {
        updateTypingStatus()
        updateUserStatus()
        updateGroupCount()
        connect()
        background.backgroundColor = messageHeaderStyle.background
        if let user = viewModel?.user {
            listItemView.hide(statusIndicator: false)
            if let name = user.name {
                listItemView.set(title: name.capitalized)
                listItemView.set(avatarName: name.capitalized)
            }
            if let avatarURL = user.avatar {
                listItemView.set(avatarURL: avatarURL)
            }
            if let menu = menus?(user,nil) {
                listItemView.set(tail: menu)
            }
            if !disableUsersPresence {
                switch user.status {
                case .online :
                    listItemView.hide(statusIndicator: false)
                    listItemView.set(statusIndicatorColor: messageHeaderStyle.onlineStatusColor)
                case .offline:
                    listItemView.hide(statusIndicator: true)
                case .available:
                    listItemView.hide(statusIndicator: true)
                @unknown default:
                    listItemView.hide(statusIndicator: true)
                }
            }
            if let usersubtitle = subtitle?(user, nil) {
                listItemView.set(subtitle: usersubtitle)
            } else {
                let label = UILabel()
                switch user.status {
                case .online:
                    label.text = MessageHeaderConstants.online
                    label.textColor = CometChatTheme.palatte.primary
                case .offline:
                    label.text = MessageHeaderConstants.offline
                    label.textColor = messageHeaderStyle.subtitleTextColor
                case .available:
                    label.text = MessageHeaderConstants.available
                    label.textColor = messageHeaderStyle.subtitleTextColor
                @unknown default:
                    label.text = MessageHeaderConstants.available
                    label.textColor = messageHeaderStyle.subtitleTextColor
                }
                label.font = messageHeaderStyle.subtitleTextFont
                listItemView.set(subtitle: label)
            }
        }
        if let group = viewModel?.group {
            if let name = group.name {
                listItemView.set(title: name.capitalized)
                listItemView.set(avatarName: name.capitalized)
            }
            if let avatarURL = group.icon {
                listItemView.set(avatarURL: avatarURL)
            }
            if let subTitleView = subtitle?(nil, group) {
                listItemView.set(subtitle: subTitleView)
            } else {
                let label = UILabel()
                if group.membersCount <= 1 {
                    label.text = String(group.membersCount) + " " + MessageHeaderConstants.member
                }else{
                    label.text = String(group.membersCount) + " " + MessageHeaderConstants.members
                }
                label.textColor = messageHeaderStyle.subtitleTextColor
                label.font = messageHeaderStyle.subtitleTextFont
                listItemView.set(subtitle: label)
            }
            if let menu = menus?(nil,group) {
                listItemView.set(tail: menu)
            }
            switch group.groupType {
            case .public:
                listItemView.statusIndicator.isHidden = true
            case .private:
                listItemView.statusIndicator.isHidden = false
                listItemView.set(statusIndicatorIcon: privateGroupIcon)
                listItemView.set(statusIndicatorColor: messageHeaderStyle.privateGroupIconBackgroundColor)
                listItemView.set(statusIndicatorIconTint: .white)
            case .password:
                listItemView.statusIndicator.isHidden = false
                listItemView.set(statusIndicatorIcon: protectedGroupIcon)
                listItemView.set(statusIndicatorColor: messageHeaderStyle.protectedGroupIconBackgroundColor)
                listItemView.set(statusIndicatorIconTint: .white)
            @unknown default: listItemView.statusIndicator.isHidden = true
            }
        }
        listItemView.set(avatarStyle: avatarStyle)
        listItemView.set(statusIndicatorStyle: statusIndicatorStyle)
        listItemView.set(listItemStyle: listItemStyle)
        listItemView.allow(selection: false)
        set(backIcon: backButtonIcon)
        set(backIconTint: messageHeaderStyle.backIconTint)
        listItemView.build()
    }
    
    public func connect() {
        CometChat.addConnectionListener("messages-header-sdk-listener", self)
        self.viewModel?.connect()
    }
    
    public func disconnect() {
        CometChat.removeConnectionListener("messages-header-sdk-listener")
        self.viewModel?.disconnect()
    }
    
    func updateUserStatus() {
        viewModel?.updateUserStatus = { [weak self] (status) in
            guard let this = self else { return }
            if !this.disableTyping {
                switch status {
                case true:
                    this.listItemView.set(subtitle: this.configureSubTitleView(text: MessageHeaderConstants.online))
                    this.listItemView.set(statusIndicatorColor: this.messageHeaderStyle.onlineStatusColor)
                    this.listItemView.hide(statusIndicator: false)
                case false:
                    this.listItemView.set(subtitle: this.configureSubTitleView(text: MessageHeaderConstants.offline))
                    this.listItemView.hide(statusIndicator: true)
                }
                this.listItemView.build()
            }
        }
    }
    
    public func updateTypingStatus() {
        var text: String = ""
        viewModel?.updateTypingStatus = { [weak self] (status) in
            guard let this = self else { return }
            if let _ = this.viewModel?.user {
                switch status {
                case true:
                    text = MessageHeaderConstants.typing
                case false:
                    text = MessageHeaderConstants.online
                }
            }
            if let group = this.viewModel?.group {
                switch status {
                case true:
                    text = (this.viewModel?.name?.capitalized ?? "") + " " + MessageHeaderConstants.isTyping
                case false:
                    if group.membersCount == 1 {
                        text = "1 " + MessageHeaderConstants.member
                    } else {
                        text = "\(group.membersCount) " + MessageHeaderConstants.members
                    }
                }
            }
            this.listItemView.set(subtitle: this.configureSubTitleView(text: text))
            this.listItemView.build()
        }
    }
    
    private func updateGroupCount() {
        var text: String = ""
        viewModel?.updateGroupCount = { [weak self] (status) in
            guard let this = self else { return }
            if let group = this.viewModel?.group {
                if status {
                    if group.membersCount == 1 {
                        text = "1 " + MessageHeaderConstants.member
                    } else {
                        text = "\(group.membersCount) " + MessageHeaderConstants.members
                    }
                     this.listItemView.set(subtitle: this.configureSubTitleView(text: text))
                }
            }
        }
    }
    
    @IBAction func didBackIconPressed(_ sender: Any) {
        if self.controller?.navigationController != nil {
            if self.controller?.navigationController?.viewControllers.first == self.controller {
                controller?.dismiss(animated: true, completion: nil)
            } else {
                controller?.navigationController?.navigationBar.isHidden = false
                controller?.navigationController?.popViewController(animated: true)
            }
          
        }else{
            controller?.dismiss(animated: true, completion: nil)
        }
    }
}

extension CometChatMessageHeader {
    
    @discardableResult
    public func set(subtitle: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
        self.subtitle = subtitle
        return self
    }
    
    @discardableResult
    public func setMenus(menu: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
        self.menus = menu
        return self
    }
    
    @discardableResult
    @objc public func set(user: User) -> CometChatMessageHeader {
        viewModel = MessageHeaderViewModel(user: user)
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configureMessageHeader()
        }
        return self
    }
    
    @discardableResult
    @objc public func set(group: Group) -> CometChatMessageHeader {
        viewModel = MessageHeaderViewModel(group: group)
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configureMessageHeader()
        }
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> Self {
        self.statusIndicatorStyle = statusIndicatorStyle
        return self
    }
    
    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(privateGroupIcon: UIImage) -> Self {
        self.privateGroupIcon = privateGroupIcon
        return self
    }
    
    @discardableResult
    public func set(protectedGroupIcon: UIImage) -> Self {
        self.protectedGroupIcon = protectedGroupIcon
        return self
    }
    
    @discardableResult
    public func disable(userPresence: Bool) -> Self {
        self.disableUsersPresence = userPresence
        return self
    }
    
    @discardableResult
    public func disable(typing: Bool) -> Self {
        self.disableTyping = typing
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(backIcon: UIImage) -> Self {
        self.backButtonIcon = backIcon.withRenderingMode(.alwaysTemplate)
        self.backIcon.setImage(backIcon, for: .normal)
        return self
    }
    
    @discardableResult
    public func set(backIconTint: UIColor) -> Self {
        self.backIcon.tintColor = backIconTint
        return self
    }
    
    @discardableResult
    public func hide(backButton: Bool) -> Self {
        self.backIcon.isHidden = backButton
        return self
    }
    
    @discardableResult
    public func set(messageHeaderStyle: MessageHeaderStyle) -> Self {
        self.messageHeaderStyle = messageHeaderStyle
        return self
    }
    
    @discardableResult
    public func set(customMessageHeader: UIView) -> Self {
        for view in listItemContainer.subviews {
            view.removeFromSuperview()
        }
        customMessageHeader.frame = listItemContainer.bounds
        listItemContainer.addSubview(customMessageHeader)
        return self
    }
}

extension CometChatMessageHeader {
    
    public func configureSubTitleView(text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = messageHeaderStyle.subtitleTextColor
        label.font = messageHeaderStyle.subtitleTextFont
        return label
    }
}

extension CometChatMessageHeader: CometChatConnectionDelegate {
    public func connected() {
        updateTypingStatus()
        updateUserStatus()
        updateGroupCount()
    }
    
    public func connecting() {
        
    }
    
    public func disconnected() {
        
    }
}

