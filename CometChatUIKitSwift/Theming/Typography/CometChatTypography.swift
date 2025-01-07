//
//  CometChatTypography.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 27/08/24.
//

import Foundation
import UIKit


public class CometChatTypography {

    // Title Styles
    public class Title {
        public static var bold: UIFont = UIFont.systemFont(ofSize: 32, weight: .bold)
        public static var medium: UIFont = UIFont.systemFont(ofSize: 32, weight: .medium)
        public static var regular: UIFont = UIFont.systemFont(ofSize: 32, weight: .regular)
    }

    // Heading 1 Styles
    public class Heading1 {
        public static var bold: UIFont = UIFont.systemFont(ofSize: 24, weight: .bold)
        public static var medium: UIFont = UIFont.systemFont(ofSize: 24, weight: .medium)
        public static var regular: UIFont = UIFont.systemFont(ofSize: 24, weight: .regular)
    }

    // Heading 2 Styles
    public class Heading2 {
        public static var bold: UIFont = UIFont.systemFont(ofSize: 20, weight: .bold)
        public static var medium: UIFont = UIFont.systemFont(ofSize: 20, weight: .medium)
        public static var regular: UIFont = UIFont.systemFont(ofSize: 20, weight: .regular)
    }

    // Heading 3 Styles
    public class Heading3 {
        public static var bold: UIFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        public static var medium: UIFont = UIFont.systemFont(ofSize: 18, weight: .medium)
        public static var regular: UIFont = UIFont.systemFont(ofSize: 18, weight: .regular)
    }
    
    // Heading 4 Styles
    public class Heading4 {
        public static var bold: UIFont = UIFont.systemFont(ofSize: 16, weight: .bold)
        public static var medium: UIFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        public static var regular: UIFont = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    // Body Styles
    public class Body {
        public static var bold: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        public static var medium: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        public static var regular: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    // Caption 1 Styles
    public class Caption1 {
        public static var bold: UIFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        public static var medium: UIFont = UIFont.systemFont(ofSize: 12, weight: .medium)
        public static var regular: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
    }
    
    // Caption 2 Styles
    public class Caption2 {
        public static var bold: UIFont = UIFont.systemFont(ofSize: 10, weight: .bold)
        public static var medium: UIFont = UIFont.systemFont(ofSize: 10, weight: .medium)
        public static var regular: UIFont = UIFont.systemFont(ofSize: 10, weight: .regular)
    }
    
    // Button Styles
    public class Button {
        public static var bold: UIFont = UIFont.systemFont(ofSize: 14, weight: .bold)
        public static var medium: UIFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        public static var regular: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
    
    // Link Styles
    public class Link {
        public static var regular: UIFont = UIFont.systemFont(ofSize: 14, weight: .regular)
    }
}
