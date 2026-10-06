//
//  OptionElement.swift
//  
//
//  Created by Abhishek Saralaya on 15/09/23.
//

import Foundation

@objc public class OptionElement: NSObject {
    @objc public var id = ""
    @objc public var value = ""
    @objc public var selectedValue = ""

    /// Builds an option from a server payload entry. The value is read from
    /// "value", falling back to "id"; the display label (stored in `id`) is read
    /// from "label", falling back to the value. An entry with neither a value nor
    /// an id is rejected.
    static func optionFromJSON(_ option: [String: Any]) -> OptionElement? {
        guard let value = (option[InteractiveConstants.OptionElementConstants.VALUE] as? String)
                ?? (option[InteractiveConstants.RadioButtonUIConstants.OPTION_ID] as? String) else {
            return nil
        }
        let optionElement = OptionElement()
        optionElement.id = option[InteractiveConstants.OptionElementConstants.LABEL] as? String ?? value
        optionElement.value = value
        return optionElement
    }
}

