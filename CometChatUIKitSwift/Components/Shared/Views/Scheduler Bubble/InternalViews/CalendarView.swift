//
//  CalendarSelectionView.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 27/12/23.
//

import Foundation
import UIKit

class CalendarView: UIView {
    
    private(set) weak var controller: UIViewController?
    private(set) var style = SchedulerBubbleStyle()
    private(set) var message: SchedulerMessage?
    private(set) var onBackButtonClicked: (() -> ())?
    private(set) var onDateSelected: ((_ date: Date) -> ())?
    
    var headingView = UIView()
    
    var middleView: UIStackView = {
        let middleView = UIStackView()
        middleView.axis = .vertical
        middleView.spacing = 15
        middleView.translatesAutoresizingMaskIntoConstraints = false
        return middleView
    }()
    
    lazy var uiCalendar: UIDatePicker = {
        var uiCalendar = UIDatePicker()
        uiCalendar.translatesAutoresizingMaskIntoConstraints = false
        uiCalendar.datePickerMode = .date
        uiCalendar.tintColor = style.messageTintColor
        if let message = message {
            uiCalendar.minimumDate = Date(timeIntervalSince1970: TimeInterval(message.dateRangeStart))
            uiCalendar.maximumDate = Date(timeIntervalSince1970: TimeInterval(message.dateRangeEnd))
        }
        if #available(iOS 14.0, *) {
            uiCalendar.preferredDatePickerStyle = .inline
        }
        uiCalendar.layoutIfNeeded()
        ///doing this because valueChanged callback will not work when the already selected date is tapped
        selectedDateContainerView = uiCalendar.findViewContainingLabel(withText: Date().extractDay())
        uiCalendar.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        return uiCalendar
    }()
    
    lazy var onTapGestureForSelectedDate = UITapGestureRecognizer(target: self, action: #selector(onTapped))
    var selectedDateContainerView: UIView? {
        didSet {
            oldValue?.removeGestureRecognizer(onTapGestureForSelectedDate)
            selectedDateContainerView?.addGestureRecognizer(onTapGestureForSelectedDate)
        }
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buildUI() {
        
        self.translatesAutoresizingMaskIntoConstraints = false
        buildHeader()
        buildCalendarView()
    }
    
    func buildCalendarView() {
                
        let selectDateContainer = UIStackView()
        selectDateContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let selectDateLabel = UILabel()
        selectDateLabel.text = "SELECT_A_DAY".localize()
        selectDateLabel.textColor = CometChatTheme_v4.palatte.accent600
        selectDateLabel.font = CometChatTheme_v4.typography.text1
        
        selectDateContainer.addArrangedSubview(selectDateLabel)
        selectDateContainer.isLayoutMarginsRelativeArrangement = true
        selectDateContainer.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
        middleView.addArrangedSubview(selectDateContainer)
        middleView.setCustomSpacing(-10, after: selectDateContainer)
        
        middleView.addArrangedSubview(uiCalendar)
        middleView.setCustomSpacing(0, after: uiCalendar)
        
        let containerStackView = UIStackView()
        containerStackView.axis = .horizontal
        containerStackView.spacing = 5
        containerStackView.distribution = .fill
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        containerStackView.addArrangedSubview(UIView())
        
        let icon = UIImageView()
        icon.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "time-zone-earth", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
        image?.withTintColor(CometChatTheme_v4.palatte.accent900)
        icon.image = image
        icon.tintColor = CometChatTheme_v4.palatte.accent900
        icon.contentMode = .scaleAspectFill
        icon.widthAnchor.constraint(equalToConstant: 13).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 13).isActive = true
        containerStackView.addArrangedSubview(icon)
        
        let textLabel = UILabel()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.textColor = CometChatTheme_v4.palatte.accent900
        textLabel.font = CometChatTheme_v4.typography.caption1
        textLabel.text = "\(TimeZone.current.getFullForm())"
        textLabel.sizeToFit()
        containerStackView.addArrangedSubview(textLabel)
        
        middleView.addArrangedSubview(containerStackView)
        middleView.setCustomSpacing(5, after: containerStackView)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: 0).isActive = true
        middleView.setCustomSpacing(30, after: spacer)
        middleView.addArrangedSubview(spacer)
        
        self.addSubview(middleView)
        middleView.topAnchor.constraint(equalTo: headingView.bottomAnchor, constant: 0).isActive = true
        middleView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
        middleView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        middleView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -15).isActive = true
    }
    
    @objc func onTapped() {
        datePickerChanged(picker: uiCalendar)
    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        if picker.date < picker.minimumDate! && picker.date > picker.maximumDate! {
            return
        }
        selectedDateContainerView = picker.findViewContainingLabel(withText: picker.date.extractDay())
        onDateSelected?(picker.date)
        return
    }
    
    func buildHeader() {
        guard let message = message else { return }
        headingView = SchedulerHeaderView.getHeaderView(message: message, style: style, onBackButtonClicked:  #selector(onBackButtonClickedSelector), target: self)
        headingView.translatesAutoresizingMaskIntoConstraints = false
        headingView.layoutIfNeeded()
        self.addSubview(headingView)
        headingView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0).isActive = true
        headingView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
        headingView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
    }
    
    @objc func onBackButtonClickedSelector() {
        self.onBackButtonClicked?()
    }
    
}

extension CalendarView {
    
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
    public func set(onBackButtonClicked: (() -> ())?) -> Self {
        self.onBackButtonClicked = onBackButtonClicked
        return self
    }
    
    @discardableResult
    public func set(onDateSelected: ((_ date: Date) -> ())?) -> Self {
        self.onDateSelected = onDateSelected
        return self
    }
    
    @discardableResult
    public func build() -> Self {
        self.buildUI()
        return self
    }
    
}

extension UIView {
    func findViewContainingLabel(withText searchText: String) -> UIView? {
        for subview in subviews {
            if let label = subview as? UILabel, label.text == searchText {
                return self
            } else if let nestedView = subview.findViewContainingLabel(withText: searchText) {
                return nestedView
            }
        }
        return nil
    }
}


extension Date {
    func extractDay() -> String {
        let calendar = Calendar.current
        let dayComponent = calendar.component(.day, from: self)
        return String(dayComponent)
    }
}
