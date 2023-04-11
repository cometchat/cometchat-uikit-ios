//
//  CometChatThemeNew.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 15/03/22.
//

import Foundation
import UIKit

public class CometChatTheme {
    
    public static var typography: Typography = Typography()
    public static var palatte: Palette = Palette()
    
    public init() {}
    
    @discardableResult
    public init(typography: Typography, palatte: Palette) {
        CometChatTheme.typography = typography
        CometChatTheme.palatte = palatte
    }
    
    public static func defaultAppearance() {
        CometChatTheme.init(typography: typography, palatte: palatte)
    }
    
    public static func set(mode: UIUserInterfaceStyle, for window: UIWindow?) {
        if let window = window {
            window.overrideUserInterfaceStyle = mode
        }
    }
}
