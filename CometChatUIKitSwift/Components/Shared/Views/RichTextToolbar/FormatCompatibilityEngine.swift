//
//  FormatCompatibilityEngine.swift
//  CometChatUIKitSwift
//
//  Created by Kiro on 29/01/26.
//

import Foundation

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
