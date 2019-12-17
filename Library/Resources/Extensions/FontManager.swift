//
//  FontManager.swift
//  Demo
//
//  Created by MacMini-03 on 16/12/19.
//  Copyright © 2019 MacMini-03. All rights reserved.
//
import UIKit

public extension UIFont {
    
    class func loadAllFonts(bundleIdentifierString: String) {
        registerFontWithFilenameString(filenameString: "SF-Pro-Display-Black.otf", bundleIdentifierString: bundleIdentifierString)
        registerFontWithFilenameString(filenameString: "SF-Pro-Display-Bold.otf", bundleIdentifierString: bundleIdentifierString)
        registerFontWithFilenameString(filenameString: "SF-Pro-Display-Regular.otf", bundleIdentifierString: bundleIdentifierString)
    }
    
    static func registerFontWithFilenameString(filenameString: String, bundleIdentifierString: String) {
        if let frameworkBundle = Bundle(identifier: bundleIdentifierString) {
            let pathForResourceString = frameworkBundle.path(forResource: filenameString, ofType: nil)
            let fontData = NSData(contentsOfFile: pathForResourceString!)
            let dataProvider = CGDataProvider(data: fontData!)
            guard let fontRef = CGFont(dataProvider!) ?? nil else { return }
            var errorRef: Unmanaged<CFError>? = nil
            
            if (CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) == false) {
                print("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
            }
        }
        else {
            print("Failed to register font - bundle identifier invalid.")
        }
    }
}
