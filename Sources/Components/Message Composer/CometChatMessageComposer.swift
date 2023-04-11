//
//  CometChatMessageComposer.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 08/11/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import CometChatPro
import AudioToolbox
import AVFoundation
import CoreLocation
import CoreLocationUI


public enum MessageComposerMode {
    case draft
    case edit
    case reply
}

@objc @IBDesignable public class CometChatMessageComposer: UIView  {
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var messageInput: CometChatMessageInput!
    @IBOutlet weak var messagePreview: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var close: UIButton!
    @IBOutlet weak var editLineIndicator: UIView!
    @IBOutlet weak var headerContainer: UIStackView!
    @IBOutlet weak var footerContainer: UIStackView!
    
    // MARK: - Declaration of Variables
    private(set) var text: String?
    private(set) var placeholderText: String = "TYPE_A_MESSAGE".localize()
    private(set) var maxLine: Int?
    private(set) var onChange: (() -> Void)?
    private(set) var hideLiveReaction = false
    private(set) var disableSoundForMessages = true
    private(set) var customSoundForMessage: URL?
    private(set) var disableTypingEvents = false
    weak var controller: UIViewController?
    private(set) var secondaryButtonView: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var auxilaryButtonView: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var headerView: UIView?
    private(set) var hideHeaderView = true
    private(set) var footerView: UIView?
    private(set) var hideFooterView = true
    private(set) var sendButtonView: ((_ user: User?, _ group: Group?) -> UIView)?
    private(set) var messageComposerMode: MessageComposerMode =  .draft
    private(set) var auxiliaryButtonsAlignment: AuxilaryButtonAlignment = .right
    private(set) var messageComposerStyle = MessageComposerStyle()
    private(set) var messagePreviewStyle = MessagePreviewStyle()
    private(set) var actionItems: [ActionItem] = [ActionItem]()
    private(set) var attachmentOptions: [CometChatMessageComposerAction] = MessageUtils.getDefaultAttachmentOptions()
    private(set) var viewModel:  MessageComposerViewModel?
    private(set) var primaryButtonsView = UIStackView()
    private(set) var onSendButtonClick: ((BaseMessage) -> Void)?
    
