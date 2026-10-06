//
//  CometChatStreamBubble.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 30/09/25.
//

import Foundation
import UIKit
import CometChatSDK
import CometChatCardsSwift

public class CometChatStreamBubble: UITableViewCell, StreamCallback {
    public let containerStackView = UIStackView()
    public let avatarView = CometChatAvatar(image: nil).withoutAutoresizingMaskConstraints()
    public let bubbleView = UIView()
    public let typingIndicator = TypingIndicatorView()
    public let messageLabel = UILabel()
    public let errorContainerView = UIView()
    public let errorLabel = UILabel()
    let markdownParser = MarkdownParser()
    
    private var markdownView = CombinedMarkdownBubbleView()

    /// Per run: the stream buffer (what the markdown view renders) and the shared
    /// queue buffer as they were when a tool call started, restored when it ends.
    private var originalMessageText: [Int: String] = [:]
    private var originalQueueBuffer: [Int: String] = [:]

    /// The run whose text was last written into this cell; `nil` while empty.
    private var lastWrittenRunId: Int?

    private var streamBuffer: String = ""
    private var isUpdatingUI = false
    private var displayedLength: Int = 0
    private let uiUpdateInterval: TimeInterval = 0.03
        
    var messageObj: StreamMessage?

    public let queueManager = CometChatAIStreamService.shared

    var runId: Int = 0
    public var hasError: Bool = false
    public var errorText: String = ""

    // Optional closure for tableView reload
    var updateUI: (() -> Void)?
    
    private var hasStartedStreaming = false
    
