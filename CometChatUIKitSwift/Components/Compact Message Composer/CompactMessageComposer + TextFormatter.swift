//
//  CompactMessageComposer + TextFormatter.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 29/01/26.
//

import UIKit
import Foundation
import CometChatSDK

extension CometChatCompactMessageComposer: GrowingTextViewDelegate {
    
    // MARK: - GrowingTextViewDelegate
    
    public func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        // Invalidate intrinsic content size so the composer resizes
        invalidateIntrinsicContentSize()
        setNeedsLayout()
        
        // Animate the height change for smooth expansion
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layoutIfNeeded()
            self?.controller?.view.layoutIfNeeded()
        }
        
        // Update code block background frame after height change
        if RichTextFormatterManager.shared.isInCodeBlockMode {
            // Check if we have a codeBlockStartPosition (code block after blockquote or other content)
            if let codeBlockStart = codeBlockStartPosition {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    guard let self = self else { return }
                    let textLength = self.textView.text?.count ?? 0
                    let text = self.textView.text ?? ""
                    
                    // Use the stored codeBlockStartPosition as the minimum start position
                    // This ensures code block never starts before where it was originally set
                    var actualCodeBlockStart = codeBlockStart
                    
                    // If there's blockquote content, ensure code block starts AFTER it
                    if let blockquoteRange = self.blockquoteTextRange, blockquoteRange.length > 0 {
                        // Code block must start after blockquote content
                        let blockquoteEnd = blockquoteRange.location + blockquoteRange.length
                        actualCodeBlockStart = max(actualCodeBlockStart, blockquoteEnd)
                        
                        // Skip any newlines/whitespace after blockquote
                        while actualCodeBlockStart < textLength {
                            let index = text.index(text.startIndex, offsetBy: actualCodeBlockStart)
                            let char = text[index]
                            if char == "\n" || char == " " || char == "\t" {
                                actualCodeBlockStart += 1
                            } else {
                                break
                            }
                        }
                    }
                    
                    // IMPORTANT: Never let actualCodeBlockStart be less than the original codeBlockStart
                    // This prevents the code block from expanding backwards to cover previous content
                    actualCodeBlockStart = max(actualCodeBlockStart, codeBlockStart)
                    
                    if textLength > actualCodeBlockStart {
                        // Show background for code block content only (after blockquote and newlines)
                        let codeBlockContentRange = NSRange(location: actualCodeBlockStart, length: textLength - actualCodeBlockStart)
                        self.updateCodeBlockBackgroundFrameForRangeDirect(codeBlockContentRange)
                        self.codeBlockBackgroundView.isHidden = false
                        self.codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                        self.updateCodeBlockLeftBorderFrame()
                    } else {
                        // No code block content yet - show background at cursor position with minimum height
                        if let startPos = self.textView.position(from: self.textView.beginningOfDocument, offset: actualCodeBlockStart) {
                            let caretRect = self.textView.caretRect(for: startPos)
                            if !caretRect.isNull && !caretRect.isInfinite && caretRect.height > 0 {
                                NSLayoutConstraint.deactivate(self.codeBlockBackgroundConstraints)
                                self.codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = true
                                
                                // Use minimum height if set, otherwise use caret height
                                // Don't center - extend downward only to avoid overlapping text above
                                let bgHeight = self.codeBlockMinimumHeight > 0 ? max(self.codeBlockMinimumHeight, caretRect.height) : caretRect.height
                                
                                let bgFrame = CGRect(
                                    x: 0,
                                    y: caretRect.origin.y - self.textView.contentOffset.y,
                                    width: self.textViewContainer.bounds.width,
                                    height: bgHeight
                                )
                                self.codeBlockBackgroundView.frame = bgFrame
                                self.codeBlockBackgroundView.isHidden = false
                                self.codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                                self.updateCodeBlockLeftBorderFrame()
                            }
                        }
                    }
                }
            } else if let blockquoteRange = blockquoteTextRange, blockquoteRange.length > 0 {
                // No codeBlockStartPosition but there's blockquote content - calculate code block start
                // This handles the case where code block was activated after blockquote but codeBlockStartPosition wasn't set
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    guard let self = self else { return }
                    let textLength = self.textView.text?.count ?? 0
                    let text = self.textView.text ?? ""
                    
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
                    self.codeBlockStartPosition = codeBlockStart
                    
                    // Ensure code block start is AFTER blockquote end to prevent overlap
                    let safeCodeBlockStart = max(codeBlockStart, blockquoteRange.location + blockquoteRange.length)
                    
                    if textLength > safeCodeBlockStart {
                        // Show background for code block content only (after blockquote)
                        let codeBlockContentRange = NSRange(location: safeCodeBlockStart, length: textLength - safeCodeBlockStart)
                        self.updateCodeBlockBackgroundFrameForRangeDirect(codeBlockContentRange)
                        self.codeBlockBackgroundView.isHidden = false
                        self.codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                        self.updateCodeBlockLeftBorderFrame()
                    } else {
                        // No code block content yet - show background at cursor position with minimum height
                        if let startPos = self.textView.position(from: self.textView.beginningOfDocument, offset: safeCodeBlockStart) {
                            let caretRect = self.textView.caretRect(for: startPos)
                            if !caretRect.isNull && !caretRect.isInfinite && caretRect.height > 0 {
                                NSLayoutConstraint.deactivate(self.codeBlockBackgroundConstraints)
                                self.codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = true
                                
                                // Use minimum height if set, otherwise use caret height
                                // Don't center - extend downward only to avoid overlapping text above
                                let bgHeight = self.codeBlockMinimumHeight > 0 ? max(self.codeBlockMinimumHeight, caretRect.height) : caretRect.height
                                
                                let bgFrame = CGRect(
                                    x: 0,
                                    y: caretRect.origin.y - self.textView.contentOffset.y,
                                    width: self.textViewContainer.bounds.width,
                                    height: bgHeight
                                )
                                self.codeBlockBackgroundView.frame = bgFrame
                                self.codeBlockBackgroundView.isHidden = false
                                self.codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                                self.updateCodeBlockLeftBorderFrame()
                            }
                        }
                    }
                }
            } else {
                // No codeBlockStartPosition and no blockquote content - update for full text
                // Force layout update first for accurate frame calculation
                textView.setNeedsLayout()
                textView.layoutIfNeeded()
                textViewContainer.setNeedsLayout()
                textViewContainer.layoutIfNeeded()
                
                // Update immediately first for responsive feel
                updateCodeBlockBackgroundForFullText()
                // Then update again after animation completes to ensure accuracy
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.updateCodeBlockBackgroundForFullText()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                    self?.updateCodeBlockBackgroundForFullText()
                }
            }
        } else if codeBlockTextRange != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.updateCodeBlockBackgroundFrame()
            }
        }
        
        // Update blockquote bar frame after height change
        if blockquoteTextRange != nil && !RichTextFormatterManager.shared.isInBlockquoteMode {
            // Exited blockquote mode - update bar for the fixed range
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                self?.updateBlockquoteBarFrame()
            }
        } else if blockquoteStartPosition != nil && RichTextFormatterManager.shared.isInBlockquoteMode {
            // In blockquote mode with existing content before - update bar as text grows
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self else { return }
                let textLength = self.textView.text?.count ?? 0
                
                // Use the blockquoteStartPosition that was set when entering blockquote mode
                // Do NOT recalculate it based on code block range - that would override the user's intent
                let blockquoteStart = self.blockquoteStartPosition!
                
                
                if textLength > blockquoteStart {
                    // Show bar for blockquote content only (after previous content)
                    let blockquoteContentRange = NSRange(location: blockquoteStart, length: textLength - blockquoteStart)
                    self.updateBlockquoteBarFrameForRangeDirect(blockquoteContentRange)
                    self.blockquoteBarView.isHidden = false
                } else if textLength >= blockquoteStart {
                    // Cursor is at or near blockquote start - show bar at cursor height
                    if let selectedRange = self.textView.selectedTextRange {
                        let caretRect = self.textView.caretRect(for: selectedRange.end)
                        if !caretRect.isNull && !caretRect.isInfinite && caretRect.height > 0 {
                            NSLayoutConstraint.deactivate(self.blockquoteBarConstraints)
                            self.blockquoteBarView.translatesAutoresizingMaskIntoConstraints = true
                            
                            let barFrame = CGRect(
                                x: -2,
                                y: caretRect.origin.y - self.textView.contentOffset.y,
                                width: 4,
                                height: caretRect.height
                            )
                            self.blockquoteBarView.frame = barFrame
                            self.blockquoteBarView.isHidden = false
                        }
                    }
                }
            }
        } else if RichTextFormatterManager.shared.isInBlockquoteMode && blockquoteStartPosition == nil {
            // In blockquote mode without blockquoteStartPosition - blockquote covers all text
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self else { return }
                let textLength = self.textView.text?.count ?? 0
                if textLength > 0 {
                    let blockquoteRange = NSRange(location: 0, length: textLength)
                    self.updateBlockquoteBarFrameForRangeDirect(blockquoteRange)
                    self.blockquoteBarView.isHidden = false
                }
            }
        }
    }
    
    // MARK: - UITextViewDelegate
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // Set typing attributes based on persistent formats (or default if none)
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
        return true
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        // Only handle tap interactions (not long press or other interactions)
        guard interaction == .invokeDefaultAction else {
            return false
        }
        
        // Get the link text and URL
        guard let attributedText = textView.attributedText else {
            return false
        }
        
        let linkText = (attributedText.string as NSString).substring(with: characterRange)
        let urlString = URL.absoluteString
        
        // Show alert with Edit and Remove options
        showLinkOptionsAlert(linkText: linkText, url: urlString, range: characterRange)
        
        // Return false to prevent default link opening behavior
        return false
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // Handle "select all and delete" - when user selects all text and deletes it
        // This ensures the text field is restored to its original state
        let currentTextLength = textView.text?.count ?? 0
        let isDeletingAllText = text.isEmpty && range.location == 0 && range.length == currentTextLength && currentTextLength > 0
        
        if isDeletingAllText {
            // User is deleting all text - reset all formatting state immediately
            // The actual text clearing will happen, then textViewDidChange will be called
            // But we reset state here to ensure clean transition
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
            self.textView.hidePlaceholder = false
            
            // Reset typing attributes
            textView.typingAttributes = [
                .font: style.textFieldFont,
                .foregroundColor: style.textFieldColor
            ]
            
            // Reset toolbar
            richTextToolbar.setActiveFormats([])
            richTextToolbar.enableAllButtons()
            
            // Allow the deletion to proceed
            return true
        }
        
        // Check if user is typing within a code block region and re-enable code block mode
        // This handles the case where user exits code block mode but then moves cursor back into code block area
        if !RichTextFormatterManager.shared.isInCodeBlockMode && !text.isEmpty && text != "\n" {
            if let attributedText = textView.attributedText {
                var shouldReEnableCodeBlock = false
                
                // IMPORTANT: If we have a stored codeBlockTextRange (exited code block), 
                // only re-enable if cursor is WITHIN that range, not after it
                if let storedRange = codeBlockTextRange {
                    // Check if cursor is within the stored code block range
                    let cursorInCodeBlock = range.location >= storedRange.location && 
                                           range.location < storedRange.location + storedRange.length
                    
                    if cursorInCodeBlock {
                        // Check if the character at cursor position has isCodeBlockKey attribute
                        if range.location < attributedText.length {
                            let attributes = attributedText.attributes(at: range.location, effectiveRange: nil)
                            if let isCodeBlock = attributes[RichTextFormatterManager.isCodeBlockKey] as? Bool, isCodeBlock {
                                shouldReEnableCodeBlock = true
                            }
                        }
                    }
                    // If cursor is AFTER the stored range, do NOT re-enable code block mode
                    // This allows user to type normal text after the code block
                } else {
                    // No stored range - check attributes normally (for initial code block creation)
                    // Check if the character at cursor position has isCodeBlockKey attribute
                    if range.location < attributedText.length {
                        let attributes = attributedText.attributes(at: range.location, effectiveRange: nil)
                        if let isCodeBlock = attributes[RichTextFormatterManager.isCodeBlockKey] as? Bool, isCodeBlock {
                            shouldReEnableCodeBlock = true
                        }
                    }
                    
                    // Also check the character before cursor position (for appending at end of code block)
                    // But only if there's no stored range (meaning we haven't exited code block yet)
                    if !shouldReEnableCodeBlock && range.location > 0 {
                        let prevIndex = range.location - 1
                        if prevIndex < attributedText.length {
                            let attributes = attributedText.attributes(at: prevIndex, effectiveRange: nil)
                            if let isCodeBlock = attributes[RichTextFormatterManager.isCodeBlockKey] as? Bool, isCodeBlock {
                                shouldReEnableCodeBlock = true
                            }
                        }
                    }
                }
                
                if shouldReEnableCodeBlock {
                    // Re-enable code block mode
                    RichTextFormatterManager.shared.isInCodeBlockMode = true
                    RichTextFormatterManager.shared.isInBulletListMode = false
                    RichTextFormatterManager.shared.isInNumberedListMode = false
                    RichTextFormatterManager.shared.isInBlockquoteMode = false
                    RichTextFormatterManager.shared.currentListNumber = 1
                    
                    // Update typing attributes for code block
                    let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
                    textView.typingAttributes = [
                        .font: monoFont,
                        .foregroundColor: CometChatTheme.neutralColor900,
                        RichTextFormatterManager.isCodeBlockKey: true
                    ]
                    
                    // Show code block background and update toolbar
                    codeBlockBackgroundView.isHidden = false
                    codeBlockLeftBorderView.isHidden = true
                    
                    // If there's an existing codeBlockTextRange, we're re-entering an existing code block
                    // Update the background frame for that range (it will be expanded as user types)
                    if codeBlockTextRange != nil {
                        updateCodeBlockBackgroundFrame()
                    } else {
                        updateCodeBlockBackgroundForFullText()
                    }
                    updateToolbarActiveFormats()
                    
                }
            }
        }
        
        // Check if user is typing within a blockquote region and re-enable blockquote mode
        // This handles the case where user exits blockquote mode but then moves cursor back into blockquote area
        // Skip if code block mode is active (code block takes precedence)
        if !RichTextFormatterManager.shared.isInBlockquoteMode && !RichTextFormatterManager.shared.isInCodeBlockMode && !text.isEmpty && text != "\n" {
            if let attributedText = textView.attributedText, range.location < attributedText.length {
                // Check if the character at cursor position has isBlockquoteKey attribute
                let attributes = attributedText.attributes(at: range.location, effectiveRange: nil)
                if let isBlockquote = attributes[RichTextFormatterManager.isBlockquoteKey] as? Bool, isBlockquote {
                    // Re-enable blockquote mode
                    RichTextFormatterManager.shared.isInBlockquoteMode = true
                    
                    // Update typing attributes to include blockquote key
                    var typingAttrs: [NSAttributedString.Key: Any] = [
                        .font: style.textFieldFont,
                        .foregroundColor: style.textFieldColor,
                        RichTextFormatterManager.isBlockquoteKey: true
                    ]
                    if !RichTextFormatterManager.shared.persistentFormats.isEmpty {
                        typingAttrs = RichTextFormatterManager.shared.getTypingAttributes(
                            baseFont: style.textFieldFont,
                            baseColor: style.textFieldColor
                        )
                        typingAttrs[RichTextFormatterManager.isBlockquoteKey] = true
                    }
                    textView.typingAttributes = typingAttrs
                    
                    // Show blockquote bar and update toolbar
                    blockquoteBarView.isHidden = false
                    updateToolbarActiveFormats()
                    
                }
            } else if range.location > 0, let attributedText = textView.attributedText {
                // Check the character before cursor position (for appending at end of blockquote)
                let prevIndex = range.location - 1
                if prevIndex < attributedText.length {
                    let attributes = attributedText.attributes(at: prevIndex, effectiveRange: nil)
                    if let isBlockquote = attributes[RichTextFormatterManager.isBlockquoteKey] as? Bool, isBlockquote {
                        // Re-enable blockquote mode
                        RichTextFormatterManager.shared.isInBlockquoteMode = true
                        
                        // Update typing attributes to include blockquote key
                        var typingAttrs: [NSAttributedString.Key: Any] = [
                            .font: style.textFieldFont,
                            .foregroundColor: style.textFieldColor,
                            RichTextFormatterManager.isBlockquoteKey: true
                        ]
                        if !RichTextFormatterManager.shared.persistentFormats.isEmpty {
                            typingAttrs = RichTextFormatterManager.shared.getTypingAttributes(
                                baseFont: style.textFieldFont,
                                baseColor: style.textFieldColor
                            )
                            typingAttrs[RichTextFormatterManager.isBlockquoteKey] = true
                        }
                        textView.typingAttributes = typingAttrs
                        
                        // Show blockquote bar and update toolbar
                        blockquoteBarView.isHidden = false
                        updateToolbarActiveFormats()
                        
                    }
                }
            }
        }
        
        // IMPORTANT: Intercept emoji input BEFORE it's inserted to prevent formatting from being applied
        // This must happen before any other processing
        if !text.isEmpty && text.containsEmoji() {
            // Check if inline code is active - convert emojis to shortcodes in composer
            let hasInlineCode = RichTextFormatterManager.shared.persistentFormats.contains(.code)
            let isInCodeBlockMode = RichTextFormatterManager.shared.isInCodeBlockMode
            
            // Convert emojis to shortcodes for both inline code AND code block modes
            if hasInlineCode || isInCodeBlockMode {
                // Convert emoji to shortcode and insert it with code formatting
                let shortcodeText = text.emojisToShortcodes()
                
                let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
                
                // Get current typing attributes (should have code formatting)
                let currentTypingAttributes = textView.typingAttributes
                
                let shortcodeAttributedString = NSAttributedString(string: shortcodeText, attributes: currentTypingAttributes)
                
                // Replace the range with shortcode
                if range.length > 0 {
                    attributedString.replaceCharacters(in: range, with: shortcodeAttributedString)
                } else {
                    attributedString.insert(shortcodeAttributedString, at: range.location)
                }
                
                textView.attributedText = attributedString
                
                // Move cursor to end of inserted text
                let newCursorPosition = range.location + shortcodeText.count
                if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
                
                // Restore typing attributes for continued code input
                textView.typingAttributes = currentTypingAttributes
                
                // If in code block mode, update the background
                if isInCodeBlockMode {
                    // Force layout update
                    textView.setNeedsLayout()
                    textView.layoutIfNeeded()
                    textViewContainer.setNeedsLayout()
                    textViewContainer.layoutIfNeeded()
                    
                    // Update the code block background
                    if let codeBlockStart = codeBlockStartPosition {
                        let textLength = textView.text?.count ?? 0
                        if textLength > codeBlockStart {
                            let codeBlockRange = NSRange(location: codeBlockStart, length: textLength - codeBlockStart)
                            updateCodeBlockBackgroundFrameForRangeDirect(codeBlockRange)
                        }
                    } else {
                        updateCodeBlockBackgroundForFullText()
                    }
                }
                
                // Notify about text change
                if let currentText = textView.text as NSString? {
                    onTextChangedListener?(currentText as String)
                }
                
                updateSendButtonState()
                
                // Return false since we handled the insertion ourselves
                return false
            }
            
            // Check if blockquote mode is active - allow emojis as-is
            let isInBlockquoteMode = RichTextFormatterManager.shared.isInBlockquoteMode
            
            // Allow emojis in blockquote mode - they stay as emojis
            if isInBlockquoteMode {
                // Let the emoji be inserted normally with current formatting
                return true
            }
            
            // For other formatting modes (bold, italic, etc.), strip formatting from emojis
            let hasActiveFormatting = !RichTextFormatterManager.shared.persistentFormats.isEmpty
            
            if hasActiveFormatting {
                // Manually insert the text, applying default attributes to emojis only
                let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
                
                // Build the replacement attributed string character by character
                let replacementAttributedString = NSMutableAttributedString()
                
                // Get current typing attributes for non-emoji characters
                let currentTypingAttributes = textView.typingAttributes
                
                // Default attributes for emojis - completely unformatted
                let defaultEmojiAttributes: [NSAttributedString.Key: Any] = [
                    .font: style.textFieldFont,
                    .foregroundColor: style.textFieldColor
                ]
                
                for char in text {
                    if char.isEmoji {
                        // Use default attributes for emojis
                        replacementAttributedString.append(NSAttributedString(string: String(char), attributes: defaultEmojiAttributes))
                    } else {
                        // Use current typing attributes for non-emoji characters
                        replacementAttributedString.append(NSAttributedString(string: String(char), attributes: currentTypingAttributes))
                    }
                }
                
                // Replace the range with our custom attributed string
                if range.length > 0 {
                    attributedString.replaceCharacters(in: range, with: replacementAttributedString)
                } else {
                    attributedString.insert(replacementAttributedString, at: range.location)
                }
                
                textView.attributedText = attributedString
                
                // Move cursor to end of inserted text
                let newCursorPosition = range.location + replacementAttributedString.length
                if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
                
                // Notify about text change
                if let currentText = textView.text as NSString? {
                    onTextChangedListener?(currentText as String)
                }
                
                updateSendButtonState()
                
                // Return false since we handled the insertion ourselves
                return false
            }
        }
        
        // Handle Enter key for list continuation
        if text == "\n" {
            // Check if user is pressing Enter within a code block region and re-enable code block mode
            // This handles the case where user exits code block mode but then moves cursor back into code block area
            // BUT: Don't re-enable if the current line is empty (user is trying to exit with double-enter)
            if !RichTextFormatterManager.shared.isInCodeBlockMode {
                if let attributedText = textView.attributedText {
                    var shouldReEnableCodeBlock = false
                    
                    // First, check if the current line is empty (double-enter to exit scenario)
                    let text = attributedText.string
                    let lineInfo = getLineInfo(at: range.location, in: text)
                    let lineText = (text as NSString).substring(with: NSRange(location: lineInfo.start, length: lineInfo.length))
                    let isCurrentLineEmpty = lineText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    
                    // Also check if cursor is at end after a newline (another double-enter scenario)
                    let isAtEndAfterNewline = range.location == text.count && text.hasSuffix("\n")
                    
                    // Only re-enable code block mode if the current line has content
                    // This allows double-enter to exit even after re-entering code block
                    if !isCurrentLineEmpty && !isAtEndAfterNewline {
                        // IMPORTANT: If we have a stored codeBlockTextRange (exited code block),
                        // only re-enable if cursor is WITHIN that range, not after it
                        if let storedRange = codeBlockTextRange {
                            // Check if cursor is within the stored code block range
                            let cursorInCodeBlock = range.location >= storedRange.location && 
                                                   range.location < storedRange.location + storedRange.length
                            
                            if cursorInCodeBlock {
                                // Check if cursor is within code block content
                                if range.location < attributedText.length {
                                    let attributes = attributedText.attributes(at: range.location, effectiveRange: nil)
                                    if let isCodeBlock = attributes[RichTextFormatterManager.isCodeBlockKey] as? Bool, isCodeBlock {
                                        shouldReEnableCodeBlock = true
                                    }
                                }
                            }
                            // If cursor is AFTER the stored range, do NOT re-enable code block mode
                        } else {
                            // No stored range - check attributes normally
                            // Check if cursor is within code block content
                            if range.location < attributedText.length {
                                let attributes = attributedText.attributes(at: range.location, effectiveRange: nil)
                                if let isCodeBlock = attributes[RichTextFormatterManager.isCodeBlockKey] as? Bool, isCodeBlock {
                                    shouldReEnableCodeBlock = true
                                }
                            }
                            
                            // Also check character before cursor (for pressing Enter at end of code block line)
                            if !shouldReEnableCodeBlock && range.location > 0 {
                                let prevIndex = range.location - 1
                                if prevIndex < attributedText.length {
                                    let attributes = attributedText.attributes(at: prevIndex, effectiveRange: nil)
                                    if let isCodeBlock = attributes[RichTextFormatterManager.isCodeBlockKey] as? Bool, isCodeBlock {
                                        shouldReEnableCodeBlock = true
                                    }
                                }
                            }
                        }
                    }
                    
                    if shouldReEnableCodeBlock {
                        // Re-enable code block mode
                        RichTextFormatterManager.shared.isInCodeBlockMode = true
                        RichTextFormatterManager.shared.isInBulletListMode = false
                        RichTextFormatterManager.shared.isInNumberedListMode = false
                        RichTextFormatterManager.shared.isInBlockquoteMode = false
                        RichTextFormatterManager.shared.currentListNumber = 1
                        
                        // Show code block background and update toolbar
                        codeBlockBackgroundView.isHidden = false
                        codeBlockLeftBorderView.isHidden = true
                        
                        // If there's an existing codeBlockTextRange, we're re-entering an existing code block
                        if codeBlockTextRange != nil {
                            updateCodeBlockBackgroundFrame()
                        } else {
                            updateCodeBlockBackgroundForFullText()
                        }
                        updateToolbarActiveFormats()
                        
                        // Set typing attributes for code block mode
                        let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
                        textView.typingAttributes = [
                            .font: monoFont,
                            .foregroundColor: CometChatTheme.neutralColor900,
                            RichTextFormatterManager.isCodeBlockKey: true
                        ]
                        
                    }
                }
            }
            
            // Check if user is pressing Enter within a blockquote region and re-enable blockquote mode
            // This handles the case where user exits blockquote mode but then moves cursor back into blockquote area
            if !RichTextFormatterManager.shared.isInBlockquoteMode && !RichTextFormatterManager.shared.isInCodeBlockMode {
                if let attributedText = textView.attributedText {
                    var shouldReEnableBlockquote = false
                    
                    // Check if cursor is within blockquote content
                    if range.location < attributedText.length {
                        let attributes = attributedText.attributes(at: range.location, effectiveRange: nil)
                        if let isBlockquote = attributes[RichTextFormatterManager.isBlockquoteKey] as? Bool, isBlockquote {
                            shouldReEnableBlockquote = true
                        }
                    }
                    
                    // Also check character before cursor (for pressing Enter at end of blockquote line)
                    if !shouldReEnableBlockquote && range.location > 0 {
                        let prevIndex = range.location - 1
                        if prevIndex < attributedText.length {
                            let attributes = attributedText.attributes(at: prevIndex, effectiveRange: nil)
                            if let isBlockquote = attributes[RichTextFormatterManager.isBlockquoteKey] as? Bool, isBlockquote {
                                shouldReEnableBlockquote = true
                            }
                        }
                    }
                    
                    if shouldReEnableBlockquote {
                        // Re-enable blockquote mode
                        RichTextFormatterManager.shared.isInBlockquoteMode = true
                        
                        // Show blockquote bar and update toolbar
                        blockquoteBarView.isHidden = false
                        updateToolbarActiveFormats()
                        
                    }
                }
            }
            
            let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
            
            
            if let result = RichTextFormatterManager.shared.handleNewLine(
                at: range.location,
                in: attributedString,
                baseFont: style.textFieldFont
            ) {
                textView.attributedText = result.0
                
                // Set cursor position
                if let newPosition = textView.position(from: textView.beginningOfDocument, offset: result.1) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
                
                // Check if we exited code block mode (double-enter)
                if result.2 == "EXIT_CODE_BLOCK" {
                    // Reset typing attributes to normal with minimal paragraph spacing
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.paragraphSpacingBefore = 4  // Minimal spacing after code block
                    
                    textView.typingAttributes = [
                        .font: style.textFieldFont,
                        .foregroundColor: style.textFieldColor,
                        .paragraphStyle: paragraphStyle
                    ]
                    
                    // Calculate the code block text range
                    // The text now has the code block content followed by newlines for spacing
                    // We need to find where the actual code block content ends
                    // Strip ALL trailing newlines - they don't need to be part of the visual code block
                    // The code block should only cover the actual text content
                    let text = textView.text ?? ""
                    var codeBlockEndPosition = text.count
                    
                    // Strip ALL trailing newlines from the code block range
                    // This ensures the code block background only covers actual text content
                    while codeBlockEndPosition > 0 {
                        let checkIndex = codeBlockEndPosition - 1
                        let charIndex = text.index(text.startIndex, offsetBy: checkIndex)
                        if text[charIndex] == "\n" {
                            codeBlockEndPosition -= 1
                        } else {
                            break
                        }
                    }
                    
                    // Determine the code block start position
                    // Priority: codeBlockStartPosition > blockquoteTextRange end > 0
                    var codeBlockStart = 0
                    
                    if let startPos = codeBlockStartPosition {
                        // Use the stored start position (set when entering code block mode)
                        codeBlockStart = startPos
                    } else if let blockquoteRange = blockquoteTextRange, blockquoteRange.length > 0 {
                        // Code block starts after blockquote content
                        codeBlockStart = blockquoteRange.location + blockquoteRange.length
                        
                        // Skip any newlines/whitespace to find where actual code block content starts
                        while codeBlockStart < codeBlockEndPosition {
                            let index = text.index(text.startIndex, offsetBy: codeBlockStart)
                            let char = text[index]
                            if char == "\n" || char == " " || char == "\t" {
                                codeBlockStart += 1
                            } else {
                                break
                            }
                        }
                    }
                    // else: codeBlockStart stays at 0 (code block from the beginning)
                    
                    
                    // Set flag to prevent background from being re-expanded during exit
                    isExitingCodeBlock = true
                    
                    // Reset minimum height BEFORE updating the background frame
                    codeBlockMinimumHeight = 0
                    
                    // Reset codeBlockStartPosition since we're exiting code block mode
                    codeBlockStartPosition = nil
                    
                    // Reset text container inset to default
                    centerTextInCodeBlock()
                    
                    if codeBlockEndPosition > codeBlockStart {
                        let codeBlockRange = NSRange(location: codeBlockStart, length: codeBlockEndPosition - codeBlockStart)
                        
                        // IMPORTANT: First ensure isCodeBlockKey attribute is applied to code block content
                        // and REMOVED from text after the code block
                        if let attributedText = textView.attributedText {
                            let safeRange = NSRange(
                                location: codeBlockRange.location,
                                length: min(codeBlockRange.length, attributedText.length - codeBlockRange.location)
                            )
                            if safeRange.length > 0 {
                                let mutableText = NSMutableAttributedString(attributedString: attributedText)
                                mutableText.addAttribute(RichTextFormatterManager.isCodeBlockKey, value: true, range: safeRange)
                                
                                // Remove isCodeBlockKey from text AFTER the code block (the newlines)
                                if safeRange.location + safeRange.length < mutableText.length {
                                    let afterRange = NSRange(
                                        location: safeRange.location + safeRange.length,
                                        length: mutableText.length - (safeRange.location + safeRange.length)
                                    )
                                    mutableText.removeAttribute(RichTextFormatterManager.isCodeBlockKey, range: afterRange)
                                }
                                
                                // Update text SYNCHRONOUSLY - no async delays
                                isSettingCursorProgrammatically = true
                                let selectedRange = textView.selectedRange
                                textView.attributedText = mutableText
                                textView.selectedRange = selectedRange
                                textView.layoutIfNeeded()
                                isSettingCursorProgrammatically = false
                            }
                        }
                        
                        // Now update the background frame IMMEDIATELY
                        updateCodeBlockBackgroundForRange(codeBlockRange)
                        codeBlockBackgroundView.isHidden = false
                    } else {
                        codeBlockBackgroundView.isHidden = true
                        codeBlockLeftBorderView.isHidden = true
                        codeBlockTextRange = nil
                    }
                    
                    // Clear the exit flag
                    isExitingCodeBlock = false
                    
                    // Enable all toolbar buttons when exiting code block mode
                    richTextToolbar.enableAllButtons()
                    
                    // Update toolbar to reflect code block is no longer active
                    updateToolbarActiveFormats()
                    
                    // Animate mic button visibility (show when exiting code block)
                    updateMicrophoneButtonVisibility()
                }
                // Check if we exited blockquote mode (double-enter)
                else if result.2 == "EXIT_BLOCKQUOTE" {
                    // Reset typing attributes to normal - preserve persistent formats if any
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
                    
                    // Calculate the blockquote text range
                    // result.1 is cursor position after the newline we added
                    // We need to find where the actual blockquote content ends (before the empty line)
                    let text = textView.text ?? ""
                    let cursorAfterNewline = result.1
                    
                    // Find the end of actual blockquote content by going back past the empty line
                    // The pattern is: "content\n\n" where the second \n was just added
                    // So we need to find the position before the first \n of the empty line
                    var blockquoteEndPosition = cursorAfterNewline - 1 // Position of the newline we just added
                    
                    // Go back to find where the empty line started (skip the newline that created the empty line)
                    if blockquoteEndPosition > 0 {
                        // Check if there's a newline before (the one that created the empty line)
                        let charBeforeIndex = text.index(text.startIndex, offsetBy: blockquoteEndPosition - 1, limitedBy: text.endIndex)
                        if let idx = charBeforeIndex, text[idx] == "\n" {
                            blockquoteEndPosition -= 1 // Skip the newline that created the empty line
                        }
                    }
                    
                    // Determine blockquote start position
                    let blockquoteStart: Int
                    if let startPos = blockquoteStartPosition {
                        blockquoteStart = startPos
                    } else {
                        blockquoteStart = 0
                    }
                    
                    if blockquoteEndPosition > blockquoteStart {
                        // There's blockquote content - keep the bar visible for it
                        let blockquoteRange = NSRange(location: blockquoteStart, length: blockquoteEndPosition - blockquoteStart)
                        blockquoteTextRange = blockquoteRange
                        updateBlockquoteBarForRange(blockquoteRange)
                        blockquoteBarView.isHidden = false
                        
                        // Ensure isBlockquoteKey attribute is applied to blockquote content only (not the trailing newlines)
                        if let attributedText = textView.attributedText, blockquoteRange.length > 0 {
                            let mutableText = NSMutableAttributedString(attributedString: attributedText)
                            
                            // First, remove isBlockquoteKey from everything after the blockquote content
                            let afterBlockquoteStart = blockquoteRange.location + blockquoteRange.length
                            let afterBlockquoteLength = mutableText.length - afterBlockquoteStart
                            if afterBlockquoteLength > 0 {
                                let afterBlockquoteRange = NSRange(location: afterBlockquoteStart, length: afterBlockquoteLength)
                                mutableText.removeAttribute(RichTextFormatterManager.isBlockquoteKey, range: afterBlockquoteRange)
                            }
                            
                            // Apply isBlockquoteKey to blockquote content
                            mutableText.addAttribute(RichTextFormatterManager.isBlockquoteKey, value: true, range: blockquoteRange)
                            
                            isSettingCursorProgrammatically = true
                            let selectedRange = textView.selectedRange
                            textView.attributedText = mutableText
                            textView.selectedRange = selectedRange
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                                self?.isSettingCursorProgrammatically = false
                            }
                        }
                    } else {
                        // No blockquote content - hide the bar
                        blockquoteBarView.isHidden = true
                        blockquoteTextRange = nil
                        resetBlockquoteBarToFullMode()
                    }
                    
                    // Reset blockquoteStartPosition since we're exiting blockquote mode
                    blockquoteStartPosition = nil
                    
                    // Enable all toolbar buttons
                    richTextToolbar.enableAllButtons()
                    
                    // Update toolbar to reflect blockquote is no longer active
                    updateToolbarActiveFormats()
                }
                // Set typing attributes based on current mode
                else if RichTextFormatterManager.shared.isInBlockquoteMode {
                    // In blockquote mode, preserve persistent formats (bold, italic, etc.)
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
                    
                    // IMPORTANT: Update blockquote bar immediately after newline
                    // Force layout update first for accurate frame calculation
                    textView.setNeedsLayout()
                    textView.layoutIfNeeded()
                    textViewContainer.setNeedsLayout()
                    textViewContainer.layoutIfNeeded()
                    
                    // Update the blockquote bar to extend to the new line
                    let textLength = textView.text?.count ?? 0
                    if let startPos = blockquoteStartPosition {
                        // Blockquote starts from a specific position
                        if textLength > startPos {
                            let blockquoteRange = NSRange(location: startPos, length: textLength - startPos)
                            updateBlockquoteBarFrameForRangeDirect(blockquoteRange)
                            blockquoteBarView.isHidden = false
                        }
                    } else if textLength > 0 {
                        // No start position - blockquote covers all text
                        let blockquoteRange = NSRange(location: 0, length: textLength)
                        updateBlockquoteBarFrameForRangeDirect(blockquoteRange)
                        blockquoteBarView.isHidden = false
                    } else {
                        // Empty text - use full height
                        blockquoteBarView.translatesAutoresizingMaskIntoConstraints = false
                        NSLayoutConstraint.activate(blockquoteBarConstraints)
                        blockquoteBarView.isHidden = false
                    }
                    
                    // Also update after a short delay to catch any layout changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                        guard let self = self else { return }
                        let textLen = self.textView.text?.count ?? 0
                        if let startPos = self.blockquoteStartPosition {
                            if textLen > startPos {
                                let blockquoteRange = NSRange(location: startPos, length: textLen - startPos)
                                self.updateBlockquoteBarFrameForRangeDirect(blockquoteRange)
                            }
                        } else if textLen > 0 {
                            let blockquoteRange = NSRange(location: 0, length: textLen)
                            self.updateBlockquoteBarFrameForRangeDirect(blockquoteRange)
                        }
                    }
                    
                    // Additional delayed update for layout settling
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        guard let self = self else { return }
                        let textLen = self.textView.text?.count ?? 0
                        if let startPos = self.blockquoteStartPosition {
                            if textLen > startPos {
                                let blockquoteRange = NSRange(location: startPos, length: textLen - startPos)
                                self.updateBlockquoteBarFrameForRangeDirect(blockquoteRange)
                            }
                        } else if textLen > 0 {
                            let blockquoteRange = NSRange(location: 0, length: textLen)
                            self.updateBlockquoteBarFrameForRangeDirect(blockquoteRange)
                        }
                    }
                } else if RichTextFormatterManager.shared.isInCodeBlockMode {
                    let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
                    // IMPORTANT: Do NOT set backgroundColor - the codeBlockBackgroundView provides the background
                    textView.typingAttributes = [
                        .font: monoFont,
                        .foregroundColor: CometChatTheme.neutralColor900
                    ]
                    
                    // Force layout update before calculating the new background frame
                    textView.setNeedsLayout()
                    textView.layoutIfNeeded()
                    textViewContainer.setNeedsLayout()
                    textViewContainer.layoutIfNeeded()
                    
                    // Update the code block background to wrap around the new text immediately
                    updateCodeBlockBackgroundForFullText()
                    
                    // Also update after a short delay to catch any layout changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                        self?.updateCodeBlockBackgroundForFullText()
                    }
                }
                
                updateSendButtonState()
                return false // We handled the newline ourselves
            }
        }
        
        // Handle pasting text while in code block mode - apply code block styling to pasted text
        if RichTextFormatterManager.shared.isInCodeBlockMode && text.count > 0 && text != "\n" {
            let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
            
            let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
            
            // Convert emojis to shortcodes in pasted text (same as typing emojis in code block)
            let textToInsert = text.containsEmoji() ? text : text
            
            // Create attributed string with code block styling
            let codeAttributes: [NSAttributedString.Key: Any] = [
                .font: monoFont,
                .foregroundColor: CometChatTheme.neutralColor900,
                RichTextFormatterManager.isCodeBlockKey: true
            ]
            let formattedText = NSAttributedString(string: textToInsert, attributes: codeAttributes)
            
            // Replace the range with formatted text
            if range.length > 0 {
                attributedString.replaceCharacters(in: range, with: formattedText)
            } else {
                attributedString.insert(formattedText, at: range.location)
            }
            
            textView.attributedText = attributedString
            
            // Move cursor to end of pasted text
            let newCursorPosition = range.location + formattedText.length
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
            
            // Force layout update
            textView.setNeedsLayout()
            textView.layoutIfNeeded()
            textViewContainer.setNeedsLayout()
            textViewContainer.layoutIfNeeded()
            
            // Update the code block background to wrap around the new text
            if let codeBlockStart = codeBlockStartPosition {
                // Code block starts from a specific position
                let textLength = textView.text?.count ?? 0
                if textLength > codeBlockStart {
                    let codeBlockRange = NSRange(location: codeBlockStart, length: textLength - codeBlockStart)
                    updateCodeBlockBackgroundFrameForRangeDirect(codeBlockRange)
                }
            } else {
                // Code block covers all text
                updateCodeBlockBackgroundForFullText()
            }
            
            // Also update after a short delay to catch any layout changes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self else { return }
                if let codeBlockStart = self.codeBlockStartPosition {
                    let textLength = self.textView.text?.count ?? 0
                    if textLength > codeBlockStart {
                        let codeBlockRange = NSRange(location: codeBlockStart, length: textLength - codeBlockStart)
                        self.updateCodeBlockBackgroundFrameForRangeDirect(codeBlockRange)
                    }
                } else {
                    self.updateCodeBlockBackgroundForFullText()
                }
            }
            
            updateSendButtonState()
            onTextChangedListener?(attributedString.string)
            return false // We handled the paste ourselves
        }
        
        // Handle pasting a URL over selected text - treat selected text as link text
        if enableRichTextFormatting && range.length > 0 && text.count > 1 {
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Check if the pasted text is a URL (starts with http:// or https://)
            if trimmedText.hasPrefix("http://") || trimmedText.hasPrefix("https://") {
                // Validate it's a proper URL
                if let _ = URL(string: trimmedText) {
                    let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
                    
                    // Get the selected text to use as link text
                    let selectedText = (attributedString.string as NSString).substring(with: range)
                    
                    // Create link attributes
                    let linkAttributes: [NSAttributedString.Key: Any] = [
                        .font: style.textFieldFont,
                        .foregroundColor: CometChatTheme.primaryColor,
                        .underlineStyle: NSUnderlineStyle.single.rawValue,
                        .link: trimmedText
                    ]
                    
                    // Create attributed string with the selected text as link
                    let linkAttributedString = NSAttributedString(string: selectedText, attributes: linkAttributes)
                    
                    // Replace the selected text with the link-styled version (same text, but with link)
                    attributedString.replaceCharacters(in: range, with: linkAttributedString)
                    
                    textView.attributedText = attributedString
                    
                    // Move cursor to end of link
                    let newCursorPosition = range.location + selectedText.count
                    if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
                        textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                    }
                    
                    updateSendButtonState()
                    onTextChangedListener?(attributedString.string)
                    return false // We handled the paste ourselves
                }
            }
        }
        
        // Handle paste with markdown formatting when enableRichTextFormatting is true
        if enableRichTextFormatting && text.count > 1 && (RichTextFormatterManager.shared.containsMarkdownFormatting(text) || RichTextFormatterManager.shared.containsURLs(text)) {
            let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
            
            // Check if the pasted text is entirely a code block (```...```)
            let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
            let isEntirelyCodeBlock = trimmedText.hasPrefix("```") && trimmedText.hasSuffix("```") && trimmedText.count > 6
            
            if isEntirelyCodeBlock {
                // Extract code content from the code block
                var codeContent = String(trimmedText.dropFirst(3).dropLast(3))
                if codeContent.hasPrefix("\n") {
                    codeContent.removeFirst()
                }
                if codeContent.hasSuffix("\n") {
                    codeContent.removeLast()
                }
                
                // Enter code block mode
                RichTextFormatterManager.shared.isInBulletListMode = false
                RichTextFormatterManager.shared.isInNumberedListMode = false
                RichTextFormatterManager.shared.isInBlockquoteMode = false
                RichTextFormatterManager.shared.currentListNumber = 1
                RichTextFormatterManager.shared.isInCodeBlockMode = true
                
                // Clear any existing codeBlockTextRange from a previous code block
                // This ensures the new code block starts fresh
                codeBlockTextRange = nil
                
                // Store the start position for code block (where the pasted code begins)
                // This is used by EXIT_CODE_BLOCK handler to calculate the correct range
                codeBlockStartPosition = range.location
                
                // Hide blockquote bar if visible
                blockquoteBarView.isHidden = true
                blockquoteStartPosition = nil
                resetBlockquoteBarToFullMode()
                
                let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
                
                // Create attributed string with code block styling
                // IMPORTANT: Do NOT set backgroundColor - the codeBlockBackgroundView provides the background
                let codeAttributes: [NSAttributedString.Key: Any] = [
                    .font: monoFont,
                    .foregroundColor: CometChatTheme.neutralColor900,
                    RichTextFormatterManager.isCodeBlockKey: true
                ]
                let formattedCode = NSAttributedString(string: codeContent, attributes: codeAttributes)
                
                // Replace the range with formatted code
                if range.length > 0 {
                    attributedString.replaceCharacters(in: range, with: formattedCode)
                } else {
                    attributedString.insert(formattedCode, at: range.location)
                }
                
                textView.attributedText = attributedString
                
                // Move cursor to end of pasted text
                let newCursorPosition = range.location + formattedCode.length
                if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
                
                // Force layout update
                textView.setNeedsLayout()
                textView.layoutIfNeeded()
                textViewContainer.setNeedsLayout()
                textViewContainer.layoutIfNeeded()
                
                // Show code block background with frame-based positioning
                codeBlockBackgroundView.isHidden = false
                codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                updateCodeBlockBackgroundForFullText()
                
                // Update after a short delay to catch any layout changes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                    self?.updateCodeBlockBackgroundForFullText()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.updateCodeBlockBackgroundForFullText()
                }
                
                // Set typing attributes for code block mode (NO background - codeBlockBackgroundView handles it)
                textView.typingAttributes = [
                    .font: monoFont,
                    .foregroundColor: CometChatTheme.neutralColor900,
                    RichTextFormatterManager.isCodeBlockKey: true
                ]
                
                // Hide mic button when in code block mode
                updateMicrophoneButtonVisibility()
                
                updateSendButtonState()
                updateToolbarActiveFormats()
                onTextChangedListener?(attributedString.string)
                return false
            }
            
            // Parse the pasted markdown text into formatted attributed string
            // For composer, don't add extra newlines around code blocks
            var formattedText = RichTextFormatterManager.shared.parseMarkdown(
                text,
                baseFont: style.textFieldFont,
                baseColor: style.textFieldColor,
                addNewlinesAroundCodeBlocks: false
            )
            
            // Also apply URL formatting to detect and style plain URLs
            let mutableFormattedText = NSMutableAttributedString(attributedString: formattedText)
            RichTextFormatterManager.shared.applyURLFormatting(
                to: mutableFormattedText,
                baseFont: style.textFieldFont,
                baseColor: style.textFieldColor
            )
            
            // Strip formatting from any emojis in the pasted text
            stripFormattingFromEmojis(in: mutableFormattedText)
            
            formattedText = mutableFormattedText
            
            // Replace the range with formatted text
            if range.length > 0 {
                attributedString.replaceCharacters(in: range, with: formattedText)
            } else {
                attributedString.insert(formattedText, at: range.location)
            }
            
            textView.attributedText = attributedString
            
            // Move cursor to end of pasted text
            let newCursorPosition = range.location + formattedText.length
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
            
            updateSendButtonState()
            onTextChangedListener?(attributedString.string)
            return false // We handled the paste ourselves
        }
        
        if let currentText = textView.text as NSString? {
            let updatedText = currentText.replacingCharacters(in: range, with: text)
            onTextChangedListener?(updatedText)
        }
        if viewModel.textFormatterMap.isEmpty == false {
            return checkTextFormatter(textView: textView as! GrowingTextView, range: range, text: text)
        } else {
            return true
        }
    }
    
    public func textViewDidChangeSelection(_ textView: UITextView) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            // Skip if we're programmatically setting the cursor/selection
            if this.isSettingCursorProgrammatically {
                return
            }
            
            if this.viewModel.textFormatterMap.isEmpty == false {
                this.onCursorUpdated(growingTextView: textView as! GrowingTextView)
            }
            
            // Sync persistentFormats with text attributes at cursor position
            // This ensures that when user moves cursor to formatted text, the format buttons
            // reflect the text attributes and clicking them will toggle OFF (not ON)
            this.syncPersistentFormatsWithCursorPosition(textView)
            
            // Update toolbar active formats when selection changes
            this.updateToolbarActiveFormats()
            
            // Update code block background when cursor position changes
            // This ensures the background includes the cursor line ONLY when in code block mode
            // Skip if we're in the process of exiting code block
            if this.isExitingCodeBlock {
                // Do nothing - exit handler will update the background
            } else if RichTextFormatterManager.shared.isInCodeBlockMode {
                if this.codeBlockStartPosition != nil || this.blockquoteTextRange != nil {
                    this.updateCodeBlockBackgroundForFullText()
                } else {
                    this.updateCodeBlockBackgroundForFullText()
                }
            } else if this.codeBlockTextRange != nil {
                // NOT in code block mode - use fixed range update (doesn't include cursor)
                this.updateCodeBlockBackgroundFrame()
            }
        }
    }
    
    /// Syncs persistentFormats with the text attributes at the current cursor position
    /// This ensures format buttons correctly toggle OFF when cursor is in formatted text
    private func syncPersistentFormatsWithCursorPosition(_ textView: UITextView) {
        guard let selectedRange = textView.selectedTextRange else { return }
        
        let start = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
        let length = textView.offset(from: selectedRange.start, to: selectedRange.end)
        
        // Only sync when there's no selection (cursor position)
        guard length == 0 else { return }
        
        guard let attributedText = textView.attributedText, attributedText.length > 0 else {
            // No text - clear inline persistent formats
            let inlineFormats: Set<FormatType> = [.bold, .italic, .underline, .strikethrough, .code]
            RichTextFormatterManager.shared.persistentFormats.subtract(inlineFormats)
            return
        }
        
        // Determine which character to check for formatting:
        // - If cursor is not at beginning, check the character BEFORE cursor (inherit from left)
        // - If cursor is at beginning, check the character AFTER cursor (inherit from right)
        let checkLocation: Int
        if start > 0 {
            checkLocation = start - 1
        } else {
            checkLocation = 0
        }
        
        let range = NSRange(location: checkLocation, length: 1)
        
        // Detect formats at cursor position
        let detectedFormats = RichTextFormatterManager.shared.detectActiveFormats(in: attributedText, at: range)
        
        // Sync inline formats (bold, italic, underline, strikethrough, code) with detected formats
        let inlineFormats: Set<FormatType> = [.bold, .italic, .underline, .strikethrough, .code]
        
        // Remove inline formats from persistentFormats that are not in detected formats
        // Add inline formats to persistentFormats that are in detected formats
        for format in inlineFormats {
            if detectedFormats.contains(format) {
                RichTextFormatterManager.shared.persistentFormats.insert(format)
            } else {
                RichTextFormatterManager.shared.persistentFormats.remove(format)
            }
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            //--- START: Managing typing ---//
            if !this.disableTypingEvents && this.viewModel.checkBlockedStatus() != true {
                this.viewModel.startTyping()
                this.typingWorkItem?.cancel()
                this.typingWorkItem = DispatchWorkItem(block: {
                    this.viewModel.endTyping()
                })
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.5 , execute: this.typingWorkItem!)
            }
            //--- END: Managing typing ---//
            
            // Check if text is now empty - if so, clear all formatting state
            let textContent = textView.text ?? ""
            let isEmpty = textContent.isEmpty
            
            if isEmpty {
                // When text is completely empty, ALWAYS reset all formatting state
                // This handles the case where user deletes all text including formatting markers
                RichTextFormatterManager.shared.resetListMode()
                RichTextFormatterManager.shared.resetAllFormats()
                
                // Explicitly clear toolbar to deselect all buttons and enable all
                this.richTextToolbar.setActiveFormats([])
                this.richTextToolbar.enableAllButtons()
                
                // Reset typing attributes to default
                textView.typingAttributes = [
                    .font: this.style.textFieldFont,
                    .foregroundColor: this.style.textFieldColor
                ]
                
                // Hide code block background and blockquote bar
                this.codeBlockBackgroundView.isHidden = true
                this.codeBlockLeftBorderView.isHidden = true
                this.codeBlockPlaceholderLabel.isHidden = true
                this.blockquoteBarView.isHidden = true
                this.blockquoteStartPosition = nil
                this.blockquoteTextRange = nil
                this.codeBlockStartPosition = nil
                this.codeBlockTextRange = nil
                this.codeBlockMinimumHeight = 0  // Reset minimum height
                this.resetBlockquoteBarToFullMode()
                this.resetCodeBlockBackgroundToFullMode()
                this.resetTextViewMinHeight()  // Reset text view minHeight to original value
                this.centerTextInCodeBlock()  // Reset text container inset
                
                // Restore the text view placeholder
                this.textView.hidePlaceholder = false
            }
            
            // Update code block placeholder visibility
            this.updateCodeBlockPlaceholderVisibility()
            
            // Auto-detect list patterns when user types them manually
            // Only check if not already in a list mode and text is not empty
            if !isEmpty && !RichTextFormatterManager.shared.isInBulletListMode && !RichTextFormatterManager.shared.isInNumberedListMode {
                this.detectAndActivateListMode(in: textView)
            }
            
            // Live markdown conversion - detect and convert markdown patterns as user types
            if !isEmpty && this.enableRichTextFormatting {
                this.detectAndConvertLiveMarkdown(in: textView)
            }
            
            // Strip backticks from code block content if present
            // This handles the case where user pastes code that contains backticks
            if RichTextFormatterManager.shared.isInCodeBlockMode && !isEmpty {
                this.stripBackticksFromCodeBlockContent(in: textView)
            }
            
            // Update send button state based on text changes
            this.updateSendButtonState()
            
            // Update active formats in toolbar (only if text is not empty)
            if !isEmpty {
                this.updateToolbarActiveFormats()
            }
            
            // Update code block background frame if we have a tracked range OR if in code block mode
            // Skip if we're in the process of exiting code block
            if this.isExitingCodeBlock {
                // Do nothing - exit handler will update the background
            } else if this.codeBlockTextRange != nil && !RichTextFormatterManager.shared.isInCodeBlockMode {
                // Exited code block mode - update background for the fixed range
                this.updateCodeBlockBackgroundFrame()
            } else if this.codeBlockTextRange != nil && RichTextFormatterManager.shared.isInCodeBlockMode && !isEmpty {
                // Re-entered code block mode with existing range - expand the range to include new content
                // Find the end of code block content (text with isCodeBlockKey attribute)
                if let attributedText = textView.attributedText {
                    var codeBlockEnd = this.codeBlockTextRange!.location + this.codeBlockTextRange!.length
                    let textLength = attributedText.length
                    
                    // Expand to include any new code block content
                    while codeBlockEnd < textLength {
                        let attrs = attributedText.attributes(at: codeBlockEnd, effectiveRange: nil)
                        if let isCodeBlock = attrs[RichTextFormatterManager.isCodeBlockKey] as? Bool, isCodeBlock {
                            codeBlockEnd += 1
                        } else {
                            break
                        }
                    }
                    
                    // Update the stored range
                    this.codeBlockTextRange = NSRange(location: this.codeBlockTextRange!.location, length: codeBlockEnd - this.codeBlockTextRange!.location)
                    
                    // Update the background frame
                    this.updateCodeBlockBackgroundFrame()
                }
            } else if RichTextFormatterManager.shared.isInCodeBlockMode && !isEmpty {
                // In code block mode, update background to wrap around code block text only
                // If there's blockquote content, position background after it
                this.textView.setNeedsLayout()
                this.textView.layoutIfNeeded()
                
                // Check if we have a codeBlockStartPosition (code block after blockquote)
                if let codeBlockStart = this.codeBlockStartPosition {
                    // Code block starts after blockquote content
                    let textLength = this.textView.text?.count ?? 0
                    let text = this.textView.text ?? ""
                    
                    // Recalculate code block start position
                    var actualCodeBlockStart = codeBlockStart
                    
                    // If there's blockquote content, ensure code block starts AFTER it
                    if let blockquoteRange = this.blockquoteTextRange, blockquoteRange.length > 0 {
                        // Code block must start after blockquote content
                        let blockquoteEnd = blockquoteRange.location + blockquoteRange.length
                        actualCodeBlockStart = max(actualCodeBlockStart, blockquoteEnd)
                        
                        // Skip any newlines/whitespace after blockquote
                        while actualCodeBlockStart < textLength {
                            let index = text.index(text.startIndex, offsetBy: actualCodeBlockStart)
                            let char = text[index]
                            if char == "\n" || char == " " || char == "\t" {
                                actualCodeBlockStart += 1
                            } else {
                                break
                            }
                        }
                        this.codeBlockStartPosition = actualCodeBlockStart
                    }
                    
                    if textLength > actualCodeBlockStart {
                        let codeBlockRange = NSRange(location: actualCodeBlockStart, length: textLength - actualCodeBlockStart)
                        // Use direct update without storing the range - so it recalculates each time
                        this.updateCodeBlockBackgroundFrameForRangeDirect(codeBlockRange)
                        this.codeBlockBackgroundView.isHidden = false
                        this.codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                        this.updateCodeBlockLeftBorderFrame()
                    } else {
                        // No code block content yet - show background at cursor position with minimum height
                        if let startPos = this.textView.position(from: this.textView.beginningOfDocument, offset: actualCodeBlockStart) {
                            let caretRect = this.textView.caretRect(for: startPos)
                            if !caretRect.isNull && !caretRect.isInfinite && caretRect.height > 0 {
                                NSLayoutConstraint.deactivate(this.codeBlockBackgroundConstraints)
                                this.codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = true
                                
                                // Use minimum height if set, otherwise use caret height
                                // Don't center - extend downward only to avoid overlapping text above
                                let bgHeight = this.codeBlockMinimumHeight > 0 ? max(this.codeBlockMinimumHeight, caretRect.height) : caretRect.height
                                
                                let bgFrame = CGRect(
                                    x: 0,
                                    y: caretRect.origin.y - this.textView.contentOffset.y,
                                    width: this.textViewContainer.bounds.width,
                                    height: bgHeight
                                )
                                this.codeBlockBackgroundView.frame = bgFrame
                                this.codeBlockBackgroundView.isHidden = false
                                this.codeBlockLeftBorderView.isHidden = true
                            }
                        }
                    }
                } else if let blockquoteRange = this.blockquoteTextRange, blockquoteRange.length > 0 {
                    // There's blockquote content - position code block background after it
                    let textLength = this.textView.text?.count ?? 0
                    let text = this.textView.text ?? ""
                    
                    // Calculate code block start position (after blockquote content + newlines)
                    var codeBlockStart = blockquoteRange.location + blockquoteRange.length
                    
                    // Skip any newlines/whitespace to find where actual code block content starts
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
                    this.codeBlockStartPosition = codeBlockStart
                    
                    // Ensure code block start is AFTER blockquote end to prevent overlap
                    let safeCodeBlockStart = max(codeBlockStart, blockquoteRange.location + blockquoteRange.length)
                    
                    if textLength > safeCodeBlockStart {
                        let codeBlockRange = NSRange(location: safeCodeBlockStart, length: textLength - safeCodeBlockStart)
                        // Use direct update without storing the range - so it recalculates each time
                        this.updateCodeBlockBackgroundFrameForRangeDirect(codeBlockRange)
                        this.codeBlockBackgroundView.isHidden = false
                        this.codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                        this.updateCodeBlockLeftBorderFrame()
                    } else {
                        // No code block content yet - show background at cursor position with minimum height
                        if let startPos = this.textView.position(from: this.textView.beginningOfDocument, offset: safeCodeBlockStart) {
                            let caretRect = this.textView.caretRect(for: startPos)
                            if !caretRect.isNull && !caretRect.isInfinite && caretRect.height > 0 {
                                NSLayoutConstraint.deactivate(this.codeBlockBackgroundConstraints)
                                this.codeBlockBackgroundView.translatesAutoresizingMaskIntoConstraints = true
                                
                                // Use minimum height if set, otherwise use caret height
                                // Don't center - extend downward only to avoid overlapping text above
                                let bgHeight = this.codeBlockMinimumHeight > 0 ? max(this.codeBlockMinimumHeight, caretRect.height) : caretRect.height
                                
                                let bgFrame = CGRect(
                                    x: 0,
                                    y: caretRect.origin.y - this.textView.contentOffset.y,
                                    width: this.textViewContainer.bounds.width,
                                    height: bgHeight
                                )
                                this.codeBlockBackgroundView.frame = bgFrame
                                this.codeBlockBackgroundView.isHidden = false
                                this.codeBlockLeftBorderView.isHidden = true  // Always hidden - no purple border
                                this.updateCodeBlockLeftBorderFrame()
                            }
                        }
                    }
                } else {
                    // No blockquote content - wrap around all text
                    // Force layout update first, then update background
                    this.textView.setNeedsLayout()
                    this.textView.layoutIfNeeded()
                    this.textViewContainer.setNeedsLayout()
                    this.textViewContainer.layoutIfNeeded()
                    this.updateCodeBlockBackgroundForFullText()
                    
                    // Also update after a short delay to catch any pending layout changes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                        self?.updateCodeBlockBackgroundForFullText()
                    }
                }
            }
            
            // Update blockquote bar frame if we have a tracked start position or text range
            if this.blockquoteTextRange != nil && !RichTextFormatterManager.shared.isInBlockquoteMode {
                // Exited blockquote mode - update bar for the fixed range
                this.updateBlockquoteBarFrame()
            } else if this.blockquoteStartPosition != nil && RichTextFormatterManager.shared.isInBlockquoteMode {
                // In blockquote mode with existing content before - update bar as text grows
                let textLength = this.textView.text?.count ?? 0
                
                // Use the blockquoteStartPosition that was set when entering blockquote mode
                // Do NOT recalculate it based on code block range - that would override the user's intent
                let blockquoteStart = this.blockquoteStartPosition!
                
                
                if textLength > blockquoteStart {
                    // There's content after the blockquote start position - show bar for that content only
                    let blockquoteContentRange = NSRange(location: blockquoteStart, length: textLength - blockquoteStart)
                    this.updateBlockquoteBarFrameForRangeDirect(blockquoteContentRange)
                    this.blockquoteBarView.isHidden = false
                } else if textLength == blockquoteStart {
                    // Cursor is at blockquote start position - show bar at cursor height
                    if let startPos = this.textView.position(from: this.textView.beginningOfDocument, offset: blockquoteStart) {
                        let caretRect = this.textView.caretRect(for: startPos)
                        if !caretRect.isNull && !caretRect.isInfinite && caretRect.height > 0 {
                            NSLayoutConstraint.deactivate(this.blockquoteBarConstraints)
                            this.blockquoteBarView.translatesAutoresizingMaskIntoConstraints = true
                            
                            let barFrame = CGRect(
                                x: -2,
                                y: caretRect.origin.y - this.textView.contentOffset.y,
                                width: 4,
                                height: caretRect.height
                            )
                            this.blockquoteBarView.frame = barFrame
                            this.blockquoteBarView.isHidden = false
                        }
                    }
                } else {
                    // blockquoteStart is beyond text length - use cursor position
                    if let selectedRange = this.textView.selectedTextRange {
                        let caretRect = this.textView.caretRect(for: selectedRange.end)
                        if !caretRect.isNull && !caretRect.isInfinite && caretRect.height > 0 {
                            NSLayoutConstraint.deactivate(this.blockquoteBarConstraints)
                            this.blockquoteBarView.translatesAutoresizingMaskIntoConstraints = true
                            
                            let barFrame = CGRect(
                                x: -2,
                                y: caretRect.origin.y - this.textView.contentOffset.y,
                                width: 4,
                                height: caretRect.height
                            )
                            this.blockquoteBarView.frame = barFrame
                            this.blockquoteBarView.isHidden = false
                        }
                    }
                }
            } else if RichTextFormatterManager.shared.isInBlockquoteMode && this.blockquoteStartPosition == nil {
                // In blockquote mode without blockquoteStartPosition - blockquote covers all text
                let textLength = this.textView.text?.count ?? 0
                if textLength > 0 {
                    let blockquoteRange = NSRange(location: 0, length: textLength)
                    this.updateBlockquoteBarFrameForRangeDirect(blockquoteRange)
                    this.blockquoteBarView.isHidden = false
                } else {
                    // Empty text - use auto-layout (full height)
                    this.blockquoteBarView.translatesAutoresizingMaskIntoConstraints = false
                    NSLayoutConstraint.activate(this.blockquoteBarConstraints)
                    this.blockquoteBarView.isHidden = false
                }
            }
            
            // IMPORTANT: Clean up any formatting that was applied to emojis FIRST
            // This must happen before setting typing attributes, so that if an emoji
            // was just typed with formatting, we clear the persistent formatting state
            // before the typing attributes are updated
            this.removeFormattingFromEmojis(in: textView)
            
            // Ensure typing attributes reflect current mode (only if text is not empty)
            if !isEmpty {
                if RichTextFormatterManager.shared.isInCodeBlockMode {
                    let monoFont = UIFont.monospacedSystemFont(ofSize: this.style.textFieldFont.pointSize, weight: .regular)
                    // IMPORTANT: Do NOT set backgroundColor - the codeBlockBackgroundView provides the background
                    // This ensures mentions and other text don't have conflicting backgrounds
                    let codeBlockTypingAttributes: [NSAttributedString.Key: Any] = [
                        .font: monoFont,
                        .foregroundColor: CometChatTheme.neutralColor900,
                        RichTextFormatterManager.isCodeBlockKey: true  // Mark as code block
                    ]
                    textView.typingAttributes = codeBlockTypingAttributes
                    
                    // IMPORTANT: Apply the isCodeBlockKey attribute to ALL code block content
                    // If there's blockquote content before, only apply to content after codeBlockStartPosition
                    // We ALWAYS apply to ensure all characters (including those typed after newlines) have the attribute
                    if let attributedText = textView.attributedText, attributedText.length > 0 {
                        let mutableText = NSMutableAttributedString(attributedString: attributedText)
                        
                        // Determine the range for code block content
                        let codeBlockRange: NSRange
                        if let startPos = this.codeBlockStartPosition, startPos < mutableText.length {
                            // There's blockquote content before - only apply to content from startPos
                            codeBlockRange = NSRange(location: startPos, length: mutableText.length - startPos)
                        } else {
                            // No blockquote content - apply to all text
                            codeBlockRange = NSRange(location: 0, length: mutableText.length)
                        }
                        
                        // ALWAYS apply isCodeBlockKey to the entire code block range
                        // This ensures all characters (including those typed after newlines) have the attribute
                        if codeBlockRange.length > 0 {
                            // First, find any inline code regions (isCodeBlockKey = false) within the code block range
                            // and preserve them - they should NOT be converted to code block
                            var inlineCodeRanges: [NSRange] = []
                            mutableText.enumerateAttribute(RichTextFormatterManager.isCodeBlockKey, in: codeBlockRange, options: []) { value, range, _ in
                                if let isCodeBlock = value as? Bool, isCodeBlock == false {
                                    // This is inline code - preserve it
                                    inlineCodeRanges.append(range)
                                }
                            }
                            
                            // Apply code block attribute to the range
                            mutableText.addAttribute(RichTextFormatterManager.isCodeBlockKey, value: true, range: codeBlockRange)
                            // Remove individual background colors - codeBlockBackgroundView handles the background
                            mutableText.removeAttribute(.backgroundColor, range: codeBlockRange)
                            
                            // Restore inline code attributes (isCodeBlockKey = false)
                            for inlineRange in inlineCodeRanges {
                                mutableText.addAttribute(RichTextFormatterManager.isCodeBlockKey, value: false, range: inlineRange)
                                // Also restore inline code background color
                                mutableText.addAttribute(.backgroundColor, value: CometChatTheme.neutralColor300, range: inlineRange)
                            }
                            
                            // IMPORTANT: Ensure isBlockquoteKey is preserved on blockquote content (before codeBlockStartPosition)
                            if let startPos = this.codeBlockStartPosition, startPos > 0 {
                                // Check if blockquote content exists and preserve its attribute
                                if let blockquoteRange = this.blockquoteTextRange, blockquoteRange.length > 0 {
                                    // Re-apply isBlockquoteKey to blockquote content to ensure it's not lost
                                    let safeBlockquoteRange = NSRange(
                                        location: blockquoteRange.location,
                                        length: min(blockquoteRange.length, mutableText.length - blockquoteRange.location)
                                    )
                                    if safeBlockquoteRange.length > 0 {
                                        mutableText.addAttribute(RichTextFormatterManager.isBlockquoteKey, value: true, range: safeBlockquoteRange)
                                    }
                                }
                            }
                            
                            // Set flag to prevent cursor adjustment during programmatic cursor setting
                            this.isSettingCursorProgrammatically = true
                            
                            // Preserve cursor position
                            let selectedRange = textView.selectedRange
                            textView.attributedText = mutableText
                            textView.selectedRange = selectedRange
                            
                            // Reset flag after a delay to ensure all selection change events have completed
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                this.isSettingCursorProgrammatically = false
                            }
                        }
                    }
                } else if RichTextFormatterManager.shared.isInBlockquoteMode {
                    // In blockquote mode, combine with persistent formats (bold, italic, etc.)
                    if !RichTextFormatterManager.shared.persistentFormats.isEmpty {
                        // Get typing attributes that include persistent formats
                        var typingAttrs = RichTextFormatterManager.shared.getTypingAttributes(
                            baseFont: this.style.textFieldFont,
                            baseColor: this.style.textFieldColor
                        )
                        // Add blockquote marker
                        typingAttrs[RichTextFormatterManager.isBlockquoteKey] = true
                        // Keep the text color as the base color (don't change to secondaryLabel)
                        textView.typingAttributes = typingAttrs
                    } else {
                        // No persistent formats, just use base font and color
                        textView.typingAttributes = [
                            .font: this.style.textFieldFont,
                            .foregroundColor: this.style.textFieldColor,
                            RichTextFormatterManager.isBlockquoteKey: true
                        ]
                    }
                    
                    // IMPORTANT: Apply the isBlockquoteKey attribute to ALL blockquote content
                    // UITextView doesn't preserve custom attributes from typingAttributes,
                    // so we need to apply it manually to the attributed text
                    // We ALWAYS apply to ensure all characters (including those typed after newlines) have the attribute
                    if let attributedText = textView.attributedText, attributedText.length > 0 {
                        let mutableText = NSMutableAttributedString(attributedString: attributedText)
                        
                        // Determine the range for blockquote content
                        let blockquoteRange: NSRange
                        if let startPos = this.blockquoteStartPosition, startPos < mutableText.length {
                            // There's existing content before (code block, list, etc.) - only apply to content from startPos
                            blockquoteRange = NSRange(location: startPos, length: mutableText.length - startPos)
                        } else if let startPos = this.blockquoteStartPosition, startPos >= mutableText.length {
                            // blockquoteStartPosition is at or beyond current text length - no blockquote content yet
                            blockquoteRange = NSRange(location: 0, length: 0)
                        } else {
                            // No existing content - apply to all text
                            blockquoteRange = NSRange(location: 0, length: mutableText.length)
                        }
                        
                        // ALWAYS apply isBlockquoteKey to the entire blockquote range
                        // This ensures all characters (including those typed after newlines) have the attribute
                        if blockquoteRange.length > 0 {
                            mutableText.addAttribute(RichTextFormatterManager.isBlockquoteKey, value: true, range: blockquoteRange)
                            
                            // IMPORTANT: Ensure isCodeBlockKey is preserved on code block content (before blockquoteStartPosition)
                            if let startPos = this.blockquoteStartPosition, startPos > 0 {
                                // Check if code block content exists and preserve its attribute
                                if let codeBlockRange = this.codeBlockTextRange, codeBlockRange.length > 0 {
                                    // Re-apply isCodeBlockKey to code block content to ensure it's not lost
                                    let safeCodeBlockRange = NSRange(
                                        location: codeBlockRange.location,
                                        length: min(codeBlockRange.length, mutableText.length - codeBlockRange.location)
                                    )
                                    if safeCodeBlockRange.length > 0 {
                                        mutableText.addAttribute(RichTextFormatterManager.isCodeBlockKey, value: true, range: safeCodeBlockRange)
                                    }
                                }
                            }
                            
                            // Set flag to prevent cursor adjustment during programmatic cursor setting
                            this.isSettingCursorProgrammatically = true
                            
                            // Preserve cursor position
                            let selectedRange = textView.selectedRange
                            textView.attributedText = mutableText
                            textView.selectedRange = selectedRange
                            
                            // Reset flag after a delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                this.isSettingCursorProgrammatically = false
                            }
                        }
                    }
                } else if !RichTextFormatterManager.shared.persistentFormats.isEmpty {
                    textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
                        baseFont: this.style.textFieldFont,
                        baseColor: this.style.textFieldColor
                    )
                }
            }
        }
    }
    
    /// Detects and converts live markdown patterns as user types
    /// Patterns detected:
    /// - ```text``` -> code block
    /// - **text** -> bold
    /// - *text* or _text_ -> italic
    /// - ~~text~~ -> strikethrough
    /// - <u>text</u> -> underline
    /// - `text` -> inline code
    /// - [text](url) -> link
    private func detectAndConvertLiveMarkdown(in textView: UITextView) {
        guard let text = textView.text, !text.isEmpty else { return }
        guard let attributedText = textView.attributedText else { return }
        
        let cursorPosition = textView.selectedRange.location
        
        // We need to check if the cursor is right after a closing marker
        // This means the user just completed typing a markdown pattern
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        var didConvert = false
        var newCursorPosition = cursorPosition
        
        // Check for code block FIRST: ```text``` (must check before inline code)
        if let result = detectAndConvertCodeBlock(
            in: mutableAttributedString,
            text: text,
            cursorPosition: cursorPosition
        ) {
            didConvert = true
            newCursorPosition = result
        }
        
        // Check for inline code: `text` (but not if it's part of ```)
        // Skip if the text before cursor ends with ``` (incomplete code block)
        let textBeforeCursor = String(text.prefix(cursorPosition))
        let isPartOfTripleBacktick = textBeforeCursor.hasSuffix("```") || 
            (textBeforeCursor.count >= 2 && textBeforeCursor.hasSuffix("``")) ||
            (textBeforeCursor.count >= 4 && String(textBeforeCursor.dropLast(1)).hasSuffix("```"))
        
        if !didConvert && !isPartOfTripleBacktick, let result = detectAndConvertInlineCode(
            in: mutableAttributedString,
            text: mutableAttributedString.string,
            cursorPosition: newCursorPosition
        ) {
            didConvert = true
            newCursorPosition = result
        }
        
        // Check for bold: **text**
        if !didConvert, let result = detectAndConvertPattern(
            in: mutableAttributedString,
            text: mutableAttributedString.string,
            cursorPosition: newCursorPosition,
            openMarker: "**",
            closeMarker: "**",
            applyFormat: { content, range in
                let font: UIFont
                if let descriptor = self.style.textFieldFont.fontDescriptor.withSymbolicTraits(.traitBold) {
                    font = UIFont(descriptor: descriptor, size: self.style.textFieldFont.pointSize)
                } else {
                    font = UIFont.boldSystemFont(ofSize: self.style.textFieldFont.pointSize)
                }
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: self.style.textFieldColor
                ]
                return NSAttributedString(string: content, attributes: attributes)
            }
        ) {
            didConvert = true
            newCursorPosition = result
        }
        
        // Check for italic with underscore: _text_
        if !didConvert, let result = detectAndConvertPattern(
            in: mutableAttributedString,
            text: mutableAttributedString.string,
            cursorPosition: newCursorPosition,
            openMarker: "_",
            closeMarker: "_",
            excludeIfPrecededBy: "_",
            excludeIfFollowedBy: "_",
            applyFormat: { content, range in
                let font: UIFont
                if let descriptor = self.style.textFieldFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
                    font = UIFont(descriptor: descriptor, size: self.style.textFieldFont.pointSize)
                } else {
                    font = UIFont.italicSystemFont(ofSize: self.style.textFieldFont.pointSize)
                }
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: font,
                    .foregroundColor: self.style.textFieldColor
                ]
                return NSAttributedString(string: content, attributes: attributes)
            }
        ) {
            didConvert = true
            newCursorPosition = result
        }
        
        // Check for strikethrough: ~~text~~
        if !didConvert, let result = detectAndConvertPattern(
            in: mutableAttributedString,
            text: mutableAttributedString.string,
            cursorPosition: newCursorPosition,
            openMarker: "~~",
            closeMarker: "~~",
            applyFormat: { content, range in
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: self.style.textFieldFont,
                    .foregroundColor: self.style.textFieldColor,
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
                return NSAttributedString(string: content, attributes: attributes)
            }
        ) {
            didConvert = true
            newCursorPosition = result
        }
        
        // Check for HTML underline: <u>text</u>
        if !didConvert, let result = detectAndConvertPattern(
            in: mutableAttributedString,
            text: mutableAttributedString.string,
            cursorPosition: newCursorPosition,
            openMarker: "<u>",
            closeMarker: "</u>",
            applyFormat: { content, range in
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: self.style.textFieldFont,
                    .foregroundColor: self.style.textFieldColor,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ]
                return NSAttributedString(string: content, attributes: attributes)
            }
        ) {
            didConvert = true
            newCursorPosition = result
        }
        
        // Check for link: [text](url)
        if !didConvert, let result = detectAndConvertLinkPattern(
            in: mutableAttributedString,
            text: mutableAttributedString.string,
            cursorPosition: newCursorPosition
        ) {
            didConvert = true
            newCursorPosition = result
        }
        
        if didConvert {
            isSettingCursorProgrammatically = true
            textView.attributedText = mutableAttributedString
            
            // Set cursor position after the formatted text
            if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
                textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.isSettingCursorProgrammatically = false
            }
            
            // Update toolbar to reflect the new formatting
            updateToolbarActiveFormats()
        }
    }
    
    /// Helper method to detect and convert a markdown pattern
    /// Returns the new cursor position if conversion happened, nil otherwise
    private func detectAndConvertPattern(
        in attributedString: NSMutableAttributedString,
        text: String,
        cursorPosition: Int,
        openMarker: String,
        closeMarker: String,
        excludeIfPrecededBy: String? = nil,
        excludeIfFollowedBy: String? = nil,
        applyFormat: (String, NSRange) -> NSAttributedString
    ) -> Int? {
        // Check if cursor is right after the close marker
        let closeMarkerLength = closeMarker.count
        guard cursorPosition >= closeMarkerLength else { return nil }
        
        let textBeforeCursor = String(text.prefix(cursorPosition))
        
        // Check if text ends with close marker
        guard textBeforeCursor.hasSuffix(closeMarker) else { return nil }
        
        // Check exclusion for close marker (e.g., don't match * if followed by *)
        if let excludeFollowed = excludeIfFollowedBy {
            if cursorPosition < text.count {
                let afterCursor = String(text.dropFirst(cursorPosition).prefix(excludeFollowed.count))
                if afterCursor == excludeFollowed {
                    return nil
                }
            }
        }
        
        // Find the opening marker before the close marker
        let searchRange = String(textBeforeCursor.dropLast(closeMarkerLength))
        
        // For single character markers, we need to find the last occurrence that's not part of a double marker
        var openMarkerIndex: String.Index? = nil
        
        if openMarker.count == 1 {
            // Single character marker - find from the end, skipping double markers
            var searchIndex = searchRange.endIndex
            while searchIndex > searchRange.startIndex {
                searchIndex = searchRange.index(before: searchIndex)
                if searchRange[searchIndex] == Character(openMarker) {
                    // Check if this is part of a double marker
                    let beforeIndex = searchIndex > searchRange.startIndex ? searchRange.index(before: searchIndex) : nil
                    let afterIndex = searchIndex < searchRange.index(before: searchRange.endIndex) ? searchRange.index(after: searchIndex) : nil
                    
                    let precededByMarker = beforeIndex != nil && String(searchRange[beforeIndex!]) == openMarker
                    let followedByMarker = afterIndex != nil && String(searchRange[afterIndex!]) == openMarker
                    
                    // Check exclusion
                    if let excludePreceded = excludeIfPrecededBy, precededByMarker && excludePreceded == openMarker {
                        continue
                    }
                    if let excludeFollowed = excludeIfFollowedBy, followedByMarker && excludeFollowed == openMarker {
                        continue
                    }
                    
                    openMarkerIndex = searchIndex
                    break
                }
            }
        } else {
            // Multi-character marker - find the last occurrence
            if let range = searchRange.range(of: openMarker, options: .backwards) {
                openMarkerIndex = range.lowerBound
            }
        }
        
        guard let foundOpenIndex = openMarkerIndex else { return nil }
        
        // Extract the content between markers
        let contentStartIndex = searchRange.index(foundOpenIndex, offsetBy: openMarker.count)
        let content = String(searchRange[contentStartIndex...])
        
        // Don't convert if content is empty
        guard !content.isEmpty else { return nil }
        
        // Calculate the range to replace (from open marker to end of close marker)
        let openMarkerPosition = searchRange.distance(from: searchRange.startIndex, to: foundOpenIndex)
        let fullPatternLength = openMarker.count + content.count + closeMarker.count
        let replaceRange = NSRange(location: openMarkerPosition, length: fullPatternLength)
        
        // Apply formatting
        let formattedContent = applyFormat(content, replaceRange)
        
        // Replace the pattern with formatted content
        attributedString.replaceCharacters(in: replaceRange, with: formattedContent)
        
        // Return new cursor position (after the formatted content)
        return openMarkerPosition + content.count
    }
    
    /// Helper method to detect and convert code block pattern ```text```
    /// Only activates when the full pattern with closing ``` is typed
    private func detectAndConvertCodeBlock(
        in attributedString: NSMutableAttributedString,
        text: String,
        cursorPosition: Int
    ) -> Int? {
        // Check if cursor is right after closing ```
        guard cursorPosition >= 6 else { return nil } // Minimum: ```x```
        
        let textBeforeCursor = String(text.prefix(cursorPosition))
        
        // Check if text ends with ```
        guard textBeforeCursor.hasSuffix("```") else { return nil }
        
        // Find the opening ``` before the closing ```
        let searchRange = String(textBeforeCursor.dropLast(3))
        
        // Find the last occurrence of ``` in the search range
        guard let openingRange = searchRange.range(of: "```", options: .backwards) else { return nil }
        
        // Extract content between the markers
        let contentStartIndex = openingRange.upperBound
        let content = String(searchRange[contentStartIndex...])
        
        // Don't convert if content is empty
        guard !content.isEmpty else { return nil }
        
        // Calculate the range to replace
        let openMarkerPosition = searchRange.distance(from: searchRange.startIndex, to: openingRange.lowerBound)
        let fullPatternLength = 3 + content.count + 3 // ```content```
        let replaceRange = NSRange(location: openMarkerPosition, length: fullPatternLength)
        
        // Apply code block formatting - NO background color, codeBlockBackgroundView handles it
        let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
        let codeBlockAttributes: [NSAttributedString.Key: Any] = [
            .font: monoFont,
            .foregroundColor: CometChatTheme.neutralColor900,
            RichTextFormatterManager.isCodeBlockKey: true
        ]
        let formattedContent = NSAttributedString(string: content, attributes: codeBlockAttributes)
        
        
        // Replace the pattern with formatted content
        attributedString.replaceCharacters(in: replaceRange, with: formattedContent)
        
        // Verify the attribute was set
        if attributedString.length > openMarkerPosition {
            let checkRange = NSRange(location: openMarkerPosition, length: 1)
            let attrs = attributedString.attributes(at: openMarkerPosition, effectiveRange: nil)
        }
        
        // Enter code block mode and show background
        RichTextFormatterManager.shared.isInCodeBlockMode = true
        RichTextFormatterManager.shared.isInBulletListMode = false
        RichTextFormatterManager.shared.isInNumberedListMode = false
        RichTextFormatterManager.shared.isInBlockquoteMode = false
        RichTextFormatterManager.shared.persistentFormats.removeAll()
        
        // Clear any existing codeBlockTextRange from a previous code block
        // This ensures the new code block starts fresh
        codeBlockTextRange = nil
        
        // Store the start position for code block (where the code block content begins)
        // This is used by EXIT_CODE_BLOCK handler to calculate the correct range
        codeBlockStartPosition = openMarkerPosition
        
        
        // Show code block background view with frame-based positioning
        // This will be updated dynamically as text changes
        updateCodeBlockBackgroundForFullText()
        
        // Set typing attributes for code block mode
        textView.typingAttributes = [
            .font: monoFont,
            .foregroundColor: CometChatTheme.neutralColor900,
            RichTextFormatterManager.isCodeBlockKey: true
        ]
        
        // Return new cursor position (after the formatted content)
        return openMarkerPosition + content.count
    }
    
    /// Helper method to detect and convert inline code pattern `text`
    /// Only matches single backticks, not triple backticks
    private func detectAndConvertInlineCode(
        in attributedString: NSMutableAttributedString,
        text: String,
        cursorPosition: Int
    ) -> Int? {
        // Check if cursor is right after closing `
        guard cursorPosition >= 2 else { return nil } // Minimum: `x`
        
        let textBeforeCursor = String(text.prefix(cursorPosition))
        
        // Check if text ends with single ` (not `` or ```)
        guard textBeforeCursor.hasSuffix("`") else { return nil }
        
        // Make sure it's not ending with `` or ```
        if textBeforeCursor.hasSuffix("``") || textBeforeCursor.hasSuffix("```") {
            return nil
        }
        
        // Search for opening ` in the text before the closing `
        let searchRange = String(textBeforeCursor.dropLast(1))
        
        // Find the opening ` - must be a single ` not part of `` or ```
        var openingIndex: String.Index? = nil
        var idx = searchRange.endIndex
        
        while idx > searchRange.startIndex {
            idx = searchRange.index(before: idx)
            
            if searchRange[idx] == "`" {
                // Check if this ` is part of `` or ```
                let beforeIdx = idx > searchRange.startIndex ? searchRange.index(before: idx) : nil
                let afterIdx = idx < searchRange.index(before: searchRange.endIndex) ? searchRange.index(after: idx) : nil
                
                let precededByBacktick = beforeIdx != nil && searchRange[beforeIdx!] == "`"
                let followedByBacktick = afterIdx != nil && searchRange[afterIdx!] == "`"
                
                // Skip if this backtick is part of `` or ```
                if precededByBacktick || followedByBacktick {
                    continue
                }
                
                openingIndex = idx
                break
            }
        }
        
        guard let foundOpenIndex = openingIndex else { return nil }
        
        // Extract content between the backticks
        let contentStartIndex = searchRange.index(after: foundOpenIndex)
        let content = String(searchRange[contentStartIndex...])
        
        // Don't convert if content is empty
        guard !content.isEmpty else { return nil }
        
        // Calculate the range to replace
        let openMarkerPosition = searchRange.distance(from: searchRange.startIndex, to: foundOpenIndex)
        let fullPatternLength = 1 + content.count + 1 // `content`
        let replaceRange = NSRange(location: openMarkerPosition, length: fullPatternLength)
        
        // Apply inline code formatting
        let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize - 1, weight: .regular)
        let codeAttributes: [NSAttributedString.Key: Any] = [
            .font: monoFont,
            .foregroundColor: CometChatTheme.extendedPrimaryColor700,
            .backgroundColor: CometChatTheme.neutralColor300,
            RichTextFormatterManager.isCodeBlockKey: false
        ]
        let formattedContent = NSAttributedString(string: content, attributes: codeAttributes)
        
        // Replace the pattern with formatted content
        attributedString.replaceCharacters(in: replaceRange, with: formattedContent)
        
        // Return new cursor position (after the formatted content)
        return openMarkerPosition + content.count
    }
    
    /// Helper method to detect and convert link pattern [text](url)
    private func detectAndConvertLinkPattern(
        in attributedString: NSMutableAttributedString,
        text: String,
        cursorPosition: Int
    ) -> Int? {
        // Check if cursor is right after )
        guard cursorPosition >= 1 else { return nil }
        
        let textBeforeCursor = String(text.prefix(cursorPosition))
        guard textBeforeCursor.hasSuffix(")") else { return nil }
        
        // Find the pattern [text](url)
        let pattern = "\\[([^\\]]+)\\]\\(([^)]+)\\)$"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        
        let nsString = textBeforeCursor as NSString
        guard let match = regex.firstMatch(in: textBeforeCursor, options: [], range: NSRange(location: 0, length: nsString.length)) else {
            return nil
        }
        
        // Extract link text and URL
        let linkTextRange = match.range(at: 1)
        let urlRange = match.range(at: 2)
        
        let linkText = nsString.substring(with: linkTextRange)
        let urlString = nsString.substring(with: urlRange)
        
        // Create link attributes
        let linkAttributes: [NSAttributedString.Key: Any] = [
            .font: style.textFieldFont,
            .foregroundColor: CometChatTheme.primaryColor,
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: urlString
        ]
        
        let formattedLink = NSAttributedString(string: linkText, attributes: linkAttributes)
        
        // Replace the pattern with formatted link
        attributedString.replaceCharacters(in: match.range, with: formattedLink)
        
        // Return new cursor position
        return match.range.location + linkText.count
    }
    
    /// Detects if the user has manually typed a list pattern and activates the corresponding list mode
    /// Patterns detected:
    /// - "1. " at start of line -> activates numbered list mode
    /// - "- " at start of line -> activates bullet list mode (converts to "• ")
    private func detectAndActivateListMode(in textView: UITextView) {
        guard let text = textView.text, !text.isEmpty else { return }
        guard let selectedRange = textView.selectedTextRange else { return }
        
        let cursorPosition = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
        
        // Get the current line info
        let lineInfo = getLineInfo(at: cursorPosition, in: text)
        let lineText = (text as NSString).substring(with: NSRange(location: lineInfo.start, length: lineInfo.length))
        
        // Check for numbered list pattern: "1. " at start of line (or after blockquote)
        // Only activate if cursor is right after the pattern (user just typed the space)
        let numberedPattern = "^(▎\\s)?(\\d+)\\.\\s$"
        if let regex = try? NSRegularExpression(pattern: numberedPattern),
           regex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) != nil {
            // User typed a numbered list pattern - activate numbered list mode
            RichTextFormatterManager.shared.isInNumberedListMode = true
            
            // Extract the number to set currentListNumber
            let numberExtractPattern = "(\\d+)"
            if let numberRegex = try? NSRegularExpression(pattern: numberExtractPattern),
               let match = numberRegex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)),
               let numberRange = Range(match.range(at: 1), in: lineText) {
                let numberString = String(lineText[numberRange])
                RichTextFormatterManager.shared.currentListNumber = Int(numberString) ?? 1
            }
            
            updateToolbarActiveFormats()
            return
        }
        
        // Check for bullet list pattern: "- " at start of line (or after blockquote)
        // Only activate if cursor is right after the pattern (user just typed the space)
        let bulletPattern = "^(▎\\s)?-\\s$"
        if let regex = try? NSRegularExpression(pattern: bulletPattern),
           regex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) != nil {
            // User typed a bullet list pattern - convert "- " to "• " and activate bullet list mode
            
            // Find the position of "- " in the line
            let dashPattern = "-\\s$"
            if let dashRegex = try? NSRegularExpression(pattern: dashPattern),
               let match = dashRegex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) {
                
                let dashRange = NSRange(location: lineInfo.start + match.range.location, length: match.range.length)
                
                // Replace "- " with "• "
                let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
                attributedString.replaceCharacters(in: dashRange, with: "• ")
                
                // Set flag to prevent cursor adjustment
                isSettingCursorProgrammatically = true
                
                textView.attributedText = attributedString
                
                // Position cursor after the bullet
                let newCursorPosition = lineInfo.start + match.range.location + 2 // "• " is 2 characters
                if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
                    textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
                }
                
                // Reset flag after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.isSettingCursorProgrammatically = false
                }
            }
            
            RichTextFormatterManager.shared.isInBulletListMode = true
            updateToolbarActiveFormats()
            return
        }
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Update code block background position when text view scrolls
        if codeBlockTextRange != nil {
            updateCodeBlockBackgroundFrame()
        } else if RichTextFormatterManager.shared.isInCodeBlockMode {
            // Also update when in code block mode (even without a fixed range)
            updateCodeBlockBackgroundForFullText()
        }
        
        // Update blockquote bar position when text view scrolls
        if blockquoteTextRange != nil {
            updateBlockquoteBarFrame()
        } else if RichTextFormatterManager.shared.isInBlockquoteMode && blockquoteStartPosition != nil {
            updateBlockquoteBarFrame()
        }
    }
}

