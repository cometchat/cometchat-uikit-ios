//
//  CometChatCompactMessageComposer.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 29/01/26.
//

import UIKit
import CometChatSDK

/// A compact message composer with rich text formatting support
open class CometChatCompactMessageComposer: UIView {
    
    // MARK: - UI Components
    
    public lazy var textView: GrowingTextView = {
        let textView = GrowingTextView().withoutAutoresizingMaskConstraints()
        textView.delegate = self
        textView.placeholder = "COMPOSER_PLACEHOLDER".localize()
        textView.maxHeight = style.textFieldFont.lineHeight * 5
        textView.minHeight = style.textFieldFont.lineHeight + 16  // Ensure minimum height includes line height plus padding
        textView.backgroundColor = .clear
        textView.onFormatAction = { [weak self] format in
            self?.handleFormatSelected(format)
        }
        textView.getActiveFormats = { [weak self] in
            guard let self = self else { return [] }
            guard let attributedText = self.textView.attributedText else { return [] }
            let range = self.textView.selectedRange
            return RichTextFormatterManager.shared.detectActiveFormats(in: attributedText, at: range)
        }
        textView.onDeleteBackward = { [weak self] in
            self?.handleDeleteBackward()
        }
        return textView
    }()
    
    /// Background view for code block mode - provides full-width background
    public lazy var codeBlockBackgroundView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = UIColor(hex: "#FAFAFA")
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor(hex: "#E8E8E8").cgColor
        view.isHidden = true
        return view
    }()
    
    /// Left border view for code block mode - hidden (no purple border)
    public lazy var codeBlockLeftBorderView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = .clear  // No visible border
        view.isHidden = true  // Always hidden
        return view
    }()
    
    /// Placeholder label for code block mode
    public lazy var codeBlockPlaceholderLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        label.text = ""  // Empty placeholder - no text shown
        label.textColor = CometChatTheme.textColorTertiary
        label.font = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        label.isHidden = true
        return label
    }()
    
    /// Left bar view for blockquote mode - Slack-style vertical bar
    public lazy var blockquoteBarView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = CometChatTheme.primaryColor
        view.layer.cornerRadius = 2
        view.isHidden = true
        return view
    }()
    
    public lazy var containerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.backgroundColor = .clear
        return stackView
    }()
    
    public lazy var composerBoxContainerStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .fill
        return stackView
    }()
    
    /// Single line container that holds attachment button, text field, and action buttons
    public lazy var singleLineContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        return view
    }()
    
    public lazy var messagePreview: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.isHidden = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: CometChatSpacing.Padding.p2,
            left: CometChatSpacing.Padding.p1,
            bottom: 0,
            right: CometChatSpacing.Padding.p1
        )
        return stackView
    }()
    
    public lazy var suggestionContainerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(
            top: CometChatSpacing.Spacing.s1,
            left: CometChatSpacing.Spacing.s2,
            bottom: CometChatSpacing.Spacing.s1,
            right: CometChatSpacing.Spacing.s2
        )
        return stackView
    }()
    
    /// Footer view for sticker keyboard and other panels
    public lazy var footerView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        return stackView
    }()
    
    // MARK: - Rich Text Toolbar
    
    public lazy var richTextToolbar: CometChatRichTextToolbar = {
        let toolbar = CometChatRichTextToolbar().withoutAutoresizingMaskConstraints()
        toolbar.isHidden = true
        toolbar.onFormatSelected = { [weak self] format in
            self?.handleFormatSelected(format)
        }
        return toolbar
    }()
    
    public lazy var richTextToolbarContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.isHidden = true
        return view
    }()
    
    // MARK: - Buttons
    
    public lazy var sendButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didSendButtonClicked), for: .primaryActionTriggered)
        button.pin(anchors: [.height, .width], to: 32)
        button.roundViewCorners(corner: .init(cornerRadius: 16))
        button.accessibilityLabel = "Send"
        return button
    }()
    
    public lazy var attachmentButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(attachmentButtonClicked), for: .primaryActionTriggered)
        button.pin(anchors: [.height, .width], to: 24)
        button.accessibilityLabel = "Attachment"
        return button
    }()
    
    public lazy var microphoneButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didMicrophoneButtonClicked), for: .primaryActionTriggered)
        button.pin(anchors: [.height, .width], to: 24)
        button.accessibilityLabel = "Voice Recording"
        return button
    }()
    
    public lazy var stickersButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(didStickersButtonClicked), for: .primaryActionTriggered)
        button.pin(anchors: [.height, .width], to: 24)
        button.accessibilityLabel = "Stickers"
        return button
    }()
    
    public lazy var secondaryStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.spacing = CometChatSpacing.Padding.p3
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    public lazy var primaryStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.spacing = CometChatSpacing.Padding.p3
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    /// Stack view containing attachment button and text view - allows proper hiding of attachment button
    public lazy var leftContentStackView: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.spacing = 12  // 12px spacing between attachment button and text view
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    /// Container for text view and code block background
    public lazy var textViewContainer: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = .clear
        view.clipsToBounds = true  // Clip code block background when scrolling
        return view
    }()

    // MARK: - Style Properties
    
    public static var style = CompactMessageComposerStyle()
    public lazy var style = CometChatCompactMessageComposer.style
    
    public static var mediaRecorderStyle = CometChatMediaRecorder.style
    public lazy var mediaRecorderStyle = CometChatCompactMessageComposer.mediaRecorderStyle
    
    public static var attachmentSheetStyle = CometChatActionSheet.style
    public lazy var attachmentSheetStyle = CometChatCompactMessageComposer.attachmentSheetStyle
    
    // MARK: - Callbacks
    
    public var onSendButtonClick: ((BaseMessage) -> Void)?
    public var onError: ((_ error: CometChatException) -> Void)?
    public var onTextChangedListener: ((String) -> ())?
    public var attachmentOptionsClosure: ((_ user: User?, _ group: Group?, _ controller: UIViewController?) -> [CometChatMessageComposerAction])?
    
    // MARK: - Configuration Properties
    
    public var viewModel = CompactMessageComposerViewModel()
    public var placeholderText: String = "TYPE_A_MESSAGE".localize()
    public var disableSoundForMessages = false
    public var customSoundForMessage: URL?
    public var disableTypingEvents = false
    public var disableMentions: Bool = false
    public var composerState: ComposerState = .draft
    
    // MARK: - Visibility Properties
    
    public var hideAttachmentButton: Bool = false
    public var hideVoiceRecordingButton: Bool = false
    public var showRichTextFormattingOptions: Bool = true
    public var enableRichTextFormatting: Bool = true
    public var hideSendButton: Bool = false
    public var hideStickersButton: Bool = false
    
    // MARK: - Inline Voice Recorder
    
    public static var inlineVoiceRecorderStyle = CometChatInlineVoiceRecorder.style
    public lazy var inlineVoiceRecorderStyle = CometChatCompactMessageComposer.inlineVoiceRecorderStyle
    
    private var inlineVoiceRecorder: CometChatInlineVoiceRecorder?
    private var isVoiceRecorderShown: Bool = false
    
    // MARK: - Code Block Background Tracking
    
    /// Constraints for the code block background view (used when in full code block mode)
    internal var codeBlockBackgroundConstraints: [NSLayoutConstraint] = []
    
    /// Constraints for the code block left border view
    internal var codeBlockLeftBorderConstraints: [NSLayoutConstraint] = []
    
    /// Range of the code block text (used to position background after exiting code block mode)
    internal var codeBlockTextRange: NSRange?
    
    /// Start position of code block content (used to position background after blockquote content)
    internal var codeBlockStartPosition: Int?
    
    /// Minimum height for code block background (prevents shrinking when typing)
    internal var codeBlockMinimumHeight: CGFloat = 0
    
    /// Original minHeight of textView before code block mode (used to restore when exiting)
    internal var originalTextViewMinHeight: CGFloat?
    
    // MARK: - Blockquote Bar Tracking
    
    /// Constraints for the blockquote bar view (used when in full blockquote mode)
    internal var blockquoteBarConstraints: [NSLayoutConstraint] = []
    
    /// Start position of blockquote content (used to position bar after code block content)
    internal var blockquoteStartPosition: Int?
    
    /// Range of the blockquote text (used to position bar after exiting blockquote mode)
    internal var blockquoteTextRange: NSRange?
    
    // MARK: - Internal Properties
    
    internal var typingWorkItem: DispatchWorkItem?
    internal var suggestionView: CometChatSuggestionView?
    internal var isSuggestionLimitExceeded = false
    internal var ongoingTextFormatter: OnGoingTextFormatterModel?
    internal var selectedFormatters = [Character: [(item: SuggestionItem, range: NSRange)]]()
    internal weak var controller: UIViewController?
    internal var listenerRandomId = Date().timeIntervalSince1970
    internal var originalEditText: String?
    internal var isStickerKeyboardShown = false
    
    /// Flag to skip cursor adjustment when programmatically setting cursor position
    internal var isSettingCursorProgrammatically = false
    
    /// Flag to prevent code block background from being re-expanded during exit
    internal var isExitingCodeBlock = false
    
    internal let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    
    /// Bottom constraint for keyboard handling
    public var bottomConstant: NSLayoutConstraint!
    
    // MARK: - Initialization
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupViewModel()
        buildUI()
        handleThemeModeChange()
        setupThemeObserver()
        observeKeyboard()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViewModel()
        buildUI()
        setupThemeObserver()
        observeKeyboard()
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
    
    // MARK: - Lifecycle
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            setupStyle()
            connect()
            updateUI()
            updateSendButtonState()
            
            // Reset rich text formatting state when composer appears
            // This ensures formatting options don't persist from previous sessions
            resetRichTextFormattingState()
        } else {
            clearReplyState()
            disconnect()
        }
    }
    
    /// Resets all rich text formatting state to default
    /// Called when the composer appears to ensure a fresh start
    private func resetRichTextFormattingState() {
        // Reset the formatter manager's persistent state
        RichTextFormatterManager.shared.resetListMode()
        
        // Reset the toolbar's active format buttons
        richTextToolbar.setActiveFormats([])
        richTextToolbar.enableAllButtons()
        
        // Reset text view typing attributes to default (no formatting)
        textView.typingAttributes = [
            .font: style.textFieldFont,
            .foregroundColor: style.textFieldColor
        ]
        
        // Restore the text view placeholder
        textView.hidePlaceholder = false
        
        // Reset code block state
        resetCodeBlockBackgroundToFullMode()
        codeBlockBackgroundView.isHidden = true
        codeBlockLeftBorderView.isHidden = true
        codeBlockTextRange = nil
        codeBlockStartPosition = nil
        codeBlockMinimumHeight = 0  // Reset minimum height
        centerTextInCodeBlock()  // Reset text container inset
        
        // Reset blockquote state
        resetBlockquoteBarToFullMode()
        blockquoteBarView.isHidden = true
        blockquoteTextRange = nil
        blockquoteStartPosition = nil
    }
    
    // MARK: - Setup Methods
    
    private func setupViewModel() {
        viewModel.reset = { [weak self] _ in
            self?.resetComposer()
        }
        viewModel.failure = { [weak self] error in
            self?.onError?(error)
        }
        viewModel.showReplyView = { [weak self] message in
            self?.showReplyPreview(for: message)
        }
        viewModel.hideReplyView = { [weak self] in
            self?.hideReplyPreview()
        }
        viewModel.isSoundForMessageEnabled = { [weak self] in
            self?.playMessageSound()
        }
        viewModel.onMessageEdit = { [weak self] message in
            guard let this = self else { return }
            this.preview(message: message, mode: .edit)
        }
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
        updateSendButtonState()
    }
    
    open func handleThemeModeChange() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (self: Self, _: UITraitCollection) in
                self.setupStyle()
            }
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            setupStyle()
        }
    }
    
    // MARK: - Connection
    
    func connect() {
        viewModel.connect()
        CometChatUIEvents.addListener("compact-message-composer-ui-event-listener-\(listenerRandomId)", self)
    }
    
    func disconnect() {
        viewModel.disconnect()
        CometChatUIEvents.removeListener("compact-message-composer-ui-event-listener-\(listenerRandomId)")
    }

    // MARK: - Build UI
    
    open func buildUI() {
        var constraintsToActivate = [NSLayoutConstraint]()
        
        // Setting Container View with margins
        addSubview(containerView)
        bottomConstant = containerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -CometChatSpacing.Margin.m8)
        constraintsToActivate += [
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomConstant
        ]
        
        containerView.addArrangedSubview(suggestionContainerView)
        
        let paddingView = UIView().withoutAutoresizingMaskConstraints()
        paddingView.addSubview(composerBoxContainerStackView)
        containerView.addArrangedSubview(paddingView)
        
        // Add footer view for sticker keyboard
        containerView.addArrangedSubview(footerView)
        
        // Build composer box - vertical stack: messagePreview -> singleLineContainer -> richTextToolbar
        composerBoxContainerStackView.addArrangedSubview(messagePreview)
        composerBoxContainerStackView.addArrangedSubview(singleLineContainerView)
        composerBoxContainerStackView.addArrangedSubview(richTextToolbarContainerView)
        
        // Setup rich text toolbar container
        richTextToolbarContainerView.addSubview(richTextToolbar)
        constraintsToActivate += [
            richTextToolbar.topAnchor.constraint(equalTo: richTextToolbarContainerView.topAnchor),
            richTextToolbar.leadingAnchor.constraint(equalTo: richTextToolbarContainerView.leadingAnchor),
            richTextToolbar.trailingAnchor.constraint(equalTo: richTextToolbarContainerView.trailingAnchor),
            richTextToolbar.bottomAnchor.constraint(equalTo: richTextToolbarContainerView.bottomAnchor)
        ]
        
        // Setup single line container - horizontal layout using stack views
        // Left side: [attachment] [textViewContainer] in leftContentStackView
        // Right side: [secondaryStackView] [sendButton]
        
        // Setup text view container with code block background and blockquote bar
        textViewContainer.addSubview(codeBlockBackgroundView)
        textViewContainer.addSubview(codeBlockLeftBorderView)
        textViewContainer.addSubview(blockquoteBarView)
        textViewContainer.addSubview(textView)
        textViewContainer.addSubview(codeBlockPlaceholderLabel)
        
        constraintsToActivate += [
            // Code block background view (same position as text view but slightly larger for padding)
            // These constraints are stored so we can deactivate them when switching to frame-based positioning
        ]
        
        // Code block placeholder label constraints - positioned same as text view content
        constraintsToActivate += [
            codeBlockPlaceholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
            codeBlockPlaceholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8)
        ]
        
        // Store code block background constraints separately so we can manage them
        // These constraints make the code block background fill the text view container
        codeBlockBackgroundConstraints = [
            codeBlockBackgroundView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor),
            codeBlockBackgroundView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor),
            codeBlockBackgroundView.topAnchor.constraint(equalTo: textViewContainer.topAnchor),
            codeBlockBackgroundView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor)
        ]
        NSLayoutConstraint.activate(codeBlockBackgroundConstraints)
        
        // Code block left border constraints - purple vertical bar on the left edge of code block
        codeBlockLeftBorderConstraints = [
            codeBlockLeftBorderView.leadingAnchor.constraint(equalTo: codeBlockBackgroundView.leadingAnchor),
            codeBlockLeftBorderView.topAnchor.constraint(equalTo: codeBlockBackgroundView.topAnchor),
            codeBlockLeftBorderView.bottomAnchor.constraint(equalTo: codeBlockBackgroundView.bottomAnchor),
            codeBlockLeftBorderView.widthAnchor.constraint(equalToConstant: 3)
        ]
        NSLayoutConstraint.activate(codeBlockLeftBorderConstraints)
        
        // Blockquote bar constraints - vertical bar on the left that stretches full height
        // Store these constraints so we can deactivate them when switching to frame-based positioning
        blockquoteBarConstraints = [
            blockquoteBarView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor, constant: -2),
            blockquoteBarView.topAnchor.constraint(equalTo: textViewContainer.topAnchor, constant: 2),
            blockquoteBarView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor, constant: -2),
            blockquoteBarView.widthAnchor.constraint(equalToConstant: 4)
        ]
        NSLayoutConstraint.activate(blockquoteBarConstraints)
        
        constraintsToActivate += [
            // Text view fills the container
            textView.leadingAnchor.constraint(equalTo: textViewContainer.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: textViewContainer.trailingAnchor),
            textView.topAnchor.constraint(equalTo: textViewContainer.topAnchor),
            textView.bottomAnchor.constraint(equalTo: textViewContainer.bottomAnchor)
        ]
        
        // Build left content stack: [attachment] [textViewContainer]
        leftContentStackView.addArrangedSubview(attachmentButton)
        leftContentStackView.addArrangedSubview(textViewContainer)
        
        // Set text view container to fill available space
        textViewContainer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textViewContainer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Add components to single line container
        singleLineContainerView.addSubview(leftContentStackView)
        singleLineContainerView.addSubview(secondaryStackView)
        singleLineContainerView.addSubview(sendButton)
        
        // Secondary stack contains: stickers, microphone
        secondaryStackView.addArrangedSubview(stickersButton)
        secondaryStackView.addArrangedSubview(microphoneButton)
        
        constraintsToActivate += [
            // Single line container height
            singleLineContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            
            // Left content stack (attachment + textView)
            leftContentStackView.leadingAnchor.constraint(equalTo: singleLineContainerView.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            leftContentStackView.trailingAnchor.constraint(equalTo: secondaryStackView.leadingAnchor, constant: -12),  // 12px spacing to sticker button
            leftContentStackView.topAnchor.constraint(equalTo: singleLineContainerView.topAnchor, constant: CometChatSpacing.Padding.p2),
            leftContentStackView.bottomAnchor.constraint(equalTo: singleLineContainerView.bottomAnchor, constant: -CometChatSpacing.Padding.p2),
            
            // Secondary stack (stickers + mic) 
            secondaryStackView.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -CometChatSpacing.Padding.p3),
            secondaryStackView.centerYAnchor.constraint(equalTo: singleLineContainerView.centerYAnchor),
            
            // Send button on the right
            sendButton.trailingAnchor.constraint(equalTo: singleLineContainerView.trailingAnchor, constant: -CometChatSpacing.Padding.p3),
            sendButton.centerYAnchor.constraint(equalTo: singleLineContainerView.centerYAnchor)
        ]
        
        // Setup constraints for composer box
        constraintsToActivate += [
            composerBoxContainerStackView.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor, constant: CometChatSpacing.Margin.m2),
            composerBoxContainerStackView.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor, constant: -CometChatSpacing.Margin.m2),
            composerBoxContainerStackView.topAnchor.constraint(equalTo: paddingView.topAnchor),
            composerBoxContainerStackView.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor, constant: -CometChatSpacing.Margin.m2),
            
            richTextToolbarContainerView.leadingAnchor.constraint(equalTo: composerBoxContainerStackView.leadingAnchor),
            richTextToolbarContainerView.trailingAnchor.constraint(equalTo: composerBoxContainerStackView.trailingAnchor),
            
            singleLineContainerView.leadingAnchor.constraint(equalTo: composerBoxContainerStackView.leadingAnchor),
            singleLineContainerView.trailingAnchor.constraint(equalTo: composerBoxContainerStackView.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraintsToActivate)
        
        updateSendButtonState()
        updateMicrophoneButtonVisibility()
    }

    // MARK: - Style Setup
    
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
        composerBoxContainerStackView.roundViewCorners(corner: style.composeBoxCornerRadius)
        
        textView.font = style.textFieldFont
        textView.textColor = style.textFieldColor
        textView.placeholderColor = style.placeholderColor
        textView.placeholderFont = style.placeholderFont
        textView.typingAttributes = [
            .font: style.textFieldFont,
            .foregroundColor: style.textFieldColor
        ]
        
        // Update code block background color and border from style
        codeBlockBackgroundView.backgroundColor = style.codeBlockBackgroundColor
        codeBlockBackgroundView.layer.borderWidth = style.codeBlockBorderWidth
        codeBlockBackgroundView.layer.borderColor = style.codeBlockBorderColor.cgColor
        
        // Update code block left border color from style
        codeBlockLeftBorderView.backgroundColor = style.codeBlockLeftBorderColor
        
        // Update code block placeholder styling
        codeBlockPlaceholderLabel.text = style.codeBlockPlaceholder
        codeBlockPlaceholderLabel.textColor = style.codeBlockPlaceholderColor
        
        // Setting images
        attachmentButton.setImage(style.attachmentImage, for: .normal)
        microphoneButton.setImage(style.voiceRecordingImage, for: .normal)
        stickersButton.setImage(style.stickersImage, for: .normal)
        sendButton.setImage(style.sendButtonImage, for: .normal)
        
        // Setting tints
        sendButton.imageView?.tintColor = style.sendButtonImageTint
        sendButton.backgroundColor = style.inactiveSendButtonBackgroundColor
        microphoneButton.imageView?.tintColor = style.voiceRecordingImageTint
        attachmentButton.imageView?.tintColor = style.attachmentImageTint
        stickersButton.imageView?.tintColor = style.stickersImageTint
        
        // Apply rich text toolbar style
        richTextToolbar.style = style.richTextToolbarStyle
        
        let isAgentic = viewModel.user?.isAgentic ?? false
        
        // Apply visibility settings
        if hideAttachmentButton || isAgentic {
            attachmentButton.isHidden = true
        }
        if hideVoiceRecordingButton || isAgentic {
            microphoneButton.isHidden = true
        }
        if hideStickersButton || isAgentic {
            stickersButton.isHidden = true
        }
        
        // Rich text toolbar visibility based on showRichTextFormattingOptions property
        // Hide toolbar when agentic mode is active
        if isAgentic {
            richTextToolbarContainerView.isHidden = true
            richTextToolbar.isHidden = true
            textView.showFormattingMenu = false
            enableRichTextFormatting = false
        } else {
            // Show toolbar when showRichTextFormattingOptions is true, hide when false
            richTextToolbarContainerView.isHidden = !showRichTextFormattingOptions
            richTextToolbar.isHidden = !showRichTextFormattingOptions
            
            // Also control formatting menu in text selection context menu
            textView.showFormattingMenu = showRichTextFormattingOptions
        }
        
        // Update send button appearance for agentic mode
        if isAgentic {
            updateSendButtonForAgenticMode()
        }
    }
    
    func updateUI() {
        if hideSendButton {
            sendButton.isHidden = true
        }
        if composerState == .edit {
            viewModel.reset?(true)
        }
    }
    
    // MARK: - Send Button State
    
    /// Checks if the text view contains actual text content beyond formatting markers
    /// Returns false if text is empty, whitespace-only, or contains only formatting prefixes
    private func hasActualTextContent() -> Bool {
        guard let attributedText = textView.attributedText else { return false }
        let text = attributedText.string
        
        // Check if empty or whitespace only
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return false }
        
        // Check for formatting-only content
        // Blockquote: "▎ " or "▎"
        // Bullet list: "• " or "•"
        // Numbered list: matches pattern "N. " where N is a number
        // Combined patterns: "▎ • " (blockquote + bullet), "▎ N. " (blockquote + numbered)
        
        let formattingOnlyPatterns = [
            "^▎\\s*$",                  // Blockquote marker only
            "^•\\s*$",                  // Bullet marker only
            "^\\d+\\.\\s*$",            // Numbered list marker only
            "^▎\\s+•\\s*$",             // Blockquote + bullet marker only
            "^▎\\s+\\d+\\.\\s*$"        // Blockquote + numbered list marker only
        ]
        
        for pattern in formattingOnlyPatterns {
            if trimmed.range(of: pattern, options: .regularExpression) != nil {
                return false
            }
        }
        
        return true
    }
    
    public func updateSendButtonState() {
        // Check if text contains actual content beyond formatting markers
        let hasText = hasActualTextContent()
        
        sendButton.isEnabled = hasText
        
        if composerState == .edit {
            // Add null safety check for originalEditText
            guard let originalText = originalEditText else {
                // If originalEditText is nil in edit mode, disable send button as a safety measure
                sendButton.isEnabled = false
                sendButton.backgroundColor = style.inactiveSendButtonBackgroundColor
                updateMicrophoneButtonVisibility()
                return
            }
            
            // Convert current attributed text to markdown for proper comparison
            // This ensures we compare the same format (markdown) on both sides
            let currentMarkdown: String
            if let attributedText = textView.attributedText {
                currentMarkdown = RichTextFormatterManager.shared.convertToMarkdown(attributedText)
            } else {
                currentMarkdown = textView.text ?? ""
            }
            
            // Check if text has changed from original
            let unchanged = (currentMarkdown == originalText)
            
            // Enable send button only if text has actual content AND has changed
            sendButton.isEnabled = hasText && !unchanged
        }
        
        sendButton.backgroundColor = sendButton.isEnabled ? style.activeSendButtonBackgroundColor : style.inactiveSendButtonBackgroundColor
        
        // For agentic mode, use agentic styling
        let isAgentic = viewModel.user?.isAgentic ?? false
        if isAgentic {
            sendButton.backgroundColor = sendButton.isEnabled ? style.agenticActiveSendButtonBackgroundColor : style.agenticInactiveSendButtonBackgroundColor
        }
        
        // Update microphone visibility based on text
        updateMicrophoneButtonVisibility()
    }
    
    /// Updates send button appearance for agentic mode
    /// Changes the send button to use arrow.up icon with agentic styling
    private func updateSendButtonForAgenticMode() {
        sendButton.setImage(style.agenticSendButtonImage, for: .normal)
        sendButton.imageView?.tintColor = style.agenticSendButtonImageTint
        sendButton.backgroundColor = style.agenticInactiveSendButtonBackgroundColor
    }
    
    /// Updates microphone button visibility - hides when there's text, shows when empty
    /// Animates with a slide-right effect that makes the mic appear to merge into the send button
    /// Also smoothly animates the sticker button position change
     func updateMicrophoneButtonVisibility() {
        // Only update if not explicitly hidden by configuration
        guard !hideVoiceRecordingButton else { return }
        
        // Check if text is empty or contains only whitespace
        let textContent = textView.text ?? ""
        let hasText = !textContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        let isAgentic = viewModel.user?.isAgentic ?? false
        
        // Hide mic when: has text, is agentic, OR is in code block mode
        let isInCodeBlockMode = RichTextFormatterManager.shared.isInCodeBlockMode
        let shouldHide = hasText || isAgentic || isInCodeBlockMode
        
        // Skip animation if state hasn't changed
        let isCurrentlyHidden = microphoneButton.isHidden || microphoneButton.alpha == 0
        guard shouldHide != isCurrentlyHidden else { return }
        
        if shouldHide {
            // Animate mic sliding right and fading out (merging into send button)
            // Sticker button slides right smoothly along with mic
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                // Slide mic right towards send button and fade out
                self.microphoneButton.transform = CGAffineTransform(translationX: 40, y: 0)
                self.microphoneButton.alpha = 0
                // Slide sticker button right (same distance as mic + spacing)
                self.stickersButton.transform = CGAffineTransform(translationX: 24 + CometChatSpacing.Padding.p3, y: 0)
            } completion: { [weak self] _ in
                guard let self = self else { return }
                self.microphoneButton.isHidden = true
                self.microphoneButton.transform = .identity
                // Reset sticker transform - stack view will now position it correctly since mic is hidden
                self.stickersButton.transform = .identity
            }
        } else {
            // First, offset sticker to the right (where it will be after mic appears)
            // This compensates for the stack view's new layout
            stickersButton.transform = CGAffineTransform(translationX: 24 + CometChatSpacing.Padding.p3, y: 0)
            
            // Prepare mic for animation - start from right (at send button position)
            microphoneButton.transform = CGAffineTransform(translationX: 40, y: 0)
            microphoneButton.alpha = 0
            microphoneButton.isHidden = false
            
            // Animate mic sliding in from right (appearing from send button)
            // and sticker button sliding left to make room
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseInOut]) { [weak self] in
                guard let self = self else { return }
                // Slide mic into position and fade in
                self.microphoneButton.transform = .identity
                self.microphoneButton.alpha = 1
                // Slide sticker button back to original position
                self.stickersButton.transform = .identity
            }
        }
    }
    
    // MARK: - Button Actions
    
    @objc open func didSendButtonClicked() {
        let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackLight.impactOccurred()
        
        DispatchQueue.main.async { [weak self] in
            self?.messagePreview.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self?.messagePreview.isHidden = true
            self?.textView.resignFirstResponder()
        }
        
        guard let attributedText = textView.attributedText, !attributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Remove empty list items before sending
        let cleanedAttributedText = removeEmptyListItems(from: attributedText)
        
        // Check if there's still content after removing empty list items
        guard !cleanedAttributedText.string.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Convert attributed text to markdown for rich text formatting support
        // Pass selectedFormatters to properly convert mentions to their underlying text (mention tags)
        // Note: Blockquote markers are now added by convertToMarkdown via isBlockquoteKey attribute
        let markdownText = RichTextFormatterManager.shared.convertToMarkdown(cleanedAttributedText, selectedFormatters: selectedFormatters)
        
        
        if composerState == .edit, let message = viewModel.message as? TextMessage {
            viewModel.editTextMessage(textMessage: message, message: markdownText, textFormatter: selectedFormatters)
        } else {
            if viewModel.user != nil {
                viewModel.sendTextMessageToUser(message: markdownText, textFormatter: selectedFormatters)
            } else if viewModel.group != nil {
                viewModel.sendTextMessageToGroup(message: markdownText, textFormatter: selectedFormatters)
            }
        }
        
        // Reset all formatting state FIRST (before clearing text to prevent textViewDidChange from interfering)
        RichTextFormatterManager.shared.resetAllFormats()
        
        // Hide code block background FIRST and reset state
        codeBlockBackgroundView.isHidden = true
        codeBlockLeftBorderView.isHidden = true
        codeBlockPlaceholderLabel.isHidden = true
        codeBlockStartPosition = nil
        codeBlockTextRange = nil
        codeBlockMinimumHeight = 0  // Reset minimum height
        centerTextInCodeBlock()  // Reset text container inset
        resetTextViewMinHeight()  // Reset text view minHeight to original value
        
        // Hide blockquote bar FIRST and reset state
        blockquoteBarView.isHidden = true
        blockquoteStartPosition = nil
        blockquoteTextRange = nil
        
        // Reset constraints (view is already hidden, so this won't show it)
        resetCodeBlockBackgroundToFullMode()
        resetBlockquoteBarToFullMode()
        
        // Restore the text view placeholder
        textView.hidePlaceholder = false
        
        // Clear the text view after hiding visual elements
        textView.text = ""
        textView.attributedText = nil
        selectedFormatters.removeAll()
        
        // Reset typing attributes to default (important for code block mode)
        textView.typingAttributes = [
            .font: style.textFieldFont,
            .foregroundColor: style.textFieldColor
        ]
        
        // Update toolbar button states to reflect reset
        richTextToolbar.setActiveFormats([])
        richTextToolbar.enableAllButtons()
        
        // Update send button state (should be disabled now that text is empty)
        updateSendButtonState()
        
        // Show microphone button if applicable
        updateMicrophoneButtonVisibility()
        
        // Force layout update to ensure text field returns to original size
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
        textViewContainer.setNeedsLayout()
        textViewContainer.layoutIfNeeded()
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    /// Removes empty list items (bullet or numbered) from the attributed text
    /// Empty list items are lines that contain only the list marker (• or N.) with no content
    private func removeEmptyListItems(from attributedText: NSAttributedString) -> NSAttributedString {
        let text = attributedText.string
        let lines = text.components(separatedBy: "\n")
        var linesToKeep: [Int] = []
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Check if line is an empty bullet point (just "• " or "•")
            if trimmedLine == "•" || trimmedLine == "• " {
                continue // Skip this empty bullet point
            }
            
            // Check if line is an empty numbered list item (just "N. " or "N.")
            if let regex = try? NSRegularExpression(pattern: "^\\d+\\.\\s*$"),
               regex.firstMatch(in: trimmedLine, range: NSRange(location: 0, length: trimmedLine.count)) != nil {
                continue // Skip this empty numbered list item
            }
            
            // Check if line is an empty blockquote bullet (just "▎ • " or "▎ •")
            if trimmedLine == "▎ •" || trimmedLine == "▎ • " {
                continue // Skip this empty blockquote bullet
            }
            
            // Check if line is an empty blockquote numbered list (just "▎ N. " or "▎ N.")
            if let regex = try? NSRegularExpression(pattern: "^▎\\s+\\d+\\.\\s*$"),
               regex.firstMatch(in: trimmedLine, range: NSRange(location: 0, length: trimmedLine.count)) != nil {
                continue // Skip this empty blockquote numbered list item
            }
            
            // Check if line is an empty blockquote (just "▎ " or "▎")
            if trimmedLine == "▎" || trimmedLine == "▎ " {
                continue // Skip this empty blockquote
            }
            
            linesToKeep.append(index)
        }
        
        // If all lines are kept, return original
        if linesToKeep.count == lines.count {
            return attributedText
        }
        
        // Build new attributed string with only non-empty lines
        let mutableAttributedString = NSMutableAttributedString()
        var currentLocation = 0
        
        for (index, line) in lines.enumerated() {
            let lineLength = line.count
            let includeNewline = index < lines.count - 1
            let rangeLength = lineLength + (includeNewline ? 1 : 0)
            
            if linesToKeep.contains(index) {
                // Include this line
                let lineRange = NSRange(location: currentLocation, length: min(rangeLength, attributedText.length - currentLocation))
                if lineRange.location < attributedText.length && lineRange.length > 0 {
                    let lineAttributedString = attributedText.attributedSubstring(from: lineRange)
                    
                    // Add newline between kept lines if needed
                    if mutableAttributedString.length > 0 && !mutableAttributedString.string.hasSuffix("\n") {
                        mutableAttributedString.append(NSAttributedString(string: "\n"))
                    }
                    
                    // Remove trailing newline if this is the last line to keep
                    if index == linesToKeep.last && lineAttributedString.string.hasSuffix("\n") {
                        let trimmedRange = NSRange(location: 0, length: lineAttributedString.length - 1)
                        mutableAttributedString.append(lineAttributedString.attributedSubstring(from: trimmedRange))
                    } else {
                        mutableAttributedString.append(lineAttributedString)
                    }
                }
            }
            
            currentLocation += rangeLength
        }
        
        // Remove any trailing newlines
        while mutableAttributedString.string.hasSuffix("\n") {
            let range = NSRange(location: mutableAttributedString.length - 1, length: 1)
            mutableAttributedString.deleteCharacters(in: range)
        }
        
        return mutableAttributedString
    }
    
    @objc open func attachmentButtonClicked() {
        controller?.view.endEditing(true)
        
        var attachmentOptions = [CometChatMessageComposerAction]()
        if let customOptions = attachmentOptionsClosure?(viewModel.user, viewModel.group, controller) {
            attachmentOptions.append(contentsOf: customOptions)
        } else {
            attachmentOptions.append(contentsOf: ChatConfigurator.getDataSource().getAttachmentOptions(controller: controller ?? UIViewController(), user: viewModel.user, group: viewModel.group, id: getId(), additionalConfiguration: AdditionalConfiguration()) ?? [])
        }
        
        // Convert CometChatMessageComposerAction to ActionItem
        var actionItems = [ActionItem]()
        for option in attachmentOptions {
            let actionItem = ActionItem(id: option.id ?? "", text: option.text ?? "", leadingIcon: option.startIcon ?? UIImage(), onActionClick: option.onActionClick)
            actionItems.append(actionItem)
        }
        
        let actionSheet = CometChatActionSheet()
        actionSheet.style = attachmentSheetStyle
        actionSheet.actionSheetDelegate = self
        actionSheet.set(actionItems: actionItems)
        
        if #available(iOS 15.0, *) {
            if let sheetController = actionSheet.sheetPresentationController {
                sheetController.detents = [.medium()]
                if #available(iOS 16.0, *) {
                    let customDetent = UISheetPresentationController.Detent.custom { _ in
                        return CGFloat(actionItems.count * 50)
                    }
                    sheetController.detents = [customDetent]
                }
                sheetController.prefersGrabberVisible = true
            }
            actionSheet.modalPresentationStyle = .pageSheet
            controller?.presentWithInheritedInterfaceStyle(actionSheet)
        } else {
            controller?.presentPanModal(actionSheet)
        }
    }
    
    @objc open func didMicrophoneButtonClicked() {
        controller?.view.endEditing(true)
        
        // Toggle inline voice recorder
        if isVoiceRecorderShown {
            hideInlineVoiceRecorder()
        } else {
            showInlineVoiceRecorder()
        }
        
        // MARK: - Old Bottom Sheet Implementation (Commented Out)
        /*
        let cometChatMediaRecorder = CometChatMediaRecorder()
        cometChatMediaRecorder.style = mediaRecorderStyle
        
        if let user = viewModel.user {
            cometChatMediaRecorder.viewModel = MediaRecorderViewModel(user: user)
        } else if let group = viewModel.group {
            cometChatMediaRecorder.viewModel = MediaRecorderViewModel(group: group)
        }
        
        cometChatMediaRecorder.setSubmit(onSubmit: { [weak self] url in
            guard let self = self else { return }
            if self.onSendButtonClick != nil {
                // Handle custom send
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
            }
            cometChatMediaRecorder.modalPresentationStyle = .pageSheet
            controller?.presentWithInheritedInterfaceStyle(cometChatMediaRecorder)
        } else {
            controller?.presentPanModal(cometChatMediaRecorder)
        }
        */
    }
    
    // MARK: - Inline Voice Recorder Methods
    
    private func showInlineVoiceRecorder() {
        guard !isVoiceRecorderShown else { return }
        
        // Hide the normal composer content
        singleLineContainerView.isHidden = true
        richTextToolbarContainerView.isHidden = true
        messagePreview.isHidden = true
        
        // Create and configure the inline voice recorder
        let recorder = CometChatInlineVoiceRecorder()
        recorder.style = inlineVoiceRecorderStyle
        recorder.translatesAutoresizingMaskIntoConstraints = false
        
        recorder.setSubmit { [weak self] url in
            guard let self = self else { return }
            self.hideInlineVoiceRecorder()
            
            if self.onSendButtonClick != nil {
                // Handle custom send - create a media message for callback
            } else {
                if self.viewModel.user != nil {
                    self.viewModel.sendMediaMessageToUser(url: url, type: .audio)
                } else {
                    self.viewModel.sendMediaMessageToGroup(url: url, type: .audio)
                }
            }
        }
        
        recorder.setCancel { [weak self] in
            self?.hideInlineVoiceRecorder()
        }
        
        // Add to composer box
        composerBoxContainerStackView.insertArrangedSubview(recorder, at: 0)
        
        // Set height constraint
        recorder.heightAnchor.constraint(equalToConstant: 56).isActive = true
        
        inlineVoiceRecorder = recorder
        isVoiceRecorderShown = true
    }
    
    private func hideInlineVoiceRecorder() {
        guard isVoiceRecorderShown, let recorder = inlineVoiceRecorder else { return }
        
        // Remove the recorder
        recorder.removeFromSuperview()
        inlineVoiceRecorder = nil
        isVoiceRecorderShown = false
        
        // Show the normal composer content
        singleLineContainerView.isHidden = false
        
        // Restore rich text toolbar visibility based on settings
        if showRichTextFormattingOptions {
            richTextToolbarContainerView.isHidden = richTextToolbar.isHidden
        }
        
        // Restore message preview if needed
        if composerState == .edit || composerState == .reply {
            messagePreview.isHidden = false
        }
    }
    
    @objc open func didStickersButtonClicked() {
        let impactFeedbackLight = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackLight.impactOccurred()
        
        // Toggle sticker keyboard
        if isStickerKeyboardShown {
            // Hide sticker keyboard
            CometChatUIEvents.hidePanel(id: getId(), alignment: .composerBottom)
        } else {
            // Show sticker keyboard
            controller?.view.endEditing(true)
            
            // Create sticker keyboard
            let stickerKeyboard = CometChatStickerKeyboard()
            stickerKeyboard.setOnStickerTap { [weak self] sticker in
                guard let self = self else { return }
                
                var stickerData = [String: Any]()
                var metaData = [String: Any]()
                let pushNotificationMessage = "HAS_SHARED_A_STICKER".localize()
                
                stickerData["sticker_url"] = sticker.url
                stickerData["sticker_name"] = sticker.name
                metaData["incrementUnreadCount"] = true
                metaData["pushNotification"] = pushNotificationMessage
                
                var customMessage: CustomMessage?
                if let user = self.viewModel.user {
                    customMessage = CustomMessage(receiverUid: user.uid ?? "", receiverType: .user, customData: stickerData, type: MessageTypeConstants.sticker)
                }
                if let group = self.viewModel.group {
                    customMessage = CustomMessage(receiverUid: group.guid, receiverType: .group, customData: stickerData, type: MessageTypeConstants.sticker)
                }
                if let parentMessageId = self.viewModel.parentMessageId {
                    customMessage?.parentMessageId = parentMessageId
                }
                
                customMessage?.updateConversation = true
                if let customMessage = customMessage {
                    customMessage.muid = "\(Date().timeIntervalSince1970)"
                    customMessage.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                    customMessage.sender = CometChat.getLoggedInUser()
                    customMessage.metaData = metaData
                    
                    CometChatMessageEvents.ccMessageSent(message: customMessage, status: .inProgress)
                    CometChat.sendCustomMessage(message: customMessage) { sentMessage in
                        CometChatMessageEvents.ccMessageSent(message: sentMessage, status: .success)
                    } onError: { error in
                        if let error = error {
                            customMessage.metaData?["error"] = true
                            CometChatMessageEvents.ccMessageSent(message: customMessage, status: .error)
                            self.onError?(error)
                        }
                    }
                }
                
                // Don't hide panel after sending sticker - keep keyboard open for multiple sticker sends
            }
            
            // Show sticker keyboard panel
            CometChatUIEvents.showPanel(id: getId(), alignment: .composerBottom, view: stickerKeyboard)
        }
    }

    // MARK: - Rich Text Formatting
    
    /// Handles backspace/delete key press - called even when text view is empty
    private func handleDeleteBackward() {
        // Check if text is empty or will be empty and we're in code block mode
        let currentText = textView.text ?? ""
        let trimmedText = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle code block mode exit on backspace when empty
        if trimmedText.isEmpty && RichTextFormatterManager.shared.isInCodeBlockMode {
            // Exit code block mode
            RichTextFormatterManager.shared.isInCodeBlockMode = false
            codeBlockBackgroundView.isHidden = true
            codeBlockLeftBorderView.isHidden = true
            codeBlockPlaceholderLabel.isHidden = true
            codeBlockTextRange = nil
            codeBlockStartPosition = nil
            codeBlockMinimumHeight = 0  // Reset minimum height
            centerTextInCodeBlock()  // Reset text container inset
            resetCodeBlockBackgroundToFullMode()
            resetTextViewMinHeight()  // Reset text view minHeight to original value
            RichTextFormatterManager.shared.persistentFormats.remove(.codeBlock)
            
            // Restore the text view placeholder
            textView.hidePlaceholder = false
            
            // Reset typing attributes to normal (preserve persistent formats if any)
            if RichTextFormatterManager.shared.persistentFormats.isEmpty {
                textView.typingAttributes = [
                    .font: style.textFieldFont,
                    .foregroundColor: style.textFieldColor
                ]
            } else {
                textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
                    baseFont: style.textFieldFont,
                    baseColor: style.textFieldColor
                )
            }
            
            // Update toolbar to reflect code block is no longer active
            DispatchQueue.main.async { [weak self] in
                self?.updateToolbarActiveFormats()
                self?.updateSendButtonState()
            }
        } else if !trimmedText.isEmpty && RichTextFormatterManager.shared.isInCodeBlockMode {
            // Text is not empty but we're in code block mode - update background after delete
            // Schedule update after the delete operation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self else { return }
                self.textView.setNeedsLayout()
                self.textView.layoutIfNeeded()
                self.textViewContainer.setNeedsLayout()
                self.textViewContainer.layoutIfNeeded()
                self.updateCodeBlockBackgroundForFullText()
            }
        }
        
        // Handle blockquote mode exit on backspace when empty
        if trimmedText.isEmpty && RichTextFormatterManager.shared.isInBlockquoteMode {
            // Exit blockquote mode
            RichTextFormatterManager.shared.isInBlockquoteMode = false
            blockquoteBarView.isHidden = true
            blockquoteStartPosition = nil
            blockquoteTextRange = nil
            resetBlockquoteBarToFullMode()
            
            // Reset typing attributes to normal (preserve persistent formats if any)
            if RichTextFormatterManager.shared.persistentFormats.isEmpty {
                textView.typingAttributes = [
                    .font: style.textFieldFont,
                    .foregroundColor: style.textFieldColor
                ]
            } else {
                textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
                    baseFont: style.textFieldFont,
                    baseColor: style.textFieldColor
                )
            }
            
            // Update toolbar to reflect blockquote is no longer active
            DispatchQueue.main.async { [weak self] in
                self?.richTextToolbar.enableAllButtons()
                self?.updateToolbarActiveFormats()
                self?.updateSendButtonState()
            }
        }
    }
    
    /// Renumbers all numbered list items in the attributed string sequentially
    /// This should be called after converting a numbered list item to bullet or removing a numbered item
    /// - Parameter attributedString: The mutable attributed string to modify
    private func renumberListItems(in attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        let lines = text.components(separatedBy: "\n")
        
        var currentNumber = 1
        var offset = 0 // Track cumulative offset from replacements
        var currentPosition = 0
        
        for line in lines {
            let lineStart = currentPosition + offset
            
            // Check if this line has a numbered list pattern (with or without blockquote)
            let numberPattern = "^(▎\\s)?(\\d+)\\.\\s"
            if let regex = try? NSRegularExpression(pattern: numberPattern),
               let match = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.count)),
               let numberRange = Range(match.range(at: 2), in: line) {
                
                let oldNumber = String(line[numberRange])
                let newNumber = String(currentNumber)
                
                if oldNumber != newNumber {
                    // Calculate the actual range in the attributed string
                    let numberStartInLine = match.range(at: 2).location
                    let numberLengthInLine = match.range(at: 2).length
                    let actualRange = NSRange(location: lineStart + numberStartInLine, length: numberLengthInLine)
                    
                    // Replace the number
                    attributedString.replaceCharacters(in: actualRange, with: newNumber)
                    
                    // Update offset for subsequent lines
                    offset += newNumber.count - oldNumber.count
                    
                    // Update selectedFormatters ranges if needed
                    let lengthDiff = newNumber.count - oldNumber.count
                    if lengthDiff != 0 {
                        for (character, formatterItems) in selectedFormatters {
                            for index in 0..<formatterItems.count {
                                let itemRange = formatterItems[index].range
                                if itemRange.location > actualRange.location {
                                    let newRange = NSRange(location: itemRange.location + lengthDiff, length: itemRange.length)
                                    selectedFormatters[character]?[index].range = newRange
                                }
                            }
                        }
                    }
                }
                
                currentNumber += 1
            }
            
            // Move to next line (add 1 for newline character, except for last line)
            currentPosition += line.count + 1
        }
    }
    
    private func handleFormatSelected(_ format: FormatType) {
        
        // IMPORTANT: Don't apply formatting if a mention is being typed
        if ongoingTextFormatter != nil {
            return
        }
        
        guard let selectedRange = textView.selectedTextRange else {
            return
        }
        
        let start = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
        let length = textView.offset(from: selectedRange.start, to: selectedRange.end)
        var range = NSRange(location: start, length: length)
        
        
        // Collect all mention ranges that overlap with the selection
        var mentionRangesInSelection: [NSRange] = []
        if length > 0 {
            for (_, formatterItems) in selectedFormatters {
                for (_, mentionRange) in formatterItems {
                    // Check if ranges overlap
                    let selectionEnd = range.location + range.length
                    let mentionEnd = mentionRange.location + mentionRange.length
                    
                    // Ranges overlap if: start1 < end2 AND start2 < end1
                    if range.location < mentionEnd && mentionRange.location < selectionEnd {
                        mentionRangesInSelection.append(mentionRange)
                    }
                }
            }
        }
        
        let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
        
        // Handle link format - show alert dialog for text and URL input
        if format == .link {
            showAddLinkAlert(at: range)
            return
        }
        
        // Check format compatibility BEFORE applying
        // Get current active formats to check compatibility
        let manager = RichTextFormatterManager.shared
        let currentActiveFormats = manager.activeFormats
        
        
        // Check if we're trying to activate a format (not deactivate)
        let isActivating = !currentActiveFormats.contains(format)
        
        
        // Handle replacement logic for code block and block formats (lists, blockquote)
        if isActivating {
            let blockFormats: Set<FormatType> = [.bulletList, .numberedList, .blockquote]
            
            // Case 1: Code block is active and user selects a block format → replace code block
            if manager.isInCodeBlockMode && blockFormats.contains(format) {
                // Exit code block mode first
                manager.isInCodeBlockMode = false
                codeBlockBackgroundView.isHidden = true
                codeBlockLeftBorderView.isHidden = true
                codeBlockPlaceholderLabel.isHidden = true
                resetCodeBlockBackgroundToFullMode()
                resetTextViewMinHeight()  // Reset text view minHeight to original value
                manager.persistentFormats.remove(.codeBlock)
                
                // Restore the text view placeholder
                textView.hidePlaceholder = false
                
                // Remove code block styling from text
                if attributedString.length > 0 {
                    let fullRange = NSRange(location: 0, length: attributedString.length)
                    attributedString.removeAttribute(RichTextFormatterManager.isCodeBlockKey, range: fullRange)
                    attributedString.removeAttribute(.backgroundColor, range: fullRange)
                    // Reset font to normal
                    attributedString.addAttribute(.font, value: style.textFieldFont, range: fullRange)
                    attributedString.addAttribute(.foregroundColor, value: style.textFieldColor, range: fullRange)
                }
                
                // Reset typing attributes
                textView.typingAttributes = [
                    .font: style.textFieldFont,
                    .foregroundColor: style.textFieldColor
                ]
                
                textView.attributedText = attributedString
                // Continue to apply the new format below
            }
            
            // Case 2: A block format is active and user selects code block → replace with code block
            if format == .codeBlock && (manager.isInBulletListMode || manager.isInNumberedListMode || manager.isInBlockquoteMode) {
                // Remove existing block format markers from current line
                let lineInfo = getLineInfo(at: start, in: attributedString.string)
                let lineText = attributedString.length > 0 && lineInfo.length > 0 ?
                    (attributedString.string as NSString).substring(with: NSRange(location: lineInfo.start, length: min(lineInfo.length, 15))) : ""
                
                var deletedLength = 0
                
                // Handle combined formats first (blockquote + bullet/number)
                // "▎ • " = blockquote + bullet (4 chars)
                // "▎ N. " = blockquote + numbered list (4+ chars)
                if lineText.hasPrefix("▎ • ") {
                    // Remove both blockquote and bullet markers
                    let combinedRange = NSRange(location: lineInfo.start, length: 4)
                    attributedString.deleteCharacters(in: combinedRange)
                    deletedLength = 4
                }
                else if lineText.hasPrefix("▎ "),
                        let regex = try? NSRegularExpression(pattern: "^▎ \\d+\\.\\s"),
                        let match = regex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) {
                    // Remove blockquote + numbered list markers
                    let matchRange = NSRange(location: lineInfo.start, length: match.range.length)
                    attributedString.deleteCharacters(in: matchRange)
                    deletedLength = match.range.length
                }
                // Handle single formats
                else if lineText.hasPrefix("• ") {
                    let bulletRange = NSRange(location: lineInfo.start, length: 2)
                    attributedString.deleteCharacters(in: bulletRange)
                    deletedLength = 2
                }
                else if let regex = try? NSRegularExpression(pattern: "^\\d+\\.\\s"),
                        let match = regex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) {
                    let matchRange = NSRange(location: lineInfo.start, length: match.range.length)
                    attributedString.deleteCharacters(in: matchRange)
                    deletedLength = match.range.length
                }
                else if lineText.hasPrefix("▎ ") {
                    let blockquoteRange = NSRange(location: lineInfo.start, length: 2)
                    attributedString.deleteCharacters(in: blockquoteRange)
                    deletedLength = 2
                }
                
                // Reset block format modes
                manager.isInBulletListMode = false
                manager.isInNumberedListMode = false
                manager.isInBlockquoteMode = false
                manager.currentListNumber = 1
                
                // Update cursor position if needed
                if deletedLength > 0 && start >= lineInfo.start + deletedLength {
                    range = NSRange(location: start - deletedLength, length: range.length)
                }
                
                textView.attributedText = attributedString
                // Continue to apply code block below
            }
            
            // Check compatibility with current active formats (after potential replacement)
            let isCompatible = manager.compatibilityEngine.isCompatible(format, with: manager.activeFormats)
            
            if !isCompatible {
                // Format is incompatible - provide haptic feedback and reject
                let feedbackGenerator = UINotificationFeedbackGenerator()
                feedbackGenerator.notificationOccurred(.warning)
                return
            }
        }
        
        
        // Handle list formats differently - they work at cursor position
        if format == .bulletList || format == .numberedList {
            // Get current line info
            let lineInfo = getLineInfo(at: start, in: attributedString.string)
            let lineText = attributedString.length > 0 && lineInfo.length > 0 ?
                (attributedString.string as NSString).substring(with: NSRange(location: lineInfo.start, length: min(lineInfo.length, 15))) : ""
            
            // Check if the SAME format is already applied - if so, toggle it off
            if format == .bulletList {
                // Check if bullet marker exists (with or without blockquote)
                let hasBullet = lineText.hasPrefix("• ") || lineText.hasPrefix("▎ • ")
                
                if hasBullet && RichTextFormatterManager.shared.isInBulletListMode {
                    // Toggle off: remove bullet marker
                    RichTextFormatterManager.shared.isInBulletListMode = false
                    
                    var deletedLength = 0
                    var deletionPoint = lineInfo.start
                    
                    if lineText.hasPrefix("• ") {
                        let bulletRange = NSRange(location: lineInfo.start, length: 2)
                        attributedString.deleteCharacters(in: bulletRange)
                        deletedLength = 2
                        deletionPoint = lineInfo.start
                    } else if lineText.hasPrefix("▎ • ") {
                        let bulletRange = NSRange(location: lineInfo.start + 2, length: 2)
                        attributedString.deleteCharacters(in: bulletRange)
                        deletedLength = 2
                        deletionPoint = lineInfo.start + 2
                    }
                    
                    // Update selectedFormatters ranges to account for the deleted prefix
                    if deletedLength > 0 {
                        for (character, formatterItems) in selectedFormatters {
                            for index in 0..<formatterItems.count {
                                let itemRange = formatterItems[index].range
                                if itemRange.location >= deletionPoint + deletedLength {
                                    // Shift the range backward by the deleted length
                                    let newRange = NSRange(location: itemRange.location - deletedLength, length: itemRange.length)
                                    selectedFormatters[character]?[index].range = newRange
                                }
                            }
                        }
                    }
                    
                    textView.attributedText = attributedString
                    updateToolbarActiveFormats()
                    updateSendButtonState()
                    return
                }
                
                // If switching from numbered list to bullet list, remove the number first
                if RichTextFormatterManager.shared.isInNumberedListMode {
                    RichTextFormatterManager.shared.isInNumberedListMode = false
                    RichTextFormatterManager.shared.currentListNumber = 1
                    
                    // Remove numbered list marker (e.g., "1. ", "2. ", etc.)
                    // Handle both with and without blockquote prefix: "1. " or "▎ 1. "
                    let numberPattern = "^(▎\\s)?\\d+\\.\\s"
                    if let regex = try? NSRegularExpression(pattern: numberPattern),
                       let match = regex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) {
                        // Find where the number actually starts (after blockquote if present)
                        let numberOnlyPattern = "\\d+\\.\\s"
                        if let numberRegex = try? NSRegularExpression(pattern: numberOnlyPattern),
                           let numberMatch = numberRegex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) {
                            let matchRange = NSRange(location: lineInfo.start + numberMatch.range.location, length: numberMatch.range.length)
                            let deletedLength = numberMatch.range.length
                            let deletionPoint = lineInfo.start + numberMatch.range.location
                            
                            attributedString.deleteCharacters(in: matchRange)
                            
                            // Update selectedFormatters ranges
                            for (character, formatterItems) in selectedFormatters {
                                for index in 0..<formatterItems.count {
                                    let itemRange = formatterItems[index].range
                                    if itemRange.location >= deletionPoint + deletedLength {
                                        let newRange = NSRange(location: itemRange.location - deletedLength, length: itemRange.length)
                                        selectedFormatters[character]?[index].range = newRange
                                    }
                                }
                            }
                            
                            // Renumber remaining numbered list items after this line
                            renumberListItems(in: attributedString)
                            
                            // Adjust start position after deletion
                            if start >= lineInfo.start + numberMatch.range.location + deletedLength {
                                range = NSRange(location: start - deletedLength, length: range.length)
                            }
                        }
                    }
                }
            } else if format == .numberedList {
                // Check if numbered marker exists (with or without blockquote)
                let numberPattern = "^(▎\\s)?\\d+\\.\\s"
                let hasNumber = (try? NSRegularExpression(pattern: numberPattern))?.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) != nil
                
                if hasNumber && RichTextFormatterManager.shared.isInNumberedListMode {
                    // Toggle off: remove numbered marker
                    RichTextFormatterManager.shared.isInNumberedListMode = false
                    RichTextFormatterManager.shared.currentListNumber = 1
                    
                    let numberOnlyPattern = "\\d+\\.\\s"
                    if let numberRegex = try? NSRegularExpression(pattern: numberOnlyPattern),
                       let numberMatch = numberRegex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) {
                        let matchRange = NSRange(location: lineInfo.start + numberMatch.range.location, length: numberMatch.range.length)
                        let deletedLength = numberMatch.range.length
                        let deletionPoint = lineInfo.start + numberMatch.range.location
                        
                        attributedString.deleteCharacters(in: matchRange)
                        
                        // Update selectedFormatters ranges
                        for (character, formatterItems) in selectedFormatters {
                            for index in 0..<formatterItems.count {
                                let itemRange = formatterItems[index].range
                                if itemRange.location >= deletionPoint + deletedLength {
                                    let newRange = NSRange(location: itemRange.location - deletedLength, length: itemRange.length)
                                    selectedFormatters[character]?[index].range = newRange
                                }
                            }
                        }
                    }
                    
                    textView.attributedText = attributedString
                    updateToolbarActiveFormats()
                    updateSendButtonState()
                    return
                }
                
                // If switching from bullet list to numbered list, remove the bullet first
                if RichTextFormatterManager.shared.isInBulletListMode {
                    RichTextFormatterManager.shared.isInBulletListMode = false
                    
                    // Remove bullet list marker ("• ")
                    // Handle both with and without blockquote prefix: "• " or "▎ • "
                    if lineText.hasPrefix("• ") {
                        let bulletRange = NSRange(location: lineInfo.start, length: 2)
                        let deletedLength = 2
                        let deletionPoint = lineInfo.start
                        
                        attributedString.deleteCharacters(in: bulletRange)
                        
                        // Update selectedFormatters ranges
                        for (character, formatterItems) in selectedFormatters {
                            for index in 0..<formatterItems.count {
                                let itemRange = formatterItems[index].range
                                if itemRange.location >= deletionPoint + deletedLength {
                                    let newRange = NSRange(location: itemRange.location - deletedLength, length: itemRange.length)
                                    selectedFormatters[character]?[index].range = newRange
                                }
                            }
                        }
                        
                        // Adjust start position after deletion
                        if start >= lineInfo.start + 2 {
                            range = NSRange(location: start - 2, length: range.length)
                        }
                    } else if lineText.hasPrefix("▎ • ") {
                        // Blockquote + bullet: remove only the bullet part
                        let bulletRange = NSRange(location: lineInfo.start + 2, length: 2)
                        let deletedLength = 2
                        let deletionPoint = lineInfo.start + 2
                        
                        attributedString.deleteCharacters(in: bulletRange)
                        
                        // Update selectedFormatters ranges
                        for (character, formatterItems) in selectedFormatters {
                            for index in 0..<formatterItems.count {
                                let itemRange = formatterItems[index].range
                                if itemRange.location >= deletionPoint + deletedLength {
                                    let newRange = NSRange(location: itemRange.location - deletedLength, length: itemRange.length)
                                    selectedFormatters[character]?[index].range = newRange
                                }
                            }
                        }
                        
                        // Adjust start position after deletion
                        if start >= lineInfo.start + 4 {
                            range = NSRange(location: start - 2, length: range.length)
                        }
                    }
                }
            }
            
            // Save the original cursor position before applying format
            let originalCursorPosition = start
            
            // Calculate prefix length BEFORE applying format
            var prefixLength = 0
            if format == .bulletList {
                prefixLength = 2 // "• " length
            } else if format == .numberedList {
                prefixLength = 3 // "1. " length
            }
            
            // Get the line start position where the prefix will be inserted
            let insertionPoint = lineInfo.start
            
            RichTextFormatterManager.shared.applyFormat(format, to: range, in: attributedString, baseFont: style.textFieldFont)
            
            // Update selectedFormatters ranges to account for the inserted prefix
            // All ranges that start at or after the insertion point need to be shifted
            for (character, formatterItems) in selectedFormatters {
                for index in 0..<formatterItems.count {
                    let itemRange = formatterItems[index].range
                    if itemRange.location >= insertionPoint {
                        // Shift the range forward by the prefix length
                        let newRange = NSRange(location: itemRange.location + prefixLength, length: itemRange.length)
                        selectedFormatters[character]?[index].range = newRange
                    }
                }
            }
            
            // Set flag to prevent cursor adjustment during programmatic cursor setting
            isSettingCursorProgrammatically = true
            
            textView.attributedText = attributedString
            
            // New cursor position = original position + prefix length
            let newCursorPosition = originalCursorPosition + prefixLength
            
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: min(newCursorPosition, attributedString.length)) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
            
            // Reset flag after a delay to ensure all selection change events have completed
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.isSettingCursorProgrammatically = false
            }
            
            // Update toolbar state
            updateToolbarActiveFormats()
            updateSendButtonState()
            return
        }
        
        // Handle blockquote - shows a vertical bar on the left (Slack-style)
        if format == .blockquote {
            if RichTextFormatterManager.shared.isInBlockquoteMode {
                // Toggle off: hide blockquote bar
                RichTextFormatterManager.shared.isInBlockquoteMode = false
                blockquoteBarView.isHidden = true
                blockquoteStartPosition = nil
                resetBlockquoteBarToFullMode()
                
                // Reset typing attributes - preserve persistent formats if any
                if RichTextFormatterManager.shared.persistentFormats.isEmpty {
                    textView.typingAttributes = [
                        .font: style.textFieldFont,
                        .foregroundColor: style.textFieldColor
                    ]
                } else {
                    textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
                        baseFont: style.textFieldFont,
                        baseColor: style.textFieldColor
                    )
                }
            } else {
                // Toggle on: show blockquote bar
                // First, exit code block mode if active (they're mutually exclusive for new typing)
                if RichTextFormatterManager.shared.isInCodeBlockMode {
                    RichTextFormatterManager.shared.isInCodeBlockMode = false
                    // Don't hide the code block background - it will be updated to cover only the code block content
                    RichTextFormatterManager.shared.persistentFormats.remove(.codeBlock)
                    
                    // Calculate the code block text range (all current text is code block)
                    if attributedString.length > 0 {
                        let codeBlockRange = NSRange(location: 0, length: attributedString.length)
                        updateCodeBlockBackgroundForRange(codeBlockRange)
                        
                        // Keep isCodeBlockKey attribute on code block content - don't remove it!
                        // Just restore normal font for visual display (the attribute is used for markdown conversion)
                        // Actually, we should NOT change the font here - the code block content should keep its styling
                        // The new blockquote content will have different styling
                    } else {
                        codeBlockBackgroundView.isHidden = true
                        codeBlockLeftBorderView.isHidden = true
                    }
                }
                
                RichTextFormatterManager.shared.isInBlockquoteMode = true
                
                // Check if there's selected text - if so, apply blockquote to the selection
                let selectedRange = textView.selectedRange
                let hasSelection = selectedRange.length > 0
                
                if hasSelection {
                    // Apply blockquote attribute to selected text
                    attributedString.addAttribute(RichTextFormatterManager.isBlockquoteKey, value: true, range: selectedRange)
                    
                    // Set flag to prevent cursor adjustment
                    isSettingCursorProgrammatically = true
                    textView.attributedText = attributedString
                    
                    // Move cursor to end of selection
                    let newCursorPosition = selectedRange.location + selectedRange.length
                    if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
                        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                    }
                    
                    // Reset flag after a delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.isSettingCursorProgrammatically = false
                    }
                    
                    // Store the blockquote range and update bar to match
                    blockquoteTextRange = selectedRange
                    blockquoteStartPosition = nil  // Not using start position when we have a range
                    
                    // Deactivate auto-layout constraints and switch to frame-based positioning
                    NSLayoutConstraint.deactivate(blockquoteBarConstraints)
                    blockquoteBarView.translatesAutoresizingMaskIntoConstraints = true
                    
                    // Force layout update before calculating frame
                    textView.setNeedsLayout()
                    textView.layoutIfNeeded()
                    textViewContainer.setNeedsLayout()
                    textViewContainer.layoutIfNeeded()
                    
                    // Update bar frame to match the selected text
                    updateBlockquoteBarFrameForRange()
                    blockquoteBarView.isHidden = false
                    
                    // Also update after a short delay to catch any layout changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                        self?.updateBlockquoteBarFrameForRange()
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.updateBlockquoteBarFrameForRange()
                    }
                    
                    // Exit blockquote mode since we applied it to selection (like code block behavior)
                    RichTextFormatterManager.shared.isInBlockquoteMode = false
                    
                    // Reset typing attributes to normal
                    if RichTextFormatterManager.shared.persistentFormats.isEmpty {
                        textView.typingAttributes = [
                            .font: style.textFieldFont,
                            .foregroundColor: style.textFieldColor
                        ]
                    } else {
                        textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
                            baseFont: style.textFieldFont,
                            baseColor: style.textFieldColor
                        )
                    }
                } else {
                    // No selection - enter blockquote mode for new typing
                    let cursorPosition = textView.selectedRange.location
                    let textLength = textView.text?.count ?? 0
                    
                    // Deactivate auto-layout constraints and switch to frame-based positioning
                    NSLayoutConstraint.deactivate(blockquoteBarConstraints)
                    blockquoteBarView.translatesAutoresizingMaskIntoConstraints = true
                    
                    if cursorPosition > 0 || textLength > 0 {
                        // There's existing content - set blockquoteStartPosition to cursor position
                        // so blockquote only applies to new content typed from here
                        blockquoteStartPosition = cursorPosition
                        
                        // Position the bar to start at cursor position
                        if let startPos = textView.position(from: textView.beginningOfDocument, offset: cursorPosition) {
                            let caretRect = textView.caretRect(for: startPos)
                            if !caretRect.isNull && !caretRect.isInfinite && caretRect.height > 0 {
                                // Position bar starting from the cursor position
                                let barFrame = CGRect(
                                    x: -2,
                                    y: caretRect.origin.y - textView.contentOffset.y,
                                    width: 4,
                                    height: caretRect.height
                                )
                                blockquoteBarView.frame = barFrame
                            }
                        }
                        blockquoteBarView.isHidden = false
                    } else {
                        // No existing content - use full height bar
                        blockquoteStartPosition = nil
                        blockquoteBarView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate(blockquoteBarConstraints)
                        blockquoteBarView.isHidden = false
                    }
                    
                    // Preserve persistent formats (bold, italic, etc.) when entering blockquote mode
                    if RichTextFormatterManager.shared.persistentFormats.isEmpty {
                        textView.typingAttributes = [
                            .font: style.textFieldFont,
                            .foregroundColor: style.textFieldColor,
                            RichTextFormatterManager.isBlockquoteKey: true
                        ]
                    } else {
                        var typingAttrs = RichTextFormatterManager.shared.getTypingAttributes(
                            baseFont: style.textFieldFont,
                            baseColor: style.textFieldColor
                        )
                        typingAttrs[RichTextFormatterManager.isBlockquoteKey] = true
                        textView.typingAttributes = typingAttrs
                    }
                }
            }
            
            updateToolbarActiveFormats()
            updateSendButtonState()
            return
        }
        
        // Handle code block - block-level format with full-width background container
        if format == .codeBlock {
            // Check if selected text already has code block styling
            let selectedTextHasCodeBlock: Bool = {
                guard length > 0, let attributedText = textView.attributedText else { return false }
                var hasCodeBlock = false
                attributedText.enumerateAttribute(RichTextFormatterManager.isCodeBlockKey, in: range, options: []) { value, _, stop in
                    if let isCodeBlock = value as? Bool, isCodeBlock {
                        hasCodeBlock = true
                        stop.pointee = true
                    }
                }
                return hasCodeBlock
            }()
            
            // Toggle off if already in code block mode OR if selected text has code block styling
            if RichTextFormatterManager.shared.isInCodeBlockMode || selectedTextHasCodeBlock {
                RichTextFormatterManager.shared.isInCodeBlockMode = false
                codeBlockBackgroundView.isHidden = true
                codeBlockLeftBorderView.isHidden = true
                codeBlockPlaceholderLabel.isHidden = true
                codeBlockMinimumHeight = 0  // Reset minimum height
                centerTextInCodeBlock()  // Reset text container inset
                resetCodeBlockBackgroundToFullMode()
                resetTextViewMinHeight()  // Reset text view minHeight to original value
                RichTextFormatterManager.shared.persistentFormats.remove(.codeBlock)
                
                // Restore the text view placeholder
                textView.hidePlaceholder = false
                
                // Capture cursor position BEFORE any modifications
                let savedCursorPosition = textView.selectedRange
                
                // Restore mention styling - mentions should get their original colors back
                if let attributedText = textView.attributedText, attributedText.length > 0 {
                    let mutableText = NSMutableAttributedString(attributedString: attributedText)
                    let fullRange = NSRange(location: 0, length: mutableText.length)
                    
                    // Remove code block marker and restore normal font
                    mutableText.removeAttribute(RichTextFormatterManager.isCodeBlockKey, range: fullRange)
                    mutableText.addAttribute(.font, value: style.textFieldFont, range: fullRange)
                    mutableText.addAttribute(.foregroundColor, value: style.textFieldColor, range: fullRange)
                    
                    // Restore mention styling by re-processing text formatters
                    for (character, formatterItems) in selectedFormatters {
                        for (item, _) in formatterItems {
                            // Find the mention text in the attributed string and restore its styling
                            if let visibleText = item.visibleText {
                                let searchRange = NSRange(location: 0, length: mutableText.length)
                                var searchStart = searchRange.location
                                
                                while searchStart < mutableText.length {
                                    let remainingRange = NSRange(location: searchStart, length: mutableText.length - searchStart)
                                    let foundRange = (mutableText.string as NSString).range(of: visibleText, options: [], range: remainingRange)
                                    
                                    if foundRange.location != NSNotFound {
                                        // Restore mention attributes
                                        var mentionAttributes = item.visibleTextAttributes ?? [
                                            .font: style.textFieldFont,
                                            .foregroundColor: style.textFieldColor
                                        ]
                                        // Ensure mention has its proper styling
                                        mutableText.setAttributes(mentionAttributes, range: foundRange)
                                        searchStart = foundRange.location + foundRange.length
                                    } else {
                                        break
                                    }
                                }
                            }
                        }
                    }
                    
                    // Set flag to prevent cursor adjustment during programmatic cursor setting
                    isSettingCursorProgrammatically = true
                    
                    textView.attributedText = mutableText
                    
                    // Restore cursor position - ensure it's within valid bounds
                    let textLength = mutableText.length
                    let validCursorLocation = min(savedCursorPosition.location, textLength)
                    let validCursorLength = min(savedCursorPosition.length, textLength - validCursorLocation)
                    textView.selectedRange = NSRange(location: validCursorLocation, length: validCursorLength)
                    
                    // Reset flag after a delay to ensure all selection change events have completed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.isSettingCursorProgrammatically = false
                    }
                }
                
                textView.typingAttributes = [
                    .font: style.textFieldFont,
                    .foregroundColor: style.textFieldColor
                ]
                updateToolbarActiveFormats()
                updateSendButtonState()
                // Animate mic button visibility (show when exiting code block)
                updateMicrophoneButtonVisibility()
                return
            }
            
            // Enter code block mode - clear all incompatible formats
            RichTextFormatterManager.shared.isInBulletListMode = false
            RichTextFormatterManager.shared.isInNumberedListMode = false
            RichTextFormatterManager.shared.isInBlockquoteMode = false
            RichTextFormatterManager.shared.currentListNumber = 1
            RichTextFormatterManager.shared.isInCodeBlockMode = true
            
            // Clear any existing codeBlockTextRange from a previous code block
            // This ensures the new code block starts fresh
            codeBlockTextRange = nil
            
            // If there's existing blockquote content (tracked range), keep the bar visible
            // Otherwise hide it since code block and blockquote modes are mutually exclusive
            if blockquoteTextRange == nil {
                blockquoteBarView.isHidden = true
                blockquoteStartPosition = nil
                resetBlockquoteBarToFullMode()
            }
            
            // Clear all persistent formats (inline code, bold, italic, etc.) as they're incompatible with code block
            RichTextFormatterManager.shared.persistentFormats.removeAll()
            
            // Remove inline code styling from existing text if present
            if attributedString.length > 0 {
                let fullRange = NSRange(location: 0, length: attributedString.length)
                // Remove inline code background color
                attributedString.removeAttribute(.backgroundColor, range: fullRange)
                // Remove isCodeBlockKey = false markers (inline code markers)
                attributedString.enumerateAttribute(RichTextFormatterManager.isCodeBlockKey, in: fullRange, options: []) { value, attrRange, _ in
                    if let isCodeBlock = value as? Bool, !isCodeBlock {
                        // This is inline code - remove the marker
                        attributedString.removeAttribute(RichTextFormatterManager.isCodeBlockKey, range: attrRange)
                    }
                }
                
                // Strip any existing triple backticks from the text
                // This handles the case where user typed ``` before clicking the code block button
                var text = attributedString.string
                var didModify = false
                
                // Remove leading ``` if present (after any blockquote content)
                if let blockquoteRange = blockquoteTextRange {
                    // There's blockquote content - check for backticks after it
                    let afterBlockquote = blockquoteRange.location + blockquoteRange.length
                    if afterBlockquote < text.count {
                        let afterBlockquoteText = String(text.dropFirst(afterBlockquote))
                        var trimmedAfterBlockquote = afterBlockquoteText
                        
                        // Skip leading newlines/whitespace
                        while trimmedAfterBlockquote.hasPrefix("\n") || trimmedAfterBlockquote.hasPrefix(" ") || trimmedAfterBlockquote.hasPrefix("\t") {
                            trimmedAfterBlockquote = String(trimmedAfterBlockquote.dropFirst())
                        }
                        
                        if trimmedAfterBlockquote.hasPrefix("```") {
                            // Find the position of ``` in the original text
                            let backtickStart = text.count - trimmedAfterBlockquote.count
                            let backtickRange = NSRange(location: backtickStart, length: 3)
                            attributedString.deleteCharacters(in: backtickRange)
                            text = attributedString.string
                            didModify = true
                        }
                    }
                } else {
                    // No blockquote content - check for backticks at the start
                    var trimmedText = text
                    while trimmedText.hasPrefix("\n") || trimmedText.hasPrefix(" ") || trimmedText.hasPrefix("\t") {
                        trimmedText = String(trimmedText.dropFirst())
                    }
                    
                    if trimmedText.hasPrefix("```") {
                        let backtickStart = text.count - trimmedText.count
                        let backtickRange = NSRange(location: backtickStart, length: 3)
                        attributedString.deleteCharacters(in: backtickRange)
                        text = attributedString.string
                        didModify = true
                    }
                }
                
                // Remove trailing ``` if present
                var trimmedEnd = text
                while trimmedEnd.hasSuffix("\n") || trimmedEnd.hasSuffix(" ") || trimmedEnd.hasSuffix("\t") {
                    trimmedEnd = String(trimmedEnd.dropLast())
                }
                
                if trimmedEnd.hasSuffix("```") {
                    let backtickStart = trimmedEnd.count - 3
                    let backtickRange = NSRange(location: backtickStart, length: 3)
                    if backtickRange.location >= 0 && backtickRange.location + backtickRange.length <= attributedString.length {
                        attributedString.deleteCharacters(in: backtickRange)
                        didModify = true
                    }
                }
                
                // Update range if we modified the text
                if didModify {
                    range = NSRange(location: start, length: max(0, attributedString.length - start))
                }
            }
            
            let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
            
            // Case 1: Text is selected - apply code block styling to selected text
            if length > 0 {
                attributedString.addAttribute(.font, value: monoFont, range: range)
                // Don't use inline background - codeBlockBackgroundView provides the container
                attributedString.addAttribute(.foregroundColor, value: CometChatTheme.neutralColor900, range: range)
                attributedString.addAttribute(RichTextFormatterManager.isCodeBlockKey, value: true, range: range)  // Mark as code block
                textView.attributedText = attributedString
                
                // Restore cursor position after selection
                if let newPosition = textView.position(from: textView.beginningOfDocument, offset: start + length) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
                
                // Force layout update before calculating frame
                textView.layoutIfNeeded()
                
                // Show the code block background container positioned for the selected text
                // This provides the visual "container" look
                updateCodeBlockBackgroundForRange(range)
                codeBlockBackgroundView.isHidden = false
                codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                updateCodeBlockLeftBorderFrame()
                
                // Exit code block mode since we applied code block to selection
                RichTextFormatterManager.shared.isInCodeBlockMode = false
                
                // Reset typing attributes to normal after applying code block
                textView.typingAttributes = [
                    .font: style.textFieldFont,
                    .foregroundColor: style.textFieldColor
                ]
            }
            // Case 2: No selection - show full background container and enter code block mode
            else {
                // Calculate the minimum height for code block (single line height - same as empty state)
                let singleLineHeight = monoFont.lineHeight + 16  // Line height + padding
                
                // Get cursor position and text length
                let textLength = textView.text?.count ?? 0
                let cursorPosition = textView.selectedRange.location
                
                // Determine where code block should start based on existing content
                var codeBlockStart = cursorPosition
                
                // Check if there's existing blockquote content
                if let blockquoteRange = blockquoteTextRange, blockquoteRange.length > 0 {
                    // There's blockquote content - code block starts after it
                    let text = textView.text ?? ""
                    codeBlockStart = blockquoteRange.location + blockquoteRange.length
                    
                    // Skip any newlines/whitespace after blockquote
                    while codeBlockStart < textLength {
                        let index = text.index(text.startIndex, offsetBy: codeBlockStart)
                        let char = text[index]
                        if char == "\n" || char == " " || char == "\t" {
                            codeBlockStart += 1
                        } else {
                            break
                        }
                    }
                    
                    // Use cursor position if it's after the blockquote content
                    if cursorPosition > codeBlockStart {
                        codeBlockStart = cursorPosition
                    }
                }
                
                // Store the start position for code block
                codeBlockStartPosition = codeBlockStart
                
                // Set typing attributes for code block mode
                textView.typingAttributes = [
                    .font: monoFont,
                    .foregroundColor: CometChatTheme.neutralColor900,
                    RichTextFormatterManager.isCodeBlockKey: true
                ]
                
                // Hide the text view placeholder when in code block mode
                textView.hidePlaceholder = true
                
                // Check if there's existing content above the cursor
                if codeBlockStart > 0 {
                    // There's content above - position code block background from cursor position
                    let text = textView.text ?? ""
                    
                    // Check if we need to insert a newline before the code block
                    var needsNewlineBefore = false
                    
                    if codeBlockStart > 0 && codeBlockStart <= text.count {
                        let charBeforeIndex = text.index(text.startIndex, offsetBy: codeBlockStart - 1)
                        if text[charBeforeIndex] != "\n" {
                            needsNewlineBefore = true
                        }
                    }
                    
                    // Insert newline if needed to separate from content above
                    if needsNewlineBefore {
                        let mutableAttrString = NSMutableAttributedString(attributedString: attributedString)
                        
                        let normalAttrs: [NSAttributedString.Key: Any] = [
                            .font: style.textFieldFont,
                            .foregroundColor: style.textFieldColor
                        ]
                        let newlineString = NSAttributedString(string: "\n", attributes: normalAttrs)
                        mutableAttrString.insert(newlineString, at: codeBlockStart)
                        
                        textView.attributedText = mutableAttrString
                        
                        // Code block starts after the newline (separator)
                        let newCodeBlockStart = codeBlockStart + 1
                        codeBlockStartPosition = newCodeBlockStart
                        
                        // Move cursor to the code block line
                        if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCodeBlockStart) {
                            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                        }
                    } else {
                        codeBlockStartPosition = codeBlockStart
                    }
                    
                    // Store minimum height for future updates
                    codeBlockMinimumHeight = singleLineHeight
                    
                    // Don't center text when there's content above
                    textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
                    
                    // IMPORTANT: Ensure the text view has enough height for text above + code block
                    // Calculate the required height: text above + newline + code block line
                    let textAboveHeight = style.textFieldFont.lineHeight * CGFloat(max(1, (textView.text?.components(separatedBy: "\n").count ?? 1)))
                    let requiredHeight = textAboveHeight + singleLineHeight + 16  // text + code block + padding
                    
                    // Store original minHeight before modifying (only if not already stored)
                    if originalTextViewMinHeight == nil {
                        originalTextViewMinHeight = textView.minHeight
                    }
                    
                    // Update minHeight to ensure text view grows
                    let currentMinHeight = textView.minHeight
                    if requiredHeight > currentMinHeight {
                        textView.minHeight = requiredHeight
                    }
                    
                    // Force layout
                    textView.setNeedsLayout()
                    textView.layoutIfNeeded()
                    textViewContainer.setNeedsLayout()
                    textViewContainer.layoutIfNeeded()
                    invalidateIntrinsicContentSize()
                    setNeedsLayout()
                    layoutIfNeeded()
                    
                    // Calculate the Y position for the code block background
                    let bgHeight = singleLineHeight
                    
                    // Get the actual cursor/text position on the code block line
                    var codeBlockLineY: CGFloat = 0
                    var codeBlockLineHeight: CGFloat = monoFont.lineHeight
                    var textAboveBottomY: CGFloat = 0  // Bottom of the text above
                    
                    if let codeBlockStartPos = codeBlockStartPosition, codeBlockStartPos > 0 {
                        // Get the caret rect at the code block start position (where cursor is)
                        if let codeBlockPos = textView.position(from: textView.beginningOfDocument, offset: codeBlockStartPos) {
                            let caretRect = textView.caretRect(for: codeBlockPos)
                            if !caretRect.isNull && !caretRect.isInfinite && caretRect.height > 0 {
                                codeBlockLineY = caretRect.origin.y - textView.contentOffset.y
                                codeBlockLineHeight = caretRect.height
                            }
                        }
                        
                        // Get the bottom of the text above (for ensuring gap)
                        let charBeforeCodeBlock = codeBlockStartPos - 1
                        if charBeforeCodeBlock > 0 {
                            if let beforeNewlinePos = textView.position(from: textView.beginningOfDocument, offset: charBeforeCodeBlock - 1) {
                                let beforeRect = textView.caretRect(for: beforeNewlinePos)
                                if !beforeRect.isNull && !beforeRect.isInfinite && beforeRect.height > 0 {
                                    textAboveBottomY = beforeRect.origin.y + beforeRect.height - textView.contentOffset.y
                                    
                                    // Fallback: if we couldn't get cursor position, use text above position
                                    if codeBlockLineY == 0 {
                                        codeBlockLineY = textAboveBottomY
                                    }
                                }
                            }
                        }
                    }
                    
                    // Fallback: use the line height to calculate position
                    if codeBlockLineY == 0 {
                        let lineHeight = style.textFieldFont.lineHeight
                        codeBlockLineY = lineHeight + textView.textContainerInset.top
                        textAboveBottomY = codeBlockLineY
                    }
                    
                    // Position the code block background so the text line is vertically centered within it
                    // The background should extend equally above and below the text line
                    let verticalPaddingInBackground = (bgHeight - codeBlockLineHeight) / 2
                    var bgY = codeBlockLineY - verticalPaddingInBackground
                    
                    // Ensure minimum gap from text above (at least 2pt)
                    let minGap: CGFloat = 2
                    if textAboveBottomY > 0 && bgY < textAboveBottomY + minGap {
                        bgY = textAboveBottomY + minGap
                    }
                    
                    // Position the code block background with animation
                    NSLayoutConstraint.deactivate(codeBlockBackgroundConstraints)
                    codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = true
                    
                    let bgFrame = CGRect(
                        x: 0,
                        y: bgY,
                        width: textViewContainer.bounds.width,
                        height: bgHeight
                    )
                    codeBlockBackgroundView.frame = bgFrame
                    codeBlockBackgroundView.alpha = 0
                    codeBlockBackgroundView.isHidden = false
                    codeBlockLeftBorderView.isHidden = true
                    
                    // Animate the appearance
                    UIView.animate(withDuration: 0.2) {
                        self.codeBlockBackgroundView.alpha = 1
                    }
                    
                    updateToolbarActiveFormats()
                    updateSendButtonState()
                    return
                } else {
                    // No existing content - apply code block to all text (or empty state)
                    codeBlockStartPosition = nil  // Reset since we're starting from the beginning
                    
                    // Store minimum height for consistent appearance
                    codeBlockMinimumHeight = singleLineHeight
                    
                    // Center text vertically in code block
                    centerTextInCodeBlock()
                    
                    if attributedString.length > 0 {
                        let fullRange = NSRange(location: 0, length: attributedString.length)
                        attributedString.removeAttribute(.backgroundColor, range: fullRange)
                        attributedString.addAttribute(.font, value: monoFont, range: fullRange)
                        attributedString.addAttribute(.foregroundColor, value: CometChatTheme.neutralColor900, range: fullRange)
                        attributedString.addAttribute(RichTextFormatterManager.isCodeBlockKey, value: true, range: fullRange)
                        textView.attributedText = attributedString
                    }
                    
                    // Set typing attributes for code block mode (NO background - codeBlockBackgroundView handles it)
                    textView.typingAttributes = [
                        .font: monoFont,
                        .foregroundColor: CometChatTheme.neutralColor900,
                        RichTextFormatterManager.isCodeBlockKey: true  // Mark as code block
                    ]
                    
                    // Hide the text view placeholder when in code block mode
                    textView.hidePlaceholder = true
                    
                    // Show code block background with smooth animation
                    resetCodeBlockBackgroundToFullMode()
                    codeBlockBackgroundView.alpha = 0
                    codeBlockBackgroundView.isHidden = false
                    codeBlockLeftBorderView.isHidden = true  // No purple left border
                    
                    // Force layout first to calculate proper size
                    textViewContainer.setNeedsLayout()
                    textViewContainer.layoutIfNeeded()
                    
                    // Animate the appearance
                    UIView.animate(withDuration: 0.2) {
                        self.codeBlockBackgroundView.alpha = 1
                    }
                }
            }
            
            updateToolbarActiveFormats()
            updateSendButtonState()
            return
        }
        
        // For inline formats without selection, toggle persistent format for future typing
        if length == 0 {
            
            // Handle format compatibility when toggling persistent formats
            if format == .code {
                // Inline code is incompatible with Bold, Italic, Underline, Strike, Code Block
                if RichTextFormatterManager.shared.persistentFormats.contains(.code) {
                    // Toggling off - just remove it
                    RichTextFormatterManager.shared.togglePersistentFormat(format)
                } else {
                    // Toggling on - remove incompatible formats first
                    RichTextFormatterManager.shared.persistentFormats.remove(.bold)
                    RichTextFormatterManager.shared.persistentFormats.remove(.italic)
                    RichTextFormatterManager.shared.persistentFormats.remove(.underline)
                    RichTextFormatterManager.shared.persistentFormats.remove(.strikethrough)
                    RichTextFormatterManager.shared.persistentFormats.remove(.codeBlock)
                    
                    // If switching from code block mode, exit it
                    if RichTextFormatterManager.shared.isInCodeBlockMode {
                        RichTextFormatterManager.shared.isInCodeBlockMode = false
                        codeBlockBackgroundView.isHidden = true
                        codeBlockLeftBorderView.isHidden = true
                        codeBlockPlaceholderLabel.isHidden = true
                        resetCodeBlockBackgroundToFullMode()
                        resetTextViewMinHeight()  // Reset text view minHeight to original value
                        
                        // Restore the text view placeholder
                        textView.hidePlaceholder = false
                    }
                    
                    RichTextFormatterManager.shared.togglePersistentFormat(format)
                }
            } else if format == .bold || format == .italic || format == .underline || format == .strikethrough {
                // Text formats are incompatible with Inline Code and Code Block
                if RichTextFormatterManager.shared.persistentFormats.contains(format) {
                    // Toggling off - just remove it
                    RichTextFormatterManager.shared.togglePersistentFormat(format)
                } else {
                    // Toggling on - remove incompatible formats first
                    RichTextFormatterManager.shared.persistentFormats.remove(.code)
                    RichTextFormatterManager.shared.persistentFormats.remove(.codeBlock)
                    
                    // If switching from code block mode, exit it
                    if RichTextFormatterManager.shared.isInCodeBlockMode {
                        RichTextFormatterManager.shared.isInCodeBlockMode = false
                        codeBlockBackgroundView.isHidden = true
                        codeBlockLeftBorderView.isHidden = true
                        codeBlockPlaceholderLabel.isHidden = true
                        resetCodeBlockBackgroundToFullMode()
                        resetTextViewMinHeight()  // Reset text view minHeight to original value
                        
                        // Restore the text view placeholder
                        textView.hidePlaceholder = false
                    }
                    
                    RichTextFormatterManager.shared.togglePersistentFormat(format)
                }
            } else {
                // Other formats - just toggle
                RichTextFormatterManager.shared.togglePersistentFormat(format)
            }
            
            // Update typing attributes to reflect persistent formats
            
            // If no persistent formats, reset to default typing attributes
            if RichTextFormatterManager.shared.persistentFormats.isEmpty {
                textView.typingAttributes = [
                    .font: style.textFieldFont,
                    .foregroundColor: style.textFieldColor
                ]
            } else {
                textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
                    baseFont: style.textFieldFont,
                    baseColor: style.textFieldColor
                )
            }
            updateToolbarActiveFormats()
            return
        }
        
        // Check if format is already active
        let activeFormats = RichTextFormatterManager.shared.detectActiveFormats(in: attributedString, at: range)
        
        if activeFormats.contains(format) {
            // Remove format, skipping mention ranges
            RichTextFormatterManager.shared.removeFormat(format, from: range, in: attributedString, baseFont: style.textFieldFont, skippingRanges: mentionRangesInSelection)
            // Also remove from persistent formats if present
            RichTextFormatterManager.shared.persistentFormats.remove(format)
        } else {
            // Apply format - handle compatibility
            if format == .code {
                // Inline code is incompatible with Bold, Italic, Underline, Strike
                // Remove these formats from the selected range first, skipping mentions
                RichTextFormatterManager.shared.removeFormat(.bold, from: range, in: attributedString, baseFont: style.textFieldFont, skippingRanges: mentionRangesInSelection)
                RichTextFormatterManager.shared.removeFormat(.italic, from: range, in: attributedString, baseFont: style.textFieldFont, skippingRanges: mentionRangesInSelection)
                RichTextFormatterManager.shared.removeFormat(.underline, from: range, in: attributedString, baseFont: style.textFieldFont, skippingRanges: mentionRangesInSelection)
                RichTextFormatterManager.shared.removeFormat(.strikethrough, from: range, in: attributedString, baseFont: style.textFieldFont, skippingRanges: mentionRangesInSelection)
            } else if format == .bold || format == .italic || format == .underline || format == .strikethrough {
                // Text formats are incompatible with Inline Code
                // Remove inline code from the selected range first, skipping mentions
                RichTextFormatterManager.shared.removeFormat(.code, from: range, in: attributedString, baseFont: style.textFieldFont, skippingRanges: mentionRangesInSelection)
            }
            
            // Apply format, skipping mention ranges so mentions don't get formatted
            RichTextFormatterManager.shared.applyFormat(format, to: range, in: attributedString, baseFont: style.textFieldFont, skippingRanges: mentionRangesInSelection)
            // Also remove from persistent formats since we've applied it to selected text
            RichTextFormatterManager.shared.persistentFormats.remove(format)
        }
        
        // Set flag to prevent cursor adjustment during programmatic changes
        isSettingCursorProgrammatically = true
        
        textView.attributedText = attributedString
        
        // Restore selection
        if let newStart = textView.position(from: textView.beginningOfDocument, offset: start),
           let newEnd = textView.position(from: newStart, offset: length) {
            textView.selectedTextRange = textView.textRange(from: newStart, to: newEnd)
        }
        
        // Reset flag after a delay to ensure all selection change events have completed
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.isSettingCursorProgrammatically = false
        }
        
        // Update toolbar to reflect active formats
        updateToolbarActiveFormats()
        updateSendButtonState()
    }
    
    /// Shows a native iOS alert dialog for adding a link with text and URL fields
    /// - Parameter range: The current selection range in the text view
    private func showAddLinkAlert(at range: NSRange) {
        
        // Guard against nil controller - can't present alert without it
        guard let controller = controller else {
            return
        }
        
        
        let alert = UIAlertController(
            title: "ADD_LINK".localize(),
            message: nil,
            preferredStyle: .alert
        )
        
        
        // Validate and adjust range to be within bounds
        let attributedText = textView.attributedText ?? NSAttributedString()
        let maxLength = attributedText.length
        
        
        // Ensure range is valid
        var validRange = range
        if range.location < 0 {
            validRange.location = 0
        }
        if range.location > maxLength {
            validRange.location = maxLength
        }
        if range.location + range.length > maxLength {
            validRange.length = maxLength - range.location
        }
        
        
        // Get selected text if any to pre-fill the text field
        var selectedText = ""
        if validRange.length > 0 {
            selectedText = (attributedText.string as NSString).substring(with: validRange)
        }
        
        
        // Add text field for display text
        alert.addTextField { textField in
            textField.placeholder = "ENTER_TEXT".localize()
            textField.text = selectedText
            textField.autocapitalizationType = .sentences
            textField.clearButtonMode = .whileEditing
        }
        
        
        // Add text field for URL
        alert.addTextField { textField in
            textField.placeholder = "ENTER_LINK_URL".localize()
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.clearButtonMode = .whileEditing
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "CANCEL".localize(), style: .cancel) { [weak self] _ in
            self?.textView.becomeFirstResponder()
        }
        
        // Save action
        let saveAction = UIAlertAction(title: "SAVE".localize(), style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let displayText = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let urlString = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            // Validate that URL is provided (text is optional)
            guard !urlString.isEmpty else {
                self.textView.becomeFirstResponder()
                return
            }
            
            // If no display text provided, use the URL as display text
            let finalDisplayText = displayText.isEmpty ? urlString : displayText
            
            // Add https:// prefix if no scheme is provided
            var finalURLString = urlString
            if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
                finalURLString = "https://" + urlString
            }
            
            // Insert the link into the text view with the validated range
            self.insertLink(displayText: finalDisplayText, url: finalURLString, at: validRange)
            self.textView.becomeFirstResponder()
        }
        
        // Initially disable save button
        saveAction.isEnabled = false
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        // Add text change observers to enable/disable save button
        // We need at least a URL to enable the save button
        let textChangeHandler: (UITextField) -> Void = { _ in
            let urlText = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            saveAction.isEnabled = !urlText.isEmpty
        }
        
        // Observe text changes in both fields
        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: alert.textFields?[0],
            queue: .main
        ) { _ in
            textChangeHandler(alert.textFields?[0] ?? UITextField())
        }
        
        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: alert.textFields?[1],
            queue: .main
        ) { _ in
            textChangeHandler(alert.textFields?[1] ?? UITextField())
        }
        
        // Present the alert with dismiss gesture
        presentAlertWithDismissGesture(alert)
    }
    
    /// Presents an alert with tap-to-dismiss functionality
    /// - Parameter alert: The UIAlertController to present
    private func presentAlertWithDismissGesture(_ alert: UIAlertController) {
        controller?.present(alert, animated: true) { [weak self, weak alert] in
            guard let self = self, let alert = alert else { return }
            
            // Add tap gesture to the dimming view (superview of alert view)
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissAlertOnTapOutside(_:)))
            tapGesture.cancelsTouchesInView = false
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(tapGesture)
        }
    }
    
    /// Dismisses the presented alert when tapping outside
    @objc private func dismissAlertOnTapOutside(_ gesture: UITapGestureRecognizer) {
        guard let alertController = controller?.presentedViewController as? UIAlertController else { return }
        
        let tapLocation = gesture.location(in: alertController.view)
        
        // Check if tap is outside the alert view
        if !alertController.view.bounds.contains(tapLocation) {
            alertController.dismiss(animated: true) { [weak self] in
                self?.textView.becomeFirstResponder()
            }
        }
    }
    
    /// Inserts a formatted link into the text view at the specified range
    /// - Parameters:
    ///   - displayText: The text to display for the link
    ///   - url: The URL string for the link
    ///   - range: The range where the link should be inserted (replaces selected text if any)
    private func insertLink(displayText: String, url: String, at range: NSRange) {
        guard let currentAttributedText = textView.attributedText else {
            print("No attributed text available")
            return
        }
        
        let attributedString = NSMutableAttributedString(attributedString: currentAttributedText)
        let maxLength = attributedString.length
        
        // Validate range is within bounds - be extra defensive
        guard range.location >= 0 && range.location <= maxLength else {
            print("Invalid range location: \(range.location), string length: \(maxLength)")
            // Fallback: insert at end
            let fallbackRange = NSRange(location: maxLength, length: 0)
            insertLinkInternal(displayText: displayText, url: url, at: fallbackRange, in: attributedString)
            return
        }
        
        guard range.location + range.length <= maxLength else {
            print("Invalid range: \(range), string length: \(maxLength)")
            // Fallback: adjust range to fit
            let adjustedLength = maxLength - range.location
            let adjustedRange = NSRange(location: range.location, length: max(0, adjustedLength))
            insertLinkInternal(displayText: displayText, url: url, at: adjustedRange, in: attributedString)
            return
        }
        
        insertLinkInternal(displayText: displayText, url: url, at: range, in: attributedString)
    }
    
    /// Internal method to perform the actual link insertion
    private func insertLinkInternal(displayText: String, url: String, at range: NSRange, in attributedString: NSMutableAttributedString) {
        // Create link attributes
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .font: style.textFieldFont,
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: url
        ]
        
        let linkAttributedString = NSAttributedString(string: displayText, attributes: linkAttributes)
        
        // Replace the range with the link (or insert at cursor if no selection)
        if range.length > 0 {
            attributedString.replaceCharacters(in: range, with: linkAttributedString)
        } else {
            attributedString.insert(linkAttributedString, at: range.location)
        }
        
        // Add a space after the link for easier typing
        let spaceAttributes: [NSAttributedString.Key: Any] = [
            .font: style.textFieldFont,
            .foregroundColor: style.textFieldColor
        ]
        let spaceString = NSAttributedString(string: " ", attributes: spaceAttributes)
        
        // Calculate position for space insertion with bounds checking
        let spaceInsertPosition = range.location + displayText.count
        if spaceInsertPosition >= 0 && spaceInsertPosition <= attributedString.length {
            attributedString.insert(spaceString, at: spaceInsertPosition)
        } else {
            print("Cannot insert space at position \(spaceInsertPosition), string length: \(attributedString.length)")
        }
        
        textView.attributedText = attributedString
        
        // Move cursor after the link and space
        let newCursorPosition = min(max(0, range.location + displayText.count + 1), attributedString.length)
        if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
        
        // Reset typing attributes based on current mode
        if RichTextFormatterManager.shared.isInBlockquoteMode {
            // In blockquote mode, preserve persistent formats (bold, italic, etc.)
            if RichTextFormatterManager.shared.persistentFormats.isEmpty {
                textView.typingAttributes = [
                    .font: style.textFieldFont,
                    .foregroundColor: style.textFieldColor
                ]
            } else {
                textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
                    baseFont: style.textFieldFont,
                    baseColor: style.textFieldColor
                )
            }
        } else if RichTextFormatterManager.shared.isInCodeBlockMode {
            textView.typingAttributes = [
                .font: UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular),
                .foregroundColor: style.textFieldColor
            ]
        } else if !RichTextFormatterManager.shared.persistentFormats.isEmpty {
            textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
                baseFont: style.textFieldFont,
                baseColor: style.textFieldColor
            )
        } else {
            textView.typingAttributes = [
                .font: style.textFieldFont,
                .foregroundColor: style.textFieldColor
            ]
        }
        
        updateToolbarActiveFormats()
        updateSendButtonState()
    }
    
    /// Shows an alert with options to Edit or Remove a link when tapped
    /// - Parameters:
    ///   - linkText: The display text of the link
    ///   - url: The URL string of the link
    ///   - range: The range of the link in the text view
    func showLinkOptionsAlert(linkText: String, url: String, range: NSRange) {
        let alert = UIAlertController(
            title: "LINK".localize(),
            message: nil,
            preferredStyle: .alert
        )
        
        // Create attributed string for the URL to display it in blue
        let messageAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 13),
            .foregroundColor: UIColor.systemBlue
        ]
        let attributedMessage = NSAttributedString(string: url, attributes: messageAttributes)
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        // Edit action
        let editAction = UIAlertAction(title: "EDIT".localize(), style: .default) { [weak self] _ in
            guard let self = self else { return }
            // Open the add link alert with pre-filled values for editing
            self.editLink(displayText: linkText, url: url, at: range)
        }
        
        // Remove action
        let removeAction = UIAlertAction(title: "REMOVE".localize(), style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            self.removeLink(at: range, linkText: linkText)
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: nil)
        
        alert.addAction(editAction)
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        
        // Present the alert with dismiss gesture
        presentAlertWithDismissGesture(alert)
    }
    
    /// Opens the add link alert with pre-filled values for editing an existing link
    /// - Parameters:
    ///   - displayText: The current display text of the link
    ///   - url: The current URL of the link
    ///   - range: The range of the link in the text view
    private func editLink(displayText: String, url: String, at range: NSRange) {
        let alert = UIAlertController(
            title: "EDIT_LINK".localize(),
            message: nil,
            preferredStyle: .alert
        )
        
        // Add text field for display text (pre-filled)
        alert.addTextField { textField in
            textField.placeholder = "ENTER_TEXT".localize()
            textField.text = displayText
            textField.autocapitalizationType = .sentences
            textField.clearButtonMode = .whileEditing
        }
        
        // Add text field for URL (pre-filled)
        alert.addTextField { textField in
            textField.placeholder = "ENTER_LINK_URL".localize()
            textField.text = url
            textField.keyboardType = .URL
            textField.autocapitalizationType = .none
            textField.autocorrectionType = .no
            textField.clearButtonMode = .whileEditing
        }
        
        // Cancel action
        let cancelAction = UIAlertAction(title: "CANCEL".localize(), style: .cancel) { [weak self] _ in
            self?.textView.becomeFirstResponder()
        }
        
        // Save action
        let saveAction = UIAlertAction(title: "SAVE".localize(), style: .default) { [weak self] _ in
            guard let self = self else { return }
            
            let newDisplayText = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let newUrlString = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            
            // Validate that URL is provided
            guard !newUrlString.isEmpty else {
                self.textView.becomeFirstResponder()
                return
            }
            
            // If no display text provided, use the URL as display text
            let finalDisplayText = newDisplayText.isEmpty ? newUrlString : newDisplayText
            
            // Add https:// prefix if no scheme is provided
            var finalURLString = newUrlString
            if !newUrlString.lowercased().hasPrefix("http://") && !newUrlString.lowercased().hasPrefix("https://") {
                finalURLString = "https://" + newUrlString
            }
            
            // Update the link by replacing it at the same range
            self.updateLink(displayText: finalDisplayText, url: finalURLString, at: range)
            self.textView.becomeFirstResponder()
        }
        
        // Enable save button by default since we're editing an existing link
        saveAction.isEnabled = true
        
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        
        // Add text change observers to enable/disable save button
        let textChangeHandler: (UITextField) -> Void = { _ in
            let urlText = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            saveAction.isEnabled = !urlText.isEmpty
        }
        
        // Observe text changes in URL field
        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: alert.textFields?[1],
            queue: .main
        ) { _ in
            textChangeHandler(alert.textFields?[1] ?? UITextField())
        }
        
        // Present the alert with dismiss gesture
        presentAlertWithDismissGesture(alert)
    }
    
    /// Updates an existing link with new display text and URL
    /// - Parameters:
    ///   - displayText: The new display text for the link
    ///   - url: The new URL for the link
    ///   - range: The range of the existing link to replace
    private func updateLink(displayText: String, url: String, at range: NSRange) {
        guard let currentAttributedText = textView.attributedText else { return }
        
        let attributedString = NSMutableAttributedString(attributedString: currentAttributedText)
        
        // Validate range
        guard range.location >= 0 && range.location + range.length <= attributedString.length else {
            return
        }
        
        // Create new link attributes
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .font: style.textFieldFont,
            .foregroundColor: UIColor.systemBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: url
        ]
        
        let linkAttributedString = NSAttributedString(string: displayText, attributes: linkAttributes)
        
        // Replace the old link with the new one
        attributedString.replaceCharacters(in: range, with: linkAttributedString)
        
        textView.attributedText = attributedString
        
        // Move cursor after the updated link
        let newCursorPosition = min(range.location + displayText.count, attributedString.length)
        if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
        
        updateToolbarActiveFormats()
        updateSendButtonState()
    }
    
    /// Removes a link from the text view, keeping only the display text
    /// - Parameters:
    ///   - range: The range of the link to remove
    ///   - linkText: The display text of the link (to preserve)
    private func removeLink(at range: NSRange, linkText: String) {
        guard let currentAttributedText = textView.attributedText else { return }
        
        let attributedString = NSMutableAttributedString(attributedString: currentAttributedText)
        
        // Validate range
        guard range.location >= 0 && range.location + range.length <= attributedString.length else {
            return
        }
        
        // Create plain text attributes (no link, no underline)
        let plainTextAttributes: [NSAttributedString.Key: Any] = [
            .font: style.textFieldFont,
            .foregroundColor: style.textFieldColor
        ]
        
        let plainTextString = NSAttributedString(string: linkText, attributes: plainTextAttributes)
        
        // Replace the link with plain text
        attributedString.replaceCharacters(in: range, with: plainTextString)
        
        textView.attributedText = attributedString
        
        // Move cursor after the text
        let newCursorPosition = min(range.location + linkText.count, attributedString.length)
        if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
            textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
        }
        
        updateToolbarActiveFormats()
        updateSendButtonState()
        
        // Bring keyboard back
        textView.becomeFirstResponder()
    }
    
    /// Gets line information for the line containing the given position
    func getLineInfo(at position: Int, in text: String) -> (start: Int, length: Int) {
        guard !text.isEmpty else { return (0, 0) }
        
        let nsText = text as NSString
        let safePosition = min(position, nsText.length)
        
        // Find start of line
        var lineStart = safePosition
        while lineStart > 0 && nsText.character(at: lineStart - 1) != Character("\n").asciiValue! {
            lineStart -= 1
        }
        
        // Find end of line
        var lineEnd = safePosition
        while lineEnd < nsText.length && nsText.character(at: lineEnd) != Character("\n").asciiValue! {
            lineEnd += 1
        }
        
        return (lineStart, lineEnd - lineStart)
    }
    
    /// Updates toolbar button states based on current cursor position
    /// This method gets active formats from RichTextFormatterManager and updates the toolbar
    internal func updateToolbarButtonStates() {
        let manager = RichTextFormatterManager.shared
        let activeFormats = manager.activeFormats
        
        richTextToolbar.updateButtonStates(for: activeFormats)
        richTextToolbar.setActiveFormats(activeFormats)
    }
    
    /// Updates the toolbar to show active formats at current cursor position
    func updateToolbarActiveFormats() {
        // IMPORTANT: Don't update toolbar if a mention is being typed - keep buttons disabled
        if ongoingTextFormatter != nil {
            return
        }
        
        guard let selectedRange = textView.selectedTextRange else { return }
        
        let start = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
        let length = textView.offset(from: selectedRange.start, to: selectedRange.end)
        
        
        // If text is empty, check if we're in a special mode (code block, blockquote, list)
        // OR if we have persistent formats (like inline code, bold, italic, etc.)
        // If so, don't reset - just update the toolbar to show the active mode/formats
        guard let attributedText = textView.attributedText, attributedText.length > 0 else {
            // Check if we're in any special formatting mode OR have persistent formats
            let isInSpecialMode = RichTextFormatterManager.shared.isInCodeBlockMode ||
                                 RichTextFormatterManager.shared.isInBlockquoteMode ||
                                 RichTextFormatterManager.shared.isInBulletListMode ||
                                 RichTextFormatterManager.shared.isInNumberedListMode
            
            let hasPersistentFormats = !RichTextFormatterManager.shared.persistentFormats.isEmpty
            
            
            if isInSpecialMode || hasPersistentFormats {
                // Don't reset - just update toolbar to show active modes and persistent formats
                var formats: Set<FormatType> = []
                if RichTextFormatterManager.shared.isInCodeBlockMode {
                    formats.insert(.codeBlock)
                }
                if RichTextFormatterManager.shared.isInBlockquoteMode {
                    formats.insert(.blockquote)
                }
                if RichTextFormatterManager.shared.isInBulletListMode {
                    formats.insert(.bulletList)
                }
                if RichTextFormatterManager.shared.isInNumberedListMode {
                    formats.insert(.numberedList)
                }
                // Add persistent formats (inline code, bold, italic, etc.)
                formats.formUnion(RichTextFormatterManager.shared.persistentFormats)
                
                // When in code block mode, remove inline code to avoid confusion
                if RichTextFormatterManager.shared.isInCodeBlockMode {
                    formats.remove(.code)
                }
                
                richTextToolbar.setActiveFormats(formats)
                richTextToolbar.updateButtonStates(for: formats)
            } else {
                // Reset all formatting modes when text is completely empty and no special mode is active
                RichTextFormatterManager.shared.resetAllFormats()
                resetTextViewMinHeight()  // Reset text view minHeight to original value
                
                // Enable all buttons since there's no text
                richTextToolbar.enableAllButtons()
                richTextToolbar.setActiveFormats([])
            }
            return
        }
        
        
        // Create range for cursor position or selection
        // For cursor position (no selection), check the character BEFORE the cursor
        // This ensures we detect formatting when cursor is at the end of formatted text
        var checkLocation = start
        if length == 0 && start > 0 {
            // No selection - check the character before cursor to detect formatting
            checkLocation = start - 1
        }
        let range = NSRange(location: checkLocation, length: max(1, length))
        
        
        // Detect active formats at cursor position or selection
        var activeFormats = RichTextFormatterManager.shared.detectActiveFormats(
            in: attributedText,
            at: range
        )
        
        
        // IMPORTANT: For inline formats (bold, italic, underline, strikethrough, code) when there's no selection,
        // use persistentFormats instead of detected formats from text attributes.
        // This ensures that when user toggles OFF a format, the toolbar reflects the change immediately,
        // even if the cursor is positioned after formatted text.
        if length == 0 {
            // Remove inline formats detected from text - we'll use persistentFormats instead
            let inlineFormats: Set<FormatType> = [.bold, .italic, .underline, .strikethrough, .code]
            activeFormats.subtract(inlineFormats)
            // Add the current persistent formats (what will be applied to new text)
            activeFormats.formUnion(RichTextFormatterManager.shared.persistentFormats.intersection(inlineFormats))
        }
        
        // Also check list modes and persistent formats
        var formats = activeFormats
        
        // Ensure mutual exclusivity: only one list type can be active at a time
        if RichTextFormatterManager.shared.isInBulletListMode {
            formats.insert(.bulletList)
            formats.remove(.numberedList) // Ensure numbered list is not shown as active
        }
        if RichTextFormatterManager.shared.isInNumberedListMode {
            formats.insert(.numberedList)
            formats.remove(.bulletList) // Ensure bullet list is not shown as active
        }
        
        if RichTextFormatterManager.shared.isInBlockquoteMode {
            formats.insert(.blockquote)
        }
        if RichTextFormatterManager.shared.isInCodeBlockMode {
            formats.insert(.codeBlock)
            // When in code block mode, remove inline code to avoid confusion
            formats.remove(.code)
        }
        
        
        richTextToolbar.setActiveFormats(formats)
        richTextToolbar.updateButtonStates(for: formats)
    }
    
    // MARK: - Preview Methods
    
    func showReplyPreview(for message: BaseMessage) {
        composerState = .reply
        viewModel.quotedMessage = message
        viewModel.quotedMessageId = message.id
        
        // Remove existing preview if any
        messagePreview.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        let isUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
        
        let preview = CometChatMessagePreview.makePreview(
            for: message,
            isLoggedInUser: isUser,
            textFormatters: viewModel.textFormatter,
            formattingType: .COMPOSER,
            style: nil,
            onPreviewClicked: nil,
            onCrossClicked: { [weak self] in
                CometChatMessageEvents.ccReplyToMessage(message: message, status: .error)
                self?.viewModel.quotedMessage = nil
                self?.hideReplyPreview()
            },
            hideCloseButton: false
        )
        
        messagePreview.addArrangedSubview(preview)
        preview.topAnchor.constraint(equalTo: messagePreview.topAnchor, constant: 4).isActive = true
        messagePreview.isHidden = false
        
        textView.becomeFirstResponder()
    }
    
    open func presentEditPreview(for message: BaseMessage) {
        self.sendButton.isEnabled = true
        
        // Use agentic styling if user is agentic
        let isAgentic = viewModel.user?.isAgentic ?? false
        if isAgentic {
            self.sendButton.backgroundColor = style.agenticActiveSendButtonBackgroundColor
        } else {
            self.sendButton.backgroundColor = style.activeSendButtonBackgroundColor
        }
        
        if let textMessage = message as? TextMessage {
            // Parse markdown to show formatted text in preview instead of raw markdown
            let previewText: NSAttributedString
            if enableRichTextFormatting && RichTextFormatterManager.shared.containsMarkdownFormatting(textMessage.text) {
                // First, process text formatters to convert mention tags to display names
                let processedAttributedString = MessageUtils.processTextFormatter(
                    message: textMessage,
                    textFormatter: viewModel.textFormatter,
                    formattingType: .COMPOSER
                )
                let processedText = processedAttributedString.string
                
                // Parse markdown to create formatted attributed string for preview
                let composerStyle = MessageComposerStyle()
                previewText = RichTextFormatterManager.shared.parseMarkdown(
                    processedText,
                    baseFont: composerStyle.editPreviewMessageTextFont,
                    baseColor: composerStyle.editPreviewMessageTextColor,
                    addNewlinesAroundCodeBlocks: false
                )
            } else {
                // No markdown, process text formatters (mentions, etc.)
                previewText = MessageUtils.processTextFormatter(message: textMessage, textFormatter: viewModel.textFormatter, formattingType: .COMPOSER)
            }
            
            let editPreviewView = MessagePreviewView(title: "EDIT_MESSAGE".localize(), subTitle: previewText, style: MessageComposerStyle())
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
    
    func hideReplyPreview() {
        composerState = .draft
        viewModel.quotedMessage = nil
        viewModel.quotedMessageId = nil
        
        DispatchQueue.main.async { [weak self] in
            self?.messagePreview.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self?.messagePreview.isHidden = true
            self?.textView.resignFirstResponder()
        }
    }
    
    open func hideEditPreview() {
        composerState = .draft
        originalEditText = nil
        
        // Reset all formatting state
        RichTextFormatterManager.shared.resetListMode()
        RichTextFormatterManager.shared.resetAllFormats()
        
        // Hide code block background and reset state
        codeBlockBackgroundView.isHidden = true
        codeBlockLeftBorderView.isHidden = true
        codeBlockPlaceholderLabel.isHidden = true
        codeBlockStartPosition = nil
        codeBlockTextRange = nil
        codeBlockMinimumHeight = 0
        resetCodeBlockBackgroundToFullMode()
        resetTextViewMinHeight()
        centerTextInCodeBlock()
        
        // Hide blockquote bar and reset state
        blockquoteBarView.isHidden = true
        blockquoteStartPosition = nil
        blockquoteTextRange = nil
        resetBlockquoteBarToFullMode()
        
        // Restore placeholder
        textView.hidePlaceholder = false
        
        // Clear text
        textView.text = ""
        selectedFormatters.removeAll()
        
        // Reset typing attributes
        textView.typingAttributes = [
            .font: style.textFieldFont,
            .foregroundColor: style.textFieldColor
        ]
        
        // Reset toolbar
        richTextToolbar.setActiveFormats([])
        richTextToolbar.enableAllButtons()
        
        removeLimitView()
        messagePreview.subviews.forEach({ $0.removeFromSuperview() })
        messagePreview.isHidden = true
        updateSendButtonState()
        UIView.animate(withDuration: 0.3) { [weak self] in
            self?.controller?.view.layoutIfNeeded()
        }
    }
    
    private func clearReplyState() {
        if let message = viewModel.quotedMessage {
            CometChatMessageEvents.ccReplyToMessage(message: message, status: .error)
        }
        viewModel.quotedMessage = nil
        viewModel.quotedMessageId = nil
        hideReplyPreview()
    }
    
    // MARK: - Helper Methods
    
    func resetComposer() {
        // Reset list mode and persistent formats FIRST
        RichTextFormatterManager.shared.resetListMode()
        RichTextFormatterManager.shared.resetAllFormats()
        
        // Hide code block background view FIRST and reset state
        codeBlockBackgroundView.isHidden = true
        codeBlockLeftBorderView.isHidden = true
        codeBlockPlaceholderLabel.isHidden = true
        codeBlockStartPosition = nil
        codeBlockTextRange = nil
        codeBlockMinimumHeight = 0  // Reset minimum height
        resetTextViewMinHeight()  // Reset text view minHeight to original value
        centerTextInCodeBlock()  // Reset text container inset
        
        // Hide blockquote bar FIRST and reset state
        blockquoteBarView.isHidden = true
        blockquoteStartPosition = nil
        blockquoteTextRange = nil
        
        // Reset constraints (views are already hidden)
        resetCodeBlockBackgroundToFullMode()
        resetBlockquoteBarToFullMode()
        
        // Restore the text view placeholder
        textView.hidePlaceholder = false
        
        // Clear text view AFTER hiding visual elements
        textView.text = ""
        selectedFormatters.removeAll()
        originalEditText = nil
        endOnGoingTextFormatting()
        removeLimitView()
        
        // Reset typing attributes
        textView.typingAttributes = [
            .font: style.textFieldFont,
            .foregroundColor: style.textFieldColor
        ]
        
        // Reset toolbar
        richTextToolbar.setActiveFormats([])
        richTextToolbar.enableAllButtons()
        
        // Only hide edit preview, not reply preview
        // Reply preview is handled separately after message is sent via ccReplyToMessage event
        if composerState == .edit {
            hideEditPreview()
        }
        
        composerState = .draft
        updateSendButtonState()
        updateMicrophoneButtonVisibility()
        
        // Explicitly clear toolbar active formats to ensure no buttons remain highlighted
        richTextToolbar.setActiveFormats([])
        richTextToolbar.enableAllButtons()
        
        // Reset typing attributes to default
        textView.typingAttributes = [
            .font: style.textFieldFont,
            .foregroundColor: style.textFieldColor
        ]
        
        // Force layout update to ensure views stay hidden
        textViewContainer.setNeedsLayout()
        textViewContainer.layoutIfNeeded()
    }
    
    private func playMessageSound() {
        if !disableSoundForMessages {
            CometChatSoundManager().play(sound: .outgoingMessage, customSound: customSoundForMessage)
        }
    }
    
    func getId() -> [String: Any] {
        var id = [String: Any]()
        if let user = viewModel.user {
            id["uid"] = user.uid
        }
        if let group = viewModel.group {
            id["guid"] = group.guid
        }
        if let parentMessageId = viewModel.parentMessageId {
            id["parentMessageId"] = parentMessageId
        }
        return id
    }
    
    /// Resets stickers button to default style
    public func resetStickersButtonStyle() {
        stickersButton.imageView?.tintColor = style.stickersImageTint
    }
    
    // MARK: - Keyboard Handling
    
    func observeKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        // Only hide the sticker panel when the text view becomes first responder
        // This prevents the panel from being hidden during other keyboard events
        if textView.isFirstResponder {
            // Hide sticker keyboard when user starts typing
            if isStickerKeyboardShown {
                CometChatUIEvents.hidePanel(id: getId(), alignment: .composerBottom)
            }
            
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
    
    // MARK: - Footer View Methods
    
    @discardableResult
    public func set(footerView view: UIView) -> Self {
        self.footerView.subviews.forEach({ $0.removeFromSuperview() })
        self.footerView.addArrangedSubview(view)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.controller?.view.layoutIfNeeded()
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
}

// MARK: - CometChatUIEventListener

extension CometChatCompactMessageComposer: CometChatUIEventListener {
    
    func isForThisView(id: [String: Any]?) -> Bool {
        guard let id = id, !id.isEmpty else { return false }
        
        let isUserMatch = (id["uid"] as? String) == viewModel.user?.uid
        let isGroupMatch = (id["guid"] as? String) == viewModel.group?.guid
        
        if isUserMatch || isGroupMatch {
            if let parentMessageId = id["parentMessageId"] as? Int {
                return parentMessageId == viewModel.parentMessageId
            } else {
                return viewModel.parentMessageId == nil
            }
        }
        return false
    }
    
    public func showPanel(id: [String: Any]?, alignment: UIAlignment, view: UIView?) {
        if !isForThisView(id: id) {
            return
        }
        if let view = view {
            switch alignment {
            case .composerTop:
                break
            case .composerBottom:
                controller?.view.endEditing(true)
                set(footerView: view)
                isStickerKeyboardShown = true
                stickersButton.imageView?.tintColor = style.stickersActiveImageTint
            case .messageListTop, .messageListBottom:
                break
            }
        }
    }
    
    public func hidePanel(id: [String: Any]?, alignment: UIAlignment) {
        if !isForThisView(id: id) { return }
        switch alignment {
        case .composerTop:
            break
        case .composerBottom:
            remove(footerView: true)
            isStickerKeyboardShown = false
            resetStickersButtonStyle()
        case .messageListTop, .messageListBottom:
            break
        }
    }
    
    // MARK: - Code Block Background Management
    
    /// Updates the code block background view to cover only the code block text range
    /// Called when exiting code block mode to maintain visual styling for the code block portion
    internal func updateCodeBlockBackgroundForRange(_ range: NSRange) {
        guard range.length > 0 else {
            codeBlockBackgroundView.isHidden = true
            codeBlockLeftBorderView.isHidden = true
            return
        }
        
        // Store the range for future updates
        codeBlockTextRange = range
        
        // Deactivate auto-layout constraints and switch to frame-based positioning
        NSLayoutConstraint.deactivate(codeBlockBackgroundConstraints)
        codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = true
        
        // Show the background immediately
        codeBlockBackgroundView.isHidden = false
        codeBlockLeftBorderView.isHidden = true
        
        // Force SYNCHRONOUS layout to ensure text view has correct geometry
        textView.layoutIfNeeded()
        textViewContainer.layoutIfNeeded()
        
        // Calculate the rect for the code block text IMMEDIATELY
        updateCodeBlockBackgroundFrameImmediate()
    }
    
    /// Updates the frame of the code block background IMMEDIATELY without any async delays
    /// This is critical for fast double-enter to exit code block
    private func updateCodeBlockBackgroundFrameImmediate() {
        guard let range = codeBlockTextRange, range.length > 0 else {
            return
        }
        
        guard let text = textView.text, !text.isEmpty else {
            return
        }
        
        // Calculate visual range (strip trailing newlines for display)
        var visualLength = range.length
        let maxLength = min(range.location + range.length, text.count) - range.location
        visualLength = min(visualLength, maxLength)
        
        // Strip trailing newlines from the visual range
        while visualLength > 0 {
            let checkIndex = range.location + visualLength - 1
            if checkIndex < text.count {
                let charIndex = text.index(text.startIndex, offsetBy: checkIndex)
                if text[charIndex] == "\n" {
                    visualLength -= 1
                } else {
                    break
                }
            } else {
                visualLength -= 1
            }
        }
        
        // If no visible content, use minimal size
        if visualLength <= 0 {
            let lineHeight = textView.font?.lineHeight ?? 20
            let containerWidth = textViewContainer.bounds.width > 0 ? textViewContainer.bounds.width : textView.bounds.width
            codeBlockBackgroundView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: lineHeight + 8)
            return
        }
        
        let visualRange = NSRange(location: range.location, length: visualLength)
        
        // Get text positions for accurate measurement
        guard let startPosition = textView.position(from: textView.beginningOfDocument, offset: visualRange.location),
              let endPosition = textView.position(from: textView.beginningOfDocument, offset: visualRange.location + visualRange.length),
              let textRange = textView.textRange(from: startPosition, to: endPosition) else {
            return
        }
        
        // Get selection rects for accurate bounds
        let selectionRects = textView.selectionRects(for: textRange)
        var minY: CGFloat = .greatestFiniteMagnitude
        var maxY: CGFloat = 0
        
        for selectionRect in selectionRects {
            let rect = selectionRect.rect
            if !rect.isNull && !rect.isInfinite && rect.height > 0 {
                minY = min(minY, rect.origin.y)
                maxY = max(maxY, rect.origin.y + rect.height)
            }
        }
        
        // Fallback to caret rect
        if minY == .greatestFiniteMagnitude || maxY == 0 {
            let caretRect = textView.caretRect(for: startPosition)
            if !caretRect.isNull && !caretRect.isInfinite {
                minY = caretRect.origin.y
                let lineHeight = textView.font?.lineHeight ?? 20
                let codeBlockText = (text as NSString).substring(with: visualRange)
                var lineCount = 1
                if codeBlockText.contains("\n") {
                    lineCount = codeBlockText.components(separatedBy: "\n").count
                    if codeBlockText.hasSuffix("\n") { lineCount -= 1 }
                    lineCount = max(1, lineCount)
                }
                maxY = minY + (CGFloat(lineCount) * lineHeight)
            } else {
                return
            }
        }
        
        // If there's text above (codeBlockStartPosition is set), ensure the background
        // doesn't overlap with the text above - add a small gap
        if let codeBlockStart = codeBlockStartPosition, codeBlockStart > 1 {
            if let beforeNewlinePos = textView.position(from: textView.beginningOfDocument, offset: codeBlockStart - 2) {
                let beforeRect = textView.caretRect(for: beforeNewlinePos)
                if !beforeRect.isNull && !beforeRect.isInfinite && beforeRect.height > 0 {
                    let minAllowedY = beforeRect.origin.y + beforeRect.height + 4  // 4pt gap
                    if minY < minAllowedY {
                        minY = minAllowedY
                    }
                }
            }
        }
        
        let contentOffset = textView.contentOffset.y
        let containerWidth = textViewContainer.bounds.width > 0 ? textViewContainer.bounds.width : textView.bounds.width
        let verticalPadding: CGFloat = 4
        
        let frame = CGRect(
            x: 0,
            y: minY - contentOffset - verticalPadding,
            width: containerWidth,
            height: (maxY - minY) + (verticalPadding * 2)
        )
        
        codeBlockBackgroundView.frame = frame
    }
    
    /// Updates the frame of the code block background based on the stored text range
    internal func updateCodeBlockBackgroundFrame() {
        guard let range = codeBlockTextRange, range.length > 0 else {
            return
        }
        
        guard let text = textView.text, !text.isEmpty else {
            return
        }
        
        // Calculate visual range (strip trailing newlines for display)
        var visualLength = range.length
        let maxLength = min(range.location + range.length, text.count) - range.location
        visualLength = min(visualLength, maxLength)
        
        // Strip trailing newlines from the visual range
        while visualLength > 0 {
            let checkIndex = range.location + visualLength - 1
            if checkIndex < text.count {
                let charIndex = text.index(text.startIndex, offsetBy: checkIndex)
                if text[charIndex] == "\n" {
                    visualLength -= 1
                } else {
                    break
                }
            } else {
                visualLength -= 1
            }
        }
        
        // If no visible content after stripping newlines, keep background but with minimal size
        if visualLength <= 0 {
            let lineHeight = textView.font?.lineHeight ?? 20
            let containerWidth = textViewContainer.bounds.width > 0 ? textViewContainer.bounds.width : textView.bounds.width
            codeBlockBackgroundView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: lineHeight + 8)
            codeBlockBackgroundView.isHidden = false
            return
        }
        
        let visualRange = NSRange(location: range.location, length: visualLength)
        
        // Get the bounding rect using text positions for accurate measurement
        guard let startPosition = textView.position(from: textView.beginningOfDocument, offset: visualRange.location),
              let endPosition = textView.position(from: textView.beginningOfDocument, offset: visualRange.location + visualRange.length),
              let textRange = textView.textRange(from: startPosition, to: endPosition) else {
            return
        }
        
        // Get selection rects for accurate multi-line measurement
        let selectionRects = textView.selectionRects(for: textRange)
        var minY: CGFloat = .greatestFiniteMagnitude
        var maxY: CGFloat = 0
        
        for selectionRect in selectionRects {
            let rect = selectionRect.rect
            if !rect.isNull && !rect.isInfinite && rect.height > 0 {
                minY = min(minY, rect.origin.y)
                maxY = max(maxY, rect.origin.y + rect.height)
            }
        }
        
        // Fallback to caret rect if selection rects didn't work
        if minY == .greatestFiniteMagnitude || maxY == 0 {
            let caretRect = textView.caretRect(for: startPosition)
            if !caretRect.isNull && !caretRect.isInfinite {
                minY = caretRect.origin.y
                let lineHeight = textView.font?.lineHeight ?? 20
                // Count lines in the code block
                let codeBlockText = (text as NSString).substring(with: visualRange)
                var lineCount = 1
                if codeBlockText.contains("\n") {
                    lineCount = codeBlockText.components(separatedBy: "\n").count
                    if codeBlockText.hasSuffix("\n") {
                        lineCount -= 1
                    }
                    lineCount = max(1, lineCount)
                }
                maxY = minY + (CGFloat(lineCount) * lineHeight)
            }
        }
        
        guard minY < .greatestFiniteMagnitude && maxY > 0 else {
            return
        }
        
        // If there's text above (codeBlockStartPosition is set), ensure the background
        // doesn't overlap with the text above - add a small gap
        if let codeBlockStart = codeBlockStartPosition, codeBlockStart > 1 {
            if let beforeNewlinePos = textView.position(from: textView.beginningOfDocument, offset: codeBlockStart - 2) {
                let beforeRect = textView.caretRect(for: beforeNewlinePos)
                if !beforeRect.isNull && !beforeRect.isInfinite && beforeRect.height > 0 {
                    let minAllowedY = beforeRect.origin.y + beforeRect.height + 4  // 4pt gap
                    if minY < minAllowedY {
                        minY = minAllowedY
                    }
                }
            }
        }
        
        // Calculate the frame - NO overlap with text above or below
        let contentOffset = textView.contentOffset.y
        let containerWidth = textViewContainer.bounds.width > 0 ? textViewContainer.bounds.width : textView.bounds.width
        
        // Small vertical padding inside the background (not extending beyond text bounds)
        let verticalPadding: CGFloat = 4
        
        let frame = CGRect(
            x: 0,
            y: minY - contentOffset - verticalPadding,
            width: containerWidth,
            height: (maxY - minY) + (verticalPadding * 2)
        )
        
        codeBlockBackgroundView.frame = frame
        codeBlockBackgroundView.isHidden = false
        
        // Update left border frame to match (but keep it hidden)
        NSLayoutConstraint.deactivate(codeBlockLeftBorderConstraints)
        codeBlockLeftBorderView.translatesAutoresizingMaskIntoConstraints = true
        codeBlockLeftBorderView.frame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y,
            width: 3,
            height: frame.height
        )
        codeBlockLeftBorderView.isHidden = true
    }
    /// This is used when in code block mode to dynamically update the background as text grows
    internal func updateCodeBlockBackgroundFrameForRangeDirect(_ range: NSRange) {
        guard range.length > 0, range.location + range.length <= (textView.text?.count ?? 0) else {
            return
        }
        
        // Deactivate auto-layout constraints and switch to frame-based positioning
        NSLayoutConstraint.deactivate(codeBlockBackgroundConstraints)
        codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = true
        
        // Ensure text view is laid out before calculating frame
        textView.layoutIfNeeded()
        
        // Get the text range in UITextView coordinates
        guard let startPosition = textView.position(from: textView.beginningOfDocument, offset: range.location),
              let endPosition = textView.position(from: textView.beginningOfDocument, offset: range.location + range.length),
              let textRange = textView.textRange(from: startPosition, to: endPosition) else {
            return
        }
        
        // Get all selection rects for the text range (handles multi-line text)
        let selectionRects = textView.selectionRects(for: textRange)
        
        // Calculate the bounding rect that encompasses all selection rects
        var minY: CGFloat = .greatestFiniteMagnitude
        var maxY: CGFloat = 0
        
        for selectionRect in selectionRects {
            let rect = selectionRect.rect
            if !rect.isNull && !rect.isInfinite && rect.height > 0 {
                minY = min(minY, rect.origin.y)
                maxY = max(maxY, rect.origin.y + rect.height)
            }
        }
        
        // Also consider the cursor position - if cursor is on a new line after the text,
        // we need to include that line in the background (only when actively in code block mode)
        if RichTextFormatterManager.shared.isInCodeBlockMode {
            if let selectedTextRange = textView.selectedTextRange {
                let cursorRect = textView.caretRect(for: selectedTextRange.end)
                if !cursorRect.isNull && !cursorRect.isInfinite && cursorRect.height > 0 {
                    let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedTextRange.end)
                    if cursorPosition >= range.location {
                        minY = min(minY, cursorRect.origin.y)
                        maxY = max(maxY, cursorRect.origin.y + cursorRect.height)
                    }
                }
            }
        }
        
        // Fallback if no valid rects found - use cursor position
        if minY == .greatestFiniteMagnitude || maxY == 0 {
            if let selectedTextRange = textView.selectedTextRange {
                let cursorRect = textView.caretRect(for: selectedTextRange.end)
                if !cursorRect.isNull && !cursorRect.isInfinite && cursorRect.height > 0 {
                    minY = cursorRect.origin.y
                    maxY = cursorRect.origin.y + cursorRect.height
                }
            }
            
            // If still no valid position, try caret rect at start position
            if minY == .greatestFiniteMagnitude || maxY == 0 {
                let caretRect = textView.caretRect(for: startPosition)
                if !caretRect.isNull && !caretRect.isInfinite {
                    minY = caretRect.origin.y
                    maxY = caretRect.origin.y + caretRect.height
                } else {
                    return
                }
            }
        }
        
        // IMPORTANT: If there's text above (codeBlockStartPosition is set), ensure the background
        // doesn't overlap with the text above - add a small gap
        if let codeBlockStart = codeBlockStartPosition, codeBlockStart > 1 {
            // Get the rect of the last visible character before the newline
            // The newline is at codeBlockStart - 1, so the last visible char is at codeBlockStart - 2
            if let beforeNewlinePos = textView.position(from: textView.beginningOfDocument, offset: codeBlockStart - 2) {
                let beforeRect = textView.caretRect(for: beforeNewlinePos)
                if !beforeRect.isNull && !beforeRect.isInfinite && beforeRect.height > 0 {
                    // The minimum Y should be at least at the bottom of the line above plus a small gap
                    let minAllowedY = beforeRect.origin.y + beforeRect.height + 4  // 4pt gap from text above
                    if minY < minAllowedY {
                        minY = minAllowedY
                    }
                }
            }
        }
        
        // Calculate the frame - position exactly at text bounds, no overlap
        let contentOffset = textView.contentOffset.y
        let containerWidth = textViewContainer.bounds.width > 0 ? textViewContainer.bounds.width : textView.bounds.width
        
        // Small vertical padding inside the background
        let verticalPadding: CGFloat = 4
        
        var calculatedHeight = (maxY - minY) + (verticalPadding * 2)
        let yPosition = minY - contentOffset - verticalPadding
        
        // If minimum height is set and larger than calculated height, extend downward only
        if codeBlockMinimumHeight > 0 && codeBlockMinimumHeight > calculatedHeight {
            calculatedHeight = codeBlockMinimumHeight
        }
        
        let frame = CGRect(
            x: 0,
            y: yPosition,
            width: containerWidth,
            height: calculatedHeight
        )
        codeBlockBackgroundView.frame = frame
        
        // Update left border frame to match
        NSLayoutConstraint.deactivate(codeBlockLeftBorderConstraints)
        codeBlockLeftBorderView.translatesAutoresizingMaskIntoConstraints = true
        codeBlockLeftBorderView.frame = CGRect(
            x: frame.origin.x,
            y: frame.origin.y,
            width: 3,
            height: frame.height
        )
        codeBlockLeftBorderView.isHidden = true
    }
    
    /// Updates the code block background to wrap around all text content (for code block mode)
    /// This dynamically resizes the background as text grows/shrinks
    internal func updateCodeBlockBackgroundForFullText() {
        // Skip if we're in the process of exiting code block - the exit handler will update the background
        if isExitingCodeBlock {
            return
        }
        
        // Also skip if we're not in code block mode and have a fixed range
        // In this case, use updateCodeBlockBackgroundFrame() instead
        if !RichTextFormatterManager.shared.isInCodeBlockMode && codeBlockTextRange != nil {
            updateCodeBlockBackgroundFrame()
            return
        }
        
        // IMPORTANT: If there's a codeBlockStartPosition set (code block after existing content),
        // use frame-based positioning to only cover the code block portion
        if let codeBlockStart = codeBlockStartPosition {
            guard let text = textView.text else {
                // No text - use current cursor position for background
                if let selectedRange = textView.selectedTextRange {
                    let cursorRect = textView.caretRect(for: selectedRange.start)
                    if !cursorRect.isNull && !cursorRect.isInfinite && cursorRect.height > 0 {
                        NSLayoutConstraint.deactivate(codeBlockBackgroundConstraints)
                        codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = true
                        
                        let bgHeight = codeBlockMinimumHeight > 0 ? max(codeBlockMinimumHeight, cursorRect.height) : cursorRect.height
                        
                        let bgFrame = CGRect(
                            x: 0,
                            y: cursorRect.origin.y - textView.contentOffset.y,
                            width: textViewContainer.bounds.width,
                            height: bgHeight
                        )
                        codeBlockBackgroundView.frame = bgFrame
                        codeBlockBackgroundView.isHidden = false
                        codeBlockLeftBorderView.isHidden = true
                    }
                }
                return
            }
            
            let textLength = text.count
            
            // Ensure code block start is valid and there's content to show
            if codeBlockStart < textLength {
                let codeBlockRange = NSRange(location: codeBlockStart, length: textLength - codeBlockStart)
                updateCodeBlockBackgroundFrameForRangeDirect(codeBlockRange)
                codeBlockBackgroundView.isHidden = false
                codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
            } else {
                // No code block content yet - calculate Y position based on text BEFORE the code block
                var bgY: CGFloat = 0
                let bgHeight = codeBlockMinimumHeight > 0 ? codeBlockMinimumHeight : (textView.font?.lineHeight ?? 20) + 16
                
                // Get the rect of the last visible character before the newline
                // The newline is at codeBlockStart - 1, so the last visible char is at codeBlockStart - 2
                if codeBlockStart > 1 {
                    if let beforeNewlinePos = textView.position(from: textView.beginningOfDocument, offset: codeBlockStart - 2) {
                        let beforeRect = textView.caretRect(for: beforeNewlinePos)
                        if !beforeRect.isNull && !beforeRect.isInfinite && beforeRect.height > 0 {
                            // Code block starts on the next line
                            bgY = beforeRect.origin.y + beforeRect.height - textView.contentOffset.y
                        }
                    }
                }
                
                // Fallback: use line height
                if bgY == 0 {
                    let lineHeight = textView.font?.lineHeight ?? style.textFieldFont.lineHeight
                    bgY = lineHeight + textView.textContainerInset.top
                }
                
                NSLayoutConstraint.deactivate(codeBlockBackgroundConstraints)
                codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = true
                
                let bgFrame = CGRect(
                    x: 0,
                    y: bgY,
                    width: textViewContainer.bounds.width,
                    height: bgHeight
                )
                codeBlockBackgroundView.frame = bgFrame
                codeBlockBackgroundView.isHidden = false
                codeBlockLeftBorderView.isHidden = true
            }
            return
        }
        
        // Also check if there's blockquote content - if so, calculate code block start position
        if let blockquoteRange = blockquoteTextRange, blockquoteRange.length > 0, RichTextFormatterManager.shared.isInCodeBlockMode {
            guard let text = textView.text else {
                resetCodeBlockBackgroundToFullMode()
                codeBlockBackgroundView.isHidden = false
                codeBlockLeftBorderView.isHidden = true
                return
            }
            
            let textLength = text.count
            
            // Calculate code block start position (after blockquote + newlines/whitespace)
            var codeBlockStart = blockquoteRange.location + blockquoteRange.length
            while codeBlockStart < textLength {
                let index = text.index(text.startIndex, offsetBy: codeBlockStart)
                let char = text[index]
                if char == "\n" || char == " " || char == "\t" {
                    codeBlockStart += 1
                } else {
                    break
                }
            }
            
            // Store the calculated position for future updates
            codeBlockStartPosition = codeBlockStart
            
            if codeBlockStart < textLength {
                let codeBlockRange = NSRange(location: codeBlockStart, length: textLength - codeBlockStart)
                updateCodeBlockBackgroundFrameForRangeDirect(codeBlockRange)
                codeBlockBackgroundView.isHidden = false
                codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                updateCodeBlockLeftBorderFrame()
            } else {
                // No code block content yet - show background at cursor position with minimum height
                if let startPos = textView.position(from: textView.beginningOfDocument, offset: codeBlockStart) {
                    let caretRect = textView.caretRect(for: startPos)
                    if !caretRect.isNull && !caretRect.isInfinite && caretRect.height > 0 {
                        NSLayoutConstraint.deactivate(codeBlockBackgroundConstraints)
                        codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = true
                        
                        // Use minimum height if set, otherwise use caret height
                        // Don't center - extend downward only to avoid overlapping text above
                        let bgHeight = codeBlockMinimumHeight > 0 ? max(codeBlockMinimumHeight, caretRect.height) : caretRect.height
                        
                        let bgFrame = CGRect(
                            x: 0,
                            y: caretRect.origin.y - textView.contentOffset.y,
                            width: textViewContainer.bounds.width,
                            height: bgHeight
                        )
                        codeBlockBackgroundView.frame = bgFrame
                        codeBlockBackgroundView.isHidden = false
                        codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                    }
                }
            }
            return
        }
        
        // No blockquote content - use auto-layout constraints to fill the text view container
        // This ensures the code block background maintains its size and grows with the text
        resetCodeBlockBackgroundToFullMode()
        codeBlockBackgroundView.isHidden = false
        codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
    }
    
    /// Updates the visibility of the code block placeholder based on current state
    internal func updateCodeBlockPlaceholderVisibility() {
        // Always hide placeholder - no placeholder in code block
        codeBlockPlaceholderLabel.isHidden = true
    }
    
    /// Centers the text vertically within the code block when minimum height is set
    /// Only applies when code block starts from the beginning (no content above)
    internal func centerTextInCodeBlock() {
        // Only center text when code block is at the start (no content above)
        guard codeBlockMinimumHeight > 0, codeBlockStartPosition == nil else {
            // Reset to default insets when not in code block mode or when there's content above
            textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
            return
        }
        
        // Calculate the content height
        let font = textView.font ?? style.textFieldFont
        let lineHeight = font.lineHeight
        
        // Calculate vertical padding to center the text
        let availableHeight = codeBlockMinimumHeight
        let verticalPadding = max(8, (availableHeight - lineHeight) / 2)
        
        textView.textContainerInset = UIEdgeInsets(top: verticalPadding, left: 0, bottom: verticalPadding, right: 0)
    }
    
    /// Shows or hides all code block related views together
    internal func setCodeBlockViewsHidden(_ hidden: Bool) {
        codeBlockBackgroundView.isHidden = hidden
        codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
        codeBlockPlaceholderLabel.isHidden = true  // Always hidden - no placeholder
    }
    
    /// Updates the left border frame to match the code block background
    /// Note: Left border is always hidden - no purple border on code block
    internal func updateCodeBlockLeftBorderFrame() {
        // Always keep left border hidden - no purple border
        codeBlockLeftBorderView.isHidden = true
    }
    
    /// Resets the code block background to use auto-layout constraints (full coverage mode)
    internal func resetCodeBlockBackgroundToFullMode() {
        codeBlockTextRange = nil
        // Only clear codeBlockStartPosition if we're NOT in code block mode with existing content
        // This prevents the code block from expanding backwards to cover previous content
        if !(RichTextFormatterManager.shared.isInCodeBlockMode && codeBlockStartPosition != nil) {
            codeBlockStartPosition = nil
        }
        codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(codeBlockBackgroundConstraints)
        
        // Always keep left border hidden
        codeBlockLeftBorderView.isHidden = true
        
        // Also reset left border to use auto-layout
        codeBlockLeftBorderView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(codeBlockLeftBorderConstraints)
    }
    
    /// Resets the text view minHeight to its original value when exiting code block mode
    internal func resetTextViewMinHeight() {
        if let originalHeight = originalTextViewMinHeight {
            textView.minHeight = originalHeight
            originalTextViewMinHeight = nil
            
            // Force layout update
            textView.setNeedsLayout()
            textView.layoutIfNeeded()
            textViewContainer.setNeedsLayout()
            textViewContainer.layoutIfNeeded()
            invalidateIntrinsicContentSize()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// Resets the blockquote bar to use auto-layout constraints (full height mode)
    internal func resetBlockquoteBarToFullMode() {
        blockquoteStartPosition = nil
        blockquoteTextRange = nil
        blockquoteBarView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(blockquoteBarConstraints)
    }
    
    /// Updates the blockquote bar to cover a specific text range
    /// This is used when exiting blockquote mode to keep the bar visible for quoted content
    internal func updateBlockquoteBarForRange(_ range: NSRange) {
        guard range.length > 0, range.location + range.length <= (textView.text?.count ?? 0) else {
            blockquoteBarView.isHidden = true
            return
        }
        
        // Store the range for future updates
        blockquoteTextRange = range
        
        // Deactivate auto-layout constraints and switch to frame-based positioning
        NSLayoutConstraint.deactivate(blockquoteBarConstraints)
        blockquoteBarView.translatesAutoresizingMaskIntoConstraints = true
        
        // Calculate the rect for the blockquote text
        updateBlockquoteBarFrameForRange()
        
        blockquoteBarView.isHidden = false
    }
    
    /// Updates the frame of the blockquote bar based on the stored text range
    internal func updateBlockquoteBarFrameForRange() {
        guard let range = blockquoteTextRange, range.length > 0 else {
            return
        }
        
        // Ensure text view is laid out before calculating frame
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
        
        // Get the start and end positions
        guard let startPosition = textView.position(from: textView.beginningOfDocument, offset: range.location),
              let endPosition = textView.position(from: textView.beginningOfDocument, offset: range.location + range.length) else {
            return
        }
        
        // Get the caret rect for start position (top of blockquote)
        let startRect = textView.caretRect(for: startPosition)
        
        // Get the caret rect for end position (bottom of blockquote)
        let endRect = textView.caretRect(for: endPosition)
        
        // Validate rects
        guard !startRect.isNull && !startRect.isInfinite && startRect.height > 0,
              !endRect.isNull && !endRect.isInfinite && endRect.height > 0 else {
            return
        }
        
        // Calculate the frame - from top of start rect to bottom of end rect
        let contentOffset = textView.contentOffset.y
        let minY = startRect.origin.y
        let maxY = endRect.origin.y + endRect.height
        
        let frame = CGRect(
            x: -2,
            y: minY - contentOffset,
            width: 4,
            height: max(maxY - minY, startRect.height) // Ensure minimum height of one line
        )
        blockquoteBarView.frame = frame
    }
    
    /// Updates the blockquote bar frame directly for a given range without storing it
    /// This is used when in blockquote mode to dynamically update the bar as text grows
    internal func updateBlockquoteBarFrameForRangeDirect(_ range: NSRange) {
        guard range.length > 0, range.location + range.length <= (textView.text?.count ?? 0) else {
            return
        }
        
        // Deactivate auto-layout constraints and switch to frame-based positioning
        NSLayoutConstraint.deactivate(blockquoteBarConstraints)
        blockquoteBarView.translatesAutoresizingMaskIntoConstraints = true
        
        // Ensure text view is laid out before calculating frame
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
        
        // Get the start and end positions
        guard let startPosition = textView.position(from: textView.beginningOfDocument, offset: range.location),
              let endPosition = textView.position(from: textView.beginningOfDocument, offset: range.location + range.length) else {
            return
        }
        
        // Get the caret rect for start position (top of blockquote)
        let startRect = textView.caretRect(for: startPosition)
        
        // Get the caret rect for end position (bottom of blockquote)
        let endRect = textView.caretRect(for: endPosition)
        
        // Validate rects
        guard !startRect.isNull && !startRect.isInfinite && startRect.height > 0,
              !endRect.isNull && !endRect.isInfinite && endRect.height > 0 else {
            return
        }
        
        // Calculate the frame - from top of start rect to bottom of end rect
        let contentOffset = textView.contentOffset.y
        let minY = startRect.origin.y
        let maxY = endRect.origin.y + endRect.height
        
        let frame = CGRect(
            x: -2,
            y: minY - contentOffset,
            width: 4,
            height: max(maxY - minY, startRect.height) // Ensure minimum height of one line
        )
        blockquoteBarView.frame = frame
    }
    
    /// Updates the blockquote bar to start from a specific text position
    /// This is used when there's code block content before the blockquote
    internal func updateBlockquoteBarForPosition(_ startPosition: Int) {
        // Ensure text view is laid out before calculating frame
        textView.setNeedsLayout()
        textView.layoutIfNeeded()
        
        // Deactivate auto-layout constraints and switch to frame-based positioning
        NSLayoutConstraint.deactivate(blockquoteBarConstraints)
        blockquoteBarView.translatesAutoresizingMaskIntoConstraints = true
        
        // Get the position in the text view
        guard let textPosition = textView.position(from: textView.beginningOfDocument, offset: startPosition) else {
            // Fallback to auto-layout if we can't get text position
            resetBlockquoteBarToFullMode()
            return
        }
        
        // Get the rect for the start position
        let caretRect = textView.caretRect(for: textPosition)
        
        guard !caretRect.isNull && !caretRect.isInfinite else {
            // Fallback to auto-layout if invalid rect
            resetBlockquoteBarToFullMode()
            return
        }
        
        // Calculate the frame for the blockquote bar
        // It should start from the startPosition and extend to the bottom of the text view
        let contentOffset = textView.contentOffset.y
        let startY = caretRect.origin.y - contentOffset
        let endY = textViewContainer.bounds.height - 2
        
        // Only show the bar if there's space for it
        if endY > startY {
            let frame = CGRect(
                x: -2,
                y: startY + 2,
                width: 4,
                height: endY - startY - 4
            )
            blockquoteBarView.frame = frame
        } else {
            // No space for blockquote bar - hide it
            blockquoteBarView.isHidden = true
        }
    }
    
    /// Updates the blockquote bar frame based on the stored start position or range
    internal func updateBlockquoteBarFrame() {
        // If we have a text range (exited blockquote mode), update based on range
        if blockquoteTextRange != nil {
            updateBlockquoteBarFrameForRange()
            return
        }
        // If we have a start position (blockquote after code block), update based on position
        guard let startPosition = blockquoteStartPosition else {
            return
        }
        updateBlockquoteBarForPosition(startPosition)
    }
}
