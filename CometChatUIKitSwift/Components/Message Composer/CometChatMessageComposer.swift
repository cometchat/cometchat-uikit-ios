//
//  CometChatMessageComposer_v5.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 07/10/24.
//

import CometChatSDK
import UIKit

open class CometChatMessageComposer: UIView {
    
    // MARK: - Reply message integration
    private var replyingToMessage: BaseMessage?
    private var quotedMessage: BaseMessage?
    private var quotedPreviewView: CometChatMessagePreview?
    var messagePreviewStyle : MessagePreviewStyle = CometChatMessagePreview.style
    private var originalEditText: String?
    
    public lazy var textView: GrowingTextView = {
        let growingTextView = GrowingTextView().withoutAutoresizingMaskConstraints()
        growingTextView.delegate = self
        growingTextView.placeholder = "COMPOSER_PLACEHOLDER".localize()
        growingTextView.maxHeight = style.textFiledFont.lineHeight * 5
        growingTextView.minHeight = 12
        growingTextView.backgroundColor = .clear
        // COMMENTED OUT - Rich text formatting disabled for MessageComposer
        // growingTextView.onFormatAction = { [weak self] format in
        //     self?.applyFormat(format)
        // }
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
        stackView.alignment = .center
        
        stackView.addArrangedSubview(messagePreview)
        stackView.addArrangedSubview(topContainerView)
        stackView.addArrangedSubview(richTextToolbarContainerView)
        stackView.addArrangedSubview(dividerView)
        stackView.addArrangedSubview(bottomContainerView)
        
        return stackView
    }()
    
    // COMMENTED OUT - Rich text formatting disabled for MessageComposer
    /*
    public lazy var topContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        
        // Add code block background view behind text view
        view.addSubview(codeBlockBackgroundView)
        view.addSubview(textView)
        NSLayoutConstraint.activate([
            // Code block background view (same position as text view but slightly larger for padding)
            codeBlockBackgroundView.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p3 - 4),
            codeBlockBackgroundView.trailingAnchor.pin(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p3 + 4),
            codeBlockBackgroundView.topAnchor.pin(equalTo: view.topAnchor, constant: CometChatSpacing.Padding.p1 - 2),
            codeBlockBackgroundView.bottomAnchor.pin(equalTo: view.bottomAnchor, constant: -CometChatSpacing.Padding.p1 + 2),
            
            textView.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            textView.trailingAnchor.pin(equalTo: view.trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            textView.topAnchor.pin(equalTo: view.topAnchor, constant: CometChatSpacing.Padding.p1),
            textView.bottomAnchor.pin(equalTo: view.bottomAnchor, constant: -CometChatSpacing.Padding.p1),
        ])
        
        return view
    }()
    
    /// Background view for code block mode - provides full-width background
    public lazy var codeBlockBackgroundView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = CometChatTheme.neutralColor300
        view.layer.cornerRadius = 8
        view.isHidden = true
        return view
    }()
    */
    
    // Simplified topContainerView without code block background
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
    
