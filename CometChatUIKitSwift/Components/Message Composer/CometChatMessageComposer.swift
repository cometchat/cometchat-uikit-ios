//
//  CometChatMessageComposer_v5.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 07/10/24.
//

import CometChatSDK
import UIKit

open class CometChatMessageComposer: UIView {
    
    public lazy var textView: GrowingTextView = {
        let growingTextView = GrowingTextView().withoutAutoresizingMaskConstraints()
        growingTextView.delegate = self
        growingTextView.placeholder = "Type your message here..."
        growingTextView.maxHeight = style.textFiledFont.lineHeight * 5
        growingTextView.minHeight = 12
        growingTextView.backgroundColor = .clear
        return growingTextView
    }()
    
    public lazy var containerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.backgroundColor = .clear
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        return stackView
    }()
    
    public lazy var dividerView: UIView = {
        let dividerView = UIView().withoutAutoresizingMaskConstraints()
        dividerView.pin(anchors: [.height], to: 1)
        dividerView.backgroundColor = .separator
        return dividerView
    }()
    
    public lazy var composerBoxContainerStackView: UIStackView = {
        
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        
        stackView.addArrangedSubview(messagePreview)
        stackView.addArrangedSubview(topContainerView)
        stackView.addArrangedSubview(dividerView)
        stackView.addArrangedSubview(bottomContainerView)
        
        return stackView
    }()
    
    public lazy var topContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            textView.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            textView.trailingAnchor.pin(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            textView.topAnchor.pin(equalTo: view.topAnchor, constant: CometChatSpacing.Padding.p1),
            textView.bottomAnchor.pin(equalTo: view.bottomAnchor, constant: -CometChatSpacing.Padding.p1),
        ])
        
        return view
    }()
    
    public lazy var bottomContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.pin(anchors: [.height], to: 48)
        return view
    }()
    
    public lazy var messagePreview: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: CometChatSpacing.Padding.p1, left: CometChatSpacing.Padding.p1, bottom: CometChatSpacing.Padding.p1, right: CometChatSpacing.Padding.p1)
        stackView.isHidden = true
        return stackView
    }()
    
    public lazy var suggestionContainerView : UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: CometChatSpacing.Spacing.s1, left: CometChatSpacing.Spacing.s2, bottom: CometChatSpacing.Spacing.s1, right: CometChatSpacing.Spacing.s2)
        return stackView
    }()
    
    public lazy var primaryButtonContainerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        return stackView
    }()
    
    public lazy var secondaryButtonContainerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        return stackView
    }()
    
    public lazy var headerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .init(top: CometChatSpacing.Spacing.s1, left: CometChatSpacing.Spacing.s2, bottom: CometChatSpacing.Spacing.s1, right: CometChatSpacing.Spacing.s2)
        return stackView
    }()
    
    public lazy var footerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        return stackView
    }()
    
    public lazy var primaryStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    public lazy var secondaryStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.spacing = CometChatSpacing.Padding.p4
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    public lazy var auxiliaryStackView : UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    public lazy var aiButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didAIButtonClicked), for: .primaryActionTriggered)
        button.pin(anchors: [.height, .width], to: 32)
        return button
    }()
    
    public lazy var sendButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didSendButtonClicked), for: .primaryActionTriggered)
        button.pin(anchors: [.height, .width], to: 32)
        button.roundViewCorners(corner: .init(cornerRadius: (32/2)))
        return button
    }()
    
    public lazy var attachmentButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(attachmentButtonClicked), for: .primaryActionTriggered)
        button.pin(anchors: [.height, .width], to: 24)
        return button
    }()
    
    public lazy var microphoneButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didMicrophoneButtonClicked), for: .primaryActionTriggered)
        button.pin(anchors: [.height, .width], to: 24)
        return button
    }()
    
    public var bottomConstant: NSLayoutConstraint!
    
    //MARK: Global Style
    static public var style = MessageComposerStyle()
    static public var mediaRecorderStyle = CometChatMediaRecorder.style
    static public var attachmentSheetStyle = CometChatActionSheet.style
    static public var suggestionsStyle = SuggestionViewStyle()
    static public var mentionStyle = CometChatMentionsFormatter.composerTextStyle
    static public var aiOptionsStyle = AIOptionsStyle()
    
    //MARK: LOCAL STYLE
    public lazy var style = CometChatMessageComposer.style
    public lazy var mediaRecorderStyle = CometChatMessageComposer.mediaRecorderStyle
    public lazy var attachmentSheetStyle = CometChatMessageComposer.attachmentSheetStyle
    public lazy var suggestionsStyle = SuggestionViewStyle()
    public lazy var aiOptionsStyle = AIOptionsStyle()
    public var mentionStyle = CometChatMessageComposer.mentionStyle
    
    //MARK: CALL BACKS PROPERTIES
    public var attachmentOptionsClosure: ((_ user: User?, _ group: Group?, _ controller: UIViewController?) -> [CometChatMessageComposerAction])?
    public var aiOptionsClosure: ((_ user: User?, _ group: Group?, _ controller: UIViewController?) -> [CometChatMessageComposerAction])?
    public var onSendButtonClick: ((BaseMessage) -> Void)?
    public var onSuggestionItemClick: ((SuggestionItem) -> Void)?
    public var secondaryButtonView: ((_ user: User?, _ group: Group?) -> UIView)?
    public var auxilaryButtonView: ((_ user: User?, _ group: Group?) -> UIView)?
    public var sendButtonView: ((_ user: User?, _ group: Group?) -> UIView)?
    public var onClickSuggestionListView: (() -> Void)?
    
    public var viewModel = MessageComposerViewModel()
    public var placeholderText: String = "TYPE_A_MESSAGE".localize()
    public var disableSoundForMessages = false
    public var customSoundForMessage: URL?
    public var disableTypingEvents = false
    public var hideHeaderView = true
    public var hideFooterView = true
    public var messageComposerMode: MessageComposerMode =  .draft
    public var auxiliaryButtonsAlignment: AuxilaryButtonAlignment = .left
    public var suggestionViewStyle: SuggestionViewStyle?
    public var disableMentions: Bool = false
    public var hideSendButton = false
    public var attachmentOptions = [CometChatMessageComposerAction]()
    
    //Internal variables
    internal var typingWorkItem: DispatchWorkItem?
    internal var suggestionView: CometChatSuggestionView?
    internal var isSuggestionLimitAcceded = false
    internal var ongoingTextFormatter: OnGoingTextFormatterModel?
    internal var selectedFormatters = [Character: [(item: SuggestionItem, range: NSRange)]]()
    internal weak var controller: UIViewController?
    internal var listenerRandomId = Date().timeIntervalSince1970
    internal let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    
    // MARK: - Initialisation of required Methods
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupViewModel()
        buildUI()
        handleThemeModeChange()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewModel()
        buildUI()
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
            connect()
        }
    }
    
    open func buildUI() {
        
        var constraintsToActivate = [NSLayoutConstraint]()
        
        //Setting Container View with margins
        addSubview(containerView)
        bottomConstant = containerView.bottomAnchor.pin(equalTo: bottomAnchor, constant: -CometChatSpacing.Margin.m8)
        pin(anchors: [.top, .leading, .trailing], to: containerView)
        bottomConstant.isActive = true
        
        containerView.addArrangedSubview(headerView)
        containerView.addArrangedSubview(suggestionContainerView)
        let paddingView = UIView().withoutAutoresizingMaskConstraints()
        paddingView.embed(composerBoxContainerStackView, insets: .init(
            top: 0,
            leading: CometChatSpacing.Margin.m2,
            bottom: CometChatSpacing.Margin.m2,
            trailing: CometChatSpacing.Margin.m2
        ))
        containerView.addArrangedSubview(paddingView)
        containerView.addArrangedSubview(footerView)
        
        //building bottom view
        bottomContainerView.addSubview(secondaryStackView)
        constraintsToActivate += [
            secondaryStackView.leadingAnchor.pin(equalTo: bottomContainerView.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            secondaryStackView.trailingAnchor.pin(equalTo: auxiliaryStackView.leadingAnchor, constant: -CometChatSpacing.Padding.p4),
            secondaryStackView.centerYAnchor.pin(equalTo: bottomContainerView.centerYAnchor)
        ]
        
        bottomContainerView.addSubview(auxiliaryStackView)
        constraintsToActivate += [
            auxiliaryStackView.trailingAnchor.pin(equalTo: primaryStackView  .leadingAnchor, constant: -CometChatSpacing.Padding.p4),
            auxiliaryStackView.centerYAnchor.pin(equalTo: bottomContainerView.centerYAnchor)
        ]
        
        bottomContainerView.addSubview(primaryStackView)
        constraintsToActivate += [
            primaryStackView.trailingAnchor.pin(equalTo: bottomContainerView.trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            primaryStackView.centerYAnchor.pin(equalTo: bottomContainerView.centerYAnchor)
        ]

        //setting up primary Button
        primaryStackView.addArrangedSubview(sendButton)
        
        //setting up secondary Buttons
        secondaryStackView.addArrangedSubview(attachmentButton)
        secondaryStackView.addArrangedSubview(microphoneButton)
        
        NSLayoutConstraint.activate(constraintsToActivate)
    }
    
    open func handleThemeModeChange() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                self.setupStyle()
            })
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Check if the user interface style has changed
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.setupStyle()
        }
    }
    
    open func setupStyle() {
        backgroundColor = style.backgroundColor
        if let cornerRadius = style.cornerRadius {
            roundViewCorners(corner: cornerRadius)
        }
        borderWith(width: style.borderWidth)
        borderColor(color: style.borderColor)
        
        composerBoxContainerStackView.backgroundColor = style.composeBoxBackgroundColor
        composerBoxContainerStackView.borderWith(width: style.composeBoxBorderWidth)
        composerBoxContainerStackView.borderColor(color: style.composeBoxBorderColor)
        composerBoxContainerStackView.roundViewCorners(corner: style.composerBoxCornerRadius)
        
        dividerView.backgroundColor = style.composerSeparatorColor
        
        textView.font = style.textFiledFont
        textView.textColor = style.textFiledColor
        textView.placeholderColor = style.placeHolderTextColor
        textView.placeholderFont = style.placeHolderTextFont
        
        //setting image
        attachmentButton.setImage(style.attachmentImage, for: .normal)
        microphoneButton.setImage(style.voiceRecordingImage, for: .normal)
        sendButton.setImage(style.sendButtonImage, for: .normal)
        aiButton.setImage(style.aiImage, for: .normal)
        
        sendButton.imageView?.tintColor = style.sendButtonImageTint
        sendButton.backgroundColor = style.inactiveSendButtonImageBackgroundColor
        
        microphoneButton.imageView?.tintColor = style.voiceRecordingImageTint
        attachmentButton.imageView?.tintColor = style.attachmentImageTint
        aiButton.imageView?.tintColor = style.aiImageTint
        
        viewModel.textFormatter.forEach({ ($0 as? CometChatMentionsFormatter)?.set(composerTextStyle: mentionStyle) })
    }
    
    open func setupAuxiliaryButton() {
        if let auxiliaryOptions = ChatConfigurator.getDataSource().getAuxiliaryOptions(user: viewModel.user, group: viewModel.group, controller: controller, id: getId()) {
            if let auxiliaryOptions = (auxiliaryOptions as? UIStackView)  {
                auxiliaryOptions.spacing = CometChatSpacing.Padding.p4
                auxiliaryOptions.distribution = .fill
                
                ///Setting Tint Colour for sticker
                ///Did not want to do it but I was forced
                auxiliaryOptions.subviews.forEach({
                    if let button = $0 as? UIButton {
                        button.imageView?.tintColor = style.stickerTint
                    }
                })
                
                ///Checking AI enabled of not
                let aiOptionsList = ChatConfigurator.getDataSource().getAIOptions(controller: controller ?? UIViewController(), user: viewModel.user, group: viewModel.group, id: getId(), aiOptionsStyle: aiOptionsStyle)
                if let aiOptionsList = aiOptionsList, !aiOptionsList.isEmpty {
                    auxiliaryOptions.addArrangedSubview(aiButton)
                }
                
                if auxiliaryButtonsAlignment == .right {
                    auxiliaryOptions.insertArrangedSubview(UIView(), at: 0)
                } else if auxiliaryButtonsAlignment == .left {
                    auxiliaryOptions.addArrangedSubview(UIView())
                }
                auxiliaryStackView.embed(auxiliaryOptions)
            }
        }
    }
    
    @objc open func didMicrophoneButtonClicked() {
        controller?.view.endEditing(true)
        let cometChatMediaRecorder = CometChatMediaRecorder()
        cometChatMediaRecorder.style = mediaRecorderStyle
        if let user = viewModel.user {
            cometChatMediaRecorder.viewModel = MediaRecorderViewModel(user: user)
        } else if let group = viewModel.group {
            cometChatMediaRecorder.viewModel = MediaRecorderViewModel(group: group)
        }
        cometChatMediaRecorder.setSubmit(onSubmit: {url in
            if self.onSendButtonClick != nil {
                self.onSendButtonClick?(self.viewModel.setupBaseMessage(url: url))
            } else {
                if self.viewModel.user != nil {
                    self.viewModel.sendMediaMessageToUser(url: url, type: .audio)
                } else {
                    self.viewModel.sendMediaMessageToGroup(url: url, type: .audio)
                }
            }
        })
        
        if #available(iOS 15.0, *) {
            if let sheetController = cometChatMediaRecorder.sheetPresentationController {
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        let height = (2 * CometChatSpacing.Padding.p3) + (2 * CometChatSpacing.Padding.p5) + (CometChatSpacing.Spacing.s5) + 170
                        return CGFloat(height)
                    }
                    sheetController.detents = [customDetent]
                }
                sheetController.prefersGrabberVisible = false
                sheetController.largestUndimmedDetentIdentifier = .medium
            }
            cometChatMediaRecorder.modalPresentationStyle = .pageSheet
            controller?.present(cometChatMediaRecorder, animated: true, completion: nil)
        } else {
            controller?.presentPanModal(cometChatMediaRecorder)
        }
    }
    
    @objc open func didSendButtonClicked() {
        let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackLight.impactOccurred()
        
        if let onSendButtonClick = onSendButtonClick {
            if let text = textView.text {
                let message = viewModel.setupBaseMessage(message: text, textFormatter: selectedFormatters)
                onSendButtonClick(message)
            }
        } else {
            didDefaultSendButtonClicked()
        }
    }
    
    open func didDefaultSendButtonClicked() {
        switch messageComposerMode {
        case .draft:
            if let _ = viewModel.user, !textView.text.isEmpty {
                viewModel.sendTextMessageToUser(message: textView.text, textFormatter: selectedFormatters)
            } else if let _ = viewModel.group, !textView.text.isEmpty {
                viewModel.sendTextMessageToGroup(message: textView.text, textFormatter: selectedFormatters)
            }
        case .edit:
            if let currentMessage = self.viewModel.message as? TextMessage, !textView.text.isEmpty {
                viewModel.editTextMessage(textMessage: currentMessage, message: textView.text, textFormatter: selectedFormatters)
            }
        case .reply: break
            
        }
    }
    
    ///Setup Delegates
    internal func setupDelegates() {
        documentPicker.delegate = self
    }
    
    deinit {
        disconnect()
    }
    
    private func getId() -> [String: Any] {
        var id = [String:Any]()
        
        if let user = viewModel.user {
            id["uid"] = user.uid
        }
        if let group = viewModel.group {
            id["guid"] = group.guid
        }
        if viewModel.parentMessageId != 0 {
            id["parentMessageId"] = viewModel.parentMessageId
        }
        
        return id
    }
    
    open func presentEditPreview(for message: BaseMessage) {
        
        self.sendButton.isEnabled = true
        self.sendButton.backgroundColor = style.activeSendButtonImageBackgroundColor
        
        if let textMessage = message as? TextMessage {
            let formattedText = MessageUtils.processTextFormatter(message: textMessage, textFormatter: viewModel.textFormatter, formattingType: .COMPOSER)
            let editPreviewView = MessagePreviewView(title: "EDIT_MESSAGE".localize(), subTitle: formattedText, style: style)
            messagePreview.subviews.forEach({ $0.removeFromSuperview() })
            messagePreview.isHidden = false
            messagePreview.addArrangedSubview(editPreviewView)
            editPreviewView.layoutIfNeeded()
            editPreviewView.onCrossIconClicked = { [weak self] in
                self?.hideEditPreview()
            }
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.controller?.view.layoutIfNeeded()
            }
        }
        
    }
    
    open func hideEditPreview() {
        messageComposerMode = .draft
        messagePreview.subviews.forEach({ $0.removeFromSuperview() })
        messagePreview.isHidden = true
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.controller?.view.layoutIfNeeded()
        }
    }
    
}

