//
//  GrowingInternalTextView.swift
//  GrowingTextView
//
//  Created by Xin Hong on 16/2/16.
//  Copyright © 2016年 Teambition. All rights reserved.
//

import UIKit

internal class GrowingInternalTextView: UITextView, NSCopying {
    var placeholder: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    var shouldDisplayPlaceholder = true {
        didSet {
            if shouldDisplayPlaceholder != oldValue {
                setNeedsDisplay()
            }
        }
    }
    var isCaretHidden = false

    fileprivate var isScrollEnabledTemp = false

    override var text: String! {
        willSet {
            // If one of GrowingTextView's superviews is a scrollView, and self.scrollEnabled is false, setting the text programatically will cause UIKit to search upwards until it finds a scrollView with scrollEnabled true, then scroll it erratically. Setting scrollEnabled temporarily to true prevents this.
            isScrollEnabledTemp = isScrollEnabled
            isScrollEnabled = true
        }
        didSet {
            isScrollEnabled = isScrollEnabledTemp
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        guard let placeholder = placeholder, shouldDisplayPlaceholder else {
            return
        }
        let placeholderSize = sizeForAttributedString(placeholder)
        let xPosition: CGFloat = textContainer.lineFragmentPadding + textContainerInset.left
        let yPosition: CGFloat = (textContainerInset.top - textContainerInset.bottom) / 2
        let rect = CGRect(origin: CGPoint(x: xPosition, y: yPosition), size: placeholderSize)
        placeholder.draw(in: rect)
    }

    override func caretRect(for position: UITextPosition) -> CGRect {
        if isCaretHidden {
            return .zero
        }
        return super.caretRect(for: position)
    }

    func copy(with zone: NSZone?) -> Any {
        let textView = GrowingInternalTextView(frame: frame)
        textView.isScrollEnabled = isScrollEnabled
        textView.shouldDisplayPlaceholder = shouldDisplayPlaceholder
        textView.isCaretHidden = isCaretHidden
        textView.placeholder = placeholder
        textView.text = text
        textView.font = font
        textView.textColor = textColor
        textView.textAlignment = textAlignment
        textView.isEditable = isEditable
        textView.selectedRange = selectedRange
        textView.dataDetectorTypes = dataDetectorTypes
        textView.returnKeyType = returnKeyType
        textView.keyboardType = keyboardType
        textView.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically

        textView.textContainerInset = textContainerInset
        textView.textContainer.lineFragmentPadding = textContainer.lineFragmentPadding
        textView.showsHorizontalScrollIndicator = showsHorizontalScrollIndicator
        textView.contentInset = contentInset
        textView.contentMode = contentMode

        return textView
    }

    fileprivate func sizeForAttributedString(_ attributedString: NSAttributedString) -> CGSize {
        let size = attributedString.size()
        return CGRect(origin: .zero, size: size).integral.size
    }
}
