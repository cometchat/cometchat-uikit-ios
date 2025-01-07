//
//  RadioButtonElement.swift
//  
//
//  Created by Admin on 15/09/23.
//

import Foundation
import UIKit

@objc public class RadioButtonElement: ElementEntity {
    @objc public var optional = false
    @objc public var label = ""
    @objc public var defaultValue = ""
    fileprivate static var radioButtons = [RadioButtonView]()
    @objc public var options = [OptionElement]()
    var selectedValue = ""
    
    public override init() {
        super.init()
        self.elementType = .radio
    }
    
    @objc public static func radioButtonElementFromJSON(_ data:[String:Any])-> RadioButtonElement? {
        let radioButtonElement = RadioButtonElement()
        radioButtonElement.elementType = (data[InteractiveConstants.ELEMENT_TYPE] as? String)?.stringValueToElementType
        if let id = data[InteractiveConstants.ELEMENT_ID] as? String {
            radioButtonElement.elementId = id
        }
        if let text = data[InteractiveConstants.RadioButtonUIConstants.LABEL] as? String {
            radioButtonElement.label =  text
        }
        if let optional = data[InteractiveConstants.RadioButtonUIConstants.OPTIONAL] as? Bool {
            radioButtonElement.optional = optional
        }
        if let defaultValue = data[InteractiveConstants.RadioButtonUIConstants.DEFAULT_VALUE] as? String {
            radioButtonElement.defaultValue = defaultValue
        }
        if let options = data[InteractiveConstants.RadioButtonUIConstants.OPTIONS] as? [[String:Any]] {
            for option in options {
                if let id = option[InteractiveConstants.RadioButtonUIConstants.LABEL] as? String, let value = option[InteractiveConstants.RadioButtonUIConstants.OPTION_VALUE] as? String {
                    let optionElement = OptionElement()
                    optionElement.id = id
                    optionElement.value = value
                    radioButtonElement.options.append(optionElement)
                }
            }
        }
        return radioButtonElement
    }
    
    public func toJSON() -> [String: Any] {
        var jsonRepresentation = [String: Any]()
        jsonRepresentation[InteractiveConstants.ELEMENT_TYPE] = "radio"
        jsonRepresentation[InteractiveConstants.ELEMENT_ID] = self.elementId
        jsonRepresentation[InteractiveConstants.RadioButtonUIConstants.LABEL] = self.label
        jsonRepresentation[InteractiveConstants.RadioButtonUIConstants.OPTIONAL] = self.optional
        jsonRepresentation[InteractiveConstants.RadioButtonUIConstants.DEFAULT_VALUE] = self.defaultValue
        
        if self.options.count > 0 {
            var arrOption = [[String:Any]]()
            for option in self.options {
                var optionDict = [String:Any]()
                optionDict[InteractiveConstants.RadioButtonUIConstants.LABEL] = option.id
                optionDict[InteractiveConstants.RadioButtonUIConstants.OPTION_VALUE] = option.value
                arrOption.append(optionDict)
            }
            jsonRepresentation[InteractiveConstants.RadioButtonUIConstants.OPTIONS] = arrOption
        }
        return jsonRepresentation
    }
    
    class RadioButtonView: UIView {
        var parentRadioButtonElement: RadioButtonElement?
        private var isSelected = false {
            didSet {
                setNeedsDisplay()
            }
        }
        private let indicatorView = UIView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setupView()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupView()
        }

        private func setupView() {
            // Add a circle as the radio button indicator
            indicatorView.frame = CGRect(x: 5, y: 5, width: 20, height: 20)
            indicatorView.layer.cornerRadius = indicatorView.bounds.width / 2
            let view1 = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
            view1.layer.cornerRadius = view1.bounds.width / 2
            view1.layer.borderWidth = 1.0
            view1.layer.borderColor = (self.traitCollection.userInterfaceStyle == .dark) ? UIColor.white.cgColor : UIColor.black.cgColor
            addSubview(indicatorView)
            addSubview(view1)
            RadioButtonElement.radioButtons.append(self)
            // Add a tap gesture to toggle the selection
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(radioButtonTapped))
            addGestureRecognizer(tapGesture)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                if let parentRadioButtonElement = self.parentRadioButtonElement, self.tag != -1 {
                    if parentRadioButtonElement.defaultValue == parentRadioButtonElement.options[self.tag].value {
                        self.radioButtonTapped()
                    } else if parentRadioButtonElement.defaultValue.isEmpty && self.tag == 0 {
                        self.radioButtonTapped()
                    }
                }
            })
        }

        @objc func radioButtonTapped() {
            if !isSelected {
                isSelected.toggle()
                updateIndicator()
                if let parentRadioButtonElement = parentRadioButtonElement, tag != -1 {
                    parentRadioButtonElement.selectedValue = parentRadioButtonElement.options[tag].value
                }
                for radioButton in RadioButtonElement.radioButtons {
                    if self != radioButton, radioButton.isSelected == true, let containerView = self.superview?.superview, let radioContainerView = radioButton.superview?.superview, radioContainerView == containerView {
                        radioButton.isSelected.toggle()
                        radioButton.updateIndicator()
                    }
                }
            }
        }

        private func updateIndicator() {
            indicatorView.backgroundColor = isSelected ? CometChatTheme_v4.palatte.primary : UIColor.clear
        }
    }
}