//MARK: Keyboard event
extension CometChatMessageComposer {
    
    private func removeKeyboard() {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillChangeFrameNotification)
    }
    
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if textView.isFirstResponder {
            if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                remove(footerView: true)
                let keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
                if keyboardHeight > 0 {
                    bottomConstant.constant = -keyboardHeight - CometChatSpacing.Margin.m2
                    UIView.animate(withDuration: 0.2) {
                        self.superview?.layoutIfNeeded()
                    }
                    
                } else {
                    bottomConstant.constant = -CometChatSpacing.Margin.m8
                    UIView.animate(withDuration: 0.2) {
                        self.superview?.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @objc func attachmentButtonClicked() {
        
        let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackLight.impactOccurred()
        attachmentOptions = [CometChatMessageComposerAction]()
        
        if let attachmentOption = attachmentOptionsClosure?(viewModel.user, viewModel.group, controller) {
            attachmentOptions.append(contentsOf: attachmentOption)
        } else {
            attachmentOptions.append(contentsOf: ChatConfigurator.getDataSource().getAttachmentOptions(controller: controller!, user: viewModel.user, group: viewModel.group, id: getId()) ?? MessageUtils.getDefaultAttachmentOptions())
        }
        
        var actionItems = [ActionItem]()
        if !attachmentOptions.isEmpty {
            for  options in attachmentOptions {
                let actionItem = ActionItem(id: options.id ?? "", text: options.text ?? "", leadingIcon: options.startIcon ?? UIImage(), onActionClick: options.onActionClick)
                actionItems.append(actionItem)
            }
        }
             
        self.controller?.view.endEditing(true)
        let actionSheet = CometChatActionSheet()
        actionSheet.style = attachmentSheetStyle
        actionSheet.actionSheetDelegate = self
        actionSheet.set(actionItems: actionItems)
        
        if #available(iOS 15.0, *) {
            if let sheetController = actionSheet.sheetPresentationController {
                sheetController.detents = [.medium()] // Half-sheet height
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        if UIDevice.current.userInterfaceIdiom == .pad{
                            return CGFloat(Double(actionItems.count * 50) + (CometChatSpacing.Padding.p3))
                        }else{
                            return CGFloat(actionItems.count * 50)
                        }
                    }
                    sheetController.detents = [customDetent]
                }
                
                sheetController.prefersGrabberVisible = true // Optional: shows grabber
                sheetController.largestUndimmedDetentIdentifier = .large
            }
            actionSheet.modalPresentationStyle = .pageSheet
            controller?.present(actionSheet, animated: true, completion: nil)
        } else {
            controller?.presentPanModal(actionSheet)
        }
        
    }
    
    @objc func didAIButtonClicked() {
        var aiAttachmentOptions = [CometChatMessageComposerAction]()
        if let aiOptionsClosure = aiOptionsClosure?(viewModel.user, viewModel.group, controller){
            aiAttachmentOptions.append(contentsOf: aiOptionsClosure)
        }else{
            aiAttachmentOptions.append(contentsOf: ChatConfigurator.getDataSource().getAIOptions(controller: controller!, user: viewModel.user, group: viewModel.group, id: getId(), aiOptionsStyle: aiOptionsStyle) ?? [CometChatMessageComposerAction]())
        }
        
        var actionItems = [ActionItem]()
        if !aiAttachmentOptions.isEmpty {
            for  options in aiAttachmentOptions {
                let actionItem = ActionItem(id: options.id ?? "", text: options.text ?? "", leadingIcon: options.startIcon, onActionClick: options.onActionClick)
                actionItems.append(actionItem)
            }
        }
        self.controller?.view.endEditing(true)
        let actionSheet = CometChatActionSheet()
        actionSheet.actionSheetDelegate = self
        actionSheet.set(actionItems: actionItems)
        if #available(iOS 15.0, *) {
            if let sheetController = actionSheet.sheetPresentationController {
                sheetController.detents = [.medium()] // Half-sheet height
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return CGFloat(actionItems.count * 56)
                    }
                    sheetController.detents = [customDetent]
                }
                sheetController.largestUndimmedDetentIdentifier = .large
                sheetController.prefersGrabberVisible = true // Optional: shows grabber
            }
            actionSheet.modalPresentationStyle = .pageSheet
            controller?.present(actionSheet, animated: true, completion: nil)
        } else {
            controller?.presentPanModal(actionSheet)
        }
        
    }
}


