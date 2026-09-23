//
//  CometChatTypography.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 27/08/24.
//

import Foundation
import UIKit


public class CometChatTypography {

    // MARK: - Font Configuration
    private static var customFontName: String?

    public static func setFont(name: String) {
        customFontName = name
    }

    // MARK: - Dynamic Type

    /// Whether the Kit's text scales with the reader's iOS text-size setting.
    ///
    /// Defaults to `true`. Every font in the Kit is produced by this class, so
    /// this one switch governs all of them.
    ///
    /// Turn it off only if scaled text breaks a layout you cannot adjust:
    ///
    /// ```swift
    /// CometChatTypography.isDynamicTypeEnabled = false
    /// ```
    ///
    /// Set it before any CometChat view is created. Fonts are resolved when a
    /// view is built, so flipping this later affects only views created after.
    public static var isDynamicTypeEnabled: Bool = true

    /// How far text may grow, as a multiple of its design size. Defaults to `2.0`.
    ///
    /// **2.0 is what WCAG 1.4.4 (Level AA) requires** — text resizable to 200%
    /// without loss of content or functionality.
    ///
    /// This started at 1.6 as a deliberately cautious first step, because the Kit
    /// lays out with fixed heights in a number of places and uncapped growth would
    /// clip text — which is worse for the reader than text that is merely small.
    /// It was raised to 2.0 once the accessibility audit (Track 1 A11Y4) measured
    /// what actually breaks: across every screen at the largest accessibility
    /// size, one clipped element. The caution was not vindicated by the evidence.
    ///
    /// A cap is still applied rather than none at all: iOS's largest accessibility
    /// sizes take 14pt body text past 50pt, roughly 2.8x, which no fixed-height
    /// layout survives.
    ///
    /// - Note: If you raise this further, re-run the A11Y4 audit suite. It is the
    ///   only thing that will tell you what the new value clips.
    public static var maximumScaleFactor: CGFloat = 2.0

    /// - Parameter traits: the trait collection to resolve the reader's text size
    ///   against. `nil` — the production path — means "whatever the app is set to
    ///   right now". It exists because `UIApplication.preferredContentSizeCategory`
    ///   is read-only, so without this seam the scaling curve could only be
    ///   asserted at whatever size the test machine happened to be running.
    internal static func setFont(
        size: CGFloat,
        weight: UIFont.Weight,
        compatibleWith traits: UITraitCollection? = nil
    ) -> UIFont {
        let baseFont: UIFont
        if let name = customFontName,
           let font = UIFont(name: name, size: size) {
            baseFont = font
        } else {
            // fallback to system font
            baseFont = UIFont.systemFont(ofSize: size, weight: weight)
        }

        guard isDynamicTypeEnabled else { return baseFont }

        // Scaled against .body's curve, which is the one tuned for reading — the
        // Kit is overwhelmingly running text, and using each level's own curve
        // would make headings and captions drift apart at large sizes.
        return UIFontMetrics.default.scaledFont(
            for: baseFont,
            maximumPointSize: size * maximumScaleFactor,
            compatibleWith: traits
        )
    }
    
    // MARK: - Typography Levels
    
    public class Title {
        private static var _bold: UIFont?
        public static var bold: UIFont {
            get { _bold ?? CometChatTypography.setFont(size: 32, weight: .bold) }
            set { _bold = newValue }
        }
        
        private static var _medium: UIFont?
        public static var medium: UIFont {
            get { _medium ?? CometChatTypography.setFont(size: 32, weight: .medium) }
            set { _medium = newValue }
        }
        
        private static var _regular: UIFont?
        public static var regular: UIFont {
            get { _regular ?? CometChatTypography.setFont(size: 32, weight: .regular) }
            set { _regular = newValue }
        }
    }
    
    public class Heading1 {
        private static var _bold: UIFont?
        public static var bold: UIFont {
            get { _bold ?? CometChatTypography.setFont(size: 24, weight: .bold) }
            set { _bold = newValue }
        }
        
        private static var _medium: UIFont?
        public static var medium: UIFont {
            get { _medium ?? CometChatTypography.setFont(size: 24, weight: .medium) }
            set { _medium = newValue }
        }
        
        private static var _regular: UIFont?
        public static var regular: UIFont {
            get { _regular ?? CometChatTypography.setFont(size: 24, weight: .regular) }
            set { _regular = newValue }
        }
    }
    
    public class Heading2 {
        private static var _bold: UIFont?
        public static var bold: UIFont {
            get { _bold ?? CometChatTypography.setFont(size: 20, weight: .bold) }
            set { _bold = newValue }
        }
        
