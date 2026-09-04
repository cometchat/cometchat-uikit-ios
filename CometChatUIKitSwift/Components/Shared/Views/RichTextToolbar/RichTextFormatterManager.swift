//
//  RichTextFormatterManager.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 29/01/26.
//

import UIKit
import Foundation

/// Utility class for applying and removing rich text formatting
public class RichTextFormatterManager {
    
    // MARK: - Singleton
    public static let shared = RichTextFormatterManager()
    
    private init() { }
    
    // MARK: - Custom Attribute Keys
    
    /// Custom attribute key to track which formats are applied to text
    public static let formatTypeKey = NSAttributedString.Key("CometChatFormatType")
    
    /// Custom attribute key to track list type (bullet or numbered)
    public static let listTypeKey = NSAttributedString.Key("CometChatListType")
    
    /// Custom attribute key to track list item number
    public static let listNumberKey = NSAttributedString.Key("CometChatListNumber")
    
    /// Custom attribute key to mark code blocks (vs inline code)
    public static let isCodeBlockKey = NSAttributedString.Key("CometChatIsCodeBlock")
    
    /// Custom attribute key to mark blockquote content
    public static let isBlockquoteKey = NSAttributedString.Key("CometChatIsBlockquote")
    
    /// Custom attribute key to track bold formatting (independent of font traits)
    public static let isBoldKey = NSAttributedString.Key("CometChatIsBold")
    
    /// Custom attribute key to track italic formatting (independent of font traits)
    public static let isItalicKey = NSAttributedString.Key("CometChatIsItalic")
    
    // MARK: - List State Tracking
    
    /// Tracks if we're currently in a bullet list mode
    public var isInBulletListMode = false
    
    /// Tracks if we're currently in a numbered list mode
    public var isInNumberedListMode = false
    
    /// Tracks if we're currently in a blockquote mode
    public var isInBlockquoteMode = false
    
    /// Tracks if we're currently in a code block mode
    public var isInCodeBlockMode = false
    
    /// Current number for numbered list
    public var currentListNumber = 1
    
    // MARK: - Persistent Format Tracking
    
    /// Tracks formats that should be applied to new text (toggled on without selection)
    public var persistentFormats: Set<FormatType> = []
    
    // MARK: - Compatibility Engine
    
    private static var _compatibilityEngine: FormatCompatibilityEngine?
    
    /// The compatibility engine instance for evaluating format compatibility rules
    public var compatibilityEngine: FormatCompatibilityEngine {
        if RichTextFormatterManager._compatibilityEngine == nil {
            RichTextFormatterManager._compatibilityEngine = FormatCompatibilityEngine()
        }
        return RichTextFormatterManager._compatibilityEngine!
    }
    
    /// The currently active formats (aggregates all format state)
    public var activeFormats: Set<FormatType> {
        get {
            var formats = persistentFormats
            if isInBulletListMode { formats.insert(.bulletList) }
            if isInNumberedListMode { formats.insert(.numberedList) }
            if isInBlockquoteMode { formats.insert(.blockquote) }
            if isInCodeBlockMode { formats.insert(.codeBlock) }
            return formats
        }
        set {
            // Update individual state flags based on the new set
            isInBulletListMode = newValue.contains(.bulletList)
            isInNumberedListMode = newValue.contains(.numberedList)
            isInBlockquoteMode = newValue.contains(.blockquote)
            isInCodeBlockMode = newValue.contains(.codeBlock)
            
            // Update persistent formats (inline formats)
            persistentFormats = newValue.intersection([.bold, .italic, .underline, .strikethrough, .code, .link])
        }
    }
    
    /// Attempts to toggle a format, respecting compatibility rules
    /// - Parameter format: The format to toggle
    /// - Returns: True if the format was toggled, false if incompatible
    @discardableResult
    public func toggleFormat(_ format: FormatType) -> Bool {
        let currentActive = activeFormats
        
        // Check if we're trying to activate a format
        if !currentActive.contains(format) {
            // Check compatibility
            if !compatibilityEngine.isCompatible(format, with: currentActive) {
                return false  // Format is incompatible, reject toggle
            }
        }
        
        // Toggle the format
        var newActive = currentActive
        if newActive.contains(format) {
            newActive.remove(format)
        } else {
            newActive.insert(format)
        }
        
        activeFormats = newActive
        return true
    }
    
    /// Resets all format state to default
    public func resetAllFormats() {
        persistentFormats.removeAll()
        isInBulletListMode = false
        isInNumberedListMode = false
        isInBlockquoteMode = false
        isInCodeBlockMode = false
        currentListNumber = 1
    }
    
    // MARK: - Public Methods
    public func togglePersistentFormat(_ format: FormatType) {
        if persistentFormats.contains(format) {
            persistentFormats.remove(format)
        } else {
            persistentFormats.insert(format)
        }
    }
    
    /// Clears all persistent formats
    public func clearPersistentFormats() {
        persistentFormats.removeAll()
    }
    
    /// Gets typing attributes for the current persistent formats
    public func getTypingAttributes(baseFont: UIFont, baseColor: UIColor) -> [NSAttributedString.Key: Any] {
        var attributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: baseColor
        ]
        
        var currentFont = baseFont
        var traits = currentFont.fontDescriptor.symbolicTraits
        
        for format in persistentFormats {
            switch format {
            case .bold:
                traits.insert(.traitBold)
                // Add custom attribute for reliable tracking
                attributes[RichTextFormatterManager.isBoldKey] = true
            case .italic:
                traits.insert(.traitItalic)
                // Add custom attribute for reliable tracking
                attributes[RichTextFormatterManager.isItalicKey] = true
            case .underline:
                attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
            case .strikethrough:
                attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
            case .code:
                // Inline code: monospace font + background on characters
                // Explicitly set isCodeBlockKey to false to distinguish from code blocks
                currentFont = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
                attributes[.backgroundColor] = CometChatTheme.neutralColor300
                attributes[.foregroundColor] = CometChatTheme.extendedPrimaryColor700
                attributes[RichTextFormatterManager.isCodeBlockKey] = false  // Mark as inline code (NOT code block)
            case .codeBlock:
                // Code block: monospace font + inline background (same as inline code)
                // Using inline background ensures text retains styling after exiting code block mode
                currentFont = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
                attributes[.backgroundColor] = CometChatTheme.neutralColor300
                attributes[.foregroundColor] = CometChatTheme.neutralColor900
                attributes[RichTextFormatterManager.isCodeBlockKey] = true  // Mark as code block
            default:
                break
            }
        }
        
