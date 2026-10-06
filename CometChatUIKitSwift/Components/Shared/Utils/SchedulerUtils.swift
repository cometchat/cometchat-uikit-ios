//
//  icsFileParserUtil.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 28/12/23.
//

import Foundation
import CometChatSDK

public class SchedulerUtils {
    
    //This will generate time slots by fetching data from f
    public static func getAvailableTimeSlots(ICSFile: String?, forDate date: Date, availableTimes: [String: [TimeRange]], bufferTime: Int, duration: Int,timeZoneCode: String, completion: @escaping (_: [TimeRange]?) -> ()) {
        if let ICSFile = ICSFile,  let url = URL(string: ICSFile) {
            CometChatICSParser.load(url: url, completion: { eventsByDate in
                SchedulerUtils.generateTimeSlots(allAvailableTimes: availableTimes, allUnAvailableTime: eventsByDate, forDate: date, bufferTime: bufferTime, duration: duration, timeZoneCode: timeZoneCode, completion: completion)
            }) { _ in
                completion([])
            }
        }else {
            SchedulerUtils.generateTimeSlots(allAvailableTimes: availableTimes, allUnAvailableTime: [:], forDate: date, bufferTime: bufferTime, duration: duration, timeZoneCode: timeZoneCode, completion: completion)
        }
    }
    
    
    public static func generateTimeSlots(allAvailableTimes: [String: [TimeRange]], allUnAvailableTime: [String: [TimeRange]], forDate date: Date, bufferTime: Int, duration: Int, timeZoneCode: String, completion: @escaping (_: [TimeRange]?) -> ()) {
        
        // A non-positive meeting length never advances the cursor.
        guard duration > 0 else {
            completion([])
            return
        }

        let dateString = date.getOnlyDate()
        var unAvailableTime = allUnAvailableTime[date.getOnlyDate()] ?? []
        var timeSlots = [TimeRange]()
        let duration = duration.convertMinutesToString()
        var unAvailableIndex = 0
        
        var availableTimes = allAvailableTimes[date.dayOfWeek().lowercased()] ?? []
        if let currentTimeZone = TimeZone(identifier: timeZoneCode), TimeZone.current != currentTimeZone {
            availableTimes = convertToLocalTimeZone(availability: allAvailableTimes, date: date, timeZoneCode: timeZoneCode)
        }
        
        unAvailableTime = removeOverlappingEvents(unAvailableTime)
        
        for availableTime in availableTimes {
            var startTime = availableTime.startTime
            unAvailableIndex = 0
            
            if availableTime.startTime > availableTime.endTime { continue }
            
            while (startTime.isBefore(time: availableTime.endTime)) {   
                
                let previousStartTime = startTime
                let previousUnAvailableIndex = unAvailableIndex
                
                // A time that cannot be added to (malformed, or an oversized duration) ends this window.
                guard let timeSlot = startTime.add(time: duration) else { break }
                
                if timeSlot.isBefore(time: availableTime.endTime) {
                    if let nextUnAvailableStartTime = unAvailableTime[safe: unAvailableIndex]?.startTime {
                        if let timeSlotWithBufferTime = timeSlot.add(time: bufferTime.convertMinutesToString()), timeSlotWithBufferTime.isBefore(time: nextUnAvailableStartTime) {
                            if let endDate = unAvailableTime[safe: unAvailableIndex]?.endDate, endDate != dateString {
                                startTime = availableTime.endTime
                                break
                            }
                            timeSlots.append(TimeRange(startTime: startTime, endTime: timeSlot))
                            startTime = timeSlot
                        } else {
                            if let newStartTime = unAvailableTime[safe: unAvailableIndex]?.endTime.add(time: bufferTime.convertMinutesToString()) {
                                // Never move the cursor back: a block that ends before it (or
                                // before the window opens) must not pull slots outside availability.
                                startTime = max(newStartTime, startTime)
                            } else {
                                break
                            }
                            unAvailableIndex = unAvailableIndex+1
                        }
                    } else {
                        timeSlots.append(TimeRange(startTime: startTime, endTime: timeSlot))
                        startTime = timeSlot
                    }
                } else {
                    startTime = availableTime.endTime
                    break
                }

                // Bail out rather than spin if neither the cursor nor the block index moved.
                if startTime == previousStartTime && unAvailableIndex == previousUnAvailableIndex {
                    break
                }
            }
        }
        
        //checking for the next day
        if availableTimes.last?.endTime == "2359" && availableTimes.last?.startTime != "2359" {
            
            //checking time Zone
            var availableTimes = allAvailableTimes[date.addingTimeInterval(86400).dayOfWeek().lowercased()] ?? []
            if let currentTimeZone = TimeZone(identifier: timeZoneCode), TimeZone.current != currentTimeZone {
                availableTimes = convertToLocalTimeZone(availability: allAvailableTimes, date: date.addingTimeInterval(86400), timeZoneCode: timeZoneCode)
            }
            
            //checking if next day starts from availableTime starts with zero
            if availableTimes.first?.startTime == "0000"  {
            if let firstTimeSlot = availableTimes.first,
               let lastGeneratedSlot = Int(timeSlots.last?.endTime ?? ""),
               let lastUnavailableTime = Int(unAvailableTime.last?.startTime ?? "")
               {
                
                let startTime = String(max(lastGeneratedSlot, lastUnavailableTime))
                
                if !startTime.isAfter(time: unAvailableTime.last?.endTime ?? "0000") {
                    completion(timeSlots)
                    return
                }
                
                guard let timeSlot = startTime.add(time: duration, ordered24Formate: true) else {
                    completion(timeSlots)
                    return
                }
                
                let dateString = date.addingTimeInterval(86400).getOnlyDate()
                let nextDayUnAvailableTime = allUnAvailableTime[date.addingTimeInterval(86400).getOnlyDate()]?.first ?? TimeRange(startTime: "2359", endTime: "2359", startDate: dateString, endDate: dateString)
                
                if let timeSlotWithBuffer = timeSlot.add(time: bufferTime.convertMinutesToString(), ordered24Formate: true) {
                    if timeSlotWithBuffer.isBefore(time: firstTimeSlot.endTime) && timeSlotWithBuffer.isBefore(time: nextDayUnAvailableTime.startTime) {
                        timeSlots.append(TimeRange(startTime: startTime, endTime: timeSlot, startDate: date.getOnlyDate(), endDate: dateString))
                    }
                }
            }
        }
        }
                
        return completion(timeSlots)
    }
    
