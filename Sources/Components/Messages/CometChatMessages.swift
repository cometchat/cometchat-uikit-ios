//
//  CometChatMessages.swift
//  Created by Pushpsen Airekar on 25/11/21.
//

import UIKit
import CometChatSDK


public class CometChatMessages: UIViewController {
    
    @IBOutlet weak var liveReactions: CometChatLiveReaction!
    @IBOutlet weak var container: UIStackView!
    @IBOutlet weak var messageHeader: CometChatMessageHeader!
    @IBOutlet weak var messageList: CometChatMessageList!
    @IBOutlet weak var messageComposer: CometChatMessageComposer!
    @IBOutlet weak var messageComposerBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var messageComposerHeight: NSLayoutConstraint!
    
    private(set) var composerId: [String:Any]?
    private(set) var user: User?
    private(set) var group: Group?
    private(set) var hideTypingIndicator: Bool = false
    private(set) var disableTyping: Bool = false
    private(set) var messagesStyle: MessagesStyle = MessagesStyle()
    private(set) var hideMessageHeader: Bool = false
    private(set) var hideMessageList: Bool = false
    private(set) var hideMessageComposer: Bool = false
    private(set) var messageHeaderView: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var messageListView: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var messageComposerView: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var auxiliaryMenu: ((_ user: User?, _ group: Group?, _ id: [String: Any]?) -> UIStackView)?
    private(set) var messageHeaderConfiguration: MessageHeaderConfiguration?
    private(set) var messageListConfiguration: MessageListConfiguration?
    private(set) var messageComposerConfiguration: MessageComposerConfiguration?
    private(set) var detailsConfiguration: DetailsConfiguration?
    private(set) var threadedMessageConfiguration: ThreadedMessageConfiguration?
    private(set) var disableSoundForMessages: Bool = false
    private(set) var customSoundForIncomingMessages: URL?
    private(set) var customSoundForOutgoingMessages: URL?
    private(set) var isAnimating = false
    private(set) var hideDetails = false
    private(set) var id = [String:Any]()
    private(set) var liveReactionImage: UIImage = UIImage(named: "message-composer-heart.png", in: CometChatUIKit.bundle, with: nil) ?? UIImage()
    
