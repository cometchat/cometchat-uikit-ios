//
//  ElementEntity.swift
//  
//
//  Created by Abhishek Saralaya on 15/09/23.
//

import Foundation
import UIKit

@objc public class ElementEntity: NSObject {
    public var elementType: elementType?
    @objc public var elementId: String = ""
    
    @objc public static func entityFromJSON(_ data:[String:Any])-> ElementEntity? {
        if let type = data[InteractiveConstants.ELEMENT_TYPE] as? String, let elementType_ = type.stringValueToElementType, elementType_ == .label {
            return LabelElement.labelElementFromJSON(data)
        } else if let type = data[InteractiveConstants.ELEMENT_TYPE] as? String, let elementType_ = type.stringValueToElementType, elementType_ == .textInput {
            return TextInputElement.textInputElementFromJSON(data)
        } else if let type = data[InteractiveConstants.ELEMENT_TYPE] as? String, let elementType_ = type.stringValueToElementType, elementType_ == .button {
            return ButtonElement.buttonElementFromJSON(data)
        } else if let type = data[InteractiveConstants.ELEMENT_TYPE] as? String, let elementType_ = type.stringValueToElementType, elementType_ == .checkbox {
            return CheckboxElement.checkboxElementFromJSON(data)
        } else if let type = data[InteractiveConstants.ELEMENT_TYPE] as? String, let elementType_ = type.stringValueToElementType, elementType_ == .radio {
            return RadioButtonElement.radioButtonElementFromJSON(data)
        }else if let type = data[InteractiveConstants.ELEMENT_TYPE] as? String, let elementType_ = type.stringValueToElementType, elementType_ == .dropdown {
            return DropdownElement.dropdownElementFromJSON(data)
        }else if let type = data[InteractiveConstants.ELEMENT_TYPE] as? String, let elementType_ = type.stringValueToElementType, elementType_ == .singleSelect {
            return SingleSelectElement.singleSelectElementFromJSON(data)
        }else if let type = data[InteractiveConstants.ELEMENT_TYPE] as? String, let elementType_ = type.stringValueToElementType, elementType_ == .dateTime {
            return DateTimeElement.fromJson(data)
        }
        return nil
    }
    
}


public enum elementType {
    case textInput
    case button
    case label
    case checkbox
    case dropdown
    case radio
    case singleSelect
    case dateTime
    
    internal var value:String {
        
        switch self {
        case .textInput:
            return "textInput";
        case .button:
            return "button";
        case .label:
            return "label"
        case .checkbox:
            return "checkbox"
        case .dropdown:
            return "dropdown"
        case .radio:
            return "radio"
        case .singleSelect:
            return "singleSelect"
        case .dateTime:
            return "dateTime"
        }
    }
}

extension String {
    
    public var stringValueToElementType: elementType?{
        
        if self.compare(elementType.textInput.value) == .orderedSame {
            return .textInput;
        }
        else if self.compare(elementType.button.value) == .orderedSame {
            return .button;
        }
        else if self.compare(elementType.label.value) == .orderedSame {
            return .label;
        }
        else if self.compare(elementType.checkbox.value) == .orderedSame {
            return .checkbox;
        }
        else if self.compare(elementType.dropdown.value) == .orderedSame {
            return .dropdown;
        }
        else if self.compare(elementType.radio.value) == .orderedSame {
            return .radio;
        }
        else if self.compare(elementType.singleSelect.value) == .orderedSame {
            return .singleSelect;
        }
        else if self.compare(elementType.dateTime.value) == .orderedSame {
            return .dateTime
        }
        return nil;
    }
}