    private(set) var attachmentIcon = UIImage(named: "message-composer-plus", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private(set) var liveReactionIcon: UIImage = UIImage(named: "message-composer-heart.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
    private(set)var sendIcon: UIImage = UIImage(named: "message-composer-send.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private(set) var closeIcon: UIImage = UIImage(named: "message-composer-close.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    //Document related variables and structure
    let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    
    struct CometChatMessageActionsGroup: CometChatActionPresentable {
        let string: String = "MessageActions Group"
        let rowVC: PanModalPresentable.LayoutType = CometChatActionSheet()
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
    
    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
        setupMessageComposer()
        setupMessageInput()
        setupDelegates()
        onInputTextChange()
        reset()
    }
    
    ///Setup Delegates
    fileprivate func setupDelegates() {
        documentPicker.delegate = self
        CometChatActionSheet.actionsSheetDelegate = self
    }
    
    ///Setup MessageComposer Appearance
    fileprivate func setupMessageComposer() {
        set(attachmentOptions: attachmentOptions)
        set(closeButtonIcon: closeIcon)
        set(auxilaryButtonAignment: auxiliaryButtonsAlignment)
        set(composerStyle: messageComposerStyle)
        set(attachmentIcon: attachmentIcon)
    }
    
    @discardableResult
    public func set(customComposer: UIView) -> Self {
        for view in containerStackView.subviews {
            view.removeFromSuperview()
        }
        containerStackView.addArrangedSubview(customComposer)
        return self
    }
    
    @objc func didSendButtonClicked() {
        if let onSendButtonClick = onSendButtonClick {
            if let text = self.text, let message =  viewModel?.setupBaseMessage(message: text) {
                onSendButtonClick(message)
            }
        } else {
            didDefaultSendButonClicked()
        }
    }
    
    ///Methods related to the MessageInput
    fileprivate func setupMessageInput() {
        
        let primaryButtons = setupDefaultPrimaryButtons()
        primaryButtonsView.subviews.last?.isHidden = true
        primaryButtonsView.subviews.first?.isHidden = hideLiveReaction
        messageInput.set(primaryButtonView: primaryButtons)
        
        let attachmentButton = setupDefaultSecondaryButton()
        messageInput.set(secondaryButtonView: attachmentButton)
        
        messageInput.set(placeholderText: placeholderText)
        messageInput.set(auxilaryButtonAignment: auxiliaryButtonsAlignment)
        if let maxLine = maxLine {
            messageInput.set(maxLines: maxLine)
        }
        messageInput.build()
    }
    
    @IBAction func onCloseClick(_ sender: UIButton) {
        UIView.transition(with: self.messagePreview, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            DispatchQueue.main.async {
                self.messagePreview.isHidden = true
                self.messageComposerMode = .draft
            }
        })
    }
    
    //MARK: Setting Up the default functionality
    //=========================================
    
    func setupDefaultSecondaryButton() -> UIView {
        let attachmentButton = UIButton()
        attachmentButton.setImage(attachmentIcon,  for: .normal)
        attachmentButton.tintColor = messageComposerStyle.attachmentIconTint
        attachmentButton.translatesAutoresizingMaskIntoConstraints = false
        attachmentButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        attachmentButton.addTarget(self, action: #selector(attachmentButtonClicked), for: .touchUpInside)
        return attachmentButton
    }
    
    func setupDefaultPrimaryButtons() -> UIView {
        let sendButton = UIButton()
        sendButton.setImage(sendIcon,  for: .normal)
        sendButton.tintColor = messageComposerStyle.sendIconTint
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(didDefaultSendButonClicked), for: .touchUpInside)
        
        let liveReaction = UIButton()
        liveReaction.setImage(liveReactionIcon, for: .normal)
        liveReaction.translatesAutoresizingMaskIntoConstraints = false
        liveReaction.widthAnchor.constraint(equalToConstant: 30).isActive = true
        liveReaction.addTarget(self, action: #selector(didLiveReactionClicked), for: .touchUpInside)
        primaryButtonsView = UIStackView(arrangedSubviews: [liveReaction, sendButton])
        primaryButtonsView.translatesAutoresizingMaskIntoConstraints = false
        primaryButtonsView.axis = .horizontal
        primaryButtonsView.spacing = 10
        primaryButtonsView.alignment = .center
        primaryButtonsView.distribution = .fillEqually
        return primaryButtonsView
    }
    
    @objc func didLiveReactionClicked() {
        viewModel?.onLiveReactionClick()
    }
    
    @objc func didDefaultSendButonClicked() {
        switch messageComposerMode {
        case .draft:
            if let _ = viewModel?.user {
                viewModel?.sendTextMessageToUser(message: self.text ?? "")
            } else if let _ = viewModel?.group {
                viewModel?.sendTextMessageToGroup(message: self.text ?? "")
            }
        case .edit:
            if let currentMessage = self.viewModel?.message as? TextMessage {
                viewModel?.editTextMessage(textMessage: currentMessage, message: self.text ?? "")
            }
        case .reply: break
            
        }
    }
    
    @objc func attachmentButtonClicked() {
        self.actionItems.removeAll()
        if !attachmentOptions.isEmpty {
            for  options in attachmentOptions {
                let style = ActionItemStyle()
                style.set(titleFont: options.textFont)
                style.set(titleColor: options.textColor)
                style.set(leadingIconTint: options.startIconTint)
                
                let actionItem = ActionItem(id: options.id ?? "", text: options.text ?? "", leadingIcon: options.startIcon ?? UIImage(), style: style, onActionClick: options.onActionClick)
                actionItems.append(actionItem)
            }
        }
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let group: CometChatActionPresentable = CometChatMessageActionsGroup()
        (group.rowVC as? CometChatActionSheet)?.set(layoutMode: .listMode).set(actionItems: actionItems)
        if let controller = controller {
            controller.presentPanModal(group.rowVC, backgroundColor:  CometChatTheme.palatte.secondary)
        }
    }
    
}

extension CometChatMessageComposer: UIDocumentPickerDelegate {
    
    /// This method triggers when we open document menu to send the message of type `File`.
    /// - Parameters:
    ///   - controller: A view controller that provides access to documents or destinations outside your app’s sandbox.
    ///   - urls: A value that identifies the location of a resource, such as an item on a remote server or the path to a local file.
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            if let _ = viewModel?.user {
                viewModel?.sendMediaMessageToUser(url: urls[0].absoluteString, type: .file)
            } else if let _ = viewModel?.group {
                viewModel?.sendMediaMessageToGroup(url: urls[0].absoluteString, type: .file)
            }
        }
    }
}

extension CometChatMessageComposer {
    