    public static var style = AIAssistantBubbleStyle()
    public lazy var style = CometChatAIAssistantBubble.style

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil{
            setupStyle()
        }
    }
    
    /// Applies the style fields this cell has a view for: text font/colour through
    /// the markdown view, the bubble's background, border and corner radius, and
    /// the avatar style. The header, date, receipt, thread-indicator, reactions,
    /// preview and background-drawable fields have no view in a streaming bubble.
    open func setupStyle() {
        markdownView.style = style
        if let backgroundColor = style.backgroundColor {
            bubbleView.backgroundColor = backgroundColor
        }
        if let borderWidth = style.borderWidth {
            bubbleView.borderWith(width: borderWidth)
        }
        if let borderColor = style.borderColor {
            bubbleView.borderColor(color: borderColor)
        }
        if let cornerRadius = style.cornerRadius {
            // Radius only: roundViewCorners would also turn on masksToBounds and
            // clip streamed cards, which are allowed to overflow the bubble.
            bubbleView.layer.cornerRadius = cornerRadius.cornerRadius
        }
        if let avatarStyle = style.avatarStyle {
            avatarView.style = avatarStyle
        }
    }

    // MARK: - UI Setup
        public func setupUI() {
            selectionStyle = .none
            backgroundColor = .clear
            contentView.backgroundColor = .clear

            containerStackView.axis = .horizontal
            containerStackView.alignment = .top
            containerStackView.spacing = 8
            containerStackView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(containerStackView)

            NSLayoutConstraint.activate([
                containerStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                containerStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
                containerStackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -40),
                containerStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
            ])

            avatarView.widthAnchor.constraint(equalToConstant: 32).isActive = true
            avatarView.heightAnchor.constraint(equalToConstant: 32).isActive = true
            avatarView.style.textFont = CometChatTypography.Heading4.bold

            bubbleView.backgroundColor = .clear
            bubbleView.layer.cornerRadius = 16
            bubbleView.translatesAutoresizingMaskIntoConstraints = false

            messageLabel.font = CometChatTypography.Body.regular
            messageLabel.adjustsFontForContentSizeCategory = true
            messageLabel.numberOfLines = 0

            typingIndicator.isHidden = true
            typingIndicator.translatesAutoresizingMaskIntoConstraints = false

            // --- Error view styling ---
            errorContainerView.backgroundColor = CometChatTheme.errorColor100
            errorContainerView.layer.cornerRadius = 12
            errorContainerView.layer.masksToBounds = true
            errorContainerView.isHidden = true
            errorContainerView.translatesAutoresizingMaskIntoConstraints = false
            errorContainerView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

            errorLabel.textColor = CometChatTheme.errorColor
            errorLabel.font = CometChatTypography.Caption1.regular
            errorLabel.adjustsFontForContentSizeCategory = true
            errorLabel.numberOfLines = 0
            errorLabel.textAlignment = .left
            errorLabel.translatesAutoresizingMaskIntoConstraints = false

            errorContainerView.addSubview(errorLabel)
            NSLayoutConstraint.activate([
                errorLabel.topAnchor.constraint(equalTo: errorContainerView.layoutMarginsGuide.topAnchor),
                errorLabel.leadingAnchor.constraint(equalTo: errorContainerView.layoutMarginsGuide.leadingAnchor),
                errorLabel.trailingAnchor.constraint(equalTo: errorContainerView.layoutMarginsGuide.trailingAnchor),
                errorLabel.bottomAnchor.constraint(equalTo: errorContainerView.layoutMarginsGuide.bottomAnchor)
            ])
            
            errorContainerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true

            let bubbleStack = UIStackView(arrangedSubviews: [markdownView, typingIndicator, errorContainerView])
            bubbleStack.axis = .vertical
            bubbleStack.spacing = 6
            bubbleStack.distribution = .fill
            bubbleStack.alignment = .fill
            bubbleStack.translatesAutoresizingMaskIntoConstraints = false
            bubbleView.addSubview(bubbleStack)
            self.bubbleStack = bubbleStack

            NSLayoutConstraint.activate([
                bubbleStack.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 3),
                bubbleStack.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 8),
                bubbleStack.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -8),
                bubbleStack.bottomAnchor.constraint(equalTo: bubbleView.bottomAnchor, constant: -10)
            ])

            containerStackView.addArrangedSubview(avatarView)
            containerStackView.addArrangedSubview(bubbleView)
            
            NotificationCenter.default.addObserver(
                forName: CometChatStreamCallBackEvents.streamCompletedNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self = self else { return }
                let success = notification.userInfo?["success"] as? Bool ?? false
                if success {
                    self.onStreamReconnected()
                }
            }

            NotificationCenter.default.addObserver(
                forName: CometChatStreamCallBackEvents.streamInterruptedNotification,
                object: nil,
                queue: .main
            ) { [weak self] notification in
                guard let self = self else { return }
                let interrupted = notification.userInfo?["interrupted"] as? Bool ?? false
                if interrupted {
                    self.onStreamInterrupted()
                }
            }
        }

    deinit {
        CometChatAIStreamService.shared.unregisterStreamCallback(runId: self.runId)
        NotificationCenter.default.removeObserver(self)
    }
    
    func onStreamReconnected() {
    }
    
    public func onStreamCompleted() {
    }

    public func onStreamInterrupted() {
        showError()
        CometChatLogger.error("stream interrupted — showing error UI")
        updateUI?()
    }

    // MARK: - Bind to AI Run
    func bindToRun(runId: Int) {
        // Always reset ALL state for a new runId
        self.runId = runId
        self.streamBuffer = ""
        self.displayedLength = 0
        self.markdownView.reset()
        self.hasError = false
        self.errorText = ""
        self.errorContainerView.isHidden = true
        self.lastWrittenRunId = nil
        // A recycled cell drops the cards of the run it showed before; a rebind to
        // the same run keeps them, since the service does not replay card events.
        if streamedCardsRunId != runId {
            self.removeStreamedCards()
        }

        queueManager.startStreamingForRunId(
            runId: runId,
            onAiAssistantEvent: { [weak self] event in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.processEvent(event)
                    self.updateUI?()
                }
            },
            onError: { [weak self] error in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.hasError = true
                    self.errorText = error.description
                    self.showError()
                    self.updateUI?()
                }
            }
        )
    }

    // MARK: - Process AI Event
    /// Whether the next chunk for `runId` is its first in this cell: true until a
    /// non-empty chunk of that run has been written, and true for any other run.
    public func isFirstChunk(runId: Int) -> Bool {
        return lastWrittenRunId != runId
    }

    // MARK: - UI States
    func showThinking() {
        hasError = false
        errorContainerView.isHidden = true
        typingIndicator.isHidden = false
        typingIndicator.startAnimating()
        messageLabel.isHidden = true
        markdownView.reset()
        // The markdown view is empty again, so the buffer that mirrors it is too.
        streamBuffer = ""
        displayedLength = 0
        lastWrittenRunId = nil
    }

    func startStreaming(firstChunk: String) {
        hideThinking()
        markdownView.reset()                    // Clear previous message
        markdownView.append(markdownChunk: firstChunk)

        streamBuffer = firstChunk
        displayedLength = streamBuffer.count
        lastWrittenRunId = firstChunk.isEmpty ? nil : runId
        updateUI?()
    }

    func appendChunk(_ textChunk: String) {
        errorContainerView.isHidden = true
        messageLabel.isHidden = false
        typingIndicator.stopAnimating()
        typingIndicator.isHidden = true
        let attributedText = markdownParser.parse((messageLabel.text ?? "") + textChunk)
        messageLabel.attributedText = attributedText
        messageLabel.textColor = .label
        if !textChunk.isEmpty {
            lastWrittenRunId = runId
        }
    }

    func completeStreaming(finalText: String) {
        hideThinking()
        markdownView.reset()
        markdownView.append(markdownChunk: finalText)

        streamBuffer = finalText
        displayedLength = streamBuffer.count
        lastWrittenRunId = finalText.isEmpty ? nil : runId
        updateUI?()
    }

    func showError() {
        typingIndicator.stopAnimating()
        typingIndicator.isHidden = true
        messageLabel.isHidden = true
        errorContainerView.isHidden = false
        errorLabel.text = "SOMETHING_WENT_WRONG_ERROR".localize()

        hasError = true
        setNeedsLayout()
        layoutIfNeeded()
        updateUI?()
    }
    
    public func processEvent(_ event: AIAssistantBaseEvent) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            switch event {
            case let run as AIAssistantRunStartedEvent:
                self.showThinking()
                self.queueManager.clearBuffer(runId: run.runId)
                self.updateUI?()
            case let content as AIAssistantContentReceivedEvent:
                self.processStreamContent(runId: content.runId, content: content.delta)
                self.updateUI?()
            case let end as AIAssistantMessageEndedEvent:
                let finalText = self.queueManager.getBufferContent(runId: end.runId) ?? ""
                self.completeStreaming(finalText: finalText)
                self.queueManager.removeBuffer(runId: end.runId)
                self.updateUI?()
                
            case let runFinish as AIAssistantRunFinishedEvent:
                break
                
            case let toolStart as AIAssistantToolStartedEvent:
                // Snapshot what the markdown path renders (streamBuffer) and the
                // shared buffer the final answer is read from, before the
                // execution line is appended to both.
                if self.originalMessageText[toolStart.runId] == nil {
                    self.originalMessageText[toolStart.runId] = self.streamBuffer
                    self.originalQueueBuffer[toolStart.runId] = self.queueManager.getBufferContent(runId: toolStart.runId) ?? ""
                }

                let toolText = "\n\(toolStart.executionText)"
                self.processStreamContent(runId: toolStart.runId, content: toolText)
                self.updateUI?()

            case let toolEnd as AIAssistantToolEndedEvent:
                if let originalText = self.originalMessageText[toolEnd.runId] {
                    self.streamBuffer = originalText
                    self.displayedLength = originalText.count
                    self.appendBufferedContent()
                    self.originalMessageText.removeValue(forKey: toolEnd.runId)
                    if let originalQueueText = self.originalQueueBuffer.removeValue(forKey: toolEnd.runId) {
                        self.queueManager.clearBuffer(runId: toolEnd.runId)
                        if !originalQueueText.isEmpty {
                            self.queueManager.appendToBuffer(runId: toolEnd.runId, delta: originalQueueText)
                        }
                    }
                    self.updateUI?()
                }
                
            case let cardStarted as AIAssistantCardStartedEvent:
                self.showCardLoading(runId: cardStarted.runId, executionText: cardStarted.executionText)
                self.updateUI?()
                
            case let cardReceived as AIAssistantCardReceivedEvent:
                self.showStreamedCard(cardReceived)
                self.updateUI?()
                
            case is AIAssistantCardEndedEvent:
                // No-op: card is already rendered by cardReceived
                break
                
            default:
                break
            }
        }
    }
    
    // MARK: - Streaming Card Helpers
    
    private var cardLoadingView: UIView?
    /// Every card received in the current run, in arrival order, each wrapped in
    /// its padded container inside the bubble stack.
    private var streamedCardViews: [CometChatCardView] = []
    private var streamedCardContainers: [UIView] = []
    /// The run the cards above belong to.
    private var streamedCardsRunId: Int?

    /// Reference to the bubble's vertical stack (set during setupUI)
    private weak var bubbleStack: UIStackView?

    /// Removes the loading placeholder and every streamed card.
    private func removeStreamedCards() {
        cardLoadingView?.removeFromSuperview()
        cardLoadingView = nil
        streamedCardContainers.forEach { $0.removeFromSuperview() }
        streamedCardContainers.removeAll()
        streamedCardViews.removeAll()
        streamedCardsRunId = nil
    }

    /// Cards from an earlier run make way for the cards of `runId`; cards already
    /// received in the same run are kept.
    private func prepareCards(forRun runId: Int) {
        if let cardsRunId = streamedCardsRunId, cardsRunId != runId {
            removeStreamedCards()
        }
        streamedCardsRunId = runId
    }

    private func showCardLoading(runId: Int, executionText: String? = nil) {
        hideThinking()
        prepareCards(forRun: runId)

        // Replace any earlier placeholder; cards already shown stay
        cardLoadingView?.removeFromSuperview()

        let loadingContainer = UIView()
        loadingContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = (executionText?.isEmpty == false) ? executionText : "Loading card..."
        label.font = CometChatTypography.Caption1.regular
        label.adjustsFontForContentSizeCategory = true
        label.textColor = CometChatTheme.textColorSecondary
        
        loadingContainer.addSubview(spinner)
        loadingContainer.addSubview(label)
        
        NSLayoutConstraint.activate([
            spinner.leadingAnchor.constraint(equalTo: loadingContainer.leadingAnchor, constant: 8),
            spinner.centerYAnchor.constraint(equalTo: loadingContainer.centerYAnchor),
            label.leadingAnchor.constraint(equalTo: spinner.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: loadingContainer.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: loadingContainer.trailingAnchor, constant: -8),
            loadingContainer.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Add to the bubbleStack so it flows inline with text
        if let stack = bubbleStack {
            stack.addArrangedSubview(loadingContainer)
        }
        
        cardLoadingView = loadingContainer
        
        // Force the cell to recalculate its height
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
        if let tableView = self.superview as? UITableView {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }
    
    private func showStreamedCard(_ event: AIAssistantCardReceivedEvent) {
        // A card can arrive without a card-started event; either way the
        // Thinking indicator must not stay up beside it.
        hideThinking()
        prepareCards(forRun: event.runId)

        // Remove loading placeholder
        if let loading = cardLoadingView {
            loading.removeFromSuperview()
            cardLoadingView = nil
        }

        guard let card = event.getCard() else {
            return
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: card, options: []),
              let jsonString = String(data: jsonData, encoding: .utf8) else { return }
        
        let cardView = CometChatCardView()
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.themeMode = .auto
        
        // Set action callback before cardJson (triggers render)
        cardView.actionCallback = { [weak self] actionEvent in
            guard let self = self, let msg = self.messageObj else { return }
            CometChatCardEvents.ccCardActionClicked(message: msg, action: actionEvent)
        }
        cardView.cardJson = jsonString
        
        // Wrap in a padded container for clean presentation
        let cardContainer = UIView()
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        cardContainer.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 4),
            cardView.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor),
            cardView.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -4)
        ])
        
        // Add to the bubbleStack, after any card already shown in this run
        if let stack = bubbleStack {
            stack.addArrangedSubview(cardContainer)
        }

        streamedCardViews.append(cardView)
        streamedCardContainers.append(cardContainer)
        
        // Force the cell to recalculate its height after the card is added
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self.invalidateIntrinsicContentSize()
        
        // Allow card to overflow the bubble's constrained width (no clipping)
        self.contentView.clipsToBounds = false
        self.clipsToBounds = false
        bubbleView.clipsToBounds = false
        bubbleStack?.clipsToBounds = false
        containerStackView.clipsToBounds = false
        
        // Tell the table view to recalculate this cell's height
        if let tableView = self.superview as? UITableView {
            UIView.performWithoutAnimation {
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        }
    }

    func processStreamContent(runId: Int, content: String) {
        if let message = self.messageObj {
            message.metaData?["__show_thinking__"] = false
        }
        hideThinking()
        streamBuffer += content
        if !content.isEmpty {
            lastWrittenRunId = runId
        }
        queueManager.appendToBuffer(runId: runId, delta: content)
        if !isUpdatingUI {
            isUpdatingUI = true
            DispatchQueue.main.asyncAfter(deadline: .now() + uiUpdateInterval) { [weak self] in
                guard let self = self else { return }
                guard let startIndex = self.streamBuffer.index(self.streamBuffer.startIndex, offsetBy: self.displayedLength, limitedBy: self.streamBuffer.endIndex) else {
                    // The buffer was replaced underneath the pending update; it was
                    // re-rendered in full by whoever replaced it.
                    self.displayedLength = self.streamBuffer.count
                    self.isUpdatingUI = false
                    self.updateUI?()
                    return
                }
                let newContent = String(self.streamBuffer[startIndex...])
                if !newContent.isEmpty {
                    self.markdownView.append(markdownChunk: newContent)
                    self.displayedLength = self.streamBuffer.count
                }
                self.isUpdatingUI = false
                self.updateUI?()
            }
        }
    }
    
    func appendBufferedContent() {
        hideThinking()
        markdownView.reset()
        markdownView.append(markdownChunk: streamBuffer)
        updateUI?()
    }
    
    func hideThinking() {
        typingIndicator.stopAnimating()
        typingIndicator.isHidden = true
    }
}