extension CometChatMessageComposer {
    
    func setupViewModel() {
        
        viewModel.reset  = { [weak self] status in
            guard let this = self else { return }
            this.textView.text = ""
            this.sendButton.isEnabled = false
            this.sendButton.backgroundColor = this.style.inactiveSendButtonImageBackgroundColor
            this.selectedFormatters.removeAll()
            this.endOnGoingTextFormatting()
            this.removeLimitView()
            this.messageComposerMode = .draft
            if !this.messagePreview.isHidden {
                this.hideEditPreview()
            }
        }
        
        viewModel.onMessageEdit = { [weak self] message in
            guard let this = self else { return}
            this.preview(message: message, mode: .edit)
        }
        
        viewModel.isSoundForMessageEnabled = { [weak self]  in
            guard let this = self else { return }
            if !this.disableSoundForMessages {
                CometChatSoundManager().play(sound: .outgoingMessage, customSound: this.customSoundForMessage)
            }
        }
        
    }
}

extension CometChatMessageComposer {
    
    @discardableResult
    public func set(maxLines: Int) -> Self {
        textView.maxLength = maxLines
        return self
    }
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func connect() ->  Self {
        observeKeyboard()
        setupDelegates()
        viewModel.connect()
        CometChatUIEvents.addListener("composer-ui-event-listener-\(listenerRandomId)", self)
        return self
    }
    
