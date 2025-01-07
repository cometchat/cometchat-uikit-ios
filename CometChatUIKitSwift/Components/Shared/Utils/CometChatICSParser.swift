import Foundation
import CometChatSDK

public enum CometChatICSParser {

    public static func load(string: String, completion: @escaping (_: [String: [TimeRange]]) -> ()) {
        let icsContent = string.components(separatedBy: "\n")
        return parse(icsContent, completion: completion)
    }

    public static func load(url: URL, encoding: String.Encoding = .utf8, completion: @escaping (_: [String: [TimeRange]]) -> (), failure: ((_: CometChatException) -> ())? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                let data = try Data(contentsOf: url)
                guard let string = String(data: data, encoding: encoding) else { throw iCalError.encoding }
                load(string: string, completion: completion)
            } catch {
                DispatchQueue.main.async {
                    failure?(CometChatException(errorCode: error.localizedDescription, errorDescription: error.localizedDescription))
                }
            }
        }
    }

    private static func parse(_ icsContent: [String], completion: @escaping (_: [String: [TimeRange]]) -> ()) {
        let parser = Parser(icsContent)
        parser.read(completion: completion)
    }

}


internal class Parser {
    let icsContent: [String]

    init(_ ics: [String]) {
        icsContent = ics
    }

    func read(completion: @escaping (_: [String: [TimeRange]]) -> ()) {
        var completeCal = [String: [TimeRange]]()
        
        var inEvent = false
        var currentEvent: TimeRange?
        var currentDate: Date?
        
        for (_ , line) in icsContent.enumerated() {
            
            if line.starts(with: "BEGIN:VEVENT") {
                inEvent = true
                currentEvent = TimeRange()
                continue
            }
            
            if line.starts(with: "END:VEVENT") {
                inEvent = false
                if let currentEvent = currentEvent, let currentDate = currentDate {
                    
                    if currentEvent.startDate != currentEvent.endDate {
                        
                        //adding 1 event separately in 2 days according to its time
                        if var currentDateObj = completeCal[currentEvent.startDate] {
                            currentDateObj.append(TimeRange(startTime: currentEvent.startTime, endTime: "2359", startDate: currentEvent.startDate, endDate: currentEvent.startDate))
                            completeCal[currentEvent.startDate] = currentDateObj
                        }else {
                            completeCal.append(with: [(currentEvent.startDate): [TimeRange(startTime: currentEvent.startTime, endTime: "2359", startDate: currentEvent.startDate, endDate: currentEvent.startDate)]])
                        }
                        
                        if var currentDateObj = completeCal[currentEvent.endDate] {
                            currentDateObj.append(TimeRange(startTime: "0000", endTime: currentEvent.endTime, startDate: currentEvent.endDate, endDate: currentEvent.endDate))
                            completeCal[currentEvent.endDate] = currentDateObj
                        }else {
                            completeCal.append(with: [(currentEvent.endDate): [TimeRange(startTime: "0000", endTime: currentEvent.endTime, startDate: currentEvent.endDate, endDate: currentEvent.endDate)]])
                        }
                        
                        if currentEvent.startDate.todate().addingTimeInterval(TimeInterval((86400))).getOnlyDate() != currentEvent.endDate {
                            var date = currentEvent.startDate.todate().addingTimeInterval(TimeInterval((86400)))
                            while (date < currentEvent.endDate.todate() && date.getOnlyDate() != currentEvent.endDate) {
                                if var currentDateObj = completeCal[date.getOnlyDate()] {
                                    currentDateObj.append(TimeRange(startTime: "0000", endTime: "2359", startDate: date.getOnlyDate(), endDate: date.getOnlyDate()))
                                    completeCal[currentEvent.endDate] = currentDateObj
                                }else {
                                    completeCal.append(with: [(date.getOnlyDate()): [TimeRange(startTime: "0000", endTime: "2359", startDate: date.getOnlyDate(), endDate: date.getOnlyDate())]])
                                }
                                date = date.addingTimeInterval(TimeInterval(86400))
                            }
                        }
                        
                        
                    } else {
                        if var currentDateObj = completeCal[(currentDate.getOnlyDate())] {
                            currentDateObj.append(currentEvent)
                            completeCal[(currentDate.getOnlyDate())] = currentDateObj
                        }else {
                            completeCal.append(with: [(currentDate.getOnlyDate()): [currentEvent]])
                        }
                    }
                }
                currentDate = nil
                currentEvent = nil
                continue
            }
            
            guard let (key, value) = line.toKeyValuePair(splittingOn: ":") else {
                continue
            }
            
            if inEvent {
                if key.starts(with: "DTSTART") {
                    var date: Date?
                    if key.contains("TZID="), let timeZone = getTimeZone(key: key) {
                        date = value.convertLocalTimeZone(timeZone: timeZone).toDate()
                    } else {
                        date = value.convertLocalTimeZone().toDate()
                    }
                    currentEvent?.startTime = date?.to24HFormateTime() ?? ""
                    currentEvent?.startDate = date?.getOnlyDate() ?? ""
                    currentDate = date
                    continue
                }
                if key.starts(with: "DTEND"), let timeZone = getTimeZone(key: key)  {
                    var date: Date?
                    if key.contains("TZID=") {
                        date = value.convertLocalTimeZone(timeZone: timeZone).toDate()
                    } else {
                        date = value.convertLocalTimeZone().toDate()
                    }
                    currentEvent?.endTime = date?.to24HFormateTime() ?? ""
                    currentEvent?.endDate = date?.getOnlyDate() ?? ""
                    continue
                }
            }
        }
        DispatchQueue.main.async {
            completion(completeCal)
        }
    }
    