    @discardableResult
    public func connect() ->  Self {
        CometChatUIEvents.addListener("composer-ui-event-listener", self as CometChatUIEventListener)
        return self
    }
    
    @discardableResult
    public func disconnect() ->  Self {
        CometChatUIEvents.removeListener("composer-ui-event-listener")
        return self
    }
  
    @discardableResult
    public func set(parentMessageId: Int) ->  Self {
        viewModel?.parentMessageId = parentMessageId
        return self
    }
    
    @discardableResult
    public func set(composerStyle: MessageComposerStyle) -> Self {
        set(inputBackground: composerStyle.inputBackground)
        set(textColor: composerStyle.textColor)
        set(textFont: composerStyle.textFont)
        set(placeHolderTextFont: composerStyle.placeHolderTextFont)
        set(placeHolderTextColor: composerStyle.placeHolderTextColor)
        set(inputBorderWidth: composerStyle.inputBorderWidth)
        set(inputBorderColor: composerStyle.inputBorderColor)
        set(inputBoxPlaceholderFont: composerStyle.inputBoxPlaceholderFont)
        set(attachmentIconTint: composerStyle.attachmentIconTint)
        set(sendIconTint: composerStyle.sendIconTint)
        set(dividerTint: composerStyle.dividerTint)
        set(inputBorderColor: composerStyle.inputBorderColor)
        return self
    }
    
    @discardableResult
    @objc public func set(user: User) -> Self {
        viewModel = MessageComposerViewModel(user: user)
        DispatchQueue.main.async {
            self.checkSoundForMessage()
            self.reset()
            self.updateComposerLayout()
        }
        return self
    }
    
    @discardableResult
    @objc public func set(group: Group) -> Self {
        viewModel = MessageComposerViewModel(group: group)
        checkSoundForMessage()
        reset()
        updateComposerLayout()
        return self
    }
    
    @discardableResult
    public func draft(message: String) -> Self{
        self.messagePreview.isHidden = true
        return self
    }
    
    @discardableResult
    public func preview(message: BaseMessage, mode: MessageComposerMode) -> Self {
        switch mode {
        case .edit: edit(message: message)
        case .reply: reply(message: message)
        default: break
        }
        return self
    }
    
    @discardableResult
    public func set(placeholderText: String) ->  Self {
        self.placeholderText = placeholderText
        messageInput.set(placeholderText: placeholderText)
        return self
    }
    
    @discardableResult
    public func set(maxLine: Int) ->  Self {
        self.maxLine = maxLine
        messageInput.set(maxLines: maxLine)
        return self
    }
    
    @discardableResult
    public func disable(disableSoundForMessages: Bool) ->  Self {
        self.disableSoundForMessages = disableSoundForMessages
        return self
    }
    
    @discardableResult
    public func set(customSoundForMessage: URL) ->  Self {
        self.customSoundForMessage = customSoundForMessage
        return self
    }
    
    @discardableResult
    public func disable(disableTypingEvents: Bool) ->  Self {
        self.disableTypingEvents = disableTypingEvents
        return self
    }
    
    @discardableResult
    public func removeContainerStaView() -> Self {
        self.containerStackView.removeFromSuperview()
        return self
    }
    
