//
//  CheckboxElement.swift
//  
//
//  Created by Admin on 15/09/23.
//

import Foundation
import UIKit

@objc public class CheckboxElement: ElementEntity {
    @objc public var optional = false
    @objc public var label = ""
    @objc public var defaultValues = [String]()
    @objc public var options = [OptionElement]()
    var selectedValues = [String]()
    
    public override init() {
        super.init()
        self.elementType = .checkbox
    }
    
    @objc public static func checkboxElementFromJSON(_ data:[String:Any])-> CheckboxElement? {
        let checkboxElement = CheckboxElement()
        checkboxElement.elementType = (data[InteractiveConstants.ELEMENT_TYPE] as? String)?.stringValueToElementType
        if let id = data[InteractiveConstants.ELEMENT_ID] as? String {
            checkboxElement.elementId = id
        }
        if let text = data[InteractiveConstants.CheckBoxUIConstants.LABEL] as? String {
            checkboxElement.label =  text
        }
        if let optional = data[InteractiveConstants.CheckBoxUIConstants.OPTIONAL] as? Bool {
            checkboxElement.optional = optional
        }
        if let defaultValues = data[InteractiveConstants.CheckBoxUIConstants.DEFAULT_VALUE] as? [String] {
            checkboxElement.defaultValues = defaultValues
        }
        if let options = data[InteractiveConstants.CheckBoxUIConstants.OPTIONS] as? [[String:Any]] {
            for option in options {
                if let id = option[InteractiveConstants.CheckBoxUIConstants.LABEL] as? String, let value = option[InteractiveConstants.CheckBoxUIConstants.OPTION_VALUE] as? String {
                    let optionElement = OptionElement()
                    optionElement.id = id
                    optionElement.value = value
                    checkboxElement.options.append(optionElement)
                }
            }
        }
        return checkboxElement
    }
    
    public func toJSON() -> [String: Any] {
        var jsonRepresentation = [String: Any]()
        jsonRepresentation[InteractiveConstants.ELEMENT_TYPE] = "checkbox"
        jsonRepresentation[InteractiveConstants.ELEMENT_ID] = self.elementId
        jsonRepresentation[InteractiveConstants.CheckBoxUIConstants.LABEL] = self.label
        jsonRepresentation[InteractiveConstants.CheckBoxUIConstants.OPTIONAL] = self.optional
        jsonRepresentation[InteractiveConstants.CheckBoxUIConstants.DEFAULT_VALUE] = self.defaultValues
        
        if self.options.count > 0 {
            var arrOption = [[String:Any]]()
            for option in self.options {
                var optionDict = [String:Any]()
                optionDict[InteractiveConstants.CheckBoxUIConstants.LABEL] = option.id
                optionDict[InteractiveConstants.CheckBoxUIConstants.OPTION_VALUE] = option.value
                arrOption.append(optionDict)
            }
            jsonRepresentation[InteractiveConstants.CheckBoxUIConstants.OPTIONS] = arrOption
        }
        return jsonRepresentation
    }
    
    public class AddtionalView: UIView {
        var parentCheckBoxElement: CheckboxElement?
        var isChecked: Bool = false {
            didSet {
                if self.tag != -1, let parentCheckBoxElement = self.parentCheckBoxElement {
                    if isChecked {
                        if !parentCheckBoxElement.selectedValues.contains(self.parentCheckBoxElement!.options[tag].value) {
                            parentCheckBoxElement.selectedValues.append(parentCheckBoxElement.options[tag].value)
                        }
                    } else {
                        if parentCheckBoxElement.selectedValues.contains(parentCheckBoxElement.options[tag].value), let index = parentCheckBoxElement.selectedValues.firstIndex(of: (parentCheckBoxElement.options[tag].value)) {
                            parentCheckBoxElement.selectedValues.remove(at: index)
                        }
                    }
                        
                }
                setNeedsDisplay()
            }
        }
        var style = FormBubbleStyle()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
                if let parentCheckBoxElement = self.parentCheckBoxElement, self.tag != -1 {
                    if parentCheckBoxElement.defaultValues.contains(where: {$0 == parentCheckBoxElement.options[self.tag].value}) {
                        self.isChecked.toggle()
                    }
                }
            })
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            backgroundColor = .clear
        }
        
        public override func draw(_ rect: CGRect) {
            super.draw(rect)
            
            let checkboxFrame = CGRect(x: 1, y: 1, width: rect.height - 2, height: rect.height - 2)
            
            let checkboxPath = UIBezierPath(roundedRect: checkboxFrame, cornerRadius: 5.0)
            checkboxPath.lineWidth = 1.0
            
            // Set the checkbox fill color based on its state
            if isChecked {
                style.getButtonBackgroundColor().setFill()
            } else {
                style.background.setFill()
            }
            layer.borderColor = style.borderColor.cgColor
            layer.borderWidth = 1
            
            UIColor.black.setStroke()
            checkboxPath.stroke()
            checkboxPath.fill()
            
            // Draw the checkmark if the checkbox is checked
            if isChecked {
                let checkmarkPath = UIBezierPath()
                checkmarkPath.move(to: CGPoint(x: 8, y: 12))
                checkmarkPath.addLine(to: CGPoint(x: 12, y: 16))
                checkmarkPath.addLine(to: CGPoint(x: 20, y: 8))
                checkmarkPath.lineWidth = 2.0
                UIColor.white.setStroke()
                checkmarkPath.stroke()
            }
        }
        
        public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
            isChecked.toggle()
        }
        
        @objc func onCheckBoxClickAction() {
            isChecked.toggle()
            if isChecked {
                style.getButtonBackgroundColor().setFill()
            } else {
                style.background.setFill()
            }
        }
    }
       
}


