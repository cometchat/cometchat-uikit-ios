//
//  CometChatStreamBubble.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 30/09/25.
//

import Foundation
import UIKit
import CometChatSDK

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

    
    private var originalMessageText: [Int: String] = [:]
    
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
    
    open func setupStyle() {
        markdownView.style = style
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
            messageLabel.numberOfLines = 0

            typingIndicator.isHidden = true
            typingIndicator.translatesAutoresizingMaskIntoConstraints = false

            // --- Error view styling ---
            errorContainerView.backgroundColor = UIColor(red: 1, green: 0.95, blue: 0.95, alpha: 1) // light red/pink
            errorContainerView.layer.cornerRadius = 12
            errorContainerView.layer.masksToBounds = true
            errorContainerView.isHidden = true
            errorContainerView.translatesAutoresizingMaskIntoConstraints = false
            errorContainerView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

            errorLabel.textColor = UIColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1)
            errorLabel.font = CometChatTypography.Caption1.regular
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
        print("🟢 Stream completed")
    }

    public func onStreamInterrupted() {
        showError()
        print("🔴 Stream interrupted - showing error UI")
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
    public func isFirstChunk(runId: Int) -> Bool {
        return messageLabel.text?.isEmpty ?? true
    }

    // MARK: - UI States
    func showThinking() {
        hasError = false
        errorContainerView.isHidden = true
        typingIndicator.isHidden = false
        typingIndicator.startAnimating()
        messageLabel.isHidden = true
        markdownView.reset()
    }
    
    func startStreaming(firstChunk: String) {
        hideThinking()
        markdownView.reset()                    // Clear previous message
        markdownView.append(markdownChunk: firstChunk)
        
        streamBuffer = firstChunk
        displayedLength = streamBuffer.count
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
    }
    
    func completeStreaming(finalText: String) {
        hideThinking()
        markdownView.reset()
        markdownView.append(markdownChunk: finalText)
        
        streamBuffer = finalText
        displayedLength = streamBuffer.count
        updateUI?()
    }


    func showError() {
        typingIndicator.stopAnimating()
        typingIndicator.isHidden = true
        messageLabel.isHidden = true
        errorContainerView.isHidden = false
        errorLabel.text = "Something went wrong. Please try again"

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
                if self.originalMessageText[toolStart.runId] == nil {
                    self.originalMessageText[toolStart.runId] = self.messageLabel.text ?? ""
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
                    self.updateUI?()
                }
            default:
                break
            }
        }
    }

    func processStreamContent(runId: Int, content: String) {
        if let message = self.messageObj {
            message.metaData?["__show_thinking__"] = false
        }
        hideThinking()
        streamBuffer += content
        queueManager.appendToBuffer(runId: runId, delta: content)
        if !isUpdatingUI {
            isUpdatingUI = true
            DispatchQueue.main.asyncAfter(deadline: .now() + uiUpdateInterval) { [weak self] in
                guard let self = self else { return }
                let startIndex = self.streamBuffer.index(self.streamBuffer.startIndex, offsetBy: self.displayedLength)
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