    public override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
        }
    }
    
    public override func viewDidLoad() {
        setupMessageList()
    }
    public override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        messageList.disconnect()
        removeObserverForMessageEvents()
        addObserForMessageEvents()
        addObservers()
        setupKeyboard()
        
        if let user  = user {
            id["uid"] = user.uid
        }
        if let group  = group {
            id["guid"] = group.guid
        }
        setupMessageHeader()
        setupMessageComposer()
        set(messagesStyle: messagesStyle)
        messageHeader.infoCallBack = { [weak self] in
            guard let this = self else { return }
            if let user = this.user {
                this.onViewInformation(user: user)
            }
            if let group = this.group {
                this.onViewInformation(group: group)
            }
        }
    }
    
    
    public override func viewWillDisappear(_ animated: Bool) {
        removeObervers()
        //TODO: Need
        // messageComposer.removeContainerStaView()
    }
    
    deinit {
        print("Calling Denit")
    }
    
    
    public override func viewDidAppear(_ animated: Bool) {
        
        messageList.setOnThreadRepliesClick { [weak self] message, messageBubbleView in
            guard let this = self else { return }
            DispatchQueue.main.async {
                let threadedMessages = CometChatThreadedMessages()
                if let user = this.user {
                    threadedMessages.set(user: user)
                }
                if let group = this.group {
                    threadedMessages.set(group: group)
                }
                if let message = message {
                    threadedMessages.set(parentMessage: message)
                }
                if let view = messageBubbleView {
                    threadedMessages.set(parentMessageView: view)
                }
                if let threadedMessageConfiguration = this.threadedMessageConfiguration {
                    
                    if let messageListConfiguration = threadedMessageConfiguration.messageListConfiguration {
                        threadedMessages.set(messageListConfiguration: messageListConfiguration)
                    }
                    
                    if let messageActionView = threadedMessageConfiguration.messageActionView {
                        threadedMessages.setCustomMessageActionView(customMessageActionView: messageActionView)
                    }
                    
                    if let messageComposerConfiguration = threadedMessageConfiguration.messageComposerConfiguration {
                        threadedMessages.set(messageComposerConfiguration: messageComposerConfiguration)
                    }
                    
                    if let backIcon = threadedMessageConfiguration.backIcon {
                        threadedMessages.set(backButtonIcon: backIcon)
                    }
                }
                let navigationController = UINavigationController(rootViewController: threadedMessages)
                this.present(navigationController, animated: true)
            }
        }
    }
    
    @discardableResult
    private func set(background: UIColor) -> Self {
        self.view.backgroundColor = background
        return self
    }
    
    @discardableResult
    private func set(corner: CometChatCornerStyle) -> Self {
        view.roundViewCorners(corner: corner)
        return self
    }
    
    @discardableResult
    private func set(borderWidth: CGFloat) -> Self {
        view.borderWith(width: borderWidth)
        return self
    }
    
    @discardableResult
    private func set(borderColor: UIColor) -> Self {
        view.borderColor(color: borderColor)
        return self
    }
    
    private func addObserForMessageEvents() {
        CometChatMessageEvents.addListener("messages-message-listener", self as CometChatMessageEventListener)
    }
    
    private func removeObserverForMessageEvents() {
        CometChatMessageEvents.removeListener("messages-message-listener")
    }
    
    private func addObservers() {
        CometChatUserEvents.addListener("users-with-messages", self as CometChatUserEventListener)
        messageHeader.connect()
        messageList.connect()
        messageComposer.connect()
        CometChatMessageOption.messageOptionDelegate = self
        CometChat.addGroupListener("messages-groups-sdk-listener", self)
        CometChatGroupEvents.addListener("messages-groups-event-listener", self)
        CometChatUIEvents.addListener("messages-ui-event-listener", self)
    }
    
    private func removeObervers() {
        messageHeader.disconnect()
        messageComposer.disconnect()
        CometChatGroupEvents.removeListener("messages-group-listener")
        CometChat.removeGroupListener("messages-groups-sdk-listener")
        CometChatGroupEvents.removeListener("messages-groups-event-listener")
    }
    
    private func setupMessageHeader() {
        self.navigationController?.navigationBar.isHidden = true
        if let messageHeaderConfiguration = messageHeaderConfiguration {
            messageHeader.set(subtitle: messageHeaderConfiguration.subtitleView)
            if let backButtonIcon = messageHeaderConfiguration.backButtonIcon {
                messageHeader.set(backIcon: backButtonIcon)
            }
            if let privateGroupIcon = messageHeaderConfiguration.privateGroupIcon {
                messageHeader.set(privateGroupIcon: privateGroupIcon)
            }
            if let protectedGroupIcon = messageHeaderConfiguration.protectedGroupIcon {
                messageHeader.set(protectedGroupIcon: protectedGroupIcon)
            }
            if let messageHeaderStyle = messageHeaderConfiguration.messageHeaderStyle {
                messageHeader.set(messageHeaderStyle: messageHeaderStyle)
            }
            messageHeader.hide(backButton: messageHeaderConfiguration.hideBackIcon)
            messageHeader.disable(userPresence: messageHeaderConfiguration.disableUsersPresence)
            messageHeader.disable(typing: messageHeaderConfiguration.disableTyping)
        }
        
        if let menu = messageHeaderConfiguration?.menus {
            messageHeader.setMenus(menu: menu)
        } else  {
            messageHeader.setMenus { user, group in
                if let auxiliaryMenu = self.auxiliaryMenu?(user, group, self.id) {
                    auxiliaryMenu.spacing = 3
                    if !self.hideDetails {
                        auxiliaryMenu.addArrangedSubview(self.configureHeaderMenu())
                    }
                    return auxiliaryMenu
                }
                
                if let headerMenus = ChatConfigurator.getDataSource().getAuxiliaryHeaderMenu(user: user, group: group, controller: self, id: self.id) {
                    headerMenus.spacing = 3
                    if !self.hideDetails {
                        headerMenus.addArrangedSubview(self.configureHeaderMenu())
                    }
                    return headerMenus
                }
                
                let stackView = UIStackView(arrangedSubviews: [UIView(), self.configureHeaderMenu()])
                stackView.translatesAutoresizingMaskIntoConstraints = false
                stackView.heightAnchor.constraint(equalToConstant: 75).isActive = true
                return stackView
            }
        }
        
        if let user = user {
            if let messageHeaderView = messageHeaderView?(user, nil) {
                messageHeader.set(customMessageHeader: messageHeaderView)
            }
            messageHeader.set(user: user)
        }else if let group = group {
            if let messageHeaderView = messageHeaderView?(nil, group) {
                messageHeader.set(customMessageHeader: messageHeaderView)
            }
            messageHeader.set(group: group)
        }
        messageHeader.set(controller: self)
    }
    
    private func setupMessageList() {
        var types = [String]()
        var categories = [String]()
        var templates = [(type: String, template: CometChatMessageTemplate)]()
        
        if let messageListConfiguration = messageListConfiguration, let messageTypes = messageListConfiguration.templates {
            
            for template in messageTypes {
                if !(categories.contains(template.category)) {
                    categories.append(template.category)
                }
                if !(types.contains(template.type)) {
                    types.append(template.type)
                }
                templates.append((type: template.type, template: template))
            }
            messageList.set(templates: templates)
            
        } else {
            let messageTypes =  ChatConfigurator.getDataSource().getAllMessageTemplates()
            for template in messageTypes {
                if !(categories.contains(template.category)) {
                    categories.append(template.category)
                }
                if !(types.contains(template.type)) {
                    types.append(template.type)
                }
                templates.append((type: template.type, template: template))
            }
            
            messageList.set(templates: templates)
        }
        
        set(messageList: messageList, messageListConfiguration: messageListConfiguration)
        if let user = user {
            if let messageListConfiguration = messageListConfiguration, let requestBuilder = messageListConfiguration.messagesRequestBuilder {
                messageList.set(messagesRequestBuilder: requestBuilder)
            } else {
                let messagesRequestBuilder = MessagesRequest.MessageRequestBuilder().set(uid: user.uid ?? "").set(limit: 30).set(types: types).set(categories: categories).hideDeletedMessages(hide: messageList.hideDeletedMessages).hideReplies(hide: true)
                messageList.set(messagesRequestBuilder: messagesRequestBuilder)
            }
            messageList.set(user: user)
        } else if let group = group {
            if let messageListConfiguration = messageListConfiguration, let requestBuilder = messageListConfiguration.messagesRequestBuilder {
                messageList.set(messagesRequestBuilder: requestBuilder)
            } else {
                
                let messagesRequestBuilder = MessagesRequest.MessageRequestBuilder().set(guid: group.guid).set(limit: 30).set(types: types).set(categories: categories).hideDeletedMessages(hide: messageList.hideDeletedMessages).hideReplies(hide: true)
                messageList.set(messagesRequestBuilder: messagesRequestBuilder)
            }
            messageList.set(group: group)
        }
        
        container.addSubview(messageList)
        messageList.set(controller: self)
        messageList.disable(soundForMessages: disableSoundForMessages)
        if let customSoundForIncomingMessages = customSoundForIncomingMessages {
            messageList.set(customSoundForMessages: customSoundForIncomingMessages)
        }
    }
    
    private func set(messageList: CometChatMessageList, messageListConfiguration: MessageListConfiguration?) {
        if let messageListConfiguration = messageListConfiguration {
            messageList.set(emptyStateView: messageListConfiguration.emptyStateView)
            messageList.set(errorStateView: messageListConfiguration.errorStateView)
            messageList.set(alignment: messageListConfiguration.alignment)
            messageList.set(timeAlignment: messageListConfiguration.timeAlignment)
            messageList.show(avatar: messageListConfiguration.showAvatar)
            messageList.setDatePattern(datePattern: messageListConfiguration.datePattern)
            messageList.setDateSeparatorPattern(dateSeparatorPattern: messageListConfiguration.dateSeparatorPattern)
            messageList.scrollToBottomOnNewMessages(messageListConfiguration.scrollToBottomOnNewMessages)
            messageList.setOnThreadRepliesClick(onThreadRepliesClick: messageListConfiguration.onThreadRepliesClick)
            messageList.disable(receipt: messageListConfiguration.disableReceipt)
            
            if let messageInformationConfiguration = messageListConfiguration.messageInformationConfiguration {
                messageList.set(messageInformationConfiguration: messageInformationConfiguration)
            }
            
            if let waitIcon = messageListConfiguration.waitIcon {
                messageList.set(waitIcon: waitIcon)
            }
            if let waitIcon = messageListConfiguration.waitIcon {
                messageList.set(waitIcon: waitIcon)
            }
            if let sentIcon = messageListConfiguration.sentIcon {
                messageList.set(sentIcon: sentIcon)
            }
            if let deliveredIcon = messageListConfiguration.deliveredIcon {
                messageList.set(deliveredIcon: deliveredIcon)
            }
            if let readIcon = messageListConfiguration.readIcon {
                messageList.set(readIcon: readIcon)
            }
            
            if let messageListStyle = messageListConfiguration.messageListStyle {
                messageList.set(messageListStyle: messageListStyle)
            }
            if let headerView = messageListConfiguration.headerView {
                messageList.set(headerView: headerView)
            }
            if let footerView = messageListConfiguration.footerView {
                messageList.set(footerView: footerView)
            }
        }
    }
    
    private func setupMessageComposer() {
        if hideMessageComposer {
            messageComposer.isHidden = true
        } else {
            messageComposer.set(controller: self)
            set(messageComposer: messageComposer, messageComposerConfiguration: messageComposerConfiguration)
            messageComposer.isHidden = false
            if let user = user {
                if let messageComposerView = messageComposerView?(user, nil) {
                    messageComposer.set(customComposer: messageComposerView)
                }
                messageComposer.set(user: user)
                
            } else if let group = group {
                if let messageComposerView = messageComposerView?(nil, group) {
                    messageComposer.set(customComposer: messageComposerView)
                }
                messageComposer.set(group: group)
            }
            if let auxillaryView = ChatConfigurator.getDataSource().getAuxiliaryOptions(user: user, group: group, controller: self, id: id) {
                messageComposer.setAuxilaryButtonView { user, group in
                    return auxillaryView
                }
            }
        }
    }
    
    private func set(messageComposer: CometChatMessageComposer, messageComposerConfiguration: MessageComposerConfiguration?) {
        if let messageComposerConfiguration = messageComposerConfiguration {
            if let text = messageComposerConfiguration.placeholderText {
                messageComposer.set(placeholderText: text)
            }
            if let headerView = messageComposerConfiguration.headerView {
                messageComposer.set(headerView: headerView)
            }
            if let footerView = messageComposerConfiguration.footerView {
                messageComposer.set(footerView: footerView )
            }
            if let maxLine = messageComposerConfiguration.maxLine {
                messageComposer.set(maxLine: maxLine)
            }
            if let messageComposerStyle = messageComposerConfiguration.messageComposerStyle {
                messageComposer.set(composerStyle: messageComposerStyle)
            }
            if let sendButtonView = messageComposerConfiguration.sendButtonView {
                messageComposer.setSendButtonView(sendButtonView: sendButtonView)
            }
            if let attachmentOptions = messageComposerConfiguration.attachmentOptions {
                messageComposer.setAttachmentOptions(attachmentOptions: attachmentOptions)
            }
            if let attachmentIcon = messageComposerConfiguration.attachmentIcon {
                messageComposer.set(attachmentIcon: attachmentIcon)
            }
            if let auxilaryButtonView = messageComposerConfiguration.auxilaryButtonView {
                messageComposer.setAuxilaryButtonView(auxilaryButtonView: auxilaryButtonView)
            }
            if let liveReactionIcon = messageComposerConfiguration.liveReactionIcon {
                messageComposer.set(liveReactionIcon: liveReactionIcon)
            }
            if let hideLiveReaction = messageComposerConfiguration.hideLiveReaction {
                messageComposer.hide(liveReaction: hideLiveReaction)
            }
            if let secondaryButtonView = messageComposerConfiguration.secondaryButtonView {
                messageComposer.setSecondaryButtonView(secondaryButtonView: secondaryButtonView)
            }
            if let auxiliaryButtonsAlignment = messageComposerConfiguration.auxiliaryButtonsAlignment {
                messageComposer.set(auxilaryButtonAignment: auxiliaryButtonsAlignment)
            }
            if let hideHeaderView = messageComposerConfiguration.hideHeaderView {
                messageComposer.hide(headerView: hideHeaderView)
            }
            if let hideFooterView = messageComposerConfiguration.hideFooterView {
                messageComposer.hide(footerView: hideFooterView)
            }
            if let onchange = messageComposerConfiguration.onChange {
                messageComposer.setOnChange(onChange: onchange)
            }
            if let onSendButtonClick = messageComposerConfiguration.onSendButtonClick {
                messageComposer.setOnSendButtonClick(onSendButtonClick: onSendButtonClick)
            }
        }
        messageComposer.disable(disableSoundForMessages: false)
        if let customSoundForOutgoingMessages = customSoundForOutgoingMessages {
            messageComposer.set(customSoundForMessage: customSoundForOutgoingMessages)
        }
    }
    
    
    private func setupKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        messageList?.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.endEditing(true)
        }
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if keyboardHeight > 0 {
                UIView.animate(withDuration: 0.2) {
                    self.messageComposerBottomSpace.constant = keyboardHeight
                    self.messageList.scrollToLastVisibleCell()
                    self.view.layoutIfNeeded()
                }
                
            } else {
                UIView.animate(withDuration: 0.2) {
                    self.messageComposerBottomSpace.constant = 0.0
                    self.messageList.scrollToLastVisibleCell()
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    public func startLiveReaction(image: UIImage) {
        image.withRenderingMode(.alwaysOriginal)
        if self.isAnimating == false {
            self.liveReactions.image1 = image
            self.liveReactions.isHidden = false
            
            self.isAnimating = true
            
            Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
                self.liveReactions.sendReaction()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    timer.invalidate()
                    self.liveReactions.stopReaction()
                })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.isAnimating = false
            })
            
            if !self.liveReactions.isAnimating {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    self.liveReactions.isHidden = true
                })
            }
        }
    }
    
    private func update(user: User) {
        guard let user = self.user else { print("user not found."); return }
        self.user = user
    }
    
    private func configureHeaderMenu() -> UIStackView {
        let style = ButtonStyle()
        style.set(iconBackground: .clear)
            .set(iconTint: CometChatTheme.palatte.primary)
        
        let detailButton = CometChatButton(width: 40, height: 40)
        let infoIcon: UIImage = UIImage(named: "messages-info.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        detailButton.set(icon: infoIcon)
        detailButton.set(style: style)
        detailButton.set(controller: self)
        detailButton.setOnClick {
            if let user = self.user {
                CometChatMessageEvents.emitOnViewInformation(user: user)
            }
            if let group = self.group {
                CometChatMessageEvents.emitOnViewInformation(group: group)
            }
        }
        
        return detailButton
    }
    
}

