//
//  CometChatTextBubble.swift
//
//
//  Created by Abdullah Ansari on 19/12/22.
//

import UIKit
import SafariServices
import MessageUI
import CometChatSDK

public class CometChatTextBubble: UIView {
    
    public weak var controller: UIViewController?
    public var style = TextBubbleStyle() {
        didSet {
            applyStyle()
        }
    }
    private var hasAttributedText = false
    
    /// Message for processing text formatters (mentions, etc.) in markdown mode
    public var message: TextMessage?
    /// Text formatters for processing mentions, etc. in markdown mode
    public var textFormatters: [CometChatTextFormatter] = []
    /// Alignment for mention styling
    public var alignment: MessageBubbleAlignment = .left
    
    /// Stack view to hold text segments and code blocks
    private lazy var contentStackView: UIStackView = {
        let stack = UIStackView().withoutAutoresizingMaskConstraints()
        stack.axis = .vertical
        stack.spacing = 8
        stack.alignment = .fill
        return stack
    }()
    
    public lazy var label: HyperlinkLabel = {
        let label = HyperlinkLabel().withoutAutoresizingMaskConstraints()
        label.numberOfLines = 0
        return label
    }()
    private let phoneParser1 = HyperlinkType.custom(pattern: RegexParser.phonePattern1)
    private let phoneParser2 = HyperlinkType.custom(pattern: RegexParser.phonePattern2)
    private let emailParser = HyperlinkType.custom(pattern: RegexParser.emailPattern)
    
    /// Code block background color (configurable)
    public var codeBlockBackgroundColor: UIColor = CometChatTheme.white.withAlphaComponent(0.1)
    
