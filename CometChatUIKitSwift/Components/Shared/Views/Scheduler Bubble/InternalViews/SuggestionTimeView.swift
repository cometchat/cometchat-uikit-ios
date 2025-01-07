//
//  SuggestionTimeView.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 27/12/23.
//

import Foundation
import UIKit

class SuggestionTimeView: UIView {
    
    private(set) weak var controller: UIViewController?
    private(set) var style = SchedulerBubbleStyle()
    private(set) var message: SchedulerMessage?
    private(set) var onMoreTimeButtonClicked: (() -> ())?
    private(set) var onTimeSelected: ((_: TimeRange, _:Date) -> ())?
    private(set) var onUnavailableTimeRangeDownloaded: ((_: [String: [TimeRange]]) -> ())?
    private(set) var isTableViewUpdating: ((_: Bool) -> ())?
    private let midView = UIView()
    private let headerView = UIView()
    private var timeSlots = [TimeRange]()
    private var isIntractable = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        buildInitialView()
        addSpinnerView()
        getSuggestedTimeSlot()
        
    }
    
    func getSuggestedTimeSlot() {
        
        guard let message = message else { return }
        
        let ICSFile = message.icsFileUrl
        if let url = URL(string: ICSFile) {
            CometChatICSParser.load(url: url, completion: { [weak self] eventsByDate in
                guard let this = self else { return }
                this.onUnavailableTimeRangeDownloaded?(eventsByDate)
                var eventsByDate = eventsByDate
                let forDate = max(Date(timeIntervalSince1970: TimeInterval(message.dateRangeStart)), Date())
                if forDate.getOnlyDate() == Date().getOnlyDate() {

                    if var currentDateObj = eventsByDate[forDate.getOnlyDate()] {
                        currentDateObj.append(TimeRange(startTime: "0000", endTime: forDate.to24HFormateTime(), startDate: forDate.getOnlyDate(), endDate: forDate.getOnlyDate()))
                        eventsByDate[forDate.getOnlyDate()] = currentDateObj
                    }else {
                        eventsByDate.append(with: [(forDate.getOnlyDate()): [TimeRange(startTime: "0000", endTime: forDate.to24HFormateTime(), startDate: forDate.getOnlyDate(), endDate: forDate.getOnlyDate())]])
                    }
                }
                this.getTimeSlots(eventsByDate: eventsByDate, date: forDate)
            })
        } else {
            var eventByDate = [String: [TimeRange]]()
            let forDate = max(Date(timeIntervalSince1970: TimeInterval(message.dateRangeStart)), Date())
            if forDate.getOnlyDate() == Date().getOnlyDate() {
                if var currentDateObj = eventByDate[forDate.getOnlyDate()] {
                    currentDateObj.append(TimeRange(startTime: "0000", endTime: forDate.to24HFormateTime(), startDate: forDate.getOnlyDate(), endDate: forDate.getOnlyDate()))
                    eventByDate[forDate.getOnlyDate()] = currentDateObj
                }else {
                    eventByDate.append(with: [(forDate.getOnlyDate()): [TimeRange(startTime: "0000", endTime: forDate.to24HFormateTime(), startDate: forDate.getOnlyDate(), endDate: forDate.getOnlyDate())]])
                }
            }
            getTimeSlots(eventsByDate: eventByDate, date: forDate)
        }
        
    }
    
    func getTimeSlots(eventsByDate: [String: [TimeRange]], date: Date) {
        guard let message = message else { return }
        
        if timeSlots.count > 2 {
            self.isTableViewUpdating?(true)
            self.buildMidWithSlotsView()
            self.isTableViewUpdating?(false)
            return
        }
        
        if date > Date(timeIntervalSince1970: TimeInterval(message.dateRangeEnd)) {
            buildMidForNoSlots()
            return
        }
        
        SchedulerUtils.generateTimeSlots(allAvailableTimes: message.availability, allUnAvailableTime: eventsByDate, forDate: date, bufferTime: message.bufferTime, duration: message.duration, timeZoneCode: message.timezoneCode, completion: { [weak self] slots in
            guard let this = self else { return }
            for slot in (slots ?? []) {
                slot.startDate = String(Int(date.timeIntervalSince1970))
                slot.endDate = String(Int(date.timeIntervalSince1970))
                this.timeSlots.append(slot)
            }
            this.getTimeSlots(eventsByDate: eventsByDate, date: date.addingTimeInterval(TimeInterval(86400)))
        })
    }
    
    func addSpinnerView() {
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        midView.addSubview(spinner)
        spinner.topAnchor.constraint(equalTo: midView.topAnchor, constant: 0).isActive = true
        spinner.leadingAnchor.constraint(equalTo: midView.leadingAnchor, constant: 0).isActive = true
        spinner.trailingAnchor.constraint(equalTo: midView.trailingAnchor, constant: 0).isActive = true
        spinner.bottomAnchor.constraint(equalTo: midView.bottomAnchor, constant: -10).isActive = true
        spinner.heightAnchor.constraint(equalToConstant: 200).isActive = true
        spinner.startAnimating()
    }
    
    func buildInitialView() {
        
        self.addSubview(headerView)
        headerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        headerView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        headerView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        
        let avatarView = CometChatAvatar(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        avatarView.setAvatar(avatarUrl: message?.avatarURL ?? message?.sender?.avatar, with: message?.sender?.name)
        avatarView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        avatarView.widthAnchor.constraint(equalToConstant: 60).isActive = true
//        avatarView.set(avatarStyle: style.avatarStyle)
        headerView.addSubview(avatarView)
        avatarView.translatesAutoresizingMaskIntoConstraints = false
        avatarView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 30).isActive = true
        avatarView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        let titleLabel = UILabel()
        titleLabel.textColor = style.titleTint
        titleLabel.font = style.titleFont
        if let title = message?.title {
            titleLabel.text = title
        } else {
            titleLabel.text = "MEETING_WITH".localize() + " " + (message?.sender?.name ?? "")
        }
        headerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: avatarView.bottomAnchor, constant: 10).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor).isActive = true
        
        let dividerView = UIView()
        headerView.addSubview(dividerView)
        dividerView.translatesAutoresizingMaskIntoConstraints = false
        dividerView.backgroundColor = style.dividerTint
        dividerView.heightAnchor.constraint(equalToConstant: 0.3).isActive = true
        dividerView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10).isActive = true
        dividerView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -10).isActive = true
        dividerView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0).isActive = true
        dividerView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: 0).isActive = true
        
        
        self.addSubview(midView)
        midView.translatesAutoresizingMaskIntoConstraints = false
        midView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 10).isActive = true
        midView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        midView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
        midView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive = true
        
    }
    
    func buildMidForNoSlots() {
        
        guard let message = message else { return }
        
        midView.subviews.forEach({ $0.removeFromSuperview() })
        
        let containerView = UIStackView()
        containerView.axis = .vertical
        containerView.spacing = 10
        containerView.alignment = .center
        
        let spacer1 = UIView()
        spacer1.heightAnchor.constraint(equalToConstant: 10).isActive = true
        containerView.addArrangedSubview(spacer1)
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "error-clock", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
        image?.withTintColor(CometChatTheme_v4.palatte.accent900)
        icon.image = image
        icon.tintColor = CometChatTheme_v4.palatte.accent600
        icon.contentMode = .scaleAspectFill
        icon.widthAnchor.constraint(equalToConstant: 35).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 35).isActive = true
        containerView.addArrangedSubview(icon)
        
        let noSlotsAvailableLabel = UILabel()
        noSlotsAvailableLabel.textColor = CometChatTheme_v4.palatte.accent600
        noSlotsAvailableLabel.font = CometChatTheme_v4.typography.text1
        noSlotsAvailableLabel.numberOfLines = 0
        noSlotsAvailableLabel.textAlignment = .center
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        noSlotsAvailableLabel.text = "\("NO_TIME_SLOTS_AVAILABLE".localize())"
        containerView.addArrangedSubview(noSlotsAvailableLabel)
        
        let spacer2 = UIView()
        spacer2.heightAnchor.constraint(equalToConstant: 50).isActive = true
        containerView.addArrangedSubview(spacer2)
        
        midView.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.topAnchor.constraint(equalTo: midView.topAnchor, constant: 10).isActive = true
        containerView.bottomAnchor.constraint(equalTo: midView.bottomAnchor, constant: -10).isActive = true
        containerView.leadingAnchor.constraint(equalTo: midView.leadingAnchor).isActive = true
        containerView.trailingAnchor.constraint(equalTo: midView.trailingAnchor).isActive = true

        
    }
    
    func buildMidWithSlotsView() {
        
        guard let message = message else { return }
        
        midView.subviews.forEach({ $0.removeFromSuperview() })
        
        let suggestButtonContainerView = UIStackView()
        suggestButtonContainerView.axis = .vertical
        suggestButtonContainerView.spacing = 10
        suggestButtonContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        for i in 0..<min(timeSlots.count, 3)  {
            let suggestedButton = UIButton(type: .system)
            suggestedButton.backgroundColor = CometChatTheme_v4.palatte.accent50
            suggestedButton.setTitle(formatDateTime(epochDate: Int(timeSlots[i].startDate) ?? 0, timeString: timeSlots[i].startTime ), for: .normal)
            suggestedButton.tintColor = isIntractable ? style.messageTintColor : style.deactivatedTint
            suggestedButton.setTitleColor(isIntractable ? style.messageTintColor : style.deactivatedTint, for: .normal)
            suggestedButton.setTitleColor(CometChatTheme_v4.palatte.secondary, for: .focused)
            suggestedButton.titleLabel?.font = CometChatTheme_v4.typography.text2
            suggestedButton.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: 5))
            suggestedButton.borderWith(width: 0.7)
            suggestedButton.borderColor(color: isIntractable ? style.messageTintColor : style.deactivatedTint)
            suggestedButton.tag = i
            suggestedButton.backgroundColor = CometChatTheme_v4.palatte.background
            suggestedButton.translatesAutoresizingMaskIntoConstraints = false
            suggestedButton.addTarget(self, action: #selector(onTimeSelectedSelector(_:)), for: .primaryActionTriggered)
            suggestButtonContainerView.addArrangedSubview(suggestedButton)
        }
        
        midView.addSubview(suggestButtonContainerView)
        suggestButtonContainerView.topAnchor.constraint(equalTo: midView.topAnchor, constant: 0).isActive = true
        suggestButtonContainerView.leadingAnchor.constraint(equalTo: midView.leadingAnchor, constant: 25).isActive = true
        suggestButtonContainerView.trailingAnchor.constraint(equalTo: midView.trailingAnchor, constant: -25).isActive = true
        
        let durationLabel = UILabel()
        durationLabel.text = "\((message.duration))min meeting • \(TimeZone.current.getFullForm())"
        durationLabel.textColor = CometChatTheme_v4.palatte.accent700
        durationLabel.font = CometChatTheme_v4.typography.caption2
        durationLabel.translatesAutoresizingMaskIntoConstraints = false
        midView.addSubview(durationLabel)
        durationLabel.topAnchor.constraint(equalTo: suggestButtonContainerView.bottomAnchor, constant: 5).isActive = true
        durationLabel.leadingAnchor.constraint(equalTo: suggestButtonContainerView.leadingAnchor, constant: 0).isActive = true
        
        let moreTimeButton = UIButton(type: .system)
        moreTimeButton.setTitle("More times", for: .normal)
        moreTimeButton.titleLabel?.font = CometChatTheme_v4.typography.text3
        moreTimeButton.setTitleColor(isIntractable ? style.messageTintColor : style.deactivatedTint, for: .normal)
        moreTimeButton.setTitleColor(CometChatTheme_v4.palatte.secondary, for: .selected)
        midView.addSubview(moreTimeButton)
        moreTimeButton.translatesAutoresizingMaskIntoConstraints = false
        moreTimeButton.topAnchor.constraint(equalTo: durationLabel.bottomAnchor, constant: 15).isActive = true
        moreTimeButton.bottomAnchor.constraint(equalTo: midView.bottomAnchor, constant: -15).isActive = true
        moreTimeButton.centerXAnchor.constraint(equalTo: midView.centerXAnchor).isActive = true
        moreTimeButton.addTarget(self, action: #selector(onMoreTimeButtonClickedSelector), for: .primaryActionTriggered)
        
    }
    
    @objc func onMoreTimeButtonClickedSelector() {
        onMoreTimeButtonClicked?()
    }
    
    @objc func onTimeSelectedSelector(_ sender: UIButton) {
        onTimeSelected?(timeSlots[sender.tag], Date(timeIntervalSince1970: TimeInterval(Int(timeSlots[sender.tag].startDate) ?? 0)))
    }

    func formatDateTime(epochDate: Int, timeString: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(epochDate))
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "EEE, MMM d"
        let formattedDate = dateFormatter.string(from: date)
        let hour = Int(timeString.prefix(2))!
        let minute = Int(timeString.suffix(2))!

        let calendar = Calendar.current
        let components = DateComponents(hour: hour, minute: minute)
        let timeDate = calendar.date(from: components)!

        dateFormatter.dateFormat = "h:mm a"
        let formattedTime = dateFormatter.string(from: timeDate)

        return formattedDate + " at " + formattedTime
    }

}

extension SuggestionTimeView {
    
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(style: SchedulerBubbleStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(message: SchedulerMessage?) -> Self {
        self.message = message
        return self
    }
    
    @discardableResult
    public func set(onMoreTimeButtonClicked: (() -> ())?) -> Self {
        self.onMoreTimeButtonClicked = onMoreTimeButtonClicked
        return self
    }
    
    @discardableResult
    public func set(onTimeSelected: ((_: TimeRange, _:Date) -> ())?) -> Self {
        self.onTimeSelected = onTimeSelected
        return self
    }
    
    @discardableResult
    public func set(onUnavailableTimeRangeDownloaded: ((_: [String: [TimeRange]]) -> ())?) -> Self {
        self.onUnavailableTimeRangeDownloaded = onUnavailableTimeRangeDownloaded
        return self
    }
    
    @discardableResult
    public func set(isTableViewUpdating: ((_: Bool) -> ())?) -> Self {
        self.isTableViewUpdating = isTableViewUpdating
        return self
    }
    
    @discardableResult
    public func set(isIntractable: Bool) -> Self {
        self.isIntractable = isIntractable
        return self
    }
    
    @discardableResult
    public func build() -> Self {
        self.buildUI()
        return self
    }
}
