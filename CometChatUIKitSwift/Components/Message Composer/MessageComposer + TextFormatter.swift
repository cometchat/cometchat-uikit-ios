//
//  MessageComposer + TextFormatter.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 07/03/24.
//

import UIKit
import Foundation
import CometChatSDK

extension CometChatMessageComposer: UITextViewDelegate {
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        remove(footerView: true)
        // COMMENTED OUT - Rich text formatting disabled for MessageComposer
        // Set typing attributes based on persistent formats (or default if none)
        // if RichTextFormatterManager.shared.persistentFormats.isEmpty {
        //     textView.typingAttributes = [
        //         .font: style.textFiledFont,
        //         .foregroundColor: style.textFiledColor
        //     ]
        // } else {
        //     textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
        //         baseFont: style.textFiledFont,
        //         baseColor: style.textFiledColor
        //     )
        // }
        
        // Always use default typing attributes
        textView.typingAttributes = [
            .font: style.textFiledFont,
            .foregroundColor: style.textFiledColor
        ]
        return true
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // COMMENTED OUT - Rich text formatting disabled for MessageComposer
        // Handle paste with markdown formatting when enableRichTextFormatting is true
        // if enableRichTextFormatting && text.count > 1 && (RichTextFormatterManager.shared.containsMarkdownFormatting(text) || RichTextFormatterManager.shared.containsURLs(text)) {
        //     ... (all the markdown paste handling code)
        // }
        
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
            if this.viewModel.textFormatterMap.isEmpty == false {
                this.onCursorUpdated(growingTextView: textView as! GrowingTextView)
            }
            // COMMENTED OUT - Rich text formatting disabled for MessageComposer
            // Update toolbar active formats when selection changes
            // this.updateToolbarActiveFormats()
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

            // Update send button state based on text changes
            this.updateSendButtonState()
            
            // COMMENTED OUT - Rich text formatting disabled for MessageComposer
            // Update active formats in toolbar
            // this.updateToolbarActiveFormats()
            
            // Ensure typing attributes reflect current mode
            // if RichTextFormatterManager.shared.isInBlockquoteMode {
            //     textView.typingAttributes = [
            //         .font: this.style.textFiledFont,
            //         .foregroundColor: UIColor.secondaryLabel
            //     ]
            // } else if RichTextFormatterManager.shared.isInCodeBlockMode {
            //     let monoFont = UIFont.monospacedSystemFont(ofSize: this.style.textFiledFont.pointSize, weight: .regular)
            //     // Use inline background styling for code block
            //     textView.typingAttributes = [
            //         .font: monoFont,
            //         .foregroundColor: CometChatTheme.neutralColor900,
            //         .backgroundColor: CometChatTheme.neutralColor300
            //     ]
            // } else if !RichTextFormatterManager.shared.persistentFormats.isEmpty {
            //     textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
            //         baseFont: this.style.textFiledFont,
            //         baseColor: this.style.textFiledColor
            //     )
            // }
        }
    }
    
}

extension CometChatMessageComposer {
    
