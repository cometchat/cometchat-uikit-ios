
import Foundation
import UIKit
import CometChatSDK

@objc @IBDesignable  
public class CometChatDate: UILabel {
    
    public static var style = DateStyle() //global styling
    public lazy var style = CometChatDate.style //component level styling
    
    var pattern : CometChatDatePattern? = .dayDate
    var timestamp : Int? = 0
    var dateFormat: String?
    var customFormat:  String?
    
    // Padding for the label
    internal var padding = UIEdgeInsets()
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        buildUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        buildUI()
    }
    
    public override func drawText(in rect: CGRect) {
        let paddedRect = rect.inset(by: padding)
        super.drawText(in: paddedRect)
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        if newSuperview != nil {
            setupStyle()
        }
    }
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let paddedBounds = bounds.inset(by: padding)
        let textRect = super.textRect(forBounds: paddedBounds, limitedToNumberOfLines: numberOfLines)
        let insetRect = CGRect(
            x: textRect.origin.x - padding.left,
            y: textRect.origin.y - padding.top,
            width: textRect.size.width + padding.left + padding.right,
            height: textRect.size.height + padding.top + padding.bottom
        )
        return insetRect
    }
    
    open func buildUI() {
        self.numberOfLines = 0
        self.clipsToBounds = true
        self.textAlignment = .center
    }
    
    open func setupStyle() {
        self.textColor = style.textColor
        self.font = style.textFont
        self.layer.borderColor = style.borderColor.cgColor
        self.layer.borderWidth = style.borderWidth
        self.backgroundColor = style.backgroundColor
        self.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: CometChatSpacing.Radius.r1))
        
    }
    
    @discardableResult
    @objc public func set(timestamp: Int) -> CometChatDate {
        self.timestamp = timestamp
        if let customFormat = self.customFormat, !customFormat.isEmpty  {
            self.text = customFormat
            return self
        } else {
            switch self.pattern {
            case .time:
                self.text = setTime(for: timestamp)
            case .dayDate:
                self.text = setDayDate(for: timestamp)
                
            case .dayDateTime:
                self.text = setDayTime(for: timestamp)
                
            default:
                break
            }
        }
        return self
    }
    
    @discardableResult
    public func set(pattern: CometChatDatePattern) -> CometChatDate {
        self.pattern = pattern
        return self
    }
    
    
    @discardableResult
    @objc public func setCustomPattern(customPattern: @escaping (_ timestamp: Int)->(String?)) -> CometChatDate {
        if let timestamp = timestamp, let customFormat = customPattern(timestamp) {
            self.customFormat = customFormat
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
    
    
    func reduceTo_MMM_dd_yyy() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return dateFormatter.string(from: self)
        }
    }

    func reduceTo(customFormate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = customFormate
        return dateFormatter.string(from: self)
    }
    
}


extension CometChatDate {
    
    func setTime(for time: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let str = fetchMessagePastTime(for: date)
        return str
    }
    
    func fetchMessagePastTime(for date : Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat =  "hh:mm a"
        formatter.locale = Locale(identifier: "en_US")
        let strDate: String = formatter.string(from: date)
        return strDate
    }
    
    func setDayDate(for time: Int) -> String {
        let interval = TimeInterval(time)
        let calendar = Calendar.current
        let date = Date(timeIntervalSince1970: interval)
        if (interval == 0.0) || (interval == -1) || (calendar.isDateInToday(date)) { return "TODAY".localize() }
        else if calendar.isDateInYesterday(date) { return "YESTERDAY".localize() }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "d MMM, yyyy"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate
        }
        
    }
    
    
    
    func setDayTime(for time: Int) -> String {
        
        let date       = Date(timeIntervalSince1970: TimeInterval(time))
        var secondsAgo = Int(Date().timeIntervalSince(date))
        if secondsAgo < 0 {
            secondsAgo = secondsAgo * (-1)
        }
        
        let minute = 60
        let hour = 60 * minute
        let day = 24 * hour
        let twoDays = 2 * day
        let sevenDays = 7 * day
        
        if secondsAgo < day {
            let day = secondsAgo/hour
            let formatter = DateFormatter()
            formatter.dateFormat = "hh:mm a"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            if day == 1{
                return strDate
             } else {
                return strDate
            }
        } else if secondsAgo < twoDays {
            let day = secondsAgo/day
            if day == 1 {
                return "YESTERDAY".localize()
             } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEE"
                formatter.locale = Locale(identifier: "en_US")
                let strDate: String = formatter.string(from: date)
                return strDate.capitalized
            }
        } else if secondsAgo < sevenDays {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate.capitalized
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy"
            formatter.locale = Locale(identifier: "en_US")
            let strDate: String = formatter.string(from: date)
            return strDate.capitalized
        }
    }
    
}
