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

@objc @IBDesignable public class CometChatMessageHeader: UIView {

    // MARK: - Lazy Properties
    public lazy var backButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(didBackIconPressed), for: .touchUpInside)
        button.pin(anchors: [.width], to: 20)
        return button
    }()
    
    public lazy var backButtonView: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(didBackIconPressed), for: .touchUpInside)
        button.backgroundColor = .clear
        return button
    }()
    
    public lazy var avatar: CometChatAvatar = {
        let avatar = CometChatAvatar(frame: .infinite).withoutAutoresizingMaskConstraints()
        avatar.pin(anchors: [.height, .width], to: 40)
        return avatar
    }()
    
    public lazy var titleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        return label
    }()
    
    public lazy var titleLabelView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.embed(titleLabel, insets: .init(top: 0, leading: 0, bottom: 1, trailing: 0))
        return view
    }()
    
    public lazy var subtitleLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        return label
    }()
    
    public lazy var subtitleView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.embed(subtitleLabel, insets: .init(top: 1, leading: 0, bottom: 0, trailing: 0))
        return view
    }()
    
    public lazy var tailView: UIStackView = {
        let view = UIStackView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    public lazy var statusIndicator: CometChatStatusIndicator = {
        let indicator = CometChatStatusIndicator().withoutAutoresizingMaskConstraints()
        indicator.pin(anchors: [.height, .width], to: 13)
        return indicator
    }()

    // MARK: - Variables
    private var disableTyping: Bool = false
    private var hideBackIcon: Bool = false
    private var disableUsersPresence: Bool = false
    private weak var controller: UIViewController?
    public lazy var avatarStyle = CometChatAvatar.style
    
    //MARK: GLOBEL STYLING
    public static var style = MessageHeaderStyle() // global styling
    public static var statusIndicatorStyle = {
        var style = CometChatStatusIndicator.style
        style.borderWidth = 2
        return style
    }()
    public static var typingIndicatorStyle = {
        var style = CometChatTypingIndicator.style
        style.textFont = CometChatTypography.Caption1.regular
        return style
    }()
    
    public var titleContainerStackView = UIStackView().withoutAutoresizingMaskConstraints()
    
    //MARK: LOCAL STYLING
    public lazy var style = CometChatMessageHeader.style
    public lazy var statusIndicatorStyle = CometChatMessageHeader.statusIndicatorStyle
    public lazy var typingIndicatorStyle = CometChatMessageHeader.typingIndicatorStyle

    // MARK: - ViewModel
    open var viewModel: MessageHeaderViewModelProtocol = MessageHeaderViewModel()

    // MARK: - Initialization
    override public init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        buildUI()
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil{
            setupStyle()
            connect()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buildUI()
    }
    
    deinit {
        disconnect()
    }
    
    open func buildUI() {
        
        var constraintsToActivate = [NSLayoutConstraint]()
        
        addSubview(backButtonView)
        backButtonView.addSubview(backButton)
        constraintsToActivate += [
            backButtonView.leadingAnchor.pin(equalTo: leadingAnchor),
            backButtonView.topAnchor.pin(equalTo: topAnchor),
            backButtonView.bottomAnchor.pin(equalTo: bottomAnchor),
            backButton.leadingAnchor.pin(equalTo: backButtonView.leadingAnchor, constant: CometChatSpacing.Padding.p4),
            backButton.trailingAnchor.pin(equalTo: backButtonView.trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            backButton.centerYAnchor.pin(equalTo: centerYAnchor)
        ]
        
        addSubview(avatar)
        constraintsToActivate += [
            avatar.leadingAnchor.pin(equalTo: backButtonView.trailingAnchor),
            avatar.centerYAnchor.pin(equalTo: backButton.centerYAnchor)
        ]
        
        addSubview(statusIndicator)
        constraintsToActivate += [
            statusIndicator.trailingAnchor.pin(equalTo: avatar.trailingAnchor, constant: -1),
            statusIndicator.bottomAnchor.pin(equalTo: avatar.bottomAnchor, constant: -1)
        ]
        
        titleContainerStackView.axis = .vertical
        titleContainerStackView.distribution = .equalCentering
        titleContainerStackView.alignment = .leading
        addSubview(titleContainerStackView)
        titleContainerStackView.addArrangedSubview(titleLabelView)
        titleContainerStackView.addArrangedSubview(subtitleView)
        
        constraintsToActivate += [
            titleContainerStackView.leadingAnchor.pin(equalTo: avatar.trailingAnchor, constant: CometChatSpacing.Padding.p3),
            titleContainerStackView.centerYAnchor.constraint(equalTo: avatar.centerYAnchor)
        ]
        
        addSubview(tailView)
        constraintsToActivate += [
            tailView.leadingAnchor.pin(equalTo: titleContainerStackView.trailingAnchor, constant: CometChatSpacing.Padding.p3),
            tailView.topAnchor.pin(equalTo: topAnchor),
            tailView.bottomAnchor.pin(equalTo: bottomAnchor),
            tailView.trailingAnchor.pin(equalTo: trailingAnchor, constant: -CometChatSpacing.Padding.p4)
        ]
        
        NSLayoutConstraint.activate(constraintsToActivate)
    }

    open func setupStyle() {
        setBackground(image: style.backgroundImage)
        backgroundColor = style.backgroundColor
        borderWith(width: style.borderWidth)
        borderColor(color: style.borderColor)
        
        backButton.setImage(style.backButtonIcon, for: .normal)
        backButton.tintColor = style.backButtonImageTintColor

        titleLabel.textColor = style.titleTextColor
        titleLabel.font = style.titleTextFont
        subtitleLabel.textColor = style.subtitleTextColor
        subtitleLabel.font = style.subtitleTextFont
                
        roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: 0))
        
        updateUserStatus(viewModel.user?.status == .online ? true : false)
        configureGroupStatusIndicatorStyling()
        configureGroupSubtitleStyling()
    }

    open func configure(user: User) {
        statusIndicator.isHidden = true
        
        titleLabel.text = user.name ?? ""
        avatar.setAvatar(avatarUrl: user.avatar, with: user.name)
    }

    open func configure(group: Group) {
        titleLabel.text = group.name ?? ""
        avatar.setAvatar(avatarUrl: group.icon, with: group.name)
        subtitleLabel.text = "\(group.membersCount) \(group.membersCount > 1 ? MessageHeaderConstants.members : MessageHeaderConstants.member)"
    }

    open func configureGroupSubtitleStyling() {
        if let group = viewModel.group {
            subtitleLabel.textColor = style.subtitleTextColor
            subtitleLabel.font = style.subtitleTextFont
        }
    }

    open func configureGroupStatusIndicatorStyling() {
        statusIndicator.style = statusIndicatorStyle
        if let group = viewModel.group {
            switch group.groupType {
            case .public:
                statusIndicator.isHidden = true
            case .private:
                statusIndicator.set(
                    icon: style.privateGroupIcon,
                    with: style.privateGroupBadgeImageTintColor
                )
                statusIndicator.style.backgroundColor = style.privateGroupImageBackgroundColor
            case .password:
                statusIndicator.set(
                    icon: style.protectedGroupIcon,
                    with: style.passwordProtectedGroupBadgeImageTintColor
                )
                statusIndicator.style.backgroundColor = style.passwordGroupImageBackgroundColor
            default:
                statusIndicator.isHidden = true
            }
        }
    }

    // MARK: - Connectivity
    public func connect() {
        CometChat.addConnectionListener("messages-header-sdk-listener-\(viewModel.listenerRandomId)", self)
        setupViewModel()
        self.viewModel.connect()
    }
    
    public func disconnect() {
        CometChat.removeConnectionListener("messages-header-sdk-listener-\(viewModel.listenerRandomId)")
        viewModel.disconnect()
    }

    // MARK: - Updates
    public func setupViewModel() {
        viewModel.updateUserStatus = { [weak self] isOnline in
            self?.updateUserStatus(isOnline)
        }
        
        viewModel.hideUserStatus = { [weak self] in
            self?.subtitleView.isHidden = true
            self?.subtitleView.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        viewModel.updateTypingStatus = { [weak self] byUser, isTyping in
            self?.updateTypingStatus(user: byUser, isTyping: isTyping)
        }
        
        viewModel.updateGroupCount = { [weak self] group in
            DispatchQueue.main.async {
                guard let self = self else { return }
                let text = "\(group.membersCount) \(group.membersCount > 1 ? MessageHeaderConstants.members : MessageHeaderConstants.member)"
                self.configureSubTitleView(text: text, isTyping: false)
            }
        }
    }

    open func updateUserStatus(_ isOnline: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self, self.viewModel.user != nil else { return }
            self.viewModel.user?.status = isOnline ? .online : .offline
            if let user = viewModel.user {
                if !disableUsersPresence {
                    let currentTime = Date()
                    
                    // Safely unwrap 'lastActiveAt' to ensure it's not nil
                    let lastSeenTime = Date(timeIntervalSince1970: user.lastActiveAt)
                    let timeDifference = currentTime.timeIntervalSince(lastSeenTime)
                    
                    // Check if user is online
                    if user.status == .online {
                        subtitleLabel.text = MessageHeaderConstants.online
                    }
                    // If the user has been offline for less than 1 hour (3600 seconds)
                    else if timeDifference < 3600 {
                        let minutesAgo = Int(timeDifference / 60)
                        if minutesAgo <= 1{
                            subtitleLabel.text = "Last seen a minute ago"
                        }else{
                            subtitleLabel.text = "Last seen \(minutesAgo) minutes ago"
                        }
                        
                    }
                    // If user was last seen more than an hour ago
                    else {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "d MMM 'at' h:mm a" // Customize date-time format as needed
                        subtitleLabel.text = "Last seen \(dateFormatter.string(from: lastSeenTime))"
                    }
                    subtitleLabel.textColor = style.subtitleTextColor

                } else {
                    subtitleView.isHidden = true
                }
            }
        }
    }

    private func updateTypingStatus(user: User?, isTyping: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if isTyping && !disableTyping {
                if let group = viewModel.group {
                    let text = (user?.name ?? "") + " " + MessageHeaderConstants.isTyping
                    configureSubTitleView(text: text, isTyping: true)
                } else {
                    configureSubTitleView(text: MessageHeaderConstants.typing, isTyping: true)
                }
            } else {
                if let group = viewModel.group {
                    let groupText = "\(group.membersCount) \(group.membersCount > 1 ? MessageHeaderConstants.members : MessageHeaderConstants.member)"
                    configureSubTitleView(text: groupText, isTyping: false)
                } else {
                    updateUserStatus(user?.status == .online)
                }
            }
        }
    }

    // MARK: - Actions
    @objc func didBackIconPressed() {
        if let navController = controller?.navigationController {
            if navController.viewControllers.first == controller {
                controller?.dismiss(animated: true)
            } else {
                navController.navigationBar.isHidden = false
                navController.popViewController(animated: true)
            }
        } else {
            controller?.dismiss(animated: true)
        }
    }
}


