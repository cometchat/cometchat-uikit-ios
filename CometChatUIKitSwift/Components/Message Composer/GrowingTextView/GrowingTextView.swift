//
//  GrowingTextView.swift
//  CometChat

import Foundation
import UIKit

@objc public protocol GrowingTextViewDelegate: UITextViewDelegate {
    @objc optional func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat)
}

@IBDesignable
open class GrowingTextView: UITextView {
    override open var text: String! {
        didSet { setNeedsDisplay() }
    }
    
    override open var attributedText: NSAttributedString! {
        didSet {
            setNeedsDisplay()
        }
    }
    private var heightConstraint: NSLayoutConstraint?
    
    // Maximum length of text. 0 means no limit.
    @IBInspectable open var maxLength: Int = 0
    
    // Trim white space and newline characters when1 end editing. Default is true
    @IBInspectable open var trimWhiteSpaceWhenEndEditing: Bool = true
    
    // Customization
    @IBInspectable open var minHeight: CGFloat = 0 {
        didSet { forceLayoutSubviews() }
    }
    @IBInspectable open var maxLine: Int = 0 {
        didSet { forceLayoutSubviews() }
    }
    @IBInspectable open var maxHeight: CGFloat = 0 {
        didSet { forceLayoutSubviews() }
    }
    @IBInspectable open var placeholder: String? {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable open var placeholderColor: UIColor = UIColor(white: 0.8, alpha: 1.0) {
        didSet { setNeedsDisplay() }
    }
    @IBInspectable open var placeholderFont: UIFont = .systemFont(ofSize: 12) {
        didSet { setNeedsDisplay() }
    }
    open var attributedPlaceholder: NSAttributedString? {
        didSet { setNeedsDisplay() }
    }
    
    /// Whether to hide the placeholder (used when in code block mode)
    open var hidePlaceholder: Bool = false {
        didSet { setNeedsDisplay() }
    }
    
    // MARK: - Formatting Menu Support
    
    /// Callback for when a formatting action is selected from the context menu
    public var onFormatAction: ((FormatType) -> Void)?
    
    /// Whether to show formatting options in the context menu
    public var showFormattingMenu: Bool = true
    
    /// Callback to get the currently active formats for filtering the context menu
    public var getActiveFormats: (() -> Set<FormatType>)?
    
    /// Callback for when delete/backspace is pressed (even when text is empty)
    public var onDeleteBackward: (() -> Void)?
    
    // Override deleteBackward to detect backspace even when text is empty
    open override func deleteBackward() {
        // Call the callback before performing the delete
        onDeleteBackward?()
        
        // Perform the default delete behavior
        super.deleteBackward()
    }
    
    // Initialize
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        contentMode = .redraw
        associateConstraints()
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: self)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidEndEditing), name: UITextView.textDidEndEditingNotification, object: self)
    }
    
    // MARK: - Context Menu Actions
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // Allow our custom formatting actions when text is selected
        if showFormattingMenu && selectedRange.length > 0 {
            let formattingActions: [Selector] = [
                #selector(formatBold),
                #selector(formatItalic),
                #selector(formatUnderline),
                #selector(formatStrikethrough),
                #selector(formatCode)
            ]
            if formattingActions.contains(action) {
                return true
            }
        }
        
        // Allow default actions
        return super.canPerformAction(action, withSender: sender)
    }
    
    open override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        guard showFormattingMenu else { return }
        
        // Get active formats from the callback (if provided)
        let activeFormats = getActiveFormats?() ?? []
        
        // Use the compatibility engine to determine which formats should be disabled
        let compatibilityEngine = FormatCompatibilityEngine()
        let disabledFormats = compatibilityEngine.getDisabledFormats(for: activeFormats)
        
        // Create formatting menu items, filtering out incompatible formats
        var menuActions: [UIAction] = []
        
        // Bold
        if !disabledFormats.contains(.bold) {
            let boldAction = UIAction(title: "Bold", image: UIImage(systemName: "bold")) { [weak self] _ in
                self?.formatBold()
            }
            menuActions.append(boldAction)
        }
        
        // Italic
        if !disabledFormats.contains(.italic) {
            let italicAction = UIAction(title: "Italic", image: UIImage(systemName: "italic")) { [weak self] _ in
                self?.formatItalic()
            }
            menuActions.append(italicAction)
        }
        
        // Underline
        if !disabledFormats.contains(.underline) {
            let underlineAction = UIAction(title: "Underline", image: UIImage(systemName: "underline")) { [weak self] _ in
                self?.formatUnderline()
            }
            menuActions.append(underlineAction)
        }
        
        // Strikethrough
        if !disabledFormats.contains(.strikethrough) {
            let strikethroughAction = UIAction(title: "Strikethrough", image: UIImage(systemName: "strikethrough")) { [weak self] _ in
                self?.formatStrikethrough()
            }
            menuActions.append(strikethroughAction)
        }
        
        // Inline Code
        if !disabledFormats.contains(.code) {
            let codeAction = UIAction(title: "Code", image: UIImage(systemName: "chevron.left.forwardslash.chevron.right")) { [weak self] _ in
                self?.formatCode()
            }
            menuActions.append(codeAction)
        }
        
        // Only create and insert the Format menu if there are compatible actions
        if !menuActions.isEmpty {
            let formatMenu = UIMenu(
                title: "Format",
                image: UIImage(systemName: "textformat"),
                identifier: UIMenu.Identifier("com.cometchat.format"),
                options: [],
                children: menuActions
            )
            
            // Insert after the standard edit menu
            builder.insertSibling(formatMenu, afterMenu: .standardEdit)
        }
    }
    
    @objc open func formatBold() {
        onFormatAction?(.bold)
    }
    
    @objc open func formatItalic() {
        onFormatAction?(.italic)
    }
    
    @objc open func formatUnderline() {
        onFormatAction?(.underline)
    }
    
    @objc open func formatStrikethrough() {
        onFormatAction?(.strikethrough)
    }
    
    @objc open func formatCode() {
        onFormatAction?(.code)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // Override paste to handle markdown formatting when enabled
    open override func paste(_ sender: Any?) {
        // First, check if there's RTF data on the pasteboard (attributed text)
        if let rtfData = UIPasteboard.general.data(forPasteboardType: "public.rtf"),
           let attributedString = try? NSAttributedString(data: rtfData, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil) {
            // Check if the attributed text has code formatting (monospace font)
            let hasCodeFormatting = checkForCodeFormatting(in: attributedString)
            
            if hasCodeFormatting {
                // Convert attributed text back to markdown and let delegate handle it
                let markdown = convertAttributedTextToMarkdown(attributedString)
                let selectedRange = self.selectedRange
                
                if let textViewDelegate = self.delegate,
                   !(textViewDelegate.textView?(self, shouldChangeTextIn: selectedRange, replacementText: markdown) ?? false) {
                    // Delegate handled the paste
                    return
                }
            }
        }
        
        if let pasteboardString = UIPasteboard.general.string {
            // Check if delegate wants to handle the paste (for markdown formatting)
            let selectedRange = self.selectedRange
            if let textViewDelegate = self.delegate,
               !(textViewDelegate.textView?(self, shouldChangeTextIn: selectedRange, replacementText: pasteboardString) ?? false) {
                // Delegate handled the paste
                return
            }
            
            // Default behavior: Insert plain text at current position, preserving current typing attributes
            let currentAttributes = self.typingAttributes
            self.insertText(pasteboardString)
            self.typingAttributes = currentAttributes
        }
    }
    
    /// Checks if attributed string contains code formatting (monospace font)
    private func checkForCodeFormatting(in attributedString: NSAttributedString) -> Bool {
        var hasCodeFormatting = false
        let fullRange = NSRange(location: 0, length: attributedString.length)
        
        attributedString.enumerateAttribute(.font, in: fullRange, options: []) { value, _, stop in
            if let font = value as? UIFont {
                let fontName = font.fontName.lowercased()
                if fontName.contains("mono") || fontName.contains("courier") || fontName.contains("menlo") {
                    hasCodeFormatting = true
                    stop.pointee = true
                }
            }
        }
        
        return hasCodeFormatting
    }
    
    /// Converts attributed text with formatting back to markdown
    private func convertAttributedTextToMarkdown(_ attributedString: NSAttributedString) -> String {
        var result = ""
        let fullRange = NSRange(location: 0, length: attributedString.length)
        
        // Track code regions
        var rawCodeRegions: [(start: Int, end: Int)] = []
        var currentCodeStart: Int? = nil
        
        attributedString.enumerateAttribute(.font, in: fullRange, options: []) { value, range, _ in
            let isCode: Bool
            if let font = value as? UIFont {
                let fontName = font.fontName.lowercased()
                isCode = fontName.contains("mono") || fontName.contains("courier") || fontName.contains("menlo")
            } else {
                isCode = false
            }
            
            if isCode {
                if currentCodeStart == nil {
                    currentCodeStart = range.location
                }
            } else {
                if let start = currentCodeStart {
                    rawCodeRegions.append((start: start, end: range.location))
                    currentCodeStart = nil
                }
            }
        }
        
        // Handle code region at the end
        if let start = currentCodeStart {
            rawCodeRegions.append((start: start, end: attributedString.length))
        }
        
        // Merge adjacent code regions
        var codeRegions: [(start: Int, end: Int)] = []
        for region in rawCodeRegions {
            if let lastRegion = codeRegions.last, lastRegion.end == region.start {
                // Merge with the last region
                codeRegions[codeRegions.count - 1] = (start: lastRegion.start, end: region.end)
            } else {
                codeRegions.append(region)
            }
        }
        
        // Build result with markdown
        var currentIndex = 0
        
        for region in codeRegions {
            // Add non-code text before this region
            if region.start > currentIndex {
                let nonCodeRange = NSRange(location: currentIndex, length: region.start - currentIndex)
                let nonCodeText = (attributedString.string as NSString).substring(with: nonCodeRange)
                result += nonCodeText
            }
            
            // Add code region with markdown
            let codeRange = NSRange(location: region.start, length: region.end - region.start)
            let codeText = (attributedString.string as NSString).substring(with: codeRange)
            
            if codeText.contains("\n") {
                // Multi-line code block
                result += "```\n\(codeText)\n```"
            } else {
                // Inline code
                result += "`\(codeText)`"
            }
            
            currentIndex = region.end
        }
        
        // Add remaining non-code text
        if currentIndex < attributedString.length {
            let remainingRange = NSRange(location: currentIndex, length: attributedString.length - currentIndex)
            let remainingText = (attributedString.string as NSString).substring(with: remainingRange)
            result += remainingText
        }
        
        // If no code regions, return plain text
        if codeRegions.isEmpty {
            result = attributedString.string
        }
        
        return result
    }
    
    open override var intrinsicContentSize: CGSize {
        let size = sizeThatFits(CGSize(width: bounds.width > 0 ? bounds.width : UIView.layoutFittingCompressedSize.width, height: CGFloat.greatestFiniteMagnitude))
        var height = size.height
        
        // Constrain minimum height
        height = minHeight > 0 ? max(height, minHeight) : height
        
        // Constrain maximum height
        height = maxHeight > 0 ? min(height, maxHeight) : height
        
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }
    
    private func associateConstraints() {
        // iterate through all text view's constraints and identify
        // height,from: https://github.com/legranddamien/MBAutoGrowingTextView
        for constraint in constraints {
            if constraint.firstAttribute == .height && constraint.relation == .equal {
                heightConstraint = constraint
            }
        }
    }
    
    // Calculate and adjust textview's height
    private var oldText: String = ""
    private var oldSize: CGSize = .zero
    
    private func forceLayoutSubviews() {
        oldSize = .zero
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    private var shouldScrollAfterHeightChanged = false
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        if text == oldText && bounds.size == oldSize { return }
        oldText = text
        oldSize = bounds.size
        
        self.textContainer.maximumNumberOfLines = maxLine
        
        let size = sizeThatFits(CGSize(width: bounds.size.width, height: CGFloat.greatestFiniteMagnitude))
        var height = size.height
        
        // Constrain minimum height
        height = minHeight > 0 ? max(height, minHeight) : height
        
        // Constrain maximum height
        height = maxHeight > 0 ? min(height, maxHeight) : height
        
        // Add height constraint if it is not found
        if heightConstraint == nil {
            heightConstraint = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: height)
            addConstraint(heightConstraint!)
        }
        
        // Update height constraint if needed
        if height != heightConstraint!.constant {
            shouldScrollAfterHeightChanged = true
            heightConstraint!.constant = height
            invalidateIntrinsicContentSize()
            if let delegate = delegate as? GrowingTextViewDelegate {
                delegate.textViewDidChangeHeight?(self, height: height)
            }
        } else if shouldScrollAfterHeightChanged {
            shouldScrollAfterHeightChanged = false
            scrollToCorrectPosition()
        }
    }
    
    private func scrollToCorrectPosition() {
        if self.isFirstResponder {
            self.scrollRangeToVisible(NSRange(location: -1, length: 0)) // Scroll to bottom
        } else {
            self.scrollRangeToVisible(NSRange(location: 0, length: 0)) // Scroll to top
        }
    }
    
    // Show placeholder if needed
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Don't show placeholder if hidePlaceholder is true (e.g., in code block mode)
        if text.isEmpty && !hidePlaceholder {
            let xValue = textContainerInset.left + textContainer.lineFragmentPadding
            let yValue = textContainerInset.top
            let width = rect.size.width - xValue - textContainerInset.right
            let height = rect.size.height - yValue - textContainerInset.bottom
            let placeholderRect = CGRect(x: xValue, y: yValue, width: width, height: height)
            
            if let attributedPlaceholder = attributedPlaceholder {
                // Prefer to use attributedPlaceholder
                attributedPlaceholder.draw(in: placeholderRect)
            } else if let placeholder = placeholder {
                // Otherwise user placeholder and inherit `text` attributes
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = textAlignment
                var attributes: [NSAttributedString.Key: Any] = [
                    .foregroundColor: placeholderColor,
                    .paragraphStyle: paragraphStyle,
                    .font: placeholderFont
                ]
                if let font = font {
                    attributes[.font] = font
                }
                
                placeholder.draw(in: placeholderRect, withAttributes: attributes)
            }
        }
    }
    
    // Trim white space and new line characters when end editing.
    @objc func textDidEndEditing(notification: Notification) {
        if let sender = notification.object as? GrowingTextView, sender == self {
            if trimWhiteSpaceWhenEndEditing {
                // Preserve attributed text formatting when trimming
                if let currentAttributedText = attributedText, currentAttributedText.length > 0 {
                    let trimmedString = currentAttributedText.string.trimmingCharacters(in: .whitespacesAndNewlines)
                    if trimmedString.count != currentAttributedText.length {
                        // Find the range to keep (trimmed range)
                        let originalString = currentAttributedText.string as NSString
                        var startIndex = 0
                        var endIndex = originalString.length
                        
                        // Find start index (skip leading whitespace)
                        while startIndex < originalString.length {
                            let char = originalString.character(at: startIndex)
                            if let scalar = UnicodeScalar(char), !CharacterSet.whitespacesAndNewlines.contains(scalar) {
                                break
                            }
                            startIndex += 1
                        }
                        
                        // Find end index (skip trailing whitespace)
                        while endIndex > startIndex {
                            let char = originalString.character(at: endIndex - 1)
                            if let scalar = UnicodeScalar(char), !CharacterSet.whitespacesAndNewlines.contains(scalar) {
                                break
                            }
                            endIndex -= 1
                        }
                        
                        // Create new attributed string with trimmed range
                        if startIndex < endIndex {
                            let trimmedRange = NSRange(location: startIndex, length: endIndex - startIndex)
                            attributedText = currentAttributedText.attributedSubstring(from: trimmedRange)
                        } else {
                            attributedText = NSAttributedString(string: "")
                        }
                    }
                } else {
                    text = text?.trimmingCharacters(in: .whitespacesAndNewlines)
                }
                setNeedsDisplay()
            }
            scrollToCorrectPosition()
        }
    }
    
    // Limit the length of text
    @objc func textDidChange(notification: Notification) {
        if let sender = notification.object as? GrowingTextView, sender == self {
            if maxLength > 0 && text.count > maxLength {
                let endIndex = text.index(text.startIndex, offsetBy: maxLength)
                text = String(text[..<endIndex])
                undoManager?.removeAllActions()
            }
            setNeedsDisplay()
        }
    }
}