    static func removeOverlappingEvents(_ timeRanges: [TimeRange]) -> [TimeRange] {
        var nonOverlappingRanges: [TimeRange] = []
        // A range with a malformed start or end cannot be placed, so it is skipped.
        let sortedRanges = timeRanges
            .filter { $0.startTime.isValidSchedulerTime && $0.endTime.isValidSchedulerTime }
            .sorted { $0.startTime < $1.startTime }

        for range in sortedRanges {
            if let previous = nonOverlappingRanges.last, !range.startTime.isAfter(time: previous.endTime) {
                // Overlaps the previous block: the merged block runs to whichever ends later.
                if range.endTime > previous.endTime {
                    previous.endTime = range.endTime
                    previous.endDate = range.endDate
                }
            } else {
                nonOverlappingRanges.append(TimeRange(startTime: range.startTime, endTime: range.endTime, startDate: range.startDate, endDate: range.endDate))
            }
        }

        return nonOverlappingRanges
    }

    public static func checkTimeSlotAvailable(icsFileURL: String?, date: Date, timeSlot: TimeRange, completion: @escaping ((_: Bool) -> ()), failure: ((_: CometChatException) -> ())? = nil) {
        DispatchQueue.global(qos: .userInteractive).async {
            // No calendar to check against: nothing can block the slot.
            guard let ICSFile = icsFileURL, let url = URL(string: ICSFile) else {
                DispatchQueue.main.async {
                    completion(true)
                }
                return
            }
            CometChatICSParser.load(url: url, completion: { scheduledEventsByDate in
                // The parser keys events by the same yyyyMMdd day key.
                let scheduledEvents = scheduledEventsByDate[date.getOnlyDate()] ?? []
                let isBlocked = scheduledEvents.contains { event in
                    SchedulerUtils.timeSlot(timeSlot, overlaps: event)
                }
                DispatchQueue.main.async {
                    completion(!isBlocked)
                }
            }, failure: failure)
        }
    }