    /// Stub for code block background view (not used)
    public lazy var codeBlockBackgroundView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.isHidden = true
        return view
    }()
    
    public lazy var bottomContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.pin(anchors: [.height], to: 48)
        return view
    }()
    
    // MARK: - Rich Text Toolbar Components (COMMENTED OUT - using CompactMessageComposer only)
    /*
    public lazy var richTextToolbar: CometChatRichTextToolbar = {
        let toolbar = CometChatRichTextToolbar().withoutAutoresizingMaskConstraints()
        toolbar.onFormatSelected = { [weak self] format in
            self?.applyFormat(format)
        }
        return toolbar
    }()
    
    public lazy var richTextToolbarContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.isHidden = true
        return view
    }()
    */
    
    // Stub views to prevent compilation errors
    public lazy var richTextToolbar: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.isHidden = true
        return view
    }()
    
    public lazy var richTextToolbarContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.isHidden = true
        return view
    }()
    
    public lazy var messagePreview: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
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
    
    var stickerButton: StickerAuxiliaryButton?
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
    var onTextChangedListener: ((String) -> ())?
    
    var onError: ((_ error: CometChatException) -> Void)?
    
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
    public var disableMentions: Bool = false {
        didSet {
            if disableMentions == true {
                if let defaultMentions = viewModel.textFormatter.firstIndex(where: { $0.formatterID == "internal_mentions" }) {
                    var mentions = viewModel.textFormatter
                    mentions.remove(at: defaultMentions)
                    viewModel.textFormatter = mentions
                }
            }
        }
    }
    public var hideSendButton = false
    public var hideAIButton = false
    public var attachmentOptions = [CometChatMessageComposerAction]()
    
    var additionalConfiguration = AdditionalConfiguration()
    
    public var hideImageAttachmentOption: Bool = false{
        didSet{
            additionalConfiguration.hideImageAttachmentOption = hideImageAttachmentOption
        }
    }
    public var hideVideoAttachmentOption: Bool = false{
        didSet{
            additionalConfiguration.hideVideoAttachmentOption = hideVideoAttachmentOption
        }
    }
    public var hideFileAttachmentOption: Bool = false{
        didSet{
            additionalConfiguration.hideFileAttachmentOption = hideFileAttachmentOption
        }
    }
    public var hidePollsOption: Bool = false{
        didSet{
            additionalConfiguration.hidePollsOption = hidePollsOption
        }
    }
    public var hideCollaborativeDocumentOption: Bool = false{
        didSet{
            additionalConfiguration.hideCollaborativeDocumentOption = hideCollaborativeDocumentOption
        }
    }
    public var hideCollaborativeWhiteboardOption: Bool = false{
        didSet{
            additionalConfiguration.hideCollaborativeWhiteboardOption = hideCollaborativeWhiteboardOption
        }
    }
    public var hideAttachmentButton: Bool = false
    public var hideVoiceRecordingButton: Bool = false
    public var hideStickersButton: Bool = false
    
    // MARK: - Rich Text Formatting Properties (COMMENTED OUT - using CompactMessageComposer only)
    // public var showRichTextFormattingOptions: Bool = false
    // public var enableRichTextFormatting: Bool = false
    public var showRichTextFormattingOptions: Bool = true  // Keep for API compatibility but always false
    public var enableRichTextFormatting: Bool = true  // Keep for API compatibility but always false
    
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
        setupThemeObserver()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViewModel()
        buildUI()
        setupThemeObserver()
    }
    
    open override var intrinsicContentSize: CGSize {
        let targetSize = CGSize(
            width: bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width,
            height: UIView.layoutFittingCompressedSize.height
        )

        let height = containerView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        ).height

        return CGSize(width: UIView.noIntrinsicMetric, height: height)
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
        // Update send button state which will apply the new theme color
        updateSendButtonState()
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
            connect()
            updateUI()
            updateSendButtonState()
        }else{
            clearReplyState()
            disconnect()
        }
    }
    
    private func clearReplyState() {
        if let message = quotedMessage{
            CometChatMessageEvents.ccReplyToMessage(message: message, status: .error)
        }
        viewModel.quotedMessage = nil
        viewModel.quotedMessageId = nil
        hideReplyPreview()
    }
    
    private func observeStreamingState() {
        CometChatAIStreamService.shared.onStreamingStateChanged = { [weak self] isBusy in
            guard let self = self else { return }
            self.sendButton.isEnabled = !isBusy
            self.sendButton.backgroundColor = isBusy ? self.style.inactiveSendButtonImageBackgroundColor : self.style.activeSendButtonImageBackgroundColor
        }
    }
    
    func updateSendButtonState() {
        let aiBusyButton: UIImage = UIImage(systemName: "stop.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
        let hasText = !(textView.text?.isEmpty ?? true)
        let isAIBusy = CometChatAIStreamService.shared.isAIBusy
        let isAgentic = viewModel.user?.isAgentic ?? false
        
        sendButton.isEnabled = hasText && !isAIBusy
        
        // Set background color based on user type
        if isAgentic {
            sendButton.backgroundColor = sendButton.isEnabled ? style.agenticActiveSendButtonImageBackgroundColor : style.agenticInactiveSendButtonImageBackgroundColor
        } else {
            // In edit mode, disable send when text is unchanged; enable when it changes
            if messageComposerMode == .edit {
                let currentText = textView.text ?? ""
                let unchanged = (currentText == (originalEditText ?? ""))
                sendButton.isEnabled = hasText && !isAIBusy && !unchanged
                sendButton.backgroundColor = sendButton.isEnabled ? style.activeSendButtonImageBackgroundColor : style.inactiveSendButtonImageBackgroundColor
            } else {
                sendButton.backgroundColor = sendButton.isEnabled ? style.activeSendButtonImageBackgroundColor : style.inactiveSendButtonImageBackgroundColor
            }
        }
        
        // Set image based on state and user type
        if !isAIBusy {
            sendButton.setImage(isAgentic ? style.agenticSendButtonImage : style.sendButtonImage, for: .normal)
        } else {
            sendButton.setImage(aiBusyButton, for: .normal)
        }
        
        // Set tint color based on user type
        sendButton.imageView?.tintColor = isAgentic ? style.agenticSendButtonImageTint : style.sendButtonImageTint
    }
    
    private func updateSendButtonForAgenticUser() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            let isAgentic = this.viewModel.user?.isAgentic ?? false
            let isAIBusy = CometChatAIStreamService.shared.isAIBusy
            
            if isAgentic && isAIBusy {
                let aiBusyButton: UIImage = UIImage(systemName: "stop.fill")?.withRenderingMode(.alwaysTemplate) ?? UIImage()
                this.sendButton.setImage(aiBusyButton, for: .normal)
            } else {
                this.sendButton.setImage(this.style.sendButtonImage, for: .normal)
            }
        }
    }
    
    func updateUI(){
        if hideSendButton{
            sendButton.isHidden = true
        }
        if messageComposerMode == .edit {
            viewModel.reset?(true)
        }
        
        if viewModel.user?.isAgentic ?? false{
            secondaryStackView.isHidden = true
            auxiliaryStackView.isHidden = true
            disableMentions = true
            dividerView.isHidden = true
            sendButton.imageView?.translatesAutoresizingMaskIntoConstraints = false
            sendButton.imageView?.widthAnchor.constraint(equalToConstant: 16).isActive = true
            sendButton.imageView?.heightAnchor.constraint(equalToConstant: 16).isActive = true
            sendButton.imageView?.contentMode = .scaleAspectFit
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
        paddingView.addSubview(composerBoxContainerStackView)
        
        containerView.addArrangedSubview(paddingView)
        containerView.addArrangedSubview(footerView)
        
        //building bottom view
        bottomContainerView.addSubview(secondaryStackView)
        constraintsToActivate += [
            secondaryStackView.leadingAnchor.pin(equalTo: bottomContainerView.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            secondaryStackView.trailingAnchor.pin(equalTo: auxiliaryStackView.leadingAnchor, constant: -CometChatSpacing.Padding.p4),
            secondaryStackView.centerYAnchor.pin(equalTo: bottomContainerView.centerYAnchor),
            
            composerBoxContainerStackView.leadingAnchor.pin(equalTo: paddingView.leadingAnchor, constant: CometChatSpacing.Margin.m2),
            composerBoxContainerStackView.trailingAnchor.pin(equalTo: paddingView.trailingAnchor, constant: -CometChatSpacing.Margin.m2),
            composerBoxContainerStackView.topAnchor.pin(equalTo: paddingView.topAnchor, constant: 0),
            
            
            messagePreview.leadingAnchor.pin(equalTo: composerBoxContainerStackView.leadingAnchor, constant: 4),
            messagePreview.trailingAnchor.pin(equalTo: composerBoxContainerStackView.trailingAnchor, constant: -4),
            
            topContainerView.leadingAnchor.pin(equalTo: composerBoxContainerStackView.leadingAnchor),
            topContainerView.trailingAnchor.pin(equalTo: composerBoxContainerStackView.trailingAnchor),
            
            dividerView.leadingAnchor.pin(equalTo: composerBoxContainerStackView.leadingAnchor),
            dividerView.trailingAnchor.pin(equalTo: composerBoxContainerStackView.trailingAnchor),
            
            bottomContainerView.leadingAnchor.pin(equalTo: composerBoxContainerStackView.leadingAnchor),
            bottomContainerView.trailingAnchor.pin(equalTo: composerBoxContainerStackView.trailingAnchor)
        ]
        
        if DeviceType.IS_SMALL_DEVICE {
            composerBoxContainerStackView.bottomAnchor.pin(equalTo: paddingView.bottomAnchor, constant: 0).isActive = true
        } else if DeviceType.IS_BIG_DEVICE {
            composerBoxContainerStackView.bottomAnchor.pin(equalTo: paddingView.bottomAnchor, constant: -CometChatSpacing.Margin.m2).isActive = true
        }
        
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
        
        // Setup rich text toolbar container
        richTextToolbarContainerView.addSubview(richTextToolbar)
        constraintsToActivate += [
            richTextToolbarContainerView.leadingAnchor.pin(equalTo: composerBoxContainerStackView.leadingAnchor),
            richTextToolbarContainerView.trailingAnchor.pin(equalTo: composerBoxContainerStackView.trailingAnchor),
            
            richTextToolbar.topAnchor.pin(equalTo: richTextToolbarContainerView.topAnchor, constant: CometChatSpacing.Padding.p1),
            richTextToolbar.leadingAnchor.pin(equalTo: richTextToolbarContainerView.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            richTextToolbar.trailingAnchor.pin(equalTo: richTextToolbarContainerView.trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            richTextToolbar.bottomAnchor.pin(equalTo: richTextToolbarContainerView.bottomAnchor, constant: -CometChatSpacing.Padding.p2)
        ]
        
        NSLayoutConstraint.activate(constraintsToActivate)
        
        updateSendButtonState()
        
    }
    
    @objc private func handleAIBusyStateChanged() {
        DispatchQueue.main.async { [weak self] in
            self?.updateSendButtonState()
        }
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
        
        // Handle size class changes for iPad flexible window resizing
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass ||
           previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// Handle window size transitions for iPad flexible window resizing
    open func handleWindowSizeTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator?) {
        coordinator?.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }, completion: nil)
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
        textView.typingAttributes = [
            .font: style.textFiledFont,
            .foregroundColor: style.textFiledColor
        ]
        //setting image
        attachmentButton.setImage(style.attachmentImage, for: .normal)
        microphoneButton.setImage(style.voiceRecordingImage, for: .normal)
        aiButton.setImage(style.aiImage, for: .normal)
        
        // Set send button image and tint based on user type
        let isAgentic = viewModel.user?.isAgentic ?? false
        sendButton.setImage(isAgentic ? style.agenticSendButtonImage : style.sendButtonImage, for: .normal)
        sendButton.imageView?.tintColor = isAgentic ? style.agenticSendButtonImageTint : style.sendButtonImageTint
        sendButton.backgroundColor = isAgentic ? style.agenticInactiveSendButtonImageBackgroundColor : style.inactiveSendButtonImageBackgroundColor
        
        microphoneButton.imageView?.tintColor = style.voiceRecordingImageTint
        attachmentButton.imageView?.tintColor = style.attachmentImageTint
        aiButton.imageView?.tintColor = style.aiImageTint
        
        viewModel.textFormatter.forEach({ ($0 as? CometChatMentionsFormatter)?.set(composerTextStyle: mentionStyle) })
        
        if hideAttachmentButton{
            attachmentButton.isHidden = true
        }
        if hideVoiceRecordingButton{
            microphoneButton.isHidden = true
        }
        
        // COMMENTED OUT - Rich text formatting disabled for MessageComposer
        // Rich text toolbar visibility based on showRichTextFormattingOptions property
        // richTextToolbarContainerView.isHidden = !showRichTextFormattingOptions
        // richTextToolbar.isHidden = !showRichTextFormattingOptions
        
        // Also control formatting menu in text selection context menu
        // textView.showFormattingMenu = showRichTextFormattingOptions
        
        // Always hide rich text toolbar in MessageComposer
        richTextToolbarContainerView.isHidden = true
        richTextToolbar.isHidden = true
        textView.showFormattingMenu = false
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
                        stickerButton = button as? StickerAuxiliaryButton
                        button.imageView?.tintColor = style.stickerTint
                        if hideStickersButton{
                            button.isHidden = true
                        }
                    }
                })
                
                ///Checking AI enabled of not
                let aiOptionsList = ChatConfigurator.getDataSource().getAIOptions(controller: controller ?? UIViewController(), user: viewModel.user, group: viewModel.group, id: getId(), aiOptionsStyle: aiOptionsStyle)
                if let aiOptionsList = aiOptionsList, !aiOptionsList.isEmpty && !hideAIButton && (viewModel.parentMessageId ?? 0) == 0 {
                    auxiliaryOptions.addArrangedSubview(aiButton)
                }
                
                if auxiliaryButtonsAlignment == .right {
                    auxiliaryOptions.insertArrangedSubview(UIView(), at: 0)
                } else if auxiliaryButtonsAlignment == .left {
                    auxiliaryOptions.addArrangedSubview(UIView())
                }
                if let auxilaryButtonView = auxilaryButtonView?(viewModel.user, viewModel.group){
                    auxiliaryStackView.embed(auxilaryButtonView)
                }else{
                    auxiliaryStackView.embed(auxiliaryOptions)
                }
            }
        }
    }
    
    @objc open func didMicrophoneButtonClicked() {
        controller?.view.endEditing(true)
        CometChatUIEvents.hidePanel(id: getId(), alignment: .composerBottom)
        let cometChatMediaRecorder = CometChatMediaRecorder()
        cometChatMediaRecorder.style = mediaRecorderStyle
        if let user = viewModel.user {
            cometChatMediaRecorder.viewModel = MediaRecorderViewModel(user: user)
        } else if let group = viewModel.group {
            cometChatMediaRecorder.viewModel = MediaRecorderViewModel(group: group)
        }
        cometChatMediaRecorder.setSubmit(onSubmit: {url, duration in
            if self.onSendButtonClick != nil {
                self.onSendButtonClick?(self.viewModel.setupBaseMessage(url: url))
                self.viewModel.reset?(true)
            } else {
                if self.viewModel.user != nil {
                    self.viewModel.sendMediaMessageToUser(url: url, type: .audio, audioDuration: duration)
                } else {
                    self.viewModel.sendMediaMessageToGroup(url: url, type: .audio, audioDuration: duration)
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
            controller?.presentWithInheritedInterfaceStyle(cometChatMediaRecorder)
        } else {
            controller?.presentPanModal(cometChatMediaRecorder)
        }
    }
    
    @objc open func didSendButtonClicked() {
        let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackLight.impactOccurred()
        
        if let onSendButtonClick = onSendButtonClick {
            // COMMENTED OUT - Rich text formatting disabled for MessageComposer
            // Convert attributed text to markdown if rich text formatting is enabled
            // let messageText: String
            // if enableRichTextFormatting, let attributedText = textView.attributedText {
            //     messageText = RichTextFormatterManager.shared.convertToMarkdown(attributedText)
            // } else {
            //     messageText = textView.text ?? ""
            // }
            let messageText = textView.text ?? ""
            
            if !messageText.isEmpty {
                let message = viewModel.setupBaseMessage(message: messageText, textFormatter: selectedFormatters)
                onSendButtonClick(message)
                viewModel.reset?(true)
            }
        } else {
            if viewModel.user?.isAgentic ?? false{
                CometChatAIStreamService.shared.isAIBusy = true
            }
            updateSendButtonState()
            didDefaultSendButtonClicked()
        }
    }
    
    open func didDefaultSendButtonClicked() {
        // COMMENTED OUT - Rich text formatting disabled for MessageComposer
        // Convert attributed text to markdown if rich text formatting is enabled
        // let messageText: String
        // if enableRichTextFormatting, let attributedText = textView.attributedText {
        //     messageText = RichTextFormatterManager.shared.convertToMarkdown(attributedText)
        // } else {
        //     messageText = textView.text ?? ""
        // }
        let messageText = textView.text ?? ""
        
        switch messageComposerMode {
        case .draft:
            if let _ = viewModel.user, !messageText.isEmpty {
                viewModel.sendTextMessageToUser(message: messageText, textFormatter: selectedFormatters)
            } else if let _ = viewModel.group, !messageText.isEmpty {
                viewModel.sendTextMessageToGroup(message: messageText, textFormatter: selectedFormatters)
            }
        case .edit:
            if let currentMessage = self.viewModel.message as? TextMessage, !messageText.isEmpty {
                viewModel.editTextMessage(textMessage: currentMessage, message: messageText, textFormatter: selectedFormatters)
            }
        case .reply: break
            
        }
        viewModel.quotedMessage = nil
    }
    
    ///Setup Delegates
    internal func setupDelegates() {
        documentPicker.delegate = self
    }
    
    deinit {
        disconnect()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("AIBusyStateChanged"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("CometChatThemeChanged"), object: nil)
    }
    
    private func getId() -> [String: Any] {
        var id = [String:Any]()
        
        if let user = viewModel.user {
            id["uid"] = user.uid
        }
        if let group = viewModel.group {
            id["guid"] = group.guid
        }
        if let parentMessageId = viewModel.parentMessageId, parentMessageId > 0 {
            id["parentMessageId"] = parentMessageId
        }
        
        return id
    }
    
    open func presentEditPreview(for message: BaseMessage) {
        let isAgentic = viewModel.user?.isAgentic ?? false
        
        self.sendButton.isEnabled = true
        self.sendButton.backgroundColor = isAgentic ? style.agenticActiveSendButtonImageBackgroundColor : style.activeSendButtonImageBackgroundColor
        
        if let textMessage = message as? TextMessage {
            let formattedText = MessageUtils.processTextFormatter(message: textMessage, textFormatter: viewModel.textFormatter, formattingType: .COMPOSER)
            let editPreviewView = MessagePreviewView(title: "EDIT_MESSAGE".localize(), subTitle: formattedText, style: style)
            messagePreview.subviews.forEach({ $0.removeFromSuperview() })
            messagePreview.isHidden = false
            messagePreview.addArrangedSubview(editPreviewView)
            editPreviewView.topAnchor.constraint(equalTo: messagePreview.topAnchor, constant: 4).isActive = true
            editPreviewView.layoutIfNeeded()
            editPreviewView.onCrossIconClicked = { [weak self] in
                self?.hideEditPreview()
            }
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.controller?.view.layoutIfNeeded()
            }
        }
        updateSendButtonState()
    }
    
    open func hideEditPreview() {
        messageComposerMode = .draft
        originalEditText = nil
        textView.text = ""
        selectedFormatters.removeAll()
        removeLimitView()
        messagePreview.subviews.forEach({ $0.removeFromSuperview() })
        messagePreview.isHidden = true
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.controller?.view.layoutIfNeeded()
        }
    }
    
}