    func getTimeZone(key: String) -> String? {
        if let startRange = key.range(of: "TZID="),
           let endRange = key.range(of: ":", range: startRange.upperBound..<key.endIndex) {
            return String(key[startRange.upperBound..<endRange.lowerBound])
        }
        return ""
    }
    
}

extension String {
    
    func toKeyValuePair(splittingOn separator: Character) -> (first: String, second: String)? {
        let arr = self.split(separator: separator,
                             maxSplits: 1,
                             omittingEmptySubsequences: false)
        if arr.count < 2 {
            return nil
        } else {
            return (String(arr[0]), String(arr[1]))
        }
    }
    
    func toDate() -> Date? {
        let dateTrimmed = self.replacingOccurrences(of: "\r", with: "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        return dateFormatter.date(from: dateTrimmed)
    }
    
    func convertLocalTimeZone(timeZone: String = "UTC") -> String {
        let dateTrimmed = self.replacingOccurrences(of: "\r", with: "")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: timeZone)

        if let utcDate = dateFormatter.date(from: dateTrimmed) {
            dateFormatter.timeZone = TimeZone.current
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
            let localTimeString = dateFormatter.string(from: utcDate)
            return localTimeString
        } else {
            return "Error converting date"
        }
    }
    
    func to12HFormattedTime() -> String {
        let hour = Int(self.prefix(2))!
        let minute = Int(self.suffix(2))!
        
        let calendar = Calendar.current
        let components = DateComponents(hour: hour, minute: minute)
        let timeDate = calendar.date(from: components)!
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: timeDate)
    }
}

extension Date {
    func getOnlyDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.string(from: self)
    }
    
    
    func to24HFormateTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HHmm"
        return dateFormatter.string(from: self)
    }
    
    func dayOfWeek() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).lowercased()
    }
}

extension TimeZone {
    func getFullForm() -> String {
        let locale = Locale(identifier: "en_IN")
        return self.localizedName(for: .generic, locale: locale) ?? ""
    }
}


public enum iCalError: Error {
    case fileNotFound
    case encoding
    case parseError
    case unsupportedICalVersion
}