    /// Whether a slot intersects an event's half-open window [start, end). A slot with no
    /// end is treated as the single instant it starts at.
    static func timeSlot(_ timeSlot: TimeRange, overlaps event: TimeRange) -> Bool {
        guard timeSlot.startTime.isValidSchedulerTime,
              event.startTime.isValidSchedulerTime,
              event.endTime.isValidSchedulerTime else { return false }

        let slotStart = timeSlot.startTime
        if timeSlot.endTime.isValidSchedulerTime, timeSlot.endTime > slotStart {
            return slotStart < event.endTime && event.startTime < timeSlot.endTime
        }
        return event.startTime <= slotStart && slotStart < event.endTime
    }

    static func convertToLocalTimeZone(availability: [String: [TimeRange]], date: Date, timeZoneCode: String) -> [TimeRange] {
        
        var convertedAvailability = [TimeRange]()
        let senderStartDate = combinedDate(date.getOnlyDate(), "0000", fromTimeZone: TimeZone.current.identifier, toTimeZone: timeZoneCode)
        let senderEndDate = combinedDate(date.getOnlyDate(), "2359", fromTimeZone: TimeZone.current.identifier, toTimeZone: timeZoneCode)
        var senderTimeAvList = [TimeRange]()
        let startDateAvailability = senderStartDate.date.todateIfValid().flatMap { availability[$0.dayOfWeek()] } ?? []
        
        startDateAvailability.forEach { timeRange in
            let newTimeRange = TimeRange()
            newTimeRange.endTime = timeRange.endTime
            newTimeRange.startTime = timeRange.startTime
            newTimeRange.startDate = senderStartDate.date
            senderTimeAvList.append(newTimeRange)
        }
        
        if senderStartDate.date != senderEndDate.date {
            let endDateAvailability = senderEndDate.date.todateIfValid().flatMap { availability[$0.dayOfWeek()] } ?? []
            endDateAvailability.forEach { timeRange in
                let newTimeRange = TimeRange()
                newTimeRange.endTime = timeRange.endTime
                newTimeRange.startTime = timeRange.startTime
                newTimeRange.startDate = senderEndDate.date
                senderTimeAvList.append(newTimeRange)
            }
        }
        
        senderTimeAvList.forEach { timeRange in
            
            let localStartDate = convertTimezone(dateString: timeRange.startDate, timeString: timeRange.startTime, fromTimeZoneIdentifier: timeZoneCode, toTimeZoneIdentifier: TimeZone.current.identifier)
            let localEndDate = convertTimezone(dateString: timeRange.startDate, timeString: timeRange.endTime, fromTimeZoneIdentifier: timeZoneCode, toTimeZoneIdentifier: TimeZone.current.identifier)
            
            if localStartDate?.date == date.getOnlyDate() {
                if localEndDate?.date == date.getOnlyDate() {
                    convertedAvailability.append(
                        TimeRange(
                            startTime: localStartDate?.time ?? "",
                            endTime: localEndDate?.time ?? ""
                        )
                    )
                } else {
                    convertedAvailability.append(
                        TimeRange(
                            startTime: localStartDate?.time ?? "",
                            endTime: "2359"
                        )
                    )
                }
            } else {
                if localEndDate?.date == date.getOnlyDate() {
                    convertedAvailability.append(
                        TimeRange(
                            startTime: "0000",
                            endTime: localEndDate?.time ?? ""
                        )
                    )
                }
            }
        }
        
        convertedAvailability.sort { $0.startTime < $1.startTime }
        
        return convertedAvailability
    }
    
    static func combinedDate(_ dateString: String, _ timeString: String, fromTimeZone: String? = nil, toTimeZone: String? = nil) -> (date: String, time: String) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        if let date = dateFormatter.date(from: dateString) {
            let fromTimeZone = fromTimeZone.flatMap { TimeZone(identifier: $0) }
            dateFormatter.timeZone = fromTimeZone ?? TimeZone.current
            
            let dateWithTime = "\(dateString) \(timeString)"
            dateFormatter.dateFormat = "yyyyMMdd HHmm"
            
            if let finalDate = dateFormatter.date(from: dateWithTime) {
                if let toTimeZone = toTimeZone {
                    let timeZone = TimeZone(identifier: toTimeZone)
                    dateFormatter.timeZone = timeZone
                }
                
                let finalDateString = dateFormatter.string(from: finalDate)
                return (finalDateString.prefix(8).description, finalDateString.suffix(4).description)
            }
        }

