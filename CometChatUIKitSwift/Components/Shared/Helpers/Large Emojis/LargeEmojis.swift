//
//  LargeEmojis.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 02/02/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation

extension String {
    func containsOnlyEmojis() -> Bool {
        if count == 0 {
            return false
        }
        for character in self {
            if !character.isEmoji {
                return false
            }
        }
        return true
    }

    func containsEmoji() -> Bool {
        for character in self {
            if character.isEmoji {
                return true
            }
        }
        return false
    }
    
    /// Converts emojis in the string to their shortcode format (e.g., 😀 -> :grinning_face:)
    /// Uses Unicode names for the shortcodes
    func emojisToShortcodes() -> String {
        var result = ""
        for character in self {
            if character.isEmoji {
                result += character.emojiShortcode
            } else {
                result += String(character)
            }
        }
        return result
    }
    
    /// Converts shortcodes in the string back to emojis (e.g., :grinning_face: -> 😀)
    /// Uses Unicode names to find the matching emoji
    func shortcodesToEmojis() -> String {
        var result = self
        
        // Find all shortcodes in the format :name:
        let pattern = ":([a-z0-9_]+):"
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return result
        }
        
        let nsString = result as NSString
        let matches = regex.matches(in: result, options: [], range: NSRange(location: 0, length: nsString.length))
        
        // Process matches in reverse order to preserve indices
        for match in matches.reversed() {
            let shortcodeRange = match.range
            let shortcode = nsString.substring(with: shortcodeRange)
            
            // Extract the name from :name:
            let nameRange = match.range(at: 1)
            let name = nsString.substring(with: nameRange)
            
            // Convert shortcode name back to Unicode name format
            let unicodeName = name
                .uppercased()
                .replacingOccurrences(of: "_", with: " ")
            
            // Try to find the emoji by Unicode name
            if let emoji = String.emojiFromUnicodeName(unicodeName) {
                result = (result as NSString).replacingCharacters(in: shortcodeRange, with: emoji)
            }
        }
        
        return result
    }
    
    /// Finds an emoji by its Unicode name
    /// - Parameter name: The Unicode name (e.g., "GRINNING FACE")
    /// - Returns: The emoji character if found, nil otherwise
    static func emojiFromUnicodeName(_ name: String) -> String? {
        // Iterate through common emoji ranges to find a match
        // This covers most common emojis
        let emojiRanges: [ClosedRange<UInt32>] = [
            0x1F600...0x1F64F, // Emoticons
            0x1F300...0x1F5FF, // Misc Symbols and Pictographs
            0x1F680...0x1F6FF, // Transport and Map
            0x1F700...0x1F77F, // Alchemical Symbols
            0x1F780...0x1F7FF, // Geometric Shapes Extended
            0x1F800...0x1F8FF, // Supplemental Arrows-C
            0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
            0x1FA00...0x1FA6F, // Chess Symbols
            0x1FA70...0x1FAFF, // Symbols and Pictographs Extended-A
            0x2600...0x26FF,   // Misc symbols
            0x2700...0x27BF,   // Dingbats
            0x231A...0x231B,   // Watch, Hourglass
            0x23E9...0x23F3,   // Various symbols
            0x23F8...0x23FA,   // Various symbols
            0x25AA...0x25AB,   // Squares
            0x25B6...0x25C0,   // Triangles
            0x25FB...0x25FE,   // Squares
            0x2614...0x2615,   // Umbrella, Hot Beverage
            0x2648...0x2653,   // Zodiac
            0x267F...0x267F,   // Wheelchair
            0x2693...0x2693,   // Anchor
            0x26A1...0x26A1,   // High Voltage
            0x26AA...0x26AB,   // Circles
            0x26BD...0x26BE,   // Soccer, Baseball
            0x26C4...0x26C5,   // Snowman, Sun
            0x26CE...0x26CE,   // Ophiuchus
            0x26D4...0x26D4,   // No Entry
            0x26EA...0x26EA,   // Church
            0x26F2...0x26F3,   // Fountain, Golf
            0x26F5...0x26F5,   // Sailboat
            0x26FA...0x26FA,   // Tent
            0x26FD...0x26FD,   // Fuel Pump
            0x2702...0x2702,   // Scissors
            0x2705...0x2705,   // Check Mark
            0x2708...0x270D,   // Various
            0x270F...0x270F,   // Pencil
            0x2712...0x2712,   // Black Nib
            0x2714...0x2714,   // Check Mark
            0x2716...0x2716,   // X Mark
            0x271D...0x271D,   // Latin Cross
            0x2721...0x2721,   // Star of David
            0x2728...0x2728,   // Sparkles
            0x2733...0x2734,   // Eight Spoked Asterisk
            0x2744...0x2744,   // Snowflake
            0x2747...0x2747,   // Sparkle
            0x274C...0x274C,   // Cross Mark
            0x274E...0x274E,   // Cross Mark
            0x2753...0x2755,   // Question Marks
            0x2757...0x2757,   // Exclamation Mark
            0x2763...0x2764,   // Heart Exclamation, Heart
            0x2795...0x2797,   // Plus, Minus, Divide
            0x27A1...0x27A1,   // Right Arrow
            0x27B0...0x27B0,   // Curly Loop
            0x27BF...0x27BF,   // Double Curly Loop
            0x2934...0x2935,   // Arrows
            0x2B05...0x2B07,   // Arrows
            0x2B1B...0x2B1C,   // Squares
            0x2B50...0x2B50,   // Star
            0x2B55...0x2B55,   // Circle
            0x3030...0x3030,   // Wavy Dash
            0x303D...0x303D,   // Part Alternation Mark
            0x3297...0x3297,   // Circled Ideograph Congratulation
            0x3299...0x3299,   // Circled Ideograph Secret
        ]
        
        for range in emojiRanges {
            for codePoint in range {
                guard let scalar = Unicode.Scalar(codePoint) else { continue }
                if let scalarName = scalar.properties.name {
                    // Compare names (case-insensitive, normalize spaces)
                    let normalizedScalarName = scalarName.uppercased()
                    let normalizedSearchName = name.uppercased()
                    if normalizedScalarName == normalizedSearchName {
                        return String(Character(scalar))
                    }
                }
            }
        }
        
        return nil
    }
}

extension Character {
    // An emoji can either be a 2 byte unicode character or a normal UTF8 character with an emoji modifier
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
    
    /// Returns the shortcode representation of an emoji character
    /// Uses the Unicode name converted to a shortcode format
    var emojiShortcode: String {
        let scalars = unicodeScalars
        guard let firstScalar = scalars.first else { return String(self) }
        
        // Get the Unicode name and convert to shortcode format
        if let name = firstScalar.properties.name {
            let shortcode = name
                .lowercased()
                .replacingOccurrences(of: " ", with: "_")
                .replacingOccurrences(of: "-", with: "_")
                .replacingOccurrences(of: ",", with: "")
                .replacingOccurrences(of: "'", with: "")
                .replacingOccurrences(of: ":", with: "")
            return ":\(shortcode):"
        }
        
        // Fallback: use Unicode code points
        let codePoints = scalars.map { String(format: "%04X", $0.value) }.joined(separator: "_")
        return ":u\(codePoints):"
    }
}
