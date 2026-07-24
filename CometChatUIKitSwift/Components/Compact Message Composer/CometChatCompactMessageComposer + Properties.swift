//
//  CometChatCompactMessageComposer + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 29/01/26.
//

import UIKit
import CometChatSDK

extension CometChatCompactMessageComposer {
    
    // MARK: - Data Configuration
    
    @discardableResult
    public func set(user: User) -> Self {
        viewModel.set(user: user)
        uploadManager.receiverId = user.uid ?? ""
        uploadManager.receiverType = .user
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.connect()
        }
        return self
    }
    
    @discardableResult
    public func set(group: Group) -> Self {
        viewModel.set(group: group)
        uploadManager.receiverId = group.guid
        uploadManager.receiverType = .group
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.connect()
        }
        return self
    }
    
    @discardableResult
    public func set(parentMessageId: Int) -> Self {
        viewModel.parentMessageId = parentMessageId
        return self
    }
    
    // MARK: - Text Formatter Configuration
    
    @discardableResult
    public func set(textFormatter: [CometChatTextFormatter]) -> Self {
        viewModel.textFormatter = textFormatter
        return self
    }
    
    // MARK: - Callback Configuration
    
    @discardableResult
    public func set(onSendButtonClick: @escaping ((BaseMessage) -> Void)) -> Self {
        self.onSendButtonClick = onSendButtonClick
        return self
    }
    
    @discardableResult
    public func set(onError: ((_ error: CometChatException) -> Void)?) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(onTextChangedListener: @escaping ((String) -> ())) -> Self {
        self.onTextChangedListener = onTextChangedListener
        return self
    }
    
    @discardableResult
    public func set(attachmentOptions: @escaping ((_ user: User?, _ group: Group?, _ controller: UIViewController?) -> [CometChatMessageComposerAction])) -> Self {
        self.attachmentOptionsClosure = attachmentOptions
        return self
    }
    
    // MARK: - View Configuration
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(placeholder: String) -> Self {
        self.placeholderText = placeholder
        textView.placeholder = placeholder
        return self
    }
    
    @discardableResult
    public func set(maxLines: Int) -> Self {
        textView.maxLength = maxLines
        return self
    }
    
    // MARK: - Feature Toggles
    
    @discardableResult
    public func disable(soundForMessages: Bool) -> Self {
        self.disableSoundForMessages = soundForMessages
        return self
    }
    
    @discardableResult
    public func disable(typingEvents: Bool) -> Self {
        self.disableTypingEvents = typingEvents
        return self
    }
    
    @discardableResult
    public func disable(mentions: Bool) -> Self {
        self.disableMentions = mentions
        if mentions {
            if let index = viewModel.textFormatter.firstIndex(where: { $0.formatterID == "internal_mentions" }) {
                var formatters = viewModel.textFormatter
                formatters.remove(at: index)
                viewModel.textFormatter = formatters
            }
        }
        return self
    }
    
    // MARK: - Edit/Reply Mode
    
    @discardableResult
    public func edit(message: BaseMessage) -> Self {
        // Media messages are caption-only editable: the attachments are read-only, the
        // composer edits just the caption text. The caption prefill goes through the
        // SAME pipeline as text-message edits so code blocks, quotes and mentions
        // render immediately (not only after the next keystroke).
        if let media = message as? MediaMessage {
            self.viewModel.message = media
            self.composerState = .edit
            let caption = media.caption ?? ""
            self.originalEditText = caption
            prefillComposerForEdit(text: caption, message: media)
            presentEditPreview(for: media)
            return self
        }

        guard let message = message as? TextMessage else {
            print("[CometChatCompactMessageComposer] Error: Cannot edit non-TextMessage")
            return self
        }

        self.viewModel.message = message
        self.composerState = .edit
        // Set originalEditText even if empty - this is important for change detection
        self.originalEditText = message.text
        prefillComposerForEdit(text: message.text, message: message)
        presentEditPreview(for: message)
        return self
    }

    /// Shared edit-mode prefill for text messages and media captions: resets formatting
    /// state, renders the markdown (with mention formatters) into the text view, and
    /// activates code-block mode when the whole text is one code block.
    private func prefillComposerForEdit(text: String, message: BaseMessage) {
        selectedFormatters.removeAll()
        endOnGoingTextFormatting()
        removeLimitView()

        // Reset formatting state before loading edit content
        RichTextFormatterManager.shared.resetListMode()
        codeBlockBackgroundView.isHidden = true
        codeBlockLeftBorderView.isHidden = true
        blockquoteBarView.isHidden = true
        blockquoteTextRange = nil
        blockquoteStartPosition = nil

        // Check if the message is entirely a code block (```...```)
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let isEntirelyCodeBlock = trimmedText.hasPrefix("```") && trimmedText.hasSuffix("```") && trimmedText.count > 6

        // Parse markdown text to attributed string for editing
        // This ensures that when editing a message, the formatted text is shown
        // instead of raw markdown (e.g., **bold** shows as bold text)
        var attributedString: NSMutableAttributedString
        if enableRichTextFormatting && RichTextFormatterManager.shared.containsMarkdownFormatting(text) {
            // First, process text formatters to convert mention tags to display names
            // This must happen before markdown parsing so mentions inside code blocks are converted
            var processedText = text
            var tempSelectedFormatters: [Character: [(item: SuggestionItem, range: NSRange)]] = [:]

            for (character, formatter) in viewModel.textFormatterMap {
                let regex = formatter.getRegex()
                let tempAttributedString = NSMutableAttributedString(string: processedText)
                let processedString = MessageUtils.processMessageForTextFormatter(tempAttributedString, regex: regex) { regexText in
                    return formatter.prepareMessageString(baseMessage: message, regexString: regexText, formattingType: .COMPOSER)
                }
                tempSelectedFormatters[character] = processedString.1
                processedText = processedString.0.string
            }

            // Parse the markdown to create formatted attributed string
            attributedString = NSMutableAttributedString(
                attributedString: RichTextFormatterManager.shared.parseMarkdown(
                    processedText,
                    baseFont: style.textFieldFont,
                    baseColor: style.textFieldColor,
                    addNewlinesAroundCodeBlocks: false
                )
            )

            // Update selectedFormatters with the processed mention ranges
            // Note: The ranges may have changed after markdown parsing, so we need to recalculate
            for (character, formatter) in viewModel.textFormatterMap {
                let regex = formatter.getRegex()
                let processedString = MessageUtils.processMessageForTextFormatter(attributedString, regex: regex) { regexText in
                    return formatter.prepareMessageString(baseMessage: message, regexString: regexText, formattingType: .COMPOSER)
                }
                selectedFormatters[character] = processedString.1
                attributedString = NSMutableAttributedString(attributedString: processedString.0)
            }

            // If the message is entirely a code block, activate code block mode
            if isEntirelyCodeBlock {
                RichTextFormatterManager.shared.isInCodeBlockMode = true
                codeBlockBackgroundView.isHidden = false
                codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border

                // Remove any individual background colors from the attributed string
                // The codeBlockBackgroundView provides the background
                let fullRange = NSRange(location: 0, length: attributedString.length)
                attributedString.removeAttribute(.backgroundColor, range: fullRange)
                attributedString.addAttribute(RichTextFormatterManager.isCodeBlockKey, value: true, range: fullRange)

                // Set typing attributes for code block mode (NO background - codeBlockBackgroundView handles it)
                let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
                textView.typingAttributes = [
                    .font: monoFont,
                    .foregroundColor: CometChatTheme.neutralColor900,
                    RichTextFormatterManager.isCodeBlockKey: true
                ]

                // Disable incompatible toolbar buttons (all except codeBlock)
                let formatsToDisable: Set<FormatType> = [.bold, .italic, .underline, .strikethrough, .code, .numberedList, .bulletList, .blockquote, .link]
                richTextToolbar.disableButtons(for: formatsToDisable)

                // Set code block as active in toolbar
                richTextToolbar.setActiveFormats([.codeBlock])
            }
        } else {
            // No markdown formatting, use plain text
            attributedString = NSMutableAttributedString(string: text, attributes: [
                .font: style.textFieldFont,
                .foregroundColor: style.textFieldColor
            ])

            // Processing Message for textFormatters (mentions, etc.)
            for (character, formatter) in viewModel.textFormatterMap {
                let regex = formatter.getRegex()
                let processedString = MessageUtils.processMessageForTextFormatter(attributedString, regex: regex) { regexText in
                    return formatter.prepareMessageString(baseMessage: message, regexString: regexText, formattingType: .COMPOSER)
                }
                selectedFormatters[character] = processedString.1
                attributedString = NSMutableAttributedString(attributedString: processedString.0)
            }
        }

        // Blockquote markers ("> " at line start) are left to the caller by
        // parseMarkdown: strip them and mark those lines so the composer shows the
        // quote bar instead of raw ">" characters — same look as while composing.
        var editBlockquoteRange: NSRange?
        if !isEntirelyCodeBlock {
            editBlockquoteRange = applyBlockquotePrefill(to: attributedString)
        }

        textView.attributedText = attributedString
        updateSendButtonState()

        if let quoteRange = editBlockquoteRange, quoteRange.length > 0 {
            blockquoteTextRange = quoteRange
            // Position the bar after the text view has laid out the new content.
            DispatchQueue.main.async { [weak self] in
                self?.updateBlockquoteBarFrameForRange()
                self?.blockquoteBarView.isHidden = false
            }
        }

        // Check if the message being edited already has 10 or more mentions
        // If so, show the limit view to prevent adding more
        if getUniqueSelectedTextFormatterCount() >= 10 {
            addLimitView()
        }
    }

    /// Strips blockquote markers ("> " / ">") from line starts and applies the
    /// composer's blockquote attributes (isBlockquoteKey + quote text color) to those
    /// lines, so an edited quote renders with the visual quote bar instead of raw
    /// markdown. Lines inside code blocks are left untouched. Returns the merged range
    /// of quoted content (for the bar), or nil when the text has no quotes.
    private func applyBlockquotePrefill(to attributedString: NSMutableAttributedString) -> NSRange? {
        let blockquoteTextColor: UIColor
        if #available(iOS 13.0, *) {
            blockquoteTextColor = UIColor { trait in
                trait.userInterfaceStyle == .dark ? .lightGray : .darkGray
            }
        } else {
            blockquoteTextColor = .darkGray
        }

        var quotedRanges: [NSRange] = []
        var location = 0
        while location < attributedString.length {
            let nsText = attributedString.string as NSString
            let lineRange = nsText.lineRange(for: NSRange(location: location, length: 0))
            let line = nsText.substring(with: lineRange)

            // Never touch code-block content — a ">" there is literal code.
            let isCodeLine = attributedString.attribute(RichTextFormatterManager.isCodeBlockKey,
                                                        at: lineRange.location,
                                                        effectiveRange: nil) as? Bool == true

            if !isCodeLine, line.hasPrefix(">") {
                let markerLength = line.hasPrefix("> ") ? 2 : 1
                attributedString.deleteCharacters(in: NSRange(location: lineRange.location,
                                                              length: markerLength))
                let contentRange = NSRange(location: lineRange.location,
                                           length: max(0, lineRange.length - markerLength))
                if contentRange.length > 0 {
                    attributedString.addAttribute(RichTextFormatterManager.isBlockquoteKey,
                                                  value: true, range: contentRange)
                    attributedString.addAttribute(.foregroundColor,
                                                  value: blockquoteTextColor, range: contentRange)
                }
                quotedRanges.append(contentRange)
                location = contentRange.location + max(contentRange.length, 1)
            } else {
                location = lineRange.location + max(lineRange.length, 1)
            }
        }

        guard let first = quotedRanges.first, let last = quotedRanges.last else { return nil }
        return NSRange(location: first.location,
                       length: (last.location + last.length) - first.location)
    }
    
    @discardableResult
    public func reply(message: BaseMessage) -> Self {
        viewModel.message = message
        viewModel.quotedMessage = message
        viewModel.quotedMessageId = message.id
        composerState = .reply
        showReplyPreview(for: message)
        return self
    }
    
    @discardableResult
    public func preview(message: BaseMessage, mode: ComposerState) -> Self {
        switch mode {
        case .edit: return edit(message: message)
        case .reply: return reply(message: message)
        case .draft: return self
        }
    }
}