        private static var _medium: UIFont?
        public static var medium: UIFont {
            get { _medium ?? CometChatTypography.setFont(size: 20, weight: .medium) }
            set { _medium = newValue }
        }
        
        private static var _regular: UIFont?
        public static var regular: UIFont {
            get { _regular ?? CometChatTypography.setFont(size: 20, weight: .regular) }
            set { _regular = newValue }
        }
    }
    
    public class Heading3 {
        private static var _bold: UIFont?
        public static var bold: UIFont {
            get { _bold ?? CometChatTypography.setFont(size: 18, weight: .bold) }
            set { _bold = newValue }
        }
        
        private static var _medium: UIFont?
        public static var medium: UIFont {
            get { _medium ?? CometChatTypography.setFont(size: 18, weight: .medium) }
            set { _medium = newValue }
        }
        
        private static var _regular: UIFont?
        public static var regular: UIFont {
            get { _regular ?? CometChatTypography.setFont(size: 18, weight: .regular) }
            set { _regular = newValue }
        }
    }
    
    public class Heading4 {
        private static var _bold: UIFont?
        public static var bold: UIFont {
            get { _bold ?? CometChatTypography.setFont(size: 16, weight: .bold) }
            set { _bold = newValue }
        }
        
        private static var _medium: UIFont?
        public static var medium: UIFont {
            get { _medium ?? CometChatTypography.setFont(size: 16, weight: .medium) }
            set { _medium = newValue }
        }
        
        private static var _regular: UIFont?
        public static var regular: UIFont {
            get { _regular ?? CometChatTypography.setFont(size: 16, weight: .regular) }
            set { _regular = newValue }
        }
    }
    
    public class Body {
        private static var _bold: UIFont?
        public static var bold: UIFont {
            get { _bold ?? CometChatTypography.setFont(size: 14, weight: .bold) }
            set { _bold = newValue }
        }
        
        private static var _medium: UIFont?
        public static var medium: UIFont {
            get { _medium ?? CometChatTypography.setFont(size: 14, weight: .medium) }
            set { _medium = newValue }
        }
        
        private static var _regular: UIFont?
        public static var regular: UIFont {
            get { _regular ?? CometChatTypography.setFont(size: 14, weight: .regular) }
            set { _regular = newValue }
        }
    }
    
    public class Caption1 {
        private static var _bold: UIFont?
        public static var bold: UIFont {
            get { _bold ?? CometChatTypography.setFont(size: 12, weight: .bold) }
            set { _bold = newValue }
        }
        
        private static var _medium: UIFont?
        public static var medium: UIFont {
            get { _medium ?? CometChatTypography.setFont(size: 12, weight: .medium) }
            set { _medium = newValue }
        }
        
        private static var _regular: UIFont?
        public static var regular: UIFont {
            get { _regular ?? CometChatTypography.setFont(size: 12, weight: .regular) }
            set { _regular = newValue }
        }
    }
    
    public class Caption2 {
        private static var _bold: UIFont?
        public static var bold: UIFont {
            get { _bold ?? CometChatTypography.setFont(size: 10, weight: .bold) }
            set { _bold = newValue }
        }
        
        private static var _medium: UIFont?
        public static var medium: UIFont {
            get { _medium ?? CometChatTypography.setFont(size: 10, weight: .medium) }
            set { _medium = newValue }
        }
        
        private static var _regular: UIFont?
        public static var regular: UIFont {
            get { _regular ?? CometChatTypography.setFont(size: 10, weight: .regular) }
            set { _regular = newValue }
        }
    }
    
    public class Button {
        private static var _bold: UIFont?
        public static var bold: UIFont {
            get { _bold ?? CometChatTypography.setFont(size: 14, weight: .bold) }
            set { _bold = newValue }
        }
        
        private static var _medium: UIFont?
        public static var medium: UIFont {
            get { _medium ?? CometChatTypography.setFont(size: 14, weight: .medium) }
            set { _medium = newValue }
        }
        
        private static var _regular: UIFont?
        public static var regular: UIFont {
            get { _regular ?? CometChatTypography.setFont(size: 14, weight: .regular) }
            set { _regular = newValue }
        }
    }
    
    public class Link {
        private static var _regular: UIFont?
        public static var regular: UIFont {
            get { _regular ?? CometChatTypography.setFont(size: 14, weight: .regular) }
            set { _regular = newValue }
        }
    }
}
