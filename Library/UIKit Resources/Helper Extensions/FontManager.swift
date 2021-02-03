//
//  FontManager.swift
//  Demo
//
//  Created by CometChat Inc. on 16/12/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.
//
import UIKit

 extension UIFont {
    
//    class func loadAllFonts(bundleIdentifierString: String) {
//        registerFontWithFilenameString(filenameString: "SF-Pro-Display-Black.otf", bundleIdentifierString: bundleIdentifierString)
//        registerFontWithFilenameString(filenameString: "SF-Pro-Display-Bold.otf", bundleIdentifierString: bundleIdentifierString)
//        registerFontWithFilenameString(filenameString: "SF-Pro-Display-Regular.otf", bundleIdentifierString: bundleIdentifierString)
//        registerFontWithFilenameString(filenameString: "SF-Pro-Display-RegularItalic.otf", bundleIdentifierString: bundleIdentifierString)
//    }
//
//    static func registerFontWithFilenameString(filenameString: String, bundleIdentifierString: String) {
//        let pathForResourceString = UIKitSettings.bundle.path(forResource: filenameString, ofType: "")
//            if let path = pathForResourceString {
//                guard let fontData = NSData(contentsOfFile: path) else { return  }
//                guard let dataProvider = CGDataProvider(data: fontData) else { return }
//                guard let fontRef = CGFont(dataProvider) ?? nil else { return }
//                var errorRef: Unmanaged<CFError>? = nil
//               if (CTFontManagerRegisterGraphicsFont(fontRef, &errorRef) == false) {}
//            }
//        }
//
//        static func loadFontWith(name: String) {
//            let frameworkBundle = UIKitSettings.bundle
//            let pathForResourceString = frameworkBundle.path(forResource: name, ofType: "otf")
//            let fontData = NSData(contentsOfFile: pathForResourceString!)
//            let dataProvider = CGDataProvider(data: fontData!)
//            let fontRef = CGFont(dataProvider!)
//            var errorRef: Unmanaged<CFError>? = nil
//
//            if (CTFontManagerRegisterGraphicsFont(fontRef!, &errorRef) == false) {
//                NSLog("Failed to register font - register graphics font failed - this font may have already been registered in the main bundle.")
//            }
//        }
//
//         static let loadMyFonts: () = {
//            loadFontWith(name: "SF-Pro-Display-Black")
//            loadFontWith(name: "SF-Pro-Display-Bold")
//            loadFontWith(name: "SF-Pro-Display-Regular")
//            loadFontWith(name: "SF-Pro-Display-RegularItalic")
//        }()
  
}