        // Apply font traits if bold or italic (but not if code is active - code uses monospace)
        if (persistentFormats.contains(.bold) || persistentFormats.contains(.italic)) && 
           !persistentFormats.contains(.code) && !persistentFormats.contains(.codeBlock) {
            if let newDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                currentFont = UIFont(descriptor: newDescriptor, size: currentFont.pointSize)
            } else {
                // Fallback: try to create font with combined traits from system font
                let systemFont = UIFont.systemFont(ofSize: baseFont.pointSize)
                if let combinedDescriptor = systemFont.fontDescriptor.withSymbolicTraits(traits) {
                    currentFont = UIFont(descriptor: combinedDescriptor, size: baseFont.pointSize)
                } else {
                    // Last resort: apply individual traits with multiple fallback attempts
                    if persistentFormats.contains(.bold) && persistentFormats.contains(.italic) {
                        // Use createBoldItalicFont for consistent behavior
                        currentFont = createBoldItalicFont(size: baseFont.pointSize)
                    } else if persistentFormats.contains(.bold) {
                        currentFont = UIFont.boldSystemFont(ofSize: baseFont.pointSize)
                    } else if persistentFormats.contains(.italic) {
                        currentFont = UIFont.italicSystemFont(ofSize: baseFont.pointSize)
                    }
                }
            }
        }
        
        attributes[.font] = currentFont
        return attributes
    }
    
    /// Checks if text contains markdown formatting syntax
    /// - Parameter text: The text to check
    /// - Returns: True if the text contains markdown formatting patterns
    public func containsMarkdownFormatting(_ text: String) -> Bool {
        // Check for common markdown patterns using simple string checks first
        // Bold: **text**
        if text.contains("**") {
            return true
        }
        // Italic: _text_ (single underscore, but not mid-word like in URLs)
        if text.range(of: "(?<![\\w/])_[^_]+_(?!\\w)", options: .regularExpression) != nil {
            return true
        }
        // Underline: <u>text</u> (HTML style only)
        if text.contains("<u>") && text.contains("</u>") {
            return true
        }
        // Strikethrough: ~~text~~
        if text.contains("~~") {
            return true
        }
        // Inline code: `text`
        if text.contains("`") {
            return true
        }
        // Link: [text](url)
        if text.contains("](") && text.contains("[") {
            return true
        }
        // Blockquote: > at start of line
        if text.hasPrefix("> ") || text.contains("\n> ") {
            return true
        }
        
        return false
    }
    
    /// Checks if text contains URLs that should be formatted as links
    /// - Parameter text: The text to check
    /// - Returns: True if the text contains URL patterns
    public func containsURLs(_ text: String) -> Bool {
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return false
        }
        let range = NSRange(location: 0, length: text.utf16.count)
        return detector.firstMatch(in: text, options: [], range: range) != nil
    }
    
    /// Applies link formatting to URLs found in the attributed string
    /// - Parameters:
    ///   - attributedString: The mutable attributed string to modify
    ///   - baseFont: The base font to use
    ///   - baseColor: The base text color
    /// - Returns: The attributed string with URLs formatted as links
    @discardableResult
    public func applyURLFormatting(
        to attributedString: NSMutableAttributedString,
        baseFont: UIFont,
        baseColor: UIColor
    ) -> NSMutableAttributedString {
        let text = attributedString.string
        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) else {
            return attributedString
        }
        
        let range = NSRange(location: 0, length: text.utf16.count)
        let matches = detector.matches(in: text, options: [], range: range)
        
        for match in matches {
            guard let url = match.url else { continue }
            
            // Apply link attributes
            attributedString.addAttribute(.link, value: url, range: match.range)
            attributedString.addAttribute(.foregroundColor, value: baseColor, range: match.range)
            attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: match.range)
        }
        
        return attributedString
    }
    
    /// Strips markdown formatting symbols from text, returning plain text
    /// - Parameter text: The markdown text to strip
    /// - Returns: Plain text without markdown symbols
    public func stripMarkdown(_ text: String) -> String {
        var result = text
        
        // Remove code blocks (```...```) - replace with just the content
        while let startRange = result.range(of: "```") {
            let afterStart = startRange.upperBound
            if let endRange = result[afterStart...].range(of: "```") {
                var content = String(result[afterStart..<endRange.lowerBound])
                // Trim leading/trailing newlines from code block content
                if content.hasPrefix("\n") { content.removeFirst() }
                if content.hasSuffix("\n") { content.removeLast() }
                result.replaceSubrange(startRange.lowerBound..<endRange.upperBound, with: content)
            } else {
                break
            }
        }
        
        // Remove inline code (`...`)
        while let startRange = result.range(of: "`") {
            let afterStart = startRange.upperBound
            if afterStart < result.endIndex, let endRange = result[afterStart...].range(of: "`") {
                let content = String(result[afterStart..<endRange.lowerBound])
                result.replaceSubrange(startRange.lowerBound..<endRange.upperBound, with: content)
            } else {
                break
            }
        }
        
        // Remove bold+italic (***...***) 
        while let startRange = result.range(of: "***") {
            let afterStart = startRange.upperBound
            if let endRange = result[afterStart...].range(of: "***") {
                let content = String(result[afterStart..<endRange.lowerBound])
                result.replaceSubrange(startRange.lowerBound..<endRange.upperBound, with: content)
            } else {
                break
            }
        }
        
        // Remove bold (**...**)
        while let startRange = result.range(of: "**") {
            let afterStart = startRange.upperBound
            if let endRange = result[afterStart...].range(of: "**") {
                let content = String(result[afterStart..<endRange.lowerBound])
                result.replaceSubrange(startRange.lowerBound..<endRange.upperBound, with: content)
            } else {
                break
            }
        }
        
        // Remove strikethrough (~~...~~)
        while let startRange = result.range(of: "~~") {
            let afterStart = startRange.upperBound
            if let endRange = result[afterStart...].range(of: "~~") {
                let content = String(result[afterStart..<endRange.lowerBound])
                result.replaceSubrange(startRange.lowerBound..<endRange.upperBound, with: content)
            } else {
                break
            }
        }
        
        // Remove italic with underscore (_..._) but not mid-word underscores (URLs)
        if let regex = try? NSRegularExpression(pattern: "(?<![\\w/])_([^_]+)_(?!\\w)", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }
        
        // Remove HTML underline (<u>...</u>)
        if let regex = try? NSRegularExpression(pattern: "<u>([^<]*)</u>", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }
        
        // Remove links [text](url) - keep just the text
        if let regex = try? NSRegularExpression(pattern: "\\[([^\\]]+)\\]\\([^)]+\\)", options: []) {
            let range = NSRange(result.startIndex..., in: result)
            result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "$1")
        }
        
        return result
    }
    
    // MARK: - Public Methods
    
    /// Applies the specified format to the text at the given range with visual styling
    /// - Parameters:
    ///   - format: The format type to apply
    ///   - range: The range of text to format
    ///   - attributedString: The mutable attributed string to modify
    ///   - baseFont: The base font to use for styling (optional)
    /// - Returns: The resulting attributed string
    @discardableResult
    public func applyFormat(
        _ format: FormatType,
        to range: NSRange,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont? = nil
    ) -> NSMutableAttributedString {
        // Call the overload with empty skip ranges
        return applyFormat(format, to: range, in: attributedString, baseFont: baseFont, skippingRanges: [])
    }
    
    /// Applies the specified format to the text at the given range, skipping certain ranges (like mentions)
    /// - Parameters:
    ///   - format: The format type to apply
    ///   - range: The range of text to format
    ///   - attributedString: The mutable attributed string to modify
    ///   - baseFont: The base font to use (optional)
    ///   - skippingRanges: Ranges to skip (e.g., mention ranges that should not be formatted)
    /// - Returns: The resulting attributed string
    @discardableResult
    public func applyFormat(
        _ format: FormatType,
        to range: NSRange,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont? = nil,
        skippingRanges: [NSRange]
    ) -> NSMutableAttributedString {
        let font = baseFont ?? UIFont.systemFont(ofSize: 17)
        
        // If there are ranges to skip, calculate the non-skip ranges and apply format to each
        if !skippingRanges.isEmpty && range.length > 0 {
            let rangesToFormat = calculateNonOverlappingRanges(from: range, excluding: skippingRanges)
            
            // Apply format to each non-mention range
            for subRange in rangesToFormat {
                applyFormatToRange(format, to: subRange, in: attributedString, baseFont: font)
            }
            
            return attributedString
        }
        
        // No ranges to skip, apply format normally
        return applyFormatToRange(format, to: range, in: attributedString, baseFont: font)
    }
    
    /// Internal method to apply format to a single range
    private func applyFormatToRange(
        _ format: FormatType,
        to range: NSRange,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont
    ) -> NSMutableAttributedString {
        switch format {
        case .bold:
            guard range.length > 0 else { return attributedString }
            applyBoldFormat(to: range, in: attributedString, baseFont: baseFont)
        case .italic:
            guard range.length > 0 else { return attributedString }
            applyItalicFormat(to: range, in: attributedString, baseFont: baseFont)
        case .underline:
            guard range.length > 0 else { return attributedString }
            applyUnderlineFormat(to: range, in: attributedString)
        case .strikethrough:
            guard range.length > 0 else { return attributedString }
            applyStrikethroughFormat(to: range, in: attributedString)
        case .code:
            guard range.length > 0 else { return attributedString }
            applyCodeFormat(to: range, in: attributedString)
        case .codeBlock:
            // Code block can be applied without selection (starts code block mode)
            return applyCodeBlockAtCursor(at: range.location, in: attributedString, baseFont: baseFont, selectedRange: range)
        case .link:
            guard range.length > 0 else { return attributedString }
            applyLinkFormat(to: range, in: attributedString)
        case .bulletList:
            // Bullet list can be applied even without selection (inserts at cursor)
            return applyBulletListAtCursor(at: range.location, in: attributedString, baseFont: baseFont)
        case .numberedList:
            // Numbered list can be applied even without selection (inserts at cursor)
            return applyNumberedListAtCursor(at: range.location, in: attributedString, baseFont: baseFont)
        case .blockquote:
            return applyBlockquoteAtCursor(at: range.location, in: attributedString, baseFont: baseFont)
        }
        
        // Track the applied format for inline formats
        if range.length > 0 {
            addFormatTracking(format, to: range, in: attributedString)
        }
        
        return attributedString
    }
    
    /// Calculates the ranges that are NOT covered by the excluded ranges
    /// - Parameters:
    ///   - range: The original range
    ///   - excludedRanges: Ranges to exclude
    /// - Returns: Array of ranges that don't overlap with excluded ranges
    private func calculateNonOverlappingRanges(from range: NSRange, excluding excludedRanges: [NSRange]) -> [NSRange] {
        guard !excludedRanges.isEmpty else { return [range] }
        
        // Sort excluded ranges by location
        let sortedExcluded = excludedRanges.sorted { $0.location < $1.location }
        
        var result: [NSRange] = []
        var currentStart = range.location
        let rangeEnd = range.location + range.length
        
        for excluded in sortedExcluded {
            let excludedStart = excluded.location
            let excludedEnd = excluded.location + excluded.length
            
            // Skip if excluded range is completely outside our range
            if excludedEnd <= range.location || excludedStart >= rangeEnd {
                continue
            }
            
            // Clamp excluded range to our range
            let clampedStart = max(excludedStart, range.location)
            let clampedEnd = min(excludedEnd, rangeEnd)
            
            // Add the range before this excluded range (if any)
            if currentStart < clampedStart {
                result.append(NSRange(location: currentStart, length: clampedStart - currentStart))
            }
            
            // Move current start past this excluded range
            currentStart = clampedEnd
        }
        
        // Add any remaining range after the last excluded range
        if currentStart < rangeEnd {
            result.append(NSRange(location: currentStart, length: rangeEnd - currentStart))
        }
        
        return result
    }
    
    /// Removes the specified format from the text at the given range
    /// - Parameters:
    ///   - format: The format type to remove
    ///   - range: The range of text to unformat
    ///   - attributedString: The mutable attributed string to modify
    ///   - baseFont: The base font to restore (optional)
    /// - Returns: The resulting attributed string
    @discardableResult
    public func removeFormat(
        _ format: FormatType,
        from range: NSRange,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont? = nil
    ) -> NSMutableAttributedString {
        return removeFormat(format, from: range, in: attributedString, baseFont: baseFont, skippingRanges: [])
    }
    
    /// Removes the specified format from the text at the given range, skipping certain ranges (like mentions)
    /// - Parameters:
    ///   - format: The format type to remove
    ///   - range: The range of text to unformat
    ///   - attributedString: The mutable attributed string to modify
    ///   - baseFont: The base font to restore (optional)
    ///   - skippingRanges: Ranges to skip (e.g., mention ranges that should not be modified)
    /// - Returns: The resulting attributed string
    @discardableResult
    public func removeFormat(
        _ format: FormatType,
        from range: NSRange,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont? = nil,
        skippingRanges: [NSRange]
    ) -> NSMutableAttributedString {
        guard range.length > 0 else { return attributedString }
        
        let font = baseFont ?? UIFont.systemFont(ofSize: 17)
        
        // If there are ranges to skip, calculate the non-skip ranges and remove format from each
        if !skippingRanges.isEmpty {
            let rangesToProcess = calculateNonOverlappingRanges(from: range, excluding: skippingRanges)
            
            for subRange in rangesToProcess {
                removeFormatFromRange(format, from: subRange, in: attributedString, baseFont: font)
            }
            
            return attributedString
        }
        
        return removeFormatFromRange(format, from: range, in: attributedString, baseFont: font)
    }
    
    /// Internal method to remove format from a single range
    private func removeFormatFromRange(
        _ format: FormatType,
        from range: NSRange,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont
    ) -> NSMutableAttributedString {
        guard range.length > 0 else { return attributedString }
        
        switch format {
        case .bold:
            removeBoldFormat(from: range, in: attributedString, baseFont: baseFont)
        case .italic:
            removeItalicFormat(from: range, in: attributedString, baseFont: baseFont)
        case .underline:
            removeUnderlineFormat(from: range, in: attributedString)
        case .strikethrough:
            removeStrikethroughFormat(from: range, in: attributedString)
        case .code, .codeBlock:
            removeCodeFormat(from: range, in: attributedString, baseFont: baseFont)
        case .link:
            removeLinkFormat(from: range, in: attributedString)
        case .bulletList:
            isInBulletListMode = false
            // Remove bullet from current line if exists
            break
        case .numberedList:
            isInNumberedListMode = false
            currentListNumber = 1
            // Remove number from current line if exists
            break
        case .blockquote:
            removeBlockquoteFormat(from: range, in: attributedString)
        }
        
        // Remove format tracking
        removeFormatTracking(format, from: range, in: attributedString)
        
        return attributedString
    }
    
    /// Handles new line insertion - continues list if in list mode
    /// - Parameters:
    ///   - cursorPosition: Current cursor position
    ///   - attributedString: The attributed string
    ///   - baseFont: Base font for styling
    /// - Returns: Tuple of (new attributed string, new cursor position, text to insert)
    public func handleNewLine(
        at cursorPosition: Int,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont
    ) -> (NSMutableAttributedString, Int, String)? {
        
        // Debug: Log which modes are active
        
        if isInBulletListMode {
            // Check if current line is empty (just bullet)
            let lineInfo = getLineInfo(at: cursorPosition, in: attributedString.string)
            let lineText = (attributedString.string as NSString).substring(with: NSRange(location: lineInfo.start, length: lineInfo.length))
            
            // Check for empty line pattern: "•"
            let trimmed = lineText.trimmingCharacters(in: .whitespaces)
            if trimmed == "•" {
                isInBulletListMode = false
                // Remove the bullet
                let bulletRange = NSRange(location: lineInfo.start, length: lineInfo.length)
                attributedString.replaceCharacters(in: bulletRange, with: "")
                return (attributedString, lineInfo.start, "")
            }
            
            // Build new line text with bullet
            // Note: Blockquote is now view-based, so no "▎" prefix needed
            let newLineText = "\n• "
            
            // Use blockquote text color if in blockquote mode
            let textColor: UIColor
            if isInBlockquoteMode {
                if #available(iOS 13.0, *) {
                    textColor = UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark
                            ? UIColor.lightGray
                            : UIColor.darkGray
                    }
                } else {
                    textColor = UIColor.darkGray
                }
            } else {
                textColor = UIColor.label
            }
            
            let insertPosition = cursorPosition
            // Add isBlockquoteKey attribute if in blockquote mode so the bar extends to new lines
            var attributes: [NSAttributedString.Key: Any] = [
                .font: baseFont,
                .foregroundColor: textColor
            ]
            if isInBlockquoteMode {
                attributes[RichTextFormatterManager.isBlockquoteKey] = true
            }
            attributedString.insert(NSAttributedString(string: newLineText, attributes: attributes), at: insertPosition)
            return (attributedString, insertPosition + newLineText.count, newLineText)
        }
        
        if isInNumberedListMode {
            // Check if current line is empty (just number)
            let lineInfo = getLineInfo(at: cursorPosition, in: attributedString.string)
            let lineText = (attributedString.string as NSString).substring(with: NSRange(location: lineInfo.start, length: lineInfo.length))
            
            // Check for empty line pattern: "N. "
            let numberPattern = "^\\d+\\.\\s*$"
            if let regex = try? NSRegularExpression(pattern: numberPattern),
               regex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) != nil {
                isInNumberedListMode = false
                currentListNumber = 1
                // Remove the number
                let numberRange = NSRange(location: lineInfo.start, length: lineInfo.length)
                attributedString.replaceCharacters(in: numberRange, with: "")
                return (attributedString, lineInfo.start, "")
            }
            
            // Detect the current line's number to determine the next number
            let currentLineNumber: Int
            let numberDetectionPattern = "(\\d+)\\."
            if let regex = try? NSRegularExpression(pattern: numberDetectionPattern),
               let match = regex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)),
               let numberRange = Range(match.range(at: 1), in: lineText) {
                let numberString = String(lineText[numberRange])
                currentLineNumber = Int(numberString) ?? currentListNumber
            } else {
                currentLineNumber = currentListNumber
            }
            
            // Next number is current + 1
            let nextNumber = currentLineNumber + 1
            currentListNumber = nextNumber
            
            // Build new line text with number
            // Note: Blockquote is now view-based, so no "▎" prefix needed
            let newLineText = "\n\(nextNumber). "
            
            // Use blockquote text color if in blockquote mode
            let textColor: UIColor
            if isInBlockquoteMode {
                if #available(iOS 13.0, *) {
                    textColor = UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark
                            ? UIColor.lightGray
                            : UIColor.darkGray
                    }
                } else {
                    textColor = UIColor.darkGray
                }
            } else {
                textColor = UIColor.label
            }
            
            let insertPosition = cursorPosition
            // Add isBlockquoteKey attribute if in blockquote mode so the bar extends to new lines
            var attributes: [NSAttributedString.Key: Any] = [
                .font: baseFont,
                .foregroundColor: textColor
            ]
            if isInBlockquoteMode {
                attributes[RichTextFormatterManager.isBlockquoteKey] = true
            }
            attributedString.insert(NSAttributedString(string: newLineText, attributes: attributes), at: insertPosition)
            return (attributedString, insertPosition + newLineText.count, newLineText)
        }
        
        // Check if we're on a numbered list line even though mode is off
        // This handles the case where user double-entered to exit, then went back to a numbered line
        if !isInNumberedListMode {
            let lineInfo = getLineInfo(at: cursorPosition, in: attributedString.string)
            let lineText = (attributedString.string as NSString).substring(with: NSRange(location: lineInfo.start, length: lineInfo.length))
            
            // Check if current line has a numbered list pattern: "1. text"
            let numberPattern = "^(\\d+)\\.\\s+"
            if let regex = try? NSRegularExpression(pattern: numberPattern),
               let match = regex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)),
               let numberRange = Range(match.range(at: 1), in: lineText) {
                
                // Extract the current line number
                let numberString = String(lineText[numberRange])
                let currentLineNumber = Int(numberString) ?? 1
                
                // Re-enable numbered list mode
                isInNumberedListMode = true
                currentListNumber = currentLineNumber + 1
                
                // Build new line text with number
                let newLineText = "\n\(currentListNumber). "
                
                // Use blockquote text color if in blockquote mode
                let textColor: UIColor
                if isInBlockquoteMode {
                    if #available(iOS 13.0, *) {
                        textColor = UIColor { traitCollection in
                            return traitCollection.userInterfaceStyle == .dark
                                ? UIColor.lightGray
                                : UIColor.darkGray
                        }
                    } else {
                        textColor = UIColor.darkGray
                    }
                } else {
                    textColor = UIColor.label
                }
                
                let insertPosition = cursorPosition
                // Add isBlockquoteKey attribute if in blockquote mode so the bar extends to new lines
                var attributes: [NSAttributedString.Key: Any] = [
                    .font: baseFont,
                    .foregroundColor: textColor
                ]
                if isInBlockquoteMode {
                    attributes[RichTextFormatterManager.isBlockquoteKey] = true
                }
                attributedString.insert(NSAttributedString(string: newLineText, attributes: attributes), at: insertPosition)
                return (attributedString, insertPosition + newLineText.count, newLineText)
            }
        }
        
        if isInBlockquoteMode {
            // Check if current line is empty - if so, exit blockquote mode (double-enter to exit)
            let lineInfo = getLineInfo(at: cursorPosition, in: attributedString.string)
            let lineText = (attributedString.string as NSString).substring(with: NSRange(location: lineInfo.start, length: lineInfo.length))
            
            // If line is empty, exit blockquote mode
            if lineText.trimmingCharacters(in: .whitespaces).isEmpty && lineInfo.start > 0 {
                isInBlockquoteMode = false
                // Return special marker to indicate blockquote exit
                let newLineText = "\n"
                let insertPosition = cursorPosition
                attributedString.insert(NSAttributedString(string: newLineText, attributes: [
                    .font: baseFont,
                    .foregroundColor: UIColor.label
                ]), at: insertPosition)
                return (attributedString, insertPosition + newLineText.count, "EXIT_BLOCKQUOTE")
            }
            
            // Continue in blockquote mode - add newline with blockquote text color AND isBlockquoteKey attribute
            let blockquoteTextColor: UIColor = {
                if #available(iOS 13.0, *) {
                    return UIColor { traitCollection in
                        return traitCollection.userInterfaceStyle == .dark
                            ? UIColor.lightGray
                            : UIColor.darkGray
                    }
                } else {
                    return UIColor.darkGray
                }
            }()
            
            let newLineText = "\n"
            let insertPosition = cursorPosition
            // IMPORTANT: Add isBlockquoteKey attribute so the blockquote bar extends to new lines
            attributedString.insert(NSAttributedString(string: newLineText, attributes: [
                .font: baseFont,
                .foregroundColor: blockquoteTextColor,
                RichTextFormatterManager.isBlockquoteKey: true
            ]), at: insertPosition)
            return (attributedString, insertPosition + newLineText.count, newLineText)
        }
        
        if isInCodeBlockMode {
            // Check if current line is empty (double-enter to exit code block)
            let text = attributedString.string
            let lineInfo = getLineInfo(at: cursorPosition, in: text)
            let lineText = (text as NSString).substring(with: NSRange(location: lineInfo.start, length: lineInfo.length))
            
            
            // If line is empty (just whitespace or nothing), exit code block mode
            // This means user pressed enter on an empty line (double-enter to exit)
            let isEmptyLine = lineText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            
            // Check if cursor is at end of text after a newline (user pressed Enter, now on empty line)
            // This is the double-enter scenario: text ends with \n and cursor is at the end
            let isAtEndAfterNewline = cursorPosition == text.count && text.hasSuffix("\n")
            
            // Also check if the previous character is a newline (meaning we're on an empty line)
            // This handles the case where there's content after the code block
            let isPrevCharNewline = cursorPosition > 0 && (text as NSString).character(at: cursorPosition - 1) == Character("\n").asciiValue!
            
            // Exit if:
            // 1. Current line is empty AND we're not at the very beginning (lineInfo.start > 0)
            // 2. OR cursor is at end after a newline
            // 3. OR text is completely empty
            // 4. OR current line is empty AND previous char is newline (double-enter in middle of text)
            let shouldExit = (isEmptyLine && lineInfo.start > 0) || 
                             isAtEndAfterNewline || 
                             attributedString.length == 0 ||
                             (isEmptyLine && isPrevCharNewline && lineInfo.length == 0)
            
            
            if shouldExit {
                isInCodeBlockMode = false
                persistentFormats.remove(.codeBlock)
                
                // Handle the case where cursor is at end after a newline (double-enter scenario)
                // In this case, we need to keep the content but add spacing for the new line
                let text = attributedString.string
                
                if text.hasSuffix("\n") && cursorPosition == text.count {
                    // Text ends with newline and cursor is at the end
                    // Don't remove anything, just add a newline with spacing for the new content
                    let newLineText = "\n"
                    let insertPosition = cursorPosition
                    
                    // Create paragraph style with minimal spacing before the new paragraph
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.paragraphSpacingBefore = 4  // Minimal spacing after code block
                    
                    attributedString.insert(NSAttributedString(string: newLineText, attributes: [
                        .font: baseFont,
                        .foregroundColor: UIColor.label,
                        .paragraphStyle: paragraphStyle
                    ]), at: insertPosition)
                    
                    
                    return (attributedString, insertPosition + newLineText.count, "EXIT_CODE_BLOCK")
                } else if lineInfo.start > 0 {
                    // Remove the empty line (the newline that created this empty line)
                    // Find the newline character before this empty line
                    let removeStart = lineInfo.start - 1
                    let removeLength = lineInfo.length + 1
                    let removeRange = NSRange(location: removeStart, length: min(removeLength, attributedString.length - removeStart))
                    
                    
                    if removeRange.length > 0 && removeRange.location + removeRange.length <= attributedString.length {
                        attributedString.replaceCharacters(in: removeRange, with: "")
                    }
                    
                    // Insert a single newline to end the code block
                    // The visual spacing will be handled by the code block background's bottom padding
                    let newLineText = "\n"
                    let insertPosition = min(removeStart, attributedString.length)
                    
                    // Create paragraph style with minimal spacing before the new paragraph
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.paragraphSpacingBefore = 4  // Minimal spacing after code block
                    
                    attributedString.insert(NSAttributedString(string: newLineText, attributes: [
                        .font: baseFont,
                        .foregroundColor: UIColor.label,
                        .paragraphStyle: paragraphStyle
                    ]), at: insertPosition)
                    
                    
                    // Return special marker to indicate code block exit
                    // Position cursor after the newline
                    return (attributedString, insertPosition + newLineText.count, "EXIT_CODE_BLOCK")
                } else {
                    // Empty code block - just exit without adding newline
                    return (attributedString, 0, "EXIT_CODE_BLOCK")
                }
            }
            
            // In code block mode, continue with code block styling (monospace font)
            // Note: Background is handled by codeBlockBackgroundView, not inline attributes
            let newLineText = "\n"
            let insertPosition = cursorPosition
            let monoFont = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
            attributedString.insert(NSAttributedString(string: newLineText, attributes: [
                .font: monoFont,
                .foregroundColor: CometChatTheme.neutralColor900,
                RichTextFormatterManager.isCodeBlockKey: true  // Mark as code block
            ]), at: insertPosition)
            return (attributedString, insertPosition + newLineText.count, newLineText)
        }
        
        return nil
    }
    
    /// Resets list mode
    public func resetListMode() {
        isInBulletListMode = false
        isInNumberedListMode = false
        isInBlockquoteMode = false
        isInCodeBlockMode = false
        currentListNumber = 1
        persistentFormats.removeAll()
    }
    
    /// Detects which formats are currently active at the given range
    /// - Parameters:
    ///   - attributedString: The attributed string to analyze
    ///   - range: The range to check for active formats
    /// - Returns: A set of active format types
    public func detectActiveFormats(
        in attributedString: NSAttributedString,
        at range: NSRange
    ) -> Set<FormatType> {
        var formats = Set<FormatType>()
        
        guard attributedString.length > 0 else {
            // Add list and block format state flags even if text is empty
            if isInBulletListMode { formats.insert(.bulletList) }
            if isInNumberedListMode { formats.insert(.numberedList) }
            if isInBlockquoteMode { formats.insert(.blockquote) }
            if isInCodeBlockMode { formats.insert(.codeBlock) }
            return formats
        }
        
        // Use the start of the range for detection
        let checkLocation = min(range.location, attributedString.length - 1)
        let effectiveRange = NSRange(location: checkLocation, length: min(1, attributedString.length - checkLocation))
        
        guard effectiveRange.location + effectiveRange.length <= attributedString.length else {
            // Add list and block format state flags
            if isInBulletListMode { formats.insert(.bulletList) }
            if isInNumberedListMode { formats.insert(.numberedList) }
            if isInBlockquoteMode { formats.insert(.blockquote) }
            if isInCodeBlockMode { formats.insert(.codeBlock) }
            return formats
        }
        
        attributedString.enumerateAttributes(in: effectiveRange, options: []) { attributes, _, _ in
            // Check for bold from custom attribute first (more reliable), then font traits
            if let isBold = attributes[RichTextFormatterManager.isBoldKey] as? Bool, isBold {
                formats.insert(.bold)
            } else if let font = attributes[.font] as? UIFont {
                let traits = font.fontDescriptor.symbolicTraits
                if traits.contains(.traitBold) {
                    formats.insert(.bold)
                }
            }
            
            // Check for italic from custom attribute first (more reliable), then font traits
            if let isItalic = attributes[RichTextFormatterManager.isItalicKey] as? Bool, isItalic {
                formats.insert(.italic)
            } else if let font = attributes[.font] as? UIFont {
                let traits = font.fontDescriptor.symbolicTraits
                if traits.contains(.traitItalic) {
                    formats.insert(.italic)
                }
            }
            
            // Check for inline code and code block from font and isCodeBlockKey attribute
            if let font = attributes[.font] as? UIFont {
                let fontName = font.fontName.lowercased()
                if fontName.contains("mono") || fontName.contains("courier") || fontName.contains("menlo") {
                    // Monospace font detected - check isCodeBlockKey attribute first
                    let isCodeBlockAttr = attributes[RichTextFormatterManager.isCodeBlockKey]
                    
                    if let isCodeBlock = isCodeBlockAttr as? Bool {
                        if isCodeBlock {
                            formats.insert(.codeBlock)
                        } else {
                            formats.insert(.code)
                        }
                    } else if isInCodeBlockMode {
                        // Fallback to mode flag if attribute not set
                        formats.insert(.codeBlock)
                    } else {
                        formats.insert(.code)
                    }
                }
            }
            
            // Check for link first (before underline, since links have underline by default)
            let hasLink = attributes[.link] != nil
            if hasLink {
                formats.insert(.link)
            }
            
            // Check for underline - but NOT if it's a link (links have underline by default)
            if !hasLink {
                if let underline = attributes[.underlineStyle] as? Int, underline == NSUnderlineStyle.single.rawValue {
                    formats.insert(.underline)
                }
            }
            
            // Check for strikethrough
            if let strikethrough = attributes[.strikethroughStyle] as? Int, strikethrough == NSUnderlineStyle.single.rawValue {
                formats.insert(.strikethrough)
            }
        }
        
        // Add list and block format state flags
        if isInBulletListMode { formats.insert(.bulletList) }
        if isInNumberedListMode { formats.insert(.numberedList) }
        if isInBlockquoteMode { formats.insert(.blockquote) }
        if isInCodeBlockMode {
            formats.insert(.codeBlock)
            // When in code block mode, remove inline code to avoid confusion
            formats.remove(.code)
        }
        
        
        return formats
    }
    
    /// Gets the markdown syntax for a format type
    /// - Parameter format: The format type
    /// - Returns: The markdown syntax structure
    public func getMarkdownSyntax(for format: FormatType) -> MarkdownSyntax {
        return format.markdownSyntax
    }
    
    // MARK: - Mention Tag Protection Helpers
    
    /// Protects mention tags by replacing them with unique placeholders
    /// - Parameter text: The text containing mention tags
    /// - Returns: A tuple of (protected text with placeholders, mapping of placeholders to original tags)
    private func protectMentionTags(in text: String) -> (protected: String, placeholders: [String: String]) {
        var protectedText = text
        var placeholders: [String: String] = [:]
        var index = 0
        
        // Regex pattern to match mention tags: <@uid:...> or <@all:...>
        let pattern = "<@(?:uid|all):([^>]+)>"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return (text, [:])
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        
        // Process matches in reverse order to maintain correct positions
        for match in matches.reversed() {
            let matchedText = nsString.substring(with: match.range)
            
            // Generate unique placeholder
            var placeholder = "__MENTION_\(index)__"
            var suffix = 1
            
            // Handle placeholder collision (max 100 attempts)
            while protectedText.contains(placeholder) && suffix < 100 {
                placeholder = "__MENTION_\(index)_\(suffix)__"
                suffix += 1
            }
            
            if suffix >= 100 {
                // Log error and skip this mention tag
                continue
            }
            
            // Store mapping
            placeholders[placeholder] = matchedText
            
            
            // Replace mention tag with placeholder
            protectedText = (protectedText as NSString).replacingCharacters(in: match.range, with: placeholder) as String
            
            index += 1
        }
        
        return (protectedText, placeholders)
    }
    
    /// Restores mention tags from placeholders
    /// - Parameters:
    ///   - text: The text containing placeholders
    ///   - placeholders: The mapping of placeholders to original mention tags
    /// - Returns: Text with mention tags restored
    private func restoreMentionTags(in text: String, using placeholders: [String: String]) -> String {
        var restoredText = text
        
        // Replace each placeholder with its original mention tag
        for (placeholder, mentionTag) in placeholders {
            if restoredText.contains(placeholder) {
                restoredText = restoredText.replacingOccurrences(of: placeholder, with: mentionTag)
            } else {
                // Log warning if placeholder not found
            }
        }
        
        // Validate that all placeholders were replaced
        for placeholder in placeholders.keys {
            if restoredText.contains(placeholder) {
            }
        }
        
        // Validate mention tag integrity after restoration
        let mentionPattern = "<@(?:uid|all):([^>]+)>"
        if let mentionRegex = try? NSRegularExpression(pattern: mentionPattern, options: []) {
            let nsString = restoredText as NSString
            let matches = mentionRegex.matches(in: restoredText, options: [], range: NSRange(location: 0, length: nsString.length))
            
            // Verify all restored mention tags are valid
            for match in matches {
                let matchedTag = nsString.substring(with: match.range)
                if !placeholders.values.contains(matchedTag) && placeholders.isEmpty == false {
                }
            }
        }
        
        // Check for partial mention tags (incomplete tags)
        let partialTagPattern = "<@(?:uid|all):([^>]*$|[^<]*(?!>))"
        if let partialRegex = try? NSRegularExpression(pattern: partialTagPattern, options: []) {
            let nsString = restoredText as NSString
            let partialMatches = partialRegex.matches(in: restoredText, options: [], range: NSRange(location: 0, length: nsString.length))
            
            if !partialMatches.isEmpty {
                for match in partialMatches {
                    let partialTag = nsString.substring(with: match.range)
                }
            }
        }
        
        return restoredText
    }
    
    /// Converts attributed string to markdown text for sending
    /// - Parameter attributedString: The attributed string to convert
    /// - Returns: Plain text with markdown syntax
    public func convertToMarkdown(_ attributedString: NSAttributedString) -> String {
        // Call the overloaded version with empty selectedFormatters
        return convertToMarkdown(attributedString, selectedFormatters: [:])
    }
    
    /// Converts attributed string to markdown text for sending, with mention support
    /// - Parameters:
    ///   - attributedString: The attributed string to convert
    ///   - selectedFormatters: Dictionary mapping tracking characters to suggestion items with ranges
    /// - Returns: Plain text with markdown syntax and proper mention tags
    public func convertToMarkdown(_ attributedString: NSAttributedString, selectedFormatters: [Character: [(item: SuggestionItem, range: NSRange)]]) -> String {
        
        // First, replace visible mention text with underlying text (mention tags)
        // This must happen before any markdown conversion
        let workingAttributedString: NSAttributedString
        if !selectedFormatters.isEmpty {
            let mutableString = NSMutableAttributedString(attributedString: attributedString)
            
            // Collect all mention replacements sorted by location (descending to preserve positions)
            var replacements: [(range: NSRange, underlyingText: String)] = []
            for (_, items) in selectedFormatters {
                for (item, range) in items {
                    if let underlyingText = item.underlyingText {
                        replacements.append((range: range, underlyingText: underlyingText))
                    }
                }
            }
            
            // Sort by location descending so we can replace from end to start
            replacements.sort { $0.range.location > $1.range.location }
            
            // Replace visible text with underlying text
            for replacement in replacements {
                if replacement.range.location >= 0 && 
                   replacement.range.location + replacement.range.length <= mutableString.length {
                    // Get the attributes at this range to preserve formatting
                    let existingAttributes = mutableString.attributes(at: replacement.range.location, effectiveRange: nil)
                    let replacementString = NSAttributedString(string: replacement.underlyingText, attributes: existingAttributes)
                    mutableString.replaceCharacters(in: replacement.range, with: replacementString)
                }
            }
            
            workingAttributedString = mutableString
        } else {
            workingAttributedString = attributedString
        }
        
        var result = ""
        let fullRange = NSRange(location: 0, length: workingAttributedString.length)
        
        // Debug: Print all attributes in the string
        workingAttributedString.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
            let text = (workingAttributedString.string as NSString).substring(with: range)
            let hasBlockquoteKey = attributes[RichTextFormatterManager.isBlockquoteKey] as? Bool
            let hasCodeBlockKey = attributes[RichTextFormatterManager.isCodeBlockKey] as? Bool
        }
        
        // First pass: identify code regions using isCodeBlockKey attribute (more reliable than font detection)
        // This handles emojis and other multi-byte characters correctly
        // Use a combined approach: detect code using isCodeBlockKey attribute OR monospace font
        var rawCodeRegions: [(start: Int, end: Int, isCodeBlock: Bool)] = []
        var currentCodeStart: Int? = nil
        var currentIsCodeBlock: Bool = false
        
        workingAttributedString.enumerateAttributes(in: fullRange, options: []) { attributes, range, _ in
            // Check isCodeBlockKey attribute first
            let codeBlockKeyValue = attributes[RichTextFormatterManager.isCodeBlockKey]
            let hasCodeBlockKey = codeBlockKeyValue != nil
            let isCodeBlockFromAttr = (codeBlockKeyValue as? Bool) == true
            
            // Also check for monospace font as fallback
            var hasMonospaceFont = false
            if let font = attributes[.font] as? UIFont {
                let fontName = font.fontName.lowercased()
                hasMonospaceFont = fontName.contains("mono") || fontName.contains("courier") || fontName.contains("menlo")
            }
            
            // Consider it code if either:
            // 1. isCodeBlockKey is explicitly set (to true or false)
            // 2. Has monospace font (fallback for cases where attribute is missing)
            let isCode = hasCodeBlockKey || hasMonospaceFont
            let isCodeBlock = isCodeBlockFromAttr  // Only true if explicitly marked as code block
            
            if isCode {
                if currentCodeStart == nil {
                    currentCodeStart = range.location
                    currentIsCodeBlock = isCodeBlock
                } else if isCodeBlock != currentIsCodeBlock {
                    // Different code type (inline vs block) - close current and start new
                    rawCodeRegions.append((start: currentCodeStart!, end: range.location, isCodeBlock: currentIsCodeBlock))
                    currentCodeStart = range.location
                    currentIsCodeBlock = isCodeBlock
                }
                // Continue extending the current code region
            } else {
                if let start = currentCodeStart {
                    rawCodeRegions.append((start: start, end: range.location, isCodeBlock: currentIsCodeBlock))
                    currentCodeStart = nil
                }
            }
        }
        // Handle code region at the end
        if let start = currentCodeStart {
            rawCodeRegions.append((start: start, end: workingAttributedString.length, isCodeBlock: currentIsCodeBlock))
        }
        
        // Merge adjacent code regions (regions that are next to each other with same isCodeBlock value)
        var codeRegions: [(start: Int, end: Int, isCodeBlock: Bool)] = []
        for region in rawCodeRegions {
            if let lastRegion = codeRegions.last, lastRegion.end == region.start, lastRegion.isCodeBlock == region.isCodeBlock {
                // Merge with the last region
                codeRegions[codeRegions.count - 1] = (start: lastRegion.start, end: region.end, isCodeBlock: region.isCodeBlock)
            } else {
                codeRegions.append(region)
            }
        }
        
        
        // Second pass: build the result with proper markdown
        var currentIndex = 0
        
        for region in codeRegions {
            // Add non-code text before this region
            if region.start > currentIndex {
                let nonCodeRange = NSRange(location: currentIndex, length: region.start - currentIndex)
                let nonCodeText = convertNonCodeToMarkdown(workingAttributedString, range: nonCodeRange)
                result += nonCodeText
            }
            
            // Add code region
            let codeRange = NSRange(location: region.start, length: region.end - region.start)
            let codeText = (workingAttributedString.string as NSString).substring(with: codeRange)
            
            // Use the isCodeBlock value from the region tuple (already determined during enumeration)
            let isCodeBlock = region.isCodeBlock
            
            
            // Skip code regions that contain only whitespace/newlines
            // This can happen when inline code is turned off but the font attributes remain on newline characters
            let trimmedCodeText = codeText.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedCodeText.isEmpty {
                // Treat as regular text - just add the whitespace as-is
                result += codeText
                currentIndex = region.end
                continue
            }
            
            // Convert emojis to shortcodes in code regions
            let codeTextWithShortcodes = codeText.emojisToShortcodes()
            
            
            if isCodeBlock {
                // Code block - use triple backticks
                // First, strip any existing triple backticks from the content
                // (they may have been added when entering code block mode)
                var cleanCodeText = codeTextWithShortcodes
                
                // Remove leading ``` if present
                if cleanCodeText.hasPrefix("```") {
                    cleanCodeText = String(cleanCodeText.dropFirst(3))
                    // Also remove the newline after opening backticks if present
                    if cleanCodeText.hasPrefix("\n") {
                        cleanCodeText = String(cleanCodeText.dropFirst(1))
                    }
                }
                
                // Remove trailing ``` if present
                if cleanCodeText.hasSuffix("```") {
                    cleanCodeText = String(cleanCodeText.dropLast(3))
                    // Also remove the newline before closing backticks if present
                    if cleanCodeText.hasSuffix("\n") {
                        cleanCodeText = String(cleanCodeText.dropLast(1))
                    }
                }
                
                // Ensure there's a newline before code block if result doesn't end with one
                // This prevents malformed markdown like `inline````codeblock```
                if !result.isEmpty && !result.hasSuffix("\n") {
                    result += "\n"
                }
                
                result += "```\n\(cleanCodeText)\n```"
            } else {
                // Inline code - use single backticks. Inline code cannot span lines in
                // markdown, but silently promoting the region to a ``` code block would
                // CHANGE the formatting the user chose (the composer showed inline, the
                // bubble would render a block, and a later edit would open in code-block
                // mode). Emit one inline span per line instead — the newline between
                // spans stays plain text.
                let trimmedCodeText = codeTextWithShortcodes.trimmingCharacters(in: .newlines)
                if trimmedCodeText.contains("\n") {
                    let inlineLines = trimmedCodeText.components(separatedBy: "\n").map { line -> String in
                        let content = line.trimmingCharacters(in: .whitespaces)
                        return content.isEmpty ? line : "`\(line)`"
                    }
                    result += inlineLines.joined(separator: "\n")
                } else {
                    result += "`\(trimmedCodeText)`"
                }
            }
            
            currentIndex = region.end
        }
        
        // Add remaining non-code text
        if currentIndex < workingAttributedString.length {
            let remainingRange = NSRange(location: currentIndex, length: workingAttributedString.length - currentIndex)
            let remainingText = convertNonCodeToMarkdown(workingAttributedString, range: remainingRange)
            result += remainingText
        }
        
        // If no code regions, convert everything as non-code
        if codeRegions.isEmpty {
            result = convertNonCodeToMarkdown(workingAttributedString, range: fullRange)
        }
        
        // Now handle blockquote markers - check which parts of the original text have isBlockquoteKey
        // We need to add "> " prefix to lines that have blockquote content
        result = addBlockquoteMarkersToResult(result, originalAttributedString: workingAttributedString)
        
        
        return result
    }
    
    /// Adds blockquote markers ("> ") to lines that have blockquote content
    /// Emojis are kept as-is in blockquotes (no conversion to shortcodes)
    /// - Parameters:
    ///   - result: The markdown result string
    ///   - originalAttributedString: The original attributed string to check for blockquote attributes
    /// - Returns: The result with blockquote markers added where needed
    private func addBlockquoteMarkersToResult(_ result: String, originalAttributedString: NSAttributedString) -> String {
        // First, identify blockquote regions (similar to code region detection)
        var blockquoteRegions: [(start: Int, end: Int)] = []
        var currentBlockquoteStart: Int? = nil
        let fullRange = NSRange(location: 0, length: originalAttributedString.length)
        
        originalAttributedString.enumerateAttribute(RichTextFormatterManager.isBlockquoteKey, in: fullRange, options: []) { value, range, _ in
            let isBlockquote = (value as? Bool) == true
            
            if isBlockquote {
                if currentBlockquoteStart == nil {
                    currentBlockquoteStart = range.location
                }
                // Continue extending the current blockquote region
            } else {
                if let start = currentBlockquoteStart {
                    blockquoteRegions.append((start: start, end: range.location))
                    currentBlockquoteStart = nil
                }
            }
        }
        // Handle blockquote region at the end
        if let start = currentBlockquoteStart {
            blockquoteRegions.append((start: start, end: originalAttributedString.length))
        }
        
        // Merge adjacent blockquote regions
        var mergedBlockquoteRegions: [(start: Int, end: Int)] = []
        for region in blockquoteRegions {
            if let lastRegion = mergedBlockquoteRegions.last, lastRegion.end == region.start {
                mergedBlockquoteRegions[mergedBlockquoteRegions.count - 1] = (start: lastRegion.start, end: region.end)
            } else {
                mergedBlockquoteRegions.append(region)
            }
        }
        
        // If no blockquote content, return as-is
        if mergedBlockquoteRegions.isEmpty {
            return result
        }
        
        
        // Create a set of character indices that are in blockquote regions
        var blockquoteIndices = Set<Int>()
        for region in mergedBlockquoteRegions {
            for i in region.start..<region.end {
                blockquoteIndices.insert(i)
            }
        }
        
        // Split original text into lines and track which lines are blockquotes
        let originalText = originalAttributedString.string
        let originalLines = originalText.components(separatedBy: "\n")
        var lineIsBlockquote: [Bool] = []
        var currentPosition = 0
        
        for (lineIndex, line) in originalLines.enumerated() {
            // Check if any character in this line is in a blockquote region
            var hasBlockquote = false
            
            // For non-empty lines, check if any character has blockquote attribute
            if !line.isEmpty {
                for i in 0..<line.count {
                    if blockquoteIndices.contains(currentPosition + i) {
                        hasBlockquote = true
                        break
                    }
                }
            } else {
                // For empty lines (just newlines), check if the previous line was blockquote
                // and the next line is also blockquote - then this empty line is part of blockquote
                if lineIndex > 0 && lineIndex < originalLines.count - 1 {
                    // Check if previous line was blockquote
                    let prevWasBlockquote = lineIndex > 0 ? lineIsBlockquote[lineIndex - 1] : false
                    
                    // Check if next line has blockquote content
                    var nextHasBlockquote = false
                    var nextLineStart = currentPosition + 1 // +1 for the newline
                    let nextLine = originalLines[lineIndex + 1]
                    for i in 0..<nextLine.count {
                        if blockquoteIndices.contains(nextLineStart + i) {
                            nextHasBlockquote = true
                            break
                        }
                    }
                    
                    // If both previous and next lines are blockquote, this empty line is too
                    hasBlockquote = prevWasBlockquote && nextHasBlockquote
                } else if lineIndex > 0 {
                    // Last line is empty - inherit from previous line
                    hasBlockquote = lineIsBlockquote[lineIndex - 1]
                }
            }
            
            lineIsBlockquote.append(hasBlockquote)
            currentPosition += line.count + 1 // +1 for newline
        }
        
        
        // Now apply blockquote markers to result lines
        // The result may have different line structure due to markdown conversion,
        // but we'll try to match based on line index
        let resultLines = result.components(separatedBy: "\n")
        var outputLines: [String] = []
        
        var isInsideCodeBlock = false
        
        
        for (lineIndex, line) in resultLines.enumerated() {
            // Check if this line is a code block marker
            if line == "```" {
                isInsideCodeBlock = !isInsideCodeBlock
                outputLines.append(line)
                continue
            }
            
            // Code block content should never have blockquote markers
            if isInsideCodeBlock {
                outputLines.append(line)
                continue
            }
            
            // Check if this line corresponds to a blockquote line in the original
            // Use the line index to determine if it should be a blockquote
            let shouldBeBlockquote: Bool
            if lineIndex < lineIsBlockquote.count {
                shouldBeBlockquote = lineIsBlockquote[lineIndex]
            } else {
                // If we've run out of original lines, check if the last line was blockquote
                shouldBeBlockquote = lineIsBlockquote.last ?? false
            }
            
            
            if shouldBeBlockquote && !line.isEmpty {
                outputLines.append("> \(line)")
            } else {
                outputLines.append(line)
            }
        }
        
        let finalResult = outputLines.joined(separator: "\n")
        return finalResult
    }
    
    /// Helper to convert non-code attributed text to markdown
    private func convertNonCodeToMarkdown(_ attributedString: NSAttributedString, range: NSRange) -> String {
        var result = ""
        
        attributedString.enumerateAttributes(in: range, options: []) { attributes, subRange, _ in
            let text = (attributedString.string as NSString).substring(with: subRange)
            var formattedText = text
            
            guard !text.isEmpty else { return }
            
            // Check for link
            if let link = attributes[.link] {
                let urlString: String
                if let url = link as? URL {
                    urlString = url.absoluteString
                } else if let urlStr = link as? String {
                    urlString = urlStr
                } else {
                    urlString = ""
                }
                
                if !urlString.isEmpty {
                    // Build the link, then fall through: a link run can also be
                    // bold or italic and must keep those markers.
                    formattedText = "[\(text)](\(urlString))"
                }
            }
            
            // Check for bold - only use symbolic traits for reliable detection
            var isBold = false
            if let font = attributes[.font] as? UIFont {
                let traits = font.fontDescriptor.symbolicTraits
                isBold = traits.contains(.traitBold)
            }
            
            // Check for italic - only use symbolic traits for reliable detection
            var isItalic = false
            if let font = attributes[.font] as? UIFont {
                let traits = font.fontDescriptor.symbolicTraits
                isItalic = traits.contains(.traitItalic)
            }
            
            // Check for underline
            let hasUnderline = (attributes[.underlineStyle] as? Int ?? 0) != 0 && attributes[.link] == nil
            
            // Check for strikethrough
            let hasStrikethrough = (attributes[.strikethroughStyle] as? Int ?? 0) != 0
            
            // Apply bold and italic
            if isBold && isItalic {
                formattedText = "**_\(formattedText)_**"
            } else if isBold {
                formattedText = "**\(formattedText)**"
            } else if isItalic {
                formattedText = "_\(formattedText)_"
            }
            
            // Apply underline (using HTML style)
            if hasUnderline {
                formattedText = "<u>\(formattedText)</u>"
            }
            
            // Apply strikethrough
            if hasStrikethrough {
                formattedText = "~~\(formattedText)~~"
            }
            
            result += formattedText
        }
        
        return result
    }
    
    /// Processes mentions inside code block/inline code content
    /// Note: Mentions should already be converted to display names by text formatters before parseMarkdown is called
    /// This method applies code styling to the content
    /// Shortcodes are kept as-is (e.g., :grinning_face: stays as text) so users can copy them
    /// - Parameters:
    ///   - content: The code content (may contain shortcodes from emoji conversion)
    ///   - attributes: The code styling attributes to apply
    /// - Returns: An attributed string with code styling applied
    private func processMentionsInCodeBlock(_ content: String, attributes: [NSAttributedString.Key: Any]) -> NSAttributedString {
        // Keep shortcodes as-is - don't convert them back to emojis
        // This allows users to see and copy the shortcode text
        return NSAttributedString(string: content, attributes: attributes)
    }
    
    /// Parses markdown text and converts it to an attributed string for display
    /// Note: Blockquotes ("> ") are handled separately by CometChatTextBubble.parseAndDisplayMixedContent
    /// This function only handles inline formatting (bold, italic, code, links, etc.)
    /// - Parameters:
    ///   - markdown: The markdown text to parse
    ///   - baseFont: The base font to use
    ///   - baseColor: The base text color to use
    ///   - inlineCodeBackgroundColor: Background color for inline code (defaults to neutralColor300)
    ///   - codeBlockBackgroundColor: Background color for code blocks (defaults to neutralColor200)
    ///   - codeTextColor: Text color for code blocks (defaults to neutralColor900)
    ///   - inlineCodeTextColor: Text color for inline code (defaults to extendedPrimaryColor700 - purple)
    ///   - addNewlinesAroundCodeBlocks: Whether to add newlines before/after code blocks (defaults to true for message bubbles, false for composer)
    /// - Returns: An attributed string with formatting applied
    public func parseMarkdown(
        _ markdown: String,
        baseFont: UIFont,
        baseColor: UIColor,
        inlineCodeBackgroundColor: UIColor? = nil,
        codeBlockBackgroundColor: UIColor? = nil,
        codeTextColor: UIColor? = nil,
        inlineCodeTextColor: UIColor? = nil,
        addNewlinesAroundCodeBlocks: Bool = true
    ) -> NSAttributedString {
        let result = NSMutableAttributedString()
        
        // Use the markdown text directly - blockquotes are handled by the caller
        let text = markdown
        
        // Use provided colors or defaults
        let inlineCodeBgColor = inlineCodeBackgroundColor ?? CometChatTheme.neutralColor300
        let codeBlockBgColor = codeBlockBackgroundColor ?? CometChatTheme.neutralColor200
        let codeFgColor = codeTextColor ?? CometChatTheme.neutralColor900
        // Inline code text color defaults to purple
        let inlineCodeFgColor = inlineCodeTextColor ?? CometChatTheme.extendedPrimaryColor700
        
        // Base attributes
        let baseAttributes: [NSAttributedString.Key: Any] = [
            .font: baseFont,
            .foregroundColor: baseColor
        ]
        
        // Process the text character by character, looking for markdown patterns
        var index = text.startIndex
        
        while index < text.endIndex {
            
            // Code block (```) - apply monospace font with distinct block styling
            // Check if we have at least 3 characters and they are ```
            if text.distance(from: index, to: text.endIndex) >= 3 {
                let threeChars = String(text[index..<text.index(index, offsetBy: 3)])
                if threeChars == "```" {
                    let afterBackticks = text.index(index, offsetBy: 3)
                    
                    // Find the closing ``` - search from afterBackticks
                    if afterBackticks < text.endIndex {
                        let searchRange = text[afterBackticks...]
                        if let endRange = searchRange.range(of: "```") {
                            var codeContent = String(text[afterBackticks..<endRange.lowerBound])
                            
                            // Trim leading/trailing newlines
                            if codeContent.hasPrefix("\n") {
                                codeContent.removeFirst()
                            }
                            if codeContent.hasSuffix("\n") {
                                codeContent.removeLast()
                            }
                            
                            // Apply code block formatting
                            let monoFont = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize - 1, weight: .regular)
                            let codeBlockAttributes: [NSAttributedString.Key: Any] = [
                                .font: monoFont,
                                .foregroundColor: codeFgColor,
                                .backgroundColor: codeBlockBgColor,
                                RichTextFormatterManager.isCodeBlockKey: true  // Mark as code block for proper detection
                            ]
                            
                            // Add newline before code block if not at start (only if addNewlinesAroundCodeBlocks is true)
                            if addNewlinesAroundCodeBlocks && result.length > 0 {
                                result.append(NSAttributedString(string: "\n", attributes: baseAttributes))
                            }
                            
                            // Process mentions inside code block content
                            // Mentions have format <@uid:...> or <@all:...>
                            let processedCodeContent = processMentionsInCodeBlock(codeContent, attributes: codeBlockAttributes)
                            result.append(processedCodeContent)
                            
                            // Add newline after code block (only if addNewlinesAroundCodeBlocks is true)
                            if addNewlinesAroundCodeBlocks {
                                result.append(NSAttributedString(string: "\n", attributes: baseAttributes))
                            }
                            
                            index = endRange.upperBound
                            continue
                        }
                    }
                }
            }
            
            // Inline code (`) - apply monospace font with subtle background
            // Only match single backticks, not triple backticks or double backticks at the start
            if text[index] == "`" {
                // Make sure this is not part of ``` or ``
                let remaining = text[index...]
                if !remaining.hasPrefix("```") {
                    // Check if this is a double backtick `` at the start
                    // If so, treat both as literal text and skip
                    if remaining.hasPrefix("``") {
                        // This is `` - add both as literal text
                        result.append(NSAttributedString(string: "``", attributes: baseAttributes))
                        index = text.index(index, offsetBy: 2)
                        continue
                    }
                    
                    let afterBacktick = text.index(after: index)
                    if afterBacktick < text.endIndex {
                        // Find the closing single backtick (not part of ``` or ``)
                        // This allows content like `Verb``Reverb` to be treated as single inline code
                        // where `` inside is treated as literal double backticks
                        var closingBacktick: String.Index? = nil
                        var searchIndex = afterBacktick
                        
                        while searchIndex < text.endIndex {
                            if text[searchIndex] == "`" {
                                // Check if this backtick is part of ```
                                let remainingFromHere = text[searchIndex...]
                                if remainingFromHere.hasPrefix("```") {
                                    // Skip past the ``` - this is a code block marker
                                    searchIndex = text.index(searchIndex, offsetBy: 3, limitedBy: text.endIndex) ?? text.endIndex
                                    continue
                                }
                                // Check if this backtick is part of `` (double backtick)
                                let nextIndex = text.index(after: searchIndex)
                                if nextIndex < text.endIndex && text[nextIndex] == "`" {
                                    // Check if it's actually ``` (triple)
                                    let nextNextIndex = text.index(after: nextIndex)
                                    if nextNextIndex < text.endIndex && text[nextNextIndex] == "`" {
                                        // This is ```, skip all 3
                                        searchIndex = text.index(searchIndex, offsetBy: 3, limitedBy: text.endIndex) ?? text.endIndex
                                        continue
                                    }
                                    // This is `` (double backtick) inside the code - skip both and continue
                                    searchIndex = text.index(searchIndex, offsetBy: 2, limitedBy: text.endIndex) ?? text.endIndex
                                    continue
                                } else {
                                    // This is a single backtick not followed by another - this is our closer
                                    closingBacktick = searchIndex
                                    break
                                }
                            }
                            searchIndex = text.index(after: searchIndex)
                        }
                        
                        if let closingBacktickIndex = closingBacktick {
                            let codeContent = String(text[afterBacktick..<closingBacktickIndex])
                            
                            // Apply code formatting if there's any content (including spaces)
                            // Only skip if completely empty (no characters at all)
                            if !codeContent.isEmpty {
                                // Apply inline code formatting
                                let monoFont = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize - 1, weight: .regular)
                                
                                // Use the passed inlineCodeTextColor, or default to purple
                                // The caller should pass white for outgoing messages
                                let finalInlineCodeColor = inlineCodeFgColor
                                
                                let inlineCodeAttributes: [NSAttributedString.Key: Any] = [
                                    .font: monoFont,
                                    .foregroundColor: finalInlineCodeColor,
                                    .backgroundColor: inlineCodeBgColor,
                                    RichTextFormatterManager.isCodeBlockKey: false  // Mark as inline code (NOT code block)
                                ]
                                
                                // Process mentions inside inline code content
                                let processedCodeContent = processMentionsInCodeBlock(codeContent, attributes: inlineCodeAttributes)
                                result.append(processedCodeContent)
                                
                                index = text.index(after: closingBacktickIndex)
                                continue
                            } else {
                                // Empty inline code `` - just skip the backticks
                                index = text.index(after: closingBacktickIndex)
                                continue
                            }
                        }
                    }
                }
                // If no closing backtick found or it's part of ```, treat as regular character
            }
            
            // Check for link [text](url)
            if text[index] == "[" {
                if let closeBracket = text[index...].firstIndex(of: "]") {
                    let afterCloseBracket = text.index(after: closeBracket)
                    if afterCloseBracket < text.endIndex && text[afterCloseBracket] == "(" {
                        let linkTextStart = text.index(after: index)
                        let linkText = String(text[linkTextStart..<closeBracket])
                        
                        // Search for closing paren from after the "("
                        let urlStart = text.index(after: afterCloseBracket)
                        if urlStart < text.endIndex, let closeParen = text[urlStart...].firstIndex(of: ")") {
                            let urlString = String(text[urlStart..<closeParen])
                            
                            // Don't set .link attribute here - it causes iOS to override foreground color with blue
                            // Instead, store the URL in a custom attribute that HyperlinkLabel can use
                            var linkAttributes: [NSAttributedString.Key: Any] = [
                                .font: baseFont,
                                .foregroundColor: baseColor,
                                .underlineStyle: NSUnderlineStyle.single.rawValue
                            ]
                            // Store URL in a custom attribute instead of .link to avoid iOS blue color override
                            if let url = URL(string: urlString) {
                                linkAttributes[NSAttributedString.Key("CometChatLinkURL")] = url
                            } else if !urlString.isEmpty {
                                linkAttributes[NSAttributedString.Key("CometChatLinkURL")] = urlString
                            }
                            result.append(NSAttributedString(string: linkText, attributes: linkAttributes))
                            
                            index = text.index(after: closeParen)
                            continue
                        }
                    }
                }
            }
            
            // Check for bold+italic (***)
            if text[index...].hasPrefix("***") {
                let afterMarker = text.index(index, offsetBy: 3)
                if afterMarker < text.endIndex, let endRange = text[afterMarker...].range(of: "***") {
                    let content = String(text[afterMarker..<endRange.lowerBound])
                    
                    // Create bold italic font
                    let font: UIFont
                    if let descriptor = baseFont.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
                        font = UIFont(descriptor: descriptor, size: baseFont.pointSize)
                    } else {
                        // Fallback: use system bold italic
                        font = UIFont.systemFont(ofSize: baseFont.pointSize, weight: .bold).withTraits(.traitItalic) ?? UIFont.boldSystemFont(ofSize: baseFont.pointSize)
                    }
                    
                    let attributes: [NSAttributedString.Key: Any] = [
                        .font: font,
                        .foregroundColor: baseColor
                    ]
                    result.append(NSAttributedString(string: content, attributes: attributes))
                    
                    index = endRange.upperBound
                    continue
                }
            }
            
            // Check for bold (**) - must not be *** (bold+italic combo)
            if text[index...].hasPrefix("**") && !text[index...].hasPrefix("***") {
                let afterMarker = text.index(index, offsetBy: 2)
                if afterMarker < text.endIndex {
                    // Find closing ** - can be standalone or first two * of ***
                    var searchIdx = afterMarker
                    var foundClosing = false
                    while searchIdx < text.endIndex {
                        let remaining = text[searchIdx...]
                        if remaining.hasPrefix("**") {
                            // Check that the character BEFORE searchIdx is not * 
                            // to avoid matching the middle ** in *** (e.g., in "a]***[b" we don't want the middle **)
                            if searchIdx > afterMarker {
                                let prevIdx = text.index(before: searchIdx)
                                if text[prevIdx] == "*" {
                                    // This ** is preceded by *, so it's the middle/end of ***
                                    // Skip this position
                                    searchIdx = text.index(after: searchIdx)
                                    continue
                                }
                            }
                            
                            // Valid closing ** found (either standalone ** or first two * of ***)
                            let content = String(text[afterMarker..<searchIdx])
                            
                            // Recursively parse the content for nested formatting (italic, etc.)
                            let parsedContent = parseMarkdown(
                                content,
                                baseFont: baseFont,
                                baseColor: baseColor,
                                inlineCodeBackgroundColor: inlineCodeBgColor,
                                codeBlockBackgroundColor: codeBlockBgColor,
                                codeTextColor: codeFgColor,
                                inlineCodeTextColor: inlineCodeFgColor,
                                addNewlinesAroundCodeBlocks: addNewlinesAroundCodeBlocks
                            )
                            
                            // Apply bold to the parsed content
                            let boldContent = NSMutableAttributedString(attributedString: parsedContent)
                            boldContent.enumerateAttribute(.font, in: NSRange(location: 0, length: boldContent.length), options: []) { value, range, _ in
                                if let existingFont = value as? UIFont {
                                    // Preserve existing traits (like italic) and add bold
                                    var traits = existingFont.fontDescriptor.symbolicTraits
                                    traits.insert(.traitBold)
                                    if let descriptor = existingFont.fontDescriptor.withSymbolicTraits(traits) {
                                        let newFont = UIFont(descriptor: descriptor, size: existingFont.pointSize)
                                        boldContent.addAttribute(.font, value: newFont, range: range)
                                    } else {
                                        // Fallback: use system bold font
                                        boldContent.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: existingFont.pointSize), range: range)
                                    }
                                } else {
                                    // No font set, use base bold font
                                    if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitBold) {
                                        let boldFont = UIFont(descriptor: descriptor, size: baseFont.pointSize)
                                        boldContent.addAttribute(.font, value: boldFont, range: range)
                                    } else {
                                        boldContent.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: baseFont.pointSize), range: range)
                                    }
                                }
                            }
                            
                            result.append(boldContent)
                            
                            index = text.index(searchIdx, offsetBy: 2)
                            foundClosing = true
                            break
                        }
                        searchIdx = text.index(after: searchIdx)
                    }
                    if foundClosing {
                        continue
                    }
                }
                // No closing ** found, treat as regular text
                result.append(NSAttributedString(string: "**", attributes: baseAttributes))
                index = text.index(index, offsetBy: 2)
                continue
            }
            
            // Check for italic with underscore (_text_)
            if text[index] == "_" {
                // Skip underscore-based italic if the underscore is mid-word (e.g., inside URLs like product_id)
                // A mid-word underscore has an alphanumeric or allowed URL character on both sides
                let isIntraWord: Bool = {
                    let hasPrevAlnum: Bool
                    if index > text.startIndex {
                        let prevChar = text[text.index(before: index)]
                        hasPrevAlnum = prevChar.isLetter || prevChar.isNumber || prevChar == "/" || prevChar == "%" || prevChar == "~"
                    } else {
                        hasPrevAlnum = false
                    }
                    let afterIdx = text.index(after: index)
                    let hasNextAlnum: Bool
                    if afterIdx < text.endIndex {
                        let nextChar = text[afterIdx]
                        hasNextAlnum = nextChar.isLetter || nextChar.isNumber
                    } else {
                        hasNextAlnum = false
                    }
                    return hasPrevAlnum && hasNextAlnum
                }()
                
                if !isIntraWord {
                let afterMarker = text.index(after: index)
                if afterMarker < text.endIndex {
                    // Find closing _
                    var searchIdx = afterMarker
                    var foundClosing = false
                    while searchIdx < text.endIndex {
                        if text[searchIdx] == "_" {
                            // Also check that the closing _ is not mid-word
                            let closingIsIntraWord: Bool = {
                                let hasPrevAlnum: Bool
                                if searchIdx > text.startIndex {
                                    let prevChar = text[text.index(before: searchIdx)]
                                    hasPrevAlnum = prevChar.isLetter || prevChar.isNumber
                                } else {
                                    hasPrevAlnum = false
                                }
                                let nextIdx = text.index(after: searchIdx)
                                let hasNextAlnum: Bool
                                if nextIdx < text.endIndex {
                                    let nextChar = text[nextIdx]
                                    hasNextAlnum = nextChar.isLetter || nextChar.isNumber || nextChar == "/" || nextChar == "%" || nextChar == "~"
                                } else {
                                    hasNextAlnum = false
                                }
                                return hasPrevAlnum && hasNextAlnum
                            }()
                            
                            if closingIsIntraWord {
                                searchIdx = text.index(after: searchIdx)
                                continue
                            }
                            
                            let content = String(text[afterMarker..<searchIdx])
                            
                            // Recursively parse the content for nested formatting (bold, etc.)
                            let parsedContent = parseMarkdown(
                                content,
                                baseFont: baseFont,
                                baseColor: baseColor,
                                inlineCodeBackgroundColor: inlineCodeBgColor,
                                codeBlockBackgroundColor: codeBlockBgColor,
                                codeTextColor: codeFgColor,
                                inlineCodeTextColor: inlineCodeFgColor,
                                addNewlinesAroundCodeBlocks: addNewlinesAroundCodeBlocks
                            )
                            
                            // Apply italic to the parsed content
                            let italicContent = NSMutableAttributedString(attributedString: parsedContent)
                            italicContent.enumerateAttribute(.font, in: NSRange(location: 0, length: italicContent.length), options: []) { value, range, _ in
                                if let existingFont = value as? UIFont {
                                    // Preserve existing traits (like bold) and add italic
                                    var traits = existingFont.fontDescriptor.symbolicTraits
                                    traits.insert(.traitItalic)
                                    if let descriptor = existingFont.fontDescriptor.withSymbolicTraits(traits) {
                                        let newFont = UIFont(descriptor: descriptor, size: existingFont.pointSize)
                                        italicContent.addAttribute(.font, value: newFont, range: range)
                                    } else {
                                        // Fallback: use system italic font
                                        italicContent.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: existingFont.pointSize), range: range)
                                    }
                                } else {
                                    // No font set, use base italic font
                                    if let descriptor = baseFont.fontDescriptor.withSymbolicTraits(.traitItalic) {
                                        let italicFont = UIFont(descriptor: descriptor, size: baseFont.pointSize)
                                        italicContent.addAttribute(.font, value: italicFont, range: range)
                                    } else {
                                        italicContent.addAttribute(.font, value: UIFont.italicSystemFont(ofSize: baseFont.pointSize), range: range)
                                    }
                                }
                            }
                            
                            result.append(italicContent)
                            
                            index = text.index(after: searchIdx)
                            foundClosing = true
                            break
                        }
                        searchIdx = text.index(after: searchIdx)
                    }
                    if foundClosing {
                        continue
                    }
                }
                } // end if !isIntraWord
            }
            
            // Check for HTML underline (<u>text</u>) - supports nested formatting
            if text[index...].hasPrefix("<u>") {
                let afterMarker = text.index(index, offsetBy: 3)
                if afterMarker < text.endIndex, let endRange = text[afterMarker...].range(of: "</u>") {
                    let content = String(text[afterMarker..<endRange.lowerBound])
                    
                    // Recursively parse the content for nested formatting (bold, italic, etc.)
                    let parsedContent = parseMarkdown(
                        content,
                        baseFont: baseFont,
                        baseColor: baseColor,
                        inlineCodeBackgroundColor: inlineCodeBgColor,
                        codeBlockBackgroundColor: codeBlockBgColor,
                        codeTextColor: codeFgColor,
                        inlineCodeTextColor: inlineCodeFgColor,
                        addNewlinesAroundCodeBlocks: addNewlinesAroundCodeBlocks
                    )
                    
                    // Apply underline to the parsed content
                    let underlinedContent = NSMutableAttributedString(attributedString: parsedContent)
                    underlinedContent.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: underlinedContent.length))
                    
                    result.append(underlinedContent)
                    
                    index = endRange.upperBound
                    continue
                }
            }
            
            // Check for strikethrough (~~) - supports nested formatting like ~~***text***~~
            if text[index...].hasPrefix("~~") {
                let afterMarker = text.index(index, offsetBy: 2)
                if let endRange = text[afterMarker...].range(of: "~~") {
                    let content = String(text[afterMarker..<endRange.lowerBound])
                    
                    // Recursively parse the content for nested formatting (bold, italic, etc.)
                    let parsedContent = parseMarkdown(
                        content,
                        baseFont: baseFont,
                        baseColor: baseColor,
                        inlineCodeBackgroundColor: inlineCodeBgColor,
                        codeBlockBackgroundColor: codeBlockBgColor,
                        codeTextColor: codeFgColor,
                        inlineCodeTextColor: inlineCodeFgColor,
                        addNewlinesAroundCodeBlocks: addNewlinesAroundCodeBlocks
                    )
                    
                    // Apply strikethrough to the parsed content
                    let strikethroughContent = NSMutableAttributedString(attributedString: parsedContent)
                    strikethroughContent.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: NSRange(location: 0, length: strikethroughContent.length))
                    
                    result.append(strikethroughContent)
                    
                    index = endRange.upperBound
                    continue
                }
            }
            
            // Regular character - add with base attributes
            result.append(NSAttributedString(string: String(text[index]), attributes: baseAttributes))
            index = text.index(after: index)
        }
        
        return result
    }
    
    // MARK: - Private Format Application Methods
    
    /// Helper function to create a font with both bold and italic traits
    private func createBoldItalicFont(size: CGFloat) -> UIFont {
        // Try multiple approaches to create bold+italic font
        
        // Approach 1: Use preferredFontDescriptor with both traits
        let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        if let boldItalicDescriptor = descriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            let font = UIFont(descriptor: boldItalicDescriptor, size: size)
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) && 
               font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                return font
            }
        }
        
        // Approach 2: Start from system font
        let systemFont = UIFont.systemFont(ofSize: size)
        if let boldItalicDescriptor = systemFont.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            let font = UIFont(descriptor: boldItalicDescriptor, size: size)
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) && 
               font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                return font
            }
        }
        
        // Approach 3: Start from bold font and add italic
        let boldFont = UIFont.boldSystemFont(ofSize: size)
        if let boldItalicDescriptor = boldFont.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            let font = UIFont(descriptor: boldItalicDescriptor, size: size)
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) && 
               font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                return font
            }
        }
        
        // Approach 4: Start from italic font and add bold
        let italicFont = UIFont.italicSystemFont(ofSize: size)
        if let boldItalicDescriptor = italicFont.fontDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            let font = UIFont(descriptor: boldItalicDescriptor, size: size)
            if font.fontDescriptor.symbolicTraits.contains(.traitBold) && 
               font.fontDescriptor.symbolicTraits.contains(.traitItalic) {
                return font
            }
        }
        
        // Approach 5: Create descriptor with explicit font attributes
        let fontAttributes: [UIFontDescriptor.AttributeName: Any] = [
            .family: systemFont.familyName,
            .traits: [
                UIFontDescriptor.TraitKey.symbolic: UIFontDescriptor.SymbolicTraits([.traitBold, .traitItalic]).rawValue
            ]
        ]
        let explicitDescriptor = UIFontDescriptor(fontAttributes: fontAttributes)
        let explicitFont = UIFont(descriptor: explicitDescriptor, size: size)
        if explicitFont.fontDescriptor.symbolicTraits.contains(.traitBold) && 
           explicitFont.fontDescriptor.symbolicTraits.contains(.traitItalic) {
            return explicitFont
        }
        
        // Approach 6: Use matrix transformation to simulate italic on bold font
        // This creates a visually italic font but we need to mark it specially
        let matrix = CGAffineTransform(a: 1, b: 0, c: CGFloat(tanf(Float(12 * Double.pi / 180))), d: 1, tx: 0, ty: 0)
        
        // Create a new descriptor that includes both the matrix AND the symbolic traits
        var matrixDescriptor = boldFont.fontDescriptor.withMatrix(matrix)
        
        // Try to add the italic trait to the matrix-transformed descriptor
        if let combinedDescriptor = matrixDescriptor.withSymbolicTraits([.traitBold, .traitItalic]) {
            return UIFont(descriptor: combinedDescriptor, size: size)
        }
        
        // Last resort: return the matrix-transformed bold font (visually italic but won't be detected as italic)
        return UIFont(descriptor: matrixDescriptor, size: size)
    }
    
    private func applyBoldFormat(to range: NSRange, in attributedString: NSMutableAttributedString, baseFont: UIFont) {
        let text = attributedString.string
        
        // First, add the custom bold attribute to the entire range for reliable tracking
        attributedString.addAttribute(RichTextFormatterManager.isBoldKey, value: true, range: range)
        
        // Check if italic is already applied (via custom attribute)
        var hasItalicInRange = false
        attributedString.enumerateAttribute(RichTextFormatterManager.isItalicKey, in: range, options: []) { value, _, stop in
            if let isItalic = value as? Bool, isItalic {
                hasItalicInRange = true
                stop.pointee = true
            }
        }
        
        attributedString.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            // Check if this subrange contains only emojis - if so, skip it
            let subText = (text as NSString).substring(with: subRange)
            if subText.containsOnlyEmojis() {
                return // Skip this subrange
            }
            
            let currentFont = (value as? UIFont) ?? baseFont
            // Check both font traits AND custom attribute for italic
            let hasItalicFromFont = currentFont.fontDescriptor.symbolicTraits.contains(.traitItalic)
            let hasItalic = hasItalicFromFont || hasItalicInRange
            let fontSize = currentFont.pointSize
            
            // Create the font with desired traits
            let newFont: UIFont
            if hasItalic {
                // Need bold + italic
                newFont = createBoldItalicFont(size: fontSize)
            } else {
                // Just need bold
                newFont = UIFont.boldSystemFont(ofSize: fontSize)
            }
            
            attributedString.addAttribute(.font, value: newFont, range: subRange)
        }
    }
    
    private func applyItalicFormat(to range: NSRange, in attributedString: NSMutableAttributedString, baseFont: UIFont) {
        let text = attributedString.string
        
        // First, add the custom italic attribute to the entire range for reliable tracking
        attributedString.addAttribute(RichTextFormatterManager.isItalicKey, value: true, range: range)
        
        // Check if bold is already applied (via custom attribute)
        var hasBoldInRange = false
        attributedString.enumerateAttribute(RichTextFormatterManager.isBoldKey, in: range, options: []) { value, _, stop in
            if let isBold = value as? Bool, isBold {
                hasBoldInRange = true
                stop.pointee = true
            }
        }
        
        attributedString.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            // Check if this subrange contains only emojis - if so, skip it
            let subText = (text as NSString).substring(with: subRange)
            if subText.containsOnlyEmojis() {
                return // Skip this subrange
            }
            
            let currentFont = (value as? UIFont) ?? baseFont
            // Check both font traits AND custom attribute for bold
            let hasBoldFromFont = currentFont.fontDescriptor.symbolicTraits.contains(.traitBold)
            let hasBold = hasBoldFromFont || hasBoldInRange
            let fontSize = currentFont.pointSize
            
            // Create the font with desired traits
            let newFont: UIFont
            if hasBold {
                // Need bold + italic
                newFont = createBoldItalicFont(size: fontSize)
            } else {
                // Just need italic
                newFont = UIFont.italicSystemFont(ofSize: fontSize)
            }
            
            attributedString.addAttribute(.font, value: newFont, range: subRange)
        }
    }
    
    private func applyUnderlineFormat(to range: NSRange, in attributedString: NSMutableAttributedString) {
        // Apply underline character-by-character, skipping emojis
        let text = attributedString.string
        
        // Use String.Index iteration to properly handle multi-byte emojis
        var currentIndex = text.startIndex
        let endIndex = text.index(text.startIndex, offsetBy: range.location + range.length, limitedBy: text.endIndex) ?? text.endIndex
        
        // Skip to the start of the range
        if range.location > 0 {
            currentIndex = text.index(text.startIndex, offsetBy: range.location, limitedBy: text.endIndex) ?? text.endIndex
        }
        
        while currentIndex < endIndex {
            let char = text[currentIndex]
            
            // Calculate NSRange for this character
            let charStartIndex = text.distance(from: text.startIndex, to: currentIndex)
            let nextIndex = text.index(after: currentIndex)
            let charLength = text.distance(from: currentIndex, to: nextIndex)
            let charRange = NSRange(location: charStartIndex, length: charLength)
            
            // Skip emojis - don't apply underline to them
            if !char.isEmoji {
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: charRange)
            }
            
            currentIndex = nextIndex
        }
    }
    
    private func applyStrikethroughFormat(to range: NSRange, in attributedString: NSMutableAttributedString) {
        // Apply strikethrough character-by-character, skipping emojis
        let text = attributedString.string
        
        // Use String.Index iteration to properly handle multi-byte emojis
        var currentIndex = text.startIndex
        let endIndex = text.index(text.startIndex, offsetBy: range.location + range.length, limitedBy: text.endIndex) ?? text.endIndex
        
        // Skip to the start of the range
        if range.location > 0 {
            currentIndex = text.index(text.startIndex, offsetBy: range.location, limitedBy: text.endIndex) ?? text.endIndex
        }
        
        while currentIndex < endIndex {
            let char = text[currentIndex]
            
            // Calculate NSRange for this character
            let charStartIndex = text.distance(from: text.startIndex, to: currentIndex)
            let nextIndex = text.index(after: currentIndex)
            let charLength = text.distance(from: currentIndex, to: nextIndex)
            let charRange = NSRange(location: charStartIndex, length: charLength)
            
            // Skip emojis - don't apply strikethrough to them
            if !char.isEmoji {
                attributedString.addAttribute(.strikethroughStyle, value: NSUnderlineStyle.single.rawValue, range: charRange)
            }
            
            currentIndex = nextIndex
        }
    }
    
    private func applyCodeFormat(to range: NSRange, in attributedString: NSMutableAttributedString) {
        // Apply inline code formatting - keep emojis as-is in composer
        // Emojis will be converted to shortcodes when sending (in convertToMarkdown)
        let monoFont = UIFont.monospacedSystemFont(ofSize: 15, weight: .regular)
        attributedString.addAttribute(.font, value: monoFont, range: range)
        attributedString.addAttribute(.backgroundColor, value: CometChatTheme.neutralColor300, range: range)
        attributedString.addAttribute(.foregroundColor, value: CometChatTheme.extendedPrimaryColor700, range: range)
        // Explicitly mark as inline code (NOT code block)
        attributedString.addAttribute(RichTextFormatterManager.isCodeBlockKey, value: false, range: range)
    }
    
    private func applyCodeBlockFormat(to range: NSRange, in attributedString: NSMutableAttributedString) {
        applyCodeFormat(to: range, in: attributedString)
    }
    
    /// Applies code block at cursor position (block-level format with continuation)
    /// Note: Background is handled by codeBlockBackgroundView in the composer, not by attributed string
    private func applyCodeBlockAtCursor(
        at position: Int,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont,
        selectedRange: NSRange
    ) -> NSMutableAttributedString {
        // Toggle code block mode if already active
        if isInCodeBlockMode {
            isInCodeBlockMode = false
            return attributedString
        }
        
        // Exit other modes if active
        isInBulletListMode = false
        isInNumberedListMode = false
        isInBlockquoteMode = false
        currentListNumber = 1
        isInCodeBlockMode = true
        
        let monoFont = UIFont.monospacedSystemFont(ofSize: baseFont.pointSize, weight: .regular)
        
        // If there's a selection, only apply monospace font to selected text
        if selectedRange.length > 0 {
            attributedString.addAttribute(.font, value: monoFont, range: selectedRange)
        }
        // If no selection, just enter code block mode - new text will use monospace font
        // Don't modify existing text
        
        return attributedString
    }
    
    private func applyLinkFormat(to range: NSRange, in attributedString: NSMutableAttributedString) {
        attributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: range)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
    }
    
    /// Applies bullet list at cursor position (Slack-like behavior)
    private func applyBulletListAtCursor(
        at position: Int,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont
    ) -> NSMutableAttributedString {
        // Toggle bullet list mode
        if isInBulletListMode {
            isInBulletListMode = false
            return attributedString
        }
        
        // Exit numbered list mode if active
        isInNumberedListMode = false
        currentListNumber = 1
        isInBulletListMode = true
        
        // Find start of current line
        let lineInfo = getLineInfo(at: position, in: attributedString.string)
        
        // Check if line has blockquote prefix and/or bullet
        let lineText = attributedString.length > 0 && lineInfo.length > 0 ?
            (attributedString.string as NSString).substring(with: NSRange(location: lineInfo.start, length: min(lineInfo.length, 10))) : ""
        
        // Determine insertion position based on existing formatting
        var insertPosition = lineInfo.start
        
        // Check for blockquote prefix "▎ "
        if lineText.hasPrefix("▎ ") {
            insertPosition = lineInfo.start + 2  // Insert after blockquote marker
            
            // Check if bullet already exists after blockquote
            if lineText.hasPrefix("▎ • ") {
                // Already has blockquote + bullet, don't add another
                return attributedString
            }
        } else if lineText.hasPrefix("• ") {
            // Already has bullet at start, don't add another
            return attributedString
        }
        
        // Insert bullet at determined position
        let bulletText = "• "
        attributedString.insert(NSAttributedString(string: bulletText, attributes: [
            .font: baseFont,
            .foregroundColor: UIColor.label
        ]), at: insertPosition)
        
        return attributedString
    }
    
    /// Applies numbered list at cursor position (Slack-like behavior)
    private func applyNumberedListAtCursor(
        at position: Int,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont
    ) -> NSMutableAttributedString {
        // Toggle numbered list mode
        if isInNumberedListMode {
            isInNumberedListMode = false
            currentListNumber = 1
            return attributedString
        }
        
        // Exit bullet list mode if active
        isInBulletListMode = false
        isInNumberedListMode = true
        
        // Determine the next number by scanning existing numbered list items
        currentListNumber = getNextNumberedListNumber(in: attributedString.string)
        
        // Find start of current line
        let lineInfo = getLineInfo(at: position, in: attributedString.string)
        
        // Check if line has blockquote prefix and/or number
        let lineText = attributedString.length > 0 && lineInfo.length > 0 ?
            (attributedString.string as NSString).substring(with: NSRange(location: lineInfo.start, length: min(lineInfo.length, 10))) : ""
        
        // Determine insertion position based on existing formatting
        var insertPosition = lineInfo.start
        
        // Check for blockquote prefix "▎ "
        if lineText.hasPrefix("▎ ") {
            insertPosition = lineInfo.start + 2  // Insert after blockquote marker
            
            // Check if number already exists after blockquote
            let afterBlockquote = String(lineText.dropFirst(2))
            let numberPattern = "^\\d+\\.\\s"
            if let regex = try? NSRegularExpression(pattern: numberPattern),
               regex.firstMatch(in: afterBlockquote, range: NSRange(location: 0, length: afterBlockquote.count)) != nil {
                // Already has blockquote + number, don't add another
                return attributedString
            }
        } else {
            // Check if line starts with a number (no blockquote)
            let numberPattern = "^\\d+\\.\\s"
            if let regex = try? NSRegularExpression(pattern: numberPattern),
               regex.firstMatch(in: lineText, range: NSRange(location: 0, length: lineText.count)) != nil {
                // Already has number, don't add another
                return attributedString
            }
        }
        
        // Insert number at determined position
        let numberText = "\(currentListNumber). "
        attributedString.insert(NSAttributedString(string: numberText, attributes: [
            .font: baseFont,
            .foregroundColor: UIColor.label
        ]), at: insertPosition)
        
        return attributedString
    }
    
    /// Scans the document for existing numbered list items and returns the next number
    /// - Parameter text: The full text content to scan
    /// - Returns: The next number to use (1 if no numbered lists exist, otherwise max + 1)
    private func getNextNumberedListNumber(in text: String) -> Int {
        // Pattern to match numbered list items: "1. ", "2. ", etc.
        // Also handles blockquote prefix: "▎ 1. ", "▎ 2. ", etc.
        let numberPattern = "(?:^|\\n)(?:▎\\s)?(\\d+)\\.\\s"
        
        guard let regex = try? NSRegularExpression(pattern: numberPattern, options: []) else {
            return 1
        }
        
        let nsString = text as NSString
        let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: nsString.length))
        
        // Find the highest number
        var maxNumber = 0
        for match in matches {
            if match.numberOfRanges > 1 {
                let numberRange = match.range(at: 1)
                let numberString = nsString.substring(with: numberRange)
                if let number = Int(numberString) {
                    maxNumber = max(maxNumber, number)
                }
            }
        }
        
        // Return max + 1, or 1 if no numbered lists exist
        return maxNumber + 1
    }
    
    /// Applies blockquote styling at cursor position
    /// Note: The visual bar is handled by blockquoteBarView in the composer
    private func applyBlockquoteAtCursor(
        at position: Int,
        in attributedString: NSMutableAttributedString,
        baseFont: UIFont
    ) -> NSMutableAttributedString {
        // Toggle blockquote mode if already active
        if isInBlockquoteMode {
            isInBlockquoteMode = false
            return attributedString
        }
        
        // Blockquote is compatible with lists - don't exit list modes
        isInBlockquoteMode = true
        
        // No text modification needed - the visual bar is handled by the composer's blockquoteBarView
        return attributedString
    }
    
    /// Gets line information (start position and length) for the line containing the given position
    private func getLineInfo(at position: Int, in text: String) -> (start: Int, length: Int) {
        guard !text.isEmpty else { return (0, 0) }
        
        let nsText = text as NSString
        let safePosition = min(position, nsText.length)
        
        // Find start of line
        var lineStart = safePosition
        while lineStart > 0 && nsText.character(at: lineStart - 1) != Character("\n").asciiValue! {
            lineStart -= 1
        }
        
        // Find end of line
        var lineEnd = safePosition
        while lineEnd < nsText.length && nsText.character(at: lineEnd) != Character("\n").asciiValue! {
            lineEnd += 1
        }
        
        return (lineStart, lineEnd - lineStart)
    }
    
    private func applyBulletListFormat(to range: NSRange, in attributedString: NSMutableAttributedString) {
        let text = (attributedString.string as NSString).substring(with: range)
        let lines = text.components(separatedBy: "\n")
        var formattedLines: [String] = []
        
        for line in lines {
            if !line.hasPrefix("• ") {
                formattedLines.append("• \(line)")
            } else {
                formattedLines.append(line)
            }
        }
        
        let formattedText = formattedLines.joined(separator: "\n")
        attributedString.replaceCharacters(in: range, with: formattedText)
    }
    
    private func applyNumberedListFormat(to range: NSRange, in attributedString: NSMutableAttributedString) {
        let text = (attributedString.string as NSString).substring(with: range)
        let lines = text.components(separatedBy: "\n")
        var formattedLines: [String] = []
        
        for (index, line) in lines.enumerated() {
            formattedLines.append("\(index + 1). \(line)")
        }
        
        let formattedText = formattedLines.joined(separator: "\n")
        attributedString.replaceCharacters(in: range, with: formattedText)
    }
    
    // MARK: - Private Format Removal Methods
    
    private func removeBoldFormat(from range: NSRange, in attributedString: NSMutableAttributedString, baseFont: UIFont) {
        // Remove the custom bold attribute
        attributedString.removeAttribute(RichTextFormatterManager.isBoldKey, range: range)
        
        // Check if italic is still applied (via custom attribute)
        var hasItalicInRange = false
        attributedString.enumerateAttribute(RichTextFormatterManager.isItalicKey, in: range, options: []) { value, _, stop in
            if let isItalic = value as? Bool, isItalic {
                hasItalicInRange = true
                stop.pointee = true
            }
        }
        
        attributedString.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            let currentFont = (value as? UIFont) ?? baseFont
            
            if hasItalicInRange {
                // Keep italic, remove bold
                let newFont = UIFont.italicSystemFont(ofSize: currentFont.pointSize)
                attributedString.addAttribute(.font, value: newFont, range: subRange)
            } else {
                var traits = currentFont.fontDescriptor.symbolicTraits
                traits.remove(.traitBold)
                
                if let newDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                    let newFont = UIFont(descriptor: newDescriptor, size: currentFont.pointSize)
                    attributedString.addAttribute(.font, value: newFont, range: subRange)
                } else {
                    // Fallback to base font without bold
                    attributedString.addAttribute(.font, value: baseFont, range: subRange)
                }
            }
        }
    }
    
    private func removeItalicFormat(from range: NSRange, in attributedString: NSMutableAttributedString, baseFont: UIFont) {
        // Remove the custom italic attribute
        attributedString.removeAttribute(RichTextFormatterManager.isItalicKey, range: range)
        
        // Check if bold is still applied (via custom attribute)
        var hasBoldInRange = false
        attributedString.enumerateAttribute(RichTextFormatterManager.isBoldKey, in: range, options: []) { value, _, stop in
            if let isBold = value as? Bool, isBold {
                hasBoldInRange = true
                stop.pointee = true
            }
        }
        
        attributedString.enumerateAttribute(.font, in: range, options: []) { value, subRange, _ in
            let currentFont = (value as? UIFont) ?? baseFont
            
            if hasBoldInRange {
                // Keep bold, remove italic
                let newFont = UIFont.boldSystemFont(ofSize: currentFont.pointSize)
                attributedString.addAttribute(.font, value: newFont, range: subRange)
            } else {
                var traits = currentFont.fontDescriptor.symbolicTraits
                traits.remove(.traitItalic)
                
                if let newDescriptor = currentFont.fontDescriptor.withSymbolicTraits(traits) {
                    let newFont = UIFont(descriptor: newDescriptor, size: currentFont.pointSize)
                    attributedString.addAttribute(.font, value: newFont, range: subRange)
                } else {
                    // Fallback to base font without italic
                    attributedString.addAttribute(.font, value: baseFont, range: subRange)
                }
            }
        }
    }
    
    private func removeUnderlineFormat(from range: NSRange, in attributedString: NSMutableAttributedString) {
        attributedString.removeAttribute(.underlineStyle, range: range)
    }
    
    private func removeStrikethroughFormat(from range: NSRange, in attributedString: NSMutableAttributedString) {
        attributedString.removeAttribute(.strikethroughStyle, range: range)
    }
    
    private func removeCodeFormat(from range: NSRange, in attributedString: NSMutableAttributedString, baseFont: UIFont) {
        // When removing code format, preserve bold/italic attributes
        // Check for custom bold/italic attributes and restore appropriate font
        var hasBoldInRange = false
        var hasItalicInRange = false
        
        attributedString.enumerateAttribute(RichTextFormatterManager.isBoldKey, in: range, options: []) { value, _, stop in
            if let isBold = value as? Bool, isBold {
                hasBoldInRange = true
                stop.pointee = true
            }
        }
        
        attributedString.enumerateAttribute(RichTextFormatterManager.isItalicKey, in: range, options: []) { value, _, stop in
            if let isItalic = value as? Bool, isItalic {
                hasItalicInRange = true
                stop.pointee = true
            }
        }
        
        // Determine the appropriate font based on preserved attributes
        let newFont: UIFont
        if hasBoldInRange && hasItalicInRange {
            newFont = createBoldItalicFont(size: baseFont.pointSize)
        } else if hasBoldInRange {
            newFont = UIFont.boldSystemFont(ofSize: baseFont.pointSize)
        } else if hasItalicInRange {
            newFont = UIFont.italicSystemFont(ofSize: baseFont.pointSize)
        } else {
            newFont = baseFont
        }
        
        attributedString.addAttribute(.font, value: newFont, range: range)
        attributedString.removeAttribute(.backgroundColor, range: range)
    }
    
    private func removeLinkFormat(from range: NSRange, in attributedString: NSMutableAttributedString) {
        attributedString.removeAttribute(.link, range: range)
        attributedString.removeAttribute(.underlineStyle, range: range)
    }
    
    private func removeBlockquoteFormat(from range: NSRange, in attributedString: NSMutableAttributedString) {
        // Remove paragraph style (indent), background color, and format tracking
        attributedString.removeAttribute(.paragraphStyle, range: range)
        attributedString.removeAttribute(.backgroundColor, range: range)
        attributedString.removeAttribute(RichTextFormatterManager.formatTypeKey, range: range)
    }
    
    // MARK: - Format Tracking
    
    private func addFormatTracking(_ format: FormatType, to range: NSRange, in attributedString: NSMutableAttributedString) {
        attributedString.enumerateAttribute(RichTextFormatterManager.formatTypeKey, in: range, options: []) { value, subRange, _ in
            var formats = (value as? Set<String>) ?? Set<String>()
            formats.insert(format.rawValue)
            attributedString.addAttribute(RichTextFormatterManager.formatTypeKey, value: formats, range: subRange)
        }
    }
    
    private func removeFormatTracking(_ format: FormatType, from range: NSRange, in attributedString: NSMutableAttributedString) {
        attributedString.enumerateAttribute(RichTextFormatterManager.formatTypeKey, in: range, options: []) { value, subRange, _ in
            var formats = (value as? Set<String>) ?? Set<String>()
            formats.remove(format.rawValue)
            if formats.isEmpty {
                attributedString.removeAttribute(RichTextFormatterManager.formatTypeKey, range: subRange)
            } else {
                attributedString.addAttribute(RichTextFormatterManager.formatTypeKey, value: formats, range: subRange)
            }
        }
    }
}

