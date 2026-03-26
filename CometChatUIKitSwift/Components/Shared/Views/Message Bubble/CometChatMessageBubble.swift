//
//  CometChatMessageBubble.swift
//
//
//  Created by Suryansh Bisen on 2/09/24.
//

import UIKit
import CometChatSDK

open class CometChatMessageBubble: UITableViewCell {
    
    // top most container
    public lazy var containerStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .top
        return stackView
    }()
    
    public lazy var headerView: UIView = UIView()
        .withoutAutoresizingMaskConstraints()
    
    public lazy var middleStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        return stackView
    }()
    
    // container for replayView, messageContentView, statusInfoView, bottomView
    public lazy var bubbleStackView: UIStackView = {
        var stackView = UIStackView()
        stackView.withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        return stackView
    }()
    
    public let highlightOverlay: UIView = {
        let v = UIView()
        v.isUserInteractionEnabled = false
        v.backgroundColor = .clear
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    public var messagePreview: UIView?
    
    public lazy var replayView: UIView = UIView()
        .withoutAutoresizingMaskConstraints()
    
    public lazy var messageContentView: UIView = UIView()
        .withoutAutoresizingMaskConstraints()
    
    public lazy var statusInfoView: UIView = UIView()
        .withoutAutoresizingMaskConstraints()
    
    public lazy var bottomView: UIView = UIView()
        .withoutAutoresizingMaskConstraints()
    
    public lazy var footerView: UIView = UIView()
        .withoutAutoresizingMaskConstraints()
    
    // For threaded message indicator
    public lazy var viewReplyView: UIView = UIView()
        .withoutAutoresizingMaskConstraints()
    
    // will contain avatar view
    public lazy var leadingView: UIStackView = {
        var stackView = UIStackView()
        stackView.withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        return stackView
    }()
    
    public lazy var avatarContainerView: UIStackView = {
        var stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.addArrangedSubview(avatar)
        stackView.distribution = .fill
        return stackView
    }()
    
    public var message: BaseMessage?
    //This will be used for setting whole bubble's view custom
    public var customBubbleView: UIView?
    public var bubbleViewSpacing: CGFloat = 10
    public lazy var leadingSpacer = UIView().withoutAutoresizingMaskConstraints() //spacer for containerStackView
    public lazy var trailingSpacer = UIView().withoutAutoresizingMaskConstraints() //spacer for containerStackView
    public lazy var avatar = CometChatAvatar(image: nil).withoutAutoresizingMaskConstraints()
    static public var style = (
        incoming: MessageBubbleStyle(styleType: .incoming),
        outgoing: MessageBubbleStyle(styleType: .outgoing)
    )
    static public var actionBubbleStyle = GroupActionBubbleStyle()
    static public var callActionBubbleStyle = CallActionBubbleStyle()
    
    //-------- styling variables -------- //
    var alignment: MessageBubbleAlignment = .right
    static let identifier = "CometChatMessageBubble"
    var actionSheetStyle : ActionSheetStyle = CometChatActionSheet.style
    var messagePreviewStyle : MessagePreviewStyle = CometChatMessagePreview.style
    var avatarName: String?
    var avatarURL: String?
    
    //-------- context menu variables -------- //
    weak var baseMessage: BaseMessage?
    var firstLongPressForAnimation: UILongPressGestureRecognizer?
    var secondLongPressForAction: UILongPressGestureRecognizer?
    var onLongPressGestureRecognized: (() -> Void)?
    var disableSwipeToReply: Bool = false
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        buildUI()
        setupThemeObserver()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("CometChatThemeChanged"), object: nil)
    }
    
    private func setupThemeObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleThemeChange),
            name: NSNotification.Name("CometChatThemeChanged"),
            object: nil
        )
    }
    
    @objc private func handleThemeChange() {
        // Re-apply the style to update colors
        // The style's computed properties will fetch the latest theme colors
        if let message = message {
            // Determine if this is an outgoing message
            let isOutgoing = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
            let currentStyle = isOutgoing ? CometChatMessageBubble.style.outgoing : CometChatMessageBubble.style.incoming
            
            // Re-apply background color from the style
            set(backgroundColor: currentStyle.backgroundColor)
        }
    }
    
    @objc func onLongPressStarted(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .ended || sender.state == .cancelled {
            UIView.animate(withDuration: 0.1) {
                self.bubbleStackView.transform = .identity
            }
        } else {
            UIView.animate(withDuration: 0.1) {
                self.bubbleStackView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        }
    }
    
    @objc func onLongPressEnded(_ sender: UILongPressGestureRecognizer) {
        
        if sender.state == .began {
            let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
            impactFeedbackGenerator.prepare()
            impactFeedbackGenerator.impactOccurred()
            
            onLongPressGestureRecognized?()
        }
    }
    
    open func buildUI() {
        
        contentView.addSubview(highlightOverlay)

        NSLayoutConstraint.activate([
            highlightOverlay.topAnchor.constraint(equalTo: contentView.topAnchor),
            highlightOverlay.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            highlightOverlay.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            highlightOverlay.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        firstLongPressForAnimation = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressStarted(_:)))
        firstLongPressForAnimation!.minimumPressDuration = 0.2
        firstLongPressForAnimation!.delegate = self
        bubbleStackView.addGestureRecognizer(firstLongPressForAnimation!)

        secondLongPressForAction = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressEnded(_:)))
        secondLongPressForAction!.minimumPressDuration = 0.3
        bubbleStackView.addGestureRecognizer(secondLongPressForAction!)
        
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerStackView)
        contentView.embed(
            containerStackView,
            insets: NSDirectionalEdgeInsets(
                top: CometChatSpacing.Padding.p2,
                leading: CometChatSpacing.Padding.p4,
                bottom: CometChatSpacing.Padding.p2,
                trailing: CometChatSpacing.Padding.p4
            )
        )
        
        // Set content hugging and compression resistance for flexible resizing
        containerStackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        containerStackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        //Setting custom view
        if let bubbleView = customBubbleView {
            containerStackView.embed(bubbleView)
            return
        }
        
        containerStackView.addArrangedSubview(leadingSpacer)
        containerStackView.addArrangedSubview(leadingView)
        containerStackView.addArrangedSubview(middleStackView)
        containerStackView.addArrangedSubview(trailingSpacer)
        
        // Set flexible priorities for spacers to handle window resizing
        leadingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        trailingSpacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        
        buildAvatarView()
        buildMiddleStackView()
        buildBubbleStackView()
    }
    
    open func buildMiddleStackView() {
        middleStackView.addArrangedSubview(headerView)
        middleStackView.addArrangedSubview(bubbleStackView)
        middleStackView.addArrangedSubview(footerView)
        middleStackView.addArrangedSubview(viewReplyView)
    }
    
    open func buildBubbleStackView() {
        bubbleStackView.addArrangedSubview(replayView)
        bubbleStackView.addArrangedSubview(messageContentView)
        bubbleStackView.addArrangedSubview(statusInfoView)
        bubbleStackView.addArrangedSubview(bottomView)
        
        replayView.pin(anchors: [.leading, .trailing], to: bubbleStackView)
        statusInfoView.pin(anchors: [.leading, .trailing], to: bubbleStackView)
        bottomView.pin(anchors: [.leading, .trailing], to: bubbleStackView)
    }
    
    open func buildAvatarView() {
        avatarContainerView.pin(anchors: [.height, .width], to: 32)
        leadingView.addArrangedSubview(avatarContainerView)
    }
    
    public func set(bubbleAlignment: MessageBubbleAlignment) {
        self.alignment = bubbleAlignment
        
        switch alignment {
        case .left:
            containerStackView.distribution = .fill
            leadingSpacer.isHidden = true
            hide(avatar: false)
            trailingSpacer.isHidden = false
            middleStackView.alignment = .leading
            leadingView.isHidden = false
        case .right:
            containerStackView.distribution = .fill
            leadingSpacer.isHidden = false
            trailingSpacer.isHidden = true
            hide(avatar: true)
            middleStackView.alignment = .trailing
            leadingView.isHidden = false
        case .center:
            leadingView.isHidden = true
            hide(avatar: true)
            containerStackView.distribution = .equalCentering
            trailingSpacer.isHidden = true
            leadingSpacer.isHidden = true
            middleStackView.alignment = .center
        }
    }
    
    @discardableResult
    public func set(avatarURL url: String? = nil, avatarName name: String? = nil) -> Self {
        self.avatar.setAvatar(avatarUrl: url, with: name)
        return self
    }
    
    @discardableResult
    public func hide(avatar: Bool) -> Self {
        containerStackView.setCustomSpacing(avatar ? 0 : CometChatSpacing.Padding.p2, after: leadingView)
        self.avatarContainerView.isHidden = avatar
        return self
    }
    
    @discardableResult
    public func hide(headerView: Bool) -> Self {
        self.middleStackView.setCustomSpacing(0, after: self.headerView)
        self.headerView.isHidden = headerView
        return self
    }
    
    @discardableResult
    public func onLongPressGestureRecognised(gesture: @escaping (() -> Void)) -> Self {
        self.onLongPressGestureRecognized = gesture
        return self
    }
    
    @discardableResult
    public func hide(footerView: Bool) -> Self {
        self.footerView.isHidden = footerView
        return self
    }
    
    @discardableResult
    public func set(actionSheetStyle:ActionSheetStyle) -> Self{
        self.actionSheetStyle = actionSheetStyle
        return self
    }
    
    @discardableResult
    public func set(bubbleView: UIView?) -> Self {
        if let bubbleView = bubbleView{
            self.customBubbleView?.subviews.forEach({$0.removeFromSuperview()})
            self.leadingView.subviews.forEach({$0.removeFromSuperview()})
            self.middleStackView.subviews.forEach({$0.removeFromSuperview()})
            self.bubbleStackView.subviews.forEach({$0.removeFromSuperview()})
            self.customBubbleView = bubbleView
            self.containerStackView.embed(bubbleView)
        }
        return self
    }
    
    @discardableResult
    public func set(headerView: UIView) -> Self {
        self.headerView.embed(headerView, insets: .init(top: 0, leading: 0, bottom: CometChatSpacing.Padding.p1, trailing: 0))
        return self
    }
    
    @discardableResult
    public func set(footerView: UIView) -> Self {
        self.footerView.embed(footerView)
        return self
    }
    
    @discardableResult
    public func set(contentView: UIView) -> Self {
        self.messageContentView.embed(contentView)
        return self
    }
    
    @discardableResult
    public func set(bottomView: UIView?) -> Self {
        self.bottomView.subviews.forEach { $0.removeFromSuperview() }
        if let bottomView = bottomView{
            self.bottomView.embed(bottomView)
        }
        return self
    }
    
    @discardableResult
    public func set(statusInfoView: UIView) -> Self {
        self.statusInfoView.embed(statusInfoView)
        return self
    }
    
    @discardableResult
    public func set(viewReply: UIView) -> Self {
        self.viewReplyView.embed(viewReply)
        return self
    }
    
    @discardableResult
    public func set(replyView view: UIView?) -> Self {
        // Remove any previous reply subviews
        replayView.subviews.forEach { $0.removeFromSuperview() }

        self.messagePreview = view
        
        guard let view = messagePreview else {
            replayView.isHidden = true
            // Reset background to clear when no reply
            if let customMsg = baseMessage as? CustomMessage, customMsg.type == "extension_sticker" {
                set(backgroundColor: .clear)
            }
            return self
        }

        replayView.isHidden = false
        view.withoutAutoresizingMaskConstraints()
        replayView.addSubview(view)
        view.leadingAnchor.constraint(equalTo: replayView.leadingAnchor, constant: 4).isActive = true
        view.trailingAnchor.constraint(equalTo: replayView.trailingAnchor, constant: -4).isActive = true
        view.topAnchor.constraint(equalTo: replayView.topAnchor, constant: 4).isActive = true
        view.bottomAnchor.constraint(equalTo: replayView.bottomAnchor, constant: -4).isActive = true
        
        // Set background color for sticker messages with reply
        if baseMessage?.messageType == .custom, let customMsg = baseMessage as? CustomMessage, customMsg.type == "extension_sticker" {
            let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: baseMessage?.senderUid)
            if !isLoggedInUser {
                // Incoming sticker with reply - use neutral color
                set(backgroundColor: CometChatTheme.neutralColor300)
            }
        }
        return self
    }

    // Helper for preview text extraction
    private func previewText(for message: BaseMessage) -> String {
        if let txt = message as? TextMessage { return txt.text }
        if let media = message as? MediaMessage {
            switch media.messageType {
            case .image: return "Image"
            case .video: return "Video"
            case .audio: return "Audio"
            case .file:  return media.attachment?.fileName ?? "File"
            default: return "Media"
            }
        }
        if let action = message as? ActionMessage { return action.message ?? "Action" }
        return "Message"
    }

    
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupAppearance() {
        //TODO: setupAppearance
    }

    func set(backgroundColor: UIColor) {
        bubbleStackView.backgroundColor = backgroundColor
    }
    
    func set(cornerRadius: CometChatCornerStyle) {
        bubbleStackView.roundViewCorners(corner: cornerRadius)
    }
    
    func set(borderWidth: CGFloat) {
        bubbleStackView.borderWith(width: borderWidth)
    }
    
    func set(borderColor: UIColor) {
        bubbleStackView.borderColor(color: borderColor)
    }
    
    func set(message: BaseMessage) {
        self.baseMessage = message
    }
    
    func set(style: MessageBubbleStyle = MessageBubbleStyle(), specificMessageTypeStyle: BaseMessageBubbleStyle? = nil) {
        
        var style = style
        avatar.style = specificMessageTypeStyle?.avatarStyle ?? style.avatarStyle
        set(borderColor: specificMessageTypeStyle?.borderColor ?? style.borderColor)
        set(borderWidth: specificMessageTypeStyle?.borderWidth ?? style.borderWidth)
        set(backgroundColor:  specificMessageTypeStyle?.backgroundColor ?? style.backgroundColor)
        set(cornerRadius: specificMessageTypeStyle?.cornerRadius ?? style.cornerRadius)

    }
    
    func set(actionStyle: GroupActionBubbleStyle = GroupActionBubbleStyle()) {
        
        set(borderColor: actionStyle.borderColor)
        set(borderWidth: actionStyle.borderWidth)
        set(backgroundColor:  actionStyle.backgroundColor)
        set(cornerRadius: actionStyle.cornerRadius ?? .init(cornerRadius: 11))

    }
    
    func set(callActionStyle: CallActionBubbleStyle = CallActionBubbleStyle()) {
        set(borderColor: callActionStyle.borderColor)
        set(borderWidth: callActionStyle.borderWidth)
        set(backgroundColor:  callActionStyle.backgroundColor)
        set(cornerRadius: callActionStyle.cornerRadius ?? .init(cornerRadius: 16))
    }

    public override func prepareForReuse() {
        super.prepareForReuse()
        
        messagePreview = nil
        replayView.isHidden = true
        
        contentView.subviews
                .filter { $0.tag == 9999 }
                .forEach { $0.removeFromSuperview() }
        
        self.headerView.subviews.forEach({ $0.removeFromSuperview() })
        self.footerView.subviews.forEach({ $0.removeFromSuperview() })
        self.viewReplyView.subviews.forEach({ $0.removeFromSuperview() })
        self.replayView.subviews.forEach({ $0.removeFromSuperview() })
        self.statusInfoView.subviews.forEach({ $0.removeFromSuperview() })
        self.bottomView.subviews.forEach({ $0.removeFromSuperview() }) // Clear moderation view on reuse
        self.bubbleStackView.setCustomSpacing(0, after: messageContentView) //reseting spacing for x statusInfoView
        self.messageContentView.subviews.forEach({ $0.removeFromSuperview() })
        self.avatar.layer.sublayers?.forEach({ $0.removeFromSuperlayer() })
        self.avatar.image = nil
        self.baseMessage = nil
    }
    
    open override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool{
        return true
    }
    
    // MARK: - Swipe to Reply Support
    private var swipeGesture: UISwipeGestureRecognizer?
    private var onSwipeReply: ((_ message: BaseMessage?) -> Void)?

    
    // Call this after bubble alignment is set
    func setupSwipeGestures(message: BaseMessage) {
        // Remove old gesture if any
        
        // Always remove previous gesture recognizers first
        if let existing = swipeGesture {
            bubbleStackView.removeGestureRecognizer(existing)
            swipeGesture = nil
        }
        
        if message.messageCategory == .action {
            return
        }
        
        if disableSwipeToReply { return }
        
        if MessageUtils.isMessageModerationDisapproved(message: message) { return }
        
        // Disable swipe to reply for error messages (including RBAC errors)
        if message.metaData?["error"] as? Bool == true { return }
        
        if message.id <= 0 {
            return
        }
        
        if let existing = swipeGesture {
            bubbleStackView.removeGestureRecognizer(existing)
        }

        // Decide direction based on alignment
        let direction: UISwipeGestureRecognizer.Direction = .right
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeReply(_:)))
        swipe.direction = direction
        bubbleStackView.addGestureRecognizer(swipe)
        swipeGesture = swipe
    }
    
    @objc private func handleSwipeReply(_ gesture: UISwipeGestureRecognizer) {
        guard gesture.state == .ended else { return }
        // Animate slight movement for visual feedback
        UIView.animate(withDuration: 0.15,
                       animations: {
                           self.bubbleStackView.transform = CGAffineTransform(translationX: gesture.direction == .right ? 15 : -15, y: 0)
                       },
                       completion: { _ in
                           UIView.animate(withDuration: 0.15) {
                               self.bubbleStackView.transform = .identity
                           }
                       })
        // Trigger callback
        onSwipeReply?(baseMessage)
    }

    @discardableResult
    public func onSwipeReplyDetected(_ handler: @escaping (_ message: BaseMessage?) -> Void) -> Self {
        self.onSwipeReply = handler
        return self
    }


}
