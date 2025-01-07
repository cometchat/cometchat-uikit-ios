//
//  CometChatTimeSlotSelector.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 03/01/24.
//

import Foundation
import UIKit

public class CometChatTimeSlotSelector: UIStackView {
    
    private(set) var style = TimeSlotSelectorStyle()
    private(set) var isTableViewUpdating: ((_: Bool) -> ())?
    private(set) var onTimeSelected: ((_: TimeRange, _:Date) -> ())?
    private(set) var availability = [String: [TimeRange]]()
    private(set) var unavailableTimeRange: [String: [TimeRange]]?
    private(set) var bufferTime: Int?
    private(set) var duration: Int?
    private(set) var icsFileUrl: String?
    private(set) var date: Date?
    private var timeSlots = [TimeRange]()
    private(set) var hideDateText = false
    private(set) var hideSelectTimeText = false
    private(set) var hideTimeZone = false
    private(set) var timeZone: String?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSpinnerView()
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func buildUI() {
        
        self.backgroundColor = style.background
        self.borderWith(width: style.borderWidth)
        self.borderColor(color: style.borderColor)
        self.roundViewCorners(corner: style.cornerRadius)
        
        if let date = date {
            if let availability = availability[date.dayOfWeek().lowercased()], !availability.isEmpty, let bufferTime = bufferTime, let duration = duration, let timeZone = timeZone {
                
                let completionHandler: ((_: [TimeRange]?) -> ()) = { slots in
                    self.timeSlots = slots ?? []
                    
                    self.isTableViewUpdating?(true)
                    self.buildTimeSlot()
                    self.isTableViewUpdating?(false)
                    

                }
                
                if let unavailableTimeRange = unavailableTimeRange {
                    SchedulerUtils.generateTimeSlots(allAvailableTimes: self.availability, allUnAvailableTime: unavailableTimeRange, forDate: date, bufferTime: bufferTime, duration: duration, timeZoneCode: timeZone, completion: completionHandler)
                } else if let icsFileUrl = icsFileUrl {
                    SchedulerUtils.getAvailableTimeSlots(ICSFile: icsFileUrl , forDate: date, availableTimes: self.availability, bufferTime: bufferTime, duration: duration, timeZoneCode: timeZone, completion: completionHandler)
                }
                
            } else {
                self.isTableViewUpdating?(true)
                self.buildTimeSlot()
                self.isTableViewUpdating?(false)
            }
        }
    }
    
