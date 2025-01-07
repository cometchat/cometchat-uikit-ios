//
//  SingleSelectElement.swift
//
//
//  Created by Abhishek Saralaya on 15/09/23.
//

import Foundation
import UIKit

@objc public class SingleSelectElement: ElementEntity {
    @objc public var optional = false
    @objc public var label = ""
    @objc public var defaultValue = ""
    @objc public var options = [OptionElement]()
    var selectedValue = ""
    
    public override init() {
        super.init()
        self.elementType = .singleSelect
    }
    
    @objc public static func singleSelectElementFromJSON(_ data:[String:Any])-> SingleSelectElement? {
        let singleSelectElement = SingleSelectElement()
        singleSelectElement.elementType = (data[InteractiveConstants.ELEMENT_TYPE] as? String)?.stringValueToElementType
        if let id = data[InteractiveConstants.ELEMENT_ID] as? String {
            singleSelectElement.elementId = id
        }
        if let text = data[InteractiveConstants.SingleSelectUIConstants.LABEL] as? String {
            singleSelectElement.label =  text
        }
        if let optional = data[InteractiveConstants.SingleSelectUIConstants.OPTIONAL] as? Bool {
            singleSelectElement.optional = optional
        }
        if let options = data[InteractiveConstants.SingleSelectUIConstants.OPTIONS] as? [[String:Any]] {
            for option in options {
                if let id = option[InteractiveConstants.SingleSelectUIConstants.LABEL] as? String, let value = option[InteractiveConstants.SingleSelectUIConstants.OPTION_VALUE] as? String {
                    let optionElement = OptionElement()
                    optionElement.id = id
                    optionElement.value = value
                    singleSelectElement.options.append(optionElement)
                }
            }
        }
        return singleSelectElement
    }
    
    public func toJSON() -> [String: Any] {
        var jsonRepresentation = [String: Any]()
        jsonRepresentation[InteractiveConstants.ELEMENT_TYPE] = "singleSelect"
        jsonRepresentation[InteractiveConstants.ELEMENT_ID] = self.elementId
        jsonRepresentation[InteractiveConstants.SingleSelectUIConstants.LABEL] = self.label
        jsonRepresentation[InteractiveConstants.SingleSelectUIConstants.OPTIONAL] = self.optional
        jsonRepresentation[InteractiveConstants.SingleSelectUIConstants.DEFAULT_VALUE] = self.defaultValue
        
        if self.options.count > 0 {
            var arrOption = [[String:Any]]()
            for option in self.options {
                var optionDict = [String:Any]()
                optionDict[InteractiveConstants.SingleSelectUIConstants.LABEL] = option.id
                optionDict[InteractiveConstants.SingleSelectUIConstants.OPTION_VALUE] = option.value
                arrOption.append(optionDict)
            }
            jsonRepresentation[InteractiveConstants.SingleSelectUIConstants.OPTIONS] = arrOption
        }
        return jsonRepresentation
    }
    
    class ToggleSwitchView: UIView {
        private let switchThumb = UIView()
        var style: FormBubbleStyle = FormBubbleStyle()
        var parentSingleSelectElement : SingleSelectElement? {
            didSet {
                if let parentSingleSelectElement = parentSingleSelectElement {
                    parentSingleSelectElement.selectedValue = parentSingleSelectElement.options.first?.value ?? ""
                }
            }
        }
        private var isOn = false {
            didSet {
                if let parentSingleSelectElement = parentSingleSelectElement {
                    parentSingleSelectElement.selectedValue = isOn ? parentSingleSelectElement.options.last?.value ?? "" : parentSingleSelectElement.options.first?.value ?? ""
                }
                setNeedsDisplay()
            }
        }
        // Options to display in the dropdown
        private var options: [OptionElement] = []
        private var color = UIColor.white
//        private let offColor = UIColor.lightGray
        private var onTextColor = UIColor.black
        private var offTextColor = UIColor.lightGray
        private var label = UILabel()
        private var label1 = UILabel()
        private var view1 = UIView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }

        private func setupView() {
            // Add switch background (off state)
//            backgroundColor = offColor
            if let parentSingleSelectElement = parentSingleSelectElement {
                parentSingleSelectElement.selectedValue = parentSingleSelectElement.options.first?.value ?? ""
            }
            color = (self.traitCollection.userInterfaceStyle == .dark) ? style.getSelectedBackgroundColor() : .clear
            if self.traitCollection.userInterfaceStyle == .dark {
                onTextColor = (self.traitCollection.userInterfaceStyle == .dark) ? style.getOptionTextColor() : style.getSelectedOptionTextColor()
                onTextColor = (self.traitCollection.userInterfaceStyle == .dark) ? style.getSelectedOptionTextColor() : style.getOptionTextColor()
            } else {
                onTextColor = (self.traitCollection.userInterfaceStyle == .dark) ? style.getSelectedOptionTextColor() : style.getOptionTextColor()
                onTextColor = (self.traitCollection.userInterfaceStyle == .dark) ? style.getOptionTextColor() : style.getSelectedOptionTextColor()
            }
            // Add switch thumb (the part that moves)
            switchThumb.backgroundColor = color
//            switchThumb.layer.cornerRadius = bounds.height / 2
            view1.backgroundColor = (self.traitCollection.userInterfaceStyle == .dark) ? .white : .lightGray
            label.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            label1.font = UIFont.systemFont(ofSize: 15, weight: .regular)
            addSubview(view1)
            addSubview(switchThumb)
            addSubview(label)
            addSubview(label1)
//            NSLayoutConstraint.activate([label.leadingAnchor.constraint(equalTo: leadingAnchor),
//                                         label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: bounds.width/2),
//                                         label.topAnchor.constraint(equalTo: topAnchor),
//                                         label.bottomAnchor.constraint(equalTo: bottomAnchor)])
            
//            NSLayoutConstraint.activate([label1.leadingAnchor.constraint(equalTo: leadingAnchor, constant: bounds.width/2),
//                                         label1.trailingAnchor.constraint(equalTo: trailingAnchor),
//                                         label1.topAnchor.constraint(equalTo: topAnchor),
//                                         label1.bottomAnchor.constraint(equalTo: bottomAnchor)])
//            label.backgroundColor = .blue
            label.textColor = isOn ? offTextColor : onTextColor
            label1.textColor = isOn ? onTextColor : offTextColor
            insertSubview(label, aboveSubview: switchThumb)
            insertSubview(label1, aboveSubview: switchThumb)

            // Add a tap gesture recognizer to toggle the switch
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toggleSwitch))
            addGestureRecognizer(tapGesture)
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            // Position the thumb based on the switch state
            label.frame = CGRect(x: 0, y: 0, width: (bounds.width / 2) - 0.25, height: bounds.height)
            label1.frame = CGRect(x: (bounds.width / 2) + 0.25, y: 0, width: (bounds.width / 2) - 0.25, height: bounds.height)
            label.textAlignment = .center
            label1.textAlignment = .center
            switchThumb.frame = isOn ? CGRect(x: (bounds.width / 2) + 0.25, y: 0, width: (bounds.width / 2) - 0.25, height: bounds.height) : CGRect(x: 0, y: 0, width: (bounds.width / 2) - 0.25, height: bounds.height)
            view1.frame = CGRect(x: (bounds.width / 2) - 0.25, y: 0, width: 0.5, height: bounds.height)
            switchThumb.backgroundColor = color
            backgroundColor = color
        }

        @objc private func toggleSwitch() {
            isOn.toggle()
            backgroundColor = color
            label.textColor = isOn ? offTextColor : onTextColor
            label1.textColor = isOn ? onTextColor : offTextColor
            setNeedsLayout()
        }
        
        func setOptions(_ options: [OptionElement]) {
            self.options = options
            label.text = options[0].id
            label1.text = options[1].id
//            titleLabel.text = options.first?.id
        }
    }
}