extension CometChatCompactMessageComposer {
        
        func onCursorUpdated(growingTextView: GrowingTextView) {
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                
                // Skip cursor adjustment if we're programmatically setting the cursor
                if this.isSettingCursorProgrammatically {
                    return
                }
                
                let currentPosition = growingTextView.selectedRange
                for (_, formatter) in this.selectedFormatters {
                    formatter.forEach { (_, range) in
                        if currentPosition.lowerBound > range.lowerBound && currentPosition.upperBound < range.upperBound {
                            if growingTextView.selectedRange == currentPosition {
                                growingTextView.selectedRange = NSRange(location: range.upperBound, length: 0)
                            }
                        } else if currentPosition.lowerBound > range.lowerBound && currentPosition.lowerBound < range.upperBound {
                            if growingTextView.selectedRange == currentPosition {
                                growingTextView.selectedRange = NSRange(location: range.lowerBound, length: currentPosition.upperBound - range.lowerBound)
                            }
                        } else if currentPosition.upperBound > range.lowerBound && currentPosition.upperBound < range.upperBound {
                            if growingTextView.selectedRange == currentPosition {
                                growingTextView.selectedRange = NSRange(location: currentPosition.lowerBound, length: range.upperBound - currentPosition.lowerBound)
                            }
                        }
                    }
                }
            }
        }
        
        func setUpSuggestionView(suggestionItems: [SuggestionItem]) {
            
            suggestionContainerView.isHidden = false
            suggestionContainerView.subviews.forEach{( $0.removeFromSuperview() )}
            
            suggestionView = CometChatSuggestionView()
                .set(onSelected: { [weak self] listItemModel in
                    guard let this = self else { return }
                    this.onTextFormatterSelected(listItemModel: listItemModel)
                })
                .set(listScrolledToBottom: { [weak self] onNewItemFetched in
                    guard let this = self else { return }
                    this.ongoingTextFormatter?.textFormatter.onScrollToBottom(suggestionItemList: this.suggestionView?.suggestionItems ?? [], listItem: { listModel in
                        onNewItemFetched(listModel)
                    })
                })
                .set(controller: controller)
                .set(suggestionItems: suggestionItems)
                .build()
            
            suggestionContainerView.addArrangedSubview(suggestionView!)
            
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.controller?.view.layoutIfNeeded()
            }
        }
        
        func update(suggestionItems: [SuggestionItem]) {
            DispatchQueue.main.async { [weak self] in
                guard let this = self else { return }
                if this.ongoingTextFormatter == nil {
                    this.suggestionView?.removeFromSuperview()
                    this.suggestionView = nil
                    this.suggestionContainerView.isHidden = true
                    return
                }
                if let suggestionView = this.suggestionView {
                    suggestionView.set(suggestionItems: suggestionItems)
                } else {
                    this.setUpSuggestionView(suggestionItems: suggestionItems)
                }
            }
        }
        
        func getUniqueSelectedTextFormatterCount() -> Int {
            var uniqueAddedTextFormatter = [String: SuggestionItem]()
            selectedFormatters.forEach { (character, _) in
                selectedFormatters[character]?.forEach({ (item, range) in
                    uniqueAddedTextFormatter[item.id ?? ""] = item
                })
            }
            return uniqueAddedTextFormatter.count
        }
        
        func onTextFormatterSelected(listItemModel: SuggestionItem) {
            
            if let ongoingTextFormatter = ongoingTextFormatter, let attributedComposerText = textView.attributedText {

                // The tracked mention range can go stale (text shortened after it was captured,
                // e.g. fast delete / autocorrect) while the suggestion list is still tappable.
                // Applying a stale range below would crash with "out of bounds". If it no longer
                // fits both the plain and attributed text, invalidate state and bail safely.
                let mentionRange = ongoingTextFormatter.range
                let currentTextLength = ((textView.text ?? "") as NSString).length
                let isMentionRangeValid = mentionRange.location != NSNotFound
                    && mentionRange.location >= 0
                    && mentionRange.length >= 0
                    && mentionRange.location + mentionRange.length <= currentTextLength
                    && mentionRange.location + mentionRange.length <= attributedComposerText.length

                guard isMentionRangeValid else {
                    // Invalidate synchronously so the stale range can't be reused, then clean up UI.
                    self.ongoingTextFormatter = nil
                    self.suggestionView?.removeFromSuperview()
                    self.suggestionView = nil
                    self.suggestionContainerView.isHidden = true
                    richTextToolbar.enableAllButtons()
                    updateToolbarActiveFormats()
                    endOnGoingTextFormatting()
                    return
                }

                let trackingCharacter = ongoingTextFormatter.textFormatter.getTrackingCharacter()
                
                self.ongoingTextFormatter = nil
                //removing suggestionView view
                self.suggestionView?.removeFromSuperview()
                self.suggestionView = nil
                self.suggestionContainerView.isHidden = true
                
                // Re-enable toolbar buttons when mention is selected
                richTextToolbar.enableAllButtons()
                updateToolbarActiveFormats()
                
                checkTextFormatter(textView: textView, range: ongoingTextFormatter.range, text: listItemModel.visibleText ?? "")
                
                let mutableAttributedString = NSMutableAttributedString(attributedString: attributedComposerText)
                
                // Use the mention's original attributes - preserve mention styling
                var selectedAttributes = listItemModel.visibleTextAttributes ?? [
                    .font: style.textFieldFont,
                    .foregroundColor: style.textFieldColor
                ]
                
                // If in code block mode, add the code block key while preserving mention styling
                if RichTextFormatterManager.shared.isInCodeBlockMode {
                    selectedAttributes[RichTextFormatterManager.isCodeBlockKey] = true
                }
                // If in blockquote mode, add the blockquote key while preserving mention styling
                else if RichTextFormatterManager.shared.isInBlockquoteMode {
                    selectedAttributes[RichTextFormatterManager.isBlockquoteKey] = true
                }
                
                mutableAttributedString.replaceCharacters(
                    in: ongoingTextFormatter.range,
                    with: NSAttributedString(
                        string: listItemModel.visibleText ?? "",
                        attributes: selectedAttributes
                    )
                )
                
                // Add space after mention with appropriate styling based on current mode
                var spaceAttributes: [NSAttributedString.Key: Any] = [
                    NSAttributedString.Key.foregroundColor: style.textFieldColor,
                    NSAttributedString.Key.font: style.textFieldFont
                ]
                
                // If in code block mode, use code block styling for the space
                if RichTextFormatterManager.shared.isInCodeBlockMode {
                    let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
                    spaceAttributes = [
                        NSAttributedString.Key.foregroundColor: CometChatTheme.neutralColor900,
                        NSAttributedString.Key.font: monoFont,
                        RichTextFormatterManager.isCodeBlockKey: true
                    ]
                } else if RichTextFormatterManager.shared.isInBlockquoteMode {
                    spaceAttributes = [
                        NSAttributedString.Key.foregroundColor: style.textFieldColor,
                        NSAttributedString.Key.font: style.textFieldFont,
                        RichTextFormatterManager.isBlockquoteKey: true
                    ]
                }
                
                mutableAttributedString.append(NSAttributedString(string: " ", attributes: spaceAttributes))
                
                textView.attributedText = NSAttributedString(attributedString: mutableAttributedString)
                
                let newRange = NSRange(location: ongoingTextFormatter.range.location, length: (listItemModel.visibleText as? NSString)?.length ?? 0)
                
                if listItemModel.underlyingText != nil {
                    if selectedFormatters[trackingCharacter] != nil {
                        selectedFormatters[trackingCharacter]?.append((item: listItemModel, range: newRange))
                    } else {
                        selectedFormatters[trackingCharacter] = [(item: listItemModel, range: newRange)]
                    }
                }
                
                var selectedRange = NSRange(location: newRange.upperBound, length: 0)
                if newRange.upperBound+1 == mutableAttributedString.length {
                    selectedRange.location = (newRange.upperBound + 1)
                }
                textView.selectedRange = selectedRange

                // Reset typing attributes so text typed AFTER the mention uses normal styling
                // instead of inheriting the mention's (orange) color. Mirrors the trailing
                // space's attributes so it stays correct in code-block / blockquote modes too.
                textView.typingAttributes = spaceAttributes

                if getUniqueSelectedTextFormatterCount() >= 10 {
                    endOnGoingTextFormatting()
                    addLimitView()
                } else {
                    removeLimitView()
                }
            }
            
            endOnGoingTextFormatting()
        }
        
        func addLimitView() {
            isSuggestionLimitExceeded = true
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let limitView = LimitedFormatterView()
                limitView.icon.image = style.infoIcon
                limitView.icon.tintColor = style.infoIconTint
                limitView.infoLabel.textColor = style.infoTextColor
                limitView.backgroundColor = style.infoBackgroundColor
                self.suggestionContainerView.subviews.forEach({ $0.removeFromSuperview() })
                self.suggestionContainerView.isHidden = false
                self.suggestionContainerView.addArrangedSubview(limitView)
                
                UIView.animate(withDuration: 0.3) {
                    self.controller?.view.layoutIfNeeded()
                }
            }
        }
        
        func removeLimitView() {
            isSuggestionLimitExceeded = false
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return  }
                self.suggestionContainerView.isHidden = true
                self.suggestionContainerView.subviews.forEach({ $0.removeFromSuperview() })
                UIView.animate(withDuration: 0.3) {
                    self.controller?.view.layoutIfNeeded()
                }
            }
        }
        
        internal func endOnGoingTextFormatting() {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return  }
                if self.ongoingTextFormatter != nil {
                    self.ongoingTextFormatter = nil
                    self.suggestionView?.removeFromSuperview()
                    self.suggestionView = nil
                    self.suggestionContainerView.isHidden = true

                    // Re-enable toolbar buttons when mention typing ends
                    self.richTextToolbar.enableAllButtons()
                    self.updateToolbarActiveFormats()

                    UIView.animate(withDuration: 0.3) {
                        self.controller?.view.layoutIfNeeded()
                    }
                }
            }
        }
        
        @discardableResult
        internal func checkTextFormatter(textView: GrowingTextView, range: NSRange, text: String) -> Bool {

            // Safety net: `range` may be a stale mention span that no longer fits the current
            // text (e.g. the text was shortened after the range was captured). Passing such a
            // range to `replacingCharacters(in:)` crashes with "Range or index out of bounds".
            // On the live-typing path UIKit always supplies a valid range, so this never fires
            // there; it only guards the stored-range callers.
            let nsCurrentText = (textView.text ?? "") as NSString
            guard range.location != NSNotFound,
                  range.location >= 0,
                  range.length >= 0,
                  range.location + range.length <= nsCurrentText.length else {
                return true
            }

            let updatedString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text)
            let editLocation = range.location
            let oldText = textView.text! as NSString
            let oldString = textView.text!
            
            // Set typing attributes based on current mode - blockquote/codeBlock takes priority, then persistent formats
            if RichTextFormatterManager.shared.isInBlockquoteMode {
                // In blockquote mode, preserve persistent formats (bold, italic, etc.)
                // IMPORTANT: Add isBlockquoteKey so the blockquote bar extends to all typed text
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
            } else if RichTextFormatterManager.shared.isInCodeBlockMode {
                let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
                // IMPORTANT: Do NOT set backgroundColor - the codeBlockBackgroundView provides the background
                // Add isCodeBlockKey so the code block is properly detected when sending
                textView.typingAttributes = [
                    .font: monoFont,
                    .foregroundColor: CometChatTheme.neutralColor900,
                    RichTextFormatterManager.isCodeBlockKey: true
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
            
            //going through already added text-formatter
            for (character, value) in selectedFormatters {
                
                for (index, (_, key)) in value.enumerated() {
                    
                    if let attributedString = textView.attributedText {
                        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)
                        
                        //if back pressed or newTextAdded and nsrange same as the current formatter then removing formatter & its text
                        if range.location == (key.upperBound-1) || range == key {
                            if getUniqueSelectedTextFormatterCount() <= 10 {
                                removeLimitView()
                            }
                            selectedFormatters[character]?.remove(at: index)
                            endOnGoingTextFormatting()
                            if text == "" && range.length <= 1 {
                                let removingRange = removeAccordingToDefaultBehavior(range: key, mutableAttributedString: mutableAttributedString)
                                checkTextFormatter(textView: textView, range: removingRange, text: "")
                                textView.attributedText = mutableAttributedString
                                textView.selectedRange = NSRange(location: removingRange.location, length: 0)
                                onCursorUpdated(growingTextView: textView)
                                return false
                            }
                            else {
                                checkTextFormatter(textView: textView, range: range, text: text)
                                return true
                            }
                        } else if (range.lowerBound <= key.lowerBound && range.upperBound >= key.upperBound) {
                            if getUniqueSelectedTextFormatterCount() <= 10 {
                                removeLimitView()
                            }
                            selectedFormatters[character]?.remove(at: index)
                            endOnGoingTextFormatting()
                            if text == "" && range.length <= 1 {
                                let removingRange = removeAccordingToDefaultBehavior(range: key, mutableAttributedString: mutableAttributedString)
                                checkTextFormatter(textView: textView, range: removingRange, text: "")
                                textView.attributedText = mutableAttributedString
                                textView.selectedRange = NSRange(location: removingRange.location, length: 0)
                                onCursorUpdated(growingTextView: textView)
                                return false
                            }
                            else {
                                checkTextFormatter(textView: textView, range: range, text: text)
                                return true
                            }
                        } else if (range.lowerBound < key.upperBound && range.upperBound > key.lowerBound) {
                            if getUniqueSelectedTextFormatterCount() <= 10 {
                                removeLimitView()
                            }
                            selectedFormatters[character]?.remove(at: index)
                            endOnGoingTextFormatting()
                            let newRange = NSRange(location: key.lowerBound, length: range.upperBound - key.lowerBound)
                            let removingRange = removeAccordingToDefaultBehavior(range: newRange, mutableAttributedString: mutableAttributedString)
                            checkTextFormatter(textView: textView, range: removingRange, text: "")
                            textView.attributedText = mutableAttributedString
                            textView.selectedRange = NSRange(location: removingRange.location, length: 0)
                            onCursorUpdated(growingTextView: textView)
                            return false
                        }
                        
                        //If new added text is in between already added formatter then removing the formatter and changing its style to normal
                        if (range.lowerBound <= key.lowerBound && range.upperBound >= key.upperBound) {
                            mutableAttributedString.removeAttribute(NSAttributedString.Key.foregroundColor, range: key)
                            mutableAttributedString.removeAttribute(NSAttributedString.Key.font, range: key)
                            mutableAttributedString.addAttributes([
                                NSAttributedString.Key.foregroundColor: style.textFieldColor,
                                NSAttributedString.Key.font: style.textFieldFont
                            ], range: key)
                            textView.attributedText = mutableAttributedString
                            textView.selectedRange = range
                            selectedFormatters[character]?.remove(at: index)
                        }
                        
                        //if the new added text is in the left side of the already added formatter then updating its NSRange
                        if (range.location-1) < key.location {
                            var newLocation = key.location + (text as NSString).length - range.length
                            if text == "" {
                                if range.length > 1 {
                                    if range.lowerBound > 0 && range.upperBound < oldText.length {
                                        if (oldString[(range.upperBound)] == " " || composerSpaceManageSpacialCharacter[oldString[range.upperBound]] ?? false) &&  oldString[(range.lowerBound-1)] == " " {
                                            newLocation = newLocation - 1
                                        }
                                    } else if range.lowerBound == 0 && range.upperBound < oldText.length && oldString[(range.upperBound)] == " " {
                                        newLocation = newLocation - 1
                                    }
                                }
                            }
                            let newRange = NSRange(location: newLocation, length: key.length)
                            selectedFormatters[character]?[index].range = newRange
                        }
                    }
                }
            }
            
            //checking for left nearest textFormatter character to start new onGoingTextFormatter
            // Don't start mention if in code block mode or inline code mode - mentions should not work inside code
            // Also don't start if certain rich text formatters are active
            let hasInlineFormatters = RichTextFormatterManager.shared.isInBulletListMode ||
                                      RichTextFormatterManager.shared.isInNumberedListMode
            
            // Disable mentions in code block mode or inline code mode
            let isInCodeBlockMode = RichTextFormatterManager.shared.isInCodeBlockMode
            let hasInlineCode = RichTextFormatterManager.shared.persistentFormats.contains(.code)
            let shouldDisableMentions = isInCodeBlockMode || hasInlineCode
            
            if ongoingTextFormatter == nil && !isSuggestionLimitExceeded && !hasInlineFormatters && !shouldDisableMentions {
                if let updatedString = updatedString {
                    var index = (range.location - range.length)
                    var checkCount = 0
                    while index >= 0, updatedString[index] != " ", checkCount < 30 {
                        
                        if let characterAtIndex = updatedString[index].first, let textFormatter = viewModel.textFormatterMap[characterAtIndex] {
                            let length = range.location - index
                            ongoingTextFormatter = OnGoingTextFormatterModel(range: NSRange(location: index, length: (length + 1)), textFormatter: textFormatter)
                            // Disable all toolbar buttons when mention is being typed
                            disableToolbarForMention()
                            break
                        }
                        index = index-1
                        checkCount = checkCount+1
                    }
                }
            }
            
            if let updatedString = updatedString, (text as NSString).length <= 1, !isSuggestionLimitExceeded && !hasInlineFormatters && !shouldDisableMentions {
                
                // New OnGoingTextFormatter start if the matched character is found
                if let newCharacter = text.first, let textFormatter = viewModel.textFormatterMap[newCharacter] {
                    
                    if (range.location == 0 || oldString[range.location-1] == " " || oldString[range.location-1] == "\n") {
                        ongoingTextFormatter = OnGoingTextFormatterModel(range: NSRange(location: editLocation, length: 1), textFormatter: textFormatter)
                        // Disable all toolbar buttons when mention is being typed
                        disableToolbarForMention()
                        textFormatter.search(string: "") { listItem in
                            if listItem.isEmpty {
                                self.endOnGoingTextFormatting()
                            } else {
                                self.update(suggestionItems: listItem)
                            }
                        }
                    }
                    
                } else if let onGoingTextFormatter = ongoingTextFormatter {
                    
                    let changeIsWithInRange = NSLocationInRange(range.location, onGoingTextFormatter.range) && NSLocationInRange(range.upperBound, onGoingTextFormatter.range)
                    
                    if changeIsWithInRange ||
                        range.location == onGoingTextFormatter.range.location + onGoingTextFormatter.range.length ||
                        (text == "" && (changeIsWithInRange ||
                                        range.location == onGoingTextFormatter.range.location + onGoingTextFormatter.range.length - 1)
                        ) {
                        
                        if text == "" && (oldText as NSString).substring(with: range) == "\(onGoingTextFormatter.textFormatter.getTrackingCharacter())" {
                            endOnGoingTextFormatting()
                        }
                        
                        if range.location == onGoingTextFormatter.range.location + onGoingTextFormatter.range.length {
                            
                            if text == "" {
                                onGoingTextFormatter.range.length = onGoingTextFormatter.range.length-1
                            } else {
                                onGoingTextFormatter.range.length = onGoingTextFormatter.range.length+1
                            }
                            
                            if onGoingTextFormatter.range.length-1 <= 0 {
                                if onGoingTextFormatter.range.length == 1 &&
                                    (updatedString as NSString).substring(with: onGoingTextFormatter.range).first == onGoingTextFormatter.textFormatter.getTrackingCharacter() {
                                    let focuedText = String(onGoingTextFormatter.textFormatter.getTrackingCharacter())
                                    onGoingTextFormatter.textFormatter.search(string: focuedText) { listItem in
                                        if listItem.isEmpty {
                                            self.endOnGoingTextFormatting()
                                        } else {
                                            self.update(suggestionItems: listItem)
                                        }
                                    }
                                } else {
                                    self.endOnGoingTextFormatting()
                                    return true
                                }
                            }
                            
                            let focuedText = (updatedString as NSString).substring(with: onGoingTextFormatter.range)
                            onGoingTextFormatter.textFormatter.search(string: focuedText) { listItem in
                                if listItem.isEmpty {
                                    self.endOnGoingTextFormatting()
                                } else {
                                    self.update(suggestionItems: listItem)
                                }
                            }
                            
                        } else {
                            
                            if range.length <= 1 {
                                onGoingTextFormatter.range.length = range.location - onGoingTextFormatter.range.location
                                let focuedText = (updatedString as NSString).substring(with: onGoingTextFormatter.range)
                                onGoingTextFormatter.textFormatter.search(string: focuedText) { listItem in
                                    if listItem.isEmpty {
                                        self.endOnGoingTextFormatting()
                                    }
                                    self.update(suggestionItems: listItem)
                                }
                            } else {
                                self.endOnGoingTextFormatting()
                            }
                        }
                    } else {
                        self.endOnGoingTextFormatting()
                    }
                }
            } else {
                self.endOnGoingTextFormatting()
            }
            
            return true
        }
        
        func removeAccordingToDefaultBehavior(range: NSRange, mutableAttributedString: NSMutableAttributedString) -> NSRange {
            var newRange = range
            let nsString = mutableAttributedString.string
            if range.length > 1 {
                if range.lowerBound > 0 && range.upperBound < nsString.utf16.count {
                    if range.lowerBound > 0 && range.upperBound < nsString.utf16.count {
                        if (nsString[range.upperBound] == " " || composerSpaceManageSpacialCharacter[nsString[range.upperBound]] ?? false) && nsString[(range.lowerBound-1)] == " "  {
                            newRange.location = newRange.location - 1
                            newRange.length = newRange.length + 1
                        }
                    }
                } else if range.lowerBound == 0 && range.upperBound < nsString.utf16.count && nsString[(range.upperBound)] == " " {
                    newRange.length = newRange.length + 1
                }
            }
            
            mutableAttributedString.deleteCharacters(in: newRange)
            return newRange
        }
    }
    
    extension CometChatCompactMessageComposer {
        /// Disables all toolbar buttons when a mention is being typed
        /// This prevents rich text formatting from being applied to mentions
        func disableToolbarForMention() {
            for (_, button) in richTextToolbar.formatButtons {
                button.isEnabled = false
                button.alpha = 0.3
            }
        }
        
        /// Removes ALL formatting from emojis in the text view
        /// This is called after text changes to ensure emojis remain completely unformatted
        /// Emojis should always appear in their natural form without any styling
        func removeFormattingFromEmojis(in textView: UITextView) {
            guard let attributedText = textView.attributedText, attributedText.length > 0 else { return }
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            let text = attributedText.string
            var modified = false
            var foundEmojiWithFormatting = false
            
            // Default attributes for emojis - completely unformatted
            let defaultEmojiAttributes: [NSAttributedString.Key: Any] = [
                .font: style.textFieldFont,
                .foregroundColor: style.textFieldColor
            ]
            
            // Iterate through each character in the string
            var index = text.startIndex
            while index < text.endIndex {
                let char = text[index]
                
                // Check if this character is an emoji
                if char.isEmoji {
                    // Calculate the NSRange for this character (emojis can be multi-byte)
                    let charStartIndex = text.distance(from: text.startIndex, to: index)
                    let nextIndex = text.index(after: index)
                    let charLength = text.distance(from: index, to: nextIndex)
                    let charRange = NSRange(location: charStartIndex, length: charLength)
                    
                    // Validate range
                    guard charRange.location + charRange.length <= attributedText.length else {
                        index = nextIndex
                        continue
                    }
                    
                    // Get current attributes
                    let attributes = attributedText.attributes(at: charRange.location, effectiveRange: nil)
                    
                    // Check if any formatting is applied
                    let hasUnderline = attributes[.underlineStyle] != nil
                    let hasStrikethrough = attributes[.strikethroughStyle] != nil
                    let hasBackgroundColor = attributes[.backgroundColor] != nil
                    let hasLink = attributes[.link] != nil
                    let hasCodeBlockKey = attributes[RichTextFormatterManager.isCodeBlockKey] != nil
                    
                    // Check font formatting
                    var hasFontFormatting = false
                    if let font = attributes[.font] as? UIFont {
                        let fontName = font.fontName.lowercased()
                        let isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
                        let isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
                        let isMonospace = fontName.contains("mono") || fontName.contains("courier") || fontName.contains("menlo")
                        hasFontFormatting = isBold || isItalic || isMonospace
                    }
                    
                    let hasAnyFormatting = hasUnderline || hasStrikethrough || hasBackgroundColor || 
                                          hasLink || hasCodeBlockKey || hasFontFormatting
                    
                    if hasAnyFormatting {
                        // Remove ALL formatting attributes
                        mutableAttributedString.removeAttribute(.underlineStyle, range: charRange)
                        mutableAttributedString.removeAttribute(.strikethroughStyle, range: charRange)
                        mutableAttributedString.removeAttribute(.backgroundColor, range: charRange)
                        mutableAttributedString.removeAttribute(.link, range: charRange)
                        mutableAttributedString.removeAttribute(RichTextFormatterManager.isCodeBlockKey, range: charRange)
                        
                        // Set default attributes for emoji
                        mutableAttributedString.addAttribute(.font, value: style.textFieldFont, range: charRange)
                        mutableAttributedString.addAttribute(.foregroundColor, value: style.textFieldColor, range: charRange)
                        
                        modified = true
                        foundEmojiWithFormatting = true
                    }
                }
                
                index = text.index(after: index)
            }
            
            // Only update if we actually removed formatting
            if modified {
                // Save cursor position
                let selectedRange = textView.selectedRange
                
                // Update attributed text
                textView.attributedText = mutableAttributedString
                
                // Restore cursor position
                textView.selectedRange = selectedRange
            }
            
            // If we found an emoji with formatting, it means the user just typed an emoji with persistent formatting active
            // Clear persistent formatting state to prevent future emojis from getting formatted
            // But DON'T clear if we're in code block mode - the user might want to continue typing code
            if foundEmojiWithFormatting && !RichTextFormatterManager.shared.persistentFormats.isEmpty &&
               !RichTextFormatterManager.shared.isInCodeBlockMode {
                RichTextFormatterManager.shared.clearPersistentFormats()
                
                // Reset typing attributes to default
                textView.typingAttributes = [
                    .font: style.textFieldFont,
                    .foregroundColor: style.textFieldColor
                ]
                
                // Update toolbar
                DispatchQueue.main.async { [weak self] in
                    self?.updateToolbarActiveFormats()
                }
            }
        }
    }


