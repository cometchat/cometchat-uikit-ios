//
//  CCExtensions.swift
//  CometChatUIKit
//
//  Created by CometChat Inc. on 16/10/19.
//  Copyright © 2020 CometChat Inc. All rights reserved.
//

import UIKit
import Foundation
import CometChatPro

extension UIView {
    
    func dropShadow() {
        DispatchQueue.main.async {  [weak self] in
               guard let this = self else { return }
              this.layer.masksToBounds = false
                  this.layer.shadowColor = UIColor.gray.cgColor
                  this.layer.shadowOpacity = 0.3
                  this.layer.shadowOffset = CGSize.zero
                  this.layer.shadowRadius = 5
                  this.layer.shouldRasterize = true
                  this.layer.rasterizationScale = UIScreen.main.scale
        }
    }
}


extension UIViewController{
    func isModal() -> Bool {
        
        if let navigationController = self.navigationController{
            if navigationController.viewControllers.first != self{
                return false
            }
        }
        
        if self.presentingViewController != nil {
            return true
        }
        
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController  {
            return true
        }
        
        if self.tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        return indices ~= index ? self[index] : nil
    }
}

extension UITableView {
    func scrollToBottomRow() {
        DispatchQueue.main.async { [weak self] in
        guard let this = self else { return }
            guard this.numberOfSections > 0 else { return }
            
            // Make an attempt to use the bottom-most section with at least one row
            var section = max(this.numberOfSections - 1, 0)
            var row = max(this.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)
            
            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !this.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(this.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)
                
                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }
            
            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard this.indexPathIsValid(indexPath) else { return }
            this.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.numberOfSections && row < self.numberOfRows(inSection: section)
    }
}


/// Toast Start


// Extension for Show alert

extension UIViewController {
    func showAlert(title : String?, msg : String,
                   style: UIAlertController.Style = .alert,
                   dontRemindKey : String? = nil) {
        if dontRemindKey != nil,
            UserDefaults.standard.bool(forKey: dontRemindKey!) == true {
            return
        }
        
        let ac = UIAlertController.init(title: title,
                                        message: msg, preferredStyle: style)
        ac.addAction(UIAlertAction.init(title: "OK",
                                        style: .default, handler: nil))
        
        if dontRemindKey != nil {
            ac.addAction(UIAlertAction.init(title: "Don't Remind",
                                            style: .default, handler: { (aa) in
                                                UserDefaults.standard.set(true, forKey: dontRemindKey!)
                                                UserDefaults.standard.synchronize()
            }))
        }
        DispatchQueue.main.async { [weak self] in
        guard let this = self else { return }
            this.present(ac, animated: true, completion: nil)
        }
    }
}



 extension UIDevice {
    
    // This extention deals with the devices which you want to check the specific conditions and Do the UI Changes according with device size.
    
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "\(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
    
}


extension Date {
    
    func dateFromCustomString(customString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: customString) ?? Date()
    }
    
    func reduceToMonthDayYear() -> Date {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let year = calendar.component(.year, from: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: "\(month)/\(day)/\(year)") ?? Date()
    }
}


extension String {
    func setMessageDateHeader(time: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let str = fetchMessageDateHeader(for: date)
        
        return str
    }
    