extension CometChatMessages {
    
    @discardableResult
    @objc public func hide(details: Bool) -> Self {
        self.hideDetails = details
        return self
    }
    
    @discardableResult
    public func setAuxiliaryMenu(auxiliaryMenu: ((_ user: User?, _ group: Group?, _ id: [String: Any]?) -> UIStackView)?) -> Self {
        self.auxiliaryMenu = auxiliaryMenu
        return self
    }
    
    @discardableResult
    @objc public func set(user: User) -> Self {
        self.user = user
        return self
    }
    
    @discardableResult
    @objc public func set(group: Group) -> Self {
        self.group = group
        return self
    }
    
    @discardableResult
    public func disable(disableTyping: Bool)  ->  Self {
        self.disableTyping = disableTyping
        return self
    }
    
    @discardableResult
    public func hide(typingIndicator: Bool)  ->  Self {
        self.hideTypingIndicator = typingIndicator
        return self
    }
    
    @discardableResult
    public func set(messagesStyle: MessagesStyle) -> Self {
        self.messagesStyle = messagesStyle
        set(background: messagesStyle.background)
        set(corner: messagesStyle.cornerRadius)
        set(borderWidth: messagesStyle.borderWidth)
        set(borderColor: messagesStyle.borderColor)
        return self
    }
    
