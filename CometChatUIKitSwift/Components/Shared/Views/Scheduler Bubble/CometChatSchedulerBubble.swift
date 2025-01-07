//
//  CometChatMeetingBubble.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 25/12/23.
//

import Foundation
import UIKit
import CometChatSDK

public class CometChatSchedulerBubble: UIView {
    
    private var viewStack = [UIView]()
    private(set) weak var controller: UIViewController?
    private(set) var style = SchedulerBubbleStyle()
    private(set) var message: SchedulerMessage?
    private(set) var onScheduleClick: ((_ dateTime: String?, _ message: SchedulerMessage) -> Void)?
    private(set) var unavailableTimeRange: [String: [TimeRange]]?
    private var tableView: UITableView?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public init() {
        super.init(frame: .zero)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        self.backgroundColor = style.background
        self.borderWith(width: style.borderWidth)
        self.borderColor(color: style.borderColor)
        self.roundViewCorners(corner: style.cornerRadius)
        
        self.widthAnchor.constraint(equalToConstant: ((window?.bounds.size.width ?? 340) - 40)).isActive = true
        
        if let message = message, (!message.allowSenderInteraction && LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)) {
            self.isUserInteractionEnabled = false
        }
        
        if let message = message, (message.interactions == nil || message.interactions?.isEmpty == true) {
            suggestionTimeView()
        } else {
            openMessageInteractedView()
        }
    }
    
    func addToSuperView(view: UIView) {
        
        self.viewStack.append(view)
        let tableView = getTableView(self)
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        tableView?.beginUpdates()
        
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
        tableView?.endUpdates()
    }
    
    func onBackButtonClicked() {
        
        self.viewStack.remove(at: (viewStack.count-1))
        guard let view = viewStack.last else { return }
        let tableView = getTableView(self)
        let tableViewOffSet = tableView?.contentOffset
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        tableView?.beginUpdates()
        
        self.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
        tableView?.endUpdates()
        if let tableViewOffSet = tableViewOffSet {
            tableView?.setContentOffset(tableViewOffSet, animated: false)
        }
    }
    
    func onScheduleButtonClicked(timeSlot: TimeRange, date: Date, onFailure: @escaping (() -> Void)) {
        guard let message = self.message else { return }
        if (onScheduleClick != nil) {
            onScheduleClick?(self.getFinalDate(date: date, time: timeSlot.startTime), message)
        } else {
            let scheduledPayload: [String: Any] = [
                InteractiveConstants.DURATION: message.duration,
                InteractiveConstants.MEET_STARTED_AT: (self.getFinalDate(date: date, time: timeSlot.startTime) ?? ""),
            ]
            ActionElementUtils.performAction(message: message, buttonElement: message.scheduleElement, payload: [InteractiveConstants.ButtonUIConstants.SCHEDULER_DATA: scheduledPayload]) { [weak self] success in
                guard let this = self else { return }
                if success {
                    DispatchQueue.main.async {
                        this.openMessageInteractedView()
                    }
                    CometChat.markAsInteracted(messageId: message.id, interactedElementId: message.scheduleElement?.elementId ?? "") { _ in } onError: { _ in   }
                } else {
                    DispatchQueue.main.async {
                        onFailure()
                    }
                }
            }
        }
    }
    
    
    func getFinalDate(date: Date, time: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let datePart = dateFormatter.string(from: date)
        
        dateFormatter.dateFormat = "yyyy-MM-dd HHmm"
        guard let convertedDate = dateFormatter.date(from: "\(datePart) \(time)") else {
            return nil
        }
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return dateFormatter.string(from: convertedDate)
    }
}

//Internal UI
extension CometChatSchedulerBubble {
    
    func suggestionTimeView() {
        
        guard let message = message else { return }
        let suggestionTimeView = SuggestionTimeView()
            .set(style: style)
            .set(controller: controller)
            .set(message: message)
            .set(onTimeSelected: { [weak self] pickedTimeSlot, date in
                guard let this = self else { return }
                this.onTimeSelected(timeSlot: pickedTimeSlot, date: date)
            })
            .set(onMoreTimeButtonClicked: { [weak self] in
                guard let this = self else { return }
                this.openCalendarView()
            })
            .set(isTableViewUpdating: { [weak self] isUpdating in
                guard let this = self else { return }
                let tableView = this.getTableView(this)
                if isUpdating {
                    tableView?.beginUpdates()
                } else {
                    tableView?.endUpdates()
                }
            })
            .set(onUnavailableTimeRangeDownloaded: { [weak self] unavailableTimeRange in
                guard let this = self else { return }
                this.unavailableTimeRange = unavailableTimeRange
            })
            .set(isIntractable: !(!message.allowSenderInteraction && LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)))
            .build()
        