    func fetchMessageDateHeader(for date : Date) -> String {
        
        var secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let twoDays = 2 * day
        let oneDay = 1 * day
        
        if secondsAgo < oneDay  {
            
            return NSLocalizedString("TODAY", bundle: UIKitSettings.bundle, comment: "")
            
        } else if secondsAgo < twoDays {
            let day = secondsAgo/day
            if day == 1 {
                return NSLocalizedString("YESTERDAY", bundle: UIKitSettings.bundle, comment: "")
            }else{
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                formatter.locale = Locale(identifier: "en_US")
                let strDate: String = formatter.string(from: date)
                return strDate.uppercased()
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate.uppercased()
        }
    }
    
    
    func setCallsTime(time: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let str = fetchCallsPastTime(for: date)
        return str
    }
    
    func fetchCallsPastTime(for date : Date) -> String {
        let minute = 60
        var secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }
        if secondsAgo < minute  {
            if secondsAgo < 2{
                return "Just Now"
            }else{
                return "\(secondsAgo) secs"
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate
        }
    }
    
    
    
    func setConversationsTime(time: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let str = fetchConversationsPastTime(for: date)
        
        return str
    }
    
    func fetchConversationsPastTime(for date : Date) -> String {
        
        var secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let twoDays = 2 * day
        
        
        
        if secondsAgo < minute  {
            if secondsAgo < 2{
                return "Just Now"
            }else{
                return "\(secondsAgo) secs"
            }
        } else if secondsAgo < hour {
            let min = secondsAgo/minute
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            if min == 1{
                return strDate
            }else{
                return strDate
            }
        }else if secondsAgo < twoDays {
            let day = secondsAgo/day
            if day == 1 {
                return "Yesterday"
            }else{
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                formatter.locale = Locale(identifier: "en_US")
                let strDate: String = formatter.string(from: date)
                return strDate.uppercased()
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate.uppercased()
        }
    }
    
    
    func setMessageTime(time: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let str = fetchMessagePastTime(for: date)
        
        return str
    }
    
    func fetchMessagePastTime(for date : Date) -> String {
        
        var secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let twoDays = 2 * day
        
        if secondsAgo < minute  {
            if secondsAgo < 2{
                return "Just Now"
            }else{
                return "\(secondsAgo) secs"
            }
        } else if secondsAgo < hour {
            let min = secondsAgo/minute
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            if min == 1 {
                return strDate
            }else{
                return strDate
            }
        } else if secondsAgo < day {
            let hr = secondsAgo/hour
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            if hr == 1 {
                return strDate
            }else{
                return strDate
            }
        }else if secondsAgo < twoDays {
            let day = secondsAgo/day
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            if day == 1 {
                return strDate
            }else{
                return strDate
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, hh:mm a"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate
        }
    }
    
    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
    
}


extension UITableView {
    
    func isLast(for indexPath: IndexPath) -> Bool {
        
        let indexOfLastSection = numberOfSections > 0 ? numberOfSections - 1 : 0
        let indexOfLastRowInLastSection = numberOfRows(inSection: indexOfLastSection) - 1
        
        return indexPath.section == indexOfLastSection && indexPath.row == indexOfLastRowInLastSection
    }
}

extension UILabel {
    
    func roundLabelCorners(_ corners: CACornerMask, radius: CGFloat){
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = corners
        } else {
            // Fallback on earlier versions
        }
        self.layer.cornerRadius = radius
    }
    
    
}


extension UILabel{
    
    func animation(typing value:String,duration: Double){
        let characters = value.map { $0 }
        var index = 0
        Timer.scheduledTimer(withTimeInterval: duration, repeats: true, block: { [weak self] timer in
            if index < value.count {
                let char = characters[index]
                self?.text! += "\(char)"
                index += 1
            } else {
                timer.invalidate()
            }
        })
    }
    
    
    func textWithAnimation(text:String,duration:CFTimeInterval){
        fadeTransition(duration)
        self.text = text
    }
    
    //followed from @Chris and @winnie-ru
    func fadeTransition(_ duration:CFTimeInterval) {
        let animation = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeIn)
        animation.type = CATransitionType.fade
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.fade.rawValue)
    }
    
}


 struct Units {
    
     let bytes: Int64
    
     var kilobytes: Double {
        return Double(bytes) / 1_024
    }
    
     var megabytes: Double {
        return kilobytes / 1_024
    }
    
     var gigabytes: Double {
        return megabytes / 1_024
    }
    
     init(bytes: Int64) {
        self.bytes = bytes
    }
    
     func getReadableUnit() -> String {
        
        switch bytes {
        case 0..<1_024:
            return "\(bytes) bytes"
        case 1_024..<(1_024 * 1_024):
            return "\(String(format: "%.2f", kilobytes)) KB"
        case 1_024..<(1_024 * 1_024 * 1_024):
            return "\(String(format: "%.2f", megabytes)) MB"
        case (1_024 * 1_024 * 1_024)...Int64.max:
            return "\(String(format: "%.2f", gigabytes)) GB"
        default:
            return "\(bytes) bytes"
        }
    }
}

