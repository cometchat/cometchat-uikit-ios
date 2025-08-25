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
    
    internal static func setFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        if let name = customFontName,
           let font = UIFont(name: name, size: size) {
            return font
        } else {
            // fallback to system font
            return UIFont.systemFont(ofSize: size, weight: weight)
        }
    }
    
    // MARK: - Typography Levels
    
    public class Title {
        public static var bold: UIFont { CometChatTypography.setFont(size: 32, weight: .bold) }
        public static var medium: UIFont { CometChatTypography.setFont(size: 32, weight: .medium) }
        public static var regular: UIFont { CometChatTypography.setFont(size: 32, weight: .regular) }
    }
    
    public class Heading1 {
        public static var bold: UIFont { CometChatTypography.setFont(size: 24, weight: .bold) }
        public static var medium: UIFont { CometChatTypography.setFont(size: 24, weight: .medium) }
        public static var regular: UIFont { CometChatTypography.setFont(size: 24, weight: .regular) }
    }
    
    public class Heading2 {
        public static var bold: UIFont { CometChatTypography.setFont(size: 20, weight: .bold) }
        public static var medium: UIFont { CometChatTypography.setFont(size: 20, weight: .medium) }
        public static var regular: UIFont { CometChatTypography.setFont(size: 20, weight: .regular) }
    }

    // Heading 3 Styles
    public class Heading3 {
        public static var bold: UIFont { CometChatTypography.setFont(size: 18, weight: .bold) }
        public static var medium: UIFont { CometChatTypography.setFont(size: 18, weight: .medium) }
        public static var regular: UIFont { CometChatTypography.setFont(size: 18, weight: .regular) }
    }
    
    // Heading 4 Styles
    public class Heading4 {
        public static var bold: UIFont { CometChatTypography.setFont(size: 16, weight: .bold) }
        public static var medium: UIFont { CometChatTypography.setFont(size: 16, weight: .medium) }
        public static var regular: UIFont { CometChatTypography.setFont(size: 16, weight: .regular) }
    }
    
    // Body Styles
    public class Body {
        public static var bold: UIFont { CometChatTypography.setFont(size: 14, weight: .bold) }
        public static var medium: UIFont { CometChatTypography.setFont(size: 14, weight: .medium) }
        public static var regular: UIFont { CometChatTypography.setFont(size: 14, weight: .regular) }
    }
    
    // Caption 1 Styles
    public class Caption1 {
        public static var bold: UIFont { CometChatTypography.setFont(size: 12, weight: .bold) }
        public static var medium: UIFont { CometChatTypography.setFont(size: 12, weight: .medium) }
        public static var regular: UIFont { CometChatTypography.setFont(size: 12, weight: .regular) }
    }
    
    // Caption 2 Styles
    public class Caption2 {
        public static var bold: UIFont { CometChatTypography.setFont(size: 10, weight: .bold) }
        public static var medium: UIFont { CometChatTypography.setFont(size: 10, weight: .medium) }
        public static var regular: UIFont { CometChatTypography.setFont(size: 10, weight: .regular) }
    }
    
    // Button Styles
    public class Button {
        public static var bold: UIFont { CometChatTypography.setFont(size: 14, weight: .bold) }
        public static var medium: UIFont { CometChatTypography.setFont(size: 14, weight: .medium) }
        public static var regular: UIFont { CometChatTypography.setFont(size: 14, weight: .regular) }
    }
    
    // Link Styles
    public class Link {
        public static var regular: UIFont { CometChatTypography.setFont(size: 14, weight: .regular) }
    }
}
