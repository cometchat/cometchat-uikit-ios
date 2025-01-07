//
//  TextInputElement.swift
//  
//
//  Created by Abhishek Saralaya on 15/09/23.
//

import Foundation

@objc public class TextInputElement: ElementEntity {
    public var optional:Bool?
    @objc public var label = ""
    public var maximum: Int?
    @objc public var placeHolder = "Enter text here..."
    @objc public var defaultValue = ""
    @objc public var text = ""
    
    public override init() {
        super.init()
        self.elementType = .textInput
    }
    
    @objc public static func textInputElementFromJSON(_ data:[String:Any])-> TextInputElement? {
        let textInputElement = TextInputElement()
        textInputElement.elementType = (data[InteractiveConstants.ELEMENT_TYPE] as? String)?.stringValueToElementType
        if let id = data[InteractiveConstants.ELEMENT_ID] as? String {
            textInputElement.elementId = id
        }
        if let placeholder = data[InteractiveConstants.TextInputUIConstants.PLACEHOLDER] as? [String:Any], let text = placeholder[InteractiveConstants.TextInputUIConstants.PLACEHOLDER_TEXT] as? String {
            textInputElement.placeHolder =  text
        }
        if let label = data[InteractiveConstants.TextInputUIConstants.LABEL] as? String {
            textInputElement.label = label
        }
        if let defaultValue = data[InteractiveConstants.TextInputUIConstants.DEFAULT_VALUE] as? String {
            textInputElement.defaultValue = defaultValue
        }
        if let optional = data[InteractiveConstants.TextInputUIConstants.OPTIONAL] as? Bool {
            textInputElement.optional = optional
        }
        return textInputElement
    }
    
    public func toJSON() -> [String: Any] {
        var jsonRepresentation = [String: Any]()
        jsonRepresentation[InteractiveConstants.ELEMENT_TYPE] = "textInput"
        
        jsonRepresentation[InteractiveConstants.ELEMENT_ID] = self.elementId
        
        var jsonPlaceholder = [String:Any]()
        
        jsonPlaceholder[InteractiveConstants.TextInputUIConstants.PLACEHOLDER_TEXT] = self.placeHolder
        
        jsonRepresentation[InteractiveConstants.TextInputUIConstants.PLACEHOLDER] = jsonPlaceholder
        
        jsonRepresentation[InteractiveConstants.TextInputUIConstants.LABEL] = self.label
        
        jsonRepresentation[InteractiveConstants.TextInputUIConstants.DEFAULT_VALUE] = self.defaultValue
        
        if let value = self.optional {
            jsonRepresentation[InteractiveConstants.TextInputUIConstants.OPTIONAL] = value
        }
        
        
        return jsonRepresentation
    }
}
