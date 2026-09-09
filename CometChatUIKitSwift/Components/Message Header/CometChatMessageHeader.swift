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
    
    public lazy var leadingConatinerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    public lazy var backButtonView: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(didBackIconPressed), for: .touchUpInside)
        button.backgroundColor = .clear
        return button
    }()
    
    public lazy var avatar: CometChatAvatar = {
        let avatar = CometChatAvatar(frame: .zero).withoutAutoresizingMaskConstraints()
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
    
    public lazy var subtitle: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.embed(subtitleLabel, insets: .init(top: 1, leading: 0, bottom: 0, trailing: 0))
        return view
    }()
    
    public lazy var tailView: UIStackView = {
        let view = UIStackView().withoutAutoresizingMaskConstraints()
        view.distribution = .fill
        view.alignment = .center
        view.spacing = CometChatSpacing.Spacing.s4
        view.addArrangedSubview(UIView())
        view.widthAnchor.constraint(lessThanOrEqualToConstant: 120).isActive = true
        return view
    }()
    
//    private lazy var aiActionStackView: UIStackView = {
//        // Plus button
//        let plusButton = UIButton(type: .system)
//        plusButton.setImage(UIImage(systemName: "plus"), for: .normal)
//        plusButton.tintColor = .gray
//        plusButton.translatesAutoresizingMaskIntoConstraints = false
//        plusButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        plusButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        plusButton.addTarget(self, action: #selector(newChatButtonClicked), for: .touchUpInside)
//
//        // Refresh button
//        let refreshButton = UIButton(type: .system)
//        refreshButton.setImage(UIImage(systemName: "arrow.counterclockwise"), for: .normal)
//        refreshButton.tintColor = .gray
//        refreshButton.translatesAutoresizingMaskIntoConstraints = false
//        refreshButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
//        refreshButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
//        refreshButton.addTarget(self, action: #selector(aiHistoryButtonClicked), for: .touchUpInside)
//
//        // StackView
//        let stack = UIStackView(arrangedSubviews: [plusButton, refreshButton])
//        stack.axis = .horizontal
//        stack.alignment = .center
//        stack.spacing = 8
//        stack.distribution = .fillEqually
//        stack.translatesAutoresizingMaskIntoConstraints = false
//        return stack
//    }()
    
    private lazy var newChatButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.addTarget(self, action: #selector(newChatButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var chatHistoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 30).isActive = true
        button.heightAnchor.constraint(equalToConstant: 30).isActive = true
        button.addTarget(self, action: #selector(aiHistoryButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var aiActionStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [newChatButton, chatHistoryButton])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    public lazy var statusIndicator: CometChatStatusIndicator = {
        let indicator = CometChatStatusIndicator().withoutAutoresizingMaskConstraints()
        indicator.pin(anchors: [.height, .width], to: 13)
        return indicator
    }()

    // MARK: - Variables
    public var disableTyping: Bool = false
    private var hideBackIcon: Bool = false
    private var disableUsersPresence: Bool = false
    weak var controller: UIViewController?
    
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
    public static var avatarStyle = {
        var style = CometChatAvatar.style
        return style
    }()
    
    public var titleContainerStackView = UIStackView().withoutAutoresizingMaskConstraints()
    
    //Date Time Formatter
    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    public lazy var dateTimeFormatter: CometChatDateTimeFormatter = CometChatMessageHeader.dateTimeFormatter
    
    var onError: ((_ error: CometChatException) -> Void)?
    var onBack: (() -> Void)?
    var listItemView: ((_ user: User?, _ group: Group?) -> UIView)?
    var leadingView: ((_ user: User?, _ group: Group?) -> UIView)?
    var titleView: ((_ user: User?, _ group: Group?) -> UIView)?
    var subtitleView: ((_ user: User?, _ group: Group?) -> UIView)?
    var trailView: ((_ user: User?, _ group: Group?) -> UIView)?
    var auxiliaryView: ((_ user: User?, _ group: Group?) -> UIView)?
    
    var options: [CometChatPopupMenu.MenuItem]?
    private var menuButton: UIButton!
    
    //MARK: LOCAL STYLING
    public lazy var style = CometChatMessageHeader.style
    public lazy var statusIndicatorStyle = CometChatMessageHeader.statusIndicatorStyle
    public lazy var typingIndicatorStyle = CometChatMessageHeader.typingIndicatorStyle
    
    public var additionalConfiguration = AdditionalConfiguration()
    
    public var hideBackButton: Bool = false {
        didSet {
            updateUI()
        }
    }
    public var hideUserStatus: Bool = false {
        didSet {
            updateUI()
        }
    }
    public var hideVideoCallButton: Bool = false{
        didSet{
            additionalConfiguration.hideVideoCallButton = hideVideoCallButton
        }
    }
    public var hideVoiceCallButton: Bool = false{
        didSet{
            additionalConfiguration.hideVoiceCallButton = hideVoiceCallButton
        }
    }
    public lazy var avatarStyle = CometChatMessageHeader.avatarStyle

    // MARK: - ViewModel
    open var viewModel: MessageHeaderViewModelProtocol = MessageHeaderViewModel()
    public var onAiChatHistoryClicked: ((User) -> Void)?
    public var onAiNewChatClicked: ((User) -> Void)?
    public var hideNewChatButton: Bool = false
    public var hideChatHistoryButton: Bool = false

    /// The thread's root message the subscription bell acts on. The bell renders
    /// only when this is set — that is what puts the header in thread mode.
    public var parentMessage: BaseMessage? {
        didSet { addCustomViews() }
    }
    /// Master switch for the bell, mirroring the message list's own flag.
    /// Hides the bell while leaving the feature on, for a host that already
    /// renders its own control elsewhere on the screen.
    public var hideThreadSubscriptionButton: Bool = false

    /// Subscribe/unsubscribe control, in the header's trailing area.
    public lazy var threadSubscriptionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(onThreadSubscriptionButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24)
        ])
        return button
    }()

    // MARK: - Initialization
    override public init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        buildUI()
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil{
            setupStyle()
            connect()
            updateUI()
            addCustomViews()
        }
    }
    
    /// Rebuilds the ⋮ menu from `options` onto the existing button.
    ///
    /// Split out of `addCustomViews()` so `set(options:)` can refresh the menu after the
    /// header is already laid out — needed by any menu item whose title or icon depends on
    /// state (a Pin/Unpin toggle, for instance), since `MenuItem` carries no toggle state
    /// and its properties are not readable from outside the module.
    internal func rebuildMenu(for options: [CometChatPopupMenu.MenuItem]) {
        guard let button = menuButton else { return }

        let actions = options.map { item in
            UIAction(title: item.title, image: item.icon) { _ in item.action?() }
        }

        if #available(iOS 14.0, *) {
            button.menu = UIMenu(title: "", children: actions)
            button.showsMenuAsPrimaryAction = true
        }
    }

    func addCustomViews(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tailView.subviews.forEach({ $0.removeFromSuperview() })

            if let auxiliaryView = self.auxiliaryView?(self.viewModel.user, self.viewModel.group) {
                self.tailView.addArrangedSubview(auxiliaryView)
            } else {
                if self.viewModel.user?.isAgentic ?? false{
                    newChatButton.setImage(style.newChatButtonImage, for: .normal)
                    chatHistoryButton.setImage(style.chatHistoryButtonImage, for: .normal)
                    newChatButton.tintColor = style.newChatButtonImageTintColor
                    chatHistoryButton.tintColor = style.chatHistoryButtonImageTintColor
                    newChatButton.isHidden = hideNewChatButton
                    chatHistoryButton.isHidden = hideChatHistoryButton
                    self.tailView.addArrangedSubview(aiActionStackView)
                }
                else if let auxiliaryHeaderMenu = CometChatUIKit.getDataSource().getAuxiliaryHeaderMenu(user: self.viewModel.user, group: self.viewModel.group, controller: self.controller, id: nil, additionalConfiguration: self.additionalConfiguration){
                    auxiliaryHeaderMenu.distribution = .fillEqually
                    self.tailView.addArrangedSubview(auxiliaryHeaderMenu)
                }
                if let options = self.options, !options.isEmpty {

                    self.menuButton?.removeFromSuperview()

                    // Create button
                    let button = UIButton(type: .system)
                    button.translatesAutoresizingMaskIntoConstraints = false
                    button.setImage(style.menuIcon, for: .normal)
                    button.tintColor = style.menuIconTintColor

                    // Add to tailView
                    self.tailView.addArrangedSubview(button)
                    self.menuButton = button

                    self.rebuildMenu(for: options)

                    // Optional button constraints
                    button.widthAnchor.constraint(equalToConstant: 24).isActive = true
                    button.heightAnchor.constraint(equalToConstant: 24).isActive = true
                }
            }
            
            // Thread mode: the bell replaces the conversation-level trailing items.
            if self.shouldShowThreadSubscription {
                self.tailView.alignment = .center
                self.tailView.addArrangedSubview(self.threadSubscriptionButton)
                self.updateThreadSubscriptionState()
            }

            if let trailView = trailView?(viewModel.user, viewModel.group){
                self.tailView.alignment = .center
                self.tailView.addArrangedSubview(trailView)
            }
            
            if let titleView = titleView?(viewModel.user, viewModel.group){
                self.titleLabelView.subviews.forEach({$0.removeFromSuperview()})
                self.titleLabelView.embed(titleView)
            }
            
            if let subtitleView = subtitleView?(viewModel.user, viewModel.group){
                self.subtitle.isHidden = false
                self.subtitle.subviews.forEach({$0.removeFromSuperview()})
                self.subtitle.embed(subtitleView)
            }
            
            if let leadingView = leadingView?(viewModel.user, viewModel.group){
                self.leadingConatinerView.subviews.forEach({ $0.removeFromSuperview() })
                var constraintsToActivate = [NSLayoutConstraint]()
                self.leadingConatinerView.addSubview(leadingView)
                constraintsToActivate += [
                    leadingView.leadingAnchor.pin(equalTo: leadingConatinerView.leadingAnchor),
                    leadingView.topAnchor.pin(equalTo: leadingConatinerView.topAnchor),
                    leadingView.bottomAnchor.pin(equalTo: leadingConatinerView.bottomAnchor),
                    leadingView.trailingAnchor.pin(equalTo: leadingConatinerView.trailingAnchor),
                    leadingView.widthAnchor.constraint(equalToConstant: 100)
                ]
                NSLayoutConstraint.activate(constraintsToActivate)
            }
            
            if let listItemView = listItemView?(viewModel.user, viewModel.group){
                listItemView.translatesAutoresizingMaskIntoConstraints = false
                self.embed(listItemView)
                self.bringSubviewToFront(listItemView)
            }
        }
    }
    
    func updateUI(){
        if hideBackButton{
            backButtonView.removeFromSuperview()
            if leadingConatinerView.subviews.contains(avatar){
                avatar.leadingAnchor.pin(equalTo: leadingConatinerView.leadingAnchor, constant: 16).isActive = true
                avatar.centerYAnchor.pin(equalTo: titleContainerStackView.centerYAnchor).isActive = true
            }
        }
        
        if hideUserStatus{
            self.subtitle.isHidden = true
            self.subtitle.subviews.forEach({ $0.removeFromSuperview() })
        } else {
            if let user = viewModel.user {
                updateUserStatus(user.status == .online ? true : false)
            }
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
        
        addSubview(leadingConatinerView)
        constraintsToActivate += [
            leadingConatinerView.leadingAnchor.pin(equalTo: leadingAnchor),
            leadingConatinerView.topAnchor.pin(equalTo: topAnchor),
            leadingConatinerView.bottomAnchor.pin(equalTo: bottomAnchor),
            leadingConatinerView.centerYAnchor.pin(equalTo: centerYAnchor),
            leadingConatinerView.trailingAnchor.pin(equalTo: titleContainerStackView.leadingAnchor, constant: -CometChatSpacing.Padding.p3)
        ]
        
        leadingConatinerView.addSubview(backButtonView)
        backButtonView.addSubview(backButton)
        constraintsToActivate += [
            backButtonView.leadingAnchor.pin(equalTo: leadingConatinerView.leadingAnchor),
            backButtonView.topAnchor.pin(equalTo: leadingConatinerView.topAnchor),
            backButtonView.bottomAnchor.pin(equalTo: leadingConatinerView.bottomAnchor),
            backButton.leadingAnchor.pin(equalTo: backButtonView.leadingAnchor, constant: CometChatSpacing.Padding.p4),
            backButton.trailingAnchor.pin(equalTo: backButtonView.trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            backButton.centerYAnchor.pin(equalTo: leadingConatinerView.centerYAnchor)
        ]
        
        leadingConatinerView.addSubview(avatar)
        constraintsToActivate += [
            avatar.leadingAnchor.pin(equalTo: backButtonView.trailingAnchor),
            avatar.centerYAnchor.pin(equalTo: backButton.centerYAnchor),
            avatar.trailingAnchor.pin(equalTo: leadingConatinerView.trailingAnchor, constant: 0)
        ]
        
        leadingConatinerView.addSubview(statusIndicator)
        constraintsToActivate += [
            statusIndicator.trailingAnchor.pin(equalTo: avatar.trailingAnchor, constant: -1),
            statusIndicator.bottomAnchor.pin(equalTo: avatar.bottomAnchor, constant: -1)
        ]
        
        titleContainerStackView.axis = .vertical
        titleContainerStackView.distribution = .equalCentering
        titleContainerStackView.alignment = .leading
        addSubview(titleContainerStackView)
        titleContainerStackView.addArrangedSubview(titleLabelView)
        titleContainerStackView.addArrangedSubview(subtitle)
        
        constraintsToActivate += [
            titleContainerStackView.centerYAnchor.constraint(equalTo: leadingConatinerView.centerYAnchor)
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
    
    @objc func aiHistoryButtonClicked() {
        if let user = viewModel.user{
            self.onAiChatHistoryClicked?(user)
        }
    }
    
    @objc func newChatButtonClicked() {
        if let user = viewModel.user{
            self.onAiNewChatClicked?(user)
        }
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
        avatar.style = avatarStyle
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
        // Keeps the bell in step with a toggle made from the message action sheet.
        CometChatThreadEvents.addListener("messages-header-thread-listener-\(viewModel.listenerRandomId)", self)
        setupViewModel()
        self.viewModel.connect()
    }

    public func disconnect() {
        CometChat.removeConnectionListener("messages-header-sdk-listener-\(viewModel.listenerRandomId)")
        CometChatThreadEvents.removeListener("messages-header-thread-listener-\(viewModel.listenerRandomId)")
        viewModel.disconnect()
    }

    // MARK: - Thread Subscription

    /// The bell renders only in thread mode — a parent message is set, the feature is
    /// on, and the host has not suppressed it in favour of its own control.
    ///
    /// Offered in 1-1 threads as well as groups, matching the action-sheet option:
    /// subscribing applies to `receiverType: user` too, so there is no receiver-type gate.
    var shouldShowThreadSubscription: Bool {
        guard let parentMessage, parentMessage.id > 0 else { return false }
        return CometChatUIKit.isThreadSubscriptionEnabled() && !hideThreadSubscriptionButton
    }

    /// Reads the flag off the parent message rather than tracking its own state, so the
    /// bell and the action sheet never disagree. A message that arrived without the flag
    /// renders as unsubscribed.
    open func updateThreadSubscriptionState() {
        guard let parentMessage, parentMessage.id > 0 else { return }
        renderThreadSubscription(isSubscribed: parentMessage.threadSubscribed)
    }

    open func renderThreadSubscription(isSubscribed: Bool) {
        threadSubscriptionButton.setImage(
            isSubscribed ? AssetConstants.unfollowThread : AssetConstants.followThread,
            for: .normal
        )
        threadSubscriptionButton.tintColor = isSubscribed
            ? CometChatTheme.iconColorHighlight
            : CometChatTheme.iconColorPrimary
        // State-labelled, not action-labelled, so the name matches what is shown.
        threadSubscriptionButton.accessibilityLabel = isSubscribed
            ? "THREAD_SUBSCRIBED".localize()
            : "THREAD_SUBSCRIBE".localize()
    }

    @objc open func onThreadSubscriptionButtonTapped() {
        guard let parentMessage, parentMessage.id > 0 else { return }

        let parentMessageId = parentMessage.id
        let isSubscribed = parentMessage.threadSubscribed

        // Flip now so the control responds to the tap; the original goes back on failure.
        renderThreadSubscription(isSubscribed: !isSubscribed)
        threadSubscriptionButton.isEnabled = false

        let onSuccess: (String) -> Void = { [weak self] _ in
            DispatchQueue.main.async {
                guard let this = self else { return }
                this.threadSubscriptionButton.isEnabled = true
                // Stamp the message: it is the source of truth the bell reads back.
                this.parentMessage?.threadSubscribed = !isSubscribed
                CometChatThreadEvents.ccThreadSubscriptionChanged(parentMessageId: parentMessageId,
                                                                  isSubscribed: !isSubscribed)
                // Unsubscribing is not permanent, so say so rather than let the user discover it.
                let toast = isSubscribed ? "THREAD_UNSUBSCRIBED_TOAST" : "THREAD_SUBSCRIBED_TOAST"
                CometChatToast.show(message: toast.localize(), on: this.controller)
            }
        }

        let onError: (CometChatException) -> Void = { [weak self] _ in
            DispatchQueue.main.async {
                guard let this = self else { return }
                this.threadSubscriptionButton.isEnabled = true
                this.renderThreadSubscription(isSubscribed: isSubscribed)
                CometChatToast.show(message: "THREAD_SUBSCRIPTION_FAILED".localize(), on: this.controller)
            }
        }

        if isSubscribed {
            CometChat.unsubscribeFromThread(parentMessageId: parentMessageId, onSuccess: onSuccess, onError: onError)
        } else {
            CometChat.subscribeToThread(parentMessageId: parentMessageId, onSuccess: onSuccess, onError: onError)
        }
    }

    // MARK: - Updates
    public func setupViewModel() {
        
        viewModel.onUpdate = { [weak self] in
            self?.addCustomViews()
        }
        
        viewModel.updateUserStatus = { [weak self] isOnline in
            self?.updateUserStatus(isOnline)
        }
        
        viewModel.hideUserStatus = { [weak self] in
            self?.subtitle.isHidden = true
            self?.subtitle.subviews.forEach({ $0.removeFromSuperview() })
        }
        
        viewModel.unHideUserStatus = { [weak self] in
            guard let self = self else { return }
            self.subtitle.isHidden = false
            self.subtitle.embed(subtitleLabel, insets: .init(top: 1, leading: 0, bottom: 0, trailing: 0))
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
                    let dateTimeFormatterUtils = DateTimeFormatterUtils()
                    
                    // Safely unwrap 'lastActiveAt' to ensure it's not nil
                    let lastSeenTime = Date(timeIntervalSince1970: user.lastActiveAt)
                    let timeDifference = currentTime.timeIntervalSince(lastSeenTime)

                    let timestamp = Int(user.lastActiveAt)

                    // If the user is online
                    if user.status == .online {
                        subtitleLabel.text = MessageHeaderConstants.online
                    }
                    else if user.lastActiveAt == 0 {
                        subtitleLabel.text = "OFFLINE".localize()
                    }
                    else if let formatter = dateTimeFormatterUtils.getFormattedDateFromClosures(timeStamp: timestamp, dateTimeFormatter: dateTimeFormatter){
                        subtitleLabel.text = "\("LAST_SEEN".localize()) \(formatter)"
                    }else{
                        if timeDifference < 3600 {
                            let minutesAgo = Int(timeDifference / 60)
                            if minutesAgo <= 1{
                                subtitleLabel.text = "LAST_SEEN_A_MINUTE_AGO".localize()
                            }else{
                                subtitleLabel.text = "\("LAST_SEEN".localize()) \(minutesAgo) \("MINUTES_AGO".localize())"
                            }
                        }
                        else {
                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: CometChatLocalize.getLocale())
                            dateFormatter.dateFormat = "d MMM 'at' h:mm a"
                            subtitleLabel.text = "\("LAST_SEEN".localize()) \(dateFormatter.string(from: lastSeenTime))"
                        }
                    }
                    subtitleLabel.textColor = style.subtitleTextColor

                } else {
                    subtitle.isHidden = true
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
        if let onBack = onBack?(){
            onBack
            return
        }
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

extension CometChatMessageHeader: CometChatThreadEventListener {

    public func ccThreadSubscriptionChanged(parentMessageId: Int, isSubscribed: Bool) {
        guard parentMessageId == parentMessage?.id else { return }
        DispatchQueue.main.async { [weak self] in
            self?.renderThreadSubscription(isSubscribed: isSubscribed)
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
                if let error = error, let onError = self.onError?(error){
                    onError
                }
            }
        } else if let user = viewModel.user {
            CometChat.getUser(UID: viewModel.user?.uid ?? "") { [weak self] user in
                guard let this = self else { return }
                this.viewModel.user = user
                this.updateTypingStatus(user: user, isTyping: false)
                this.setupViewModel()
            } onError: { error in
                if let error = error, let onError = self.onError?(error){
                    onError
                }
            }
        }
        
    }
    
    public func connecting() {}
    
    public func disconnected() {}
}

