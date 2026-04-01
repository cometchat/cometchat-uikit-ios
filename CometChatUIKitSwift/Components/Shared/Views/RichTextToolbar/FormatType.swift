//
//  FormatType.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 29/01/26.
//

import Foundation
import UIKit

/// Represents the available rich text formatting options
public enum FormatType: String, CaseIterable {
    case bold
    case italic
    case underline
    case strikethrough
    case link
    case numberedList
    case bulletList
    case blockquote
    case code
    case codeBlock
    
    /// The markdown prefix/suffix for this format type
    var markdownSyntax: MarkdownSyntax {
        switch self {
        case .bold:
            return MarkdownSyntax(prefix: "**", suffix: "**")
        case .italic:
            return MarkdownSyntax(prefix: "_", suffix: "_")
        case .underline:
            return MarkdownSyntax(prefix: "<u>", suffix: "</u>")
        case .strikethrough:
            return MarkdownSyntax(prefix: "~~", suffix: "~~")
        case .code:
            return MarkdownSyntax(prefix: "`", suffix: "`")
        case .codeBlock:
            return MarkdownSyntax(prefix: "```\n", suffix: "\n```")
        case .link:
            return MarkdownSyntax(prefix: "[", suffix: "](url)")
        case .bulletList:
            return MarkdownSyntax(prefix: "- ", suffix: "", isLinePrefix: true)
        case .numberedList:
            return MarkdownSyntax(prefix: "1. ", suffix: "", isLinePrefix: true, isNumbered: true)
        case .blockquote:
            return MarkdownSyntax(prefix: "> ", suffix: "", isLinePrefix: true)
        }
    }
    
    /// Custom image name from messages-assets.xcassets (nil if using SF Symbol)
    var customImageName: String? {
        switch self {
        case .blockquote: return "blockQuoteFormatter"
        case .codeBlock: return "codeBlockFormatter"
        case .code: return "codeFormatter"
        case .link: return "linkFormatter"
        case .numberedList: return "numberListFormatter"
        default: return nil
        }
    }
    
    /// SF Symbol name for the format button icon (used as fallback)
    var iconName: String {
        switch self {
        case .bold: return "bold"
        case .italic: return "italic"
        case .underline: return "underline"
        case .strikethrough: return "strikethrough"
        case .link: return "link"
        case .numberedList: return "list.number"
        case .bulletList: return "list.bullet"
        case .blockquote: return "text.quote"
        case .code: return "chevron.left.forwardslash.chevron.right"
        case .codeBlock: return "curlybraces.square"
        }
    }
    
    /// Returns the appropriate image for this format type
    /// Uses custom image from assets if available, otherwise falls back to SF Symbol
    var image: UIImage? {
        if let customName = customImageName {
            return UIImage(named: customName, in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
        }
        return UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate)
    }
    
    /// Accessibility label for the format button
    var accessibilityLabel: String {
        switch self {
        case .bold: return "Bold"
        case .italic: return "Italic"
        case .underline: return "Underline"
        case .strikethrough: return "Strikethrough"
        case .link: return "Insert Link"
        case .numberedList: return "Numbered List"
        case .bulletList: return "Bullet List"
        case .blockquote: return "Blockquote"
        case .code: return "Inline Code"
        case .codeBlock: return "Code Block"
        }
    }
}

/// Represents the markdown syntax for a format type
public struct MarkdownSyntax {
    let prefix: String
    let suffix: String
    var isLinePrefix: Bool = false
    var isNumbered: Bool = false
}
