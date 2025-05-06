//
//  DateTimeFormatterUtils.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 28/04/25.
//

import Foundation

public class DateTimeFormatterUtils{
    
    public init() {}
    
    public func getFormattedDateFromClosures(timeStamp: Int, dateTimeFormatter: CometChatDateTimeFormatter?) -> String? {
        
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        let currentDate = Date()
        let calendar = Calendar.current
        
        let timeInterval = currentDate.timeIntervalSince(date)
        let timeDifferenceInMinutes = Int(timeInterval / 60)
        let timeDifferenceInHours = Int(timeInterval / 3600)
        
        // MARK: - Try Custom Formatters Only (No fallback here)
        
        if let minuteFormatter = dateTimeFormatter?.minute, timeDifferenceInMinutes == 1 {
            return minuteFormatter(timeStamp)
        }
        
        if let minutesFormatter = dateTimeFormatter?.minutes, timeDifferenceInMinutes > 1 && timeDifferenceInMinutes < 60 {
            return minutesFormatter(timeStamp)
        }
        
        if let hourFormatter = dateTimeFormatter?.hour, timeDifferenceInHours == 1 {
            return hourFormatter(timeStamp)
        }
        
        if let hoursFormatter = dateTimeFormatter?.hours, timeDifferenceInHours > 1 && timeDifferenceInHours < 24 {
            return hoursFormatter(timeStamp)
        }
        
        if calendar.isDateInToday(date) {
            if let todayFormatter = dateTimeFormatter?.today {
                return todayFormatter(timeStamp)
            } else if let timeFormatter = dateTimeFormatter?.time {
                return timeFormatter(timeStamp)
            }
        }
        
        if let yesterdayFormatter = dateTimeFormatter?.yesterday, calendar.isDateInYesterday(date) {
            return yesterdayFormatter(timeStamp)
        }
        
        let now = Date()
        if let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: now),
           date >= sevenDaysAgo && date <= now {
            if let lastWeekFormatter = dateTimeFormatter?.lastWeek {
                return lastWeekFormatter(timeStamp)
            }
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "EEEE"
            dateFormat.locale = Locale(identifier: CometChatLocalize.getLocale())
            return dateFormat.string(from: date).capitalized
        }
        
        if let otherDayFormatter = dateTimeFormatter?.otherDay {
            return otherDayFormatter(timeStamp)
        }
        
        return nil
    }
}