    @discardableResult
    public func hide(messageHeader: Bool)  ->  Self {
        self.hideMessageHeader = messageHeader
        return self
    }
    
    @discardableResult
    public func hide(messageList: Bool)  ->  Self {
        self.hideMessageList = messageList
        return self
    }
    
    @discardableResult
    public func hide(messageComposer: Bool)  ->  Self {
        self.hideMessageComposer = messageComposer
        return self
    }
    
    @discardableResult
    public func setMessageHeaderView(messageHeaderView: ((_ user: User?, _ group: Group?) -> UIView)?)  ->  Self {
        self.messageHeaderView = messageHeaderView
        return self
    }
    
    @discardableResult
    public func setMessageListView(messageListView: ((_ user: User?, _ group: Group?) -> UIView)?)  ->  Self {
        self.messageListView = messageListView
        return self
    }
    
    @discardableResult
    public func setMessageComposerView(messageComposerView: ((_ user: User?, _ group: Group?) -> UIView)?)  ->  Self {
        self.messageComposerView = messageComposerView
        return self
    }
    
    @discardableResult
    public func set(messagesConfiguration: MessagesConfiguration)  ->  Self {
        set(messageHeaderConfiguration: messagesConfiguration.messageHeaderConfiguration)
        set(messageListConfiguration: messagesConfiguration.messageListConfiguration)
        set(messageComposerConfiguration: messagesConfiguration.messageComposerConfiguration)
        set(detailsConfiguration: messagesConfiguration.detailsConfiguration)
        return self
    }
    
