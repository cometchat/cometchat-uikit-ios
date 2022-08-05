//
//  Palette.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 29/03/22.
//

import Foundation
import UIKit



public struct Palette {
    
 //   static var mode: UIUserInterfaceStyle = .light

    var background: UIColor? = UIColor(named: "background", in: Bundle.module, compatibleWith: nil)
    
    var primary: UIColor? =  UIColor(named: "primary", in: Bundle.module, compatibleWith: nil)
    
    var secondary: UIColor? =  UIColor(named: "secondary", in: Bundle.module, compatibleWith: nil)
    
    var error: UIColor? =  UIColor(named: "error", in: Bundle.module, compatibleWith: nil)
    
    var success: UIColor? =  UIColor(named: "success", in: Bundle.module, compatibleWith: nil)
    
    var accent: UIColor? =  UIColor(named: "accent", in: Bundle.module, compatibleWith: nil)
    
    var accent50: UIColor? {
        return accent?.withAlphaComponent(0.04)
    }
    
    var accent100: UIColor? {
        return accent?.withAlphaComponent(0.08)
    }
    
    var accent200: UIColor? {
        return accent?.withAlphaComponent(0.14)
    }
    
    var accent300: UIColor? {
        return accent?.withAlphaComponent(0.24)
    }
    
    var accent400: UIColor? {
        return accent?.withAlphaComponent(0.34)
    }
    
    var accent500: UIColor? {
        return accent?.withAlphaComponent(0.46)
    }
    
    var accent600: UIColor? {
        return accent?.withAlphaComponent(0.58)
    }
    
    var accent700: UIColor? {
        return accent?.withAlphaComponent(0.69)
    }
    
    var accent800: UIColor? {
        return accent?.withAlphaComponent(0.84)
    }
    
    var accent900: UIColor? {
        return accent?.withAlphaComponent(1)
    }
    
    public init() {}
    
    @discardableResult
    public mutating func set(primary: UIColor) -> Palette {
        self.primary = primary
        return self
    }
    
    @discardableResult
    public mutating func set(secondary: UIColor) -> Palette {
        self.secondary = secondary
        return self
    }
    
    @discardableResult
    public mutating func set(background: UIColor) -> Palette {
        self.background = background
        return self
    }
    
    @discardableResult
    public mutating func set(error: UIColor) -> Palette {
        self.error = error
        return self
    }
    
    @discardableResult
    public mutating func set(success: UIColor) -> Palette {
        self.success = success
        return self
    }
    
    @discardableResult
    public mutating func set(accent: UIColor) -> Palette {
        self.accent = accent
        return self
    }
    
}
