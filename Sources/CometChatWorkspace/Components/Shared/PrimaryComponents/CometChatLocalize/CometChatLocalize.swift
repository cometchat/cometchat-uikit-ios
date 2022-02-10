//
//  CometChatListBase.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import Foundation

/**
 `Language` is an enum which is being used for setting the different launguage for UI Kit.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
public enum Language : String {
    
    /// Specifies an enum value where in this case the language will be `german`
    case german = "de";
    /// Specifies an enum value where in this case the language will be `arabic`
    case arabic = "ar";
    /// Specifies an enum value where in this case the language will be `chinese_taiwan`
    case chinese_taiwan = "zh-TW";
    /// Specifies an enum value where in this case the language will be `english`
    case english = "en";
    /// Specifies an enum value where in this case the language will be `spanish`
    case spanish = "es";
    /// Specifies an enum value where in this case the language will be `malay`
    case malay = "ms";
    /// Specifies an enum value where in this case the language will be `swedish`
    case swedish = "sv";
    /// Specifies an enum value where in this case the language will be `hungarian`
    case hungarian = "hu";
    /// Specifies an enum value where in this case the language will be `lithuanian`
    case lithuanian = "lt";
    /// Specifies an enum value where in this case the language will be `russian`
    case russian = "ru";
    /// Specifies an enum value where in this case the language will be `french`
    case french = "fr";
    /// Specifies an enum value where in this case the language will be `portuguese`
    case portuguese = "pt";
    /// Specifies an enum value where in this case the language will be `hindi`
    case hindi = "hi";
    /// Specifies an enum value where in this case the language will be `chinese`
    case chinese = "zh";
}

var bundleKey: UInt8 = 0


/**
 `CometChatListBase` is a subclass of UIViewController which will be the base class for all list controllers. Other view controllers will inherit this class to use their methods & properties. .
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
public class CometChatLocalize: Bundle {
    
    static var defaultlocale: Language = .english
    static var locale: String = Locale.current.languageCode ?? defaultlocale.rawValue
    
    
    /**
     This method will set the language specified by the user and it will set the language for all components used in the UI Kit.
     - Parameters:
     - locale: This specifies the language.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    public class func set(locale: Language){
        self.locale = locale.rawValue
        defer {
            object_setClass(Bundle.main, CometChatLocalize.self)
        }
        objc_setAssociatedObject(Bundle.main, &bundleKey,    Bundle.main.path(forResource: locale.rawValue, ofType: "lproj"), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /**
     This method will set the language specified by the user and it will set the language for all components used in the UI Kit.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    public class func getLocale() -> String {
        return UserDefaults.standard.value(forKey: "lang") as? String ?? Locale.current.languageCode as! String
    }
    
    
    
    public override func localizedString(forKey key: String,
                                  value: String?,
                                  table tableName: String?) -> String {
        
        guard let path = objc_getAssociatedObject(self, &bundleKey) as? String,
            let bundle = Bundle(path: path) else {
                
                return super.localizedString(forKey: key, value: value, table: tableName)
        }
        
        return bundle.localizedString(forKey: key, value: value, table: tableName)
    }
}


extension String {
    
    public func localize() -> String {
        CometChatLocalize.set(locale: Language(rawValue: CometChatLocalize.locale) ?? .english)
        UserDefaults.standard.set(CometChatLocalize.locale, forKey: "lang")
        if let lang = UserDefaults.standard.value(forKey: "lang") as? String {
            let path = Bundle.main.path(forResource: lang, ofType: "lproj")
            let bundle = Bundle(path: path!)
            return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
        }else{
            let path = Bundle.main.path(forResource: "en", ofType: "lproj")
            let bundle = Bundle(path: path!)
            return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
        }
    }
}

extension String {

    var isLocalized: Bool {
        return localize() != self
    }

    func localize(parameter: CVarArg? = nil) -> String {
        if let parameter = parameter {
            return String(format: NSLocalizedString(self, comment: ""), parameter)
        }
        else {
            return NSLocalizedString(self, comment: "")
        }
    }

    func localize(parameter0: CVarArg, parameter1: CVarArg) -> String {
        return String(format: NSLocalizedString(self, comment: ""), parameter0, parameter1)
    }

}