extension UIView {
    
    func roundViewCorners(_ corners: CACornerMask, radius: CGFloat) {
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = corners
        } else {
            // Fallback on earlier versions
        }
        self.layer.cornerRadius = radius
    }
}


extension UISegmentedControl {
    /// Tint color doesn't have any effect on iOS 13.
    func ensureiOS12Style() {
        if #available(iOS 13, *) {
            
        }else {
            self.backgroundColor = UIColor.white
            self.tintColor = UIKitSettings.primaryColor
            self.layer.borderColor = UIKitSettings.primaryColor.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 8
            self.clipsToBounds = true
            
        }
    }
}

extension Dictionary {
    /// Merge and return a new dictionary
    func merge(with: Dictionary<Key,Value>) -> Dictionary<Key,Value> {
        var copy = self
        for (k, v) in with {
            // If a key is already present it will be overritten
            copy[k] = v
        }
        return copy
    }
    
    /// Merge in-place
    mutating func append(with: Dictionary<Key,Value>) {
        for (k, v) in with {
            // If a key is already present it will be overritten
            self[k] = v
        }
    }
}

extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        if #available(iOS 13.0, *) {
            messageLabel.textColor = .systemGray
        } else {
            messageLabel.textColor = .gray
        }
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        
        messageLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: (self.bounds.size.height/2)))
        messageLabel.text = message
        if #available(iOS 13.0, *) {
            messageLabel.textColor = .systemGray
        } else {
            messageLabel.textColor = .gray
        }
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.systemFont(ofSize: 35, weight: .bold)
        messageLabel.sizeToFit()
        self.backgroundView = messageLabel
    }
    
    func restore() {
        self.backgroundView = nil
    }
}

 extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

//Blur the Image:
protocol Bluring {
    func addBlur(_ alpha: CGFloat)
}

extension Bluring where Self: UIView {
    func addBlur(_ alpha: CGFloat = 1) {
        // create effect
        if #available(iOS 13.0, *) {
            let effect = UIBlurEffect(style: .systemThinMaterialDark)
            let effectView = UIVisualEffectView(effect: effect)
            
            // set boundry and alpha
            effectView.frame = self.bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            effectView.alpha = alpha
            self.addSubview(effectView)
        } else {
            let effect = UIBlurEffect(style: .dark)
            let effectView = UIVisualEffectView(effect: effect)
            
            // set boundry and alpha
            effectView.frame = self.bounds
            effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            effectView.alpha = alpha
            self.addSubview(effectView)
        }
        
    }
}

// Conformance
extension UIView: Bluring {}

extension URL    {
    func checkFileExist() -> Bool {
        let path = self.path
        if (FileManager.default.fileExists(atPath: path))   {
            return true
        }else{
            return false;
        }
    }
}


extension String {
    func containsOnlyEmojis() -> Bool {
        if count == 0 {
            return false
        }
        for character in self {
            if !character.isEmoji {
                return false
            }
        }
        return true
    }

    func containsEmoji() -> Bool {
        for character in self {
            if character.isEmoji {
                return true
            }
        }
        return false
    }
}

extension Character {
    // An emoji can either be a 2 byte unicode character or a normal UTF8 character with an emoji modifier
    // appended as is the case with 3️⃣. 0x238C is the first instance of UTF16 emoji that requires no modifier.
    // `isEmoji` will evaluate to true for any character that can be turned into an emoji by adding a modifier
    // such as the digit "3". To avoid this we confirm that any character below 0x238C has an emoji modifier attached
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji && (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}
