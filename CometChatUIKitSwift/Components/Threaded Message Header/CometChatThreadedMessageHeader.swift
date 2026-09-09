//
//  CometChatThreadedMessageHeader.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 15/10/24.
//

import UIKit
import CometChatSDK

open class CometChatThreadedMessageHeader: UIView {

    //Story board variable
    public lazy var bubbleContainerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: CometChatSpacing.Padding.p2, left: 0, bottom: CometChatSpacing.Padding.p2, right: 0)
        return stackView
    }()
    
    public lazy var bubbleScrollView: UIScrollView = {
        let scrollView = UIScrollView().withoutAutoresizingMaskConstraints()
        scrollView.addSubview(bubbleContainerView)
        NSLayoutConstraint.activate([
            bubbleContainerView.leadingAnchor.pin(equalTo: scrollView.leadingAnchor),
            bubbleContainerView.trailingAnchor.pin(equalTo: scrollView.trailingAnchor),
            bubbleContainerView.topAnchor.pin(equalTo: scrollView.topAnchor),
            bubbleContainerView.bottomAnchor.pin(equalTo: scrollView.bottomAnchor),
            bubbleContainerView.widthAnchor.pin(equalTo: scrollView.widthAnchor),
        ])
        return scrollView
    }()
    
    public lazy var threadCountContainerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.spacing = CometChatSpacing.Padding.p2
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(
            top: CometChatSpacing.Padding.p1,
            left: CometChatSpacing.Padding.p5,
            bottom: CometChatSpacing.Padding.p1,
            right: CometChatSpacing.Padding.p5
        )
        
        stackView.addArrangedSubview(threadCountLabel)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(threadSubscriptionButton)
        return stackView
    }()

    public lazy var threadCountLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        return label
    }()

    /// Subscribe/unsubscribe control, a trailing action on the reply-count bar.
    public lazy var threadSubscriptionButton: UIButton = {
        let button = UIButton(type: .system).withoutAutoresizingMaskConstraints()
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(onThreadSubscriptionButtonTapped), for: .touchUpInside)
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 24),
            button.heightAnchor.constraint(equalToConstant: 24)
        ])
        return button
    }()

    //Config Variable
    public var enableSoundForMessages: Bool = true
    public var customIncomingMessageSound: URL?
    public var customOutgoingMessageSound: URL?
    public var customSoundForOutgoingMessages: URL?
    public var singleNewMessageText: String = "ONE_REPLY".localize()
    public var multipleNewMessageText: String = "REPLIES".localize()
    public var controller: UIViewController?
    var template: CometChatMessageTemplate?
    var storedTemplates: [CometChatMessageTemplate]?
    public var messageAlignment: MessageListAlignment = .standard
    public var hideReceipt: Bool = false
    public var hideBubbleHeader: Bool = false
    public var messageBubbleStyle = CometChatMessageBubble.style
    public var maxHeight: CGFloat = 250 {
        didSet {
            heightConstant.constant = maxHeight
        }
    }
    var textFormatters: [CometChatTextFormatter] = {
        return ChatConfigurator.getDataSource().getTextFormatters()
    }()
    var datePattern: ((_ conversation: Conversation) -> String)?
    public var hideReplyCount: Bool = false
    public var hideReplyCountBar: Bool = false
    /// Master switch for the subscribe/unsubscribe bell, mirroring the message list's flag.
    /// Hides the bell while leaving the feature on, for a host that already renders
    /// its own control elsewhere on the screen.
    public var hideThreadSubscriptionButton: Bool = false
    public var hideAvatar: Bool?

    //Helper Variable
    public static var style = ThreadedMessageHeaderStyle()
    public lazy var style = CometChatThreadedMessageHeader.style
    internal var count: Int = 0
    private var heightConstant: NSLayoutConstraint!
    open var viewModel: ThreadedMessageHeaderViewModelProtocol = ThreadedMessageHeaderViewModel()
    
    //Date Time Formatter
    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    public lazy var dateTimeFormatter: CometChatDateTimeFormatter = CometChatThreadedMessageHeader.dateTimeFormatter
    
    lazy var onTapGesture: UITapGestureRecognizer = {
        let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        onTapGesture.cancelsTouchesInView = false
        return onTapGesture
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = true
        buildUI()
        setupViewModel()
        addKeyboardDismissGesture()
    }
    
    public init() {
        super.init(frame: .zero)
        isUserInteractionEnabled = true
        buildUI()
        setupViewModel()
        addKeyboardDismissGesture()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var getCount: Int {
        get {
            return count
        }
    }
    
    deinit {
        disconnect()
        removeKeyboardDismissGesture()
    }
    
    open func setupViewModel() {
        viewModel.incrementCount = { [weak self] in
            if let self {
                self.incrementCount()
            }
        }

        // Keeps the bell in step with a toggle made from the message action sheet.
        viewModel.onThreadSubscriptionChanged = { [weak self] isSubscribed in
            DispatchQueue.main.async {
                self?.renderThreadSubscription(isSubscribed: isSubscribed)
            }
        }
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            connect()
            setupThreadCountIndicator()
            setupStyle()
            updateUI()
        }
    }
    
    func updateUI(){
        threadCountLabel.isHidden = hideReplyCount
        threadCountContainerView.isHidden = hideReplyCountBar
        updateThreadSubscriptionState()
    }

    open func setupStyle() {
        backgroundColor = style.backgroundColor
        borderWith(width: style.borderWith)
        borderColor(color: style.borderColor)
        if let cornerRadius = style.cornerRadius {
            roundViewCorners(corner: cornerRadius)
        }
        
        bubbleScrollView.backgroundColor = style.bubbleContainerBackgroundColor
        bubbleScrollView.borderWith(width: style.bubbleContainerBorderWidth)
        bubbleScrollView.borderColor(color: style.bubbleContainerBorderColor)
        if let bubbleContainerCornerRadius = style.bubbleContainerCornerRadius {
            bubbleScrollView.roundViewCorners(corner: bubbleContainerCornerRadius)
        }
        
        threadCountContainerView.backgroundColor = style.dividerTintColor
        threadCountLabel.textColor = style.countTextColor
        threadCountLabel.font = style.countTextFont
        
    }
    
    open func buildUI() {
        
        heightConstant = heightAnchor.constraint(lessThanOrEqualToConstant: maxHeight)
        heightConstant.isActive = true
        
        withoutAutoresizingMaskConstraints()
        
        var constraintsToActive = [NSLayoutConstraint]()
        
        addSubview(bubbleScrollView)
        constraintsToActive += [
            bubbleScrollView.leadingAnchor.pin(equalTo: leadingAnchor),
            bubbleScrollView.trailingAnchor.pin(equalTo: trailingAnchor),
            bubbleScrollView.topAnchor.pin(equalTo: topAnchor),
        ]
        
        addSubview(threadCountContainerView)
        
        constraintsToActive += [
            threadCountContainerView.topAnchor.pin(equalTo: bubbleScrollView.bottomAnchor),
            threadCountContainerView.leadingAnchor.pin(equalTo: leadingAnchor),
            threadCountContainerView.trailingAnchor.pin(equalTo: trailingAnchor),
            threadCountContainerView.bottomAnchor.pin(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraintsToActive)
        
        
    }
    
    //Setting Up Message Bubble View
    open func setupMessageBubbleView() {
        let cell = CometChatMessageBubble(style: .default, reuseIdentifier: "CometChatMessageBubble")
        
        if let template = template, let message = self.viewModel.parentMessage {
            let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
            let bubbleStyle = isLoggedInUser ? messageBubbleStyle.outgoing : messageBubbleStyle.incoming
            let messageTypeStyle = MessageUtils.getSpecificMessageTypeStyle(message: message, from: messageBubbleStyle)
            cell.set(style: bubbleStyle, specificMessageTypeStyle: messageTypeStyle)
            
            //setting cell alignment
            switch messageAlignment {
            case .standard:
                if isLoggedInUser {
                    cell.set(bubbleAlignment: .right)
                } else {
                    cell.set(bubbleAlignment: .left)
                }
            case .leftAligned:
                cell.set(bubbleAlignment: .left)
            }
            
            //setting up avatar view
            if let user = message.sender {
                cell.set(avatarURL: user.avatar, avatarName: user.name)
                
                //setting header View
                switch message.receiverType {
                case .user:
                    cell.hide(headerView: true)
                    if cell.alignment == .left {
                        cell.hide(avatar: hideAvatar ?? true)
                    }
                case .group:
                    if cell.alignment == .left {
                        cell.hide(avatar: hideAvatar ?? false)
                        cell.hide(headerView: false)
                    } else {
                        cell.hide(headerView: true)
                    }
                @unknown default:
                    break
                }
            }
            
            //adding headerView
            if let headerView = template.headerView?(message, cell.alignment, controller) {
                cell.hide(headerView: false)
                cell.set(headerView: headerView)
            } else {
                if !hideBubbleHeader {
                    let nameLabel = UILabel()
                    nameLabel.numberOfLines = 1
                    nameLabel.text = isLoggedInUser ? "YOU".localize() : message.sender?.name?.capitalized ?? ""
                    nameLabel.font = messageTypeStyle?.headerTextFont ?? bubbleStyle.headerTextFont
                    nameLabel.textColor = messageTypeStyle?.headerTextColor ?? bubbleStyle.headerTextColor
                    
                    cell.set(headerView: nameLabel)
                }
            }
            
            //adding contentView
            if let contentView = template.contentView?(message, cell.alignment, controller) {
                cell.set(contentView: contentView)
            }
            
            //adding bottomView
            if let bottomView = template.bottomView?(message, cell.alignment, controller) {
                cell.set(bottomView: bottomView)
            }
            
            //adding date and read receipt
            if let statusInfoView = template.statusInfoView?(message, cell.alignment, controller) {
                cell.set(statusInfoView: statusInfoView)
            } else {
                MessageUtils.buildStatusInfo(
                    from: cell,
                    messageTypeStyle: messageTypeStyle,
                    bubbleStyle: bubbleStyle,
                    message: message,
                    hideReceipt: hideReceipt,
                    messageAlignment: messageAlignment, dateTimeFormatter: dateTimeFormatter
                )
            }
            
            if let footerView = template.footerView?(message, cell.alignment, controller) {
                cell.set(footerView: footerView)
            }
            
            if let bubbleView = template.bubbleView?(message, cell.alignment, controller){
                cell.set(bubbleView: bubbleView)
            }
            
            if let quotedMessage = message.quotedMessage{
                if let replyView = template.replyView?(quotedMessage, cell.alignment, controller) {
                    cell.set(replyView: replyView)
                }else{
                    if quotedMessage.deletedAt <= 0 {
                        let preview = CometChatMessagePreview.makePreview(
                            for: quotedMessage,
                            isLoggedInUser: isLoggedInUser,
                            textFormatters: textFormatters,                 // use your existing variable
                            formattingType: .MESSAGE_BUBBLE,
                            style: messageTypeStyle?.messagePreviewStyle ?? bubbleStyle.messagePreviewStyle,
                            onPreviewClicked: nil,
                            onCrossClicked: nil,
                            hideCloseButton: true                           // you had closeButton.isHidden = true
                        )

                        cell.set(replyView: preview)

                    }
                }
            }
        }
        
        bubbleContainerView.subviews.forEach({ $0.removeFromSuperview() })
        bubbleContainerView.addArrangedSubview(cell.contentView)
        bubbleContainerView.layoutIfNeeded()
        
        if bubbleContainerView.bounds.height < (maxHeight - 30) {
            bubbleContainerView.heightAnchor.pin(equalTo: bubbleScrollView.heightAnchor).isActive = true
        }
        
    }
    
    open func setupThreadCountIndicator() {
        set(count: viewModel.parentMessage?.replyCount ?? 0)
    }

    // MARK: - Thread Subscription

    /// The bell renders only on a sent root message, with the feature on and the host
    /// not suppressing it in favour of its own control.
    ///
    /// Offered in 1-1 threads as well as groups, matching the action-sheet option:
    /// subscribing applies to `receiverType: user` too, so there is no receiver-type gate.
    var shouldShowThreadSubscription: Bool {
        guard let parentMessage = viewModel.parentMessage, parentMessage.id > 0 else { return false }
        return CometChatUIKit.isThreadSubscriptionEnabled() && !hideThreadSubscriptionButton
    }

    /// Reads the flag off the parent message rather than tracking its own state, so the
    /// bell and the action sheet never disagree. A message that arrived without the flag
    /// renders as unsubscribed.
    open func updateThreadSubscriptionState() {
        threadSubscriptionButton.isHidden = !shouldShowThreadSubscription
        guard let parentMessage = viewModel.parentMessage, parentMessage.id > 0 else { return }
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
        guard let parentMessage = viewModel.parentMessage, parentMessage.id > 0 else { return }

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
                this.viewModel.parentMessage?.threadSubscribed = !isSubscribed
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
    
    open func connect() {
        viewModel.connect()
    }
    
    open func disconnect() {
        viewModel.disconnect()
    }
    
    func getDefaultTemplate(for message: BaseMessage) {
        let additionalConfiguration = AdditionalConfiguration()
        additionalConfiguration.messageBubbleStyle = messageBubbleStyle
        
        var messageType = message.messageType.toString()
        let messageCategory = message.messageCategory.toString()
        
        if let customMessage = message as? CustomMessage {
            messageType = customMessage.type ?? ""
        }
        
        let allMessageTemplates = ChatConfigurator.getDataSource().getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        allMessageTemplates.forEach { template in
            if template.category == messageCategory && template.type == messageType {
                self.template = template
            }
        }
    }
    
    func applyTemplates(_ templates: [CometChatMessageTemplate]) {
        guard let parentMessage = viewModel.parentMessage else { return }
        
        var messageType = parentMessage.messageType.toString()
        let messageCategory = parentMessage.messageCategory.toString()
        
        if let customMessage = parentMessage as? CustomMessage {
            messageType = customMessage.type ?? ""
        }
        
        templates.forEach { template in
            if template.category == messageCategory && template.type == messageType {
                self.template = template
            }
        }
        
        setupMessageBubbleView()
    }
    
}

extension CometChatThreadedMessageHeader {
    func addKeyboardDismissGesture() {
        self.addGestureRecognizer(onTapGesture)
        controller?.view.addGestureRecognizer(onTapGesture)
    }
    
    @objc func dismissKeyboard() {
        UIApplication.shared.keyWindow?.endEditing(true)
        self.endEditing(true)
        controller?.view.endEditing(true)
    }

    
    func removeKeyboardDismissGesture() {
        self.removeGestureRecognizer(onTapGesture)
        controller?.view.removeGestureRecognizer(onTapGesture)
    }
}