//MARK: Keyboard event
extension CometChatMessageComposer {
    
    func removeKeyboard() {
        NotificationCenter.default.removeObserver(UIResponder.keyboardWillChangeFrameNotification)
    }
    
    func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        CometChatUIEvents.hidePanel(id: getId(), alignment: .composerBottom)
        if textView.isFirstResponder {
            if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                // Convert keyboard frame to view's coordinate space for iPad flexible window support
                let keyboardHeight = calculateKeyboardHeight(from: endFrame)
                let animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double) ?? 0.2
                
                if keyboardHeight > 0 {
                    bottomConstant.constant = -keyboardHeight - CometChatSpacing.Margin.m2
                    UIView.animate(withDuration: animationDuration) {
                        self.superview?.layoutIfNeeded()
                    }
                    
                } else {
                    bottomConstant.constant = -CometChatSpacing.Margin.m8
                    UIView.animate(withDuration: animationDuration) {
                        self.superview?.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    /// Calculate keyboard height accounting for iPad flexible window positioning
    /// - Parameter keyboardFrame: The keyboard frame in screen coordinates
    /// - Returns: The effective keyboard height relative to this view's window
    private func calculateKeyboardHeight(from keyboardFrame: CGRect) -> CGFloat {
        guard let window = self.window else {
            // Fallback to screen-based calculation if no window
            return UIScreen.main.bounds.height - keyboardFrame.origin.y
        }
        
        // Convert keyboard frame from screen coordinates to window coordinates
        let keyboardFrameInWindow = window.convert(keyboardFrame, from: nil)
        
        // Get the view's frame in window coordinates
        let viewFrameInWindow = self.convert(self.bounds, to: window)
        
        // Calculate how much the keyboard overlaps with the view's window
        let windowHeight = window.bounds.height
        let keyboardTopInWindow = keyboardFrameInWindow.origin.y
        
        // If keyboard is below the window (not visible), return 0
        if keyboardTopInWindow >= windowHeight {
            return 0
        }
        
        // Calculate the keyboard height relative to the window bottom
        // This accounts for iPad flexible window positioning where the window
        // may not extend to the bottom of the screen
        let keyboardHeightInWindow = windowHeight - keyboardTopInWindow
        
        // Ensure we don't return negative values
        return max(0, keyboardHeightInWindow)
    }
    
    @objc func attachmentButtonClicked() {
        CometChatUIEvents.hidePanel(id: getId(), alignment: .composerBottom)
        let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackLight.impactOccurred()
        attachmentOptions = [CometChatMessageComposerAction]()
        
        if let attachmentOption = attachmentOptionsClosure?(viewModel.user, viewModel.group, controller) {
            attachmentOptions.append(contentsOf: attachmentOption)
        } else {
            attachmentOptions.append(contentsOf: ChatConfigurator.getDataSource().getAttachmentOptions(controller: controller!, user: viewModel.user, group: viewModel.group, id: getId(), additionalConfiguration: additionalConfiguration) ?? MessageUtils.getDefaultAttachmentOptions(addtionalConfiguration: additionalConfiguration))
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
            controller?.presentWithInheritedInterfaceStyle(actionSheet)
        } else {
            controller?.presentPanModal(actionSheet)
        }
        
    }
    
    @objc func didAIButtonClicked() {
        CometChatUIEvents.hidePanel(id: getId(), alignment: .composerBottom)
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
            controller?.presentWithInheritedInterfaceStyle(actionSheet)
        } else {
            controller?.presentPanModal(actionSheet)
        }
        
    }
}

extension CometChatMessageComposer {
    