    func onCursorUpdated(growingTextView: GrowingTextView) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
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
                if let onSuggestionItemClick = this.onSuggestionItemClick{
                    onSuggestionItemClick(listItemModel)
                }else{
                    this.onTextFormatterSelected(listItemModel: listItemModel)
                }
            })
            .set(listScrolledToBottom: { [weak self] onNewItemFetched in
                guard let this = self else { return }
                this.ongoingTextFormatter?.textFormatter.onScrollToBottom(suggestionItemList: this.suggestionView?.suggestionItems ?? [], listItem: { listModel in
                    onNewItemFetched(listModel)
                })
            })
            .set(controller: controller)
            .set(suggestionItems: suggestionItems)
            .set(style: suggestionViewStyle)
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
                self.ongoingTextFormatter = nil
                self.suggestionView?.removeFromSuperview()
                self.suggestionView = nil
                self.suggestionContainerView.isHidden = true
                endOnGoingTextFormatting()
                return
            }

            let trackingCharacter = ongoingTextFormatter.textFormatter.getTrackingCharacter()

            self.ongoingTextFormatter = nil
            //removing suggestionView view
            self.suggestionView?.removeFromSuperview()
            self.suggestionView = nil
            self.suggestionContainerView.isHidden = true

            checkTextFormatter(textView: textView, range: ongoingTextFormatter.range, text: listItemModel.visibleText ?? "")
            
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedComposerText)
            var selectedAttributes = listItemModel.visibleTextAttributes
            if selectedAttributes == nil {
                selectedAttributes = [
                    .font: style.textFiledFont,
                    .foregroundColor: style.textFiledColor
                ]
            }
            mutableAttributedString.replaceCharacters(
                in: ongoingTextFormatter.range,
                with: NSAttributedString(
                    string: listItemModel.visibleText ?? "",
                    attributes: selectedAttributes
                )
            )
            mutableAttributedString.append(NSAttributedString(string: " ", attributes: [
                NSAttributedString.Key.foregroundColor: style.textFiledColor,
                NSAttributedString.Key.font: style.textFiledFont
            ]))
            
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
            // instead of inheriting the mention's (orange) color.
            textView.typingAttributes = [
                NSAttributedString.Key.foregroundColor: style.textFiledColor,
                NSAttributedString.Key.font: style.textFiledFont
            ]

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
        isSuggestionLimitAcceded = true
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return } 
            let limitView = LimitedFormatterView()
            limitView.icon.image = style.infoIcon
            limitView.icon.tintColor = style.infoIconTint
            limitView.infoLabel.textColor = style.infoTextColor
            limitView.dividerView.backgroundColor = style.infoSeparatorColor
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
        isSuggestionLimitAcceded = false
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
        
        // COMMENTED OUT - Rich text formatting disabled for MessageComposer
        // Set typing attributes based on current mode - blockquote/codeBlock takes priority, then persistent formats
        // if RichTextFormatterManager.shared.isInBlockquoteMode {
        //     textView.typingAttributes = [
        //         .font: style.textFiledFont,
        //         .foregroundColor: UIColor.secondaryLabel
        //     ]
        // } else if RichTextFormatterManager.shared.isInCodeBlockMode {
        //     let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFiledFont.pointSize, weight: .regular)
        //     // Monospace font with inline background for code block
        //     textView.typingAttributes = [
        //         .font: monoFont,
        //         .foregroundColor: CometChatTheme.neutralColor900,
        //         .backgroundColor: CometChatTheme.neutralColor300
        //     ]
        // } else if !RichTextFormatterManager.shared.persistentFormats.isEmpty {
        //     textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
        //         baseFont: style.textFiledFont, 
        //         baseColor: style.textFiledColor
        //     )
        // } else {
        //     textView.typingAttributes = [
        //         .font: style.textFiledFont, 
        //         .foregroundColor: style.textFiledColor
        //     ]
        // }
        
        // Always use default typing attributes
        textView.typingAttributes = [
            .font: style.textFiledFont, 
            .foregroundColor: style.textFiledColor
        ]
        
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
                        ///When textFormatter is selected with some extra texts se well
                        ///case: "hey whats upp @Iron Man how are you?"
                        ///key = @Iron Man
                        ///Range = "upp @Iron Man how"
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
                        ///When backspace is long pressed this case arrives
                        ///case: "hey whats upp @Iron Man how are you?"
                        ///key = @Iron Man
                        ///Range = "Man how are you"
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
                            NSAttributedString.Key.foregroundColor: style.textFiledColor,
                            NSAttributedString.Key.font: style.textFiledFont
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
        if ongoingTextFormatter == nil && !isSuggestionLimitAcceded {
            if let updatedString = updatedString {
                var index = (range.location - range.length)
                var checkCount = 0
                while index >= 0, updatedString[index] != " ", checkCount < 30 {
                    
                    if let characterAtIndex = updatedString[index].first, let textFormatter = viewModel.textFormatterMap[characterAtIndex] {
                        let length = range.location - index
                        ongoingTextFormatter = OnGoingTextFormatterModel(range: NSRange(location: index, length: (length + 1)), textFormatter: textFormatter)
                        break
                    }
                    index = index-1
                    checkCount = checkCount+1
                }
            }
        }
        
        if let updatedString = updatedString, (text as NSString).length <= 1, !isSuggestionLimitAcceded {
            
            // New OnGoingTextFormatter start if the matched character is found
            if let newCharacter = text.first, let textFormatter = viewModel.textFormatterMap[newCharacter] {
                
                if (range.location == 0 || oldString[range.location-1] == " " || oldString[range.location-1] == "\n") {
                    ongoingTextFormatter = OnGoingTextFormatterModel(range: NSRange(location: editLocation, length: 1), textFormatter: textFormatter)
                    textFormatter.search(string: "") { listItem in
                        if listItem.isEmpty {
                            self.endOnGoingTextFormatting()
                        } else {
                            self.update(suggestionItems: listItem)
                        }
                    }
                }
                
            } else if let onGoingTextFormatter = ongoingTextFormatter { ///if not found then checking for onGoingTextFormatter and updating it
               
                let changeIsWithInRange = NSLocationInRange(range.location, onGoingTextFormatter.range) && NSLocationInRange(range.upperBound, onGoingTextFormatter.range)
                
                //Checking if the new change is within onGoingTextFormatter's range
                if changeIsWithInRange ||
                    range.location == onGoingTextFormatter.range.location + onGoingTextFormatter.range.length ||
                    (text == "" && (changeIsWithInRange || 
                                    range.location == onGoingTextFormatter.range.location + onGoingTextFormatter.range.length - 1)
                    ) {
                    
                    //if backspaces is pressed on the onGoingTextFormatter's TriggerKey then ending the endOnGoingTextFormatter
                    if text == "" && (oldText as NSString).substring(with: range) == "\(onGoingTextFormatter.textFormatter.getTrackingCharacter())" {
                        endOnGoingTextFormatting()
                    }
                    
                    //if the new added text is in the last of onGoingTextFormatter
                    if range.location == onGoingTextFormatter.range.location + onGoingTextFormatter.range.length {
                        
                        if text == "" { //check for backSpace
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
                        
                    } else { //if the new text added is in middle of the ongoing onGoingTextFormatter
                        
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
    
    //We are doing this because iOS has a way of removing a group of characters at once, it manly adjust the spacing around the removed text
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
    
    // COMMENTED OUT - Rich text formatting disabled for MessageComposer
    // /// Updates the toolbar to show active formats at current cursor position
    // func updateToolbarActiveFormats() {
    //     guard let selectedRange = textView.selectedTextRange else { return }
    //     
    //     let start = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
    //     let length = textView.offset(from: selectedRange.start, to: selectedRange.end)
    //     let range = NSRange(location: start, length: max(1, length))
    //     
    //     let activeFormats = RichTextFormatterManager.shared.detectActiveFormats(
    //         in: textView.attributedText ?? NSAttributedString(),
    //         at: range
    //     )
    //     
    //     // Also check list modes and persistent formats
    //     var formats = activeFormats
    //     if RichTextFormatterManager.shared.isInBulletListMode {
    //         formats.insert(.bulletList)
    //     }
    //     if RichTextFormatterManager.shared.isInNumberedListMode {
    //         formats.insert(.numberedList)
    //     }
    //     if RichTextFormatterManager.shared.isInBlockquoteMode {
    //         formats.insert(.blockquote)
    //     }
    //     if RichTextFormatterManager.shared.isInCodeBlockMode {
    //         formats.insert(.codeBlock)
    //     }
    //     
    //     // Include persistent formats (formats that will be applied to new text)
    //     formats.formUnion(RichTextFormatterManager.shared.persistentFormats)
    //     
    //     richTextToolbar.setActiveFormats(formats)
    // }
    
}

// COMMENTED OUT - Rich text formatting disabled for MessageComposer
// // MARK: - Rich Text Formatting
// extension CometChatMessageComposer {
//     
//     /// Applies the selected format from the rich text toolbar
//     func applyFormat(_ format: FormatType) {
//         guard let selectedRange = textView.selectedTextRange else { return }
//         
//         let start = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
//         let length = textView.offset(from: selectedRange.start, to: selectedRange.end)
//         let range = NSRange(location: start, length: length)
//         
//         let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
//         
//         // Handle link format - show alert dialog for text and URL input
//         if format == .link {
//             showAddLinkAlert(at: range)
//             return
//         }
//         
//         // Handle list formats differently - they work at cursor position
//         if format == .bulletList || format == .numberedList {
//             RichTextFormatterManager.shared.applyFormat(format, to: range, in: attributedString, baseFont: style.textFiledFont)
//             textView.attributedText = attributedString
//             
//             // Move cursor to end of inserted prefix
//             let lineInfo = getLineInfo(at: start, in: attributedString.string)
//             var newCursorPosition = lineInfo.start
//             
//             if format == .bulletList {
//                 newCursorPosition += 2 // "• " length
//             } else if format == .numberedList {
//                 newCursorPosition += 3 // "1. " length
//             }
//             
//             // Add the original offset within the line
//             newCursorPosition += (start - lineInfo.start)
//             
//             if let newPosition = textView.position(from: textView.beginningOfDocument, offset: min(newCursorPosition, attributedString.length)) {
//                 textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//             }
//             
//             updateToolbarActiveFormats()
//             updateSendButtonState()
//             return
//         }
//         
//         // Handle blockquote - applies to current line with left border visual
//         if format == .blockquote {
//             RichTextFormatterManager.shared.applyFormat(format, to: range, in: attributedString, baseFont: style.textFiledFont)
//             textView.attributedText = attributedString
//             
//             // Move cursor after the blockquote prefix "▎ "
//             let newCursorPosition = start + 2  // "▎ " is 2 characters
//             if let newPosition = textView.position(from: textView.beginningOfDocument, offset: min(newCursorPosition, attributedString.length)) {
//                 textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//             }
//             
//             // Set typing attributes for blockquote text (secondary color)
//             if RichTextFormatterManager.shared.isInBlockquoteMode {
//                 textView.typingAttributes = [
//                     .font: style.textFiledFont,
//                     .foregroundColor: UIColor.secondaryLabel
//                 ]
//             }
//             
//             updateToolbarActiveFormats()
//             updateSendButtonState()
//             return
//         }
//         
//         // Handle code block - block-level format
//         if format == .codeBlock {
//             // Toggle off if already in code block mode
//             if RichTextFormatterManager.shared.isInCodeBlockMode {
//                 RichTextFormatterManager.shared.isInCodeBlockMode = false
//                 codeBlockBackgroundView.isHidden = true
//                 RichTextFormatterManager.shared.persistentFormats.remove(.codeBlock)
//                 textView.typingAttributes = [
//                     .font: style.textFiledFont,
//                     .foregroundColor: style.textFiledColor
//                 ]
//                 updateToolbarActiveFormats()
//                 updateSendButtonState()
//                 return
//             }
//             
//             // Enter code block mode
//             RichTextFormatterManager.shared.isInBulletListMode = false
//             RichTextFormatterManager.shared.isInNumberedListMode = false
//             RichTextFormatterManager.shared.isInBlockquoteMode = false
//             RichTextFormatterManager.shared.currentListNumber = 1
//             RichTextFormatterManager.shared.isInCodeBlockMode = true
//             
//             let monoFont = UIFont.monospacedSystemFont(ofSize: style.textFiledFont.pointSize, weight: .regular)
//             let codeBlockBgColor = CometChatTheme.neutralColor300
//             
//             // Case 1: Text is selected - apply inline code styling to selected text only
//             if length > 0 {
//                 attributedString.addAttribute(.font, value: monoFont, range: range)
//                 attributedString.addAttribute(.backgroundColor, value: codeBlockBgColor, range: range)
//                 textView.attributedText = attributedString
//                 
//                 // Restore cursor position after selection
//                 if let newPosition = textView.position(from: textView.beginningOfDocument, offset: start + length) {
//                     textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//                 }
//                 
//                 // Don't show full background - using inline styling
//                 codeBlockBackgroundView.isHidden = true
//             }
//             // Case 2: No selection, but has existing text - insert newline and start code block on new line
//             else if attributedString.length > 0 {
//                 let newlineAttr = NSAttributedString(string: "\n", attributes: [
//                     .font: style.textFiledFont,
//                     .foregroundColor: style.textFiledColor
//                 ])
//                 attributedString.insert(newlineAttr, at: start)
//                 textView.attributedText = attributedString
//                 
//                 // Move cursor after newline
//                 let newCursorPosition = start + 1
//                 if let newPosition = textView.position(from: textView.beginningOfDocument, offset: newCursorPosition) {
//                     textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//                 }
//                 
//                 // Don't show full background - new code will use inline styling
//                 codeBlockBackgroundView.isHidden = true
//             }
//             // Case 3: Empty text view - show full background container
//             else {
//                 codeBlockBackgroundView.isHidden = false
//             }
//             
//             // Set typing attributes for code block mode (with inline background)
//             textView.typingAttributes = [
//                 .font: monoFont,
//                 .foregroundColor: CometChatTheme.neutralColor900,
//                 .backgroundColor: codeBlockBgColor
//             ]
//             
//             updateToolbarActiveFormats()
//             updateSendButtonState()
//             return
//         }
//         
//         // For inline formats without selection, toggle persistent format for future typing
//         if length == 0 {
//             RichTextFormatterManager.shared.togglePersistentFormat(format)
//             // Update typing attributes to reflect persistent formats
//             textView.typingAttributes = RichTextFormatterManager.shared.getTypingAttributes(
//                 baseFont: style.textFiledFont,
//                 baseColor: style.textFiledColor
//             )
//             updateToolbarActiveFormats()
//             return
//         }
//         
//         // Check if format is already active
//         let activeFormats = RichTextFormatterManager.shared.detectActiveFormats(in: attributedString, at: range)
//         
//         if activeFormats.contains(format) {
//             // Remove format
//             RichTextFormatterManager.shared.removeFormat(format, from: range, in: attributedString, baseFont: style.textFiledFont)
//         } else {
//             // Apply format
//             RichTextFormatterManager.shared.applyFormat(format, to: range, in: attributedString, baseFont: style.textFiledFont)
//         }
//         
//         textView.attributedText = attributedString
//         
//         // Restore selection
//         if let newStart = textView.position(from: textView.beginningOfDocument, offset: start),
//            let newEnd = textView.position(from: newStart, offset: length) {
//             textView.selectedTextRange = textView.textRange(from: newStart, to: newEnd)
//         }
//         
//         updateToolbarActiveFormats()
//         updateSendButtonState()
//     }
//     
//     /// Shows a native iOS alert dialog for adding a link with text and URL fields
//     private func showAddLinkAlert(at range: NSRange) {
//         let alert = UIAlertController(
//             title: "ADD LINK".localize(),
//             message: nil,
//             preferredStyle: .alert
//         )
//         
//         // Get selected text if any to pre-fill the text field
//         var selectedText = ""
//         if range.length > 0, let attributedText = textView.attributedText {
//             selectedText = (attributedText.string as NSString).substring(with: range)
//         }
//         
//         // Add text field for display text
//         alert.addTextField { textField in
//             textField.placeholder = "ENTER TEXT".localize()
//             textField.text = selectedText
//             textField.autocapitalizationType = .sentences
//             textField.clearButtonMode = .whileEditing
//         }
//         
//         // Add text field for URL
//         alert.addTextField { textField in
//             textField.placeholder = "ENTER LINK URL".localize()
//             textField.keyboardType = .URL
//             textField.autocapitalizationType = .none
//             textField.autocorrectionType = .no
//             textField.clearButtonMode = .whileEditing
//         }
//         
//         // Cancel action
//         let cancelAction = UIAlertAction(title: "CANCEL".localize(), style: .cancel) { [weak self] _ in
//             self?.textView.becomeFirstResponder()
//         }
//         
//         // Save action
//         let saveAction = UIAlertAction(title: "SAVE".localize(), style: .default) { [weak self] _ in
//             guard let self = self else { return }
//             
//             let displayText = alert.textFields?[0].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//             let urlString = alert.textFields?[1].text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
//             
//             // Validate inputs
//             guard !displayText.isEmpty, !urlString.isEmpty else {
//                 self.textView.becomeFirstResponder()
//                 return
//             }
//             
//             // Add https:// prefix if no scheme is provided
//             var finalURLString = urlString
//             if !urlString.lowercased().hasPrefix("http://") && !urlString.lowercased().hasPrefix("https://") {
//                 finalURLString = "https://" + urlString
//             }
//             
//             // Insert the link into the text view
//             self.insertLink(displayText: displayText, url: finalURLString, at: range)
//             self.textView.becomeFirstResponder()
//         }
//         
//         alert.addAction(cancelAction)
//         alert.addAction(saveAction)
//         
//         // Present the alert
//         controller?.present(alert, animated: true)
//     }
//     
//     /// Inserts a formatted link into the text view at the specified range
//     private func insertLink(displayText: String, url: String, at range: NSRange) {
//         let attributedString = NSMutableAttributedString(attributedString: textView.attributedText ?? NSAttributedString())
//         
//         // Create link attributes
//         let linkAttributes: [NSAttributedString.Key: Any] = [
//             .font: style.textFiledFont,
//             .foregroundColor: UIColor.systemBlue,
//             .underlineStyle: NSUnderlineStyle.single.rawValue,
//             .link: url
//         ]
//         
//         let linkAttributedString = NSAttributedString(string: displayText, attributes: linkAttributes)
//         
//         // Replace or insert the link
//         if range.length > 0 {
//             attributedString.replaceCharacters(in: range, with: linkAttributedString)
//         } else {
//             attributedString.insert(linkAttributedString, at: range.location)
//         }
//         
//         // Add a space after the link with normal attributes
//         let spaceAttributes: [NSAttributedString.Key: Any] = [
//             .font: style.textFiledFont,
//             .foregroundColor: style.textFiledColor
//         ]
//         let spaceString = NSAttributedString(string: " ", attributes: spaceAttributes)
//         let insertPosition = range.location + displayText.count
//         if insertPosition <= attributedString.length {
//             attributedString.insert(spaceString, at: insertPosition)
//         } else {
//             attributedString.append(spaceString)
//         }
//         
//         textView.attributedText = attributedString
//         
//         // Move cursor after the link and space
//         let newCursorPosition = range.location + displayText.count + 1
//         if let newPosition = textView.position(from: textView.beginningOfDocument, offset: min(newCursorPosition, attributedString.length)) {
//             textView.selectedTextRange = textView.textRange(from: newPosition, to: newPosition)
//         }
//         
//         // Reset typing attributes to normal
//         textView.typingAttributes = [
//             .font: style.textFiledFont,
//             .foregroundColor: style.textFiledColor
//         ]
//         
//         updateSendButtonState()
//     }
//     
//     /// Gets line information (start and end indices) for the line containing the given position
//     private func getLineInfo(at position: Int, in text: String) -> (start: Int, end: Int) {
//         let nsString = text as NSString
//         var lineStart = position
//         var lineEnd = position
//         
//         // Find line start
//         while lineStart > 0 && nsString.character(at: lineStart - 1) != 10 { // 10 is newline
//             lineStart -= 1
//         }
//         
//         // Find line end
//         while lineEnd < nsString.length && nsString.character(at: lineEnd) != 10 {
//             lineEnd += 1
//         }
//         
//         return (lineStart, lineEnd)
//     }
// }


//Helper for TextFormatter
extension String {
    subscript(i: Int) -> String {
        let nsString = self as NSString
        let idx1 = i
        let idx2 = i + 1
        let range = NSRange(location: idx1, length: max(0, min(nsString.length - idx1, idx2 - idx1)))
        return nsString.substring(with: range)
    }
}

internal let composerSpaceManageSpacialCharacter = [
    "@": true,
    "#": true,
    "%": true,
    "!": true,
    "&": true,
    "*": true,
    "(": true,
    ")": true,
    "-": true,
    ".": true,
    ":": true,
    ";": true,
    "'": true,
    "{": true,
    "}": true,
    "[": true,
    "]": true,
    "/": true,
    ",": true,
    "?": true,
]