    func buildTimeSlot() {
        
        self.axis = .vertical
        self.spacing = 20
        self.translatesAutoresizingMaskIntoConstraints = false
        
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        let dateStackView = UIStackView()
        dateStackView.axis = .horizontal
        dateStackView.spacing = 6
        dateStackView.distribution = .fillProportionally
        dateStackView.translatesAutoresizingMaskIntoConstraints = false
        dateStackView.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        let dateIcon = UIImageView()
        dateIcon.translatesAutoresizingMaskIntoConstraints = false
        let dateImage = UIImage(named: "calendar", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
        dateImage?.withTintColor(CometChatTheme_v4.palatte.accent900)
        dateIcon.image = dateImage
        dateIcon.tintColor = CometChatTheme_v4.palatte.accent800
        dateIcon.contentMode = .scaleAspectFit
        dateIcon.widthAnchor.constraint(equalToConstant: 15).isActive = true
        dateIcon.heightAnchor.constraint(equalToConstant: 15).isActive = true
        dateStackView.addArrangedSubview(dateIcon)
        
        let dateLabel = UILabel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy, EEE"
        dateLabel.text = dateFormatter.string(from: date ?? Date())
        dateLabel.textColor = CometChatTheme_v4.palatte.accent800
        dateLabel.font = CometChatTheme_v4.typography.text1
        dateStackView.isHidden = hideDateText
        dateStackView.addArrangedSubview(dateLabel)
        
        self.addArrangedSubview(dateStackView)
        self.setCustomSpacing(15, after: dateStackView)
        
        let dividerContainerView = UIView()
        dividerContainerView.translatesAutoresizingMaskIntoConstraints = false
        dividerContainerView.heightAnchor.constraint(equalToConstant: 0.2).isActive = true
        dividerContainerView.translatesAutoresizingMaskIntoConstraints = false
        dividerContainerView.backgroundColor = CometChatTheme_v4.palatte.accent300
        
        self.addArrangedSubview(dividerContainerView)
        
        self.setCustomSpacing(15, after: dividerContainerView)

        let selectTimeLabel = UILabel()
        selectTimeLabel.text = "SELECT_A_TIME".localize()
        selectTimeLabel.textColor = style.titleColor
        selectTimeLabel.font = style.titleFont 
        selectTimeLabel.isHidden = hideSelectTimeText
        self.addArrangedSubview(selectTimeLabel)
        self.setCustomSpacing(10, after: selectTimeLabel)
        
        
        if timeSlots.count != 0 {
            
            let timeSlotContainerStackView = UIStackView()
            timeSlotContainerStackView.axis = .vertical
            timeSlotContainerStackView.spacing = 7
            timeSlotContainerStackView.translatesAutoresizingMaskIntoConstraints = false
            
            var count = 0
            var timeSlotVContainerStackView = UIStackView()
            timeSlotVContainerStackView.axis = .horizontal
            timeSlotVContainerStackView.spacing = 7
            timeSlotVContainerStackView.distribution = .fillEqually
            timeSlotVContainerStackView.translatesAutoresizingMaskIntoConstraints = false
            
            for index in 0..<timeSlots.count {
                let timeSlot = timeSlots[index]
                let scheduleButton = UIButton(type: .system)
                scheduleButton.setTitle(timeSlot.startTime.to12HFormattedTime(), for: .normal)
                scheduleButton.backgroundColor = CometChatTheme_v4.palatte.background
                scheduleButton.setTitleColor(style.slotTextColor, for: .normal)
                scheduleButton.setTitleColor(style.selectedSlotTextColor, for: .highlighted)
                scheduleButton.titleLabel?.font = style.slotTextFont
                scheduleButton.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: 5))
                scheduleButton.tag = index
                scheduleButton.addTarget(self, action: #selector(onTimeSelectedSelector(_:)), for: .primaryActionTriggered)
                scheduleButton.translatesAutoresizingMaskIntoConstraints = false
                
                timeSlotVContainerStackView.addArrangedSubview(scheduleButton)
                count = count + 1
                
                if count == 3 {
                    count = 0
                    timeSlotContainerStackView.addArrangedSubview(timeSlotVContainerStackView)
                    timeSlotVContainerStackView = UIStackView()
                    timeSlotVContainerStackView.axis = .horizontal
                    timeSlotVContainerStackView.spacing = 5
                    timeSlotVContainerStackView.distribution = .fillEqually
                    timeSlotVContainerStackView.translatesAutoresizingMaskIntoConstraints = false
                }
            }
            
            if count > 0 {
                while (count != 3) {
                    timeSlotVContainerStackView.addArrangedSubview(UIView())
                    count = count + 1
                }
                timeSlotContainerStackView.addArrangedSubview(timeSlotVContainerStackView)
            }
            
            self.addArrangedSubview(timeSlotContainerStackView)
            
        } else {
            
            let errorContainerView = UIView()
            errorContainerView.translatesAutoresizingMaskIntoConstraints = false
                        
            let icon = UIImageView()
            icon.translatesAutoresizingMaskIntoConstraints = false
            let image = UIImage(named: "error-clock", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
            image?.withTintColor(CometChatTheme_v4.palatte.accent900)
            icon.image = image
            icon.tintColor = CometChatTheme_v4.palatte.accent600
            icon.contentMode = .scaleAspectFit
            icon.widthAnchor.constraint(equalToConstant: 35).isActive = true
            icon.heightAnchor.constraint(equalToConstant: 35).isActive = true
            errorContainerView.addSubview(icon)
            icon.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor).isActive = true
            icon.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor).isActive = true
            icon.topAnchor.constraint(equalTo: errorContainerView.topAnchor, constant: 50).isActive = true
            
            let noSlotsAvailableLabel = UILabel()
            noSlotsAvailableLabel.translatesAutoresizingMaskIntoConstraints = false
            noSlotsAvailableLabel.textColor = CometChatTheme_v4.palatte.accent600
            noSlotsAvailableLabel.font = CometChatTheme_v4.typography.text1
            noSlotsAvailableLabel.numberOfLines = 0
            noSlotsAvailableLabel.textAlignment = .center
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMMM yyyy"
            noSlotsAvailableLabel.text = "NO_TIME_SLOTS_AVAILABLE_FOR_THIS_DAY".localize()
            errorContainerView.addSubview(noSlotsAvailableLabel)
            noSlotsAvailableLabel.leadingAnchor.constraint(equalTo: errorContainerView.leadingAnchor).isActive = true
            noSlotsAvailableLabel.trailingAnchor.constraint(equalTo: errorContainerView.trailingAnchor).isActive = true
            noSlotsAvailableLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 10).isActive = true
            noSlotsAvailableLabel.bottomAnchor.constraint(equalTo: errorContainerView.bottomAnchor, constant: -50).isActive = true
                        
