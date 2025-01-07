//
//  CometChatColorExtensions.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 27/08/24.
//

import Foundation
import UIKit

extension UIColor {
    
    // Creates a dynamic color that adjusts based on the user interface style (light or dark mode)
    public static func dynamicColor(lightModeColor: UIColor, darkModeColor: UIColor) -> UIColor {
        return UIColor { traitCollection -> UIColor in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return darkModeColor
            default:
                return lightModeColor
            }
        }
    }
    
    // Mixes the current color with black by a given percentage
    func mixWithBlack(percentage: CGFloat) -> UIColor {
        return self.mixWithColor(.black, percentage: percentage)
    }
    
    // Mixes the current color with white by a given percentage
    func mixWithWhite(percentage: CGFloat) -> UIColor {
        return self.mixWithColor(.white, percentage: percentage)
    }
    
    // Helper method to mix the current color with another color by a given percentage
    private func mixWithColor(_ color: UIColor, percentage: CGFloat) -> UIColor {
        let percentage = max(min(percentage, 1.0), 0.0)
        
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0
        
        self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        
        let red = r1 + (r2 - r1) * percentage
        let green = g1 + (g2 - g1) * percentage
        let blue = b1 + (b2 - b1) * percentage
        let alpha = a1 + (a2 - a1) * percentage
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    //Convert hex string to UIColor
    public convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }

}

extension CGColor {
    
    /// Create a `CGColor` from a hex string.
    /// - Parameter hex: The hex color string (e.g., "#RRGGBB" or "RRGGBB" or "#RRGGBBAA" or "RRGGBBAA").
    static func fromHex(_ hex: String) -> CGColor? {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.hasPrefix("#") ? String(hexSanitized.dropFirst()) : hexSanitized
        
        var rgb: UInt64 = 0
        var length = hexSanitized.count
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r, g, b, a: CGFloat
        switch length {
        case 6: // RGB (e.g. "FF0000" for red)
            r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgb & 0x0000FF) / 255.0
            a = 1.0
        case 8: // RGBA (e.g. "FF0000FF" for red with full opacity)
            r = CGFloat((rgb & 0xFF000000) >> 24) / 255.0
            g = CGFloat((rgb & 0x00FF0000) >> 16) / 255.0
            b = CGFloat((rgb & 0x0000FF00) >> 8) / 255.0
            a = CGFloat(rgb & 0x000000FF) / 255.0
        default:
            return nil
        }
        
        return CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [r, g, b, a])
    }
    
    /// Returns the hex string representation of the `CGColor`.
    func toHex() -> String? {
        guard let components = self.components, components.count >= 3 else { return nil }
        
        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = components.count >= 4 ? components[3] : 1.0
        
        let rgb: Int = (Int(r * 255) << 24) | (Int(g * 255) << 16) | (Int(b * 255) << 8) | Int(a * 255)
        return String(format: "#%08X", rgb)
    }
}