        return ("", "")
    }
    
    static func convertTimezone(dateString: String, timeString: String, fromTimeZoneIdentifier: String, toTimeZoneIdentifier: String) -> (date: String, time: String)? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd HHmm"
        
        guard let fromTimeZone = TimeZone(identifier: fromTimeZoneIdentifier),
              let toTimeZone = TimeZone(identifier: toTimeZoneIdentifier) else {
            return nil
        }
        
        dateFormatter.timeZone = fromTimeZone
        
        if let inputDate = dateFormatter.date(from: "\(dateString) \(timeString)") {
            dateFormatter.timeZone = toTimeZone
            let outputDateString = dateFormatter.string(from: inputDate)
            
            let components = outputDateString.components(separatedBy: " ")
            let outputDate = components.first ?? ""
            let outputTime = components.last ?? ""
            
            return (date: outputDate, time: outputTime)
        }
        
        return nil
    }

    
}

extension Int {
    
    func convertMinutesToString() -> String {
        let hours = self / 60
        let mins = self % 60

        let formattedString = String(format: "%02d%02d", hours, mins)
        return formattedString
    }
    
}

extension String {
    
    internal func isBefore(time: String) -> Bool {
        
        if (self == "2400" && time == "2359") {
            return true
        }
        
        guard self.count == 4,
              let selfHours = Int(self.prefix(2)),
              let selfMinutes = Int(self.suffix(2)) else {
            return false
        }
        
        guard time.count == 4,
              let givenHours = Int(time.prefix(2)),
              let givenMinutes = Int(time.suffix(2)) else {
            return false
        }
        
        if selfHours < givenHours {
            return true
        } else if selfHours == givenHours {
            if selfMinutes <= givenMinutes {
                return true
            }else {
                return false
            }
        } else {
            return false
        }
    }
    
    internal func isAfter(time: String) -> Bool {
        guard self.count == 4,
              let selfHours = Int(self.prefix(2)),
              let selfMinutes = Int(self.suffix(2)) else {
            return false
        }
        
        guard time.count == 4,
              let givenHours = Int(time.prefix(2)),
              let givenMinutes = Int(time.suffix(2)) else {
            return false
        }
        
        if selfHours > givenHours {
            return true
        } else if selfHours == givenHours {
            if selfMinutes >= givenMinutes {
                return true
            }else {
                return false
            }
        } else {
            return false
        }
    }
    
    internal func add(time: String, ordered24Formate: Bool = false) -> String? {
        guard self.count == 4,
              let selfHours = Int(self.prefix(2)),
              let selfMinutes = Int(self.suffix(2)) else {
            return nil
        }
        
        guard time.count == 4,
              let addingHours = Int(time.prefix(2)),
              let addingMinutes = Int(time.suffix(2)) else {
            return nil
        }
        
        var afterAddedHours = selfHours + addingHours + ((selfMinutes+addingMinutes)/60)
        let afterAddedMinutes = ((selfMinutes+addingMinutes)%60)
        
        if ordered24Formate {
            if afterAddedHours >= 24 {
                afterAddedHours -= 24
            }
        }
        
        return String(format: "%02d%02d", afterAddedHours, afterAddedMinutes)
        
    }
    
    internal func todate(format: String = "yyyyMMdd") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)!
    }

    /// `todate(format:)` without the trap: nil when the string is empty or does not match.
    internal func todateIfValid(format: String = "yyyyMMdd") -> Date? {
        guard !self.isEmpty else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }

    /// A four-digit "HHmm" time, or the end-of-day "2400".
    internal var isValidSchedulerTime: Bool {
        return self == "2400" || hhmmComponents() != nil
    }
}

extension Date {
    internal func convertToLocaleTimeZone() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = dateFormatter.string(from: self)
        return dateFormatter.date(from: dateString) ?? Date()
    }
    
    internal func stringFrom(formate: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateFormat = formate
        return dateFormatter.string(from: self)
    }
}