extension CometChatCompactMessageComposer {
    /// Strips ALL formatting from emojis in an NSMutableAttributedString
    /// This is used when processing pasted text or other attributed strings
    func stripFormattingFromEmojis(in attributedString: NSMutableAttributedString) {
        let text = attributedString.string
        guard !text.isEmpty else { return }
        
        // Iterate through each character in the string
        var index = text.startIndex
        while index < text.endIndex {
            let char = text[index]
            
            // Check if this character is an emoji
            if char.isEmoji {
                // Calculate the NSRange for this character (emojis can be multi-byte)
                let charStartIndex = text.distance(from: text.startIndex, to: index)
                let nextIndex = text.index(after: index)
                let charLength = text.distance(from: index, to: nextIndex)
                let charRange = NSRange(location: charStartIndex, length: charLength)
                
                // Validate range
                guard charRange.location + charRange.length <= attributedString.length else {
                    index = nextIndex
                    continue
                }
                
                // Remove ALL formatting attributes from emoji
                attributedString.removeAttribute(.underlineStyle, range: charRange)
                attributedString.removeAttribute(.strikethroughStyle, range: charRange)
                attributedString.removeAttribute(.backgroundColor, range: charRange)
                attributedString.removeAttribute(.link, range: charRange)
                attributedString.removeAttribute(RichTextFormatterManager.isCodeBlockKey, range: charRange)
                
                // Set default attributes for emoji
                attributedString.addAttribute(.font, value: style.textFieldFont, range: charRange)
                attributedString.addAttribute(.foregroundColor, value: style.textFieldColor, range: charRange)
            }
            
            index = text.index(after: index)
        }
    }
    
