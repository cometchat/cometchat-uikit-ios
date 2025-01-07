//
//  DateTimePickerElement.swift
//  CometChatUIKitSwift
//
//  Created by SuryanshBisen on 08/01/24.
//

import UIKit
import Foundation

public class DateTimeElement: ElementEntity {
    public var isOptional: Bool = false
    public var label: String = ""
    public var defaultValue: Int?
    public var mode: DateTimePickerMode = .dateTime
    public var fromDateTime: Int = 0
    public var toDateTime: Int = 0
    public var dateTimeFormat: String = "dd-MM-YYYY: HH:mm a"
    public var timeZone: String = ""
    
    internal var selectedDateTime: [String: Any]?
    
    public override init() {
        super.init()
        self.elementType = .dateTime
    }
    
    @objc public static func fromJson(_ data: [String: Any]) -> DateTimeElement {
        let dateTimePicker = DateTimeElement()
        
        if let elementId = data[InteractiveConstants.ELEMENT_ID] as? String {
            dateTimePicker.elementId = elementId
        }
        if let isOptional = data[InteractiveConstants.DateTimeConstants.OPTIONAL] as? Bool {
            dateTimePicker.isOptional = isOptional
        }
        if let label = data[InteractiveConstants.DateTimeConstants.LABEL] as? String {
            dateTimePicker.label = label
        }
        if let timeZone = data[InteractiveConstants.DateTimeConstants.TIME_ZONE] as? String {
            dateTimePicker.timeZone = timeZone
        }
        
        if let mode = data[InteractiveConstants.DateTimeConstants.MODE] as? String {
            dateTimePicker.mode = DateTimePickerMode(value: mode)
        }
        
        if let dateTimeFormat = data[InteractiveConstants.DateTimeConstants.DATE_TIME_FORMATE] as? String {
            dateTimePicker.dateTimeFormat = dateTimeFormat
        }else {
            if dateTimePicker.mode == .time {
                dateTimePicker.dateTimeFormat = "HH:mm a"
            } else if dateTimePicker.mode == .date {
                dateTimePicker.dateTimeFormat = "dd-MM-YYYY"
            } else {
                dateTimePicker.dateTimeFormat = "dd-MM-YYYY HH:mm a"
            }
        }
        
        if let defaultValue = data[InteractiveConstants.DateTimeConstants.DEFAULT_VALUE] as? String {
            let dateFormater = DateFormatter()
            if dateTimePicker.mode == .time {
                dateFormater.dateFormat = "HH:mm"
            } else if dateTimePicker.mode == .date {
                dateFormater.dateFormat = "yyyy-MM-dd"
            } else {
                dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm"
            }
            dateFormater.timeZone = TimeZone(identifier: dateTimePicker.timeZone)
            dateTimePicker.defaultValue = Int(dateFormater.date(from: defaultValue)?.timeIntervalSince1970 ?? 0)
        }

        if let fromDateTime = data[InteractiveConstants.DateTimeConstants.FROM] as? String {
            let dateFormater = DateFormatter()
            if dateTimePicker.mode == .time {
                dateFormater.dateFormat = "HH:mm"
            } else if dateTimePicker.mode == .date {
                dateFormater.dateFormat = "yyyy-MM-dd"
            } else {
                dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm"
            }
            dateFormater.timeZone = TimeZone(identifier: dateTimePicker.timeZone)
            dateTimePicker.fromDateTime = Int(dateFormater.date(from: fromDateTime)?.timeIntervalSince1970 ?? 0)
        }
        if let todateTime = data[InteractiveConstants.DateTimeConstants.TO] as? String {
            let dateFormater = DateFormatter()
            if dateTimePicker.mode == .time {
                dateFormater.dateFormat = "HH:mm"
            } else if dateTimePicker.mode == .date {
                dateFormater.dateFormat = "yyyy-MM-dd"
            } else {
                dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm"
            }
            dateFormater.timeZone = TimeZone(identifier: dateTimePicker.timeZone)
            dateTimePicker.toDateTime = Int(dateFormater.date(from: todateTime)?.timeIntervalSince1970 ?? 0)
        }
        
        return dateTimePicker
    }
    
