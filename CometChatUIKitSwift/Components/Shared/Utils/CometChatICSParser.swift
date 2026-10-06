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
        var hasUnparseableDate = false
        
        for (_ , line) in icsContent.enumerated() {
            
            if line.starts(with: "BEGIN:VEVENT") {
                inEvent = true
                currentEvent = TimeRange()
                hasUnparseableDate = false
                continue
            }
            
            if line.starts(with: "END:VEVENT") {
                inEvent = false
                // An event whose start (or a present end) failed to parse is skipped rather
                // than filed under an empty key or with an empty time.
                if let currentEvent = currentEvent, !hasUnparseableDate,
                   !currentEvent.startDate.isEmpty, !currentEvent.startTime.isEmpty {
                    // No DTEND: a single-day event on its start date.
                    if currentEvent.endDate.isEmpty || currentEvent.endTime.isEmpty {
                        currentEvent.endDate = currentEvent.startDate
                        currentEvent.endTime = currentEvent.startTime
                    }
                    add(event: currentEvent, to: &completeCal)
                }
                currentEvent = nil
                continue
            }
            
            guard let (key, value) = line.toKeyValuePair(splittingOn: ":") else {
                continue
            }
            
            if inEvent {
                if key.starts(with: "DTSTART") {
                    if let date = parseDate(key: key, value: value) {
                        currentEvent?.startTime = date.to24HFormateTime()
                        currentEvent?.startDate = date.getOnlyDate()
                    } else {
                        hasUnparseableDate = true
                    }
                    continue
                }
                if key.starts(with: "DTEND") {
                    if let date = parseDate(key: key, value: value) {
                        currentEvent?.endTime = date.to24HFormateTime()
                        currentEvent?.endDate = date.getOnlyDate()
                    } else {
                        hasUnparseableDate = true
                    }
                    continue
                }
            }
        }
        DispatchQueue.main.async {
            completion(completeCal)
        }
    }
    
    /// Files an event under the yyyyMMdd key of every local day it covers. An event that
    /// crosses midnight is split: its start day runs to 2359, its end day starts at 0000,
    /// and any day in between is blocked whole.
    private func add(event: TimeRange, to completeCal: inout [String: [TimeRange]]) {
        let startDate = event.startDate
        let endDate = event.endDate
        
        if startDate == endDate {
            completeCal[startDate, default: []].append(event)
            return
        }
        
        // An end before the start is malformed; skip it rather than block the wrong days.
        guard endDate > startDate,
              let start = startDate.todateIfValid(),
              let end = endDate.todateIfValid() else { return }
        
        completeCal[startDate, default: []].append(TimeRange(startTime: event.startTime, endTime: "2359", startDate: startDate, endDate: startDate))
        completeCal[endDate, default: []].append(TimeRange(startTime: "0000", endTime: event.endTime, startDate: endDate, endDate: endDate))
        
        var day = Calendar.current.date(byAdding: .day, value: 1, to: start)
        while let date = day, date < end, date.getOnlyDate() != endDate {
            let dayKey = date.getOnlyDate()
            completeCal[dayKey, default: []].append(TimeRange(startTime: "0000", endTime: "2359", startDate: dayKey, endDate: dayKey))
            day = Calendar.current.date(byAdding: .day, value: 1, to: date)
        }
    }
    
    /// Parses a DTSTART/DTEND value. A trailing `Z` is UTC; otherwise the value is local
    /// to the key's `TZID` parameter, or floating (the device's zone) when there is none.
    func parseDate(key: String, value: String) -> Date? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
        
        if trimmed.hasSuffix("Z") {
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            return dateFormatter.date(from: String(trimmed.dropLast()))
        }
        
        if let identifier = getTimeZone(key: key), let timeZone = TimeZone(identifier: identifier) {
            dateFormatter.timeZone = timeZone
        } else {
            dateFormatter.timeZone = TimeZone.current
        }
        return dateFormatter.date(from: trimmed)
    }
    
    /// The `TZID` parameter of a property key such as `DTSTART;TZID=Asia/Kolkata`, or
    /// nil when the key carries none.
    func getTimeZone(key: String) -> String? {
        guard let startRange = key.range(of: "TZID=") else { return nil }
        let remainder = key[startRange.upperBound...]
        let endIndex = remainder.firstIndex(where: { $0 == ";" || $0 == ":" }) ?? remainder.endIndex
        let identifier = remainder[..<endIndex].trimmingCharacters(in: CharacterSet(charactersIn: "\"").union(.whitespacesAndNewlines))
        return identifier.isEmpty ? nil : identifier
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
        // DateFormatter parses "" to its reference date rather than failing.
        guard !dateTrimmed.isEmpty else { return nil }
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
            return "" // no English sentinel: callers chain .toDate(), which is nil for ""
        }
    }
    
    /// The hour and minute of a four-digit "HHmm" time, or nil when it is not one.
    func hhmmComponents() -> (hour: Int, minute: Int)? {
        guard self.count == 4,
              self.allSatisfy({ $0.isASCII && $0.isNumber }),
              let hour = Int(self.prefix(2)),
              let minute = Int(self.suffix(2)),
              (0...23).contains(hour),
              (0...59).contains(minute) else {
            return nil
        }
        return (hour, minute)
    }
    
    /// "HHmm" rendered as "h:mm a". Malformed input is returned unchanged.
    func to12HFormattedTime() -> String {
        guard let time = hhmmComponents() else { return self }
        
        let calendar = Calendar.current
        let components = DateComponents(hour: time.hour, minute: time.minute)
        guard let timeDate = calendar.date(from: components) else { return self }
        
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
