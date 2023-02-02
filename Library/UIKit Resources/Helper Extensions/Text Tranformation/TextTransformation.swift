//
//  TextTransformation.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 02/02/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit

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
        let str = fetchMessageHeaderDate(from: TimeInterval(time))
        return str
    }
    
    func fetchMessageHeaderDate(from interval : TimeInterval) -> String {
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: interval)
        if (interval == 0.0) || (calendar.isDateInToday(date)) { return "TODAY".localized() }
        else if calendar.isDateInYesterday(date) { return "YESTERDAY".localized() }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, yyyy"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate
        }
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
            
            return "TODAY".localized()
            
        } else if secondsAgo < twoDays {
            let day = secondsAgo/day
            if day == 1 {
                return "YESTERDAY".localized()
            }else{
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                formatter.locale = Locale(identifier: "en_US")
                let strDate: String = formatter.string(from: date)
                return strDate.uppercased()
            }
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, yyyy"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate
        }
    }
    
    func checkNewMessageDate(time: Int) -> String {
        let interval = TimeInterval(time)
        let date = Date(timeIntervalSince1970: interval)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, yyyy"
        formatter.locale = Locale(identifier: "en_US")
        let strDate: String = formatter.string(from: date)
        return strDate
    }
    
    func compareDates(newTimeInterval: Int, currentTimeInterval: Int ) -> Bool {
        let tempNewDate = Date(timeIntervalSince1970: TimeInterval(newTimeInterval))
        let tempCurrentDate = Date(timeIntervalSince1970: TimeInterval(currentTimeInterval))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")
        let formattedNewDate = dateFormatter.string(from: tempNewDate)
        let formattedCurrentDate = dateFormatter.string(from: tempCurrentDate)
        if let previousDate = dateFormatter.date(from: formattedNewDate) , let currentDate = dateFormatter.date(from: formattedCurrentDate) {
            return previousDate.compare(currentDate) == .orderedSame
        }
        return false
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
                return "JUST_NOW".localized()
            }else{
                return "\(secondsAgo) " + "SECS".localized()
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
        
        let calendar = Calendar.current
        var secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }
        
        let minute = 60
        
        if secondsAgo < minute  {
            if secondsAgo < 2{
                return "JUST_NOW".localized()
            }else{
                return "\(secondsAgo) " + "SECS".localized()
            }
        } else if calendar.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate
        } else if calendar.isDateInYesterday(date) {
            return "YESTERDAY".localized()
            
        }  else {
            let startOfNow = calendar.startOfDay(for: Date())
            let startOfTimeStamp = calendar.startOfDay(for: date)
            if  let day = calendar.dateComponents([.day], from: startOfNow, to: startOfTimeStamp).day {
                let formatter = DateFormatter()
                formatter.dateFormat = (day < -1)  &&  (day >= -7) ? "EEE" : "MMM dd"
                formatter.locale = Locale(identifier: "en_US")
                let strDate: String = formatter.string(from: date)
                return  (day < -1)  &&  (day >= -7) ? strDate.uppercased() : strDate
            }
            
            return ""
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
                return "JUST_NOW".localized()
            }else{
                return "\(secondsAgo) " + "SECS".localized()
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
