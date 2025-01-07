//
//  TimeSlotView.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 28/12/23.
//

import Foundation
import UIKit

public class TimeSlotView: UIView {
    
    private(set) weak var controller: UIViewController?
    private(set) var style: SchedulerBubbleStyle?
    private(set) var message: SchedulerMessage?
    private(set) var onBackButtonClicked: (() -> ())?
    private(set) var onTimeSelected: ((_: TimeRange, _:Date) -> ())?
    private(set) var unavailableTimeRange: [String: [TimeRange]]?
    private(set) var date: Date?
    private(set) var isTableViewUpdating: ((_: Bool) -> ())?
    
    private var timeSlots = [TimeRange]()
    
    var headingView = UIView()
    
    var middleView = UIStackView()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        self.translatesAutoresizingMaskIntoConstraints = false
        buildInitialView()
    }
    
    func buildInitialView() {
        
        guard let message = message else { return }
        headingView = SchedulerHeaderView.getHeaderView(message: message, style: style, onBackButtonClicked:  #selector(onBackButtonClickedSelector), target: self)
        headingView.translatesAutoresizingMaskIntoConstraints = false
        headingView.layoutIfNeeded()
        self.addSubview(headingView)
        headingView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        headingView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        headingView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
        let timeSlotSelector = CometChatTimeSlotSelector()
            .set(date: date)
            .set(style: style?.timeSlotSelectorStyle)
            .set(duration: message.duration)
            .set(bufferTime: message.bufferTime)
            .set(icsFileUrl: message.icsFileUrl)
            .set(unavailableTimeRange: unavailableTimeRange)
            .set(timeZone: message.timezoneCode)
            .set(onTimeSelected: { [weak self] timeRange, date in
                guard let this = self else { return }
                this.onTimeSelected?(timeRange, date)
            })
            .set(availability: message.availability)
            .set(isTableViewUpdating: { [weak self] isUpdating in
                guard let this = self else { return }
                this.layoutIfNeeded()
                this.isTableViewUpdating?(isUpdating)
            })
            .build()
        
        self.addSubview(timeSlotSelector)
        timeSlotSelector.translatesAutoresizingMaskIntoConstraints = false
        timeSlotSelector.topAnchor.constraint(equalTo: headingView.bottomAnchor, constant: 10).isActive = true
        timeSlotSelector.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        timeSlotSelector.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -15).isActive = true
        timeSlotSelector.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
        
    }
    
    @objc func onBackButtonClickedSelector() {
        self.onBackButtonClicked?()
    }
    
}

extension TimeSlotView {
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(style: SchedulerBubbleStyle?) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(message: SchedulerMessage?) -> Self {
        self.message = message
        return self
    }
    
    @discardableResult
    public func set(onBackButtonClicked: (() -> ())?) -> Self {
        self.onBackButtonClicked = onBackButtonClicked
        return self
    }
    
    @discardableResult
    public func set(onTimeSelected: ((_: TimeRange, _:Date) -> ())?) -> Self {
        self.onTimeSelected = onTimeSelected
        return self
    }
    
    @discardableResult
    public func set(date: Date?) -> Self {
        self.date = date
        return self
    }
    
    @discardableResult
    public func set(unavailableTimeRange: [String: [TimeRange]]?) -> Self {
        self.unavailableTimeRange = unavailableTimeRange
        return self
    }
    
    @discardableResult
    public func set(isTableViewUpdating: ((_: Bool) -> ())?) -> Self {
        self.isTableViewUpdating = isTableViewUpdating
        return self
    }
    
    @discardableResult
    public func build() -> Self {
        self.buildUI()
        return self
    }
    
}
