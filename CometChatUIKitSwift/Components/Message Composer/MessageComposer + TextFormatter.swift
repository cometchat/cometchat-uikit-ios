//
//  MessageComposer + TextFormatter.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 07/03/24.
//

import UIKit
import Foundation

extension CometChatMessageComposer: UITextViewDelegate {
    
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        remove(footerView: true)
        return true
    }
    
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }

            //--- START: Managing typing ---//
            if  !this.disableTypingEvents && this.viewModel.checkBlockedStatus() != true {
                this.viewModel.startTyping()
                this.typingWorkItem?.cancel()
                this.typingWorkItem = DispatchWorkItem(block: {
                    this.viewModel.endTyping()
                })
                DispatchQueue.global().asyncAfter(deadline: .now() + 1.5 , execute: this.typingWorkItem!)
            }
            //--- END: Managing typing ---//
            
            if textView.text.isEmpty {
                if this.viewModel.checkBlockedStatus() != true {
                    this.viewModel.endTyping()
                }
                this.sendButton.backgroundColor = this.style.inactiveSendButtonImageBackgroundColor
                this.sendButton.isEnabled = false
            } else {
                this.sendButton.backgroundColor = this.style.activeSendButtonImageBackgroundColor
                this.sendButton.isEnabled = true
            }
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
        
        let updatedString = (textView.text as NSString?)?.replacingCharacters(in: range, with: text)
        let editLocation = range.location
        let oldText = textView.text! as NSString
        let oldString = textView.text!
        
        textView.typingAttributes = [.font: style.textFiledFont, .foregroundColor: style.textFiledColor]
        
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
    
}


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