    /// Inline code background color (configurable)
    public var inlineCodeBackgroundColor: UIColor = CometChatTheme.white.withAlphaComponent(0.1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpHyperLinkLabel()
        buildUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            applyStyle()
            //updateLabelAlignment()
        }
    }
    
    public func buildUI() {
        
        self.withoutAutoresizingMaskConstraints()
        NSLayoutConstraint.activate([
            widthAnchor.pin(lessThanOrEqualToConstant: UIScreen.main.bounds.width/1.2),
        ])
        
        self.embed(
            label,
            insets: .init(
                top: CometChatSpacing.Padding.p3,
                leading: CometChatSpacing.Padding.p3,
                bottom: 0,
                trailing: CometChatSpacing.Padding.p3
            )
        )
        
        applyStyle()
    }
    
    /// Rebuilds UI with stack view for mixed content (text + code blocks)
    private func buildStackUI() {
        // Remove label if it was added directly
        label.removeFromSuperview()
        
        // Remove contentStackView if already added (to avoid duplicate constraints)
        contentStackView.removeFromSuperview()
        
        // Clear any existing arranged subviews
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add stack view
        self.embed(
            contentStackView,
            insets: .init(
                top: CometChatSpacing.Padding.p3,
                leading: CometChatSpacing.Padding.p3,
                bottom: 0,
                trailing: CometChatSpacing.Padding.p3
            )
        )
        
    }
    
    open func applyStyle() {
        // Only set textColor and font if not using attributed text
        // Setting textColor on HyperlinkLabel triggers updateTextStorage which can interfere
        // with the attributed string's foreground colors (like inline code purple)
        if !hasAttributedText {
            self.label.textColor = style.textColor
            self.label.font = style.textFont
            
            // Only customize hyperlink colors if not using attributed text
            // The customize block calls updateTextStorage() which can interfere with attributed text colors
            label.customize { label in
                label.URLColor = style.textHighlightColor
                label.URLSelectedColor = style.textHighlightColor
                label.customColor[phoneParser1] = style.textHighlightColor
                label.customSelectedColor[phoneParser1] = style.textHighlightColor
                label.customColor[phoneParser2] = style.textHighlightColor
                label.customSelectedColor[phoneParser2] = style.textHighlightColor
                label.customColor[emailParser] = style.textHighlightColor
                label.customSelectedColor[emailParser] = style.textHighlightColor
                
                label.addUnderline[phoneParser1] = true
                label.addUnderline[phoneParser2] = true
                label.addUnderline[emailParser] = true
            }
        }
    }
    
    open func setUpHyperLinkLabel() {
        
        label.enabledTypes.append(phoneParser1)
        label.enabledTypes.append(phoneParser2)
        label.enabledTypes.append(emailParser)

        self.label.handleURLTap { link in
            UIApplication.shared.open(link)
        }
        
        self.label.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern1)) { (number) in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            if let url = URL(string: "tel://\(number)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
        }
        
        self.label.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern2)) { (number) in
            let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
            if let url = URL(string: "tel://\(number)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        self.label.handleCustomTap(for: .custom(pattern: RegexParser.emailPattern)) { [weak self] (emailID) in
            
            guard let this = self else { return }
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = this
                mail.setToRecipients([emailID])

                if let  topViewController = this.window?.topViewController() as? UIViewController{
                    topViewController.present(mail, animated: true, completion: nil)
                }
               
            } else {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "OK".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                confirmDialog.set(title: "WARNING".localize())
                confirmDialog.set(messageText: "MAIL_APP_NOT_FOUND_MESSAGE".localize())
                confirmDialog.open(onConfirm: { [weak self] in
                    guard let strongSelf = self else { return }
                    
                })
            }
        }
        
    }
    
    public func set(text: String) {
        label.text = text
     }
     
    public func set(attributedText: NSAttributedString) {
        
        // First, set up the custom link types BEFORE setting attributedText
        // This ensures HyperlinkLabel parses them correctly
        setupAttributedLinksBeforeDisplay(in: attributedText)
        
        
        // Now set the attributed text - this triggers updateTextStorage which will parse our custom types
        label.attributedText = attributedText
        hasAttributedText = true
        
    }
    
    /// Sets text with markdown, rendering code blocks and blockquotes with proper styling
    public func setMarkdownText(_ markdown: String, baseFont: UIFont, baseColor: UIColor, codeTextColor: UIColor? = nil, inlineCodeTextColor: UIColor? = nil) {
        
        // Check if text contains code blocks (``` ... ```) or blockquotes (> at start of line)
        let hasCodeBlocks = markdown.contains("```")
        let lines = markdown.components(separatedBy: "\n")
        let hasBlockquotes = lines.contains { line in
            line.hasPrefix("> ") || line == ">"
        }
        
        
        if hasCodeBlocks || hasBlockquotes {
            // Use stack view for mixed content
            buildStackUI()
            parseAndDisplayMixedContent(markdown, baseFont: baseFont, baseColor: baseColor, codeTextColor: codeTextColor, inlineCodeTextColor: inlineCodeTextColor)
        } else {
            // Simple case - just use attributed string for inline formatting
            let attributedString = RichTextFormatterManager.shared.parseMarkdown(
                markdown,
                baseFont: baseFont,
                baseColor: baseColor,
                inlineCodeBackgroundColor: inlineCodeBackgroundColor,
                codeBlockBackgroundColor: codeBlockBackgroundColor,
                codeTextColor: codeTextColor,
                inlineCodeTextColor: inlineCodeTextColor
            )
            set(attributedText: attributedString)
        }
    }
    
    /// Parses markdown and creates separate views for code blocks and blockquotes
    private func parseAndDisplayMixedContent(_ markdown: String, baseFont: UIFont, baseColor: UIColor, codeTextColor: UIColor? = nil, inlineCodeTextColor: UIColor? = nil) {
        // Clear existing content
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        
        // Process line by line to handle blockquotes, then handle code blocks within segments
        let lines = markdown.components(separatedBy: "\n")
        var currentSegment: [String] = []
        var isInBlockquote = false
        var blockquoteLines: [String] = []
        
        for line in lines {
            let isBlockquoteLine = line.hasPrefix("> ") || line == ">"
            
            if isBlockquoteLine {
                // If we were building a regular segment, flush it first
                if !currentSegment.isEmpty {
                    let segmentText = currentSegment.joined(separator: "\n")
                    addMixedContentSegment(segmentText, baseFont: baseFont, baseColor: baseColor, codeTextColor: codeTextColor, inlineCodeTextColor: inlineCodeTextColor)
                    currentSegment = []
                }
                
                // Add to blockquote
                isInBlockquote = true
                let quoteContent = line.hasPrefix("> ") ? String(line.dropFirst(2)) : ""
                blockquoteLines.append(quoteContent)
            } else {
                // If we were building a blockquote, flush it first
                if isInBlockquote && !blockquoteLines.isEmpty {
                    addBlockquoteView(blockquoteLines.joined(separator: "\n"), baseFont: baseFont, baseColor: baseColor, codeTextColor: codeTextColor, inlineCodeTextColor: inlineCodeTextColor)
                    blockquoteLines = []
                    isInBlockquote = false
                }
                
                // Add to regular segment
                currentSegment.append(line)
            }
        }
        
        // Flush any remaining content
        if !blockquoteLines.isEmpty {
            addBlockquoteView(blockquoteLines.joined(separator: "\n"), baseFont: baseFont, baseColor: baseColor, codeTextColor: codeTextColor, inlineCodeTextColor: inlineCodeTextColor)
        }
        if !currentSegment.isEmpty {
            let segmentText = currentSegment.joined(separator: "\n")
            addMixedContentSegment(segmentText, baseFont: baseFont, baseColor: baseColor, codeTextColor: codeTextColor, inlineCodeTextColor: inlineCodeTextColor)
        }
    }
    
    /// Adds a segment that may contain code blocks
    private func addMixedContentSegment(_ text: String, baseFont: UIFont, baseColor: UIColor, codeTextColor: UIColor? = nil, inlineCodeTextColor: UIColor? = nil) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        // Check if this segment contains code blocks
        if trimmedText.contains("```") {
            // Pass clearExisting: false since we're adding to existing content (e.g., after a blockquote)
            parseAndDisplayWithCodeBlocks(trimmedText, baseFont: baseFont, baseColor: baseColor, codeTextColor: codeTextColor, inlineCodeTextColor: inlineCodeTextColor, clearExisting: false)
        } else {
            addTextSegment(trimmedText, baseFont: baseFont, baseColor: baseColor, codeTextColor: codeTextColor, inlineCodeTextColor: inlineCodeTextColor)
        }
    }
    
    /// Adds a blockquote view with proper left bar styling and background
    private func addBlockquoteView(_ text: String, baseFont: UIFont, baseColor: UIColor, codeTextColor: UIColor? = nil, inlineCodeTextColor: UIColor? = nil) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        
        // Keep shortcodes as-is in blockquotes - don't convert them back to emojis
        // This allows users to see and copy the shortcode text (e.g., :grinning_face:)
        
        // Process mentions FIRST if we have a message and text formatters
        // This converts <@uid:...> to @Username with proper styling
        var attributedText: NSAttributedString
        if let message = self.message, !textFormatters.isEmpty {
            // Create a temporary HyperlinkLabel to process mentions
            let tempLabel = HyperlinkLabel()
            tempLabel.numberOfLines = 0
            
            if let processedString = MessageUtils.processTextFormatter(
                for: message,
                customText: trimmedText,
                in: tempLabel,
                textFormatter: textFormatters,
                controller: controller,
                alignment: alignment
            ) {
                // Now parse markdown on the processed text (with mentions already styled)
                let mentionProcessedText = processedString.string
                
                // Parse markdown for inline formatting (bold, italic, inline code)
                let markdownParsed = RichTextFormatterManager.shared.parseMarkdown(
                    mentionProcessedText,
                    baseFont: baseFont,
                    baseColor: baseColor,
                    inlineCodeBackgroundColor: inlineCodeBackgroundColor,
                    codeBlockBackgroundColor: codeBlockBackgroundColor,
                    codeTextColor: codeTextColor,
                    inlineCodeTextColor: inlineCodeTextColor
                )
                
                // Merge: start with markdown parsed, then overlay mention styling
                let mutableResult = NSMutableAttributedString(attributedString: markdownParsed)
                
                // Apply mention attributes from processedString
                processedString.enumerateAttributes(in: NSRange(location: 0, length: processedString.length), options: []) { attrs, range, _ in
                    // Apply mention-specific attributes (background color, foreground color for mentions)
                    if let bgColor = attrs[.backgroundColor] {
                        if range.location + range.length <= mutableResult.length {
                            mutableResult.addAttribute(.backgroundColor, value: bgColor, range: range)
                        }
                    }
                    if let fgColor = attrs[.foregroundColor] {
                        if range.location + range.length <= mutableResult.length {
                            mutableResult.addAttribute(.foregroundColor, value: fgColor, range: range)
                        }
                    }
                }
                
                attributedText = mutableResult
            } else {
                // Fallback to just parsing markdown
                attributedText = RichTextFormatterManager.shared.parseMarkdown(
                    trimmedText,
                    baseFont: baseFont,
                    baseColor: baseColor,
                    inlineCodeBackgroundColor: inlineCodeBackgroundColor,
                    codeBlockBackgroundColor: codeBlockBackgroundColor,
                    codeTextColor: codeTextColor,
                    inlineCodeTextColor: inlineCodeTextColor
                )
            }
        } else {
            // No mentions to process - just parse markdown
            attributedText = RichTextFormatterManager.shared.parseMarkdown(
                trimmedText,
                baseFont: baseFont,
                baseColor: baseColor,
                inlineCodeBackgroundColor: inlineCodeBackgroundColor,
                codeBlockBackgroundColor: codeBlockBackgroundColor,
                codeTextColor: codeTextColor,
                inlineCodeTextColor: inlineCodeTextColor
            )
        }
        
        
        // Determine if this is a light or dark text color to choose appropriate bar and background colors
        // For light text (outgoing messages), use a light bar and semi-transparent white background
        // For dark text (incoming messages), use the primary color bar and white background
        let barColor: UIColor
        let quoteBackgroundColor: UIColor
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        baseColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let brightness = (red + green + blue) / 3.0
        
        if brightness > 0.5 {
            // Light text (outgoing message) - use white bar and semi-transparent white background
            barColor = UIColor.white
            quoteBackgroundColor = UIColor.white.withAlphaComponent(0.2)
        } else {
            // Dark text (incoming message) - use primary color bar and white background
            barColor = CometChatTheme.primaryColor
            quoteBackgroundColor = UIColor.white
        }
        
        let blockquoteView = BlockquoteView(
            attributedText: attributedText,
            barColor: barColor,
            textColor: baseColor,
            quoteBackgroundColor: quoteBackgroundColor
        )
        
        contentStackView.addArrangedSubview(blockquoteView)
    }
    
    /// Parses markdown and creates separate views for code blocks
    /// - Parameter clearExisting: If true, clears existing content first. Set to false when called from addMixedContentSegment.
    private func parseAndDisplayWithCodeBlocks(_ markdown: String, baseFont: UIFont, baseColor: UIColor, codeTextColor: UIColor? = nil, inlineCodeTextColor: UIColor? = nil, clearExisting: Bool = true) {
        // Only clear existing content if called directly (not from addMixedContentSegment)
        if clearExisting {
            contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        }
        
        // Split by code block pattern
        let pattern = "```[\\s\\S]*?```"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            // Fallback to simple text
            addTextSegment(markdown, baseFont: baseFont, baseColor: baseColor, codeTextColor: codeTextColor, inlineCodeTextColor: inlineCodeTextColor)
            return
        }
        
        let nsString = markdown as NSString
        let fullRange = NSRange(location: 0, length: nsString.length)
        let matches = regex.matches(in: markdown, options: [], range: fullRange)
        
        var lastEnd = 0
        
        for match in matches {
            // Add text before this code block
            if match.range.location > lastEnd {
                let textRange = NSRange(location: lastEnd, length: match.range.location - lastEnd)
                let textBefore = nsString.substring(with: textRange)
                addTextSegment(textBefore, baseFont: baseFont, baseColor: baseColor, codeTextColor: codeTextColor, inlineCodeTextColor: inlineCodeTextColor)
            }
            
            // Extract code block content (remove ``` markers)
            var codeBlock = nsString.substring(with: match.range)
            
            // Remove opening ```
            if codeBlock.hasPrefix("```") {
                codeBlock = String(codeBlock.dropFirst(3))
            }
            // Remove closing ```
            if codeBlock.hasSuffix("```") {
                codeBlock = String(codeBlock.dropLast(3))
            }
            // Trim leading/trailing newlines
            codeBlock = codeBlock.trimmingCharacters(in: .newlines)
            
            // Add code block view
            if !codeBlock.isEmpty {
                addCodeBlockView(codeBlock, baseFont: baseFont, codeTextColor: codeTextColor)
            }
            
            lastEnd = match.range.location + match.range.length
        }
        
        // Add any remaining text after the last code block
        if lastEnd < nsString.length {
            let remainingRange = NSRange(location: lastEnd, length: nsString.length - lastEnd)
            let remainingText = nsString.substring(with: remainingRange)
            addTextSegment(remainingText, baseFont: baseFont, baseColor: baseColor, codeTextColor: codeTextColor, inlineCodeTextColor: inlineCodeTextColor)
        }
    }
    
    /// Adds a text segment (with inline formatting) to the stack
    private func addTextSegment(_ text: String, baseFont: UIFont, baseColor: UIColor, codeTextColor: UIColor? = nil, inlineCodeTextColor: UIColor? = nil) {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let textLabel = HyperlinkLabel()
        textLabel.numberOfLines = 0
        
        // Process mentions FIRST if we have a message and text formatters
        // This converts <@uid:...> to @Username with proper styling
        if let message = self.message, !textFormatters.isEmpty {
            // Use processTextFormatter which handles mention tags and applies styling
            if let processedString = MessageUtils.processTextFormatter(
                for: message,
                customText: trimmedText,
                in: textLabel,
                textFormatter: textFormatters,
                controller: controller,
                alignment: alignment
            ) {
                // Now parse markdown on the processed text (with mentions already styled)
                // We need to preserve mention styling while adding markdown formatting
                let mentionProcessedText = processedString.string
                
                // Parse markdown for inline formatting (bold, italic, inline code)
                let markdownParsed = RichTextFormatterManager.shared.parseMarkdown(
                    mentionProcessedText,
                    baseFont: baseFont,
                    baseColor: baseColor,
                    inlineCodeBackgroundColor: inlineCodeBackgroundColor,
                    codeBlockBackgroundColor: codeBlockBackgroundColor,
                    codeTextColor: codeTextColor,
                    inlineCodeTextColor: inlineCodeTextColor
                )
                
                // Merge: start with markdown parsed, then overlay mention styling
                let mutableResult = NSMutableAttributedString(attributedString: markdownParsed)
                
                // Apply mention attributes from processedString
                processedString.enumerateAttributes(in: NSRange(location: 0, length: processedString.length), options: []) { attrs, range, _ in
                    // Apply mention-specific attributes (background color, foreground color for mentions)
                    if let bgColor = attrs[.backgroundColor] {
                        if range.location + range.length <= mutableResult.length {
                            mutableResult.addAttribute(.backgroundColor, value: bgColor, range: range)
                        }
                    }
                    if let fgColor = attrs[.foregroundColor] {
                        if range.location + range.length <= mutableResult.length {
                            mutableResult.addAttribute(.foregroundColor, value: fgColor, range: range)
                        }
                    }
                }
                
                // Set up link handlers BEFORE setting attributedText
                setupAttributedLinksForLabel(textLabel, in: mutableResult)
                textLabel.attributedText = mutableResult
                contentStackView.addArrangedSubview(textLabel)
                return
            }
        }
        
        // No mentions to process - just parse markdown
        let attributedString = RichTextFormatterManager.shared.parseMarkdown(
            trimmedText,
            baseFont: baseFont,
            baseColor: baseColor,
            inlineCodeBackgroundColor: inlineCodeBackgroundColor,
            codeBlockBackgroundColor: codeBlockBackgroundColor,
            codeTextColor: codeTextColor,
            inlineCodeTextColor: inlineCodeTextColor
        )
        
        // Set up link handlers BEFORE setting attributedText so HyperlinkLabel parses them correctly
        setupAttributedLinksForLabel(textLabel, in: attributedString)
        
        // Now set the attributed text - this triggers updateTextStorage which will parse our custom types
        textLabel.attributedText = attributedString
        
        contentStackView.addArrangedSubview(textLabel)
    }
    
    /// Sets up tap handlers for links in attributed text for a specific HyperlinkLabel
    private func setupAttributedLinksForLabel(_ label: HyperlinkLabel, in attributedText: NSAttributedString) {
        let fullRange = NSRange(location: 0, length: attributedText.length)
        let customLinkKey = NSAttributedString.Key("CometChatLinkURL")
        
        // Check for both standard .link attribute and our custom CometChatLinkURL attribute
        attributedText.enumerateAttributes(in: fullRange, options: []) { [weak self] attrs, range, _ in
            guard let self = self else { return }
            
            // Check for our custom link attribute first, then fall back to standard .link
            let link = attrs[customLinkKey] ?? attrs[.link]
            guard let linkValue = link else { return }
            
            let urlString: String
            if let url = linkValue as? URL {
                urlString = url.absoluteString
            } else if let str = linkValue as? String {
                urlString = str
            } else {
                return
            }
            
            // Get the text at this range
            let linkText = (attributedText.string as NSString).substring(with: range)
            
            // Create a custom hyperlink type for this specific link
            let escapedText = NSRegularExpression.escapedPattern(for: linkText)
            let customType = HyperlinkType.custom(pattern: escapedText)
            
            // Add the custom type to enabled types if not already present
            if !label.enabledTypes.contains(where: { type in
                if case .custom(let pattern) = type, case .custom(let otherPattern) = customType {
                    return pattern == otherPattern
                }
                return false
            }) {
                label.enabledTypes.append(customType)
            }
            
            // Set the color and underline for this custom link type to match the text highlight color
            label.customColor[customType] = self.style.textHighlightColor
            label.customSelectedColor[customType] = self.style.textHighlightColor
            label.addUnderline[customType] = true
            
            // Handle tap for this link
            label.handleCustomTap(for: customType) { _ in
                guard let url = URL(string: urlString) else { return }
                UIApplication.shared.open(url)
            }
        }
    }
    
    /// Adds a code block view with proper padding and rounded corners
    private func addCodeBlockView(_ code: String, baseFont: UIFont, codeTextColor: UIColor? = nil) {
        
        // Create a wrapper view to allow the code block to size to content
        let wrapperView = UIView()
        wrapperView.translatesAutoresizingMaskIntoConstraints = false
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.backgroundColor = codeBlockBackgroundColor
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true
        
        let codeLabel = CopyableLabel()
        codeLabel.numberOfLines = 0
        codeLabel.font = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize - 1, weight: .regular)
        codeLabel.textColor = codeTextColor ?? style.textColor
        codeLabel.isUserInteractionEnabled = true
        codeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Process mentions if we have a message and text formatters
        // This converts <@uid:...> to @Username with proper styling
        if let message = self.message, !textFormatters.isEmpty {
            // Create a temporary HyperlinkLabel to process mentions
            let tempLabel = HyperlinkLabel()
            tempLabel.numberOfLines = 0
            
            if let processedString = MessageUtils.processTextFormatter(
                for: message,
                customText: code,
                in: tempLabel,
                textFormatter: textFormatters,
                controller: controller,
                alignment: alignment
            ) {
                // Create attributed string with code styling
                let monoFont = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize - 1, weight: .regular)
                let codeAttributes: [NSAttributedString.Key: Any] = [
                    .font: monoFont,
                    .foregroundColor: codeTextColor ?? style.textColor
                ]
                
                let mutableResult = NSMutableAttributedString(string: processedString.string, attributes: codeAttributes)
                
                // Apply mention attributes from processedString (background color, foreground color)
                processedString.enumerateAttributes(in: NSRange(location: 0, length: processedString.length), options: []) { attrs, range, _ in
                    if let bgColor = attrs[.backgroundColor] {
                        if range.location + range.length <= mutableResult.length {
                            mutableResult.addAttribute(.backgroundColor, value: bgColor, range: range)
                        }
                    }
                    if let fgColor = attrs[.foregroundColor] {
                        if range.location + range.length <= mutableResult.length {
                            mutableResult.addAttribute(.foregroundColor, value: fgColor, range: range)
                        }
                    }
                }
                
                codeLabel.attributedText = mutableResult
            } else {
                codeLabel.text = code
            }
        } else {
            codeLabel.text = code
        }
        
        containerView.addSubview(codeLabel)
        wrapperView.addSubview(containerView)
        
        // Add padding inside the container
        NSLayoutConstraint.activate([
            codeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            codeLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            codeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            codeLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        // Position container in wrapper - align based on message alignment
        // Container should hug its content width but have a minimum width
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: wrapperView.topAnchor),
            containerView.bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
            // Allow container to be smaller than wrapper
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: wrapperView.trailingAnchor),
            // Minimum width for code blocks so single characters don't look too narrow
            containerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
        ])
        
        // Set content hugging priority so the container hugs its content
        containerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        codeLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        contentStackView.addArrangedSubview(wrapperView)
    }
    
    /// Sets up custom hyperlink types for links in attributed text BEFORE setting attributedText
    /// This ensures HyperlinkLabel parses them correctly when updateTextStorage is called
    private func setupAttributedLinksBeforeDisplay(in attributedText: NSAttributedString) {
        let fullRange = NSRange(location: 0, length: attributedText.length)
        let customLinkKey = NSAttributedString.Key("CometChatLinkURL")
        
        
        // Check for both standard .link attribute and our custom CometChatLinkURL attribute
        attributedText.enumerateAttributes(in: fullRange, options: []) { [weak self] attrs, range, _ in
            guard let self = self else { return }
            
            
            // Check for our custom link attribute first, then fall back to standard .link
            let link = attrs[customLinkKey] ?? attrs[.link]
            guard let linkValue = link else { 
                return 
            }
            
            let urlString: String
            if let url = linkValue as? URL {
                urlString = url.absoluteString
            } else if let str = linkValue as? String {
                urlString = str
            } else {
                return
            }
            
            // Get the text at this range
            let linkText = (attributedText.string as NSString).substring(with: range)
            
            
            // Create a custom hyperlink type for this specific link
            let escapedText = NSRegularExpression.escapedPattern(for: linkText)
            let customType = HyperlinkType.custom(pattern: escapedText)
            
            
            // Add the custom type to enabled types if not already present
            if !self.label.enabledTypes.contains(where: { type in
                if case .custom(let pattern) = type, case .custom(let otherPattern) = customType {
                    return pattern == otherPattern
                }
                return false
            }) {
                self.label.enabledTypes.append(customType)
            }
            
            // Set the color and underline for this custom link type to match the text highlight color
            self.label.customColor[customType] = self.style.textHighlightColor
            self.label.customSelectedColor[customType] = self.style.textHighlightColor
            self.label.addUnderline[customType] = true
            
            // Handle tap for this link
            self.label.handleCustomTap(for: customType) { _ in
                guard let url = URL(string: urlString) else { 
                    return 
                }
                UIApplication.shared.open(url)
            }
        }
    }
    
    /// Sets up tap handlers for links in attributed text
    private func setupAttributedLinks(in attributedText: NSAttributedString) {
        let fullRange = NSRange(location: 0, length: attributedText.length)
        let customLinkKey = NSAttributedString.Key("CometChatLinkURL")
        
        // Check for both standard .link attribute and our custom CometChatLinkURL attribute
        attributedText.enumerateAttributes(in: fullRange, options: []) { [weak self] attrs, range, _ in
            guard let self = self else { return }
            
            // Check for our custom link attribute first, then fall back to standard .link
            let link = attrs[customLinkKey] ?? attrs[.link]
            guard let linkValue = link else { return }
            
            let urlString: String
            if let url = linkValue as? URL {
                urlString = url.absoluteString
            } else if let str = linkValue as? String {
                urlString = str
            } else {
                return
            }
            
            // Get the text at this range
            let linkText = (attributedText.string as NSString).substring(with: range)
            
            // Create a custom hyperlink type for this specific link
            let escapedText = NSRegularExpression.escapedPattern(for: linkText)
            let customType = HyperlinkType.custom(pattern: escapedText)
            
            // Add the custom type to enabled types if not already present
            if !self.label.enabledTypes.contains(where: { type in
                if case .custom(let pattern) = type, case .custom(let otherPattern) = customType {
                    return pattern == otherPattern
                }
                return false
            }) {
                self.label.enabledTypes.append(customType)
            }
            
            // Set the color and underline for this custom link type to match the text highlight color
            self.label.customColor[customType] = self.style.textHighlightColor
            self.label.customSelectedColor[customType] = self.style.textHighlightColor
            self.label.addUnderline[customType] = true
            
            // Handle tap for this link
            self.label.handleCustomTap(for: customType) { [weak self] _ in
                guard let url = URL(string: urlString) else { return }
                UIApplication.shared.open(url)
            }
        }
    }
    
    public func updateLabelAlignment() {
        if (label.text ?? "").containsOnlyEmojis() || (label.attributedText?.string ?? "").containsOnlyEmojis() {
            label.textAlignment = .center
            label.font = applyLargeSizeEmoji()
        }
    }
    
    private func applyLargeSizeEmoji() -> UIFont {
        let normalFont = style.textFont
        if let text = self.label.text, text.containsOnlyEmojis() {
            let count = text.count
            if count == 1 {
                return UIFont.systemFont(ofSize: (normalFont.pointSize * 3.8), weight: .regular)
            } else if count == 2 {
                return  UIFont.systemFont(ofSize: (normalFont.pointSize * 2.4), weight: .regular)
            } else if count == 3 {
                return UIFont.systemFont(ofSize: (normalFont.pointSize * 1.7), weight: .regular)
            } else {
                return UIFont.systemFont(ofSize: normalFont.pointSize, weight: .regular)
            }
         } else {
            return UIFont.systemFont(ofSize: normalFont.pointSize, weight: .regular)
        }
    }
    
}