    @discardableResult
    public func set(messageHeaderConfiguration: MessageHeaderConfiguration?)  ->  Self {
        self.messageHeaderConfiguration = messageHeaderConfiguration
        return self
    }
    
    @discardableResult
    public func set(messageListConfiguration: MessageListConfiguration?)  ->  Self {
        self.messageListConfiguration = messageListConfiguration
        return self
    }
    
    @discardableResult
    public func set(messageComposerConfiguration: MessageComposerConfiguration?)  ->  Self {
        self.messageComposerConfiguration = messageComposerConfiguration
        return self
    }
    
    @discardableResult
    public func set(detailsConfiguration: DetailsConfiguration?)  ->  Self {
        self.detailsConfiguration = detailsConfiguration
        return self
    }
    
    @discardableResult
    public func set(threadedMessageConfiguration: ThreadedMessageConfiguration) -> Self {
        self.threadedMessageConfiguration = threadedMessageConfiguration
        return self
    }
    
    @discardableResult
    public func disable(soundForMessages: Bool)  ->  Self {
        self.disableSoundForMessages = soundForMessages
        return self
    }
    
    @discardableResult
    public func set(customSoundForIncomingMessages: URL) -> Self {
        self.customSoundForIncomingMessages = customSoundForIncomingMessages
        return self
    }
    @discardableResult
    public func set(customSoundForOutgoingMessages: URL) -> Self {
        self.customSoundForOutgoingMessages = customSoundForOutgoingMessages
        return self
    }
}


extension CometChatMessages: CometChatMessageOptionDelegate {
    
