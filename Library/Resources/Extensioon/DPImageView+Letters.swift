//
//  DPImageView+Letters.swift
//  CometChatPro-CachingExtension-SampleApp
//
//  Created by CometChat Inc. on 09/07/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.
//

import Foundation

import Foundation
import UIKit

extension UIImageView {
    
    /// Sets the image property of the view based on initial text, a specified background color, custom text attributes, and a circular clipping
    ///
    /// - Parameters:
    ///   - string: The string used to generate the initials. This should be a user's full name if available.
    ///   - color: This optional paramter sets the background of the image. By default, a random color will be generated.
    ///   - circular: This boolean will determine if the image view will be clipped to a circular shape.
    ///   - textAttributes: This dictionary allows you to specify font, text color, shadow properties, etc.
    open func setImage(string: String?,
                       color: UIColor? = nil,
                       circular: Bool = false,
                       stroke: Bool = false,
                       textAttributes: [NSAttributedString.Key: Any]? = nil) {
        
        let image = imageSnap(text: string != nil ? string?.initials : "",
                              color: UIKitSettings.primaryColor,
                              circular: circular,
                              stroke: stroke,
                              textAttributes:textAttributes)
        
        if let newImage = image {
            self.image = newImage
        }
    }
    
    private func imageSnap(text: String?,
                           color: UIColor,
                           circular: Bool,
                           stroke: Bool,
                           textAttributes: [NSAttributedString.Key: Any]?) -> UIImage? {
        
        let scale = Float(UIScreen.main.scale)
        var size = bounds.size
        if contentMode == .scaleToFill || contentMode == .scaleAspectFill || contentMode == .scaleAspectFit || contentMode == .redraw {
            size.width = CGFloat(floorf((Float(size.width) * scale) / scale))
            size.height = CGFloat(floorf((Float(size.height) * scale) / scale))
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, CGFloat(scale))
        let context = UIGraphicsGetCurrentContext()
        if circular {
            let path = CGPath(ellipseIn: bounds, transform: nil)
            context?.addPath(path)
            context?.clip()
        }
        
        // Fill
        
        context?.setFillColor(color.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let attributes = textAttributes ?? [NSAttributedString.Key.foregroundColor: UIColor.white,
                                            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0)]
        
        
        //stroke color
        if stroke {
            
            //outer circle
            context?.setStrokeColor((attributes[NSAttributedString.Key.foregroundColor] as! UIColor).cgColor)
            context?.setLineWidth(4)
            var rectangle : CGRect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            context?.addEllipse(in: rectangle)
            context?.drawPath(using: .fillStroke)
            
            //inner circle
            context?.setLineWidth(1)
            rectangle = CGRect(x: 4, y: 4, width: size.width - 8, height: size.height - 8)
            context?.addEllipse(in: rectangle)
            context?.drawPath(using: .fillStroke)
        }
        
        // Text
        if let text = text {
            let textSize = text.size(withAttributes: attributes)
            let bounds = self.bounds
            let rect = CGRect(x: bounds.size.width/2 - textSize.width/2, y: bounds.size.height/2 - textSize.height/2, width: textSize.width, height: textSize.height)
            
            text.draw(in: rect, withAttributes: attributes)
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}

// MARK: UIColor Helper
extension UIColor {
    
    /// Returns random generated color.
     static var random: UIColor {
        srandom(arc4random())
        var red: Double = 0
        
        while (red < 0.1 || red > 0.84) {
            red = drand48()
        }
        
        var green: Double = 0
        while (green < 0.1 || green > 0.84) {
            green = drand48()
        }
        
        var blue: Double = 0
        while (blue < 0.1 || blue > 0.84) {
            blue = drand48()
        }
        
        return .init(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
    }
    
     static func colorHash(name: String?) -> UIColor {
        guard let name = name else {
            return .red
        }
        
        var nameValue = 0
        for character in name {
            let characterString = String(character)
            let scalars = characterString.unicodeScalars
            nameValue += Int(scalars[scalars.startIndex].value)
        }
        
        var r = Float((nameValue * 123) % 51) / 51
        var g = Float((nameValue * 321) % 73) / 73
        var b = Float((nameValue * 213) % 91) / 91
        
        let defaultValue: Float = 0.84
        r = min(max(r, 0.1), defaultValue)
        g = min(max(g, 0.1), defaultValue)
        b = min(max(b, 0.1), defaultValue)
        
        return .init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1.0)
    }
}

// MARK: String Helper
// Example = Ex
// For Example = FE
// for example = fe
// "" = DP
extension String {
    
     var initials: String {
        
        let words = components(separatedBy: .whitespacesAndNewlines)
        
        //to identify letters
        let letters = CharacterSet.alphanumerics
        var firstChar : String = ""
        var secondChar : String = ""
        var firstCharFoundIndex : Int = -1
        var firstCharFound : Bool = false
        var secondCharFound : Bool = false
        
        for (index, item) in words.enumerated() {
            
            if item.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                continue
            }
            
            //browse through the rest of the word
            for (_, char) in item.unicodeScalars.enumerated() {
                
                //check if its a aplha
                if letters.contains(char) {
                    
                    if !firstCharFound {
                        firstChar = String(char)
                        firstCharFound = true
                        firstCharFoundIndex = index
                        
                    } else if !secondCharFound {
                        
                        secondChar = String(char)
                        if firstCharFoundIndex != index {
                            secondCharFound = true
                        }
                        
                        break
                    } else {
                        break
                    }
                }
            }
        }
        
        if firstChar.isEmpty && secondChar.isEmpty {
            firstChar = "?"
            secondChar = "?"
        }
        
        return firstChar + secondChar
    }
}
