//
//  GrowingTextView.swift
//  GrowingTextView
//
//  Created by Xin Hong on 16/2/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

open class GrowingTextView: UIView {
    // MARK: - Public properties
    weak var delegate: GrowingTextViewDelegate?

    open var internalTextView: UITextView {
        return textView
    }
    open var maxNumberOfLines: Int? {
        willSet {
            if let newValue = newValue {
                assert(newValue >= 0, "MaxNumberOfLines of growingTextView must be no less than 0.")
            }
        }
        didSet {
            updateMaxHeight()
        }
    }
    open var minNumberOfLines: Int? {
        willSet {
            if let newValue = newValue {
                assert(newValue >= 0, "MinNumberOfLines of growingTextView must be no less than 0.")
            }
        }
        didSet {
            updateMinHeight()
        }
    }
    open var maxHeight: CGFloat? {
        willSet {
            if let newValue = newValue {
                assert(newValue >= 0, "MaxHeight of growingTextView must be no less than 0.")
            }
        }
    }
    open var minHeight: CGFloat = 0 {
        willSet {
            assert(newValue >= 0, "MinHeight of growingTextView must be no less than 0.")
        }
    }
    /// A Boolean value that determines whether growing animations are enabled.
    ///
    /// The default value of this property is true.
    open var isGrowingAnimationEnabled = true
    /// The time duration of text view's growing animation.
    ///
    /// The default value of this property is 0.1.
    open var animationDuration: TimeInterval = 0.1
    /// The inset of the text view.
    ///
    /// The default value of this property is (top: 8, left: 5, bottom: 8, right: 5).
    open var contentInset = UIEdgeInsets(top: 15, left: 5, bottom: 15, right: 5) {
        didSet {
            updateTextViewFrame()
            updateMaxHeight()
            updateMinHeight()
        }
    }
    /// A Boolean value that determines whether scrolling is enabled.
    ///
    /// If the value of this property is true, scrolling is enabled, and if it is false, scrolling is disabled. The default is false.
    open var isScrollEnabled = false {
        didSet {
            textView.isScrollEnabled = isScrollEnabled
        }
    }
    /// A Boolean value that determines whether to display a placeholder when the text is empty.
    ///
    /// The default value of this property is true.
    open var isPlaceholderEnabled = true {
        didSet {
            textView.shouldDisplayPlaceholder = textView.text.isEmpty && isPlaceholderEnabled
        }
    }
    /// An attributed string that displays when there is no other text in the text view.
    open var placeholder: NSAttributedString? {
        set {
            textView.placeholder = newValue
        }
        get {
            return textView.placeholder
        }
    }
    /// A Boolean value that determines whether to display the caret.
    ///
    /// The default value of this property is false.
    open var isCaretHidden = false {
        didSet {
            textView.isCaretHidden = isCaretHidden
        }
    }

    // MARK: - UITextView properties
    /// The text displayed by the text view.
    open var text: String? {
        set {
            textView.text = newValue
            updateHeight()
        }
        get {
            return textView.text
        }
    }
    /// The font of the text.
    open var font: UIFont? {
        set {
            textView.font = newValue
            updateMaxHeight()
            updateMinHeight()
        }
        get {
            return textView.font
        }
    }
    /// The color of the text.
    ///
    /// This property applies to the entire text string. The default text color is black.
    open var textColor: UIColor? {
        set {
            textView.textColor = newValue
        }
        get {
            return textView.textColor
        }
    }
    /// The technique to use for aligning the text.
    ///
    /// This property applies to the entire text string. The default value of this property is NSTextAlignment.left.
    open var textAlignment: NSTextAlignment {
        set {
            textView.textAlignment = newValue
        }
        get {
            return textView.textAlignment
        }
    }
    /// A Boolean value indicating whether the receiver is editable.
    ///
    /// The default value of this property is true.
    open var isEditable: Bool {
        set {
            textView.isEditable = newValue
        }
        get {
            return textView.isEditable
        }
    }
    /// The current selection range of the receiver.
    open var selectedRange: NSRange? {
        set {
            if let newValue = newValue {
                textView.selectedRange = newValue
            }
        }
        get {
            return textView.selectedRange
        }
    }
    /// The types of data converted to clickable URLs in the text view.
    ///
    /// You can use this property to specify the types of data (phone numbers, http links, and so on) that should be automatically converted to clickable URLs in the text view. When clicked, the text view opens the application responsible for handling the URL type and passes it the URL.
    open var dataDetectorTypes: UIDataDetectorTypes {
        set {
            textView.dataDetectorTypes = newValue
        }
        get {
            return textView.dataDetectorTypes
        }
    }
    /// The visible title of the Return key.
    ///
    /// Setting this property to a different key type changes the visible title of the Return key and typically results in the keyboard being dismissed when it is pressed. The default value for this property is UIReturnKeyType.default.
    open var returnKeyType: UIReturnKeyType {
        set {
            textView.returnKeyType = newValue
        }
        get {
            return textView.returnKeyType
        }
    }
    /// The keyboard style of the text view.
    ///
    /// Text view can be targeted for specific types of input, such as plain text, email, numeric entry, and so on. The keyboard style identifies what keys are available on the keyboard and which ones appear by default. The default value for this property is UIKeyboardType.default.
    open var keyboardType: UIKeyboardType {
        set {
            textView.keyboardType = newValue
        }
        get {
            return textView.keyboardType
        }
    }
    /// A Boolean value indicating whether the Return key is automatically enabled when the user is entering text.
    ///
    /// The default value for this property is false. If you set it to true, the keyboard disables the Return key when the text entry area contains no text. As soon as the user enters some text, the Return key is automatically enabled.
    open var enablesReturnKeyAutomatically: Bool {
        set {
            textView.enablesReturnKeyAutomatically = newValue
        }
        get {
            return textView.enablesReturnKeyAutomatically
        }
    }
    /// A Boolean value indicating whether the text view currently contains any text.
    open var hasText: Bool {
        return textView.hasText
    }

