//
//  Palette.swift
 
//
//  Created by Pushpsen Airekar on 29/03/22.
//

import Foundation
import UIKit
//#3399FF

public class Palette {
    
    public private(set) var background = UIColor(named: "background", in: Bundle.module, compatibleWith: nil) ?? .systemBackground
    public private(set) var primary: UIColor =  UIColor(named: "primary", in: Bundle.module, compatibleWith: nil) ?? .blue
    public private(set) var secondary: UIColor =  UIColor(named: "secondary", in: Bundle.module, compatibleWith: nil) ?? .lightGray
    public private(set) var error: UIColor =  UIColor(named: "error", in: Bundle.module, compatibleWith: nil) ?? .red
    public private(set) var success: UIColor =  UIColor(named: "success", in: Bundle.module, compatibleWith: nil) ?? .gray
    public private(set) var accent: UIColor =  UIColor(named: "accent", in: Bundle.module, compatibleWith: nil) ?? .gray
    
    var accent50: UIColor {
        get { accent.withAlphaComponent(0.04) }
        set { self.accent50 = newValue }
    }
    
    var accent100: UIColor {
        get { accent.withAlphaComponent(0.08) }
        set { self.accent100 = newValue }
    }
    
    public var accent200: UIColor {
        get { accent.withAlphaComponent(0.14) }
        set { self.accent200 = newValue }
    }
    
    public var accent300: UIColor {
        get { accent.withAlphaComponent(0.24) }
        set { self.accent300 = newValue }
    }
    
    public var accent400: UIColor {
        get { accent.withAlphaComponent(0.34) }
        set { self.accent400 = newValue }
    }
    
    public var accent500: UIColor {
        get { accent.withAlphaComponent(0.46) }
        set { self.accent500 = newValue }
    }
    
    public var accent600: UIColor {
        get { accent.withAlphaComponent(0.58) }
        set { self.accent600 = newValue }
    }
    
    public var accent700: UIColor {
        get { accent.withAlphaComponent(0.69) }
        set { self.accent700 = newValue }
    }
    
    public var accent800: UIColor {
        get { accent.withAlphaComponent(0.84) }
        set { self.accent800 = newValue }
    }
    
    public var accent900: UIColor {
        get { accent.withAlphaComponent(1) }
        set { self.accent900 = newValue }
    }
    
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
