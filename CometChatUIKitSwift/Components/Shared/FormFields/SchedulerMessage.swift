//
//  MeetingMessage.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 25/12/23.
//

import Foundation
import CometChatSDK

public class SchedulerMessage: InteractiveMessage {
    
    public var title: String?
    public var avatarURL: String?
    public var goalCompletionText: String = ""
    public var timezoneCode: String = ""
    public var bufferTime = 0
    public var duration = 60
    public var dateRangeStart = Int(Date().timeIntervalSince1970)
    public var dateRangeEnd = Int(Date().addingTimeInterval((60 * 24 * 60 * 60)).timeIntervalSince1970)
    public var icsFileUrl: String = ""
    public var scheduleElement: ButtonElement?
    public var availability: [String: [TimeRange]] = [:]
    
    public override init() {
        super.init()
        
        let defaultInteractionGoal = InteractionGoal()
        defaultInteractionGoal.interactionType = .anyAction
        self.interactionGoal = defaultInteractionGoal
        self.allowSenderInteraction = false
        self.type = "scheduler"
    }
    
    public static func toSchedulerMessage(_ interactiveMessage: InteractiveMessage) -> SchedulerMessage {
        
        let schedulerMessage = SchedulerMessage()
        schedulerMessage.type = MessageTypeConstants.scheduler
        schedulerMessage.id = interactiveMessage.id
        schedulerMessage.receiverType = interactiveMessage.receiverType
        schedulerMessage.receiver = interactiveMessage.receiver
        schedulerMessage.sender = interactiveMessage.sender
        schedulerMessage.senderUid = interactiveMessage.senderUid
        schedulerMessage.sentAt = interactiveMessage.sentAt
        schedulerMessage.readAt = interactiveMessage.readAt
        schedulerMessage.deliveredAt = interactiveMessage.deliveredAt
        schedulerMessage.deletedAt = interactiveMessage.deletedAt
        schedulerMessage.updatedAt = interactiveMessage.updatedAt
        schedulerMessage.deletedBy = interactiveMessage.deletedBy
        schedulerMessage.interactionGoal = interactiveMessage.interactionGoal
        schedulerMessage.metaData = interactiveMessage.metaData
        schedulerMessage.muid = interactiveMessage.muid
        schedulerMessage.rawMessage = interactiveMessage.rawMessage
        schedulerMessage.conversationId = interactiveMessage.conversationId
        schedulerMessage.readByMeAt = interactiveMessage.readByMeAt
        schedulerMessage.receiverUid = interactiveMessage.receiverUid
        schedulerMessage.replyCount = interactiveMessage.replyCount
        schedulerMessage.tags = interactiveMessage.tags
        schedulerMessage.allowSenderInteraction = interactiveMessage.allowSenderInteraction
        schedulerMessage.interactions = interactiveMessage.interactions
        schedulerMessage.interactiveData = interactiveMessage.interactiveData
        schedulerMessage.reactions = interactiveMessage.reactions
        schedulerMessage.mentionedMe = interactiveMessage.mentionedMe
        schedulerMessage.mentionedUsers = interactiveMessage.mentionedUsers
        
        if let interactiveData = interactiveMessage.interactiveData {
            if let title = interactiveData[InteractiveConstants.TITLE] as? String {
                schedulerMessage.title = title
            }
            if let avatarURL = interactiveData[InteractiveConstants.AVATAR_URL] as? String {
                schedulerMessage.avatarURL = avatarURL
            }
            if let goalCompletionText = interactiveData[InteractiveConstants.GOAL_COMPELTION_TEXT] as? String {
                schedulerMessage.goalCompletionText = goalCompletionText
            }
            if let bufferTime = interactiveData[InteractiveConstants.BUFFER_TIME] as? Int {
                schedulerMessage.bufferTime = bufferTime
            }
            if let meetingDuration = interactiveData[InteractiveConstants.MEETING_DURATION] as? Int {
                if meetingDuration > 0 {
                    schedulerMessage.duration = meetingDuration
                }
            }
            
            if let meetingDateRangeStart = interactiveData[InteractiveConstants.DATE_RANGE_START] as? String {
                schedulerMessage.dateRangeStart = Int(meetingDateRangeStart.todate(format: SchedulerMessageConstants.defaultDateFormate).timeIntervalSince1970)
            }
            
            if let meetingDateRangeEnd = interactiveData[InteractiveConstants.DATE_RANGE_END] as? String {
                schedulerMessage.dateRangeEnd = Int(meetingDateRangeEnd.todate(format: SchedulerMessageConstants.defaultDateFormate).timeIntervalSince1970)
            }
            
            if let icsFileUrl = interactiveData[InteractiveConstants.ICS_FILE_URL] as? String {
                schedulerMessage.icsFileUrl = icsFileUrl
            }
            
            if let timezoneCode = interactiveData[InteractiveConstants.TIME_ZONE_CODE] as? String {
                schedulerMessage.timezoneCode = timezoneCode
            }
            if let scheduleElement = interactiveData[InteractiveConstants.SCHEDULE_ELEMENT] as? [String:Any] {
                if let element = ButtonElement.buttonElementFromJSON_(scheduleElement) {
                    schedulerMessage.scheduleElement = element
                }
            }
            if let availability = interactiveData[InteractiveConstants.AVAILABILITY] as? [String: Any] {
                schedulerMessage.availability = TimeRange.from(json: availability)
            }
        }
        
        return schedulerMessage
    }
    
    
    public static func interactiveMessage(from schedulerMessage: SchedulerMessage) -> InteractiveMessage {
        
        let interactiveMessage = InteractiveMessage()
        var interactiveData = [String: Any]()
        interactiveData[InteractiveConstants.TITLE] = schedulerMessage.title
        interactiveData[InteractiveConstants.AVATAR_URL] = schedulerMessage.avatarURL
        interactiveData[InteractiveConstants.GOAL_COMPELTION_TEXT] = schedulerMessage.goalCompletionText
        interactiveData[InteractiveConstants.BUFFER_TIME] = schedulerMessage.bufferTime
        interactiveData[InteractiveConstants.MEETING_DURATION] = schedulerMessage.duration
        interactiveData[InteractiveConstants.DATE_RANGE_START] = (Date(timeIntervalSince1970: TimeInterval(schedulerMessage.dateRangeStart)).stringFrom(formate: "yyyy-MM-dd"))
        interactiveData[InteractiveConstants.DATE_RANGE_END] = (Date(timeIntervalSince1970: TimeInterval(schedulerMessage.dateRangeStart)).stringFrom(formate: "yyyy-MM-dd"))
        interactiveData[InteractiveConstants.ICS_FILE_URL] = schedulerMessage.icsFileUrl
        interactiveData[InteractiveConstants.TIME_ZONE_CODE] = schedulerMessage.timezoneCode
        interactiveData[InteractiveConstants.AVAILABILITY] = TimeRange.to(json: schedulerMessage.availability)
        interactiveMessage.receiverType = schedulerMessage.receiverType
        interactiveMessage.receiverUid = schedulerMessage.receiverUid
        interactiveMessage.type = schedulerMessage.type
        interactiveData[InteractiveConstants.SCHEDULE_ELEMENT] = schedulerMessage.scheduleElement?.toJSON()
        
        interactiveMessage.interactiveData = interactiveData
        
        return interactiveMessage
    }
}