    public func toJSON() -> [String: Any] {
        var jsonRepresentation = [String: Any]()
        jsonRepresentation[InteractiveConstants.ELEMENT_TYPE] = "dateTime"
        jsonRepresentation[InteractiveConstants.ELEMENT_ID] = self.elementId
        jsonRepresentation[InteractiveConstants.DateTimeConstants.LABEL] = self.label
        jsonRepresentation[InteractiveConstants.DateTimeConstants.OPTIONAL] = self.isOptional
        jsonRepresentation[InteractiveConstants.DateTimeConstants.TIME_ZONE] = self.timeZone
        jsonRepresentation[InteractiveConstants.DateTimeConstants.MODE] = self.mode.valueToString()
        jsonRepresentation[InteractiveConstants.DateTimeConstants.DATE_TIME_FORMATE] = self.dateTimeFormat
        
        if let value = self.defaultValue {
            let dateFormater = DateFormatter()
            if self.mode == .time {
                dateFormater.dateFormat = "HH:mm"
            } else if self.mode == .date {
                dateFormater.dateFormat = "yyyy-MM-dd"
            } else {
                dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm"
            }
            dateFormater.timeZone = TimeZone(identifier: self.timeZone)
            let date = Date(timeIntervalSince1970: TimeInterval(value))
            let dateString = dateFormater.string(from: date)
            jsonRepresentation[InteractiveConstants.DateTimeConstants.DEFAULT_VALUE] = dateString
        }
        
        if self.fromDateTime > 0 {
            let dateFormater = DateFormatter()
            if self.mode == .time {
                dateFormater.dateFormat = "HH:mm"
            } else if self.mode == .date {
                dateFormater.dateFormat = "yyyy-MM-dd"
            } else {
                dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm"
            }
            dateFormater.timeZone = TimeZone(identifier: self.timeZone)
            let date = Date(timeIntervalSince1970: TimeInterval(self.fromDateTime))
            let dateString = dateFormater.string(from: date)
            jsonRepresentation[InteractiveConstants.DateTimeConstants.FROM] = dateString
        }
        
        if self.toDateTime > 0 {
            let dateFormater = DateFormatter()
            if self.mode == .time {
                dateFormater.dateFormat = "HH:mm"
            } else if self.mode == .date {
                dateFormater.dateFormat = "yyyy-MM-dd"
            } else {
                dateFormater.dateFormat = "yyyy-MM-dd'T'HH:mm"
            }
            dateFormater.timeZone = TimeZone(identifier: self.timeZone)
            let date = Date(timeIntervalSince1970: TimeInterval(self.toDateTime))
            let dateString = dateFormater.string(from: date)
            jsonRepresentation[InteractiveConstants.DateTimeConstants.TO] = dateString
        }
        
        return jsonRepresentation
    }
}

extension DateTimeElement {
    
    class DateTimePickerView: UIStackView {
        
        var style = FormBubbleStyle()
        weak var controller: UIViewController?
        var dateTextButton = UIButton()
        var datePickerIconButton = UIButton()
        var calendarIcon = UIImage(named: "calendar", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
        var closeIcon = UIImage(named: "message-composer-close", in: CometChatUIKit.bundle, with: nil)?.withRenderingMode(.alwaysTemplate)
        var isDateTimeSelected = false
        var element: DateTimeElement?
        
        lazy var dateTimePicker: UIDatePicker = {
            let datePicker = UIDatePicker()
            if #available(iOS 14.0, *) {
                datePicker.preferredDatePickerStyle = .inline
            }
            if let element = element {
                datePicker.minimumDate = Date(timeIntervalSince1970: TimeInterval(element.fromDateTime))
                datePicker.maximumDate = Date(timeIntervalSince1970: TimeInterval(element.toDateTime))
            }
            datePicker.date = Date(timeIntervalSince1970: TimeInterval(element?.defaultValue ?? 0))
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            datePicker.tintColor = CometChatTheme_v4.palatte.primary
            
            switch element?.mode {
            case .date:
                datePicker.datePickerMode = .date
            case .time:
                datePicker.datePickerMode = .time
                if #available(iOS 13.4, *) {
                    datePicker.preferredDatePickerStyle = .wheels
                }
            case .dateTime:
                datePicker.datePickerMode = .dateAndTime
            case .none:
                break
            case .some(_):
                break
            }
            return datePicker
        }()
        