    @discardableResult
    public func setSendButtonView(sendButtonView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.sendButtonView = sendButtonView
       
        if let lastView = primaryButtonsView.subviews.last {
            primaryButtonsView.removeArrangedSubview(lastView)
        }
        if let sendButtonView = self.sendButtonView?(viewModel?.user, viewModel?.group) {
            primaryButtonsView.addArrangedSubview(sendButtonView)
            let tap = UITapGestureRecognizer(target: self, action: #selector(didSendButtonClicked))
            if !sendButtonView.subviews.isEmpty {
                sendButtonView.subviews.last?.addGestureRecognizer(tap)
            } else {
                sendButtonView.addGestureRecognizer(tap)
            }
        }
        primaryButtonsView.subviews.last?.isHidden = true
        messageInput.set(primaryButtonView: primaryButtonsView)
        return self
    }
    
    @discardableResult
    public func setSecondaryButtonView(secondaryButtonView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.secondaryButtonView = secondaryButtonView
        if let secondaryButtonView = self.secondaryButtonView?(viewModel?.user, viewModel?.group) {
            messageInput.set(secondaryButtonView: secondaryButtonView )
        }
        return self
    }
    
    @discardableResult
    public func setAuxilaryButtonView(auxilaryButtonView: @escaping ((_ user: User?, _ group: Group?) -> UIView)) -> Self {
        self.auxilaryButtonView = auxilaryButtonView
        if let auxilaryButtonView =  self.auxilaryButtonView?(viewModel?.user, viewModel?.group) {
            messageInput.set(auxilaryButtonView: auxilaryButtonView)
        }
        return self
    }
    
    @discardableResult
    public func set(auxilaryButtonAignment: AuxilaryButtonAlignment) -> Self {
        self.auxiliaryButtonsAlignment = auxilaryButtonAignment
        return self
    }
    
    @discardableResult
    public func hide(liveReaction: Bool) ->  Self {
        self.hideLiveReaction = liveReaction
        if let _ = viewModel?.parentMessageId {
            self.primaryButtonsView.subviews.first?.isHidden = true
            self.primaryButtonsView.subviews.last?.isHidden = true
        } else {
            self.primaryButtonsView.subviews.first?.isHidden = true
            self.primaryButtonsView.subviews.last?.isHidden = false
        }
        return self
    }
    
    @discardableResult
    public func set(liveReactionIcon: UIImage) -> Self {
        self.liveReactionIcon = liveReactionIcon.withRenderingMode(.alwaysTemplate)
        let primaryButtons = setupDefaultPrimaryButtons()
        primaryButtonsView.subviews.last?.isHidden = true
        messageInput.set(primaryButtonView: primaryButtons)
        return self
    }
    
    @discardableResult
    public func set(attachmentIcon: UIImage) ->  Self {
        self.attachmentIcon = attachmentIcon.withRenderingMode(.alwaysTemplate)
        let attachmentButton = setupDefaultSecondaryButton()
        messageInput.set(secondaryButtonView: attachmentButton)
        return self
    }
    
    @discardableResult
    public func set(attachmentOptions: [CometChatMessageComposerAction]) -> Self {
        self.attachmentOptions = attachmentOptions
        return self
    }
    
  
    
    @discardableResult
    public func set(headerView: UIView?) ->  Self {
        self.headerView = headerView
        headerContainer.subviews.forEach({ $0.removeFromSuperview() })
        if headerView != nil {
            self.headerContainer.isHidden = false
            if let headerView = headerView {
                self.headerContainer.addArrangedSubview(headerView)
            }
        }else{
            self.headerContainer.isHidden = true
        }
        return self
    }
    
    @discardableResult
    public func hide(headerView: Bool) ->  Self {
        self.hideHeaderView = headerView
        self.headerContainer.isHidden = true
        headerContainer.subviews.forEach({ $0.removeFromSuperview() })
        self.headerContainer.isHidden = true
        return self
    }
    
    @discardableResult
    public func set(footerView: UIView) ->  Self {
        self.footerView = footerView
        footerContainer.subviews.forEach({ $0.removeFromSuperview() })
        if self.footerView != nil {
            self.footerContainer.isHidden = false
            self.footerContainer.addArrangedSubview(footerView)
        }else{
            self.footerContainer.isHidden = true
        }
        return self
    }
    
    @discardableResult
    public func hide(footerView: Bool) ->  Self {
        self.hideFooterView = footerView
        self.footerContainer.isHidden = true
        footerContainer.subviews.forEach({ $0.removeFromSuperview() })
        self.footerView = nil
        self.layoutIfNeeded()
        return self
    }
    
    @discardableResult
    public func setOnSendButtonClick(onSendButtonClick: @escaping ((BaseMessage) -> Void)) -> Self {
        self.onSendButtonClick = onSendButtonClick
        return self
    }
    
    @discardableResult
    public func setOnChange(onChange: @escaping (() -> Void)) -> Self {
        self.onChange = onChange
        return self
    }
        
    @discardableResult
    public func setOnSendButtonClick(onSendButtonClick: ((BaseMessage) -> ())?) -> Self {
        self.onSendButtonClick = onSendButtonClick
        return self
    }
    
    @discardableResult
     public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(title: String?) -> CometChatMessageComposer {
        self.title.text = title
        return self
    }
    
    @discardableResult
    public func set(titleWithAttributedText: NSAttributedString) -> CometChatMessageComposer {
        self.title.attributedText = titleWithAttributedText
        return self
    }
    
    @discardableResult
    public func set(subTitle: String?) -> CometChatMessageComposer {
        self.subtitle.text = subTitle
        return self
    }
    
    @discardableResult
    public func set(subTitleWithAttributedText: NSAttributedString) -> CometChatMessageComposer {
        self.subtitle.attributedText = subTitleWithAttributedText
        return self
    }
    
    @discardableResult
    public func set(closeButtonIcon: UIImage) -> CometChatMessageComposer {
        self.close.setImage(closeButtonIcon, for: .normal)
        return self
    }
    
    @discardableResult
    public func edit(message: BaseMessage) -> Self {
        if let message = message as? TextMessage {
            self.viewModel?.message = message
            self.messageComposerMode = .edit
            set(title: "EDIT_MESSAGE".localize())
            set(subTitle: message.text)
            messageInput.set(text: message.text)
            UIView.transition(with: messagePreview, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.messagePreview.isHidden = false
            })
        }
        return self
    }
    