    // MARK: - Private properties
    fileprivate var textView: GrowingInternalTextView = {
        let textView = GrowingInternalTextView(frame: .zero)
        textView.textContainerInset = .zero
        textView.textContainer.lineFragmentPadding = 1 // 1 pixel for caret
        textView.showsHorizontalScrollIndicator = false
        textView.contentInset = .zero
        textView.contentMode = .redraw
        return textView
    }()

    // MARK: - Initialization
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}

// MARK: - Overriding
extension GrowingTextView {
    open override var backgroundColor: UIColor? {
        didSet {
            textView.backgroundColor = backgroundColor
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        updateTextViewFrame()
        updateMaxHeight()
        updateMinHeight()
        updateHeight()
    }

    open override func sizeThatFits(_ size: CGSize) -> CGSize {
        var size = size
        if text?.count == 0 {
            size.height = minHeight
        }
        return size
    }

    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.becomeFirstResponder()
    }

    open override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()
        return textView.becomeFirstResponder()
    }

    open override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()
        return textView.resignFirstResponder()
    }

    open override var isFirstResponder: Bool {
        return textView.isFirstResponder
    }
}

// MARK: - Public
extension GrowingTextView {
    public func scrollRangeToVisible(_ range: NSRange) {
        textView.scrollRangeToVisible(range)
    }

    public func calculateHeight() -> CGFloat {
        return ceil(textView.sizeThatFits(textView.frame.size).height + contentInset.top + contentInset.bottom)
    }

    public func updateHeight() {
        let updatedHeightInfo = updatedHeight()
        let newHeight = updatedHeightInfo.newHeight
        let difference = updatedHeightInfo.difference

        if difference != 0 {
            if newHeight == maxHeight {
                if !textView.isScrollEnabled {
                    textView.isScrollEnabled = true
                    textView.flashScrollIndicators()
                }
            } else {
                textView.isScrollEnabled = isScrollEnabled
            }

            if isGrowingAnimationEnabled {
                UIView.animate(withDuration: animationDuration, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState], animations: {
                    self.updateGrowingTextView(newHeight: newHeight, difference: difference)
                    }, completion: { (_) in
                        if let delegate = self.delegate, delegate.responds(to: DelegateSelectors.didChangeHeight) {
                            delegate.growingTextView!(self, didChangeHeight: newHeight, difference: difference)
                        }
                })
            } else {
                updateGrowingTextView(newHeight: newHeight, difference: difference)

                if let delegate = delegate, delegate.responds(to: DelegateSelectors.didChangeHeight) {
                    delegate.growingTextView!(self, didChangeHeight: newHeight, difference: difference)
                }
            }
        }

        updateScrollPosition(animated: false)
        textView.shouldDisplayPlaceholder = textView.text.isEmpty && isPlaceholderEnabled
    }
}

// MARK: - Helper
extension GrowingTextView {
    fileprivate func commonInit() {
        textView.frame = CGRect(origin: .zero, size: frame.size)
        textView.delegate = self
        minNumberOfLines = 1
        addSubview(textView)
    }

    fileprivate func updateTextViewFrame() {
        let lineFragmentPadding = textView.textContainer.lineFragmentPadding
        var textViewFrame = frame
        textViewFrame.origin.x = contentInset.left - lineFragmentPadding
        textViewFrame.origin.y = contentInset.top
        textViewFrame.size.width -= contentInset.left + contentInset.right - lineFragmentPadding * 2
        textViewFrame.size.height -= contentInset.top + contentInset.bottom
        textView.frame = textViewFrame
        textView.sizeThatFits(textView.frame.size)
    }

