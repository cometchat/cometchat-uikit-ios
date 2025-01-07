//
//  Typography.swift
 
//
//  Created by Pushpsen Airekar on 29/03/22.
//

import Foundation
import UIKit

public struct Typography {
    
    public private(set) var largeHeading = UIFont.systemFont(ofSize: 34, weight: .bold)
    public private(set) var largeHeading2 = UIFont.systemFont(ofSize: 22, weight: .bold)
    public private(set) var heading = UIFont.systemFont(ofSize: 17, weight: .semibold)
    public private(set) var name = UIFont.systemFont(ofSize: 20, weight: .medium)
    public private(set) var title1 = UIFont.systemFont(ofSize: 22, weight: .regular)
    public private(set) var title2 = UIFont.systemFont(ofSize: 17, weight: .medium)
    public private(set) var subtitle1 = UIFont.systemFont(ofSize: 15, weight: .regular)
    public private(set) var subtitle2 = UIFont.systemFont(ofSize: 13, weight: .regular)
    public private(set) var text1 = UIFont.systemFont(ofSize: 17, weight: .regular)
    public private(set) var text2 = UIFont.systemFont(ofSize: 15, weight: .medium)
    public private(set) var text3 = UIFont.systemFont(ofSize: 13, weight: .semibold)
    public private(set) var caption1 = UIFont.systemFont(ofSize: 13, weight: .medium)
    public private(set) var caption2 = UIFont.systemFont(ofSize: 11, weight: .medium)
 
    public init() {}
    
    @discardableResult
    public mutating func setFont(largeHeading: UIFont) -> Typography {
        self.largeHeading = largeHeading
        return self
    }
    
    @discardableResult
    public mutating func setFont(largeHeading2: UIFont) -> Typography {
        self.largeHeading2 = largeHeading2
        return self
    }
    
    @discardableResult
    public mutating func setFont(heading: UIFont) -> Typography {
        self.heading = heading
        return self
    }
    
    @discardableResult
    public mutating func setFont(name: UIFont) -> Typography {
        self.name = name
        return self
    }
    
    @discardableResult
    public mutating func setFont(title1: UIFont) -> Typography {
        self.title1 = title1
        return self
    }
    
    @discardableResult
    public mutating func setFont(title2: UIFont) -> Typography {
        self.title2 = title2
        return self
    }
    
    @discardableResult
    public mutating func setFont(subtitle1: UIFont) -> Typography {
        self.subtitle1 = subtitle1
        return self
    }
    
    @discardableResult
    public mutating func setFont(subtitle2: UIFont) -> Typography {
        self.subtitle2 = subtitle2
        return self
    }
    
    @discardableResult
    public mutating func setFont(caption1: UIFont) -> Typography {
        self.caption1 = caption1
        return self
    }
    
    @discardableResult
    public mutating func setFont(caption2: UIFont) -> Typography {
        self.caption2 = caption2
        return self
    }
    
    @discardableResult
    public mutating func setFont(text1: UIFont) -> Typography {
        self.text1 = text1
        return self
    }
    
    @discardableResult
    public mutating func setFont(text2: UIFont) -> Typography {
        self.text2 = text2
        return self
    }
    
    @discardableResult
    public mutating func setFont(text3: UIFont) -> Typography {
        self.text3 = text3
        return self
    }
    
    @discardableResult
    public  mutating func overrideFont(family: CometChatFontFamily) -> Typography {
        setFont(largeHeading: UIFont(name: CometChatFontFamily.bold, size: 34) ?? largeHeading)
        setFont(largeHeading: UIFont(name: CometChatFontFamily.bold, size: 22) ?? largeHeading2)
        setFont(heading: UIFont(name: CometChatFontFamily.bold, size: 22) ?? heading)
        setFont(name: UIFont(name: CometChatFontFamily.medium, size: 20) ?? name)
        setFont(title1: UIFont(name: CometChatFontFamily.regular, size: 22) ?? title1)
        setFont(title2: UIFont(name: CometChatFontFamily.regular, size: 17) ?? title2)
        setFont(subtitle1: UIFont(name: CometChatFontFamily.regular, size: 15) ?? subtitle1)
        setFont(subtitle2: UIFont(name: CometChatFontFamily.regular, size: 13) ?? subtitle2)
        setFont(caption1: UIFont(name: CometChatFontFamily.medium, size: 13) ?? caption1)
        setFont(caption2: UIFont(name: CometChatFontFamily.medium, size: 11) ?? caption2)
        setFont(text1: UIFont(name: CometChatFontFamily.regular, size: 17) ?? text1)
        setFont(text2: UIFont(name: CometChatFontFamily.medium, size: 15) ?? text2)
        setFont(text3: UIFont(name: CometChatFontFamily.medium, size: 13) ?? text3)
        return self
    }
}


public class CometChatFontFamily {
    
    static var regular: String = ""
    static var medium: String  = ""
    static var semibold: String  = ""
    static var bold: String  = ""
  
    public init() {}
    
    public init(regular: String, medium: String, semibold: String, bold: String) {
        CometChatFontFamily.regular = regular
        CometChatFontFamily.medium = medium
        CometChatFontFamily.semibold = semibold
        CometChatFontFamily.bold = bold
    }
    
    public init(regular: String, medium: String, bold: String) {
        CometChatFontFamily.regular = regular
        CometChatFontFamily.medium = medium
        CometChatFontFamily.semibold = medium
        CometChatFontFamily.bold = bold
    }
    
    public init(regular: String) {
        CometChatFontFamily.regular = regular
        CometChatFontFamily.medium = regular
        CometChatFontFamily.semibold = regular
        CometChatFontFamily.bold = regular
    }
    
}