public class TypingIndicatorView: UILabel {
    private var timer: Timer?
    private var dotCount = 0
    private let gradientLayer = CAGradientLayer()
    private let shimmerAnimationKey = "shimmerAnimation"
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
        setupShimmer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
        setupShimmer()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
    
    // MARK: - Setup
    private func setupLabel() {
        text = "Thinking"
        font = CometChatTypography.Heading4.regular
        textColor = CometChatTheme.textColorTertiary
        textAlignment = .center
        clipsToBounds = true
    }
    
    private func setupShimmer() {
        // Not a theme candidate: this gradient is assigned to `layer.mask` below, and a
        // mask uses only the alpha channel — the colour never reaches the screen. Routing
        // it through CometChatTheme would change nothing visually while implying the
        // shimmer is themeable. The 0.25/0.9/0.25 alphas are the actual contract.
        gradientLayer.colors = [
            UIColor.gray.withAlphaComponent(0.25).cgColor,
            UIColor.gray.withAlphaComponent(0.9).cgColor,
            UIColor.gray.withAlphaComponent(0.25).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.frame = bounds
        layer.mask = gradientLayer
    }
    
    // MARK: - Animation Controls
    func startAnimating() {
        stopAnimating()
        startShimmer()
        
        dotCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.dotCount = (self.dotCount + 1) % 4
            let dots = String(repeating: ".", count: self.dotCount)
            self.text = "Thinking" + dots
        }
    }
    
    func stopAnimating() {
        timer?.invalidate()
        timer = nil
        stopShimmer()
        self.text = "Thinking"
    }
    
    // MARK: - Shimmer Logic
    private func startShimmer() {
        if gradientLayer.animation(forKey: shimmerAnimationKey) != nil { return }

        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [-1, -0.5, 0]
        animation.toValue = [1, 1.5, 2]
        animation.duration = 1.4
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: shimmerAnimationKey)
    }
    
    private func stopShimmer() {
        gradientLayer.removeAnimation(forKey: shimmerAnimationKey)
    }
}