    /// Strips triple backticks from code block content
    /// This handles the case where user pastes code that contains backticks or types backticks while in code block mode
    func stripBackticksFromCodeBlockContent(in textView: UITextView) {
        guard let text = textView.text, !text.isEmpty else { return }
        guard let attributedText = textView.attributedText else { return }
        
        let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
        var didModify = false
        var currentText = mutableAttributedString.string
        
        // Determine the start position for code block content
        var codeBlockContentStart = 0
        if let blockquoteRange = blockquoteTextRange, blockquoteRange.length > 0 {
            // There's blockquote content - code block starts after it
            codeBlockContentStart = blockquoteRange.location + blockquoteRange.length
            // Skip any newlines/whitespace after blockquote
            while codeBlockContentStart < currentText.count {
                let index = currentText.index(currentText.startIndex, offsetBy: codeBlockContentStart)
                let char = currentText[index]
                if char == "\n" || char == " " || char == "\t" {
                    codeBlockContentStart += 1
                } else {
                    break
                }
            }
        }
        
        // Check for leading ``` in code block content
        if codeBlockContentStart < currentText.count {
            let codeBlockContent = String(currentText.dropFirst(codeBlockContentStart))
            if codeBlockContent.hasPrefix("```") {
                // Remove the leading ```
                let backtickRange = NSRange(location: codeBlockContentStart, length: 3)
                mutableAttributedString.deleteCharacters(in: backtickRange)
                currentText = mutableAttributedString.string
                didModify = true
                
                // Also remove the newline after ``` if present
                if codeBlockContentStart < currentText.count {
                    let afterBackticks = String(currentText.dropFirst(codeBlockContentStart))
                    if afterBackticks.hasPrefix("\n") {
                        let newlineRange = NSRange(location: codeBlockContentStart, length: 1)
                        mutableAttributedString.deleteCharacters(in: newlineRange)
                        currentText = mutableAttributedString.string
                    }
                }
            }
        }
        
        // Check for trailing ``` in code block content
        var trimmedEnd = currentText
        while trimmedEnd.hasSuffix("\n") || trimmedEnd.hasSuffix(" ") || trimmedEnd.hasSuffix("\t") {
            trimmedEnd = String(trimmedEnd.dropLast())
        }
        
        if trimmedEnd.hasSuffix("```") {
            let backtickStart = trimmedEnd.count - 3
            if backtickStart >= codeBlockContentStart {
                // Also remove the newline before ``` if present
                var removeStart = backtickStart
                var removeLength = 3
                if backtickStart > 0 {
                    let charBeforeBackticks = currentText[currentText.index(currentText.startIndex, offsetBy: backtickStart - 1)]
                    if charBeforeBackticks == "\n" {
                        removeStart = backtickStart - 1
                        removeLength = 4
                    }
                }
                
                let backtickRange = NSRange(location: removeStart, length: removeLength)
                if backtickRange.location >= 0 && backtickRange.location + backtickRange.length <= mutableAttributedString.length {
                    mutableAttributedString.deleteCharacters(in: backtickRange)
                    didModify = true
                }
            }
        }
        
        // Update text view if we modified the text
        if didModify {
            // Save cursor position
            let selectedRange = textView.selectedRange
            
            // Ensure all code block content has the proper attributes
            let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFieldFont.pointSize, weight: .regular)
            if mutableAttributedString.length > codeBlockContentStart {
                let codeBlockRange = NSRange(location: codeBlockContentStart, length: mutableAttributedString.length - codeBlockContentStart)
                
                // First, find any inline code regions (isCodeBlockKey = false) within the code block range
                // and preserve them - they should NOT be converted to code block
                var inlineCodeRanges: [NSRange] = []
                mutableAttributedString.enumerateAttribute(RichTextFormatterManager.isCodeBlockKey, in: codeBlockRange, options: []) { value, range, _ in
                    if let isCodeBlock = value as? Bool, isCodeBlock == false {
                        // This is inline code - preserve it
                        inlineCodeRanges.append(range)
                    }
                }
                
                mutableAttributedString.addAttribute(.font, value: monoFont, range: codeBlockRange)
                mutableAttributedString.addAttribute(.foregroundColor, value: CometChatTheme.neutralColor900, range: codeBlockRange)
                mutableAttributedString.addAttribute(RichTextFormatterManager.isCodeBlockKey, value: true, range: codeBlockRange)
                
                // Restore inline code attributes (isCodeBlockKey = false)
                for inlineRange in inlineCodeRanges {
                    mutableAttributedString.addAttribute(RichTextFormatterManager.isCodeBlockKey, value: false, range: inlineRange)
                    // Also restore inline code background color
                    mutableAttributedString.addAttribute(.backgroundColor, value: CometChatTheme.neutralColor300, range: inlineRange)
                }
            }
            
            // Update attributed text
            textView.attributedText = mutableAttributedString
            
            // Restore cursor position (adjusted for removed characters)
            let newCursorPosition = min(selectedRange.location, mutableAttributedString.length)
            textView.selectedRange = NSRange(location: newCursorPosition, length: 0)
        }
    }
}