    @discardableResult
    public func disconnect() ->  Self {
        removeKeyboard()
        viewModel.disconnect()
        CometChatUIEvents.removeListener("composer-ui-event-listener-\(listenerRandomId)")
        return self
    }
    
    @discardableResult
    public func edit(message: BaseMessage) -> Self {
        if let message = message as? TextMessage {
            self.viewModel.message = message
            self.messageComposerMode = .edit
            
            selectedFormatters.removeAll()
            endOnGoingTextFormatting()
            removeLimitView()
            
            //Processing Message for textFormatters
            var attributedString = NSMutableAttributedString(string: message.text, attributes: [
                .font: style.textFiledFont,
                .foregroundColor: style.textFiledColor
            ])
            for (character, formatter) in viewModel.textFormatterMap {
                let regex = formatter.getRegex()
                let processedString = MessageUtils.processMessageForTextFormatter(attributedString, regex: regex) { regexText in
                    return formatter.prepareMessageString(baseMessage: message, regexString: regexText, formattingType: .COMPOSER)
                }
                selectedFormatters[character] = processedString.1
                attributedString = NSMutableAttributedString(attributedString: processedString.0)
            }
            textView.attributedText = attributedString
            
            presentEditPreview(for: message)
        }
        return self
    }
    
    @discardableResult
    public func reply(message: BaseMessage)  -> Self {
        viewModel.message = message
        self.messageComposerMode = .reply
        UIView.transition(with: messagePreview, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.messagePreview.isHidden = false
        })
        return self
    }
    
    @discardableResult
    public func set(textFormatter: [CometChatTextFormatter]) -> Self {
        viewModel.textFormatter = textFormatter
        return self
    }
    
    @discardableResult
    public func onSuggestionItemClick(onSuggestionItemClick: @escaping ((SuggestionItem) -> Void)) -> Self {
        self.onSuggestionItemClick = onSuggestionItemClick
        return self
    }
    
    @discardableResult
    public func setOnSendButtonClick(onSendButtonClick: @escaping ((BaseMessage) -> Void)) -> Self {
        self.onSendButtonClick = onSendButtonClick
        return self
    }
        
    @discardableResult
    public func setOnSendButtonClick(onSendButtonClick: ((BaseMessage) -> ())?) -> Self {
        self.onSendButtonClick = onSendButtonClick
        return self
    }
    
    @discardableResult
    public func setAttachmentOptions(attachmentOptions: @escaping ((_ user: User?, _ group: Group?, _ controller: UIViewController?) -> [CometChatMessageComposerAction])) -> Self {
        self.attachmentOptionsClosure = attachmentOptions
        return self
    }
    
    @discardableResult
    public func onClickSuggestionListView(suggestionListView: @escaping (() -> (Void))) -> Self {
        self.onClickSuggestionListView = suggestionListView
        return self
    }
    
    @discardableResult
    public func setAIOptions(aiOptionsClosure: @escaping ((_ user: User?, _ group: Group?, _ controller: UIViewController?) -> [CometChatMessageComposerAction])) -> Self {
        self.aiOptionsClosure = aiOptionsClosure
        return self
    }
    
    @discardableResult
    public func set(user: User) -> Self {
        viewModel.set(user: user)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.setupAuxiliaryButton()
            this.viewModel.connect()
        }
        return self
    }
    
    @discardableResult
    public func set(group: Group) -> Self {
        viewModel.set(group: group)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.setupAuxiliaryButton()
            this.viewModel.connect()
        }
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
    public func set(headerView: UIView) -> Self {
        self.headerView.subviews.forEach({ $0.removeFromSuperview() })
        self.headerView.addArrangedSubview(headerView)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.controller?.view.layoutIfNeeded()
        }
        return self
    }
    
    @discardableResult
    public func set(footerView: UIView) -> Self {
        self.footerView.subviews.forEach({ $0.removeFromSuperview() })
        self.footerView.addArrangedSubview(footerView)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.controller?.view.layoutIfNeeded()
        }
        return self
    }
    
    @discardableResult
    public func remove(headerView: Bool) -> Self {
        if headerView {
            self.headerView.subviews.forEach({ $0.removeFromSuperview() })
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.controller?.view.layoutIfNeeded()
            }
        }
        return self
    }
    
    @discardableResult
    public func remove(footerView: Bool) -> Self {
        if footerView {
            self.footerView.subviews.forEach({ $0.removeFromSuperview() })
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.controller?.view.layoutIfNeeded()
            }
        }
        return self
    }
    
    @discardableResult
    public func set(parentMessageId: Int) ->  Self {
        viewModel.parentMessageId = parentMessageId
        return self
    }
    
}


