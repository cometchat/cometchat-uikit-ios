//
//  Palette.swift
 
//
//  Created by Pushpsen Airekar on 29/03/22.
//

import Foundation
import UIKit
//#3399FF

public class Palette {
    
    public private(set) var background = UIColor(named: "background", in: CometChatUIKit.bundle, compatibleWith: nil) ?? .systemBackground
    public private(set) var primary: UIColor =  UIColor(named: "primary", in: CometChatUIKit.bundle, compatibleWith: nil) ?? .blue
    public private(set) var secondary: UIColor =  UIColor(named: "secondary", in: CometChatUIKit.bundle, compatibleWith: nil) ?? .lightGray
    public private(set) var error: UIColor =  UIColor(named: "error", in: CometChatUIKit.bundle, compatibleWith: nil) ?? .red
    public private(set) var success: UIColor =  UIColor(named: "success", in: CometChatUIKit.bundle, compatibleWith: nil) ?? .gray
    public private(set) var accent: UIColor =  UIColor(named: "accent", in: CometChatUIKit.bundle, compatibleWith: nil) ?? .gray
    
    lazy public var accent50: UIColor = accent.withAlphaComponent(0.04)
    lazy public var accent100: UIColor = accent.withAlphaComponent(0.08)
    lazy public var accent200: UIColor = accent.withAlphaComponent(0.14)
    lazy public var accent300: UIColor = accent.withAlphaComponent(0.24)
    lazy public var accent400: UIColor = accent.withAlphaComponent(0.34)
    lazy public var accent500: UIColor = accent.withAlphaComponent(0.46)
    lazy public var accent600: UIColor = accent.withAlphaComponent(0.58)
    lazy public var accent700: UIColor = accent.withAlphaComponent(0.69)
    lazy public var accent800: UIColor = accent.withAlphaComponent(0.84)
    lazy public var accent900: UIColor = accent.withAlphaComponent(1)
    
    public init() {}
    
    @discardableResult
    public func set(primary: UIColor) -> Palette {
        self.primary = primary
        return self
    }
    
    @discardableResult
    public func set(secondary: UIColor) -> Palette {
        self.secondary = secondary
        return self
    }
    
    @discardableResult
    public func set(background: UIColor) -> Palette {
        self.background = background
        return self
    }
    
    @discardableResult
    public func set(error: UIColor) -> Palette {
        self.error = error
        return self
    }
    
    @discardableResult
    public func set(success: UIColor) -> Palette {
        self.success = success
        return self
    }
    
    @discardableResult
    public func set(accent: UIColor) -> Palette {
        self.accent = accent
        return self
    }
    
    @discardableResult
    public  func set(accent50: UIColor) -> Palette {
        self.accent50 = accent
        return self
    }
    
    @discardableResult
    public  func set(accent100: UIColor) -> Palette {
        self.accent100 = accent
        return self
    }
    
    @discardableResult
    public  func set(accent200: UIColor) -> Palette {
        self.accent200 = accent
        return self
    }
    
    @discardableResult
    public  func set(accent300: UIColor) -> Palette {
        self.accent300 = accent
        return self
    }
    
    @discardableResult
    public  func set(accent400: UIColor) -> Palette {
        self.accent400 = accent
        return self
    }
    
    @discardableResult
    public  func set(accent500: UIColor) -> Palette {
        self.accent500 = accent
        return self
    }
    
    @discardableResult
    public  func set(accent600: UIColor) -> Palette {
        self.accent600 = accent
        return self
    }
    
    @discardableResult
    public  func set(accent700: UIColor) -> Palette {
        self.accent700 = accent
        return self
    }
    
    @discardableResult
    public  func set(accent800: UIColor) -> Palette {
        self.accent800 = accent
        return self
    }
    
    @discardableResult
    public  func set(accent900: UIColor) -> Palette {
        self.accent900 = accent
        return self
    }
}