// MARK: - UIFont Extension for Traits

extension UIFont {
    /// Returns a new font with the specified symbolic traits added
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits) -> UIFont? {
        let combinedTraits = fontDescriptor.symbolicTraits.union(traits)
        guard let descriptor = fontDescriptor.withSymbolicTraits(combinedTraits) else {
            return nil
        }
        return UIFont(descriptor: descriptor, size: pointSize)
    }
}

/// Defines which formats are incompatible with each format type
/// Rules:
/// - Code block and blockquote are mutually exclusive (selecting one switches to the other - handled in handleFormatSelected)
/// - Code block disables inline formats (bold, italic, underline, strikethrough, inline code, link)
/// - Blockquote allows inline formats (bold, italic, underline, strikethrough, inline code) and allows switching to code block
/// - Blockquote only disables link (users don't send links in quotes)
/// - Lists allow all inline formats and can coexist with blockquote
struct FormatCompatibilityMatrix {
    
    /// Maps each format to its set of incompatible formats (formats that should be DISABLED)
    /// Note: Mutually exclusive formats (like codeBlock/blockquote) are NOT listed here
    /// because they can be clicked to SWITCH between modes, not disabled
    static let incompatibilities: [FormatType: Set<FormatType>] = [
        // Code block disables inline formats but NOT blockquote (clicking blockquote switches mode)
        .codeBlock: [.bold, .italic, .underline, .strikethrough, .code, .link],
        // Blockquote only disables link (NOT code block - clicking code block switches mode)
        .blockquote: [.link],
        // Lists allow all inline formats and blockquote, but disable code block
        .bulletList: [.codeBlock],
        .numberedList: [.codeBlock],
        // Inline formats don't disable anything
        .code: [],
        .bold: [],
        .italic: [],
        .underline: [],
        .strikethrough: [],
        .link: []
    ]
    