extension CometChatMessageHeader {
    
    @discardableResult
    public func set(tailView: UIView) -> Self {
        self.tailView.subviews.forEach({ $0.removeFromSuperview() })
        self.tailView.addArrangedSubview(tailView)
        return self
    }
    
    @discardableResult
    @objc public func set(user: User) -> CometChatMessageHeader {
        viewModel.set(user: user)
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configure(user: user)
        }
        return self
    }
    
    @discardableResult
    @objc public func set(group: Group) -> CometChatMessageHeader {
        viewModel.set(group: group)
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.configure(group: group)
        }
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
    public func hide(backButton: Bool) -> Self {
        self.backButton.isHidden = backButton
        self.backButtonView.isHidden = backButton
        return self
    }
}

extension CometChatMessageHeader {
    
    public func configureSubTitleView(text: String, isTyping: Bool = false) {
        subtitleLabel.text = text
        if isTyping {
            subtitleLabel.textColor = typingIndicatorStyle.textColor
            subtitleLabel.font = typingIndicatorStyle.textFont
        } else{
            subtitleLabel.textColor = style.subtitleTextColor
            subtitleLabel.font = style.subtitleTextFont
        }
    }
}

extension CometChatMessageHeader: CometChatConnectionDelegate {
    public func connected() {
        
        if let group = viewModel.group {
            CometChat.getGroup(GUID: group.guid) { [weak self] group in
                guard let this = self else { return }
                this.viewModel.group = group
                this.updateTypingStatus(user: nil, isTyping: false)
            } onError: { error in
                //TODO: ERROR
            }
        } else if let user = viewModel.user {
            CometChat.getUser(UID: viewModel.user?.uid ?? "") { [weak self] user in
                guard let this = self else { return }
                this.viewModel.user = user
                this.updateTypingStatus(user: user, isTyping: false)
                this.setupViewModel()
            } onError: { error in
                //TODO: ERROR
            }
        }
        
    }
    
    public func connecting() {}
    
    public func disconnected() {}
}