    func onItemClick(messageOption: CometChatMessageOption, forMessage: BaseMessage?, indexPath: IndexPath?, view: UIView?) {
        if let message = forMessage {
            switch messageOption.id {
            case MessageOptionConstants.editMessage :
                if messageOption.onItemClick == nil {
                    messageComposer.preview(message: message, mode: .edit)
                    //  messageList.smartReplies.isHidden = true
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.deleteMessage :
                if messageOption.onItemClick == nil {
                    messageList.delete(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.shareMessage :
                if messageOption.onItemClick == nil {
                    didMessageSharePressed(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.copyMessage :
                if messageOption.onItemClick == nil {
                    didCopyPressed(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.replyMessage :
                if messageOption.onItemClick == nil {
                    messageComposer.preview(message: message, mode: .reply)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
                
            case MessageOptionConstants.messagePrivately :
                if messageOption.onItemClick == nil {
                    if let user = message.sender, let uid = user.uid {
                        CometChat.getUser(UID: uid) {
                            user in
                            DispatchQueue.main.async {
                                self.navigationController?.popViewController(animated: true)
                                CometChatUIEvents.emitOnOpenChat(user: user, group: nil)
                            }
                        } onError: {_ in}
                    }
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
                
            case MessageOptionConstants.translateMessage :
                if messageOption.onItemClick == nil {
                    if let indexPath = indexPath {
                        didMessageTranslatePressed(message: message, indexPath: indexPath)
                    }
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
                
            case MessageOptionConstants.forwardMessage: break
            case MessageOptionConstants.replyInThread : break
            case MessageOptionConstants.reactToMessage :
                if messageOption.onItemClick == nil {
                    didReactionPressed(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.messageInformation :
                if messageOption.onItemClick == nil {
                    messageList.didMessageInformationClicked(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            default:
                if let forMessage = forMessage {
                    messageOption.onItemClick?(forMessage)
                }
            }
        }
        updateViewConstraints()
    }
    
    private func didReactionPressed(message: BaseMessage?) {
//        let emojiKeyboard = CometChatEmojiKeyboard()
//        if let message = message {
//            emojiKeyboard.set(message: message)
//        }
//        self.presentPanModal(emojiKeyboard, backgroundColor: CometChatTheme.palatte.background)
    }
    
    private func didCopyPressed(message: BaseMessage?) {
        if let message = message as? TextMessage {
            UIPasteboard.general.string = message.text
        }
    }
    
    private func didMessageSharePressed(message: BaseMessage?) {
        if let message = message {
            if message.messageType == .text {
                
                let textToShare = (message as? TextMessage)?.text ?? ""
                copyMedia(textToShare)
                
            }else if message.messageType == .audio ||  message.messageType == .file ||  message.messageType == .image || message.messageType == .video {
                
                if let fileUrlString = (message as? MediaMessage)?.attachment?.fileUrl, let fileUrl = URL(string: fileUrlString) {
                    downloadMediaMessage(url: fileUrl, completion: {fileLocation in
                        if let fileLocation = fileLocation {
                            self.copyMedia(fileLocation)
                        }
                    })
                }
            }
        }
    }
    
    private func didMessageTranslatePressed(message: BaseMessage, indexPath: IndexPath) {
        // messageList.translate(message: message)
    }
    
    func downloadMediaMessage(url: URL, completion: @escaping (_ fileLocation: URL?) -> Void){
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent ?? "")
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(destinationUrl)
        } else {
            // CometChatSnackBoard.show(message: "Downloading...")
            URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                   // CometChatSnackBoard.hide()
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(destinationUrl)
                } catch let error as NSError {
                    completion(nil)
                }
            }).resume()
        }
    }
    
    func copyMedia(_ item: Any) {
        DispatchQueue.main.async {
            let activityViewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view
            activityViewController.excludedActivityTypes = [.airDrop]
            self.present(activityViewController, animated: true, completion: nil)
        }
    }
}

extension CometChatMessages: CometChatMessageEventListener {
    
    public func onParentMessageUpdate(message: CometChatSDK.BaseMessage) {
        self.messageList.update(message: message)
    }
    
    public func onMessageSent(message: BaseMessage, status: MessageStatus) {
        if message.parentMessageId == 0 {
            switch status {
            case .inProgress:
                self.messageList?.add(message: message)
                self.messageList?.scrollToBottom()
            case .success:
                self.messageList?.update(message: message)
            }
        }
    }
    
    public func onMessageEdit(message: BaseMessage, status:  MessageStatus) {
        self.messageList?.update(message: message)
    }
    
    public func onMessageDelete(message: BaseMessage) {
        if let messageList = messageList, messageList.hideDeletedMessages {
            self.messageList?.remove(message: message)
        } else {
            self.messageList?.update(message: message)
        }
    }
    
    public func onMessageReply(message: BaseMessage, status:  MessageStatus) {
        
    }
    
    public func onMessageRead(message: BaseMessage) {
        
    }
    
    public func onLiveReaction(reaction message: TransientMessage) {
        /*
         
         Performing live reaction for 1.5 seconds,
         if animation is on going, increase timer by 1.5 seconds.
         
         */
        startLiveReaction(image: liveReactionImage)
    }
    
    public func onMessageError(error: CometChatException) {
        
    }
    
    public func onVoiceCall(user: User) {
        
    }
    
    public func onVoiceCall(group: Group) {
        
    }
    
    public func onVideoCall(user: User) {
        
    }
    
    public func onVideoCall(group: Group) {
        
    }
    
    public func onViewInformation(user: User) {
        let userDetail = CometChatDetails()
        userDetail.set(user: user)
        if let detailsConfiguration = detailsConfiguration {
            set(details: userDetail, detailsConfiguration: detailsConfiguration)
        }
        let naviVC = UINavigationController(rootViewController: userDetail)
        self.present(naviVC, animated: true)
    }
    
    public func onViewInformation(group: Group) {
        let groupDetail = CometChatDetails()
        groupDetail.set(group: group)
        if let detailsConfiguration = detailsConfiguration {
            set(details: groupDetail, detailsConfiguration: detailsConfiguration)
        }
        let naviVC = UINavigationController(rootViewController: groupDetail)
        self.present(naviVC, animated: true)
    }
    
    // MARK:- Details configuration.
    private func set(details: CometChatDetails, detailsConfiguration: DetailsConfiguration?) {
        
        if let detailsConfiguration = detailsConfiguration {
            
            if let showCloseButton = detailsConfiguration.showCloseButton {
                details.show(closeButton: showCloseButton)
            }
            if let closeButtonIcon = detailsConfiguration.closeButtonIcon {
                details.set(closeButtonIcon: closeButtonIcon)
            }
            if let menus = detailsConfiguration.menus {
                details.set(menus:menus)
            }
            if let hide = detailsConfiguration.hideProfile {
                details.hide(profile: hide)
            }
            if let subTitleView = detailsConfiguration.subtitleView {
                details.set(subTitleView: subTitleView)
            }
            if let customProfileView = detailsConfiguration.customProfileView {
                details.set(customProfileView: customProfileView)
            }
            if let data = detailsConfiguration.data {
                details.setData(data: data)
            }
            if let disableUsersPresence = detailsConfiguration.disableUsersPresence {
                details.disable(userPreference: disableUsersPresence)
            }
            if let protectedGroupIcon = detailsConfiguration.protectedGroupIcon {
                details.set(protectedGroupIcon: protectedGroupIcon)
            }
            if let privateGroupIcon = detailsConfiguration.privateGroupIcon {
                details.set(privateGroupIcon: privateGroupIcon)
            }
            if let detailsStyle = detailsConfiguration.detailsStyle {
                details.set(detailsStyle: detailsStyle)
            }
            if let listItemStyle = detailsConfiguration.listItemStyle {
                details.set(listItemStyle: listItemStyle)
            }
            if let statusIndicatorStyle = detailsConfiguration.statusIndicatorStyle {
                details.set(statusIndicatorStyle: statusIndicatorStyle)
            }
            if let avatarStyle = detailsConfiguration.avatarStyle {
                details.set(avatarStyle: avatarStyle)
            }
            if let onError = detailsConfiguration.onError {
                details.setOnError(onError: onError)
            }
            if let onBack = detailsConfiguration.onBack {
                details.setOnBack(onBack: onBack)
            }
            
            if let addMembersConfiguration = detailsConfiguration.addMembersConfiguration {
                details.set(addMembersConfiguration: addMembersConfiguration)
            }
            
            if let bannedMembersConfiguration = detailsConfiguration.bannedMembersConfiguration {
                details.set(bannedMembersConfiguration: bannedMembersConfiguration)
            }
            
            if let groupMembersConfiguration = detailsConfiguration.groupMembersConfiguration {
                details.set(groupMemberConfiguration: groupMembersConfiguration)
            }
            
            if let transferOwnershipConfiguration = detailsConfiguration.transferOwnershipConfiguration {
                details.set(transferOwnershipConfiguration: transferOwnershipConfiguration)
            }
        }
    }
    
    public func onError(message: BaseMessage?, error: CometChatException) {
        if let message = message {
            self.messageList?.update(message: message)
        }
    }
    
    public func onMessageReact(message: BaseMessage, reaction: CometChatMessageReaction) {
        
    }
}

extension CometChatMessages: CometChatUserEventListener {
    
    public func onItemClick(user: CometChatSDK.User, index: IndexPath?) {
        
        print("CometChatMessages - event - onItemClick")
    }
    
    public func onItemLongClick(user: CometChatSDK.User, index: IndexPath?) {
        
        print("CometChatMessages - event - onItemClick")
    }
    
    public func onUserBlock(user: CometChatSDK.User) {
        // update the user
        update(user: user)
        // user.hasBlockedMe = true
        
        print("CometChatMessages - event - onItemClick")
    }
    
    public func onUserUnblock(user: CometChatSDK.User) {
        update(user: user)
        
        print("CometChatMessages - event - onItemClick")
    }
    
    public func onError(user: CometChatSDK.User?, error: CometChatSDK.CometChatException) {
        
        print("CometChatMessages - event - onItemClick")
    }
}


extension CometChatMessages: CometChatGroupEventListener {
    
    
    public func onItemClick(group: Group, index: IndexPath?) {
        
        print("CometChatMessages - Events - onItemClick")
    }
    
    public func onItemLongClick(group: Group, index: IndexPath?) {
        
        print("CometChatMessages - Events - onItemLongClick")
    }
    
    public func onCreateGroupClick() {
        
        print("CometChatMessages - Events - onCreateGroupClick")
    }
    
    public func onGroupCreate(group: Group) {
        
        print("CometChatMessages - Events - onGroupCreate")
    }
    
    public func onGroupDelete(group: Group) {
        DispatchQueue.main.async {
            if self.navigationController == nil {
                self.dismiss(animated: true, completion: nil)
            }else{
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.popViewController(animated: true)
            }
        }
        removeObervers()
    }
    
    public func onOwnershipChange(group: Group?, member: GroupMember?) {
        
        print("CometChatMessages - Events - onOwnershipChange")
    }
    
    public func onGroupMemberLeave(leftUser: User, leftGroup:  Group) {
        DispatchQueue.main.async {
            if self.navigationController == nil {
                self.dismiss(animated: true, completion: nil)
            }else{
                self.navigationController?.navigationBar.isHidden = false
                self.navigationController?.popViewController(animated: true)
            }
        }
        removeObervers()
        print("CometChatMessages - Events - onGroupMemberLeave")
    }
    
    public func onGroupMemberJoin(joinedUser: User, joinedGroup:  Group) {
        
        print("CometChatMessages - Events - onGroupMemberJoin")
    }
    
    public func onGroupMemberKick(kickedUser: User, kickedGroup: Group, kickedBy: User) {
        print("CometChatMessages - Events - onGroupMemberKick")
    }
    
    public func onGroupMemberAdd(group: Group, members: [GroupMember], addedBy: User) {
        
        messageHeader.set(group: group)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.messageHeader.reloadInputViews()
        }
        
        print("CometChatMessages - Events - onGroupMemberAdd")
    }
    
    public func onGroupMemberBan(bannedUser: User, bannedGroup: Group, bannedBy: User) {
        print("CometChatMessages - Events - onGroupMemberBan")
    }
    
    public func onGroupMemberUnban(unbannedUserUser: User, unbannedUserGroup: Group, unbannedBy: User) {
        /*
         Do Nothing.
         */
        print("CometChatMessages - Events - onGroupMemberUnban")
    }
    
    public func onGroupMemberChangeScope(updatedBy: User , updatedUser: User , scopeChangedTo: CometChat.MemberScope , scopeChangedFrom: CometChat.MemberScope, group: Group) {
        /*
         Do Nothing as per figma
         */
        print("CometChatMessages - Events - onGroupMemberChangeScope")
    }
    
    public func onError(group: Group?, error: CometChatException) {
        
        print("CometChatMessages - Events - onError")
    }
    
}

extension CometChatMessages: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        
        print("CometChatMessages - sdk - onGroupMemberJoined")
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        
        print("CometChatMessages - sdk - onGroupMemberLeft")
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        
        print("CometChatMessages - sdk - onGroupMemberKicked")
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        
        print("CometChatMessages - sdk - onGroupMemberBanned")
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        /*
         Do Nothing.
         */
        print("CometChatMessages - sdk - onGroupMemberUnbanned")
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        print("CometChatMessages - sdk - onGroupMemberScopeChanged")
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        
        print("CometChatMessages - sdk - onMemberAddedToGroup")
    }
}

extension CometChatMessages: CometChatUIEventListener {
    public func openChat(user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        
    }
    
    
    public func onActiveChatChanged(id: [String : Any]?, lastMessage: CometChatSDK.BaseMessage?, user: CometChatSDK.User?, group: CometChatSDK.Group?) {
        
    }
    
    public func showPanel(id: [String : Any]?, alignment: UIAlignment, view: UIView?) {
        if alignment == .composerBottom {
            dismissKeyboard()
        }
    }
    
    public func hidePanel(id: [String : Any]?, alignment: UIAlignment) {
        if alignment == .composerBottom {
            messageComposer.messageInput.textView.becomeFirstResponder()
        }
    }
}
