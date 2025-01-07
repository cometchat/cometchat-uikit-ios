//
//  CometChatThemeNew.swift
 
//
//  Created by Pushpsen Airekar on 15/03/22.
//

import Foundation
import UIKit

public class CometChatTheme_v4 {
    
    public static var typography: Typography = Typography()
    public static var palatte: Palette = Palette()
    
    public init() {}
    
    @discardableResult
    public init(typography: Typography, palatte: Palette) {
        CometChatTheme_v4.typography = typography
        CometChatTheme_v4.palatte = palatte
    }
    
    public static func defaultAppearance() {
        CometChatTheme_v4.init(typography: Typography(), palatte: Palette())
    }
    
    public static func set(mode: UIUserInterfaceStyle, for window: UIWindow?) {
        if let window = window {
            window.overrideUserInterfaceStyle = mode
        }
    }
}
