//
//  LabelInputElement.swift
//
//
//  Created by Abhishek Saralaya on 15/09/23.
//

import Foundation

@objc public class LabelElement: ElementEntity {
    @objc public var text = ""
    
    public override init() {
        super.init()
        self.elementType = .label
    }
    
    @objc public static func labelElementFromJSON(_ data:[String:Any])-> LabelElement? {
        let labelElement = LabelElement()
        labelElement.elementType = (data[InteractiveConstants.ELEMENT_TYPE] as? String)?.stringValueToElementType
        if let id = data[InteractiveConstants.ELEMENT_ID] as? String {
            labelElement.elementId = id
        }
        if let text = data[InteractiveConstants.LabelUIConstants.TEXT] as? String {
            labelElement.text =  text
        }
        return labelElement
    }
    
    public func toJSON() -> [String: Any] {
        var jsonRepresentation = [String: Any]()
        
        jsonRepresentation[InteractiveConstants.ELEMENT_TYPE] = "label"
        jsonRepresentation[InteractiveConstants.ELEMENT_ID] = self.elementId
        jsonRepresentation[InteractiveConstants.TEXT] = self.text
        
        
        return jsonRepresentation
    }
}