        override init(frame: CGRect) {
            super.init(frame: UIScreen.main.bounds)
        }
        
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func build() {
            
            guard let element = element else { return }
            
            self.axis = .horizontal
            self.distribution = .fill
            self.spacing = 10
            self.translatesAutoresizingMaskIntoConstraints = false
            self.borderWith(width: style.getInputStrokeWidth())
            self.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: 5))
            self.borderColor(color: style.getInputStrokeColor())
            self.isLayoutMarginsRelativeArrangement = true
            self.backgroundColor(color: self.traitCollection.userInterfaceStyle == .dark ? CometChatTheme_v4.palatte.accent50 : .clear)
            self.layoutMargins = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
            
            dateTextButton.setTitle("Tap here to select \(DateTimePickerView.getTextAccordingToMode(element: element))", for: .normal)
            dateTextButton.setTitleColor(style.getInputHintColor(), for: .normal)
            dateTextButton.titleLabel?.font = CometChatTheme_v4.typography.caption1
            dateTextButton.backgroundColor = .clear
            dateTextButton.contentHorizontalAlignment = .left
            dateTextButton.addTarget(self, action: #selector(self.onTapped), for: .primaryActionTriggered)
            dateTextButton.translatesAutoresizingMaskIntoConstraints = false
            dateTextButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
            self.addArrangedSubview(dateTextButton)
            
            datePickerIconButton.translatesAutoresizingMaskIntoConstraints = false
            datePickerIconButton.widthAnchor.constraint(equalToConstant: 15).isActive = true
            datePickerIconButton.heightAnchor.constraint(equalToConstant: 15).isActive = true
            datePickerIconButton.imageView?.contentMode = .scaleAspectFit
            datePickerIconButton.setImageTintColor(CometChatTheme_v4.palatte.accent900)
            datePickerIconButton.addTarget(self, action: #selector(self.onIconTapped), for: .primaryActionTriggered)
            datePickerIconButton.setImage(calendarIcon, for: .normal)
            
            if let defaultValue = element.defaultValue {
                dateTextButton.setTitle("\(Date(timeIntervalSince1970: TimeInterval(defaultValue)).reduceTo(customFormate: element.dateTimeFormat ))", for: .normal)
                datePickerIconButton.setImage(closeIcon, for: .normal)
                dateTextButton.setTitleColor(CometChatTheme_v4.palatte.accent900, for: .normal)
                isDateTimeSelected = true
            }
            
            self.addArrangedSubview(datePickerIconButton)
            
        }
        
        @objc func onTapped() {
            let dateChooserAlert = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
            dateChooserAlert.view.addSubview(dateTimePicker)
            dateTimePicker.translatesAutoresizingMaskIntoConstraints = false
            dateTimePicker.topAnchor.constraint(equalTo: dateChooserAlert.view.topAnchor, constant: 5).isActive = true
            dateTimePicker.leadingAnchor.constraint(equalTo: dateChooserAlert.view.leadingAnchor).isActive = true
            dateTimePicker.trailingAnchor.constraint(equalTo: dateChooserAlert.view.trailingAnchor).isActive = true
            dateChooserAlert.view.heightAnchor.constraint(
                equalToConstant: dateTimePicker.datePickerMode == .time ? 300 : 480
            ).isActive = true
            dateChooserAlert.addAction(UIAlertAction(title: "Done", style: .cancel, handler: { [weak self] action in
                guard let this = self else { return }
                this.dateTextButton.setTitle("\(this.dateTimePicker.date.reduceTo(customFormate: this.element?.dateTimeFormat ?? "") )", for: .normal)
                this.dateTextButton.setTitleColor(CometChatTheme_v4.palatte.accent900, for: .normal)
                this.dateTextButton.contentHorizontalAlignment = .left
                this.datePickerIconButton.setImage(this.closeIcon, for: .normal)
                this.isDateTimeSelected = true
                this.borderColor(color: this.style.getInputStrokeColor())
                dateChooserAlert.dismiss(animated: true)
                this.setData()
            }))
            controller?.present(dateChooserAlert, animated: true, completion: nil)
        }
        
        @objc func onIconTapped() {
            
            if !isDateTimeSelected {
                onTapped()
            }
            
            dateTextButton.setTitle("Tap here to select \(DateTimePickerView.getTextAccordingToMode(element: element))", for: .normal)
            dateTextButton.setTitleColor(style.getInputHintColor(), for: .normal)
            dateTextButton.contentHorizontalAlignment = .left
            self.datePickerIconButton.setImage(self.calendarIcon, for: .normal)
            isDateTimeSelected = false
            element?.selectedDateTime = nil
        }
        
        static func getTextAccordingToMode(element: DateTimeElement?) -> String {
            switch element?.mode {
            case .date:
                return "date"
            case .time:
                return "time"
            case .dateTime:
                return "date & time"
            case .none:
                break
            case .some(_):
                break
            }
            
            return ""
        }
        
        func setData() {
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            
            var selectedDateData = [String: Any]()
            
            if element?.mode != .time {
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                selectedDateData = [
                    InteractiveConstants.DateTimeConstants.VALUE: dateFormatter.string(from: dateTimePicker.date),
                    InteractiveConstants.DateTimeConstants.TIME_ZONE: TimeZone.current.identifier,
                ]
            }else {
                dateFormatter.dateFormat = "HH:mm:ss"
                selectedDateData = [
                    InteractiveConstants.DateTimeConstants.VALUE: dateFormatter.string(from: dateTimePicker.date),
                    InteractiveConstants.DateTimeConstants.TIME_ZONE: TimeZone.current.identifier
                ]
            }
            
            element?.selectedDateTime = selectedDateData
        }
        
    }
    
}

public enum DateTimePickerMode {
    case dateTime
    case date
    case time
    
    init(value: String) {
        switch value {
        case "dateTime":
            self = .dateTime
        case "date":
            self = .date
        case "time":
            self = .time
        default:
            self = .dateTime
        }
    }
    
    func valueToString() -> String {
        
        if self == .dateTime {
            return "dateTime"
        }
        else if self == .date {
            return "date"
        }
        else if self == .time {
            return "time"
        }
        return "";
    }
}