        self.addToSuperView(view: suggestionTimeView)
    }
    
    func onTimeSelected(timeSlot: TimeRange, date: Date) {
        let timeConfirmationView = ConfirmationView()
            .set(style: style)
            .set(controller: controller)
            .set(date: date)
            .set(timeSlot: timeSlot)
            .set(message: message)
            .set(onBackButtonClicked: onBackButtonClicked)
            .set(onTryAgainClicked: { [weak self] in
                guard let this = self else { return }
                this.viewStack = []
                this.suggestionTimeView()
            })
            .set(isTableViewUpdating: { [weak self] isUpdating in
                guard let this = self else { return }
                let tableView = this.getTableView(this)
                if isUpdating {
                    tableView?.beginUpdates()
                } else {
                    tableView?.endUpdates()
                }
            })
            .set(onScheduleButtonClicked: { [weak self] onFailure in
                guard let this = self else { return }
                this.onScheduleButtonClicked(timeSlot: timeSlot, date: date, onFailure: onFailure)
            })
            .build()
        
        self.addToSuperView(view: timeConfirmationView)
    }
    
    func openMessageInteractedView() {
        
        guard let message = self.message else { return }
        let InteractedView = InteractedView()
            .set(bodyText: message.goalCompletionText != "" ? message.goalCompletionText : "MEETING_SCHEDULED".localize() )
            .set(titleText: message.title)
            .set(subtitleText: "Meeting Scheduler")
            .build()
        
        self.addToSuperView(view: InteractedView)
    }
    
    func openCalendarView() {
        let calendarView = CalendarView()
            .set(style: style)
            .set(controller: controller)
            .set(message: message)
            .set(onBackButtonClicked: { [weak self] in
                guard let this = self else { return }
                this.onBackButtonClicked()
            })
            .set(onDateSelected: {  [weak self] date in
                guard let this = self else { return }
                this.openTimeSlotView(date: date)
            })
            .build()
        
        self.addToSuperView(view: calendarView)
    }
    
    func openTimeSlotView(date: Date) {
        let timeSlotView = TimeSlotView()
            .set(style: style)
            .set(controller: controller)
            .set(date: date)
            .set(message: message)
            .set(unavailableTimeRange: unavailableTimeRange)
            .set(onBackButtonClicked: { [weak self] in
                guard let this = self else { return }
                this.onBackButtonClicked()
            })
            .set(onTimeSelected:  { [weak self] pickedTimeSlot, date in
                guard let this = self else { return }
                this.onTimeSelected(timeSlot: pickedTimeSlot, date: date)
            })
            .set(isTableViewUpdating: { [weak self] isUpdating in
                guard let this = self else { return }
                let tableView = this.getTableView(this)
                if isUpdating {
                    tableView?.beginUpdates()
                } else {
                    tableView?.endUpdates()
                }
            })
            .build()
        
        self.addToSuperView(view: timeSlotView)
    }
    
}

//properties
extension CometChatSchedulerBubble {
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(style: SchedulerBubbleStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(message: SchedulerMessage) -> Self {
        self.message = message
        self.buildUI()
        return self
    }
    
    @discardableResult
    public func set(onScheduleClick: ((_ dateTime: String?, _ message: SchedulerMessage) -> Void)?) -> Self {
        self.onScheduleClick = onScheduleClick
        return self
    }
}

extension CometChatSchedulerBubble {
    
    func getTableView(_ view: UIView) -> UITableView? {
        if let tableView = self.tableView {
            return tableView
        }
        if let tableView = traverseHierarchy(view: self.controller?.view ?? UIView()) {
            self.tableView = tableView
            return tableView
        }
        return nil
    }

    func traverseHierarchy(view: UIView) -> UITableView? {
        if let messageListView = view as? CometChatMessageList {
            if view.isDescendant(of: messageListView) {
                return findTableViewInView(view: messageListView)
            }
        }

        for i in 0..<view.subviews.count {
            let subview = view.subviews[i]
            if let tableView = traverseHierarchy(view: subview) {
                return tableView
            }
        }

        return nil
    }

    func findTableViewInView(view: UIView) -> UITableView? {
        if let tableView = view as? UITableView {
            return tableView
        }

        for i in 0..<view.subviews.count {
            let subview = view.subviews[i]
            if let tableView = findTableViewInView(view: subview) {
                return tableView
            }
        }

        return nil
    }
    
}