    @discardableResult
    public func connect() ->  Self {
        observeKeyboard()
        setupDelegates()
        viewModel.connect()
        CometChatUIEvents.addListener("composer-ui-event-listener-\(listenerRandomId)", self)
        if viewModel.user?.isAgentic ?? false {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(handleAIBusyStateChanged),
                name: NSNotification.Name("AIBusyStateChanged"),
                object: nil
            )
        }
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
            
            // Parse markdown text to attributed string for editing
            // This ensures that when editing a message, the formatted text is shown
            // instead of raw markdown (e.g., **bold** shows as bold text)
            var attributedString: NSMutableAttributedString
            if enableRichTextFormatting && RichTextFormatterManager.shared.containsMarkdownFormatting(message.text) {
                // Parse the markdown to create formatted attributed string
                attributedString = NSMutableAttributedString(
                    attributedString: RichTextFormatterManager.shared.parseMarkdown(
                        message.text,
                        baseFont: style.textFiledFont,
                        baseColor: style.textFiledColor,
                        addNewlinesAroundCodeBlocks: false
                    )
                )
            } else {
                // No markdown formatting, use plain text
                attributedString = NSMutableAttributedString(string: message.text, attributes: [
                    .font: style.textFiledFont,
                    .foregroundColor: style.textFiledColor
                ])
            }
            
