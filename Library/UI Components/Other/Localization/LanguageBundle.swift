//
//  LanguageBundle.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 09/12/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import Foundation

var bundleKey: UInt8 = 0

class LanguageBundle: Bundle {
    
    override func localizedString(forKey key: String,
                                  value: String?,
                                  table tableName: String?) -> String {
        
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
            let bundle = Bundle(path: path) else {
                
                return super.localizedString(forKey: key, value: value, table: tableName)
        }
        
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}

extension Bundle {
    class func setLanguage(_ language: String) {
        
        defer {
            object_setClass(UIKitSettings.bundle, LanguageBundle.self)
        }
        objc_setAssociatedObject(Bundle.main, &bundleKey,    Bundle.main.path(forResource: language, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