    /// Returns the set of formats incompatible with the given format
    static func getIncompatibleFormats(for format: FormatType) -> Set<FormatType> {
        return incompatibilities[format] ?? []
    }
}

/// Engine for evaluating format compatibility rules
public class FormatCompatibilityEngine {
    
    public init() { }
    
    /// Evaluates which formats should be disabled given the current active formats
    /// - Parameter activeFormats: The set of currently active formats
    /// - Returns: A set of formats that should be disabled
    public func getDisabledFormats(for activeFormats: Set<FormatType>) -> Set<FormatType> {
        var disabledFormats = Set<FormatType>()
        
        // If no formats are active, nothing is disabled
        guard !activeFormats.isEmpty else {
            return disabledFormats
        }
        
        // Collect all incompatible formats from all active formats
        for activeFormat in activeFormats {
            let incompatible = FormatCompatibilityMatrix.getIncompatibleFormats(for: activeFormat)
            disabledFormats.formUnion(incompatible)
        }
        
        return disabledFormats
    }
    
    /// Checks if a specific format is compatible with the current active formats
    /// - Parameters:
    ///   - format: The format to check
    ///   - activeFormats: The currently active formats
    /// - Returns: True if the format can be activated, false otherwise
    public func isCompatible(_ format: FormatType, with activeFormats: Set<FormatType>) -> Bool {
        // A format is compatible if it's not in the disabled set
        let disabledFormats = getDisabledFormats(for: activeFormats)
        return !disabledFormats.contains(format)
    }
    
    /// Returns all formats that are compatible with the given format
    /// - Parameter format: The format to check compatibility for
    /// - Returns: A set of compatible formats
    public func getCompatibleFormats(for format: FormatType) -> Set<FormatType> {
        let allFormats = Set(FormatType.allCases)
        let incompatible = FormatCompatibilityMatrix.getIncompatibleFormats(for: format)
        return allFormats.subtracting(incompatible).subtracting([format])
    }
}