    @discardableResult
    public func reply(message: BaseMessage)  -> Self {
        viewModel?.message = message
        self.messageComposerMode = .reply
        UIView.transition(with: messagePreview, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.messagePreview.isHidden = false
        })
        
        if let name = message.sender?.name {
            set(subTitle: name.capitalized)
        }
        switch message.messageType {
        case .text: set(subTitle: (message as? TextMessage)?.text)
        case .image:  set(subTitle: "MESSAGE_IMAGE".localize())
        case .video:  set(subTitle: "MESSAGE_VIDEO".localize())
        case .audio:  set(subTitle: "MESSAGE_AUDIO".localize())
        case .file:  set(subTitle: "MESSAGE_FILE".localize())
        case .custom:
            if let type = (message as? CustomMessage)?.type {
                if type == MessageTypeConstants.location {
                    set(subTitle: "CUSTOM_MESSAGE_LOCATION".localize())
                } else if type == MessageTypeConstants.poll {
                    set(subTitle: "CUSTOM_MESSAGE_POLL".localize())
                } else if type == MessageTypeConstants.sticker {
                    set(subTitle: "CUSTOM_MESSAGE_STICKER".localize())
                } else if type == MessageTypeConstants.whiteboard {
                    set(subTitle: "CUSTOM_MESSAGE_WHITEBOARD".localize())
                } else if type == MessageTypeConstants.document {
                    set(subTitle: "CUSTOM_MESSAGE_DOCUMENT".localize())
                } else if type == MessageTypeConstants.meeting {
                    set(subTitle: "CUSTOM_MESSAGE_GROUP_CALL".localize())
                }
            }
        case .groupMember: break
        @unknown default: break
        }
        return self
    }

    //Style Related Methods
    @discardableResult
    public func set(inputBackground: UIColor) -> Self {
        self.messageInput.backgroundColor = inputBackground
        return self
    }
    
    @discardableResult
    public func set(textColor: UIColor) -> Self {
        messageInput.set(textColor: textColor)
        return self
    }
    
    @discardableResult
    public func set(textFont: UIFont) -> Self {
        messageInput.set(textFont: textFont)
        return self
    }
    
    @discardableResult
    public func set(inputBoxPlaceholderFont: UIFont) -> Self {
        messageInput.set(placeHolderTextFont: inputBoxPlaceholderFont)
        return self
    }
    
    @discardableResult
    public func set(inputBoxPlaceholderColor: UIColor) -> Self {
        messageInput.set(placeHolderTextColor: inputBoxPlaceholderColor)
        return self
    }
    
    @discardableResult
    public func set(attachmentIconTint: UIColor) -> Self {
        self.attachmentIcon.withTintColor(attachmentIconTint, renderingMode: .alwaysTemplate)
        return self
    }
    
    @discardableResult
    public func set(sendIconTint: UIColor) -> Self {
        self.sendIcon.withTintColor(sendIconTint, renderingMode: .alwaysTemplate)
        return self
    }
    
    @discardableResult
    public func set(placeHolderTextFont: UIFont) -> Self {
        messageInput.set(placeHolderTextFont: placeHolderTextFont)
        return self
    }
    