            // Processing Message for textFormatters (mentions, etc.)
            for (character, formatter) in viewModel.textFormatterMap {
                let regex = formatter.getRegex()
                let processedString = MessageUtils.processMessageForTextFormatter(attributedString, regex: regex) { regexText in
                    return formatter.prepareMessageString(baseMessage: message, regexString: regexText, formattingType: .COMPOSER)
                }
                selectedFormatters[character] = processedString.1
                attributedString = NSMutableAttributedString(attributedString: processedString.0)
            }
            textView.attributedText = attributedString
            
            // Store the displayed text (after formatting) for comparison
            self.originalEditText = textView.text
            
            updateSendButtonState()
            
            // Check if the message being edited already has 10 or more mentions
            // If so, show the limit view to prevent adding more
            if getUniqueSelectedTextFormatterCount() >= 10 {
                addLimitView()
            }
            
            presentEditPreview(for: message)
        }
        return self
    }
}

extension CometChatMessageComposer {
    // MARK: - Reply Preview Handling

    func showReplyPreview(for message: BaseMessage) {
        
        replyingToMessage = message
        viewModel.quotedMessage = message
        // inside showReplyPreview(for:)
        let isUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)

        let preview = CometChatMessagePreview.makePreview(
            for: message,
            isLoggedInUser: isUser,
            textFormatters: viewModel.textFormatter,       // composer uses viewModel.textFormatter
            formattingType: .COMPOSER,
            style: messagePreviewStyle,
            onPreviewClicked: nil,
            onCrossClicked: { [weak self] in
                CometChatMessageEvents.ccReplyToMessage(message: message, status: .error)
                self?.viewModel.quotedMessage = nil
                self?.hideReplyPreview()
            },
            hideCloseButton: false
        )

