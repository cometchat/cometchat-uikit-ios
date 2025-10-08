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