    @discardableResult
    public func set(placeHolderTextColor: UIColor) -> Self {
        messageInput.set(placeHolderTextColor: placeHolderTextColor)
        return self
    }
    
    @discardableResult
    public func set(inputBorderWidth: CGFloat) -> Self {
        self.messageInput.layer.borderWidth = inputBorderWidth
        return self
    }
    
    @discardableResult
    public func set(inputBorderColor: UIColor) -> Self {
        self.messageInput.layer.borderColor = inputBorderColor.cgColor
        return self
    }
    
    @discardableResult
    public func set(dividerTint: UIColor) -> Self {
        self.messageInput.set(dividerColor: dividerTint)
        return self
    }
}

///Callback Methods
///==========================
extension CometChatMessageComposer {
    private func checkSoundForMessage() {
        viewModel?.isSoundForMessageEnabled = { [weak self]  in
            guard let this = self else { return }
            if !this.disableSoundForMessages {
                CometChatSoundManager().play(sound: .outgoingMessage, customSound: this.customSoundForMessage)
            }
        }
    }
    
    private func reset() {
        viewModel?.reset  = { [weak self] status in
            guard let this = self else { return}
            this.messageComposerMode = .draft
            this.messageInput.set(text: "")
            if !this.messagePreview.isHidden {
                this.messagePreview.isHidden = true
            }
        }
    }
    
    private func onInputTextChange() {
        self.onChange?()
        
        messageInput.shouldBeginEditing = { [weak self] (bool) in
            guard let this = self else { return }
            if this.footerView != nil {
                this.hide(footerView: true)
            }
        }
        
        messageInput.shouldEndEditing = { [weak self] (bool) in
            guard self != nil else { return }
        }
        
        messageInput.onChange = { [weak self] (text) in
            guard let this = self else { return }
            this.text = text
            if  !this.disableTypingEvents {
                this.viewModel?.startTyping()
            }
            
            if text.isEmpty {
                this.viewModel?.endTyping()
                switch this.hideLiveReaction {
                case true :
                    this.primaryButtonsView.subviews.first?.isHidden = true
                    if let _ = this.viewModel?.parentMessageId {
                        this.primaryButtonsView.subviews.last?.isHidden = true
                    } else {
                        this.primaryButtonsView.subviews.last?.isHidden = false
                    }
                case false:
                    this.primaryButtonsView.subviews.first?.isHidden = false
                    this.primaryButtonsView.subviews.last?.isHidden = true
                }
            } else {
                this.primaryButtonsView.subviews.first?.isHidden = true
                this.primaryButtonsView.subviews.last?.isHidden = false
            }
        }
    }
    
    private func updateComposerLayout() {
        viewModel?.failure = { [weak self] (error) in
            guard let this = self else { return }
            this.messageComposerMode = .draft
        }
    }
    
    private func isForThisView(id: [String:Any]?) -> Bool {
        guard let id = id , !id.isEmpty else { return false }
        if (id["uid"] != nil && id["uid"] as? String ==
            viewModel?.user?.uid) || (id["guid"] != nil && id["guid"] as? String ==
                                      viewModel?.group?.guid) {
            if (id["parentMessageId"] != nil &&
                id["parentMessageId"] as? Int != viewModel?.parentMessageId) {
                return false
            }else{
                return true
            }
        }
        return false
    }
}

extension CometChatMessageComposer: CometChatUIEventListener {
    
    public func onActiveChatChanged(id: [String : Any]?, lastMessage: CometChatPro.BaseMessage?, user: CometChatPro.User?, group: CometChatPro.Group?) {
    }
    
    public func showPanel(id: [String : Any]?, alignment: UIAlignment, view: UIView?) {
        if !isForThisView(id: id) { return }
        if let view = view {
            switch alignment {
            case .composerTop:
                set(headerView: view)
            case .composerBottom:
                set(footerView: view)
            case .messageListTop, .messageListBottom: break
            }
        } else {
            hide(headerView: true)
        }
    }
    
    public func hidePanel(id: [String : Any]?, alignment: UIAlignment) {
        if !isForThisView(id: id) { return }
        switch alignment {
        case .composerTop:
            hide(headerView: true)
        case .composerBottom:
            hide(footerView: true)
        case .messageListTop, .messageListBottom: break
        }
    }
}