    fileprivate func updateGrowingTextView(newHeight: CGFloat, difference: CGFloat) {
        if let delegate = delegate, delegate.responds(to: DelegateSelectors.willChangeHeight) {
            delegate.growingTextView!(self, willChangeHeight: newHeight, difference: difference)
        }
        frame.size.height = newHeight
        updateTextViewFrame()
    }

    fileprivate func updatedHeight() -> (newHeight: CGFloat, difference: CGFloat) {
        var newHeight = calculateHeight()
        if newHeight < minHeight || !hasText {
            newHeight = minHeight
        }
        if let maxHeight = maxHeight, newHeight > maxHeight {
            newHeight = maxHeight
        }
        let difference = newHeight - frame.height

        return (newHeight, difference)
    }

    fileprivate func heightForNumberOfLines(_ numberOfLines: Int) -> CGFloat {
        var text = "-"
        if numberOfLines > 0 {
            for _ in 1..<numberOfLines {
                text += "\n|W|"
            }
        }
        let textViewCopy: GrowingInternalTextView = textView.copy() as! GrowingInternalTextView
        textViewCopy.text = text
        let height = ceil(textViewCopy.sizeThatFits(textViewCopy.frame.size).height + contentInset.top + contentInset.bottom)
        return height
    }

    fileprivate func updateMaxHeight() {
        guard let maxNumberOfLines = maxNumberOfLines else {
            return
        }
        maxHeight = heightForNumberOfLines(maxNumberOfLines)
    }

    fileprivate func updateMinHeight() {
        guard let minNumberOfLines = minNumberOfLines else {
            return
        }
        minHeight = heightForNumberOfLines(minNumberOfLines)
    }

    fileprivate func updateScrollPosition(animated: Bool) {
        guard let selectedTextRange = textView.selectedTextRange else {
            return
        }
        let caretRect = textView.caretRect(for: selectedTextRange.end)
        let caretY = max(caretRect.origin.y + caretRect.height - textView.frame.height, 0)

        // Continuous multiple "\r\n" get an infinity caret rect, set it as the content offset will result in crash.
        guard caretY != CGFloat.infinity && caretY != CGFloat.greatestFiniteMagnitude else {
            print("Invalid caretY: \(caretY)")
            return
        }

        if animated {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            textView.setContentOffset(CGPoint(x: 0, y: caretY), animated: false)
            UIView.commitAnimations()
        } else {
            textView.setContentOffset(CGPoint(x: 0, y: caretY), animated: false)
        }
    }
}

// MARK: - TextView delegate
extension GrowingTextView: UITextViewDelegate {
    public func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if let delegate = delegate, delegate.responds(to: DelegateSelectors.shouldBeginEditing) {
            return delegate.growingTextViewShouldBeginEditing!(self)
        }
        return true
    }

    public func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if let delegate = delegate, delegate.responds(to: DelegateSelectors.shouldEndEditing) {
            return delegate.growingTextViewShouldEndEditing!(self)
        }
        return true
    }

    public func textViewDidBeginEditing(_ textView: UITextView) {
        if let delegate = delegate, delegate.responds(to: DelegateSelectors.didBeginEditing) {
            delegate.growingTextViewDidBeginEditing!(self)
        }
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        if let delegate = delegate, delegate.responds(to: DelegateSelectors.didEndEditing) {
            delegate.growingTextViewDidEndEditing!(self)
        }
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if !hasText && text == "" {
            return false
        }
        if let delegate = delegate, delegate.responds(to: DelegateSelectors.shouldChangeText) {
            return delegate.growingTextView!(self, shouldChangeTextInRange: range, replacementText: text)
        }

        if text == "\n" {
            if let delegate = delegate, delegate.responds(to: DelegateSelectors.shouldReturn) {
                return delegate.growingTextViewShouldReturn!(self)
            } else {
//                textView.resignFirstResponder()
                return true
            }
        }
        return true
    }

    public func textViewDidChange(_ textView: UITextView) {
        updateHeight()
        if let delegate = delegate, delegate.responds(to: DelegateSelectors.didChange) {
            delegate.growingTextViewDidChange!(self)
        }
    }

    public func textViewDidChangeSelection(_ textView: UITextView) {
        let willUpdateHeight = updatedHeight().difference != 0
        if !willUpdateHeight {
            updateScrollPosition(animated: true)
        }
        if let delegate = delegate, delegate.responds(to: DelegateSelectors.didChangeSelection) {
            delegate.growingTextViewDidChangeSelection!(self)
        }
    }
}