extension CometChatMessageComposer: CometChatUIEventListener {
    
    func isForThisView(id: [String:Any]?) -> Bool {
        guard let id = id , !id.isEmpty else { return false }
        if (id["uid"] != nil && id["uid"] as? String ==
            viewModel.user?.uid) || (id["guid"] != nil && id["guid"] as? String ==
                                      viewModel.group?.guid) {
            
            if (id["parentMessageId"] != nil &&
                id["parentMessageId"] as? Int == viewModel.parentMessageId) {
                return true
            }else if(id["parentMessageId"] == nil && viewModel.parentMessageId == nil ){
                return true;
            }
        }
        return false
    }
    
    public func ccComposeMessage(id: [String : Any]?, message: BaseMessage) {
        if !isForThisView(id: id) { return }
        self.textView.text = (message as? TextMessage)?.text
        self.sendButton.isEnabled = true
        self.sendButton.backgroundColor = style.activeSendButtonImageBackgroundColor
    }
    
    public func showPanel(id: [String : Any]?, alignment: UIAlignment, view: UIView?) {
        if !isForThisView(id: id) { return }
        if let view = view {
            switch alignment {
            case .composerTop:
                set(headerView: view)
            case .composerBottom:
                controller?.view.endEditing(true)
                set(footerView: view)
            case .messageListTop, .messageListBottom: break
            }
        }
    }
    
    public func hidePanel(id: [String : Any]?, alignment: UIAlignment) {
        if !isForThisView(id: id) { return }
        switch alignment {
        case .composerTop:
            remove(headerView: true)
        case .composerBottom:
            remove(footerView: true)
        case .messageListTop, .messageListBottom: break
        }
    }
}

extension CometChatMessageComposer: GrowingTextViewDelegate {
    public func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
      UIView.animate(withDuration: 0.2) { [weak self] in
          self?.controller?.view.layoutIfNeeded()
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
            if let _ = viewModel.user {
                viewModel.sendMediaMessageToUser(url: urls[0].absoluteString, type: .file)
            } else if let _ = viewModel.group {
                viewModel.sendMediaMessageToGroup(url: urls[0].absoluteString, type: .file)
            }
        }
    }
}

class OnGoingTextFormatterModel {
    var range: NSRange
    var textFormatter: CometChatTextFormatter
    
    init(range: NSRange, textFormatter: CometChatTextFormatter) {
        self.range = range
        self.textFormatter = textFormatter
    }
}

public enum MessageComposerMode {
    case draft
    case edit
    case reply
}

public enum AuxilaryButtonAlignment {
    case left
    case right
}
