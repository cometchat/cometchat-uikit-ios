//
//  CometChatThreadedMessages.swift
 
//
//  Created by Pushpsen Airekar on 04/01/23.
//

import UIKit
import CometChatSDK

public class CometChatThreadedMessages: CometChatListBase {

    @IBOutlet weak var parentMessageView: UIStackView!
    @IBOutlet weak var messageListContainer: UIView!
    @IBOutlet weak var messageList: CometChatMessageList!
    @IBOutlet weak var messageComposer: CometChatMessageComposer!
    @IBOutlet weak var messageComposerBottomSpace: NSLayoutConstraint!
    @IBOutlet weak var messageComposerHeight: NSLayoutConstraint!
    @IBOutlet weak var messageActionView: UIView!
    
    private(set) var user: User?
    private(set) var group: Group?
    private(set) var parentMessage: BaseMessage?
    private(set) var bubbleView: UIView?
    private(set) var doneButton: UIBarButtonItem?
    private(set) var hideMessageComposer: Bool = false
    private(set) var messageListConfiguration: MessageListConfiguration?
    private(set) var messageComposerConfiguration: MessageComposerConfiguration?
    
    private(set) var customMessageActionView: ((_ message: BaseMessage) -> UIView)?
    
    private(set) var enableSoundForMessages: Bool = true
    private(set) var customIncomingMessageSound: URL?
    private(set) var customOutgoingMessageSound: URL?
    private(set) var customSoundForOutgoingMessages: URL?
    private(set) var singleNewMessageText: String = "ONE_REPLY".localize()
    private(set) var multipleNewMessageText: String = "REPLIES".localize()
    private(set) var count: Int = 0
    var getCount: Int {
        get {
            return count
        }
    }
    
    @discardableResult public func set(messageListConfiguration: MessageListConfiguration) -> Self {
        self.messageListConfiguration = messageListConfiguration
        return self
    }
    
    @discardableResult public func set(messageComposerConfiguration: MessageComposerConfiguration) -> Self {
        self.messageComposerConfiguration = messageComposerConfiguration
        return self
    }
    