            self.addArrangedSubview(errorContainerView)
            
        }
        
        let timeZoneView = UIStackView()
        timeZoneView.axis = .horizontal
        timeZoneView.spacing = 5
        timeZoneView.distribution = .fill
        timeZoneView.translatesAutoresizingMaskIntoConstraints = false
        timeZoneView.addArrangedSubview(UIView())
        timeZoneView.isHidden = hideTimeZone
        
        let timeZoneIcon = UIImageView()
        timeZoneIcon.translatesAutoresizingMaskIntoConstraints = false
        let timeZoneImage = UIImage(named: "time-zone-earth", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
        timeZoneImage?.withTintColor(CometChatTheme_v4.palatte.accent900)
        timeZoneIcon.image = timeZoneImage
        timeZoneIcon.tintColor = CometChatTheme_v4.palatte.accent900
        timeZoneIcon.contentMode = .scaleAspectFill
        timeZoneIcon.widthAnchor.constraint(equalToConstant: 13).isActive = true
        timeZoneIcon.heightAnchor.constraint(equalToConstant: 13).isActive = true
        timeZoneView.addArrangedSubview(timeZoneIcon)
        
        let timeZoneLabel = UILabel()
        timeZoneLabel.translatesAutoresizingMaskIntoConstraints = false
        timeZoneLabel.textColor = CometChatTheme_v4.palatte.accent900
        timeZoneLabel.font = CometChatTheme_v4.typography.caption1
        timeZoneLabel.numberOfLines = 0
        timeZoneLabel.text = TimeZone.current.getFullForm()
        timeZoneLabel.sizeToFit()
        timeZoneView.addArrangedSubview(timeZoneLabel)
        
        self.addArrangedSubview(timeZoneView)
        self.setCustomSpacing(10, after: timeZoneView)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 0).isActive = true
        
        self.addArrangedSubview(spacer)
    }
    
    func addSpinnerView() {
        self.subviews.forEach({ $0.removeFromSuperview() })
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.heightAnchor.constraint(equalToConstant: 200).isActive = true
        spinner.startAnimating()
        self.addArrangedSubview(spinner)
    }

    @objc func onTimeSelectedSelector(_ sender: UIButton) {
        self.onTimeSelected?(timeSlots[sender.tag], date ?? Date())
    }
}

extension CometChatTimeSlotSelector {
    
    @discardableResult
    public func set(icsFileUrl: String?) -> Self {
        self.icsFileUrl = icsFileUrl
        return self
    }
    
    @discardableResult
    public func set(style: TimeSlotSelectorStyle?) -> Self {
        self.style = style ?? TimeSlotSelectorStyle()
        return self
    }
    
    @discardableResult
    public func set(date: Date?) -> Self {
        self.date = date
        return self
    }
    
    @discardableResult
    public func set(duration: Int) -> Self {
        self.duration = duration
        return self
    }
    
    @discardableResult
    public func set(bufferTime: Int) -> Self {
        self.bufferTime = bufferTime
        return self
    }
    
    @discardableResult
    public func set(onTimeSelected: ((_: TimeRange, _:Date) -> ())?) -> Self {
        self.onTimeSelected = onTimeSelected
        return self
    }
    
    @discardableResult
    public func set(availability: [String: [TimeRange]]) -> Self {
        self.availability = availability
        return self
    }
    
    @discardableResult
    public func set(isTableViewUpdating: ((_: Bool) -> ())?) -> Self {
        self.isTableViewUpdating = isTableViewUpdating
        return self
    }
    
    @discardableResult
    public func hide(dateText: Bool) -> Self {
        self.hideDateText = dateText
        return self
    }
    
    @discardableResult
    public func hide(timeZone: Bool) -> Self {
        self.hideTimeZone = timeZone
        return self
    }
    
    @discardableResult
    public func hide(selectTimeText: Bool) -> Self {
        self.hideSelectTimeText = selectTimeText
        return self
    }
    
    @discardableResult
    public func set(timeZone: String) -> Self {
        self.timeZone = timeZone
        return self
    }
    
    @discardableResult
    public func build() -> Self {
        self.buildUI()
        return self
    }
    
    @discardableResult
    public func set(unavailableTimeRange: [String: [TimeRange]]?) -> Self {
        self.unavailableTimeRange = unavailableTimeRange
        return self
    }
    
}
