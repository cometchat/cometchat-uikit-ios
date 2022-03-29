
import Foundation
import  UIKit
import CometChatPro

@objc @IBDesignable  final class CometChatDate: UILabel {

    @objc enum TimeFormat: Int {
        case ConversationListDate
        case MessageListDate
        case MessageBubbleDate
        case CallListDate
    }
    
    
    // MARK: - Declaration of IBInspectable
    @IBInspectable var borderColor: UIColor = UIColor.clear
    @IBInspectable var borderWidth: CGFloat = 0.5
    @IBInspectable var radius: CGFloat = 0
    @IBInspectable var setBackgroundColor: UIColor = UIColor.clear
    @IBInspectable var setTimeColor: UIColor = CometChatThemeOld.style.subtitleColor
    @IBInspectable var setTimeFont: UIFont = CometChatThemeOld.style.subtitleFont
//    @IBInspectable var setTimeFormat: UIColor = CometChatThemeOld.style.titleColor
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    override init(frame: CGRect){
        super.init(frame: frame)
        self.setup()
    }
    
     override func drawText(in rect: CGRect) {
        super.drawText(in: rect)
        self.setup()
    }
    
    func setup(){
        self.textColor = setTimeColor
        self.layer.cornerRadius = radius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        self.backgroundColor = setBackgroundColor
        self.clipsToBounds = true
    }
    
    @discardableResult
    @objc  func set(borderColor : UIColor) -> CometChatDate {
        self.borderColor = borderColor
        return self
    }
    
    @discardableResult
    @objc  func set(borderWidth : CGFloat) -> CometChatDate {
        self.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    @objc  func set(backgroundColor : UIColor) -> CometChatDate {
        self.backgroundColor  = backgroundColor
        return self
    }
    
    @discardableResult
    @objc  func set(timeColor : UIColor) -> CometChatDate {
        self.textColor  = timeColor
        return self
    }
    
    @discardableResult
    @objc  func set(timeFont : UIFont) -> CometChatDate {
        self.font  = timeFont
        return self
    }
    
    @discardableResult
    @objc  func set(cornerRadius : CGFloat) -> CometChatDate {
        self.radius = cornerRadius
        return self
    }
    
    @discardableResult
    @objc  func set(time: Int, forType: TimeFormat) -> CometChatDate {
        switch forType {
       
        case .ConversationListDate: break
            
        case .MessageListDate: break
            
        case .MessageBubbleDate:
            self.text = String().setMessageTime(time: time)
            
        case .CallListDate: break
            
        }
        return self
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
            
            return "TODAY".localize()
            
        } else if secondsAgo < twoDays {
            let day = secondsAgo/day
            if day == 1 {
                return "YESTERDAY".localize()
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
                return "JUST_NOW".localize()
            }else{
                return "\(secondsAgo) " + "SECS".localize()
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
                return "JUST_NOW".localize()
            }else{
                return "\(secondsAgo) " + "SECS".localize()
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
                return "YESTERDAY".localize()
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
                return "JUST_NOW".localize()
            }else{
                return "\(secondsAgo) " + "SECS".localize()
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