extension CometChatTextBubble: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}






// MARK: - CopyableLabel
/// A UILabel subclass that supports copy functionality with markdown conversion for code
/// When copying, shortcodes are converted back to emojis (e.g., :grinning_face: -> 😀)
class CopyableLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCopyGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCopyGesture()
    }
    
    private func setupCopyGesture() {
        isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        becomeFirstResponder()
        
        let menuController = UIMenuController.shared
        if !menuController.isMenuVisible {
            menuController.showMenu(from: self, rect: bounds)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        // For code blocks, wrap the text in markdown code block syntax
        // Convert shortcodes back to emojis for pasting
        if let text = text {
            let textWithEmojis = text.shortcodesToEmojis()
            let markdown: String
            if textWithEmojis.contains("\n") {
                // Multi-line code block
                markdown = "```\n\(textWithEmojis)\n```"
            } else {
                // Inline code
                markdown = "`\(textWithEmojis)`"
            }
            UIPasteboard.general.string = markdown
        }
    }
}

// MARK: - BlockquoteView
/// A view that displays blockquoted text with a colored left border bar and background
/// Similar to how modern chat apps (Slack, Discord, iMessage) display quotes
/// When copying, shortcodes are converted back to emojis (e.g., :grinning_face: -> 😀)
class BlockquoteView: UIView {
    