        // Replace existing arranged subviews, add preview (like before)
        messagePreview.arrangedSubviews.forEach { $0.removeFromSuperview() }
        messagePreview.addArrangedSubview(preview)
        preview.topAnchor.constraint(equalTo: messagePreview.topAnchor, constant: 4).isActive = true
        messagePreview.isHidden = false

        // Update ViewModel bits as before
        viewModel.quotedMessageId = message.id
        textView.becomeFirstResponder()
    }

    func hideReplyPreview() {
        messagePreview.arrangedSubviews.forEach { $0.removeFromSuperview() }
        messagePreview.isHidden = true
        replyingToMessage = nil
        viewModel.quotedMessageId = nil
        textView.resignFirstResponder()
    }

}


extension CometChatMessageComposer {
    
    func setupViewModel() {
        
        viewModel.reset  = { [weak self] status in
            guard let this = self else { return }
            this.textView.text = ""
            this.sendButton.isEnabled = false
            
            let isAgentic = this.viewModel.user?.isAgentic ?? false
            this.sendButton.backgroundColor = isAgentic ? this.style.agenticInactiveSendButtonImageBackgroundColor : this.style.inactiveSendButtonImageBackgroundColor
            
            this.selectedFormatters.removeAll()
            this.endOnGoingTextFormatting()
            this.removeLimitView()
            this.messageComposerMode = .draft
            this.originalEditText = nil
            if !this.messagePreview.isHidden {
                this.hideEditPreview()
            }
            this.updateSendButtonState()
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
        
        viewModel.failure = { [weak self] error in
            self?.onError?(error)
        }
        
        viewModel.showReplyView = { [weak self] message in
            guard let this = self else { return }
            this.quotedMessage = message
            this.showReplyPreview(for: message)
        }
        
        viewModel.hideReplyView = { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                this.hideReplyPreview()
            }
        }
    }
}


