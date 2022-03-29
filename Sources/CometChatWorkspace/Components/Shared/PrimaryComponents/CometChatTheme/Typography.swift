//
//  Typography.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 29/03/22.
//

import Foundation
import UIKit

struct Typography {
    
    var Heading: UIFont = UIFont.systemFont(ofSize: 34, weight: .bold)
    
    var Name1: UIFont  = UIFont.systemFont(ofSize: 20, weight: .medium)
    
    var Name2: UIFont = UIFont.systemFont(ofSize: 17, weight: .medium)
    
    var Title1: UIFont = UIFont.systemFont(ofSize: 22, weight: .regular)
    
    var Title2: UIFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
    
    var Subtitle1: UIFont = UIFont.systemFont(ofSize: 15, weight: .regular)
    
    var Subtitle2: UIFont = UIFont.systemFont(ofSize: 13, weight: .regular)
    
    var Caption1: UIFont = UIFont.systemFont(ofSize: 13, weight: .medium)
    
    var Caption2: UIFont = UIFont.systemFont(ofSize: 11, weight: .medium)
    

    
    @discardableResult
    public mutating func setFont(heading: UIFont) -> Typography {
        self.Heading = heading
        return self
    }
    
    @discardableResult
    public mutating func setFont(name1: UIFont) -> Typography {
        self.Name1 = name1
        return self
    }
    
    @discardableResult
    public mutating func setFont(name2: UIFont) -> Typography {
        self.Name2 = name2
        return self
    }
    
    @discardableResult
    public mutating func setFont(title1: UIFont) -> Typography {
        self.Title1 = title1
        return self
    }
    
    @discardableResult
    public mutating func setFont(title2: UIFont) -> Typography {
        self.Title2 = title2
        return self
    }
    
    @discardableResult
    public mutating func setFont(subtitle1: UIFont) -> Typography {
        self.Subtitle1 = subtitle1
        return self
    }
    
    @discardableResult
    public mutating func setFont(subtitle2: UIFont) -> Typography {
        self.Subtitle2 = subtitle2
        return self
    }
    
    @discardableResult
    public mutating func setFont(caption1: UIFont) -> Typography {
        self.Caption1 = caption1
        return self
    }
    
    @discardableResult
    public mutating func setFont(caption2: UIFont) -> Typography {
        self.Caption2 = caption2
        return self
    }
    
    @discardableResult
    public  mutating func overrideFont(family: CometChatFontFamily) -> Typography {
        setFont(heading: UIFont(name: CometChatFontFamily.bold, size: 34) ?? UIFont.systemFont(ofSize: 34, weight: .bold))
        setFont(name1: UIFont(name: CometChatFontFamily.medium, size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium))
        setFont(name2: UIFont(name: CometChatFontFamily.medium, size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .medium))
        setFont(title1: UIFont(name: CometChatFontFamily.regular, size: 22) ?? UIFont.systemFont(ofSize: 22, weight: .regular))
        setFont(title2: UIFont(name: CometChatFontFamily.regular, size: 17) ?? UIFont.systemFont(ofSize: 17, weight: .regular))
        setFont(subtitle1: UIFont(name: CometChatFontFamily.regular, size: 15) ?? UIFont.systemFont(ofSize: 15, weight: .regular))
        setFont(subtitle2: UIFont(name: CometChatFontFamily.regular, size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .regular))
        setFont(caption1: UIFont(name: CometChatFontFamily.medium, size: 13) ?? UIFont.systemFont(ofSize: 13, weight: .medium))
        setFont(caption2: UIFont(name: CometChatFontFamily.medium, size: 11) ?? UIFont.systemFont(ofSize: 11, weight: .medium))
        return self
    }
    
    
}


public class CometChatFontFamily {
    
    static var regular: String = ""
    static var medium: String  = ""
    static var semibold: String  = ""
    static var bold: String  = ""
  
    
    init(regular: String, medium: String, semibold: String, bold: String) {
        CometChatFontFamily.regular = regular
        CometChatFontFamily.medium = medium
        CometChatFontFamily.semibold = semibold
        CometChatFontFamily.bold = bold
    }
    
    init(regular: String, medium: String, bold: String) {
        CometChatFontFamily.regular = regular
        CometChatFontFamily.medium = medium
        CometChatFontFamily.semibold = medium
        CometChatFontFamily.bold = bold
    }
    
    init(regular: String) {
        CometChatFontFamily.regular = regular
        CometChatFontFamily.medium = regular
        CometChatFontFamily.semibold = regular
        CometChatFontFamily.bold = regular
    }
    
}