    // MARK: - UI Components
    
    /// Container view with background color and rounded corners
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 8
        view.clipsToBounds = true
        return view
    }()
    
    /// The colored vertical bar on the left side
    private lazy var leftBar: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 1.5
        view.clipsToBounds = true
        return view
    }()
    
    /// The label containing the quoted text (supports copy with emoji conversion)
    lazy var textLabel: CopyableBlockquoteLabel = {
        let label = CopyableBlockquoteLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Style Properties
    
    /// Color of the left vertical bar (defaults to primary color)
    var barColor: UIColor = CometChatTheme.primaryColor {
        didSet { 
            leftBar.backgroundColor = barColor
        }
    }
    
    /// Background color for the quote container
    var quoteBackgroundColor: UIColor = CometChatTheme.neutralColor100 {
        didSet {
            containerView.backgroundColor = quoteBackgroundColor
        }
    }
    
    /// Width of the left vertical bar
    var barWidth: CGFloat = 3 {
        didSet { barWidthConstraint?.constant = barWidth }
    }
    
    /// Spacing between the bar and the text
    var barTextSpacing: CGFloat = 8 {
        didSet { textLeadingConstraint?.constant = barTextSpacing }
    }
    
    /// Text color for the quoted content
    var textColor: UIColor = CometChatTheme.neutralColor900 {
        didSet { textLabel.textColor = textColor }
    }
    
    /// Font for the quoted text
    var textFont: UIFont = .systemFont(ofSize: 14) {
        didSet { textLabel.font = textFont }
    }
    
    // MARK: - Constraints
    
    private var barWidthConstraint: NSLayoutConstraint?
    private var textLeadingConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    convenience init(attributedText: NSAttributedString, barColor: UIColor? = nil, textColor: UIColor? = nil, quoteBackgroundColor: UIColor? = nil) {
        self.init(frame: .zero)
        if let barColor = barColor {
            self.barColor = barColor
            leftBar.backgroundColor = barColor
        }
        if let textColor = textColor {
            self.textColor = textColor
        }
        if let quoteBackgroundColor = quoteBackgroundColor {
            self.quoteBackgroundColor = quoteBackgroundColor
            containerView.backgroundColor = quoteBackgroundColor
        }
        setAttributedText(attributedText)
    }
    
    convenience init(text: String, barColor: UIColor? = nil, textColor: UIColor? = nil, font: UIFont? = nil, quoteBackgroundColor: UIColor? = nil) {
        self.init(frame: .zero)
        if let barColor = barColor {
            self.barColor = barColor
            leftBar.backgroundColor = barColor
        }
        if let textColor = textColor {
            self.textColor = textColor
        }
        if let font = font {
            self.textFont = font
        }
        if let quoteBackgroundColor = quoteBackgroundColor {
            self.quoteBackgroundColor = quoteBackgroundColor
            containerView.backgroundColor = quoteBackgroundColor
        }
        setText(text)
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(containerView)
        containerView.addSubview(leftBar)
        containerView.addSubview(textLabel)
        
        containerView.backgroundColor = quoteBackgroundColor
        leftBar.backgroundColor = barColor
        textLabel.textColor = textColor
        textLabel.font = textFont
        
        // Round only the left corners of the bar to match container
        leftBar.layer.cornerRadius = 0
        leftBar.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        leftBar.layer.cornerRadius = 8
        
        let barWidthConst = leftBar.widthAnchor.constraint(equalToConstant: barWidth)
        let textLeadingConst = textLabel.leadingAnchor.constraint(equalTo: leftBar.trailingAnchor, constant: barTextSpacing)
        
        barWidthConstraint = barWidthConst
        textLeadingConstraint = textLeadingConst
        
        NSLayoutConstraint.activate([
            // Container view fills the BlockquoteView
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            // Left bar - flush with left edge, full height
            leftBar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            leftBar.topAnchor.constraint(equalTo: containerView.topAnchor),
            leftBar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            barWidthConst,
            
            // Text label with padding
            textLeadingConst,
            textLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            textLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            textLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
        ])
    }
    
    // MARK: - Public Methods
    
    func setText(_ text: String) {
        textLabel.text = text
        textLabel.textColor = textColor
        textLabel.font = textFont
    }
    
    func setAttributedText(_ attributedText: NSAttributedString) {
        textLabel.attributedText = attributedText
    }
}

// MARK: - CopyableBlockquoteLabel
/// A UILabel subclass that supports copy functionality for blockquotes
/// When copying, shortcodes are converted back to emojis and wrapped in blockquote markdown
class CopyableBlockquoteLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCopyGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCopyGesture()
    }
    
    private func setupCopyGesture() {
        isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        addGestureRecognizer(longPressGesture)
    }
    
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        becomeFirstResponder()
        
        let menuController = UIMenuController.shared
        if !menuController.isMenuVisible {
            menuController.showMenu(from: self, rect: bounds)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(copy(_:))
    }
    
    override func copy(_ sender: Any?) {
        // For blockquotes, wrap each line with "> " prefix
        // Emojis stay as-is (no shortcode conversion needed for blockquotes)
        let textToCopy = text ?? attributedText?.string ?? ""
        
        // Add blockquote prefix to each line
        let lines = textToCopy.components(separatedBy: "\n")
        let quotedLines = lines.map { "> \($0)" }
        let markdown = quotedLines.joined(separator: "\n")
        
        UIPasteboard.general.string = markdown
    }
}