    @discardableResult public func setCustomMessageActionView(customMessageActionView: @escaping ((_ message: BaseMessage) -> UIView)) -> Self {
        self.customMessageActionView = customMessageActionView
        return self
    }
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupMessageBubbleView()
    }
    
    func setupMessageBubbleView() {
        if let bubbleView = bubbleView as? CometChatMessageBubble {
            bubbleView.headerView.isHidden = true
            bubbleView.footerView.isHidden = true
            bubbleView.avatarContainerView.isHidden = true
            bubbleView.viewReplies.isHidden = true
            if (parentMessage?.senderUid == CometChat.getLoggedInUser()?.uid)  && (parentMessage?.messageType == .text) {
                bubbleView.background.backgroundColor =  CometChatTheme.palatte.primary
            } else {
                bubbleView.background.backgroundColor = (self.traitCollection.userInterfaceStyle == .dark) ? CometChatTheme.palatte.accent100 :  CometChatTheme.palatte.secondary
            }
            let scrollView = UIScrollView()
            scrollView.addSubview(bubbleView.contentView)
            NSLayoutConstraint.activate([
                bubbleView.contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
                bubbleView.contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 24),
                bubbleView.contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
                bubbleView.contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
                bubbleView.contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
            ])
            scrollView.translatesAutoresizingMaskIntoConstraints = false
            parentMessageView.addArrangedSubview(scrollView)
            parentMessageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
            scrollView.showsHorizontalScrollIndicator = false
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: parentMessageView.topAnchor),
                scrollView.leadingAnchor.constraint(equalTo: parentMessageView.leadingAnchor, constant: 24),
                scrollView.trailingAnchor.constraint(equalTo: parentMessageView.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: parentMessageView.bottomAnchor),
                scrollView.widthAnchor.constraint(equalTo: parentMessageView.widthAnchor, constant: 100)
            ])
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        setupKeyboard()
    }
    
    public override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
            addObservers()
            setupAppearance()
            setupMessageList()
            setupMessageComposer()
            
            if let message = parentMessage, let messageActionView = customMessageActionView?(message) {
                self.messageActionView.addSubview(messageActionView)
            } else {
                setupMessageActionView()
            }
        }
    }
    
    func setupMessageActionView() {
        var replyText = ""
        if parentMessage?.replyCount == 0 {
            replyText = "NO_REPLIES".localize()
        }else if parentMessage?.replyCount == 1 {
            replyText = "ONE_REPLY".localize()
        } else {
            replyText = String(parentMessage?.replyCount ?? 0) + "REPLIES".localize()
        }
        // To be added later
        //        let moreButton = UIButton()
        //        moreButton.setImage(UIImage(systemName: "ellipsis.circle"), for: .normal)
        //        moreButton.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        //        moreButton.tintColor = CometChatTheme.palatte.primary
        let style = ActionItemStyle()
        style.set(titleFont: CometChatTheme.typography.text1).set(titleColor: CometChatTheme.palatte.accent600)
        let actionItem = ActionItem(id: "reply-view", text: replyText, leadingIcon: nil, trailingView: nil, style: style)
        let actionItemView =  Bundle.module.loadNibNamed(CometChatActionItem.identifier, owner: self, options: nil)![0]  as! CometChatActionItem
        actionItemView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        actionItemView.frame = messageActionView.bounds
        actionItemView.set(background: CometChatTheme.palatte.background)
        actionItemView.set(actionItem: actionItem)
        messageActionView.addSubview(actionItemView)
        set(count: parentMessage?.replyCount ?? 0)
    }
    
    private func addObservers() {
        CometChatMessageOption.messageOptionDelegate = self
        CometChat.addMessageListener("threaded-messages-message-listener", self)
        CometChatMessageEvents.addListener("threaded-messages-message-listener", self as CometChatMessageEventListener)
    }
    
    private func removeObervers() {
        CometChat.removeMessageListener("threaded-messages-message-listener")
        CometChatGroupEvents.removeListener("threaded-messages-group-listener")
        CometChatMessageEvents.removeListener("threaded-messages-message-listener")
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
        if let user = user, let uid = user.uid , let parentMessage = parentMessage {
            if let messageListConfiguration = messageListConfiguration, let requestBuilder = messageListConfiguration.messagesRequestBuilder {
                messageList.set(messagesRequestBuilder: requestBuilder.set(types: types).set(categories: categories))
            } else {
                let messagesRequestBuilder = MessagesRequest.MessageRequestBuilder().set(uid: uid).hideReplies(hide: true).setParentMessageId(parentMessageId: parentMessage.id).set(limit: 30).set(categories: categories).set(types: types)
                messageList.set(messagesRequestBuilder: messagesRequestBuilder)
            }
            messageList.set(user: user, parentMessage: parentMessage)
        }
        
        if let group = group,  let parentMessage = parentMessage {
            if let messageListConfiguration = messageListConfiguration, let requestBuilder = messageListConfiguration.messagesRequestBuilder {
                messageList.set(messagesRequestBuilder: requestBuilder.set(types: types).set(categories: categories))
            } else {
                let messagesRequestBuilder = MessagesRequest.MessageRequestBuilder().set(guid: group.guid).hideReplies(hide: true).setParentMessageId(parentMessageId: parentMessage.id).set(limit: 30).set(categories: categories).set(types: types)
                messageList.set(messagesRequestBuilder: messagesRequestBuilder)
            }
           
            messageList.set(group: group, parentMessage: parentMessage)
        }
        
        if let messageList = messageList {
            messageList.set(controller: self)
            messageList.disable(soundForMessages: !enableSoundForMessages)
            if let customIncomingMessageSound = customIncomingMessageSound {
                messageList.set(customSoundForMessages: customIncomingMessageSound)
            }
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
        if let user = user {
            messageComposer.set(user: user)
        }else if let group = group {
            messageComposer.set(group: group)
        }
        if let parentMessageId = parentMessage?.id {
            messageComposer.set(parentMessageId: parentMessageId)
        }
        messageComposer.set(controller: self)
        messageComposer.hide(liveReaction: true)
        if let messageComposerConfiguration = messageComposerConfiguration {
            set(messageComposer: messageComposer, messageComposerConfiguration: messageComposerConfiguration)
        }
        messageComposer.disable(disableSoundForMessages: false)
        if let customMessageSound = customOutgoingMessageSound {
            messageComposer.set(customSoundForMessage: customMessageSound)
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
        }
        messageComposer.disable(disableSoundForMessages: false)
        if let customSoundForOutgoingMessages = customSoundForOutgoingMessages {
            messageComposer.set(customSoundForMessage: customSoundForOutgoingMessages)
        }
    }
    
    private func setupKeyboard(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        messageList?.addGestureRecognizer(tapGesture)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if keyboardHeight > 0 {
                
                UIView.animate(withDuration: 0.02, delay: 0.0, options: .transitionCrossDissolve, animations: { () -> Void in
                    self.messageComposerBottomSpace.constant = keyboardHeight
                    self.messageList.scrollToLastVisibleCell()
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    
                })
                
            } else {
                
                UIView.animate(withDuration: 0.02, delay: 0.0, options: .transitionCrossDissolve, animations: { () -> Void in
                    self.messageComposerBottomSpace.constant = 0.0
                    self.messageList.scrollToLastVisibleCell()
                    self.view.layoutIfNeeded()
                }, completion: { _ in
                    
                })
               
            }
        }
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    private func setupAppearance() {
        self.view.backgroundColor = CometChatTheme.palatte.background
        set(title: "THREAD".localize(), mode: .never)
        hide(doneButton: false)
    }
    
    @discardableResult
    public func hide(doneButton: Bool) ->  Self {
        if !doneButton {
            self.doneButton = UIBarButtonItem(title: "DONE".localize(), style: .done, target: self, action: #selector(self.didClose))
            set(doneButtonFont: CometChatTheme.typography.title2)
            set(doneButtonTint: CometChatTheme.palatte.primary)
            self.navigationItem.rightBarButtonItem = self.doneButton
        }
        return self
    }
    
    @discardableResult
    public func set(doneButtonTint: UIColor) ->  Self {
        doneButton?.tintColor = doneButtonTint
        return self
    }
    
    @discardableResult
    public func set(doneButtonFont: UIFont) ->  Self {
        self.doneButton?.setTitleTextAttributes([NSAttributedString.Key.font: doneButtonFont], for: .normal)
        return self
    }
    
    @discardableResult
    public func set(user: User) ->  Self {
        self.user = user
        return self
    }
    
    @discardableResult
    public func set(group: Group) ->  Self {
        self.group = group
        return self
    }
    
    @discardableResult
    public func set(parentMessage: BaseMessage) ->  Self {
        self.parentMessage = parentMessage
        return self
    }
    
    @discardableResult
    public func set(parentMessageView: UIView?) ->  Self {
        if let parentMessageView = parentMessageView {
            self.bubbleView = parentMessageView
        }
        return self
    }
    
    @objc func didClose() {
        self.dismiss(animated: true)
    }
    
    @discardableResult
    public func set(count : Int) -> Self {
        if let actionItemView = messageActionView.subviews.first as? CometChatActionItem {
            self.count = count
            if count == 1 {
                actionItemView.name.text = singleNewMessageText
            }else if count > 1 && count < 999 {
                actionItemView.name.text = "\(count) " + multipleNewMessageText
            }else if count > 999 {
                actionItemView.name.text = "999+ " + multipleNewMessageText
            } else {
                actionItemView.name.text = "NO_REPLIES".localize()
            }
        }
        return self
    }
    
    @discardableResult
    public func incrementCount() -> Self {
        let currentCount = self.getCount + 1
        self.set(count: currentCount )
        parentMessage?.replyCount = currentCount
        if let parentMessage = parentMessage {
            CometChatMessageEvents.emitOnParentMessageUpdate(message: parentMessage)
        }
       return self
    }
    
    @discardableResult
    public func reset() -> Self {
        self.count = 0
        return self
    }
}

extension CometChatThreadedMessages : CometChatMessageOptionDelegate {
 
    
    func onItemClick(messageOption: CometChatMessageOption, forMessage: CometChatSDK.BaseMessage?, indexPath: IndexPath?, view: UIView?) {
        if let message = forMessage {
            switch messageOption.id {
            case MessageOptionConstants.editMessage :
                if messageOption.onItemClick == nil {
                    messageComposer.preview(message: message, mode: .edit)
                 } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.deleteMessage :
                if messageOption.onItemClick == nil {
                  //  messageList.delete(message: message)
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
                
            case MessageOptionConstants.messageInformation :
                if messageOption.onItemClick == nil {
                    messageList.didMessageInformationClicked(message: message)
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
            var textToShare = ""
            if message.messageType == .text {
                textToShare = (message as? TextMessage)?.text ?? ""
            }else if message.messageType == .audio ||  message.messageType == .file ||  message.messageType == .image || message.messageType == .video {
                
                textToShare = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
            }
            let sendItems = [textToShare]
            
            if !sendItems.isEmpty {
                let activityViewController = UIActivityViewController(activityItems: sendItems, applicationActivities: nil)
                activityViewController.popoverPresentationController?.sourceView = self.view
                activityViewController.excludedActivityTypes = [.airDrop]
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
    }
    
}

extension CometChatThreadedMessages: CometChatMessageEventListener {
    
    public func onMessageSent(message: BaseMessage, status: MessageStatus) {
        /*
         
         reply count ++
         
         */
        if parentMessage?.id == message.parentMessageId {
            switch status {
            case .inProgress:
                self.incrementCount()
                self.messageList?.add(message: message)
                self.messageList?.scrollToBottom()
            case .success:
                self.messageList?.update(message: message)
            }
        }
        
        print("CometChatThreadedMessages - events - onMessageSent")
    }

    
    public func onMessageEdit(message: BaseMessage, status: MessageStatus) {
        /*
          if message is ParentMessage
                // execute callbacks.
         */
        if parentMessage?.id == message.parentMessageId {
            self.messageList?.update(message: message)
        }
        
        print("CometChatThreadedMessages - events - onMessageEdit")
    }
    
    public func onMessageDelete(message: BaseMessage) {
        /*
         if message is parentMessage
            { execure call backs. }
         */
        if parentMessage?.id == message.parentMessageId {
            if ((messageList?.hideDeletedMessages) != nil) {
                self.messageList?.remove(message: message)
            } else {
                self.messageList?.update(message: message)
            }
        }
        
        print("CometChatThreadedMessages - events - onMessageDelete")
    }
    
    public func onMessageReply(message: BaseMessage, status: MessageStatus) {
        
        print("CometChatThreadedMessages - events - onMessageReply")
    }
    
    public func onMessageRead(message: BaseMessage) {
        /*
         
         - if message is ParentMessage {
         
                execute call back
         
            }
         */
        print("CometChatThreadedMessages - events - onMessageRead")
    }
    
    public func onParentMessageUpdate(message: BaseMessage) {
        
        print("CometChatThreadedMessages - events - onParentMessageUpdate")
    }
    
    public func onLiveReaction(reaction: TransientMessage) {
        
        print("CometChatThreadedMessages - events - onLiveReaction")
    }

    public func onMessageError(error: CometChatException) {
        
        print("CometChatThreadedMessages - events - onMessageError")
    }
    
    public func onVoiceCall(user: User) {
        
        print("CometChatThreadedMessages - events - onVoiceCall - User")
    }
    
    public func onVoiceCall(group: Group) {
        
        print("CometChatThreadedMessages - events - onVoiceCall - Group")
    }
    
    public func onVideoCall(user: User) {
        
        print("CometChatThreadedMessages - events - onVideoCall - User")
    }
    
    public func onVideoCall(group: Group) {
     
        print("CometChatThreadedMessages - events - onVideoCall - Group")
    }
    
    public func onViewInformation(user: User) {
        
        print("CometChatThreadedMessages - events - onViewInformation - User")
    }
    
    public func onViewInformation(group: Group) {
        
        print("CometChatThreadedMessages - events - onViewInformation - Group")
    }
    
    public func onError(message: BaseMessage?, error: CometChatException) {
        
        if parentMessage?.id == message?.parentMessageId {
            if let message = message {
                self.messageList?.update(message: message)
            }
        }
        print("CometChatThreadedMessages - events - onError")
    }
    
    public func onMessageReact(message: BaseMessage, reaction: CometChatMessageReaction) {
        
        print("CometChatThreadedMessages - events - onMessageReact")
    }
}

extension CometChatThreadedMessages: CometChatMessageDelegate {
    
    
    public func onTextMessageReceived(textMessage: CometChatSDK.TextMessage) {
        if parentMessage?.id == textMessage.parentMessageId {
            self.incrementCount()
        }
        
        print("CometChatThreadedMessages - sdk - onTextMessageReceived")
        
    }

    public func onMediaMessageReceived(mediaMessage: CometChatSDK.MediaMessage) {
        
        print("CometChatThreadedMessages - sdk - onMediaMessageReceived")
    }

    public func onCustomMessageReceived(customMessage: CometChatSDK.CustomMessage) {
        
        print("CometChatThreadedMessages - sdk - onCustomMessageReceived")
    }

    public func onTypingStarted(_ typingDetails: CometChatSDK.TypingIndicator) {
        
        print("CometChatThreadedMessages - sdk - onTypingStarted")
    }

    public func onTypingEnded(_ typingDetails: CometChatSDK.TypingIndicator) {
        
        print("CometChatThreadedMessages - sdk - onTypingEnded")
    }

    public func onTransisentMessageReceived(_ message: CometChatSDK.TransientMessage) {
        
        print("CometChatThreadedMessages - sdk - onTransisentMessageReceived")
    }

    public func onMessageEdited(message: CometChatSDK.BaseMessage) {
        
        print("CometChatThreadedMessages - sdk - onMessageEdited")
    }

    public func onMessageDeleted(message: CometChatSDK.BaseMessage) {
        /*
         if message is parentMessage
            { execure call backs. }
         */
        print("CometChatThreadedMessages - sdk - onMessageDeleted")
    }

    public func onMessagesRead(receipt: CometChatSDK.MessageReceipt) {
        /*
         
         - if message is ParentMessage {
         
                execute call back
         
            }
         */
        print("CometChatThreadedMessages - sdk - onMessagesRead")
    }

    public func onMessagesDelivered(receipt: CometChatSDK.MessageReceipt) {
        
        print("CometChatThreadedMessages - sdk - onMessagesDelivered")
    }

    /*
    func onMessageReadByAll(messageId: String, receiverId: String, receiverType: CometChatSDK.CometChat.ReceiverType) {
        
        print("CometChatThreadedMessages - sdk - onMessageReadByAll")
    }*/
    
}