public class TimeRange {
    
    public var startTime = ""
    public var endTime = ""
    internal var startDate = ""
    internal var endDate = ""
    
    public init(startTime: String = "", endTime: String = "") {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    internal init(startTime: String = "", endTime: String = "", startDate: String = "", endDate: String = "") {
        self.startTime = startTime
        self.endTime = endTime
        self.endDate = endDate
        self.startDate = startDate
    }
    
    public static func from(json: [String: Any]) -> [String: [TimeRange]] {
        var timeRangeByDay = [String: [TimeRange]]()

        for (day, availabilityByDay) in json {
            guard let availabilityByDay = availabilityByDay as? [[String: String]] else {
                continue
            }

            var timeRanges = [TimeRange]()
            for availability in availabilityByDay {
                guard let from = availability["from"], let to = availability["to"] else {
                    continue
                }
                timeRanges.append(TimeRange(startTime: from, endTime: to))
            }

            timeRangeByDay[day] = timeRanges
        }

        return timeRangeByDay
    }
    
    public static func to(json timeRangeByDay: [String: [TimeRange]]) -> [String: Any] {
        var jsonRepresentation = [String: Any]()

        for (day, timeRanges) in timeRangeByDay {
            let timeRangesJSON = timeRanges.map { timeRange in
                return ["from": timeRange.startTime, "to": timeRange.endTime]
            }
            jsonRepresentation[day.lowercased()] = timeRangesJSON
        }

        return jsonRepresentation
    }

}