extension CometChatMessageComposer: CometChatUIEventListener {
    
    func isForThisView(id: [String: Any]?) -> Bool {
        guard let id = id, !id.isEmpty else { return false }
        
        let isUserMatch = (id["uid"] as? String) == viewModel.user?.uid
        let isGroupMatch = (id["guid"] as? String) == viewModel.group?.guid
        let isParentMessageMatch = (id["parentMessageId"] as? Int) == viewModel.parentMessageId
        
        if isUserMatch || isGroupMatch {
            if let parentMessageId = id["parentMessageId"] as? Int {
                return parentMessageId == viewModel.parentMessageId
            } else {
                return viewModel.parentMessageId == nil
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
        if !isForThisView(id: id) {
            return
        }
        if let view = view {
            switch alignment {
            case .composerTop:
                set(headerView: view)
            case .composerBottom:
                controller?.view.endEditing(true)
                set(footerView: view)
                break
            case .messageListTop, .messageListBottom: break
            }
        }
    }
    
    public func hidePanel(id: [String : Any]?, alignment: UIAlignment) {
        if !isForThisView(id: id) { return }
        switch alignment {
        case .composerTop:
            remove(headerView: true)
            break
        case .composerBottom:
            remove(footerView: true)
            stickerButton?.resetToDefaultStyle()
            break
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
